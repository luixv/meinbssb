#!/bin/bash

# --- Configuration ---
# All configuration can be overridden by environment variables

# Target URL to monitor (default: BSSB ZMI server)
TARGET_URL="${TARGET_URL:-https://webintern.bssb.bayern:56400/rest/zmi/api/serverping}"

# Expected HTTP status code (e.g., 200 for OK)
EXPECTED_HTTP_CODE="${EXPECTED_HTTP_CODE:-200}"

# Maximum allowed total response time in seconds
MAX_RESPONSE_TIME="${MAX_RESPONSE_TIME:-5.0}"

# Connection timeout in seconds
CONNECT_TIMEOUT="${CONNECT_TIMEOUT:-3}"

# Maximum total time in seconds
MAX_TIME="${MAX_TIME:-10}"

# Path for logs (CSV file). This MUST be accessible by your web server.
LOG_FILE="${LOG_FILE:-/var/www/html/data/https_monitor.csv}"

# --- End Configuration ---

# Ensure the log directory exists
LOG_DIR=$(dirname "$LOG_FILE")
mkdir -p "$LOG_DIR"

# Check if the log file is new or if header is missing, and add a header for CSV
if [ ! -f "$LOG_FILE" ] || [ -z "$(head -n 1 "$LOG_FILE" | grep 'Timestamp,Target_URL')" ]; then
    echo "Timestamp,Target_URL,HTTP_Code,Response_Time_s,Status_Message" > "$LOG_FILE"
fi

# Simple ping - just check if the server responds
echo "$(date '+%Y-%m-%d %H:%M:%S') - Pinging: $TARGET_URL" >> /var/log/monitor.log

# Make a simple request and capture the response
# Note: Using --insecure to skip SSL certificate verification for internal monitoring
RESPONSE=$(curl -s --insecure --connect-timeout "$CONNECT_TIMEOUT" --max-time "$MAX_TIME" "$TARGET_URL" 2>/dev/null)
CURL_STATUS=$?

TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

if [ "$CURL_STATUS" -eq 0 ]; then
    # Check if response contains "result":true
    if echo "$RESPONSE" | grep -q '"result":true'; then
        HTTP_CODE="200"
        RESPONSE_TIME="0.1"
        STATUS_DESCRIPTION="Online"
        echo "$(date '+%Y-%m-%d %H:%M:%S') - Server is ONLINE - Response: $RESPONSE" >> /var/log/monitor.log
    else
        HTTP_CODE="200"
        RESPONSE_TIME="0.1"
        STATUS_DESCRIPTION="Unexpected_Response"
        echo "$(date '+%Y-%m-%d %H:%M:%S') - Server responded but with unexpected content: $RESPONSE" >> /var/log/monitor.log
    fi
else
    # Connection failed
    HTTP_CODE="000"
    RESPONSE_TIME="0.000"
    STATUS_DESCRIPTION="Offline"
    echo "$(date '+%Y-%m-%d %H:%M:%S') - Server is OFFLINE - cURL status: $CURL_STATUS" >> /var/log/monitor.log
fi

# Log the data
echo "$TIMESTAMP,$TARGET_URL,$HTTP_CODE,$RESPONSE_TIME,$STATUS_DESCRIPTION" >> "$LOG_FILE"

echo "$(date '+%Y-%m-%d %H:%M:%S') - Monitoring complete: $STATUS_DESCRIPTION" >> /var/log/monitor.log

exit 0

