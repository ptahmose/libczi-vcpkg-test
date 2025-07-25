@echo on
setlocal

rem === Adjust this to your vcpkg location ===
set VCPKG_ROOT=D:\dev\vcpkg_test\vcpkg

rem === Define toolchain file ===
set VCPKG_TOOLCHAIN_FILE=%VCPKG_ROOT%\scripts\buildsystems\vcpkg.cmake

rem %VCPKG_ROOT%\vcpkg.exe install --triplet x64-windows-static --head

rem === Create and enter build directory ===
if not exist build mkdir build
cd build

rem === Run CMake configure step ===

cmake .. -DCMAKE_TOOLCHAIN_FILE=%VCPKG_TOOLCHAIN_FILE% -DCMAKE_BUILD_TYPE=Release
rem cmake .. -DCMAKE_TOOLCHAIN_FILE=%VCPKG_TOOLCHAIN_FILE% -DCMAKE_BUILD_TYPE=Release -DVCPKG_TARGET_TRIPLET=x64-windows-static

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
