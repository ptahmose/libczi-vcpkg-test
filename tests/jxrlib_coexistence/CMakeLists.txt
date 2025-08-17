cmake_minimum_required(VERSION 3.14)

# Ensure CMake respects CMAKE_MSVC_RUNTIME_LIBRARY
cmake_policy(SET CMP0091 NEW)

# --- vcpkg toolchain (only if not passed via -DCMAKE_TOOLCHAIN_FILE) ---
if(NOT DEFINED CMAKE_TOOLCHAIN_FILE)
  if(DEFINED ENV{VCPKG_ROOT})
    set(CMAKE_TOOLCHAIN_FILE "$ENV{VCPKG_ROOT}/scripts/buildsystems/vcpkg.cmake"
        CACHE FILEPATH "vcpkg toolchain file")
  else()
    message(FATAL_ERROR "VCPKG_ROOT not set and no CMAKE_TOOLCHAIN_FILE provided.")
  endif()
endif()
# ----------------------------------------------------------------------

project(jxrlib_coexistence CXX)
#message(STATUS "After project():  VCPKG_CRT_LINKAGE='${VCPKG_CRT_LINKAGE}'")
# Now vcpkg's toolchain has run -> VCPKG_CRT_LINKAGE is defined on Windows
#if(MSVC)
#  if(DEFINED VCPKG_CRT_LINKAGE)
#    if(VCPKG_CRT_LINKAGE STREQUAL "static")
#      set(CMAKE_MSVC_RUNTIME_LIBRARY "MultiThreaded$<$<CONFIG:Debug>:Debug>")
#    else()
#      set(CMAKE_MSVC_RUNTIME_LIBRARY "MultiThreaded$<$<CONFIG:Debug>:Debug>DLL")
#    endif()
#    message(STATUS "MSVC runtime set from vcpkg: ${CMAKE_MSVC_RUNTIME_LIBRARY}")
#  else()
#    message(WARNING "VCPKG_CRT_LINKAGE not defined; default MSVC runtime will be used.")
#    set(CMAKE_MSVC_RUNTIME_LIBRARY "MultiThreaded$<$<CONFIG:Debug>:Debug>DLL")
#  endif()
#endif()

#message(STATUS "********* VCPKG_CRT_LINKAGE: ${VCPKG_CRT_LINKAGE} *********")

#if(MSVC)
#  # Option A: derive from vcpkg triplet
#  if(DEFINED VCPKG_CRT_LINKAGE)
#    set(CMAKE_MSVC_RUNTIME_LIBRARY
#        "MultiThreaded$<$<CONFIG:Debug>:Debug>$<STREQUAL:${VCPKG_CRT_LINKAGE},dynamic>:DLL>")
#    message(STATUS "MSVC runtime set from vcpkg: ${CMAKE_MSVC_RUNTIME_LIBRARY}")
#  endif()
#endif()
if(MSVC AND DEFINED VCPKG_TARGET_TRIPLET)
  cmake_policy(SET CMP0091 NEW)
  if(VCPKG_TARGET_TRIPLET MATCHES "-static$")
    set(CMAKE_MSVC_RUNTIME_LIBRARY "MultiThreaded$<$<CONFIG:Debug>:Debug>")
  elseif(VCPKG_TARGET_TRIPLET MATCHES "-static-md$")
    set(CMAKE_MSVC_RUNTIME_LIBRARY "MultiThreaded$<$<CONFIG:Debug>:Debug>DLL")
  else()
    # default (e.g., x64-windows): dynamic CRT
    set(CMAKE_MSVC_RUNTIME_LIBRARY "MultiThreaded$<$<CONFIG:Debug>:Debug>DLL")
  endif()
   message(STATUS "**** MSVC runtime set from vcpkg: ${CMAKE_MSVC_RUNTIME_LIBRARY} ****")
endif()


set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

find_package(libCZI CONFIG REQUIRED)
find_package(JXR REQUIRED)

# Alias to correct libCZI variant
if(TARGET libczi::libCZI)
  add_library(libczi::libCZI_selected ALIAS libczi::libCZI)
elseif(TARGET libczi::libCZIStatic)
  add_library(libczi::libCZI_selected ALIAS libczi::libCZIStatic)
else()
  message(FATAL_ERROR "No suitable libCZI target found (shared or static).")
endif()

add_executable(${PROJECT_NAME} main.cpp)
target_include_directories(${PROJECT_NAME} PRIVATE ${JXR_INCLUDE_DIRS})
target_link_libraries(${PROJECT_NAME} PRIVATE libczi::libCZI_selected ${JXR_LIBRARIES})

message(STATUS "JXR_LIBRARIES: ${JXR_LIBRARIES}")

add_custom_target(run
  COMMAND jxrlib_coexistence
  DEPENDS jxrlib_coexistence
  WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
)
