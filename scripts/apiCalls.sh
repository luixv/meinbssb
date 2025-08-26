#!/bin/bash

# --- Configuration ---
MAIN_DIR="../lib/services/"
SCREENS_DIR="../lib/screens/" # Directory to search within
SUBFOLDERS=("core" "api")

# --- Script Logic ---

echo "--- Collecting and converting filenames to CamelCase ---"

# Array to store all generated CamelCase service names
declare -a SERVICE_NAMES

# Loop through each subfolder to collect service names
for SUBFOLDER in "${SUBFOLDERS[@]}"; do
  FULL_PATH="$MAIN_DIR/$SUBFOLDER"

  # Check if the subfolder exists
  if [ ! -d "$FULL_PATH" ]; then
    echo "  Warning: Service subfolder '$FULL_PATH' not found. Skipping."
    continue
  fi

  for file in "$FULL_PATH"/*; do
    if [ -f "$file" ]; then
      filename_with_ext=$(basename "$file")
      filename_no_ext="${filename_with_ext%.*}"

      # Convert snake_case (e.g., auth_service) to CamelCase (e.g., AuthService)
      camel_case_name=$(echo "$filename_no_ext" | sed -r 's/(^|_)([a-z])/\U\2/g')
      SERVICE_NAMES+=("$camel_case_name") # Add to array
    fi
  done
done

echo ""
echo "--- Searching for service usages in '$SCREENS_DIR' ---"

# Check if the screens directory exists
if [ ! -d "$SCREENS_DIR" ]; then
  echo "Error: Screens directory '$SCREENS_DIR' not found. Cannot search for services."
  exit 1 # Exit with an error code
fi

# Loop through each collected service name and grep for it in the screens directory
for service_name in "${SERVICE_NAMES[@]}"; do
  echo "" # Add a blank line for readability
  echo "Searching for occurrences of '$service_name':"
  # Use grep -i for case-insensitive search and -r for recursive search
  # -n to show line numbers, -l to only show filenames if no details are needed, but here details are better
  grep -irn "$service_name" "$SCREENS_DIR"

  # Check if grep found anything and provide feedback
  if [ $? -ne 0 ]; then
    echo "  No direct occurrences of '$service_name' found in '$SCREENS_DIR'."
  fi
done

echo ""
echo "--- Search complete ---"

