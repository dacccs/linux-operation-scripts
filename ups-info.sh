#!/bin/bash
##########################################################
# UPS Information Script                                 #
# Created: dacccs                                        #
# Last modification: 2025.01.09                          #
##########################################################
VERSION=1.0002;

function get_key(){
        echo $1 | cut -d':' -f1
}

function get_value(){
        echo $1 | cut -d':' -f2 | sed -E 's/^[ ]+//g' | sed -E 's/[ ]+$//g'
}

function ups_code(){
	case $1 in 
		OL) echo 'On line';;
		OB) echo 'On battery';;
		LB) echo 'Low battery';;
		RB) echo 'Replace battery';;
		BYPASS) echo 'Battery bypass active or no battery installed';;
		SD) echo 'Shutdown load';;
		CP) echo 'Cable power (must be present for cable to have valid reading)';;
		CTS) echo 'Clear to Send. Received from the UPS.';;
		RTS) echo 'Ready to Send. Sent by the PC.';;
		DCD) echo 'Data Carrier Detect. Received from the UPS.';;
		RNG) echo 'Ring indicate. Received from the UPS.';;
		DTR) echo 'Data Terminal Ready. Sent by the PC.';;
		DSR) echo 'Data Set Ready. Received from the UPS.';;
		ST) echo 'Send a BREAK on the transmit data line.';;
		NULL) echo 'Disable this signal.';;
		*) echo 'Unknown status code.'
	esac	
}

if ([ -f /etc/ups/ups.conf ] && [ -f /etc/ups/upsd.conf ]); then
	if (( $(upsc -L 2>&1 | grep -i refused -c) )); then printf "    %-28s\n" "UPS agent not running."; exit; fi
else exit;	
fi;	

echo -e '--UPS Device(s)----------------------------------------------------------------\n';

IFS=$'\n';
for ups in `upsc -L`; do 
	device=$(echo $ups | cut -d':' -f1); 
	
	printf "    %-28s\n" 'UPS device';
	printf "      %-16s: %s\n" $(get_key $ups) $(get_value $ups);
	
	voltage='';
	battery='';
	ups_info='';
	
	for value in `upsc $device@localhost | grep -iE "battery|(in|out)put.voltage(:|.nominal)|ups.(load|status)"`; do
		
		# Voltage related values
		if (( $(echo $value | grep -iE '^input|^output' -c) )); then 
			if (( $(echo $value | grep -i 'nominal' -c) )); then voltage_nominal=$(get_value $value);
			else voltage=$voltage$value'#';
			fi
		fi	
		
		# Battery related values
		if (( $(echo $value | grep -i battery -c) )); then 
			case $(echo $value | cut -d'.' -f2-) in
				charge) battery=$battery$(echo $value | cut -d'.' -f2-)'%#';;
				*) battery=$battery$(echo $value | cut -d'.' -f2-)'#';;
			esac
		fi	
		
		# UPS related values
		if (( $(echo $value | grep -i ups -c) )); then ups_info=$ups_info$(echo $value | cut -d'.' -f2-)'#'; fi
		
	done
	
	# list ups values
	for value in $(echo $ups_info | tr '#' '\n'); do
		if (( $(echo $value | grep -i status -c) )); then printf "      %-16s: %s\n" $(get_key ${value^}) $(ups_code $(get_value $value));
		else printf "      %-16s: %s\n" $(get_key ${value^}) $(get_value $value);
		fi;
	done
	
	printf "\n    %-28s\n" 'Voltage informaton';
	
	# list voltage values
	for value in $(echo $voltage | tr '#' '\n'); do
		printf "      %-20s: %sV (%sV)\n" $(get_key ${value^}) $(get_value $value) $voltage_nominal
	done
	
	printf "\n    %-28s\n" 'Battery informaton';
	
	# list battery values
	for value in $(echo $battery | tr '#' '\n'); do
		case $value in 
			charge*) value=$value'%';;
			voltage*) value=$value'V';;
		esac 
		#if (( $(echo $value | grep -i voltage -c) )); then value=$value'V'; fi;
		printf "      %-20s: %s\n" $(get_key ${value^}) $(get_value $value)
	done
	
done
