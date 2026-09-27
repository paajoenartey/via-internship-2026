#!/usr/bin/env bash
# -----------------------------------------------------------------
# @title        Task5_crud_app.sh
# @author       Joel Nartey Annan
# @index        7352323
# @school       Kwame Nkrumah University of Science and Technology (KNUST)
# @description  Menu-driven Todo List CRUD app storing data in a CSV file.
#               Fields: ID, task description, status, due date (optional).
# @date         <Date you wrote it>
#
# Exit codes:
#   0 = normal exit
#   1 = data file could not be created/accessed
# -----------------------------------------------------------------

set -u

DATA_FILE="todo_data.csv"
BACKUP_FILE="todo_data.csv.bak"

usage() {
  echo "Usage: $0"
  echo "  Runs an interactive menu-driven Todo List app."
  echo "  No arguments needed. Data is stored in '$DATA_FILE' next to this script."
  exit 0
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
fi

# --- Ensure the data file exists ---------------------------------------------
if [[ ! -f "$DATA_FILE" ]]; then
  touch "$DATA_FILE"
  if [[ $? -ne 0 ]]; then
    echo "Error: could not create data file '$DATA_FILE'." >&2
    exit 1
  fi
fi

# --- Helper: back up data file before any destructive change ----------------
backup_data() {
  cp "$DATA_FILE" "$BACKUP_FILE" 2>/dev/null
  if [[ $? -eq 0 ]]; then
    echo "(Backup saved to '$BACKUP_FILE' before this change.)"
  else
    echo "Warning: could not create backup before this change." >&2
  fi
}

# --- Helper: get next available ID -------------------------------------------
next_id() {
  if [[ ! -s "$DATA_FILE" ]]; then
    echo 1
    return
  fi
  awk -F',' 'BEGIN{max=0} {if ($1+0 > max) max=$1+0} END{print max+1}' "$DATA_FILE"
}

# --- CRUD: Add ----------------------------------------------------------------
add_task() {
  local description status due_date id

  read -rp "Enter task description: " description
  if [[ -z "$description" ]]; then
    echo "Error: description cannot be empty. Task not added." >&2
    return 1
  fi

  read -rp "Enter due date (optional, press Enter to skip): " due_date

  id=$(next_id)
  status="pending"

  # Store as CSV: id,description,status,due_date
  echo "$id,$description,$status,$due_date" >> "$DATA_FILE"
  if [[ $? -eq 0 ]]; then
    echo "Task added with ID $id."
  else
    echo "Error: failed to write new task to '$DATA_FILE'." >&2
    return 1
  fi
}

# --- CRUD: View/List ------------------------------------------------------------
list_tasks() {
  if [[ ! -s "$DATA_FILE" ]]; then
    echo "No tasks found."
    return 0
  fi
  printf "%-5s %-30s %-10s %-12s\n" "ID" "Description" "Status" "Due Date"
  echo "--------------------------------------------------------------"
  while IFS=',' read -r id description status due_date; do
    printf "%-5s %-30s %-10s %-12s\n" "$id" "$description" "$status" "$due_date"
  done < "$DATA_FILE"
}

# --- CRUD: Search ---------------------------------------------------------------
search_tasks() {
  local term results
  read -rp "Enter search term (matches description): " term
  if [[ -z "$term" ]]; then
    echo "Error: search term cannot be empty." >&2
    return 1
  fi
  results=$(grep -i "$term" "$DATA_FILE")
  if [[ -z "$results" ]]; then
    echo "No matching tasks found for '$term'."
  else
    printf "%-5s %-30s %-10s %-12s\n" "ID" "Description" "Status" "Due Date"
    echo "--------------------------------------------------------------"
    echo "$results" | while IFS=',' read -r id description status due_date; do
      printf "%-5s %-30s %-10s %-12s\n" "$id" "$description" "$status" "$due_date"
    done
  fi
}

# --- CRUD: Update ---------------------------------------------------------------
update_task() {
  local target_id new_status new_description found=0

  read -rp "Enter ID of task to update: " target_id
  if [[ -z "$target_id" ]]; then
    echo "Error: ID cannot be empty." >&2
    return 1
  fi

  if ! grep -q "^$target_id," "$DATA_FILE"; then
    echo "Task with ID $target_id not found."
    return 0
  fi

  backup_data

  read -rp "Enter new description (press Enter to keep current): " new_description
  read -rp "Enter new status (pending/done, press Enter to keep current): " new_status

  local tmp_file
  tmp_file=$(mktemp)

  while IFS=',' read -r id description status due_date; do
    if [[ "$id" == "$target_id" ]]; then
      found=1
      [[ -n "$new_description" ]] && description="$new_description"
      [[ -n "$new_status" ]] && status="$new_status"
    fi
    echo "$id,$description,$status,$due_date" >> "$tmp_file"
  done < "$DATA_FILE"

  if [[ "$found" -eq 1 ]]; then
    mv "$tmp_file" "$DATA_FILE"
    if [[ $? -eq 0 ]]; then
      echo "Task $target_id updated successfully."
    else
      echo "Error: failed to save updated data." >&2
      rm -f "$tmp_file"
      return 1
    fi
  else
    rm -f "$tmp_file"
    echo "Task with ID $target_id not found."
  fi
}

# --- CRUD: Delete -----------------------------------------------------------------
delete_task() {
  local target_id confirm found=0

  read -rp "Enter ID of task to delete: " target_id
  if [[ -z "$target_id" ]]; then
    echo "Error: ID cannot be empty." >&2
    return 1
  fi

  if ! grep -q "^$target_id," "$DATA_FILE"; then
    echo "Task with ID $target_id not found."
    return 0
  fi

  read -rp "Are you sure you want to delete task $target_id? (y/n): " confirm
  if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
    echo "Delete cancelled."
    return 0
  fi

  backup_data

  local tmp_file
  tmp_file=$(mktemp)

  while IFS=',' read -r id description status due_date; do
    if [[ "$id" == "$target_id" ]]; then
      found=1
      continue
    fi
    echo "$id,$description,$status,$due_date" >> "$tmp_file"
  done < "$DATA_FILE"

  if [[ "$found" -eq 1 ]]; then
    mv "$tmp_file" "$DATA_FILE"
    if [[ $? -eq 0 ]]; then
      echo "Task $target_id deleted successfully."
    else
      echo "Error: failed to save data after deletion." >&2
      rm -f "$tmp_file"
      return 1
    fi
  else
    rm -f "$tmp_file"
    echo "Task with ID $target_id not found."
  fi
}

# --- Main menu loop -----------------------------------------------------------------
show_menu() {
  echo
  echo "===== Todo List Menu ====="
  echo "1) Add task"
  echo "2) View/List tasks"
  echo "3) Search tasks"
  echo "4) Update task"
  echo "5) Delete task"
  echo "6) Help"
  echo "7) Exit"
  echo "==========================="
}

while true; do
  show_menu
  read -rp "Choose an option [1-7]: " choice
  case "$choice" in
    1) add_task ;;
    2) list_tasks ;;
    3) search_tasks ;;
    4) update_task ;;
    5) delete_task ;;
    6) usage ;;
    7)
      echo "Goodbye."
      exit 0
      ;;
    *)
      echo "Invalid option. Please choose a number from 1 to 7." >&2
      ;;
  esac
done
