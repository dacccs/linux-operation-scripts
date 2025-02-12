#!/bin/bash
################################################
# CPU Info Script                              #
# Created: Ottó Király                         #
# Last modification: 2025.02.12                #
################################################
VERSION=1.0044;

function printout() {
	printf "    %-28s: %-s \n" "$1" "$2";
}

cpu=$(dmidecode -t processor | sed -e 's/[ \t]*//' | sed -e 's/$/#/');
cpu_all=$(echo $cpu | sed -e 's/#/\n/g' | sed -e 's/^ //g' | grep -iE "^Handle" | wc -l);
cpu_inst=$(echo $cpu | sed -e 's/#/\n/g' | sed -e 's/^ //g' | grep -i " popu" | wc -l);
cpu_type=$(cat /proc/cpuinfo | grep -i "model n" | sort -u | cut -d':' -f 2 | sed -e 's/^ //');
cpu_core=$(echo $cpu | sed -e 's/#/\n/g' | sed -e 's/^ //g' | grep -i "core c" | sort -u | cut -d' ' -f3)
cpu_thread=$(echo $cpu | sed -e 's/#/\n/g' | sed -e 's/^ //g' | grep -i "thread c" | sort -u | cut -d' ' -f3)

echo -e '--CPU--------------------------------------------------------------------------';
echo -e '';

printout 'All/Free socket(s)' "$cpu_all/$(($cpu_all-$cpu_inst))"
printout 'Total Core Count' "$(( $cpu_inst*$cpu_core))";
printout 'Total Thread Count' "$(( $cpu_inst*$cpu_thread))";
echo -e '';
		  
printout 'Modell' "$cpu_type";
printout 'Max Speed' "$(echo $cpu | sed -e 's/#/\n/g' | sed -e 's/^ //g' | grep -i 'Max Speed' | grep -iv unknow | sort -u | cut -d':' -f 2 | sed -e 's/^ //')";
printout 'Current Speed' "$(echo $cpu | sed -e 's/#/\n/g' | sed -e 's/^ //g' | grep -i 'Current Speed' | grep -iv unknow | sort -u | cut -d':' -f 2 | sed -e 's/^ //')";
printout 'Socket' "$(echo $cpu | sed -e 's/#/\n/g' | sed -e 's/^ //g' | grep -i upgrade | sort -u | cut -d':' -f 2 | sed -e 's/^ //')";
printout 'CPU Core Count' "$(echo $cpu | sed -e 's/#/\n/g' | sed -e 's/^ //g' | grep -i 'core c' | sort -u | cut -d' ' -f3)";
printout 'CPU Thread Count' "$(echo $cpu | sed -e 's/#/\n/g' | sed -e 's/^ //g' | grep -i 'thread c' | sort -u | cut -d' ' -f3)";
echo -e '';
