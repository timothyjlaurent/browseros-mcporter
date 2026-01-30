#!/bin/bash
# BrowserOS launcher - checks if running, launches desktop app if needed

BROWSEROS_HEALTH="http://127.0.0.1:9100/health"
BROWSEROS_CMD="env DESKTOPINTEGRATION=1 /home/dadmin/AppImages/browseros.appimage %U"
LAUNCH_TIMEOUT=30

# Check if BrowserOS is running
check_browseros() {
    curl -s "$BROWSEROS_HEALTH" 2>/dev/null | grep -q '"status":"ok"'
}

# Check if BrowserOS desktop app is running
check_browseros_process() {
    pgrep -x -i "browseros.appimage" >/dev/null 2>&1
}

# Launch BrowserOS desktop app
launch_browseros() {
    echo "BrowserOS not running. Launching..." >&2
    
    # Launch BrowserOS desktop app in background
    nohup bash -c "$BROWSEROS_CMD" > /tmp/browseros.log 2>&1 &
    
    # Wait for BrowserOS to be ready
    local waited=0
    while [ $waited -lt $LAUNCH_TIMEOUT ]; do
        sleep 1
        if check_browseros; then
            echo "BrowserOS is ready!" >&2
            return 0
        fi
        waited=$((waited + 1))
        echo "Waiting for BrowserOS... ($waited/$LAUNCH_TIMEOUT)" >&2
    done
    
    echo "Timeout waiting for BrowserOS to start. Check /tmp/browseros.log" >&2
    return 1
}

# Main logic
if ! check_browseros; then
    # Check if process exists (might be running but not responding)
    if check_browseros_process; then
        echo "BrowserOS process found but health check failed." >&2
        echo "Restart to fix." >&2
        exit 1
    fi
    
    # BrowserOS not running at all - launch it
    if ! launch_browseros; then
        echo "Error: Could not start BrowserOS" >&2
        exit 1
    fi
fi

echo "BrowserOS is running"
exit 0
