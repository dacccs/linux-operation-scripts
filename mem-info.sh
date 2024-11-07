#!/bin/bash
################################################
# Memory Info Script                           #
# Created: dacccs                              #
# Last modification: 2024.11.07                #
################################################
VERSION=1.0004;
IFS=$'\n';

function trim {
    out=$(echo $1 | cut -d':' -f2 | sed -e 's/^ //g' -e 's/ $//g');
    echo -en $out;
}

function slot_output {
    if (($# > 2)); then
        part_length=$(echo ${#2});
        let out_length=38-part_length
        let out_spacer=out_length/2;
        let out_round=out_length%2;
        string=$(for ((i=1;i<=out_spacer;i++)); do echo -en █; done);
        string=$string' '$2' ';
        let out_spacer=out_spacer+out_round;
        string=$string$(for ((i=1;i<=out_spacer;i++)); do echo -en █; done);
        printf "    %-28s %-s %-s\n\n" $1 $string $3;
    else
		printf "    %-28s %-s\n\n" $1 '░░░░░░░░░░░░░░░░░ Empty ░░░░░░░░░░░░░░░░';
    fi;

}

######### Total system RAM based on dmidecode ##########

mem_all=0;
for i in `dmidecode -t memory | tr -d "\t" | grep -i "^size:" | cut -d':' -f2 | grep -iv "No Module"`; do
    if (( $(echo $i | grep -i MB -c) )); then
        i=$(echo $i | cut -d ' ' -f2);
        let i=i/1024;
    else
        i=$(echo $i | cut -d ' ' -f2);
    fi;
    let mem_all=mem_all+i;
done;

mem_slots_all=$(dmidecode -t memory | grep -i "Memory Device" -c);
mem_slots_free=$(dmidecode -t memory | grep -i "Type: Unknown" -c);

echo -e '--Memory-----------------------------------------------------------------------\n';

printf "    %-28s: %s\n" 'Installed Memory' "$mem_all GB";
printf "    %-28s: %s\n\n" 'All/Free Slot(s)' "$mem_slots_all/$mem_slots_free";

########## Slots ###############

for i in `dmidecode -t memory | tr '\n' ';' | sed 's/;;/\n/g'`; do

    mem_type=$(echo $i | tr ';' '\n' | grep -i 'Type:' | grep -iv 'Correction Type');
    if (( $(echo $mem_type | grep -i type -c) )); then
        mem_locate=$(echo $i | tr ';' '\n' | grep -i 'Locator:' | grep -iv 'Bank Locator');
        if (( ! $(echo $mem_type | grep -i unknown -c ) )); then
            mem_partnum=$(echo $i | tr ';' '\n' | grep -i 'Part Number:');
            mem_size=$(echo $i | tr ';' '\n' | grep -i 'Size:');
            slot_output $(trim $mem_locate) $(trim $mem_partnum) $(trim $mem_size);
        else
            slot_output $(trim $mem_locate);
        fi;
    fi;
done

