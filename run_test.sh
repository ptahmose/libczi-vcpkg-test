#!/usr/bin/env bash
set -euo pipefail

# -------- config --------
# vcpkg target directory (override by exporting vcpkg_target_dir)
vcpkg_target_dir="${vcpkg_target_dir:-vcpkg}"
# per-test script name (override by exporting test_script_name)
test_script_name="${test_script_name:-execute_test.sh}"
# list of test folders to run (edit this list)
TEST_DIRS=(
  "tests/pugixml_coexistence"
  "tests/jxrlib_coexistence"
  "tests/azuresdk_test"
  "tests/curl_test"
  "tests/azuresdk_and_curl_test"c
  # "tests/another_test"
)
# ------------------------

# Safety: refuse empty/root
if [[ -z "${vcpkg_target_dir// }" || "$vcpkg_target_dir" == "/" ]]; then
  echo "Refusing to operate on an empty or root vcpkg_target_dir."
  exit 1
fi

# Ensure we have tests configured
if [[ ${#TEST_DIRS[@]} -eq 0 ]]; then
  echo "No test folders specified in TEST_DIRS."
  exit 2
fi

# Fresh clone
if [[ -e "$vcpkg_target_dir" ]]; then
  echo "Removing existing '$vcpkg_target_dir'..."
  rm -rf -- "$vcpkg_target_dir"
fi

#git clone --depth 1 --single-branch --branch master --filter=blob:none \
#  https://github.com/microsoft/vcpkg.git "$vcpkg_target_dir"
git clone --depth 1 --single-branch --branch jbl/add_vcpkg_options --filter=blob:none \
  https://github.com/ptahmose/vcpkg "$vcpkg_target_dir"


# Bootstrap vcpkg (Linux/macOS or Windows bash)
bootstrap_vcpkg() {
  local dir="$1"
  local bin_unix="$dir/vcpkg"
  local bin_win="$dir/vcpkg.exe"

  if [[ -x "$bin_unix" || -x "$bin_win" ]]; then
    echo "vcpkg already bootstrapped."
    return
  fi

  if [[ -f "$dir/bootstrap-vcpkg.sh" ]]; then
    ( cd "$dir" && ./bootstrap-vcpkg.sh -disableMetrics )
  elif [[ -f "$dir/bootstrap-vcpkg.bat" ]]; then
    ( cd "$dir" && cmd.exe /C "bootstrap-vcpkg.bat -disableMetrics" )
  else
    echo "Cannot find bootstrap script in '$dir'."
    exit 1
  fi
}
bootstrap_vcpkg "$vcpkg_target_dir"

# Expose vcpkg to children and compute absolute path to pass to tests
VCPKG_DIR_ABS="$(cd "$vcpkg_target_dir" && pwd -P)"
export VCPKG_ROOT="$VCPKG_DIR_ABS"
export PATH="$VCPKG_DIR_ABS:$PATH"

# Optional sanity check
if [[ ! -x "$VCPKG_DIR_ABS/vcpkg" && ! -x "$VCPKG_DIR_ABS/vcpkg.exe" ]]; then
  echo "Error: vcpkg binary not found after bootstrap."
  exit 1
fi

# ----- run each test folder -----
for TEST_DIR in "${TEST_DIRS[@]}"; do
  echo
  echo "=== Running test in '$TEST_DIR' ==="

  if [[ ! -d "$TEST_DIR" ]]; then
    echo "Error: test directory '$TEST_DIR' not found."
    exit 1
  fi
  if [[ ! -f "$TEST_DIR/$test_script_name" ]]; then
    echo "Error: test script '$TEST_DIR/$test_script_name' not found."
    exit 1
  fi

  pushd "$TEST_DIR" >/dev/null
  if [[ -x "./$test_script_name" ]]; then
    "./$test_script_name" "$VCPKG_DIR_ABS"
  else
    bash "./$test_script_name" "$VCPKG_DIR_ABS"
  fi
  popd >/dev/null

  echo "=== '$TEST_DIR' completed successfully ==="
done

echo
echo "All tests completed successfully."
