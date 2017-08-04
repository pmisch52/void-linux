
#*********************************************************************************************
# VOID LINUX chroot installer from commandline
# Taken from: 
# https://medium.com/applied-engineering-reporting-from-the-front/void-linux-chroot-install-exploring-the-void-2e10521486e8
#*********************************************************************************************

########################################################
# Update System - nach CHROOT !

xbps-alternatives -g sh -s dash 
#xbps-install -Syu
xbps-reconfigure -f linux* glibc-locales

echo hostonly=yes > /etc/dracut.conf.d/hostonly.conf

chsh root -s /bin/bash

#######################################################
# Install grub auf sda

#xbps-install -y grub os-prober
grub-mkconfig -o /boot/grub/grub.cfg
grub-install --target=i386-pc  /dev/sda --force
echo "Nach Neustart => VLI2.sh ausführen..."

exit

reboot
