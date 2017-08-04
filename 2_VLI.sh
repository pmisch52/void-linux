#!/bin/bash
echo "Bitte zuerst 'sudo ./WLAN.sh' aufrufen."
echo "Skripte werden heruntergeladen..." 
curl http://skripta.de/VLI0.sh > VLI0.sh
curl http://skripta.de/VLI1.sh > VLI1.sh
curl http://skripta.de/VLI2.sh > VLI2.sh
chmod 1777 VLI*.sh 
echo "Fertig"

