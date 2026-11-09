#!/bin/bash
cur=$(nmcli -t -f NAME,TYPE connection show --active | awk -F: '$2=="wifi"||$2=="802-11-wireless"{print $1; exit}')
list=$(nmcli -t -f NAME,TYPE connection show | awk -F: '$2=="wifi"||$2=="802-11-wireless"{print $1}')
choice=$(printf '%s\n%s\n' "$cur" "$list" | awk 'NF && !s[$0]++' | wofi --dmenu --prompt "Forget which Wi-Fi?")
[ -z "$choice" ] && exit
nmcli connection delete id "$choice" && notify-send "Wi-Fi" "Forgot $choice"
