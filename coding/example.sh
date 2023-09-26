#!/bin/bash
# I have used CURL for HTTP requests and jq for JSON processing

# Variable Definition

# Variables defined for JSON file, service url and log file
JSON_FILE="example.json"
SERVICE_URL="https://example.com/service/generate"
LOG_FILE="client.log"

# function to log messages with timestamps
log() {
    echo "$(date +'%Y-%m-%d %H:%M:%S') $1" >> "$LOG_FILE"
}

# Check if the JSON file exists
if [ ! -f "$JSON_FILE" ]; then
    log "Error: $JSON_FILE does not exist."
    exit 1
fi

# Validate JSON syntax
if ! jq empty < "$JSON_FILE" >/dev/null 2>&1; then
    log "Error: $JSON_FILE is not valid JSON."
    exit 1
fi

# Filter the JSON content to include only objects with private set to false
filtered_json=$(jq 'select(.private == false)' < "$JSON_FILE")

# Check if there are any matching objects, or else exit
if [ -z "$filtered_json" ]; then
    log "No objects with 'private' set to false found."
    exit 0
fi

# Make a POST request to the web service using curl
response=$(curl -s -X POST -H "Content-Type: application/json" --data "$filtered_json" "$SERVICE_URL")

# Check for errors in the response from the web svc
if [ $? -ne 0 ]; then
    log "Error: Failed to connect to the web service."
    exit 1
fi

# Parse the response and extract the keys of valid objects

valid_keys=$(echo "$response" | jq -r '.[] | select(.valid == true) | .key')

# Print valid keys or a message if there is no keys
if [ -n "$valid_keys" ]; then
    log "Valid keys:"
    echo "$valid_keys"
else
    log "No valid keys found in the web service response."
fi

# Log the script's execution status
log "Script execution completed successfully."


# any script execution errors wil be captured in the log file and cron will run at the desired time to the service account with the error output

# To send any error to email, we can create a cron using crontab -e and add the below to the crontab file
# Script execution and redirect the standard error (stderr) to a temporary file
0 0 * * * /home/task.sh >> /tmp/logfile.log 2>> /tmp/error.log
# setting Mail variable where error notifications will be sent 
MAILTO=XYZl@ASX.com
