#!/bin/bash
# Script devoted to deploy and build a new apk and web version of meinBSSB.
# It includes the increment of the version number from pubspec.yaml
# The increment is done following the "semver" notation.

PROJECT_DIR="$HOME/meinbssb/app/meinbssb"
SCRIPTS_DIR="$HOME/meinbssb/scripts"
REPO_URL="https://github.com/luixv/meinbssb.git"

# Enable strict mode: exit on error, unset variables, and pipefail
set -euo pipefail

# --- Script Start ---
echo "--- Flutter Project CI/CD Script ---"

BRANCH=${1:-main}  # Use the first argument as branch name, default to 'main'

echo "Project Directory: $PROJECT_DIR"

if [ -z "${REPO_URL:-}" ]; then # Check if REPO_URL is unset or empty
  read -rp "Enter your Git repository URL (e.g., https://github.com/user/repo.git): " REPO_URL
  if [ -z "$REPO_URL" ]; then
    echo "Error: Repository URL cannot be empty. Exiting."
    exit 1
  fi
fi

echo "Repository URL: $REPO_URL"

# --- Extract from GIT ---
if [ -d "$PROJECT_DIR" ]; then
  echo "Project directory '$PROJECT_DIR' already exists. Pulling latest changes..."
  cd "$PROJECT_DIR"
  # Reset changes. No changes allowed at the server. Changes belongs to GIT.
  git reset --hard HEAD
  git pull origin "$(git rev-parse --abbrev-ref HEAD)" # Pull current branch
  echo "Pulled latest changes."
else
  echo "Cloning project into '$PROJECT_DIR'..."
  git clone "$REPO_URL" "$PROJECT_DIR"
  cd "$PROJECT_DIR"
  echo "Project cloned."
fi

# Ensure we are in the project directory
if [ ! -f "pubspec.yaml" ]; then
  echo "Error: pubspec.yaml not found in '$PWD'. Make sure '$PROJECT_DIR' is the root of your Flutter project."
  exit 1
fi

# Ensure we are in the project directory
if [ ! -f "pubspec.yaml" ]; then
  echo "Error: pubspec.yaml not found in '$PWD'. Make sure '$PROJECT_DIR' is the root of your Flutter project."
  exit 1
fi

echo "--- Parsing and Incrementing Version ---"

# --- Get the current version line from pubspec.yaml ---

VERSION_LINE=$(grep "version:" pubspec.yaml)

if [ -z "$VERSION_LINE" ]; then
  echo "Error: 'version:' line not found in pubspec.yaml. Exiting."
  exit 1
fi
echo "Version line '$VERSION_LINE' ."

# --- Extract the current version string (e.g., "1.0.0+1") ---
CURRENT_VERSION_STRING=$(echo "$VERSION_LINE" | cut -d' ' -f2 | tr -d '\r') # tr -d '\r' to handle Windows line endings

# Split into semantic version and build number
SEMVER=$(echo "$CURRENT_VERSION_STRING" | cut -d'+' -f1)
BUILD_NUM_STR=$(echo "$CURRENT_VERSION_STRING" | cut -d'+' -f2)

NEW_BUILD_NUM=1 # Default if no build number found
if [ -n "$BUILD_NUM_STR" ]; then # Check if build number part exists
  NEW_BUILD_NUM=$((BUILD_NUM_STR + 1))
fi

NEW_VERSION="${SEMVER}+${NEW_BUILD_NUM}"

echo ""
echo "Current Version: $CURRENT_VERSION_STRING"
echo "New Version: $NEW_VERSION"
echo ""

# --- Update pubspec.yaml with the new version ---
sed -i "s/^version: .*/version: $NEW_VERSION/" pubspec.yaml

echo "Updated pubspec.yaml to version: $NEW_VERSION"

grep "version:" pubspec.yaml

echo "--- Committing and Pushing Changes ---"

# --- Update pubspec.yaml with the new version ---
sed -i "s/^version: .*/version: $NEW_VERSION/" pubspec.yaml

echo "Updated pubspec.yaml to version: $NEW_VERSION"

grep "version:" pubspec.yaml

echo "--- Committing and Pushing Changes ---"

# --- Update pubspec.yaml in GIT ---
git config user.email "deploy@example.com"
git config user.name "Automated Deploy Script"
git add pubspec.yaml
git commit -m "Bump version to $NEW_VERSION"
git push origin "$(git rev-parse --abbrev-ref HEAD)" # Push to the current branch

# --- Switch config files to test version ---
 echo "🔧 Switching config to test version..."
 rm -f assets/config.json
 cp assets/config.test.json assets/config.json

# --- Build Flutter web app ---
echo "Building Flutter web app..."
flutter build web

echo "Web version complete for branch: $BRANCH"

echo "Building Flutter APK (debug)..."
flutter build apk --debug

rm -f build/app/outputs/flutter-apk/app-debug-*

# No more the date. Instead the NEW_VERSION
# mv build/app/outputs/flutter-apk/app-debug.apk build/app/outputs/flutter-apk/app-debug-$(date +'%Y-%m-%d_%H-%M').apk
mv build/app/outputs/flutter-apk/app-debug.apk build/app/outputs/flutter-apk/app-debug-$NEW_VERSION.apk

cd build/app/outputs/flutter-apk

ls -latr .

echo "APK version complete for branch: $BRANCH"
