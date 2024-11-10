#!/bin/bash
##########################################################
# NVME Information Script                                #
# Created: Ottó Király                                   #
# Last modification: 2024.11.10                          #
##########################################################
VERSION=1.0006;

function get_value(){
        echo $1 | cut -d':' -f2 | cut -d'"' -f2 | cut -d',' -f1
}

echo -e '--NVME Device(s)---------------------------------------------------------------\n';

IFS=$'\n';
num=0;
for i in `nvme list --output-format=json | grep -iE "DevicePath|ModelNumber|Firmware|SerialNumber|PhysicalSize"`; do
        case $i in
                *DevicePath*) nvme_dev=$(get_value $i); printf "    %-28s: %s\n" "NVME Device $num" $nvme_dev; let num++;;
                *ModelNumber*) printf "    %-28s: %s\n" 'NVME Model Num' $(get_value $i);;
                *Firmware*) printf "    %-28s: %s\n" 'NVME Firmware' $(get_value $i);;
                *SerialNumber*) printf "    %-28s: %s\n" 'NVME Serial' $(get_value $i);;
                *PhysicalSize*) nvme_size=$(get_value $i);
                                                let nvme_size=nvme_size/1000000000;
                                                printf "    %-28s: %s\n" 'NVME Size' "$nvme_size GB";
                                                for detail in `nvme smart-log $nvme_dev | grep -iE 'critical_warning|^temperature|percentage_used|data_units_|power_cycles|power_on_hours|unsafe_shutdowns|media_errors|num_err_log_entries|Data Units [RW]' | sed -e "s/\b\(.\)/\u\1/g";`; do
                                                        printf "    %-28s: %s\n" "$(echo $detail | cut -d':' -f1 | xargs)" "$(echo $detail | cut -d':' -f2 | xargs)";
                                                done;
                                                echo '';;
        esac
done
