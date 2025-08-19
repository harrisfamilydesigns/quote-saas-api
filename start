#!/bin/bash

# Create necessary directories if they don't exist
mkdir -p log
mkdir -p tmp/pids

# Start Rails server in the background and redirect output to log/server.log
RAILS_ENV=${RAILS_ENV:-development} bundle exec rails server -d -P tmp/pids/server.pid > log/server.log 2>&1

# Get the PID and display it
PID=$(cat tmp/pids/server.pid)
echo "Rails server started with PID: $PID"
echo "Logs are being written to log/server.log"