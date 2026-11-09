#!/bin/bash
nmcli device wifi rescan 2>/dev/null
ssid=$(nmcli -t -f SSID device wifi list | awk 'NF && !seen[$0]++' | wofi --dmenu --prompt "Wi-Fi")
[ -z "$ssid" ] && exit
name=$(nmcli -t -f NAME,TYPE connection show | awk -F: '$2=="wifi"||$2=="802-11-wireless"{print $1}' | while read -r n; do
  [ "$(nmcli -g 802-11-wireless.ssid connection show "$n")" = "$ssid" ] && echo "$n" && break
done)
if [ -n "$name" ]; then
  nmcli connection up id "$name" || notify-send "Wi-Fi" "Could not connect to $ssid"
  exit
fi
nmcli device wifi connect "$ssid" && exit
pass=$(wofi --dmenu --password="●" --prompt "Password..." --style "$HOME/.config/wofi/password.css" --width 312 --height 72 </dev/null)
[ -z "$pass" ] && exit
nmcli connection delete "$ssid" 2>/dev/null
nmcli device wifi connect "$ssid" password "$pass" || notify-send "Wi-Fi" "Could not connect to $ssid"
