# Match the same build flag used by Dart. Flutter stores DART_DEFINES as
# comma-separated base64 tokens in its generated configuration.
set(_gsmlg_plugin_rules "${FLUTTER_MANAGED_DIR}/generated_plugins.cmake")
set(_gsmlg_flutter_config "${FLUTTER_MANAGED_DIR}/ephemeral/generated_config.cmake")
set_property(DIRECTORY APPEND PROPERTY CMAKE_CONFIGURE_DEPENDS
  "${_gsmlg_plugin_rules}" "${_gsmlg_flutter_config}")
file(STRINGS "${_gsmlg_flutter_config}" _gsmlg_dart_defines REGEX "DART_DEFINES=")

if("${_gsmlg_dart_defines}" MATCHES
    "(^|[=,])R1NNTEdfRU5BQkxFX0xPQ0FMX0xMTT1mYWxzZQ==($|[,\"])")
  # TODO(upstream): https://github.com/gsmlg-app/lib_llama_cpp/issues/33
  # Remove this exclusion when a published ARM64 library/source fallback passes
  # a native Linux ARM64 build. Local inference is optional for this deployment.
  # Keep generated source untouched; only filter its FFI plugin list entry in
  # the build directory. Every other plugin retains Flutter's generated rules.
  file(READ "${_gsmlg_plugin_rules}" _gsmlg_plugins)
  string(REGEX REPLACE "\n[ \t]*lib_llama_cpp_linux[ \t]*\r?\n" "\n"
    _gsmlg_plugins "${_gsmlg_plugins}")
  set(_gsmlg_plugin_rules "${CMAKE_CURRENT_BINARY_DIR}/gsmlg_generated_plugins.cmake")
  file(WRITE "${_gsmlg_plugin_rules}" "${_gsmlg_plugins}")
  message(STATUS "Local LLM disabled (GSMLG_ENABLE_LOCAL_LLM=false)")
endif()

include("${_gsmlg_plugin_rules}")
