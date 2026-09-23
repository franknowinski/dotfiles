#!/bin/bash
# Claude Code status line: 5-hour allowance left (with bar), weekly usage, context used.
input=$(cat)

five_used=$(jq -r '.rate_limits.five_hour.used_percentage // empty' <<<"$input")
five_reset=$(jq -r '.rate_limits.five_hour.resets_at // empty' <<<"$input")
week_used=$(jq -r '.rate_limits.seven_day.used_percentage // empty' <<<"$input")
ctx_used=$(jq -r '.context_window.used_percentage // empty' <<<"$input")
model=$(jq -r '.model.display_name // empty' <<<"$input")

bar() { # $1 = percent filled, $2 = width
  local pct=${1%.*} width=${2:-10} filled
  filled=$(( (pct * width + 50) / 100 ))
  (( filled > width )) && filled=$width
  (( filled < 0 )) && filled=0
  local s="" i
  for ((i = 0; i < width; i++)); do (( i < filled )) && s+="█" || s+="░"; done
  printf '%s' "$s"
}

color() { # green when plenty left, yellow, red when low; $1 = percent left
  local left=${1%.*}
  if (( left > 50 )); then printf '\033[32m'; elif (( left > 20 )); then printf '\033[33m'; else printf '\033[31m'; fi
}
reset=$'\033[0m'; dim=$'\033[2m'

parts=()
[[ -n $model ]] && parts+=("${dim}${model}${reset}")

if [[ -n $five_used ]]; then
  left=$(( 100 - ${five_used%.*} ))
  seg="5h: $(color $left)$(bar $left 10) ${left}% left${reset}"
  if [[ -n $five_reset ]]; then
    mins=$(( (${five_reset%.*} - $(date +%s)) / 60 ))
    (( mins > 0 )) && seg+=" ${dim}(resets $((mins/60))h$((mins%60))m)${reset}"
  fi
  parts+=("$seg")
else
  parts+=("5h: ${dim}n/a${reset}")
fi

if [[ -n $week_used ]]; then
  wleft=$(( 100 - ${week_used%.*} ))
  parts+=("week: $(color $wleft)${week_used%.*}% used${reset}")
else
  parts+=("week: ${dim}n/a${reset}")
fi

if [[ -n $ctx_used ]]; then
  cleft=$(( 100 - ${ctx_used%.*} ))
  parts+=("ctx: $(color $cleft)${ctx_used%.*}% used${reset}")
fi

out=""
for p in "${parts[@]}"; do out+="${out:+ │ }$p"; done
printf '%s' "$out"
