#ifndef FLUTTER_WINDOW_H_
#define FLUTTER_WINDOW_H_

#include <flutter/dart_project.h>
#include <flutter/flutter_view_controller.h>

#include <memory>

#include "gtk/gtk.h"

class FlutterWindow {
 public:
  explicit FlutterWindow(const flutter::DartProject& project);
  ~FlutterWindow();

  bool Show();

 private:
  flutter::DartProject project_;
  GtkWindow* window_;
  FlView* view_;
};

#endif  // FLUTTER_WINDOW_H_
