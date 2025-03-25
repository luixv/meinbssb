# meinbssb

A new Flutter project.

## Getting Started

This project is a starting point for the Mein BSSB application

For building the project:
    flutter clean 
    flutter pub get                                  
    flutter run

For generating mocks and testing:
    flutter pub run build_runner build
    flutter test

Follow this structure: 
lib/
├── services/
│   ├── email_manager.dart  # New file
│   ├── api_service.dart
│   └── localization_service.dart
├── data/
│   └── email_queue_db.dart
└── screens/
    └── *_screen

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
