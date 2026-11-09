#!/bin/bash
cfg=$(mktemp)
cat > $cfg <<EOF
[general]
bars = 14
framerate = 30
[input]
method = pipewire
[output]
method = raw
raw_target = /dev/stdout
data_format = ascii
ascii_max_range = 7
bar_delimiter = 59
EOF
cava -p $cfg | sed -u 's/;//g;s/0/▁/g;s/1/▂/g;s/2/▃/g;s/3/▄/g;s/4/▅/g;s/5/▆/g;s/6/▇/g;s/7/█/g'
