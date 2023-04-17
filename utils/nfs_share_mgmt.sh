#!/bin/bash

inventory_url="https://raw.githubusercontent.com/stranden/RPI-NetBoot/master/inventory.json"

check_share() {
    echo "Check share stuff here"
}

create_share() {
    echo "Create share stuff here"
}

delete_share() {
    echo "Delete share stuff here"
}

inventorySerialArray=`curl -s $inventory_url | jq -r '.rpi.data' | jq 'keys[]' | cut -d "\"" -f 2`
for serial in ${inventorySerialArray[@]}
do
    purpose=`curl -s $inventory_url | jq -r '.rpi.data."'$serial'".config.purpose'`
    check_share
    create_share
    delete_share
    echo "$serial has the following purpose: $purpose"
done
