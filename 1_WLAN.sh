#!/bin/bash
if [ "$(id -u)" != "0" ]; then
   echo "Muss als ROOT ausgeführt werden" 1>&2
   exit 1
fi
echo "RFKILL ..."
rfkill list
read -p"Welches Geraet entblocken? (0,1,2,3...) > " device
rfkill unblock $device
ip link set dev wlp2s0 up 
sync
#iw dev wlp2s0 scan
iw dev wlp2s0 connect "JC" key 0:1111111111
dhcpcd wlp2s0 
sync
echo "...etwas warten ..."
sleep 1
iw dev wlp2s0 link


