#!/bin/bash

PID_DIR="tmp/pids"
mkdir -p "$PID_DIR"

# Function to stop a service using its PID file
stop_service() {
  local pid_file="$1"
  local service_name="$2"

  if [ ! -f "$pid_file" ]; then
    echo "$service_name PID file not found. The service may not be running."
    return 1
  fi

  local pid=$(cat "$pid_file")

  # Check if the process is running
  if ! ps -p "$pid" > /dev/null; then
    echo "Process with PID $pid for $service_name not found. Removing stale PID file."
    rm "$pid_file"
    return 1
  fi

  # Kill the process
  echo "Stopping $service_name with PID: $pid"
  kill -15 "$pid"

  # Wait for process to terminate
  for i in {1..10}; do
    if ! ps -p "$pid" > /dev/null; then
      echo "$service_name stopped successfully."
      if [ -f "$pid_file" ]; then
        rm "$pid_file"
      fi
      return 0
    fi
    sleep 1
  done

  # Force kill if graceful shutdown failed
  echo "$service_name did not stop gracefully. Forcing shutdown."
  kill -9 "$pid"
  if [ -f "$pid_file" ]; then
    rm "$pid_file"
  fi
  echo "$service_name stopped forcefully."
  return 0
}

# Stop all services
services_stopped=0
services_failed=0

# Stop Rails server
if stop_service "$PID_DIR/server.pid" "Rails server"; then
  ((services_stopped++))
else
  ((services_failed++))
fi

# Stop Sidekiq if it's running
# if stop_service "$PID_DIR/sidekiq.pid" "Sidekiq"; then
#   ((services_stopped++))
# else
#   ((services_failed++))
# fi

# Add more services here as needed
# Example:
# if stop_service "$PID_DIR/another_service.pid" "Another Service"; then
#   ((services_stopped++))
# else
#   ((services_failed++))
# fi

# Report summary
echo ""
echo "Summary: Stopped $services_stopped service(s)"

if [ $services_stopped -eq 0 ] && [ $services_failed -gt 0 ]; then
  echo "No services were running."
fi
