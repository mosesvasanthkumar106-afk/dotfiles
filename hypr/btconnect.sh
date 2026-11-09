#!/bin/bash
while true; do
  if ! bluetoothctl info 83:D4:89:AC:BF:99 | grep -q "Connected: yes"; then
    bluetoothctl connect 83:D4:89:AC:BF:99
  fi
  sleep 10
done
