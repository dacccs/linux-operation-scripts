#!/bin/bash
################################################
# Bond Check Script                            #
# Created: dacccs                              #
# Last modification: 2021.07.26                #
################################################
VERSION=1.0051; 

function info {
	echo -e '\e[1;32m'$*'\e[0m\n';
}

function error {
	echo -e '\e[1;31m'$*'\e[0m';
}

echo -e '--BOND-------------------------------------------------------------------------';
if (( ! $(lsmod | grep -i bonding -c) )); then echo -e 'No bonding interface(s) configured!'; exit; fi;

# The path of the bond directory
BOND_PATH='/proc/net/bonding';
CLASS_DIR='/sys/class/net';

# Fatch the files in directory
for BOND_FILE in `ls -1 $BOND_PATH/bond* | grep -iv '\.'`; do
	BOND=$(echo $BOND_FILE | rev | cut -d'/' -f1 | rev);
	SLAVES=$(ls -1 $CLASS_DIR/$BOND/ | grep -iE "lower|slave" | cut -d'_' -f2 | sort | uniq | wc -l)
	echo -en '\n\e[0;33mInterface: ';
	COUNT=0;
	case $SLAVES in
		0) STRING='\nSlave interface is not available.'; let COUNT++;;
		1) STRING='\nOnly one slave interface is available.'; let COUNT++;;
	esac
	if (( $SLAVES < 2 )); then STRING='\nOnly one slave interface is available.'; let COUNT++; fi;
	if (( $(cat $BOND_PATH/$BOND | grep -m1 802.3ad -c) )); then
		MII=$(cat $BOND_PATH/$BOND | grep "MII Status" | head -1 | rev | cut -d' ' -f1 | rev);
		if [[ $MII != 'up' ]]; then STRING='\nLACP not working.'; let COUNT++; fi;
	fi;
	
	# Bond interface name coloring according the status of the device
	if (( $COUNT > 0 || $(cat $BOND_PATH/$BOND | grep -i "^Aggregator ID:" | uniq | wc -l) > 1 )); then error $BOND$STRING;
	else info $BOND;
	fi;
	
	# Bondig mode details
	cat $BOND_FILE | grep -i --color=never "Bonding Mode";
	if (( $(cat $BOND_FILE | grep -i "Bonding Mode" | grep -iE "Dynamic link aggregation|802.3ad" -c) )); then cat $BOND_FILE | grep -i --color=never "LACP rate"; fi
	LACP=$(cat $BOND_PATH/$BOND | grep -m1 802.3ad -c);	
	
	# Slave interfaces
	#for SLAVE in `ls -1 $CLASS_DIR/$BOND/ | grep -i lower`; do
	for INTERFACE in `ls -1 $CLASS_DIR/$BOND/ | grep -iE "lower|slave" | cut -d'_' -f2 | sort | uniq`; do
		#INTERFACE=$(echo $SLAVE);
		# Determine the OS related configuration
		if [[ -d $CLASS_DIR/$BOND/lower_$INTERFACE/ ]]; then SLAVE='lower_'$INTERFACE; else SLAVE='slave_'$INTERFACE; fi;
		
		# Information provisioning
		echo -e 'Slave interface: '$INTERFACE;
		if (( $LACP )); then echo -en '\tAggregator ID : '; cat $CLASS_DIR/$BOND/$SLAVE/bonding_slave/ad_aggregator_id; fi;
		echo -en '\tMAC Address : '; echo $(ethtool -P $INTERFACE | sed -e 's/Permanent address: //g');
		echo -en '\tStatus : '; echo $(cat $CLASS_DIR/$BOND/$SLAVE/speed; echo '('; cat $CLASS_DIR/$BOND/$SLAVE/operstate; echo ')';);
		# LACP status dtermining
		if (( $LACP )); then
			ID=$(cat $BOND_FILE | grep -i "Aggregator ID" | head -n1 | rev | cut -d':' -f1 | rev );
			if [[ -f $CLASS_DIR/$BOND/$SLAVE/bonding_slave/ad_aggregator_id ]]; then
				if (( $ID != $(cat $CLASS_DIR/$BOND/$SLAVE/bonding_slave/ad_aggregator_id) )); then error '\tSlave interface \e[1;33m('$INTERFACE')\e[1;31m has a different Aggregator ID (\e[1;33m'$(cat $CLASS_DIR/$BOND/$SLAVE/bonding_slave/ad_aggregator_id)'\e[1;31m instead of \e[1;32m'$(echo $ID | sed -e 's/^[ \t]*//')'\e[1;31m)'; fi;
			else error '\tAggregation ID is not present on '$SLAVE'.';
			fi;
		fi;	
		echo -e '';
	done	
done
