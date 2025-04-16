#!/bin/bash

# Run Flutter analyze
echo "Running Flutter analyze..."
flutter analyze

# Run Dart format check
echo "Running Dart format check..."
dart format --output=none --set-exit-if-changed .

# Run Dart fix
echo "Running Dart fix..."
dart fix --apply

# Run Flutter test with coverage
echo "Running Flutter tests with coverage..."
flutter test  ./test/screens ./test/services --coverage

# Generate coverage report
echo "Generating coverage report..."
genhtml coverage/lcov.info -o coverage/html

echo "Quality checks completed" 