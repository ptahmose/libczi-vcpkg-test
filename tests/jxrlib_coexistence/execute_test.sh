#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 1 ]]; then
  echo "Usage: $0 <PATH_TO_VCPKG_DIR>"
  exit 2
fi

VCPKG_DIR="$1"

# Resolve absolute vcpkg path
if [[ ! -d "$VCPKG_DIR" ]]; then
  echo "Error: '$VCPKG_DIR' is not a directory."
  exit 1
fi
VCPKG_DIR_ABS="$(cd "$VCPKG_DIR" && pwd -P)"

# Find vcpkg binary
if [[ -x "$VCPKG_DIR_ABS/vcpkg" ]]; then
  VCPKG_BIN="$VCPKG_DIR_ABS/vcpkg"
elif [[ -x "$VCPKG_DIR_ABS/vcpkg.exe" ]]; then
  VCPKG_BIN="$VCPKG_DIR_ABS/vcpkg.exe"
else
  echo "Error: vcpkg binary not found. Did you bootstrap this checkout?"
  echo "Hint: $VCPKG_DIR_ABS/bootstrap-vcpkg.sh  (or .bat on Windows)"
  exit 1
fi

# Ensure we’re in a CMake project
if [[ ! -f "CMakeLists.txt" ]]; then
  echo "Error: No CMakeLists.txt in current directory. Run this from your test project's root."
  exit 1
fi

# Detect platform -> triplets
UNAME_S="$(uname -s)"
UNAME_M="$(uname -m)"
TRIPLETS=()

case "$UNAME_S" in
  MINGW*|MSYS*|CYGWIN*|Windows_NT)
    TRIPLETS=( x64-windows x64-windows-static )
    #TRIPLETS=( x64-windows-static )
    ;;
  Linux)
    if [[ "$UNAME_M" != "x86_64" ]]; then
      echo "Error: This script expects Linux x86_64. Detected arch: $UNAME_M"
      exit 1
    fi
    TRIPLETS=( x64-linux x64-linux-dynamic )
    ;;
  *)
    echo "Error: Unsupported OS: $UNAME_S"
    exit 1
    ;;
esac

# Use this vcpkg
export VCPKG_ROOT="$VCPKG_DIR_ABS"

TOOLCHAIN_FILE="$VCPKG_DIR_ABS/scripts/buildsystems/vcpkg.cmake"

for t in "${TRIPLETS[@]}"; do
  echo
  echo "===== Triplet: $t ====="

  # 1) Install ONLY the two packages for THIS triplet
  echo "Installing: libczi:$t jxrlib:$t"
  "$VCPKG_BIN" install "libczi:$t" "jxrlib:$t"

  # 2) Configure & build this triplet in its own build dir
  BUILD_DIR="build_${t}"
  echo "Configuring CMake in '$BUILD_DIR'..."
  cmake -S . -B "$BUILD_DIR" \
    -DCMAKE_TOOLCHAIN_FILE="$TOOLCHAIN_FILE" \
    -DVCPKG_TARGET_TRIPLET="$t" \
    -DCMAKE_BUILD_TYPE=Release

  echo "Building & running 'run' target for $t..."
  cmake --build "$BUILD_DIR" --config Release --target run
  # If 'run' exits non-zero, this script stops due to 'set -e'.

  # 3) Remove the packages we just installed for THIS triplet
  echo "Removing: libczi:$t jxrlib:$t"
  "$VCPKG_BIN" remove --recurse "libczi:$t" "jxrlib:$t"

  echo "===== Triplet $t completed successfully ====="
done

echo
echo "All triplets built, tested, and cleaned up."
