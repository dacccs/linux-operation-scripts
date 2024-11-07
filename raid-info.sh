#!/bin/bash
##########################################################
# Raid Information Script                                #
# Created: dacccs                                        #
# Last modification: 2024.10.07                          #
##########################################################
VERSION=1.0000;

echo -e '--Raid Device------------------------------------------------------------------';

# Linux SW Raid
if (( $(ls -1 /dev/ | grep -iE "md[0-9]+" -c) )); then
        cat /proc/mdstat
        echo '';
        for md in `ls -1 /dev/ | grep -iE "md[0-9]+"`; do
                mdadm -D /dev/$md;
        done
fi;

# MegaCLI
if (( $(rpm -qa | grep -i megacli -c) )); then
        if (( ! $(cat /etc/profile | grep -i opt/MegaRAID -c) )); then echo 'export PATH=$PATH:/opt/MegaRAID/MegaCli/' >> /etc/profile; export PATH=$PATH:/opt/MegaRAID/MegaCl
i/; fi;
        MegaCli64 -LdPdInfo -aAll | egrep -i "Virtual Drive:|^Size|^State|Number Of Drives|Firmware state" | sed -e 's/ //g' | sed -e 's/:/\#: /' | column -t -s# | sed -e 's/
:/\t:/'
        echo -e '';
# Raid Devices
        raid_dev=$(fdisk -l | grep -i MR9267-8i -B1 | grep -i dev | cut -d' ' -f2 | sed -e 's/://g')
        for i in `MegaCli64 -LdPdInfo -aAll | grep -i "^device id" | cut -d':' -f2 | sed -e 's/ //g'`; do
                        smartctl -a -d megaraid,$i $raid_dev | egrep -i "Vendor:|Product:|Revision:|Model Family|Device Model|Serial Number|User Capacity|Rotation Rate|Form F
actor|SATA Version"
                        SMART=$(smartctl -a -d megaraid,$i $raid_dev | egrep -i "Power_On_Hours|number of hours powered up|Temperature_Celsius|Power_Cycle_Count|Current Drive
 Temperature" | sed -e ':a;N;$!ba;s/\n/#/g')
                                        COUNT=$(echo $SMART | tr -dc '#' | wc -c);
                                        let COUNT+=1;
                        for ((j=1;j<=$COUNT;j++)); do
                                        if (( $(echo $SMART | cut -d'#' -f$j | grep -i Power_Cycle_Count -c) )); then
                                                        echo -e 'Power On Count:\t  '$(echo $SMART | cut -d'#' -f$j | rev | cut -d' ' -f1 | rev);
                                        fi;
                                        if (( $(echo $SMART | cut -d'#' -f$j | grep -i Power_On_Hours -c) )); then
                                                        echo -en 'Power On Time:\t  '; VALUE=$(echo $SMART | cut -d'#' -f$j | rev | cut -d' ' -f1 | rev); echo -e $(($VALUE/24
))' days, '$(($VALUE%24))' hours';
                                        fi;
                                        if (( $(echo $SMART | cut -d'#' -f$j | grep -i "number of hours powered up" -c) )); then
                                                        echo -en 'Power On Time:\t      '; VALUE=$(echo $SMART | cut -d'#' -f$j | rev | cut -d' ' -f1 | rev); echo -e $(($(ech
o $VALUE| cut -d'.' -f1)/24))' days, '$(($(echo $VALUE| cut -d'.' -f1)%24))' hours';
                                        fi;
                                        if (( $(echo $SMART | cut -d'#' -f$j | grep -iE Temperature_Cels -c) )); then
                                                        echo -e 'Temperature:\t  '$(echo $SMART | cut -d'#' -f$j | rev | cut -d' ' -f1 | rev)'°C';
                                        fi;
                                                                        if (( $(echo $SMART | cut -d'#' -f$j | grep -i 'Current Drive Temperature' -c) )); then
                                                        echo -e 'Temperature:\t      '$(echo $SMART | cut -d'#' -f$j | rev | cut -d' ' -f2 | rev)'°C';
                                        fi;
                        done
                echo -e '';
        done
fi;

#3Ware
if (( $(rpm -qa | grep -i megacli -c) )); then
        ADAPTER=$(tw_cli info | grep -iE "c[0-9]" | cut -d ' ' -f1);
        for (( i=0; i<$(tw_cli /$ADAPTER show | grep -iE "^p[0-9]" | wc -l); i++ )); do
                        smartctl -a -d 3ware,$i /dev/twa0 | egrep -i "Model Family|Device Model|Serial Number|User Capacity|Rotation Rate|Form Factor|SATA Version"
                        SMART=$(smartctl -a -d 3ware,$i /dev/twa0 | egrep -i "Power_On_Hours|Temperature_Celsius|Power_Cycle_Count" | sed -e ':a;N;$!ba;s/\n/#/g')
                        for j in {1..3}; do
                                        if (( $(echo $SMART | cut -d'#' -f$j | grep -i Power_Cycle_Count -c) )); then
                                                        echo -e 'Power On Count:\t  '$(echo $SMART | cut -d'#' -f$j | rev | cut -d' ' -f1 | rev);
                                        fi;
                                        if (( $(echo $SMART | cut -d'#' -f$j | grep -i Power_On_Hours -c) )); then
                                                        echo -en 'Power On Time:\t  '; VALUE=$(echo $SMART | cut -d'#' -f$j | rev | cut -d' ' -f1 | rev); echo -e $(($VALUE/24
))' days, '$(($VALUE%24))' hours
        ';
                                        fi;
                                        if (( $(echo $SMART | cut -d'#' -f$j | grep -i Temperature -c) )); then
                                                        echo -e 'Temperature:\t  '$(echo $SMART | cut -d'#' -f$j | rev | cut -d' ' -f1 | rev)'°C';
                                        fi;
                        done
                        echo -e '\n------------------------------------------------------------------------------\n';
        done
        echo -e 'RAID information:';
        echo -e '------------------------------------------------------------------------------';
        tw_cli /$ADAPTER show
fi;
