# Mein BSSB - AI Copilot Instructions

## Project Overview
**Mein BSSB** is a multi-platform Flutter application for managing BSSB (German sports shooting association) member data and training events. It supports Android, iOS, Windows, macOS, Linux, and Web platforms with a comprehensive CI/CD pipeline.

### Key Technologies
- **Flutter 3.38.3** (stable channel) with Dart 3.7.2+
- **Provider** pattern for state management
- **Firebase** (Remote Config, Analytics, Core)
- **HTTP/REST API** backend with PostgREST support
- **Shared Preferences** for local storage
- **build_runner** with mockito for test generation
- **GitHub Actions** CI/CD with automated versioning

---

## Architecture Patterns

### Layered Service Architecture
The app follows a clear separation of concerns with three service layers:

**API Services** (`lib/services/api/`): Domain-specific business logic
- `auth_service.dart` - Authentication & JWT token management
- `user_service.dart` - User data & profile operations
- `training_service.dart` - Training event & enrollment management
- `bank_service.dart`, `verein_service.dart`, `bezirk_service.dart` - Domain-specific data
- Each service wraps PostgREST/REST API calls with error handling

**Core Services** (`lib/services/core/`): Infrastructure & cross-cutting concerns
- `http_client.dart` - HTTP interceptor with auth headers, error handling, retry logic
- `config_service.dart` - Runtime configuration (dev/test/prod) from `assets/config.*.json`
- `postgrest_service.dart` - PostgREST database abstraction
- `cache_service.dart` - In-memory caching with cache key patterns
- `token_service.dart` - JWT token storage & refresh via shared_preferences
- `logger_service.dart` - Centralized logging with log levels
- `network_service.dart` - Connectivity monitoring (internet_connection_checker)
- `email_service.dart` - Email integration (mailer package)
- `image_service.dart` - Photo upload/download & compression

**ApiService** (`lib/services/api_service.dart`): Facade that composes all services
- 744 lines of domain-level methods (e.g., `getProfilePhoto()`, `postBSSBAppPassantrag()`)
- Injected with all API & core services
- Used directly by screens via Provider
- Reference: [ApiServiceMethodCallsByScreen.md](../ApiServiceMethodCallsByScreen.md) documents which API methods each screen calls

### Dependency Injection via Provider
All services are registered in `lib/main.dart` via `AppInitializer`:
```dart
// Example provider pattern
AppInitializer.authServiceProvider,      // Singleton auth service
AppInitializer.apiServiceProvider,       // Facade service
ChangeNotifierProvider(create: (_) => ThemeProvider()),  // State notifier
```

**Important**: Core services initialize in dependency order. `token_service` must be ready before `http_client` (for auth headers). PostgREST service depends on config service.

### State Management
- **Provider** package for dependency injection & change notification
- **ChangeNotifierProvider** for mutable state (ThemeProvider, FontSizeProvider, KillSwitchProvider)
- **MultiProvider** at app root wraps entire widget tree
- No Redux/BLoC - keep it simple with Provider

---

## Critical Developer Workflows

### Local Setup & Testing
```bash
# Install dependencies
flutter pub get

# Run local tests with coverage (required before PR)
flutter test ./test/unit --coverage

# Open coverage report
coverage/lcov-report/index.html

# Code quality checks (must pass before commit)
./scripts/quality.sh
  # Runs: flutter analyze, dart format, dart fix, test coverage

# Generate mocks for new tests
flutter pub run build_runner build --delete-conflicting-outputs

# Run the app locally (pick device)
flutter run
```

### Building for Different Platforms/Environments
The project has 3 runtime configurations:
- `assets/config.dev.json` - Local development
- `assets/config.test.json` - QA/testing environment
- `assets/config.prod.json` - Production

**Build for platform**:
```bash
# Android APK/AAB (signed with keystore)
flutter build apk --release
flutter build appbundle --release

# Web
flutter build web --release

# Windows/Mac/Linux
flutter build windows --release
```

**CI/CD Pipeline** (`.github/workflows/flutter.yml`):
1. **Test job** - Runs all unit tests, generates coverage report, uploads to codecov
2. **Build PROD** - Increments version in pubspec.yaml, builds APK/AAB/Web with prod config
3. **Build TEST** - Uses same version from PROD job, builds APK with test config
4. **Create Release** - Packages artifacts into GitHub Release

**Version Management**: Controlled by CI variables:
- `INCREMENT_BUILD_NUMBER: 'true'` - Increments build number (e.g., `1.2.11+145` → `+146`)
- `INCREMENT_VERSION_NUMBER: 'false'` - Increments patch version (e.g., `1.2.11` → `1.2.12`)
- `RUN_UNIT_TESTS: 'true'` - Skip if CI issues occur (not recommended)

### Testing Requirements (Enforced by CI)
- **All unit tests must pass** - `flutter test ./test/unit --coverage`
- **Coverage tracked** - Reports uploaded to codecov via GitHub Actions
- **Test structure**: `test/unit/{services,widgets,helpers,models,providers,screens}/`
- **Use mockito** for API service mocks: `flutter pub run build_runner build --delete-conflicting-outputs`
- Tests use `flutter_test` and `provider` for widget testing

### PR Checklist (from CODING_RULES.md)
1. Create branch from ticket (format: `TICKET-XXX-short-description`)
2. Implement changes with **daily** git pulls from main
3. Run `./scripts/quality.sh` - must pass (no warnings)
4. Test locally on web: `flutter build web`
5. Test on phone (emulator or real device APK)
6. Check code coverage: `flutter test ./test/unit --coverage` (review lcov-report)
7. Commit with meaningful message (CI will auto-version)
8. Push & open PR (do NOT merge yourself - assign to peer)

---

## Project Conventions & Patterns

### Naming Conventions
- **Screen files**: `*_screen.dart` in `lib/screens/` (e.g., `personal_data_screen.dart`)
- **Service files**: `*_service.dart` in `lib/services/` (both API & core)
- **Model files**: `*_data.dart` in `lib/models/` (not `*_model.dart`)
- **Widget files**: `*_widget.dart` in `lib/widgets/`
- **Providers**: `*_provider.dart` in `lib/providers/`

### Error Handling Pattern
```dart
// Core: NetworkException for API failures
class NetworkException implements Exception {
  NetworkException(this.message);
  final String message;
}

// Usage: API services throw NetworkException with user-friendly message
// Http client catches and wraps in NetworkException
// UI catches and shows snackbar to user
```

### Configuration Pattern
- Config loaded from `assets/config.*.json` based on build target
- Accessed via `configService.getBaseUrl()`, `configService.isDevelopment`
- Allows environment-specific endpoints without code changes

### Cache Key Pattern
CacheService uses explicit string keys:
```dart
static const String userProfileCache = 'user_profile_${userId}';
static const String schoolingCache = 'schooling_list';
```
Look in service classes for `static const String` cache key definitions.

### Authentication Flow
1. **Token storage**: JWT stored in SharedPreferences via TokenService
2. **Auto-refresh**: HttpClient intercepts 401 responses, calls TokenService.refreshToken()
3. **Auth header**: HttpClient automatically adds `Authorization: Bearer ${token}` to all requests
4. **Logout**: Clear token from SharedPreferences and pop to LoginScreen

### Image Upload/Download
- ProfilePhotos: `getProfilePhoto(userId)` returns Uint8List
- Upload: `uploadProfilePhoto(userId, imageBytes)` with multipart form
- Compression handled by ImageService before upload
- Reference: API methods in `ApiService` handle profile photo operations (getProfilePhoto, uploadProfilePhoto, deleteProfilePhoto)

### Locale & Internationalization
- **German locale** initialized at startup: `initializeDateFormatting('de_DE', null)`
- Date formatting via `intl` package - always specify `de_DE` locale
- UI constants in `lib/constants/ui_constants.dart` (colors, strings, borders)

### Web Platform Specifics
- **URL strategy**: Uses path-based URLs (no `#`) via `usePathUrlStrategy()` - set once in main()
- **Platform checks**: Use `dart:io Platform.isWeb`, wrapped in try-catch for test environments
- **Conditional imports**: `web_storage_web.dart` vs `web_storage_stub.dart` for platform-specific code
- Note: `flutter config --enable-web` must be run before `flutter run`

### Kill Switch & Compulsory Update Gates
Wrap screens with feature gates via Firebase Remote Config:
- `KillSwitchGate` - Disable feature if needed
- `CompulsoryUpdateGate` - Force update from App Store
- Reference: [kill_switch_gate.dart](../lib/widgets/kill_switch_gate.dart), [compulsory_update_gate.dart](../lib/widgets/compulsory_update_gate.dart)

---

## Integration Points

### PostgREST Backend
- **Service**: PostgrestService wraps PostgREST client
- **Common patterns**: Filter queries via `filters={'field': 'value'}`, pagination via `limit` & `offset`
- **Example**: `training_service.dart` queries schulungstermine table via PostgREST

### Firebase Integration
- **Remote Config**: Used for kill switches, feature flags, config values
- **Analytics**: Track user events (handled separately)
- **Initialization**: `firebase_options.dart` auto-generated by FlutterFire CLI
- **Offline tolerance**: Firebase init wrapped in try-catch (allow offline-first mode)

### Connectivity Monitoring
- `network_service.dart` uses `internet_connection_checker` package
- Useful for: disabling submit buttons when offline, showing offline banner
- Example: Check `_networkService.isConnected()` before API calls

### Email Integration
- `email_service.dart` uses `mailer` package for SMTP
- Common use: Send password reset links, notifications
- Reference: Check actual implementation for SMTP config (dev/test/prod different)

---

## Common Modification Patterns

### Adding a New API Method
1. Create service in `lib/services/api/` if new domain (e.g., `reporting_service.dart`)
2. Add methods that call PostgREST or REST endpoints
3. Register in `ApiService` facade (`lib/services/api_service.dart`) constructor & as field
4. Add provider registration in `AppInitializer` (main.dart)
5. Call from screen via `apiService.myNewMethod()` injected by Provider
6. Add to `ApiServiceMethodCallsByScreen.md` for documentation

### Adding a New Screen
1. Create `lib/screens/my_feature_screen.dart` extending StatefulWidget
2. Get ApiService via `final apiService = Provider.of<ApiService>(context, listen: false);`
3. Call API methods and update local state or use Provider state
4. Register route in `app.dart` navigation
5. Handle loading states, errors (show SnackBar), and success states
6. Add unit tests in `test/unit/screens/my_feature_screen_test.dart`

### Modifying HTTP Client Behavior
- Central point: `lib/services/core/http_client.dart`
- Adds auth headers, handles token refresh, error translation
- Add new interceptor logic here (rate limiting, retry policy, etc.)
- **Avoid** making raw `http.post()` calls - always go through httpClient

### Adding New Configuration Values
1. Add to `assets/config.dev.json`, `assets/config.test.json`, `assets/config.prod.json`
2. Read via `configService.getString('myKey')` or `configService.getInt('myKey')`
3. Document in README.md under "Configuration"

---

## Testing & Code Coverage

### Unit Test Structure
- Use `flutter_test` with `testWidgets()` for UI, `test()` for business logic
- Mock services with mockito: `@GenerateMocks([ApiService])` → `flutter pub run build_runner build`
- Provider testing: Wrap widget with `MultiProvider` in testWidgets
- Reference: [kill_switch_gate_test.dart](../test/unit/widgets/kill_switch_gate_test.dart)

### Coverage Expectations
- Aim for **>80% coverage** on business logic (services, models)
- UI tests focus on critical user flows, not exhaustive coverage
- CI blocks merge if coverage drops significantly (tracked by codecov)

### Running Tests
```bash
# Unit tests only (fast, ~30s)
flutter test ./test/unit

# With coverage report
flutter test ./test/unit --coverage

# Integration tests (slow, requires device/emulator)
flutter drive --driver=test_driver/integration_test.dart --target=test/integration/app_flow_test.dart --debug
```

---

## Quick Reference: Key Files

| File | Purpose |
|------|---------|
| [lib/main.dart](../lib/main.dart) | App entry point, service initialization via Provider |
| [lib/app.dart](../lib/app.dart) | Root widget, routing, theme provider setup |
| [lib/services/api_service.dart](../lib/services/api_service.dart) | **Main facade** - all domain API methods (744 lines) |
| [lib/services/core/http_client.dart](../lib/services/core/http_client.dart) | HTTP interceptor, auth headers, token refresh |
| [lib/services/core/config_service.dart](../lib/services/core/config_service.dart) | Runtime config from assets/config.*.json |
| [lib/constants/ui_constants.dart](../lib/constants/ui_constants.dart) | Colors, dimensions, UI standards |
| [.github/workflows/flutter.yml](./workflows/flutter.yml) | CI/CD pipeline, versioning, build process |
| [pubspec.yaml](../pubspec.yaml) | **DO NOT EDIT VERSION** - CI manages it |
| [CODING_RULES.md](../CODING_RULES.md) | PR process & developer workflow |
| [ApiServiceMethodCallsByScreen.md](../ApiServiceMethodCallsByScreen.md) | Maps screens to API method dependencies |

---

## Troubleshooting Tips

**"Unable to boot simulator" or device connection issues**
- Ensure Flutter SDK is in PATH: `flutter doctor`
- Rebuild: `flutter clean && flutter pub get && flutter run`

**"Certificate pinning failed" / network errors**
- Check HttpClient interceptor - may be rejecting self-signed certs in dev
- Use `config.dev.json` endpoint (localhost) for local testing

**"Provider not found" or "Null safety" errors**
- Ensure all services are registered in `AppInitializer` before use
- Use `listen: false` when getting provider outside build method

**"Tests fail after dependency changes"**
- Regenerate mocks: `flutter pub run build_runner build --delete-conflicting-outputs`
- Clear cache: `flutter clean`

**Version conflicts in CI**
- CI auto-manages version - **never edit pubspec.yaml version directly**
- If merge conflicts occur, take CI's version and re-trigger workflow

