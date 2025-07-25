cmake_minimum_required(VERSION 3.15)
project(libczi_test CXX)

# Set C++ standard
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

if (MSVC)
  set(CMAKE_MSVC_RUNTIME_LIBRARY "MultiThreaded$<$<CONFIG:Debug>:Debug>")
endif()

# Enable vcpkg toolchain
# (VCPKG toolchain file is passed via command line, no need to hardcode it here)

#find_package(zstd CONFIG REQUIRED)
#find_package(Eigen3 CONFIG REQUIRED)
find_package(libCZI CONFIG REQUIRED)

add_executable(libczi_test main.cpp)
target_link_libraries(libczi_test PRIVATE libczi::libCZI)