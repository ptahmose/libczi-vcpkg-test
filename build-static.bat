@echo on
setlocal

rem === Adjust this to your vcpkg location ===
set VCPKG_ROOT=D:\dev\vcpkg_test\vcpkg-ptahmose

rem === Define toolchain file ===
set VCPKG_TOOLCHAIN_FILE=%VCPKG_ROOT%\scripts\buildsystems\vcpkg.cmake

rem %VCPKG_ROOT%\vcpkg.exe install --triplet x64-windows-static --head

rem === Create and enter build directory ===
if not exist build_static mkdir build_static
cd build_static

rem === Run CMake configure step ===

rem cmake .. -DCMAKE_TOOLCHAIN_FILE=%VCPKG_TOOLCHAIN_FILE% -DCMAKE_BUILD_TYPE=Release
cmake .. -DCMAKE_TOOLCHAIN_FILE=%VCPKG_TOOLCHAIN_FILE% -DCMAKE_BUILD_TYPE=Release -DVCPKG_TARGET_TRIPLET=x64-windows-static 

if errorlevel 1 (
    echo CMake configuration failed.
    exit /b 1
)

rem === Build the project ===
cmake --build . --config Release
if errorlevel 1 (
    echo Build failed.
    exit /b 1
)

rem === Run the executable ===
.\Release\libczi_test.exe

endlocal
