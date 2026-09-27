#!/usr/bin/env bash
# -----------------------------------------------------------------
# @title        Task4_return_codes_error_handling.sh
# @author       Joel Nartey Annan
# @index        7352323
# @school       Kwame Nkrumah University of Science and Technology (KNUST)
# @description  Runs a sequence of system checks (host reachability, disk
#               space, file existence, command availability) with disciplined
#               exit-code handling and a cleanup trap for temp files.
# @date         <Date you wrote it>
#
# Exit codes:
#   0 = all checks passed
#   1 = missing required argument
#   2 = host unreachable
#   3 = insufficient disk space
#   4 = required file not found
#   5 = required command not found
# -----------------------------------------------------------------

set -u

usage() {
  echo "Usage: $0 <hostname>" >&2
  echo "  <hostname>  a host to ping-test for reachability (e.g. google.com)" >&2
  exit 1
}

if [[ $# -ne 1 || "$1" == "-h" || "$1" == "--help" ]]; then
  usage
fi

HOSTNAME_ARG="$1"
TEMP_FILE=$(mktemp /tmp/task4_XXXXXX)
CONFIG_FILE="./sample_config.conf"     # file-existence check target
REQUIRED_TOOL="grep"                   # command-availability check target
MIN_FREE_KB=1048576                    # 1GB minimum free space, in KB

# --- Cleanup trap: always remove the temp file, regardless of how we exit ---
cleanup() {
  if [[ -f "$TEMP_FILE" ]]; then
    rm -f "$TEMP_FILE"
    echo "Cleaned up temporary file '$TEMP_FILE'."
  fi
}
trap cleanup EXIT INT TERM

echo "Temporary file created at '$TEMP_FILE' for this run." > "$TEMP_FILE"

# --- Helper: interpret $? and exit with a documented code on failure --------
check_status() {
  local result="$1"        # the $? value being checked
  local success_msg="$2"
  local fail_msg="$3"
  local fail_code="$4"

  if [[ "$result" -eq 0 ]]; then
    echo "PASS: $success_msg"
  else
    echo "FAIL: $fail_msg" >&2
    exit "$fail_code"
  fi
}

# --- Check 1: host reachability ----------------------------------------------
ping -c 1 -W 2 "$HOSTNAME_ARG" > /dev/null 2>&1
check_status "$?" \
  "Host '$HOSTNAME_ARG' is reachable." \
  "Host '$HOSTNAME_ARG' is unreachable." \
  2

# --- Check 2: sufficient free disk space -------------------------------------
# Read available space (KB) on the filesystem holding the current directory.
FREE_KB=$(df -k . 2>/dev/null | awk 'NR==2 {print $4}')
if [[ -z "$FREE_KB" ]]; then
  echo "FAIL: could not determine free disk space." >&2
  exit 3
fi
if [[ "$FREE_KB" -ge "$MIN_FREE_KB" ]]; then
  check_status 0 "Sufficient disk space available (${FREE_KB}KB free)." "" 3
else
  check_status 1 "" "Insufficient disk space (${FREE_KB}KB free, need ${MIN_FREE_KB}KB)." 3
fi

# --- Check 3: required config/data file exists and is readable --------------
# For demo purposes we create the file if missing, so the check has something
# concrete to validate; in a real setup this would just check a real file.
if [[ ! -f "$CONFIG_FILE" ]]; then
  echo "sample setting=demo" > "$CONFIG_FILE" 2>/dev/null
fi
[[ -f "$CONFIG_FILE" && -r "$CONFIG_FILE" ]]
check_status "$?" \
  "Config file '$CONFIG_FILE' exists and is readable." \
  "Config file '$CONFIG_FILE' not found or not readable." \
  4

# --- Check 4: required command/tool is installed -----------------------------
command -v "$REQUIRED_TOOL" > /dev/null 2>&1
check_status "$?" \
  "Required command '$REQUIRED_TOOL' is installed." \
  "Required command '$REQUIRED_TOOL' is not installed." \
  5

echo "All checks passed."
exit 0
