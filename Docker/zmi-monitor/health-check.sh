#!/bin/bash

echo "=== ZMI Monitoring Health Check ==="
echo "Timestamp: $(date)"
echo "Note: This container now uses a background loop instead of cron"
echo "Note: Simplified monitoring - just checks if server responds with {'result':true}"
echo ""

echo "1. Checking if monitoring process is running..."
if pgrep -f "monitor_zmi.sh" > /dev/null; then
    echo "   ✓ Monitoring process is running"
else
    echo "   ✗ Monitoring process is NOT running"
fi

echo ""
echo "2. Checking monitoring loop..."
ps aux | grep "while true.*monitor_zmi.sh" | grep -v grep || echo "   ✗ No monitoring loop found"

echo ""
echo "3. Checking monitoring script..."
if [ -x "/usr/local/bin/monitor_zmi.sh" ]; then
    echo "   ✓ Monitoring script exists and is executable"
else
    echo "   ✗ Monitoring script not found or not executable"
fi

echo ""
echo "4. Checking CSV file..."
if [ -f "/var/www/html/data/https_monitor.csv" ]; then
    echo "   ✓ CSV file exists"
    echo "   File size: $(wc -l < /var/www/html/data/https_monitor.csv) lines"
    echo "   Last modified: $(stat -c %y /var/www/html/data/https_monitor.csv)"
    echo "   Last 3 entries:"
    tail -3 /var/www/html/data/https_monitor.csv | sed 's/^/     /'
else
    echo "   ✗ CSV file not found"
fi

echo ""
        echo "5. Checking log files..."
        if [ -f "/var/log/monitor.log" ]; then
            echo "   ✓ Monitor log exists"
            echo "   Last 5 log entries:"
            tail -5 /var/log/monitor.log | sed 's/^/     /'
        else
            echo "   ✗ Monitor log not found"
        fi

echo ""
echo "6. Testing monitoring script..."
echo "   Running monitoring script..."
/usr/local/bin/monitor_zmi.sh
if [ $? -eq 0 ]; then
    echo "   ✓ Monitoring script executed successfully"
else
    echo "   ✗ Monitoring script failed"
fi

echo ""
echo "7. Testing ZMI server connectivity..."
echo "   Simple ping test (skipping SSL verification):"
RESPONSE=$(curl -s --insecure --connect-timeout 3 --max-time 10 "$TARGET_URL" 2>/dev/null)
if [ $? -eq 0 ]; then
    echo "   ✓ Server responded: $RESPONSE"
    if echo "$RESPONSE" | grep -q '"result":true'; then
        echo "   ✓ Response contains expected content"
    else
        echo "   ⚠ Response format unexpected"
    fi
else
    echo "   ✗ Server connection failed"
fi

echo ""
echo "10. Checking file permissions..."
ls -la /var/www/html/data/ 2>/dev/null || echo "   ✗ Cannot access data directory"
ls -la /usr/local/bin/monitor_zmi.sh 2>/dev/null || echo "   ✗ Cannot access monitoring script"

echo ""
echo "=== Health Check Complete ==="

