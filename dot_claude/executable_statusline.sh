#!/bin/bash
# Claude Code status line: 5-hour allowance left (with bar), weekly usage, context used.
# Separators follow the tmux bar's theme (claude-bar picks chips, powerline or edge).
input=$(cat)

five_used=$(jq -r '.rate_limits.five_hour.used_percentage // empty' <<<"$input")
five_reset=$(jq -r '.rate_limits.five_hour.resets_at // empty' <<<"$input")
week_used=$(jq -r '.rate_limits.seven_day.used_percentage // empty' <<<"$input")
ctx_used=$(jq -r '.context_window.used_percentage // empty' <<<"$input")
model=$(jq -r '.model.display_name // empty' <<<"$input")
theme=$(cat ~/.claude/bar-theme 2>/dev/null || echo chips)

fg() { printf '\033[38;2;%d;%d;%dm' "0x${1:1:2}" "0x${1:3:2}" "0x${1:5:2}"; }
bg() { printf '\033[48;2;%d;%d;%dm' "0x${1:1:2}" "0x${1:3:2}" "0x${1:5:2}"; }
reset=$'\033[0m' bold=$'\033[1m' nobold=$'\033[22m'
THIN=$'\xee\x82\xb1'  # Nerd Font thin powerline arrow
TXT='#cdd6f4' MUTED='#7f849c' FAINT='#585b70'

bar() { # $1 = percent filled, $2 = width, $3 = filled char, $4 = empty char
  local pct=${1%.*} width=$2 filled s="" i
  filled=$(( (pct * width + 50) / 100 ))
  (( filled > width )) && filled=$width
  (( filled < 0 )) && filled=0
  for ((i = 0; i < width; i++)); do (( i < filled )) && s+="$3" || s+="$(fg $FAINT)$4"; done
  printf '%s' "$s"
}

# Green when plenty is left, yellow, red when low.
level() { local left=${1%.*}; if (( left > 50 )); then echo green; elif (( left > 20 )); then echo yellow; else echo red; fi; }
hue() { case $1 in green) echo '#a6e3a1' ;; yellow) echo '#f9e2af' ;; red) echo '#f38ba8' ;; esac; }

reset_in=''
if [[ -n $five_reset ]]; then
  mins=$(( (${five_reset%.*} - $(date +%s)) / 60 ))
  (( mins > 0 )) && reset_in="$((mins/60))h$((mins%60))m"
fi
[[ -n $five_used ]] && left=$(( 100 - ${five_used%.*} ))
[[ -n $week_used ]] && week=${week_used%.*} && wlev=$(level $(( 100 - week )))
[[ -n $ctx_used ]] && ctx=${ctx_used%.*} && clev=$(level $(( 100 - ctx )))

# Text only: Claude Code converts status line colors to the 256-color palette, which
# turns dark backgrounds teal, so the state lives in the text color, like the tmux bar.
if [[ $theme == edge ]]; then
  sep="    " fill=━ empty=━ wk=week
elif [[ $theme == powerline ]]; then
  sep="   $(fg $FAINT)$THIN$reset   " fill=━ empty=━ wk=wk
else
  sep="   $(fg $FAINT)·$reset   " fill=━ empty=━ wk=week
fi
out=()
[[ -n $model ]] && out+=("$(fg $MUTED)$model$reset")
if [[ -n $five_used ]]; then
  h=$(hue $(level $left))
  # ━ is drawn natively by the terminal, so it stays one cell wide (▰▱ and ↻ don't).
  seg="$(fg $MUTED)5h  $(fg "$h")$(bar $left 10 $fill $empty)  $(fg "$h")$bold$left%$nobold"
  [[ -n $reset_in ]] && seg+="  $(fg $MUTED)resets $reset_in"
  out+=("$seg$reset")
else
  out+=("$(fg $MUTED)5h n/a$reset")
fi
if [[ -n $week ]]; then out+=("$(fg $MUTED)$wk $(fg "$(hue $wlev)")$week%$reset"); else out+=("$(fg $MUTED)$wk n/a$reset"); fi
# Any other limit Claude Code reports (e.g. a per-model weekly cap) shows up by name.
while read -r key used; do
  [[ -n $used ]] || continue
  name=${key#seven_day_}; name=${name//_/ }
  out+=("$(fg $MUTED)$name $(fg "$(hue $(level $(( 100 - ${used%.*} ))))")${used%.*}%$reset")
done < <(jq -r '.rate_limits // {} | to_entries[] | select(.key != "five_hour" and .key != "seven_day") | "\(.key) \(.value.used_percentage // "")"' <<<"$input")
[[ -n $ctx ]] && out+=("$(fg $MUTED)ctx $(fg "$(hue $clev)")$ctx%$reset")
line=''
for p in "${out[@]}"; do
  # Edge marks: each value gets a thin bar in front, colored like the value.
  if [[ $theme == edge ]]; then
    c=$(printf '%s' "$p" | grep -oE $'\033\\[38;2;[0-9;]+m' | grep -vE '127;132;156|88;91;112' | tail -1)
    [[ -n $c ]] || c=$(fg $FAINT)  # gray labels like the model name get a faint mark
    p="${c}▎${reset}${p}"
  fi
  line+="${line:+$sep}$p"
done
printf '%s' "$line"
