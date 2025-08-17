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

# Install required packages for each triplet
PKGS=()
for t in "${TRIPLETS[@]}"; do
  PKGS+=("libczi:$t" "pugixml:$t")
done

echo "Installing with vcpkg: ${PKGS[*]}"
"$VCPKG_BIN" install "${PKGS[@]}"

# Configure, build, and run for each triplet
TOOLCHAIN_FILE="$VCPKG_DIR_ABS/scripts/buildsystems/vcpkg.cmake"
for t in "${TRIPLETS[@]}"; do
  BUILD_DIR="build_${t}"
  echo
  echo "=== Configuring $t ==="
  cmake -S . -B "$BUILD_DIR" \
    -DCMAKE_TOOLCHAIN_FILE="$TOOLCHAIN_FILE" \
    -DVCPKG_TARGET_TRIPLET="$t" \
    -DCMAKE_BUILD_TYPE=Release

  echo "=== Building & running $t ==="
  cmake --build "$BUILD_DIR" --config Release --target run
  # If 'run' returns non-zero, the build fails and the script stops due to 'set -e'.
done

echo
echo "All requested triplets built and 'run' target completed successfully."
