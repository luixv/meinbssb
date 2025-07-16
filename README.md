# Mein BSSB

This project is a starting point for the Mein BSSB application.
Be sure that flutter config --enable-web has been executed.
A Flutter application for managing BSSB-related stuff.

## CI/CD Pipeline

This project uses GitHub Actions for continuous integration and deployment. The pipeline includes:

- Automated testing
- Code coverage reporting
- Android, iOS, web and Windows builds
- Automated releases

### Pipeline Steps

1. **Test**: Runs all tests and generates coverage reports
2. **Build**: Creates release builds for Android and iOS
3. **Deploy**: Creates a GitHub release with the built artifacts

### Version Management

Version management is handled through the `scripts/version.sh` script:

```bash
# Increment patch version
./scripts/version.sh patch

# Increment minor version
./scripts/version.sh minor

# Increment major version
./scripts/version.sh major
```

### Code Quality

Code quality checks are automated through the `scripts/quality.sh` script:

```bash
./scripts/quality.sh
```

This script runs:
- Flutter analyze
- Dart format check
- Dart fix
- Test coverage

## Getting Started

1. Clone the repository
2. Install dependencies:
   ```bash
   flutter pub get
   ```
3. Run the app:
   ```bash
   flutter run
   ```

## Testing

Run tests with coverage:
```bash
flutter test  .\test\unit --coverage
```

## Contributing

1. Create a feature branch
2. Make your changes
3. Run quality checks:
   ```bash
   ./scripts/quality.sh
   ```
4. Submit a pull request

For building the project:
    flutter clean 
    flutter pub get
    flutter build web                                  
    flutter run

    flutter pub run build_runner build --delete-conflicting-outputs

For generating mocks and testing:
    flutter pub run build_runner build
    flutter test .\test\unit\screens .\test\unit\services\

For integration tests:
    flutter drive --driver=test_driver/integration_test.dart --target=test/integration/app_flow_test.dart
    (Use --debug just in case you want to debug it)

For installing at the phone do this: 
    adb install build/app/outputs/flutter-apk/app-release.apk

For the web version go to project root and at a shell run the following:

$ python.exe -m http.server 8080 --directory build/web

Previously you have to generate the web page(s) running:
$ flutter build web

Then with a web browser address the URL: localhost:8080 et voila!

For a complete tree execute this command in a bash: find lib -print | sed -e 's;[^/]*/;│   ;g;s;│   \([^│]\);├── \1;'


# Local Development Setup

This project uses Docker Compose to orchestrate a local development environment consisting of:

- PostgreSQL
- PostgREST
- MailHog
- Caddy

## Services Overview

### 1. PostgreSQL (`local_postgres`)
- **Image:** `postgres:16`
- **Port:** `5432`
- **Volumes:**
  - Persists data: `pgdata:/var/lib/postgresql/data`
  - Initializes DB schema: `./init-postgrest.sql:/docker-entrypoint-initdb.d/init-postgrest.sql`
- **Credentials:**
  - **DB Name:** `devdb`
  - **User:** `devuser`
  - **Password:** `devpass`

### 2. PostgREST (`postgrest`)
- **Image:** `postgrest/postgrest`
- **Port:** `3000`
- **Depends on:** PostgreSQL
- **Environment:**
  - Connects to PostgreSQL on `local_postgres:5432`
  - Anonymous role: `web_anon`
  - Schema: `public`
  - CORS enabled
  - Proxy URI: `http://localhost:3000`

### 3. MailHog (`local_mailhog`)
- **Image:** `mailhog/mailhog`
- **Ports:**
  - SMTP (send mail): `1025`
  - Web UI: `8025`
- **Access Web UI:** [http://localhost:8025](http://localhost:8025)

### 4. Caddy (`caddy`)
- **Image:** `caddy:2`
- **Port:** `8081`
- **Depends on:** PostgREST
- **Volumes:**
  - `./Caddyfile:/etc/caddy/Caddyfile`
  - `./build/web:/web`

## How to Start

1. Install Docker and Docker Compose.

2. Start the containers:
   ```bash
   docker-compose up -d
   ```

3. Check running containers:
   ```bash
   docker ps
   ```

## How to Access Services

| Service      | URL                              |
|--------------|----------------------------------|
| Caddy        | http://localhost:8081            |
| PostgREST    | http://localhost:3000            |
| MailHog UI   | http://localhost:8025            |
| Mail SMTP    | localhost:1025                   |
| PostgreSQL   | localhost:5432 (external tools)  |

## Notes

- Ensure `init-postgrest.sql` creates necessary schema and roles (especially `web_anon`) for PostgREST.
- You can add HTTPS support in the `Caddyfile` for production-like testing.