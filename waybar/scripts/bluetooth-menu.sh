#!/bin/bash
mac_of() { grep -o '[0-9A-F:]\{17\}' <<< "$1" | head -1; }

if ! bluetoothctl show | grep -q "Powered: yes"; then
  c=$(printf "Turn Bluetooth On\n" | wofi --dmenu --prompt "Bluetooth (off)" --width 420 --height 120)
  [ "$c" = "Turn Bluetooth On" ] && bluetoothctl power on >/dev/null
  exit 0
fi

paired=$(bluetoothctl devices Paired)
list=$(while read -r _ mac name; do
  [ -z "$mac" ] && continue
  if bluetoothctl info "$mac" | grep -q "Connected: yes"; then
    echo "Connected: $name [$mac]"
  else
    echo "$name [$mac]"
  fi
done <<< "$paired")

choice=$(printf "Turn Bluetooth Off\n%s\nScan for new devices\nForget a device\n" "$list" | sed '/^$/d' | wofi --dmenu --prompt "Bluetooth" --width 420 --height 340)
[ -z "$choice" ] && exit 0

case "$choice" in
  "Turn Bluetooth Off")
    bluetoothctl power off >/dev/null
    ;;
  "Scan for new devices")
    bluetoothctl --timeout 8 scan on >/dev/null
    all=$(bluetoothctl devices)
    new=$(comm -23 <(sort <<< "$all") <(sort <<< "$paired"))
    pick=$(sed '/^$/d' <<< "$new" | cut -d' ' -f2- | awk '{m=$1; $1=""; print substr($0,2) " [" m "]"}' | wofi --dmenu --prompt "Pair new device" --width 420 --height 320)
    [ -z "$pick" ] && exit 0
    mac=$(mac_of "$pick")
    bluetoothctl pair "$mac" && bluetoothctl trust "$mac" && bluetoothctl connect "$mac"
    ;;
  "Forget a device")
    ~/.config/waybar/scripts/bluetooth-forget.sh
    ;;
  *)
    mac=$(mac_of "$choice")
    if [[ "$choice" == Connected:* ]]; then
      bluetoothctl disconnect "$mac"
    else
      bluetoothctl connect "$mac"
    fi
    ;;
esac
