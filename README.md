# Mein BSSB
This project is a starting point for the Mein BSSB application.
Be sure that flutter config --enable-web has been executed.
A Flutter application for managing BSSB-related stuff.

IMPORTANT: In order to view (and edit) this file you can use the online editor Stackedit: https://stackedit.io/app#

## CI/CD Pipeline

This project uses GitHub Actions for continuous integration and deployment. The pipeline includes:

- Automated testing
- Code coverage reporting
- Android, iOS, web and Windows builds
- Automated releases

### Pipeline Steps

1. **Test**: Runs all tests and generates coverage reports
2. **Build**: Creates release builds for Android (AAB, APK-TEST, APK-PROD)
3. **Deploy**: Creates a GitHub release with the built artifacts

### Version Management

Version management is handled through the pipeline:
See <root>/.github/workflows/flutter.yml
```
  INCREMENT_BUILD_NUMBER: 'yes'
```
The variable INCREMENT_BUILD_NUMBER must be set to yes. Then just make a normal push to git.
If -for any reason- you want to avoid the unit test just set:
```
  RUN_UNIT_TESTS: 'false'
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

    If some packages have newer versions run:
    flutter pub outdated / flutter pub upgrade

For generating mocks and testing:
    flutter pub run build_runner build --delete-conflicting-outputs

For integration tests:
    flutter drive --driver=test_driver/integration_test.dart --target=test/integration/app_flow_test.dart
    (Use --debug just in case you want to debug it)
    (For the time being this are not up-to-date)

For installing at the phone do this: 
    adb install build/app/outputs/flutter-apk/app-release.apk
    Or easily open the corresponding apk with the package installer at yuor phone.

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


## How to deploy and create a new APK

First get a VPN connection to BSSB-Server.
This can be done using OpenVPN Connect (URL = vpn.bssb.bayern)
(You have to have installed AuthPoint at your phone)

In case the VPN does not work call Gmelch IT +49 89 452217420
 
Get a shell at the BSSB-Server (I use putty for that)
For this you need the password for the admin user (username: bssb-admin). Ask the project leader.

After that you will get a shell at the server (bssb-admin@mbssb-app-01:~$)

cd ./meinbssb/app/meinbssb/scripts/

./deployAndBuild.sh

It might be the case that this script has no running mode.

ls -l deployAndBuild.sh
-rw-rw-r--  1 bssb-admin bssb-admin 4338 Sep 25 16:49 deployAndBuild.sh

If this is the case just

chmod 0755 deployAndBuild.sh

When running this it will be asked:

Username for 'https://github.com
(well, I use my email address luis.mandel@nttdata.com )
The password MUST be your TOKEN and NOT your password

The result of this script is a new deployment and a new APK

The APK is located under build/app/outputs/flutter-apk/app-debug.apk

Using FTP (I use filezilla) upload the new APK version to out teams 

The PATH to the APK file is /home/bssb-admin/meinbssb/app/meinbssb/build/app/outputs/flutter-apk/<APK file>

Note: The version number is incremented automatically. DO NOT MAKE IT MANUALLY



## How to create a Release
This has to be done ONLY ONCE, and it is already done. Therefore, it is 
- Generating the upload-keystore.jks

cd C:\projekte\BSSB\meinbssb\android\app
keytool -genkey -v -keystore upload-keystore.jks -storetype JKS -keyalg RSA -keysize 2048 -validity 10000 -alias upload
$path = (Resolve-Path .\upload-keystore.jks).Path
[Convert]::ToBase64String([IO.File]::ReadAllBytes($path)) > .\upload-keystore.jks.b64
Write-Output "Wrote .\upload-keystore.jks.b64 (size: $(Get-Item .\upload-keystore.jks.b64).Length bytes)"

- Verifying

$base64 = (Get-Content ".\upload-keystore.jks.b64" | ForEach-Object { $_.Trim() }) -join ''
$keystorePath = Join-Path (Get-Location) "upload-keystore-decoded.jks"
[System.IO.File]::WriteAllBytes($keystorePath, [Convert]::FromBase64String($base64))
Write-Host "Keystore written to: $keystorePath"
if (Test-Path $keystorePath) { Write-Host "✅ Keystore exists and is ready!" } else { Write-Host "❌ Keystore NOT found!" }

keytool -list -v -keystore ".\test-upload-keystore.jks" -alias upload

- Try Locally

flutter clean
flutter pub get
flutter build apk --release --obfuscate --split-debug-info=build/app/outputs/symbols
apksigner verify --verbose build/app/outputs/flutter-apk/app-release.apk

## Notes

- Ensure `init-postgrest.sql` creates necessary schema and roles (especially `web_anon`) for PostgREST.
- You can add HTTPS support in the `Caddyfile` for production-like testing.


### Android Deployment
In order to deploy Android version go to:
https://play.google.com/console/u/2/developers
log in
Choose MeinBSSB
At the left hand side menu choose "Test and Release -> Production"
Click the button "Create Release"
Then follow the instructions at the screen.

You have to drag and drop an "AAB" version which has been generated by the github pipeline.
Normally versions are like: release-1.2.9+134-PROD.aab.

Take into account that github will automatically zip every artifact. Therefore you have to unzip the generated AAB
in order to upload it to google.

### Firebase
Firebase is Google's Backend-as-a-Service (BaaS) platform providing developers with tools and services (like databases, authentication, hosting, switches and analytics) to build, improve, and scale high-quality web and mobile applications without managing server infrastructure.

We have at Firebase 4 settings:
- app_enabled
  This is the "Kill switch". It can be set to "on" and "off"
- kill_switch_message
  The message to be shown if the App is disabeld. Preset to "Die App ist vorübergehend deaktiviert"
- minimum_required_version
  This value will be used in order to check if there a "compulsory update" or not.
- update_message
  Update Message for a new Version. Preset to 
  "Es ist eine neue Version von MeinBSSB verfügbar. Bitte installieren Sie die neue Version. Ihr MeinBSSB Support."

In order to see/change these settings you have to:
- Open a web broweser at: https://console.firebase.google.com/u/1/
- Log in
- Select the project "Mein BSSB"
- Follow the instructions at the screen
