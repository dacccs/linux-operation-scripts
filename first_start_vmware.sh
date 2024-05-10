#!/bin/bash
###########################################################
# VMware first start script                               #
# Created: dacccs                                         #
# Last modification: 2024.03.14                           #
###########################################################
VERSION=1.0002;

# VMware platform check
if (( $(dmidecode -t system | grep -i manufa| grep -i vmware -c) )); then 
	rm -rf /etc/NetworkManager/system-connections/*;
	rm -rf /etc/udev/rules.d/70-persistent-net.rules;
	# Rename interfaces based on VMware naming scheme
	nic=160;
	ifcount=$(ifconfig -a |grep -i "flags" | cut -d' ' -f1 | cut -d':' -f1 | grep -ivE "rac|lo" -c);
	j=0;
    for ((i=1; i<=ifcount; i++)); do 
		let divrem=i%4; 
		if (( $divrem )); then let nic=nic+32; else let nic=nic-95; fi; 
		hwaddr=$(ifconfig ens$nic | grep -i ether | cut -d'r' -f2 | cut -d' ' -f2);
		echo -e '[connection]\nid=eth'$j'\nuuid='$(uuidgen)'\ntype=ethernet\ninterface-name=eth'$j'\n\n[ethernet]\nmac-address='$hwaddr'\n\n[ipv4]\n#address1=IP/NM,GW\n#ignore-auto-dns=true\nmethod=manual\n\n[ipv6]\nmethod=disabled\n' > /etc/NetworkManager/system-connections/eth$j.nmconnection;
		echo -e 'SUBSYSTEM=="net", ACTION=="add", DRIVERS=="?*", ATTR{address}=="'$hwaddr'", ATTR{dev_id}=="0x0", ATTR{type}=="1", KERNEL=="*", NAME="eth'$j'"' >> /etc/udev/rules.d/70-persistent-net.rules
		let j++;
	done
fi;

# Set the permissions and reinitialize the devices and the service
chmod 600 /etc/NetworkManager/system-connections/*
udevadm control --reload-rules && udevadm trigger
systemctl restart NetworkManager
