#!/bin/bash
################################################
# /dev/shm configuration script                #
# Created: dacccs                              #
# Last modification: 2025.02.25                #
################################################
VERSION=1.0000; 
size=$(echo $1 | tr -dc [0-9]);
sizeg=$size'G';

if (( $(cat /etc/fstab | grep -i shm -c) )); then
	if (( $(cat /etc/fstab | grep -i shm | grep -i size -c) )); then
		sed -i -e "s/size=[0-9]\+/size=$size/g" /etc/fstab;
	else
		shm_line=$(echo $(cat /etc/fstab | grep -i shm | tr -s '\t' ' ' | tr -s '  ' ' ' | cut -d' ' -f1-4)",size=$sizeg 0 0");
		sed -i -e "s|.*/dev/shm.*|$(echo $shm_line | tr ' ' '\t')|g" /etc/fstab;
	fi
else
	if (( $(cat /etc/fstab | grep -i var -c) )); then
		sed -i -e "/var.*/atmpfs   \/dev\/shm    tmpfs   rw,noexec,nosuid,nodev,seclabel,noexec,size=$sizeg 0   0" /etc/fstab;
	else 
		echo "tmpfs   /dev/shm    tmpfs   rw,noexec,nosuid,nodev,seclabel,noexec,size=$sizeg 0   0" >> /etc/fstab;
	fi	
fi	

mount -o remount /dev/shm	
