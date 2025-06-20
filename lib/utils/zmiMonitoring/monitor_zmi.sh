#!/bin/bash

# --- Configuration ---
TARGET_URL="https://webintern.bssb.bayern:56400/rest/zmi/api/serverping"

# Expected HTTP status code (e.g., 200 for OK)
EXPECTED_HTTP_CODE="200"

# Maximum allowed total response time in seconds
MAX_RESPONSE_TIME=5.0

# Path for logs (CSV file). This MUST be accessible by your web server.
# This path should match what your web page's JavaScript is trying to read.
LOG_FILE="/volume1/web/zmi/https_monitor.csv"

# --- End Configuration ---

# Ensure the log directory exists
LOG_DIR=$(dirname "$LOG_FILE")
mkdir -p "$LOG_DIR"

# Check if the log file is new or if header is missing, and add a header for CSV
# All original columns are back: Timestamp,Target_URL,HTTP_Code,Response_Time_s,Status_Message
if [ ! -f "$LOG_FILE" ] || [ -z "$(head -n 1 "$LOG_FILE" | grep 'Timestamp,Target_URL')" ]; then
    echo "Timestamp,Target_URL,HTTP_Code,Response_Time_s,Status_Message" >> "$LOG_FILE"
fi

# Perform the HTTPS request and capture status code and total time
CURL_OUTPUT=$(curl -s -o /dev/null -w "%{http_code}:%{time_total}" -L --connect-timeout 5 --max-time 10 "$TARGET_URL")
CURL_STATUS=$? # Capture curl's exit status

# Parse the output from curl
HTTP_CODE=$(echo "$CURL_OUTPUT" | cut -d':' -f1)
RESPONSE_TIME=$(echo "$CURL_OUTPUT" | cut -d':' -f2) # Floating-point number

TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
STATUS_DESCRIPTION="OK" # Default status message for logging

# --- Determine status message for logging ---
if [ "$CURL_STATUS" -ne 0 ]; then
    STATUS_DESCRIPTION="Curl_Error"
elif [ "$HTTP_CODE" != "$EXPECTED_HTTP_CODE" ]; then
    STATUS_DESCRIPTION="HTTP_Code_Mismatch"
else
    if (( $(echo "$RESPONSE_TIME > $MAX_RESPONSE_TIME" | awk '{print ($1 > $2)}') )); then
        STATUS_DESCRIPTION="Slow_Response"
    else
        STATUS_DESCRIPTION="Online" # Changed from "Responded successfully." for conciseness
    fi
fi

# --- Always log the data for statistics (all 5 columns) ---
echo "$TIMESTAMP,$TARGET_URL,$HTTP_CODE,$RESPONSE_TIME,$STATUS_DESCRIPTION" >> "$LOG_FILE"

exit 0

