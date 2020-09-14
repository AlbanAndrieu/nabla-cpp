# CMakeList.txt : Top-level CMake project file, do global configuration
# and include sub-projects here.
#
PROJECT(MICROSOFT LANGUAGES CXX)

CMAKE_MINIMUM_REQUIRED(VERSION "3.8")

#MESSAGE(STATUS "CMAKE_SOURCE_DIR : ${CMAKE_SOURCE_DIR}")

ADD_SUBDIRECTORY(sample/microsoft)
