#!/usr/bin/env bash

# ============================================================
# Server Load Test Telemetry Collector
# ------------------------------------------------------------
# Purpose:
#   Capture server-side resource utilization during stress tests
#
# Usage:
#   ./monitor.sh -d <duration_in_seconds> [-i <interval>] [-s <service>]
#
# Example (Monitor for 10 mins, every 2s, tracking jupyterhub):
#   ./monitor.sh -d 600 -i 2 -s jupyterhub
#
# To download final results run on local machine command prompt:
#   scp -r root@<server_ip>:/root/telemetry_<timestamp> .
# ============================================================

set -euo pipefail

# -------------------------
# Default Variables
# -------------------------
INTERVAL=2
SERVICE=""
DURATION=""

# -------------------------
# Argument Parsing
# -------------------------
usage() {
  echo "Usage: $0 -d <duration_in_seconds> [-i <interval_seconds>] [-s <service_name>]"
  exit 1
}

while getopts "d:i:s:" opt; do
  case ${opt} in
    d ) DURATION=$OPTARG ;;
    i ) INTERVAL=$OPTARG ;;
    s ) SERVICE=$OPTARG ;;
    * ) usage ;;
  esac
done

if [[ -z "$DURATION" ]] || ! [[ "$DURATION" =~ ^[0-9]+$ ]]; then
  echo "Error: Duration (-d) is required and must be a positive integer."
  usage
fi

if ! [[ "$INTERVAL" =~ ^[0-9]+$ ]]; then
  echo "Error: Interval (-i) must be a positive integer."
  usage
fi

# -------------------------
# Dependency Check
# -------------------------
if ! command -v mpstat &> /dev/null; then
  echo "Error: 'mpstat' could not be found. Please install sysstat (e.g., apt-get install sysstat)."
  exit 1
fi

# -------------------------
# Setup Output Directory
# -------------------------
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
OUTPUT_DIR="telemetry_$TIMESTAMP"
mkdir -p "$OUTPUT_DIR"

CSV_FILE="$OUTPUT_DIR/metrics.csv"
LOG_FILE="$OUTPUT_DIR/monitor.log"

echo "Starting telemetry collection..." | tee "$LOG_FILE"
echo "Duration: $DURATION seconds" | tee -a "$LOG_FILE"
echo "Interval: $INTERVAL seconds" | tee -a "$LOG_FILE"
[[ -n "$SERVICE" ]] && echo "Tracking Service: $SERVICE" | tee -a "$LOG_FILE"
echo "Output directory: $OUTPUT_DIR" | tee -a "$LOG_FILE"

# Prepare CSV Header
HEADER="timestamp,cpu_percent,load_avg_1m,mem_used_mb,mem_total_mb,uptime_seconds"
[[ -n "$SERVICE" ]] && HEADER="${HEADER},${SERVICE}_active"
echo "$HEADER" > "$CSV_FILE"

# -------------------------
# Graceful Shutdown Handler
# -------------------------
STOP_REQUESTED=false
cleanup() {
  echo -e "\nInterrupt received. Stopping telemetry collection at $(date)" | tee -a "$LOG_FILE"
  STOP_REQUESTED=true
}
trap cleanup SIGINT SIGTERM

# -------------------------
# Monitoring Loop
# -------------------------
END_TIME=$((SECONDS + DURATION))

while [[ $SECONDS -lt $END_TIME ]]; do
  if [[ "$STOP_REQUESTED" = true ]]; then
    break
  fi

  CURRENT_TIME=$(date +"%Y-%m-%d %H:%M:%S")

  # CPU Usage (Locale safe subtraction)
  CPU_IDLE=$(LC_NUMERIC=C mpstat 1 1 | awk '/Average/ {print $NF}')
  CPU_USAGE=$(awk "BEGIN {print 100 - $CPU_IDLE}")

  # Load Average (1 minute)
  LOAD_AVG=$(awk '{print $1}' /proc/loadavg)

  # Memory Usage
  MEM_USED=$(free -m | awk '/Mem:/ {print $3}')
  MEM_TOTAL=$(free -m | awk '/Mem:/ {print $2}')

  # Uptime in seconds
  UPTIME_SECONDS=$(cut -d ' ' -f1 /proc/uptime)

  # Construct CSV Row
  ROW="$CURRENT_TIME,$CPU_USAGE,$LOAD_AVG,$MEM_USED,$MEM_TOTAL,$UPTIME_SECONDS"

  # Optional Service Status
  if [[ -n "$SERVICE" ]]; then
    if systemctl is-active --quiet "$SERVICE"; then
      ROW="${ROW},1"
    else
      ROW="${ROW},0"
      echo "$SERVICE inactive at $CURRENT_TIME" >> "$LOG_FILE"
    fi
  fi

  # Write to CSV
  echo "$ROW" >> "$CSV_FILE"

  sleep "$INTERVAL"
done

echo "Telemetry collection completed successfully at $(date)" | tee -a "$LOG_FILE"
echo -e "\nResults saved to:\n  $CSV_FILE\n  $LOG_FILE"