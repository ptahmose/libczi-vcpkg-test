# CMakeLists.txt

# Specify minimum CMake version required. Vcpkg generally requires 3.14 or newer.
cmake_minimum_required(VERSION 3.14)

cmake_policy(SET CMP0091 NEW)

# Define your project
project(pugixml_coexistence CXX)

# Set C++ standard (e.g., C++17)
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

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

# -------------------- vcpkg / MSVC CRT alignment --------------------
# This block ensures your executable uses the SAME MSVC runtime (CRT)
# as the vcpkg-built libraries for the active triplet. That avoids
# LNK2038/LNK4098 and multiply-defined symbol/linker issues.

# Preconditions:
#  - You are on Windows with MSVC (MSVC is true).
#  - You configured CMake with the vcpkg toolchain file so that
#    VCPKG_TARGET_TRIPLET is defined by the toolchain.
#  - Policy CMP0091 must be NEW so CMAKE_MSVC_RUNTIME_LIBRARY is honored.
#
# Recommended placement:
#  - After `project(...)` so the vcpkg toolchain has already run,
#    OR pass -DCMAKE_POLICY_DEFAULT_CMP0091=NEW at configure time.

if(MSVC AND DEFINED VCPKG_TARGET_TRIPLET)
  # Make sure CMake honors CMAKE_MSVC_RUNTIME_LIBRARY instead of deriving /MDd, /MD, /MTd, /MT from older vars.
  # cmake_policy(SET CMP0091 NEW) must be set before this point, or pass -DCMAKE_POLICY_DEFAULT_CMP0091=NEW at configure time.

  # Map common Windows triplets to the correct runtime:
  #   - *-static       -> /MT (static CRT)
  #   - *-static-md    -> /MD (dynamic CRT) even though libraries are static
  #   - otherwise      -> /MD (dynamic CRT) e.g., x64-windows
  if(VCPKG_TARGET_TRIPLET MATCHES "-static$")
    set(CMAKE_MSVC_RUNTIME_LIBRARY "MultiThreaded$<$<CONFIG:Debug>:Debug>")
  elseif(VCPKG_TARGET_TRIPLET MATCHES "-static-md$")
    set(CMAKE_MSVC_RUNTIME_LIBRARY "MultiThreaded$<$<CONFIG:Debug>:Debug>DLL")
  else()
    # Default (e.g., x86/x64/arm64-windows): dynamic CRT
    set(CMAKE_MSVC_RUNTIME_LIBRARY "MultiThreaded$<$<CONFIG:Debug>:Debug>DLL")
  endif()

  message(STATUS "**** MSVC runtime set from vcpkg triplet '${VCPKG_TARGET_TRIPLET}': ${CMAKE_MSVC_RUNTIME_LIBRARY} ****")

else()
  # Explanations to help when it doesn't trigger:
  # - On non-Windows platforms MSVC is false, so this is expected.
  # - If you're on Windows but don't see this message, ensure the vcpkg toolchain
  #   is active (set CMAKE_TOOLCHAIN_FILE or VCPKG_ROOT before project()).
  message(STATUS "vcpkg/MSVC CRT alignment block skipped (MSVC=${MSVC}, VCPKG_TARGET_TRIPLET='${VCPKG_TARGET_TRIPLET}')")
endif()
# ------------------ end vcpkg / MSVC CRT alignment -------------------

# Find your new port.
find_package(libCZI CONFIG REQUIRED)

find_package(pugixml CONFIG REQUIRED)

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
target_link_libraries(${PROJECT_NAME} PRIVATE libczi::libCZI_selected pugixml::pugixml)

add_custom_target(run
  COMMAND pugixml_coexistence
  DEPENDS pugixml_coexistence
  WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
)