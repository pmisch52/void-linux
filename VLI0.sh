
#*********************************************************************************************
# VOID LINUX chroot installer from commandline
# Taken from: 
# https://medium.com/applied-engineering-reporting-from-the-front/void-linux-chroot-install-exploring-the-void-2e10521486e8
#*********************************************************************************************

loadkeys de

lsblk
blkid

read -p"Laufwerk fuer CHROOT waehlen: sda - sdb : " sdX
umount /dev/${sdX}1 >> /dev/null

# Neuen Bootsektor schreiben: 
dd count=1 BS=512 if=/dev/zero of=/dev/${sdX}

# Partition erstellen:
cfdisk /dev/${sdX}

# Dateisystem OHNE JOURNALLING erzeugen:
mkfs.ext4 -O ^has_journal /dev/${sdX}1 

# Prepare a partition and mount it to /mnt/

mount /dev/${sdX}1 /mnt

#####################################################################
#
# Install VOID LINUX Basesystem to /mnt :

# Online-install :
# xbps-install -S -R https://repo.voidlinux.eu/current -r /mnt/ --verbose base-system
# oder lokale Kopie:

cp -axvnu / /mnt

mount -o bind /dev /mnt/dev
mount -o bind /dev/shm /mnt/dev/shm
#mount -o bind /dev/pts /mnt/dev/pts
mount -t devpts pts /mnt/dev/pts
# mount -o bind /proc /mnt/proc
mount -t proc /proc /mnt/proc
mount -t sysfs /sys /mnt/sys
mount -o bind /run /mnt/run
# mount -o bind /etc/resolv.conf /mnt/etc/resolv.conf
cp -L /etc/resolv.conf /mnt/etc/
cp /proc/mounts /mnt/etc/mtab

################################################

# xbps-install curl 

curl http://skripta.de/VLI0.sh > VLI0.sh
curl http://skripta.de/VLI1.sh > VLI1.sh
curl http://skripta.de/VLI2.sh > VLI2.sh

chmod 1777 VLI*.sh

cp VLI*.sh /mnt

echo "Nach Beendigung dieses Skripts > chroot /mnt /bin/bash < eingeben"
echo "und danach ./VLI1.sh ausführen"

