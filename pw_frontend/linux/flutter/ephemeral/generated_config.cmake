# Generated code do not commit.
file(TO_CMAKE_PATH "/home/faggi/repo/flutter/flutter" FLUTTER_ROOT)
file(TO_CMAKE_PATH "/home/faggi/repo/pswmanager/pw_frontend" PROJECT_DIR)

set(FLUTTER_VERSION "1.0.0+1" PARENT_SCOPE)
set(FLUTTER_VERSION_MAJOR 1 PARENT_SCOPE)
set(FLUTTER_VERSION_MINOR 0 PARENT_SCOPE)
set(FLUTTER_VERSION_PATCH 0 PARENT_SCOPE)
set(FLUTTER_VERSION_BUILD 1 PARENT_SCOPE)

# Environment variables to pass to tool_backend.sh
list(APPEND FLUTTER_TOOL_ENVIRONMENT
  "FLUTTER_ROOT=/home/faggi/repo/flutter/flutter"
  "PROJECT_DIR=/home/faggi/repo/pswmanager/pw_frontend"
  "DART_OBFUSCATION=false"
  "TRACK_WIDGET_CREATION=true"
  "TREE_SHAKE_ICONS=false"
  "PACKAGE_CONFIG=/home/faggi/repo/pswmanager/pw_frontend/.dart_tool/package_config.json"
  "FLUTTER_TARGET=/home/faggi/repo/pswmanager/pw_frontend/lib/main.dart"
)
