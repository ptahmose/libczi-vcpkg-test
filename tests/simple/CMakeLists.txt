# CMakeLists.txt

# Specify minimum CMake version required. Vcpkg generally requires 3.14 or newer.
cmake_minimum_required(VERSION 3.14)

cmake_policy(SET CMP0091 NEW) # enable new "MSVC runtime library selection" (https://cmake.org/cmake/help/latest/variable/CMAKE_MSVC_RUNTIME_LIBRARY.html)


# Define your project
project(simple CXX)

# Set C++ standard (e.g., C++17)
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

 #set_property(TARGET ${PROJECT_NAME} PROPERTY MSVC_RUNTIME_LIBRARY "MultiThreaded$<$<CONFIG:Debug>:Debug>")

# --- Best Practice for Vcpkg Integration ---
# 1. Toolchain File: The most robust way to integrate vcpkg.
#    This tells CMake to use vcpkg to find libraries.
#    You can pass this on the command line, in CMakePresets.json,
#    or (less ideal for discoverability but fine for a quick test app)
#    set it directly in CMakeLists.txt.
#    If you set it here, it MUST be before the first `project()` call.
#    Example (if you know the VCPKG_ROOT environment variable is set):
if(NOT DEFINED CMAKE_TOOLCHAIN_FILE)
    if(DEFINED ENV{VCPKG_ROOT})
        set(CMAKE_TOOLCHAIN_FILE "$ENV{VCPKG_ROOT}/scripts/buildsystems/vcpkg.cmake" CACHE FILEPATH "Vcpkg toolchain file")
    else()
        message(FATAL_ERROR "VCPKG_ROOT environment variable not set. Please set it to your vcpkg installation path.")
    endif()
endif()
# --- End Vcpkg Integration ---

# Find your new port. The exact name depends on what your port exports.
# Check the "usage" file for the exact `find_package` name.
# For example, if your port is named 'mylibrary' and provides target `MyLibrary::MyLibrary`:
find_package(libCZI CONFIG REQUIRED)
# Define a local alias to the correct variant of libCZI
# This allows you to use `libczi::libCZI_selected` in your target_link_libraries.
if(TARGET libczi::libCZI)
    add_library(libczi::libCZI_selected ALIAS libczi::libCZI)
elseif(TARGET libczi::libCZIStatic)
    add_library(libczi::libCZI_selected ALIAS libczi::libCZIStatic)
else()
    message(FATAL_ERROR "No suitable libCZI target found (neither shared nor static).")
endif()

# Add your executable
add_executable(${PROJECT_NAME} main.cpp)


# Link your executable against the library provided by your port
# Use the target alias provided by `find_package`.
target_link_libraries(${PROJECT_NAME} PRIVATE libczi::libCZI_selected)

add_custom_target(run
  COMMAND simple
  DEPENDS simple
  WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
)