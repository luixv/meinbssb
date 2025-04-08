# meinbssb

A new Flutter project.

## Getting Started

This project is a starting point for the Mein BSSB application.
Be sure that flutter config --enable-web has been executed.

For building the project:
    flutter clean 
    flutter pub get
    flutter build web                                  
    flutter run

    flutter pub run build_runner build --delete-conflicting-outputs

For generating mocks and testing:
    flutter pub run build_runner build
    flutter test

For the web version go to project root and at a shell run the following:

$ python.exe -m http.server 8080 --directory build/web

Then with a web browser address the URL: localhost:8080

et voila!

Follow this structure: 
lib/
├── main.dart
├── constants/
├── services/
│   ├── api_service.dart
│   ├── base_service.dart
│   ├── cache_service.dart
│   ├── database_service.dart
│   ├── email_service.dart
│   ├── error_service.dart
│   ├── http_client.dart
│   ├── iban_checker.dart
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
