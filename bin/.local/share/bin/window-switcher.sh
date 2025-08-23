#!/bin/bash

# This is the main function that runs inside the Alacritty window.
# By putting the logic in a function, we avoid all the complex escaping problems.
run_fzf_menu() {
  # ANSI escape codes for styling using the terminal's theme colors.
  local color_reset='\e[0m'
  local color_bold='\e[1m'
  local color_process='\e[34m' # Blue

  # Generate the sorted and styled list of windows.
  local window_list
  window_list=$(hyprctl clients -j |
    jq -r '[ .[] | select(.class != "fzf-switcher" and .workspace.id != -1) ] | sort_by([.workspace.name, .class, .title]) | .[] | "\(.address)\t\(.pid)\t\(.workspace.name)\t\(.title)"' |
    while IFS=$'\t' read -r address pid workspace_name title; do
      binary_name=$(ps -p "$pid" -o comm=)
      echo -e "$address    $color_bold[$workspace_name]$color_reset $color_process[$binary_name]$color_reset $title"
    done)

  # Find the 1-based line number of the active window in the list.
  local line_number
  line_number=$(echo "$window_list" | grep -nF "$ACTIVE_WINDOW_ADDRESS" | head -n 1 | cut -d: -f1)
  if [ -z "$line_number" ]; then
    line_number=1 # Default to the first line if not found.
  fi

  # Construct the action string for the `load` event to move the cursor.
  local actions
  if [[ "$line_number" -gt 1 ]]; then
    # Create a string of "down+" repeated n-1 times, and remove the trailing plus.
    local count=$((line_number - 1))
    local i
    actions="down" # Start with one 'down'
    for ((i = 1; i < count; i++)); do
      actions+="+down"
    done
  else
    # 'ignore' is a no-op action, safe to use when no movement is needed.
    actions="ignore"
  fi

  # Run fzf, with bindings for load and query change events.
  CHOSEN=$(echo "$window_list" |
    fzf --with-nth=2.. --reverse --cycle --ansi \
      --bind "load:$actions" \
      --bind "change:first")

  # If a window was chosen (i.e., the user didn't press ESC), focus it.
  if [ -n "$CHOSEN" ]; then
    ADDRESS=$(echo "$CHOSEN" | awk '{print $1}')
    hyprctl dispatch focuswindow "address:$ADDRESS"
  fi
}

# Export the function so it's available to the new shell that Alacritty creates.
export -f run_fzf_menu

# --- Launcher Logic ---
# This part of the script runs first when you press the keybinding.
LOCKFILE="/tmp/hypr-fzf-switcher.lock"

# Get the active window address *before* launching the switcher.
# This is crucial so that the switcher window itself doesn't become the active one.
# We export the variable so it's available in the shell created by `alacritty -e`.
export ACTIVE_WINDOW_ADDRESS=$(hyprctl activewindow -j | jq -r .address)

# Use flock to ensure only one instance of the switcher can run.
# If this command fails (because a switcher is already open), it runs the command after ||.
flock -n "$LOCKFILE" -c "alacritty --class 'fzf-switcher' -o font.size=13 -e bash -c run_fzf_menu" ||
  hyprctl dispatch movetoworkspace current,"class:^(fzf-switcher)$"
