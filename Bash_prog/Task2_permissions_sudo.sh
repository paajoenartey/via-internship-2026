#!/usr/bin/env bash
# -----------------------------------------------------------------
# @title        Task2_permissions_sudo.sh
# @author       Joel Nartey Annan
# @index        7352323
# @school       Kwame Nkrumah University of Science and Technology (KNUST)
# @description  Reports and modifies file permissions, demonstrates numeric
#               and symbolic chmod, and attempts chown only when running
#               with root privileges.
# @date         <Date you wrote it>
# -----------------------------------------------------------------

set -u

usage() {
  echo "Usage: $0 <file-path>" >&2
  echo "  <file-path>  path to an existing file to inspect/modify" >&2
  exit 1
}

# --- Argument validation ---------------------------------------------------
if [[ $# -ne 1 || "$1" == "-h" || "$1" == "--help" ]]; then
  usage
fi

FILE_PATH="$1"

if [[ -z "$FILE_PATH" ]]; then
  echo "Error: file path argument is empty." >&2
  exit 1
fi

if [[ ! -e "$FILE_PATH" ]]; then
  echo "Error: '$FILE_PATH' does not exist." >&2
  exit 1
fi

if [[ ! -f "$FILE_PATH" ]]; then
  echo "Error: '$FILE_PATH' is not a regular file." >&2
  exit 1
fi

# --- Helper: report permissions in symbolic + numeric form -----------------
report_permissions() {
  local label="$1"
  # stat's flags differ between Linux (GNU) and macOS (BSD); try Linux first,
  # fall back to macOS/BSD syntax if that fails.
  local symbolic
  local numeric
  symbolic=$(stat -c '%A' "$FILE_PATH" 2>/dev/null) || symbolic=$(stat -f '%Sp' "$FILE_PATH" 2>/dev/null)
  numeric=$(stat -c '%a' "$FILE_PATH" 2>/dev/null) || numeric=$(stat -f '%Lp' "$FILE_PATH" 2>/dev/null)

  if [[ -z "$symbolic" || -z "$numeric" ]]; then
    echo "Error: could not read permissions for '$FILE_PATH'." >&2
    exit 1
  fi

  echo "$label:"
  echo "  Symbolic: $symbolic"
  echo "  Numeric:  $numeric"
}

# --- Step 1: report current permissions -------------------------------------
report_permissions "Permissions BEFORE changes"

# --- Step 2a: demonstrate numeric chmod --------------------------------------
chmod 644 "$FILE_PATH"
if [[ $? -eq 0 ]]; then
  echo "Numeric chmod (644) applied successfully."
else
  echo "Error: numeric chmod failed on '$FILE_PATH'." >&2
  exit 1
fi

# --- Step 2b: demonstrate symbolic chmod -------------------------------------
chmod u+x "$FILE_PATH"
if [[ $? -eq 0 ]]; then
  echo "Symbolic chmod (u+x) applied successfully."
else
  echo "Error: symbolic chmod failed on '$FILE_PATH'." >&2
  exit 1
fi

# --- Step 3: chown only if running as root -----------------------------------
CURRENT_UID=$(id -u)
if [[ "$CURRENT_UID" -eq 0 ]]; then
  # Running as root: safe to attempt a chown. We chown to root:root as a demo.
  chown root:root "$FILE_PATH"
  if [[ $? -eq 0 ]]; then
    echo "chown to root:root succeeded (running with root privileges)."
  else
    echo "Error: chown failed even though running as root." >&2
    exit 1
  fi
else
  echo "Skipping chown: this step requires root privileges (run with sudo to enable it)."
fi

# --- Step 4: report permissions after changes --------------------------------
report_permissions "Permissions AFTER changes"

echo "Task 2 completed successfully."
exit 0
