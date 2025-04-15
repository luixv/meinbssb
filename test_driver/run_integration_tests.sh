#!/bin/bash

# Clean the project
flutter clean

# Get dependencies
flutter pub get

# Start the mock server in the background
cd ~/mock-server
node mock-server.js &
MOCK_SERVER_PID=$!

# Wait for the mock server to start
sleep 2

# Run integration tests
flutter test integration_test/app_flow_test.dart

# Kill the mock server
kill $MOCK_SERVER_PID 