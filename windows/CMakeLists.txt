cmake_minimum_required(VERSION 3.14)
project(cloudgram LANGUAGES CXX)

set(BINARY_NAME "cloudgram")
set(APPLICATION_ID "com.cloudgram.app")

cmake_policy(SET CMP0063 NEW)

set(CMAKE_INSTALL_PREFIX "${CMAKE_BINARY_DIR}/run" CACHE PATH "..." FORCE)

if(CMAKE_SOURCE_DIR STREQUAL CMAKE_CURRENT_SOURCE_DIR)
  set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/run)
  set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/run)

  set(BUILD_BUNDLE_DIR "${PROJECT_BINARY_DIR}/runner")
  set(CMAKE_INSTALL_PREFIX "${BUILD_BUNDLE_DIR}" CACHE PATH "..." FORCE)
  set(INSTALL_BUNDLE_DATA_DIR "${CMAKE_INSTALL_PREFIX}/data")
  set(INSTALL_BUNDLE_LIB_DIR "${CMAKE_INSTALL_PREFIX}")

  add_subdirectory(flutter)

  include(flutter/generated_plugins.cmake)
endif()

add_subdirectory(runner)

set(INSTALL_BUNDLE_DATA_DIR "${CMAKE_INSTALL_PREFIX}/data")
set(INSTALL_BUNDLE_LIB_DIR "${CMAKE_INSTALL_PREFIX}")

install(CODE "set(BUILD_BUNDLE_DIR \"${BUILD_BUNDLE_DIR}\")" COMPONENT Runtime)
install(CODE [[
  file(TO_CMAKE_PATH "${BUILD_BUNDLE_DIR}" _build_bundle_dir)
  if(EXISTS "${_build_bundle_dir}/_phony_")
    message(STATUS "Installing from build bundle...")
  endif()
]] COMPONENT Runtime)
