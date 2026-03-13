#!/bin/bash
input=$(cat)

if [ -z "$input" ]; then
  printf "Claude"
  exit 0
fi

# ── Colors ──
green='\033[38;2;0;175;80m'
orange='\033[38;2;255;176;85m'
yellow='\033[38;2;230;200;0m'
red='\033[38;2;255;85;85m'
cyan='\033[38;2;86;182;194m'
dim='\033[2m'
reset='\033[0m'

sep=" ${dim}|${reset} "

# ── Helpers ──
format_tokens() {
  local num=$1
  if [ "$num" -ge 1000000 ]; then
    awk "BEGIN {printf \"%.1fm\", $num / 1000000}"
  elif [ "$num" -ge 1000 ]; then
    awk "BEGIN {printf \"%.0fk\", $num / 1000}"
  else
    printf "%d" "$num"
  fi
}

color_for_pct() {
  local pct=$1
  if [ "$pct" -ge 90 ]; then printf "$red"
  elif [ "$pct" -ge 70 ]; then printf "$yellow"
  elif [ "$pct" -ge 50 ]; then printf "$orange"
  else printf "$green"
  fi
}

# ── Extract data ──
model=$(echo "$input" | jq -r '.model.display_name // "Claude"')
input_tokens=$(echo "$input" | jq -r '.context_window.total_input_tokens // 0')
output_tokens=$(echo "$input" | jq -r '.context_window.total_output_tokens // 0')
used=$(echo "$input" | jq -r '.context_window.used_percentage // 0' | cut -d. -f1)
duration_ms=$(echo "$input" | jq -r '.cost.total_api_duration_ms // 0')
cwd=$(echo "$input" | jq -r '.cwd // ""')

latency=$(echo "scale=1; $duration_ms / 1000" | bc)

in_fmt=$(format_tokens "$input_tokens")
out_fmt=$(format_tokens "$output_tokens")
pct_color=$(color_for_pct "$used")

# ── Git ──
git_info=""
if [ -n "$cwd" ] && [ "$cwd" != "null" ] && git -C "$cwd" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  branch=$(git -C "$cwd" symbolic-ref --short HEAD 2>/dev/null)
  if [ -n "$branch" ]; then
    dirty=""
    if [ -n "$(git -C "$cwd" status --porcelain 2>/dev/null)" ]; then
      dirty="${red}*${reset}"
    fi
    git_info="${sep}${cyan}${branch}${dirty}${reset}"
  fi
fi

# ── Output ──
line1="${model}${git_info}"
line2="${in_fmt}/${out_fmt} tokens${sep}${pct_color}${used}%${reset} used${sep}${latency}s"

printf "%b\n%b" "$line1" "$line2"
