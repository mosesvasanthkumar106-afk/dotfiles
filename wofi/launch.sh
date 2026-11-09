#!/bin/bash
f=~/.config/wofi/apps.txt
pick=$(while IFS='|' read -r n c i; do
command -v ${c%% *} >/dev/null || continue
i=${i// --/-}
p=$(find /usr/share/icons/Papirus/48x48/apps -name "$i.*" 2>/dev/null | head -1)
printf "img:%s:text:%s\n" "$p" "$n"
done < <(sort -f -t'|' -k1,1 $f) | wofi --dmenu -I -i -k /dev/null -p Apps)
[ -z "$pick" ] && exit
pick=${pick##*text:}
cmd=$(grep "^$pick|" $f | cut -d'|' -f2)
exec $cmd

