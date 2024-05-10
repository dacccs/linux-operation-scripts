#!/bin/bash
################################################
# HBA Information                              #
# Created: dacccs                              #
# Last modification: 2021.02.07                #
################################################
VERSION=2.0046
LINE="-------------------------------------------------------------------------------"
echo -e '--HBA--------------------------------------------------------------------------';
port_numbers=$(lspci | grep -i fibre | cut -d' ' -f1 | cut -d'.' -f1);
echo -n "Number of Fiber cards: "; lspci | egrep -i "qlogic|emulex|hba" | cut -d'.' -f1 | uniq | wc -l;
echo -e $LINE;
for hba in `lspci | egrep -i "qlogic|emulex|hba" | cut -d' ' -f1 | cut -d'.' -f1 | uniq`; do
	lspci -s $hba | cut -d' ' -f2- | cut -d':' -f2- | sed -e 's/^[[:space:]]*//' | uniq
	echo -n "Number of ports: "; ls -1 /sys/bus/pci/devices/ | grep -i "0000:$hba" | wc -l;
	echo -e '';
done	

#dev_count=$(systool -c scsi_host | grep -i "Class Device" | wc -l);
#for (( i=0; i<=$dev_count; i++  )); do
for hba in `lspci | egrep -i "qlogic|emulex|hba" | cut -d' ' -f1`; do
	for host in `ls -1 /sys/bus/pci/devices/0000\:$hba/ | grep -i host`; do 
		#if (( $(cat /sys/class/scsi_host/$host/model*desc 2>/dev/null | egrep -i "fibre|FC|HBA" | wc -l)  )); then
		echo -e $LINE;
		echo -en '\tPhysical Device \t=\t'; lspci -s $hba | cut -d' ' -f2- | cut -d':' -f2- | sed -e 's/^[[:space:]]*//';
		if [[ -f /sys/class/scsi_host/$host/portnum ]]; then if (( $(cat /sys/class/scsi_host/$host/portnum | grep -i "[0-9]" -c) )); then echo -en '\tPhysical Port Number\t=\tPort '; cat /sys/class/scsi_host/$host/portnum; fi; fi; 
		echo -e '\tPCI Connector\t\t=\t'$hba;
		echo -en '\tModel Description \t=\t';
			if [[ -f /sys/class/scsi_host/$host/modeldesc ]]; then cat /sys/class/scsi_host/$host/modeldesc;
			else cat /sys/class/scsi_host/$host/model_desc; fi;
		echo -en '\tFirmware Version \t=\t'; 
			if [[ -f /sys/class/scsi_host/$host/fwrev ]]; then cat /sys/class/scsi_host/$host/fwrev;
			else cat /sys/class/scsi_host/$host/fw_version; fi
		if [[ -f /sys/class/scsi_host/$host/hdw ]]; then echo -en '\tHardware Version \t=\t'; cat /sys/class/scsi_host/$host/hdw; fi;
		echo -en '\tROM Version \t\t=\t'; 
			if [[ -f /sys/class/scsi_host/$host/option_rom_version ]]; then cat /sys/class/scsi_host/$host/option_rom_version;
			else cat /sys/class/scsi_host/$host/optrom_fw_version; fi
		echo -en '\tSerial Number \t\t=\t'; cat /sys/class/scsi_host/$host/serial*num;
		#echo -en '\tLink State \t\t=\t'; state=$(cat /sys/class/scsi_host/$host/link_state | grep -vi fabric); echo -e $state;
		if [[ -f /sys/class/scsi_host/$host/device/fc_host/$host/port_state ]]; then state=$(cat /sys/class/scsi_host/$host/device/fc_host/$host/port_state); else state=$(cat /sys/class/scsi_host/$host/device/fc_host:$host/port_state); fi
		echo -en '\tLink State \t\t=\t'; echo $state;
		echo -en '\tCurrent Speed \t\t=\t'; if [[ -f /sys/class/scsi_host/$host/device/fc_host/$host/speed ]]; then cat /sys/class/scsi_host/$host/device/fc_host/$host/speed; else cat /sys/class/scsi_host/$host/device/fc_host:$host/speed; fi
		echo -en '\tSupported Speeds \t=\t'; if [[ -f /sys/class/scsi_host/$host/device/fc_host/$host/supported_speeds ]]; then cat /sys/class/scsi_host/$host/device/fc_host/$host/supported_speeds; else cat /sys/class/scsi_host/$host/device/fc_host:$host/supported_speeds; fi;
		echo -en '\tWWN ID\t\t\t=\t'; cat /sys/class/fc_host/$host/port_name;
		echo -en '\tSCSI Connector\t\t=\t'; if (( ! $(echo $state | grep -i down -c) && $(ls -1 /sys/bus/pci/devices/0000\:$hba/$host/ | grep -i port -c) )); then ls -1 /sys/bus/pci/devices/0000\:$hba/$host/ | grep -i port | cut -d'-' -f2 | uniq; else echo -e 'None'; fi;
		pci_slot=$(dmidecode | grep -i $(echo $hba | cut -d'.' -f1) -B8 | grep -i Designation | cut -d':' -f2 | sed -e 's/^ PCIe Slot//g' -e 's/^[ \t]*//;s/[ \t]*$//');
		echo -en '\tPCI Slot\t\t=\t';  if (( $(echo $pci_slot | tr -d '\n' | wc -m) )); then echo $pci_slot; else lspci -s $hba -v | grep -i Physical | cut -d':' -f2 | sed -e 's/ //g'; fi;
	#fi;
	done
done
