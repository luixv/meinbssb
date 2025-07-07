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


# Database Setup

This directory contains database migrations and setup scripts for the MeinBSSB application.

## Prerequisites

1. PostgreSQL installed and running
2. PostgREST installed
3. Database user `devuser` with password `devpass` created with appropriate permissions

## Initial Setup

1. Create the database user if not exists:
```sql
CREATE USER devuser WITH PASSWORD 'devpass' CREATEDB;
```

2. Run the initialization script:
```bash
cd scripts
chmod +x init_db.sh
./init_db.sh
```

This will:
- Create the database if it doesn't exist
- Run all migrations in order
- Set up necessary permissions

## Starting PostgREST

After database initialization, start PostgREST:

```bash
postgrest postgrest.conf
```

PostgREST will run on port 3000 and provide a REST API for the database.

## Manual Migration

If you need to run migrations manually:

```bash
psql -U devuser -d devdb -f db/migrations/001_create_users_table.sql
```

## Database Structure

### Users Table
- `id`: Serial primary key
- `username`: Unique email address
- `pass_number`: Unique BSSB pass number
- `verification_link`: Unique verification token
- `created_at`: Timestamp of user creation
- `verified_at`: Timestamp of email verification
- `is_verified`: Boolean flag for verification status

## Adding New Migrations

1. Create a new SQL file in `db/migrations/` with an incremental number
2. Add the file to the initialization script
3. Test the migration on a development database first 

