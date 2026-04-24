# This file controls Flutter-level build steps.
cmake_minimum_required(VERSION 3.10)

set(FLUTTER_MANAGED_DIR "\${CMAKE_CURRENT_SOURCE_DIR}/flutter")

# Flutter library and tool build rules.
set(FLUTTER_LIBRARY "\${FLUTTER_MANAGED_DIR}/libflutter_linux_gtk.so")

# Add dependency on Flutter library
add_custom_target(flutter_assemble DEPENDS \${FLUTTER_LIBRARY})
