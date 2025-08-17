#!/usr/bin/env bash
set -euo pipefail

# Change this to set the clone target (or export vcpkg_target_dir before running)
vcpkg_target_dir="${vcpkg_target_dir:-vcpkg}"

# Safety guard to avoid nuking root or empty paths
if [[ -z "${vcpkg_target_dir// }" || "$vcpkg_target_dir" == "/" ]]; then
  echo "Refusing to operate on an empty or root vcpkg_target_dir."
  exit 1
fi

# Remove existing target (dir/file/symlink) if present
if [[ -e "$vcpkg_target_dir" ]]; then
  echo "Removing existing '$vcpkg_target_dir'..."
  rm -rf -- "$vcpkg_target_dir"
fi


git clone --depth 1 --single-branch --branch master --filter=blob:none https://github.com/microsoft/vcpkg.git "$vcpkg_target_dir"

# Bootstrap vcpkg (works on Linux/macOS and Windows bash)
bootstrap_vcpkg() {
  local dir="$1"
  local bin_unix="$dir/vcpkg"
  local bin_win="$dir/vcpkg.exe"

  # Skip if already bootstrapped
  if [[ -x "$bin_unix" || -x "$bin_win" ]]; then
    echo "vcpkg already bootstrapped."
    return
  fi

  if [[ -f "$dir/bootstrap-vcpkg.sh" ]]; then
    ( cd "$dir" && ./bootstrap-vcpkg.sh -disableMetrics )
  elif [[ -f "$dir/bootstrap-vcpkg.bat" ]]; then
    # On Windows (Git Bash/Cygwin/MSYS), call via cmd.exe
    ( cd "$dir" && cmd.exe /C "bootstrap-vcpkg.bat -disableMetrics" )
  else
    echo "Cannot find bootstrap script in '$dir'."
    exit 1
  fi
}

bootstrap_vcpkg "$vcpkg_target_dir"

pushd "$TEST_DIR" >/dev/null
if [[ -x "./$TEST_SCRIPT" ]]; then
  "./$TEST_SCRIPT" "$vcpkg_target_dir"
else
  bash "./$TEST_SCRIPT" "$vcpkg_target_dir"
fi
popd >/dev/null
