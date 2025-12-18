#!/bin/bash

# Script to run Flutter app with dev configuration
# Usage: ./scripts/run-dev.sh [flutter-command]
# Possible values for flutter-command: run, build, test, analyze, etc.
# Default is run.
# The config file is assets/config.dev.json.

FLUTTER_CMD="${1:-run}"
CONFIG_FILE="assets/config.dev.json"

echo "🚀 Running Flutter with dev config: $CONFIG_FILE"
echo "Command: flutter $FLUTTER_CMD --dart-define=CONFIG_FILE=$CONFIG_FILE"

flutter $FLUTTER_CMD --dart-define=CONFIG_FILE=$CONFIG_FILE "${@:2}"
