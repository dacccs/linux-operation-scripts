#!/bin/bash
##########################################################
# NVME Information Script                                #
# Created: dacccs                                        #
# Last modification: 2024.10.07                          #
##########################################################
VERSION=1.0003;

function get_value(){
        echo $1 | cut -d':' -f2 | cut -d'"' -f2 | cut -d',' -f1
}

echo -e '--NVME Device(s)---------------------------------------------------------------';

IFS=$'\n';
num=0;
for i in `nvme list --output-format=json | grep -iE "DevicePath|ModelNumber|Firmware|SerialNumber|PhysicalSize"`; do
        case $i in
                *DevicePath*) nvme_dev=$(get_value $i); echo -e '\tNVME Device '$num'\t\t: '$nvme_dev; let num++;;
                *ModelNumber*) echo -e '\tNVME Model Num\t\t: '$(get_value $i);;
                *Firmware*) echo -e '\tNVME Serial\t\t: '$(get_value $i);;
                *SerialNumber*) echo -e '\tNVME Firmware\t\t: '$(get_value $i);;
                *PhysicalSize*) nvme_size=$(get_value $i); let nvme_size=nvme_size/1000000000; echo -e '\tNVME Size\t\t: '$nvme_size' GB'; nvme smart-log $nvme_dev | grep -iE 'critical_warning|^temperature|available_spare|percentage_used|data_units_|power_cycles|power_on_hours|unsafe_shutdowns|media_errors|num_err_log_entries' | sed -e 's/^/\t/g' -e "s/\b\(.\)/\u\1/g"; echo '';;
        esac
done
