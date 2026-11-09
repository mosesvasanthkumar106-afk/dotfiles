#!/bin/bash
list=$(bluetoothctl devices Paired | awk '{m=$2; $1=$2=""; print substr($0,3) " [" m "]"}')
choice=$(wofi --dmenu --prompt "Forget device" --width 420 --height 320 <<< "$list")
[ -z "$choice" ] && exit 0
mac=$(grep -o '[0-9A-F:]\{17\}' <<< "$choice" | head -1)
bluetoothctl disconnect "$mac" >/dev/null 2>&1
bluetoothctl remove "$mac"
