# vcpkg-triplets.sh
# Reusable helpers to detect suitable vcpkg triplets for the current host.

# Usage patterns:
#   source ./vcpkg-triplets.sh
#   TRIPLETS=($(vcpkg_detect_triplets "$VCPKG_ROOT"))
#   for t in "${TRIPLETS[@]}"; do echo "$t"; done
#
# Optional overrides for testing:
#   export VCPKG_OS_OVERRIDE=Linux|Windows|Darwin
#   export VCPKG_ARCH_OVERRIDE=x86_64|arm64|riscv64|...
#
# Notes:
# - We only probe triplets that actually exist in the supplied VCPKG_ROOT.
# - We also look in triplets/community for non-core triplets like "*-dynamic".

vcpkg_triplet_exists() {
  # $1 = VCPKG_ROOT, $2 = triplet name, echo nothing, return 0 if present
  local root="$1" t="$2"
  [[ -f "$root/triplets/$t.cmake" || -f "$root/triplets/community/$t.cmake" ]]
}

vcpkg_add_if_exists() {
  # $1 = VCPKG_ROOT, $2 = triplet name
  local root="$1" t="$2"
  if vcpkg_triplet_exists "$root" "$t"; then
    printf "%s\n" "$t"
  fi
}

vcpkg_detect_triplets() {
  # $1 = VCPKG_ROOT
  local root="${1:?missing VCPKG_ROOT}"

  # Allow env overrides for testing
  local os="${VCPKG_OS_OVERRIDE:-$(uname -s)}"
  local arch="${VCPKG_ARCH_OVERRIDE:-$(uname -m)}"

  local out=()

  case "$os" in
    MINGW*|MSYS*|CYGWIN*|Windows_NT|Windows)
      # Windows x64
      mapfile -t out < <(
        vcpkg_add_if_exists "$root" x64-windows
        vcpkg_add_if_exists "$root" x64-windows-static
      )
      ;;

    Linux)
      case "$arch" in
        x86_64|amd64)
          mapfile -t out < <(
            vcpkg_add_if_exists "$root" x64-linux
            vcpkg_add_if_exists "$root" x64-linux-dynamic
          )
          ;;
        aarch64|arm64)
          mapfile -t out < <(
            vcpkg_add_if_exists "$root" arm64-linux
            vcpkg_add_if_exists "$root" arm64-linux-dynamic
          )
          ;;
        riscv64)
          mapfile -t out < <(
            vcpkg_add_if_exists "$root" riscv64-linux
            vcpkg_add_if_exists "$root" riscv64-linux-dynamic
          )
          ;;
        *)
          ;;
      esac
      ;;

    Darwin)
      # macOS (Intel/Apple Silicon)
      if [[ "$arch" == "arm64" ]]; then
        if ! command -v mapfile &> /dev/null; then
          # Provide a fallback for mapfile if not available (e.g., on macOS older bash versions)
          out=($(
            vcpkg_add_if_exists "$root" arm64-osx
            vcpkg_add_if_exists "$root" arm64-osx-dynamic
          ))
        else
          mapfile -t out < <(
            vcpkg_add_if_exists "$root" arm64-osx
            vcpkg_add_if_exists "$root" arm64-osx-dynamic
          )
        fi
      else
        if ! command -v mapfile &> /dev/null; then
          out=($(
            vcpkg_add_if_exists "$root" x64-osx
            vcpkg_add_if_exists "$root" x64-osx-dynamic
          ))
        else
          mapfile -t out < <(
            vcpkg_add_if_exists "$root" x64-osx
            vcpkg_add_if_exists "$root" x64-osx-dynamic
          )
        fi
      fi
      ;;

    *)
      ;;
  esac

  # Print one triplet per line (easy to capture with mapfile or $(...))
  if ((${#out[@]})); then
    printf "%s\n" "${out[@]}"
  fi
}

vcpkg_default_toolchain() {
  # $1 = VCPKG_ROOT
  local root="${1:?missing VCPKG_ROOT}"
  printf "%s\n" "$root/scripts/buildsystems/vcpkg.cmake"
}
