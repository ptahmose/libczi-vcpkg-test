# === Adjust this to your vcpkg location ===
VCPKG_ROOT="~/dev/libczi-vcpkg/vcpkg-ptahmose"

# === Define toolchain file ===
VCPKG_TOOLCHAIN_FILE="$VCPKG_ROOT/scripts/buildsystems/vcpkg.cmake"

if [ ! -d build ]; then
    mkdir build
fi
cd build

# === Run CMake configure step ===

cmake .. -DCMAKE_TOOLCHAIN_FILE="$VCPKG_TOOLCHAIN_FILE" -DCMAKE_BUILD_TYPE=Release
# cmake .. -DCMAKE_TOOLCHAIN_FILE="$VCPKG_TOOLCHAIN_FILE" -DCMAKE_BUILD_TYPE=Release -DVCPKG_TARGET_TRIPLET=x64-windows-static

cmake --build . --config Release

./libczi_test