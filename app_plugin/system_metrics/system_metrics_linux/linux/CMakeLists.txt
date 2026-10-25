cmake_minimum_required(VERSION 3.10)
set(PROJECT_NAME "app_system_metrics_linux")
project(${PROJECT_NAME} LANGUAGES CXX)
find_package(Threads REQUIRED)

set(PLUGIN_NAME "${PROJECT_NAME}_plugin")

add_library(${PLUGIN_NAME} SHARED
  "system_metrics_plugin.cc"
  "activity_monitor_collector.cc"
)

apply_standard_settings(${PLUGIN_NAME})
target_compile_features(${PLUGIN_NAME} PRIVATE cxx_std_17)

set_target_properties(${PLUGIN_NAME} PROPERTIES
  CXX_VISIBILITY_PRESET hidden)
target_compile_definitions(${PLUGIN_NAME} PRIVATE FLUTTER_PLUGIN_IMPL)

target_include_directories(${PLUGIN_NAME} INTERFACE
  "${CMAKE_CURRENT_SOURCE_DIR}/include")
target_link_libraries(${PLUGIN_NAME} PRIVATE flutter Threads::Threads)
target_link_libraries(${PLUGIN_NAME} PRIVATE PkgConfig::GTK)

set(app_system_metrics_linux_bundled_libraries
  ""
  PARENT_SCOPE
)
