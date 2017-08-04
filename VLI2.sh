##############################################
# VLI2.sh
##############################################

localize() {
	
	# Localization:
	
	ln -sf /usr/share/zoneinfo/Europe/Berlin /etc/localtime
	hwclock --systohc
	echo "de_DE.UTF-8 UTF-8" >> /etc/locale.gen 
	
	echo "voidlinux"  > /etc/hostname 
	echo "export LC_ALL=de_DE.UTF-8 " >> /home/voiduser/.bashrc
	echo "export LANG=de_DE.UTF-8 " >> /home/voiduser/.bashrc
	echo "export LANGUAGE=de_DE.UTF-8 " >> /home/voiduser/.bashrc
	
	echo "de_DE.UTF-8 utf-8" >> /etc/default/libc-locales
	echo 'LANG="de_DE.UTF-8"' > /etc/locale.conf
	echo 'TIMEZONE="Europe/Madrid"' >> /etc/rc.conf
	echo 'KEYMAP="de-latin1"' >> /etc/rc.conf
	echo 'FONT="lat9w-16"' >> /etc/rc.conf
	echo 'FONT_MAP="8859-1_to_uni"' >> /etc/rc.conf
	echo "==> Check /etc/rc.conf ..."
	
	#################################################
	# Neuen User anlegen:
	
	read "Neuen User anlegen (name): " username
	
	useradd -m -G users,wheel -s /bin/bash ${username}
	
	echo "===================================="
	echo " " 
	echo -e "\e[91mPASSWORT für ${username}: "
	passwd ${username}
	echo -e "\e[0m"
	echo -e "${username}  ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers 
	echo "===================================="
	
	echo -e "\e[91mPassword for ROOT:"
	passwd root
	echo -e "\e[0m"
	
	#################################################
	# Allow mounting devices (polkit)
	
	echo -e "
	/* Allow members of the wheel group to execute any actions
     * without password authentication, similar to sudo NOPASSWD: 
     */
     polkit.addRule(function(action, subject) {
        if (subject.isInGroup(\"wheel\")) {
           return polkit.Result.YES;
     }
    });" > /etc/polkit-1/rules.d/49-nopasswd.rules
	
	
	#################################################
	# .bashrc (AUTOLOGIN)

	# [[ $- != *i* ]] && return
	# alias ls='ls --color=auto'
	# export PS1="\u \w > "
	# root:
	# export PS1="\[\e[0;31m\]\u \w >\[\e[0m\]"
	
	# autologin on tty1:
	# echo "
	# if [ -z "$DISPLAY" ] && [ "$(fgconsole)" -eq 1 ]; then
	#   startx
	# fi" >> /home/${username}/.bashrc
} 

read -p"==> Lokalisierung/Passwords/bashrc? j/n" response

if [ "$response" == "j" ]; then 
	localize
fi

################################################
# GUI - XFCE

gui() {
	
	xbps-install -Sy xorg-minimal xorg-fonts xf86-input-synaptics xf86-video-intel
	xbps-install -Sy xfce4
	xbps-install -Sy NetworkManager network-manager-applet
	xbps-install -Sy gnome-icon-theme inetutils-ifconfig gnome-keyring seahorse

	rm -fr /var/service/dhcpcd
	rm -fr /var/service/wpa_supplicant
	ln -s /etc/sv/NetworkManager /var/service
	ln -s /etc/sv/dbus /var/service
		
	cp /etc/X11/xinit/xinitrc /home/${username}/.xinitrc
	#echo "setxkbmap de" >> /home/${username}/.xinitrc
	# Automount:
	echo 'exec ck-launch-session dbus-launch startxfce4' >> /home/${username}/.xinitrc 
	
	#########################################
	# XFCE-Icons durchsichtig
	
	echo -e '
	style "xfdesktop-icon-view" {
	XfdesktopIconView::label-alpha = 0
	XfdesktopIconView::selected-label-alpha = 170
	
	base[NORMAL] = "#cccccc"
	base[SELECTED] = "#cccccc"
	base[ACTIVE] = "#cccccc"
	
	fg[NORMAL] = "#ffffff"
	fg[SELECTED] = "#000000"
	fg[ACTIVE] = "#000000"
	}
	widget_class "*XfdesktopIconView*" style "xfdesktop-icon-view"'	> .gtkrc-2.0
	
	# in Userverzeihnis kopieren? 

	################################################
	# Sound 
	
	xbps-install -Sy alsa alsa-utils 
	#xbps-install pulseaudio pavucontrol ConsoleKit2 
	
	ln -s /etc/sv/alsa /var/service/
	#ln -s /etc/sv/dbus /var/service/
	ln -s /etc/sv/cgmanager /var/service/
	ln -s /etc/sv/consolekit /var/service/
	#ln -s /etc/sv/pulseaudio /var/service/
	
	#usermod -a -G pulse-access voiduser
	
	# Change sequence of soundcards:
	# touch /etc/asound.conf
	#
	# pcm.!default {
	#     type hw
	#     card PCH
	# }
	# ctl.!default {
	#     type hw
	#     card PCH
	# }
	# oder: 
	# /etc/modprobe.d/alsa-base.conf 
	# options snd_hda_intel enable=1 index=0
	# options snd_hda_intel enable=0 index=1
}

read -p"==> XFCE/Xorg installieren? (j/n) " response
if [ "$response" == "j" ]; then
	gui
fi

####################################################
# Standard-Programme:

standard() {
		
	xbps-install -Sy firefox trojita geany gvfs-smb unzip 
	# xbps-install xorriso brasero simple-scan rpmextract
	# xbps-install base-devel openjdk 
	
	# Aufräumen:
	n=`xbps-install -Snu | wc -l`
	echo "--- There are $n updates waiting ---"
	xbps-remove -Oo
	xbps-install -Suy
	
	################################################
	# Add Local Repositories:
	# => https://wiki.voidlinux.eu/XBPS
	# Local system repositories can be made available at 
	# /usr/share/xbps.d/xbps.conf 
	# Contents pointing to a local Repository (eg. /xbps)
	# repository=/xbps
	
	###############################################
	# Weitere nützliche Pakete: 
	#
	# SDL
	# SDL-devel
	# alsa-tools
	# alsa-utils
	# base-devel
	# base-system
	# bash-completion
	# bleachbit
	# curl
	# dialog
	# dpkg
	# evince
	# firefox
	# geany
	# gnome-keyring
	# gparted
	# grub
	# gvfs-smb
	# htop
	# libopenjpeg
	# libressl
	# linux-firmware
	# mc
	# mpg123
	# mplayer
	# network-manager-applet
	# openjdk
	# pavucontrol
	# pulseaudio
	# qemu-user-static
	# rpmextract
	# samba
	# seahorse
	# sox
	# tnftp
	# trojita
	# unzip
	# xarchiver
	# xdg-utils
	# xf86-input-synaptics
	# xf86-video-intel
	# xfce4
	# xorg-fonts
	# xorg-minimal
	# xorriso
	# xterm
}
read -p"=> Standard-Programme installieren? j/n " response
if [ "$response" == "j" ]; then 
	standard
fi
echo "FERTIG!- Neustart"

