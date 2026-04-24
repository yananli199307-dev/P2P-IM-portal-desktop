# This file controls Flutter-level build steps.
cmake_minimum_required(VERSION 3.10)

set(FLUTTER_MANAGED_DIR "${CMAKE_CURRENT_SOURCE_DIR}")

# The Flutter tool subbuild will place its artifacts in this directory.
set(FLUTTER_LIBRARY "${FLUTTER_MANAGED_DIR}/libflutter_linux_gtk.so")

# Add dependency on Flutter library
add_custom_target(flutter_assemble)

# Find the Flutter package
find_package(PkgConfig REQUIRED)
pkg_check_modules(GTK REQUIRED IMPORTED_TARGET gtk+-3.0)

# Add the Flutter library
add_library(flutter SHARED IMPORTED GLOBAL)
set_target_properties(flutter PROPERTIES
  IMPORTED_LOCATION "${FLUTTER_LIBRARY}"
)
target_link_libraries(flutter INTERFACE PkgConfig::GTK)
