#!/usr/bin/env bash
# -----------------------------------------------------------------
# @title        Task1_file_handling.sh
# @author       Joel Nartey Annan
# @index        7352323
# @school       Kwame Nkrumah University of Science and Technology (KNUST)
# @description  Demonstrates basic file handling: create dir/file, write,
#               append, read, copy to .bak, then safely delete original.
# @date         <Date you wrote it>
# -----------------------------------------------------------------

set -u # treat unset variables as errors (helps catch typos early)

usage() {
  echo "Usage: $0 <target-directory>" >&2
  echo "  <target-directory>  path to a directory to create/use for the demo" >&2
  exit 1
}

# --- Argument validation ---------------------------------------------------
if [[ $# -ne 1 || "$1" == "-h" || "$1" == "--help" ]]; then
  usage
fi

TARGET_DIR="$1"
FILE_NAME="$TARGET_DIR/demo_file.txt"
BACKUP_NAME="$FILE_NAME.bak"

if [[ -z "$TARGET_DIR" ]]; then
  echo "Error: target directory argument is empty." >&2
  exit 1
fi

# --- Step 1: create directory if missing -----------------------------------
if [[ -d "$TARGET_DIR" ]]; then
  echo "Directory '$TARGET_DIR' already exists. Reusing it."
else
  mkdir -p "$TARGET_DIR"
  if [[ $? -eq 0 ]]; then
    echo "Directory '$TARGET_DIR' created successfully."
  else
    echo "Error: failed to create directory '$TARGET_DIR' (check permissions)." >&2
    exit 1
  fi
fi

# --- Step 2: create file and write content ----------------------------------
echo "This is the first line of the demo file." > "$FILE_NAME"
if [[ $? -eq 0 ]]; then
  echo "File '$FILE_NAME' created and initial content written."
else
  echo "Error: could not write to '$FILE_NAME'." >&2
  exit 1
fi

# --- Step 3: append additional content --------------------------------------
echo "This is an appended second line." >> "$FILE_NAME"
if [[ $? -eq 0 ]]; then
  echo "Content appended successfully."
else
  echo "Error: failed to append to '$FILE_NAME'." >&2
  exit 1
fi

# --- Step 4: read and display file contents ---------------------------------
if [[ -r "$FILE_NAME" ]]; then
  echo "----- Contents of $FILE_NAME -----"
  cat "$FILE_NAME"
  echo "-----------------------------------"
else
  echo "Error: '$FILE_NAME' is not readable." >&2
  exit 1
fi

# --- Step 5: copy to .bak ----------------------------------------------------
cp "$FILE_NAME" "$BACKUP_NAME"
if [[ $? -eq 0 ]]; then
  echo "Backup created at '$BACKUP_NAME'."
else
  echo "Error: failed to create backup copy." >&2
  exit 1
fi

# --- Step 6: delete original only after confirming it exists ----------------
# We re-check existence explicitly rather than assuming the earlier steps
# guarantee it, in case something else (another process, race condition)
# removed it in between.
if [[ -f "$FILE_NAME" ]]; then
  echo "About to delete original file '$FILE_NAME' (backup already saved)."
  rm "$FILE_NAME"
  if [[ $? -eq 0 ]]; then
    echo "Original file deleted successfully."
  else
    echo "Error: failed to delete '$FILE_NAME'." >&2
    exit 1
  fi
else
  echo "Error: '$FILE_NAME' does not exist, nothing to delete." >&2
  exit 1
fi

echo "Task 1 completed successfully."
exit 0
