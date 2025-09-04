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


For generating mocks and testing:
    flutter pub run build_runner build --delete-conflicting-outputs

    flutter test .\test\unit

For integration tests:
    flutter drive --driver=test_driver/integration_test.dart --target=test/integration/app_flow_test.dart
    (Use --debug just in case you want to debug it)
    (For the time being this are not up-to-date)

For installing at the phone do this: 
    adb install build/app/outputs/flutter-apk/app-release.apk

For the web version go to project root and at a shell run the following:

$ python.exe -m http.server 8080 --directory build/web

(Or use Docker, see intructions below)

Previously you have to generate the web page(s) running:
$ flutter build web

Then with a web browser address the URL: localhost:8080 et voila!

For a complete tree execute this command in a bash: find lib -print | sed -e 's;[^/]*/;│   ;g;s;│   \([^│]\);├── \1;'

For testing you can use the following credentials

Elke Jakob: 40905849
Josef Mayr: 41505803
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
- **Port:** `8080` (Web App)
- **Port:** `8081` (Postgrest)
- **Port:** `8083` (ZMI Monitor)
- **Depends on:** PostgREST, ZMI Monitor
- **Volumes:**
  - `./Caddyfile:/etc/caddy/Caddyfile`
  - `./build/web:/web`

### 5. ZMI Monitor (`zmi-monitor`)
- **Image:** Custom build from `./zmi-monitor/Dockerfile`
- **Port:** `8083` (via Caddy)
- **Environment:**
  - Monitors BSSB ZMI server
  - Runs monitoring checks every 5 minutes
  - Provides web dashboard with charts and tables
- **Volumes:**
  - Persists monitoring data: `zmi_data:/var/www/html/data`
- **How it works:**
   - Monitoring Script: `monitor_zmi.sh` runs every 5 minutes via a background loop
   - Data Storage: Results are stored in `/var/www/html/data/https_monitor.csv`
   - Web Dashboard: HTML dashboard displays the data with charts and tables
   - Auto-refresh: Dashboard refreshes every 30 seconds
- **Troubleshoot:**
```bash  
# Check monitoring logs
docker exec zmi_monitor cat /var/log/monitor.log

# Check if monitoring process is running
docker exec zmi_monitor ps aux | grep monitor_zmi

# Check process status
docker exec zmi_monitor ps aux
```
- **Logs:**
```bash
# View monitoring script execution logs
docker exec zmi_monitor tail -f /var/log/monitor.log

# Check if the CSV file is being updated
docker exec zmi_monitor ls -la /var/www/html/data/
docker exec zmi_monitor tail -5 /var/www/html/data/https_monitor.csv
```

## How to Start

1. Install Docker and Docker Compose.

2. Start the containers:
   docker-compose up -d

3. Check running containers:
   docker ps

4. Stop all running containers:
   docker-compose down

4. Stop all running containers + delete data:
   docker-compose down -v1

5. Just in case, the DB is not initialized
   docker exec -it local_postgres psql -U devuser -d devdb

## How to Access Services

| Service      | URL                              |
|--------------|----------------------------------|
| Web App      | http://localhost:8080            |
| PostgREST    | http://localhost:8081/api        |
| ZMI Monitor  | http://localhost:8086            |
| MailHog UI   | http://localhost:8025            |
| Mail SMTP    | localhost:1025                   |
| PostgreSQL   | localhost:5432 (external tools)  |

## Notes

- Ensure `init-postgrest.sql` creates necessary schema and roles (especially `web_anon`) for PostgREST.
- You can add HTTPS support in the `Caddyfile` for production-like testing.