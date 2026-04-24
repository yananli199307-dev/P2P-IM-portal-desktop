#include "flutter_window.h"

#include <optional>

#include "flutter/generated_plugin_registrant.h"

FlutterWindow::FlutterWindow(const flutter::DartProject& project)
    : project_(project) {}

FlutterWindow::~FlutterWindow() {}

bool FlutterWindow::Show() {
  window_ = GTK_WINDOW(gtk_window_new(GTK_WINDOW_TOPLEVEL));
  gtk_window_set_default_size(window_, 1280, 720);
  gtk_widget_show(GTK_WIDGET(window_));

  g_autoptr(FlDartProject) project = fl_dart_project_new();
  fl_dart_project_set_aot_library_path(project, "data/libapp.so");

  view_ = fl_view_new(project);
  gtk_widget_show(GTK_WIDGET(view_));
  gtk_container_add(GTK_CONTAINER(window_), GTK_WIDGET(view_));

  fl_register_plugins(FL_PLUGIN_REGISTRY(view_));

  gtk_widget_grab_focus(GTK_WIDGET(view_));

  return true;
}
