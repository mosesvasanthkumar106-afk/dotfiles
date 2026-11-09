#!/bin/bash
case $1 in
  up) brightnessctl set 5%+ ;;
  down) brightnessctl -n set 5%- ;;
esac
pkill -USR2 -f "python.*volosd.py"

