#!/bin/bash
#

check_inventory($serial) {
    inventorySerialArray=`curl -s https://raw.githubusercontent.com/stranden/RPI-NetBoot/master/inventory.json | jq ".rpi.data" | jq 'keys[]' | cut -d "\"" -f 2`
    if [[ "${inventorySerialArray[*]}" =~ "${serial}" ]];
    then
        echo "[SUCCESS] Inventory contains $serial"
        return 0
    else
        echo "[FAILED] $serial is not found in inventory"
        return 1
    fi
}

check_hostname($serial) {
    getHostname=$(hostname)
    inventoryHostname=`curl -s https://raw.githubusercontent.com/stranden/RPI-NetBoot/master/inventory.json | jq ".rpi.data.$serial.config.hostname"`
    if [[ $getHostname == $inventoryHostname ]];
    then
        echo "[SUCCESS] Hostname is set correct"
        return 0
    else
        echo "[FAILED] Hostname needs to be configured to: $inventoryHostname"
        sed -i "s/$getHostname/$inventoryHostname/g" /etc/hostname
        sed -i "s/$getHostname/$inventoryHostname/g" /etc/hosts
        #reboot
        return 1
    fi
}

check_purpose($serial) {
    inventoryPurpose=`curl -s https://raw.githubusercontent.com/stranden/RPI-NetBoot/master/inventory.json | jq ".rpi.data.$serial.config.purpose"`
    if [[ $inventoryPurpose == "ml_screen" ]];
    then
        inventoryMLScreenID=`curl -s https://raw.githubusercontent.com/stranden/RPI-NetBoot/master/inventory.json | jq ".rpi.data.$serial.config.ml_screen.id"`
        inventoryMLScreenIP="10.91.1.$inventoryMLScreenID"
        systemIP=$(hostname -I)
        mlScreenIP=$(echo $systemIP | cut -d " " -f 2)
        mlScreenOctet=$(echo $mlScreenIP | cut -d "." -f 4)
        mlTargetIP=$(echo $mlScreenIP | sed -e "s/\.1.$mlScreenOctet/.0.$mlScreenOctet/")

        echo "[INFO] MEGALINK Screen ID $inventoryMLScreenID"

        if [[ $inventoryMLScreenIP == $mlScreenIP ]];
        then
            echo "[SUCCESS] MEGALINK Screen IP $mlScreenIP - MEGALINK Target IP must be $mlTargetIP"
            return 0
        else
            echo "[FAILED] MEGALINK Screen IP is $mlScreenIP it should have been $inventoryMLScreenIP"
            sed -i "s/$mlScreenIP/$inventoryMLScreenIP/g" /etc/network/interfaces.d/eth0
            #reboot
            return 1
        fi
        
    fi
   
}

getSerial=`cat /proc/cpuinfo | grep Serial | cut -d ':' -f 2 | sed -e 's/^[ \t]*//' | sed -E 's/.*(.{8})$/\1/'`

check_inventory($getSerial)
if [[ "$?" -eq 0 ]];
then
    check_hostname($getSerial)
    if [[ "$?" -eq 0 ]];
    then
        check_purpose($getSerial)
        if [[ "$?" -eq 0 ]];
        then
            echo "[SUCCESS] Everything is looking good!"
        fi
    fi
else
    echo "[INFO] Terminating flight check - you are on your own!"
fi