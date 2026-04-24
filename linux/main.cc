#include <flutter/dart_project.h>
#include <flutter/flutter_view_controller.h>
#include <linux/limits.h>
#include <unistd.h>

#include <cstdlib>
#include <iostream>
#include <memory>
#include <optional>

#include "flutter_window.h"
#include "utils.h"

int main(int argc, char** argv) {
  gtk_init(&argc, &argv);

  g_set_application_name("P2P IM Portal");

  DartProject project("data");

  std::vector<std::string> command_line_arguments =
      GetCommandLineArguments();

  project.set_dart_entrypoint_arguments(std::move(command_line_arguments));

  FlutterWindow window(project);
  window.Show();

  return EXIT_SUCCESS;
}
