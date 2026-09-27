#!/usr/bin/env bash
# -----------------------------------------------------------------
# @title        Task3_pipes_redirection.sh
# @author       Joel Nartey Annan
# @index       7352323
# @school       Kwame Nkrumah University of Science and Technology (KNUST)
# @description  Generates fake log data, then uses pipes and text tools
#               to summarize log levels, top IPs, and error lines.
# @date         <Date you wrote it>
# -----------------------------------------------------------------

set -u

usage() {
  echo "Usage: $0" >&2
  echo "  This script takes no arguments. It generates its own sample log data." >&2
  exit 1
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
fi

LOG_FILE="sample_access.log"
RESULTS_FILE="results.txt"
ERROR_LOG="errors.log"

# Clear old error log so we don't accumulate stale errors across runs
: > "$ERROR_LOG"

# --- Step 1: generate at least 50 lines of fake log data --------------------
cat > "$LOG_FILE" <<'EOF'
2026-09-11 10:00:01 INFO 192.168.1.10 User login successful
2026-09-11 10:00:15 INFO 192.168.1.11 User login successful
2026-09-11 10:00:32 WARN 192.168.1.10 Disk usage above 80%
2026-09-11 10:00:47 ERROR 192.168.1.23 Connection timeout
2026-09-11 10:01:02 INFO 192.168.1.12 User login successful
2026-09-11 10:01:18 ERROR 192.168.1.23 Connection timeout
2026-09-11 10:01:33 INFO 192.168.1.10 File uploaded
2026-09-11 10:01:49 WARN 192.168.1.14 High memory usage
2026-09-11 10:02:04 INFO 192.168.1.11 File uploaded
2026-09-11 10:02:20 ERROR 192.168.1.15 Database connection failed
2026-09-11 10:02:35 INFO 192.168.1.10 User logout
2026-09-11 10:02:51 INFO 192.168.1.16 User login successful
2026-09-11 10:03:06 WARN 192.168.1.10 Disk usage above 80%
2026-09-11 10:03:21 INFO 192.168.1.12 User logout
2026-09-11 10:03:45 ERROR 192.168.1.23 Connection timeout
2026-09-11 10:04:02 WARN 192.168.1.10 Disk usage above 80%
2026-09-11 10:04:17 INFO 192.168.1.17 User login successful
2026-09-11 10:04:33 INFO 192.168.1.11 File uploaded
2026-09-11 10:04:48 ERROR 192.168.1.18 Authentication failed
2026-09-11 10:05:03 INFO 192.168.1.10 User login successful
2026-09-11 10:05:19 WARN 192.168.1.19 CPU usage high
2026-09-11 10:05:34 INFO 192.168.1.16 User logout
2026-09-11 10:05:50 ERROR 192.168.1.23 Connection timeout
2026-09-11 10:06:05 INFO 192.168.1.12 File uploaded
2026-09-11 10:06:20 INFO 192.168.1.10 User login successful
2026-09-11 10:06:36 WARN 192.168.1.14 High memory usage
2026-09-11 10:06:51 ERROR 192.168.1.15 Database connection failed
2026-09-11 10:07:07 INFO 192.168.1.20 User login successful
2026-09-11 10:07:22 INFO 192.168.1.11 User logout
2026-09-11 10:07:38 WARN 192.168.1.10 Disk usage above 80%
2026-09-11 10:07:53 ERROR 192.168.1.23 Connection timeout
2026-09-11 10:08:08 INFO 192.168.1.17 File uploaded
2026-09-11 10:08:24 INFO 192.168.1.10 User login successful
2026-09-11 10:08:39 WARN 192.168.1.19 CPU usage high
2026-09-11 10:08:55 ERROR 192.168.1.18 Authentication failed
2026-09-11 10:09:10 INFO 192.168.1.12 User login successful
2026-09-11 10:09:25 INFO 192.168.1.16 File uploaded
2026-09-11 10:09:41 WARN 192.168.1.10 Disk usage above 80%
2026-09-11 10:09:56 ERROR 192.168.1.23 Connection timeout
2026-09-11 10:10:12 INFO 192.168.1.10 User login successful
2026-09-11 10:10:27 INFO 192.168.1.20 User logout
2026-09-11 10:10:43 WARN 192.168.1.14 High memory usage
2026-09-11 10:10:58 ERROR 192.168.1.15 Database connection failed
2026-09-11 10:11:13 INFO 192.168.1.11 User login successful
2026-09-11 10:11:29 INFO 192.168.1.10 File uploaded
2026-09-11 10:11:44 WARN 192.168.1.19 CPU usage high
2026-09-11 10:12:00 ERROR 192.168.1.23 Connection timeout
2026-09-11 10:12:15 INFO 192.168.1.12 User login successful
2026-09-11 10:12:31 INFO 192.168.1.17 User logout
2026-09-11 10:12:46 WARN 192.168.1.10 Disk usage above 80%
2026-09-11 10:13:02 ERROR 192.168.1.18 Authentication failed
2026-09-11 10:13:17 INFO 192.168.1.10 User login successful
EOF

if [[ $? -eq 0 && -f "$LOG_FILE" ]]; then
  echo "Sample log file '$LOG_FILE' generated successfully."
else
  echo "Error: failed to generate sample log file." >&2
  exit 1
fi

# --- Step 2: build the summary report ----------------------------------------
{
  echo "===== Log Summary Report ====="
  echo

  echo "-- Total number of log lines --"
  wc -l < "$LOG_FILE" 2>>"$ERROR_LOG"
  echo

  echo "-- Count of lines per log level --"
  # Column 3 (space-delimited) holds the log level; count occurrences of each.
  awk '{print $3}' "$LOG_FILE" 2>>"$ERROR_LOG" | sort | uniq -c | sort -rn
  echo

  echo "-- Top 3 most frequent IP addresses --"
  # Column 4 holds the IP address.
  awk '{print $4}' "$LOG_FILE" 2>>"$ERROR_LOG" | sort | uniq -c | sort -rn | head -n 3
  echo

  echo "-- All ERROR lines --"
  grep "ERROR" "$LOG_FILE" 2>>"$ERROR_LOG"
} > "$RESULTS_FILE"

if [[ $? -eq 0 ]]; then
  echo "Report written to '$RESULTS_FILE'."
else
  echo "Error: failed to write report to '$RESULTS_FILE'. Check '$ERROR_LOG' for details." >&2
  exit 1
fi

# Let the user know if any pipeline command logged an error along the way
if [[ -s "$ERROR_LOG" ]]; then
  echo "Warning: some commands reported errors. See '$ERROR_LOG' for details." >&2
fi

echo "Task 3 completed successfully."
exit 0
