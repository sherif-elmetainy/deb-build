#!/bin/bash

LOGFILE="/var/foo/service.log"
RUNNING=true

# Function to handle termination signals
terminate() {
    echo "Service is stopping..." >> "$LOGFILE"
    RUNNING=false
}

# Trap SIGTERM and SIGINT signals and call the terminate function
trap terminate SIGTERM SIGINT

# Main loop
echo "Service is starting..." >> "$LOGFILE"
while $RUNNING; do
    echo "$(date): Service is running..." >> "$LOGFILE"
    sleep 10
done
echo "Service has stopped." >> "$LOGFILE"