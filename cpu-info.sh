#!/bin/bash
################################################
# CPU Info Script                              #
# Created: dacccs                              #
# Last modification: 2021.04.12                #
################################################
VERSION=1.0043;
cpu=$(dmidecode -t processor | sed -e 's/[ \t]*//' | sed -e 's/$/#/');
cpu_all=$(echo $cpu | sed -e 's/#/\n/g' | sed -e 's/^ //g' | grep -iE "^Handle" | wc -l);
cpu_inst=$(echo $cpu | sed -e 's/#/\n/g' | sed -e 's/^ //g' | grep -i " popu" | wc -l);
cpu_type=$(cat /proc/cpuinfo | grep -i "model n" | sort -u | cut -d':' -f 2 | sed -e 's/^ //');
cpu_core=$(echo $cpu | sed -e 's/#/\n/g' | sed -e 's/^ //g' | grep -i "core c" | sort -u | cut -d' ' -f3)
cpu_thread=$(echo $cpu | sed -e 's/#/\n/g' | sed -e 's/^ //g' | grep -i "thread c" | sort -u | cut -d' ' -f3)

echo -e '--CPU--------------------------------------------------------------------------';

#echo -e '\tCPU(s):\t\t\t'$cpu_inst" x "$cpu_type;
#let cpu_inst=cpu_all-cpu_inst;
echo -e '\tAll/Free socket(s):\t'$cpu_all'/'$(($cpu_all-$cpu_inst));
echo -e '\tTotal Core Count:\t'$(( $cpu_inst*$cpu_core));
echo -e '\tTotal Thread Count:\t'$(( $cpu_inst*$cpu_thread))'\n';

echo -e '\tModell:\t\t\t'$cpu_type;	
echo -e '\tMax Speed:\t\t'$(echo $cpu | sed -e 's/#/\n/g' | sed -e 's/^ //g' | grep -i "Max Speed" | grep -iv unknow | sort -u | cut -d':' -f 2 | sed -e 's/^ //');
echo -e '\tCurrent Speed:\t\t'$(echo $cpu | sed -e 's/#/\n/g' | sed -e 's/^ //g' | grep -i "Current Speed" | grep -iv unknow | sort -u | cut -d':' -f 2 | sed -e 's/^ //');
echo -e '\tSocket:\t\t\t'$(echo $cpu | sed -e 's/#/\n/g' | sed -e 's/^ //g' | grep -i upgrade | sort -u | cut -d':' -f 2 | sed -e 's/^ //');
echo -e '\tCPU Core Count:\t\t'$(echo $cpu | sed -e 's/#/\n/g' | sed -e 's/^ //g' | grep -i "core c" | sort -u | cut -d' ' -f3);
echo -e '\tCPU Thread Count:\t'$(echo $cpu | sed -e 's/#/\n/g' | sed -e 's/^ //g' | grep -i "thread c" | sort -u | cut -d' ' -f3)'\n\n';
