cmake_minimum_required(VERSION 3.13)
project(gsmlg_plugin_tests LANGUAGES NONE)

get_filename_component(LINUX_SOURCE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/../.." ABSOLUTE)

# Exercise the real generated plugin rules without compiling their native code.
macro(add_subdirectory source binary)
  list(APPEND configured_plugins "${binary}")
endmacro()

macro(target_link_libraries)
endmacro()

function(check_plugins name dart_defines disabled)
  set(FLUTTER_MANAGED_DIR "${CMAKE_CURRENT_BINARY_DIR}/${name}/flutter")
  file(MAKE_DIRECTORY "${FLUTTER_MANAGED_DIR}/ephemeral")
  file(WRITE "${FLUTTER_MANAGED_DIR}/ephemeral/generated_config.cmake"
    "set(FLUTTER_TOOL_ENVIRONMENT \"DART_DEFINES=${dart_defines}\")\n")
  configure_file("${LINUX_SOURCE_DIR}/flutter/generated_plugins.cmake"
    "${FLUTTER_MANAGED_DIR}/generated_plugins.cmake" COPYONLY)
  file(SHA256 "${FLUTTER_MANAGED_DIR}/generated_plugins.cmake" before_hash)

  include("${LINUX_SOURCE_DIR}/cmake/plugins.cmake")

  set(expected_plugins
    plugins/app_client_info_linux
    plugins/app_system_metrics_linux
    plugins/audioplayers_linux
    plugins/file_selector_linux
    plugins/flutter_secure_storage_linux
    plugins/record_linux
    plugins/url_launcher_linux
    plugins/jni)
  if(NOT disabled)
    list(APPEND expected_plugins plugins/lib_llama_cpp_linux)
  endif()
  if(NOT "${configured_plugins}" STREQUAL "${expected_plugins}")
    message(FATAL_ERROR "${name}: unexpected native plugins: ${configured_plugins}")
  endif()
  file(SHA256 "${FLUTTER_MANAGED_DIR}/generated_plugins.cmake" after_hash)
  if(NOT before_hash STREQUAL after_hash)
    message(FATAL_ERROR "${name}: generated source was modified")
  endif()
endfunction()

check_plugins(default "" FALSE)
check_plugins(enabled "R1NNTEdfRU5BQkxFX0xPQ0FMX0xMTT10cnVl" FALSE)
check_plugins(disabled
  "VEVTVD10cnVl,R1NNTEdfRU5BQkxFX0xPQ0FMX0xMTT1mYWxzZQ==,VEVTVD1mYWxzZQ==" TRUE)
check_plugins(partial_token "R1NNTEdfRU5BQkxFX0xPQ0FMX0xMTT1mYWxzZQ==extra" FALSE)

message(STATUS "All local LLM plugin configuration checks passed")
