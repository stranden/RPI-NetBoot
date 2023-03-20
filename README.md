# RPI-NetBoot
**Repository used for managing, configuring and booting Raspberry PI's via the network** 

First we use the [inventory.json](https://github.com/stranden/RPI-NetBoot/blob/master/inventory.json) file as the inventory for all PI's.

The serial number from each PI is used as the key when a PI check if it's managed by the repository or not.
If the check turns out to be true, then it will look under the config section. The hostname will then be given and a possible purpose for that specific PI.

```json
"e51b1483": {
    "model": "Raspberry Pi 3 Model B Plus Rev 1.3",
    "serial": "e51b1483",
    "wired_mac": "b8:27:eb:1b:14:83",
    "wireless_mac": "be:f0:4a:14:af:0a",
    "config": {
        "hostname": "e51b1483",
        "purpose": "ml_screen",
        "ml_screen": {
            "id": 1
        }
    }
}
```
> NOTE: The "value" of the "purpose" key, will ALWAYS be a new key!


## Raspberry PI server setup
**But before the PI will be able to check if it is managed, it needs to be booted. Therefore we need three diffierent services on the network:**
- DHCP server which will hand out the following options:
    - next-server <IP> of the TFTP server e.g. 172.20.60.50
    - option tftp-server-name (66) of the TFTP server e.g. "172.20.60.50"
- TFTP server which will store the bootfiles for the PI's (including bootcode.bin)
- NFS server to serve the PI which it own root filesystem / and optional a /boot mount as well

Those services can be hosted on the same server, at least the TFTP and NFS properly should be hosted on the same machine, so the /boot target will be easy to expose for the PI.

I have installed all services on the same server based on the newest Debian net-install :
```sh
$ sudo apt install isc-dhcp-server tftpd-hpa nfs-kernel-server
```

### isc-dhcp-server configuration ###
We need to define the interface where the dhcp server should listen, otherwise it will not start.
That specific configuration is defined in `/etc/default/isc-dhcp-server` and change the `INTERFACESv4` to the correct interface
```sh
INTERFACESv4="ens33"
#INTERFACESv6=""
```
After thats done we need to change actual dhcp configuration in `/etc/dhcp/dhcpd.conf`
> NOTE: If the DHCP server is located on a different subnet, than where the PI's is located we need to define the layer2 subnet for the server as well. Otherwise the DHCP will refuse to start ...

The definition for the local layer2 subnet are shown here, it will not hand any addresses out to clients.
```sh
subnet 172.20.60.0 netmask 255.255.255.0 {
}
```

This is the configuration for the subnet where the PI's are located and will receive DHCP addresses and try to PXE boot from
```sh
subnet 172.20.20.0 netmask 255.255.255.0 {
  range 172.20.20.101 172.20.20.254;
  option domain-name-servers 1.1.1.1;
  option domain-name "hs-network.dk";
  option routers 172.20.20.1;
  option broadcast-address 172.20.20.255;
  default-lease-time 600;
  max-lease-time 7200;
  next-server 172.20.60.50;
  option tftp-server-name "172.20.60.50";
}
```

We can also define a static lease for the PI, so it always will recieve the same DHCP address. Thats quite nice for management.

*NB: This should be built into the inventory, so a bash script scheduled with crontab can create these fixed addresses* 

```sh
host pi-ec6be72b {
  hardware ethernet b8:27:eb:6b:e7:2b;
  fixed-address 172.20.20.101;
  option host-name "ec6be72b";
}
```

### tftp-hpa configuration ###
The configuration for the TFTP server is much more simple than the DHCP
In order to configure the service, we need to take a look at `/etc/default/tftpd-hpa`.
`TFTP_DIRECTORY` need to be configured to the decired directory and `--verbose` should be added to ``
```sh
# /etc/default/tftpd-hpa

TFTP_USERNAME="tftp"
TFTP_DIRECTORY="/srv/rpi/tftp"
TFTP_ADDRESS=":69"
TFTP_OPTIONS="--secure --verbose"
```

### nfs-kernel-server configuration ###
Last but not least we need to configure the NFS server, which will be the one handling all the storage for all PI's
All configuration are done under `/etc/exports` which defines the targets, we are using NFSv3.
For each PI there needs to at least two shares, one for the root filesystem and one for the /boot filesystem.
The root filesytems are located under the **nfs** folder and the /boot filesystems are located under the **tftp** folder

*NB: This should also be integrated with the inventory, so there will be a bash script that will create and update all the NFS targets. It should be scheduled via crontab.*

```sh
/srv/rpi/nfs/ec6be72b/ml_screen *(rw,sync,insecure,no_subtree_check,no_root_squash)
/srv/rpi/tftp/ec6be72b *(rw,sync,insecure,no_subtree_check,no_root_squash)
```

## Raspberry PI configuration
**Every PI needs some aditional configuration in order to be able to boot of the Network**

This is table shows the different models, each model have different requirements in order to be able to boot

| Raspberry Pi model    | Able to network boot                  |
| --------------------- | ------------------------------------- |
| Raspberry Pi 1        | Requires a FAT32 SD-card with bootcode.bin |
| Raspberry Pi 2        | Requires a FAT32 SD-card with bootcode.bin |
| Raspberry Pi 3B       | Requires a FAT32 SD-card with bootcode.bin |
| Raspberry Pi 3B+      | Working out of box |
| Raspberry Pi 4        | Needs a new EEPROM bootloader |


### Raspberry Pi Model 1, 2 and 3B
For those models there are some steps in order to boot off the network
They all need to boot from the USB which includes the PXE boot

Append `program_usb_boot_mode=1` to `/boot/config.txt``
```sh
echo program_usb_boot_mode=1 | sudo tee -a /boot/config.txt
```

Reboot the PI and check if it worked as it should with `vcgencmd otp_dump | grep 17:`
```sh
pi@raspberrypi:~ $ vcgencmd otp_dump | grep 17:
17:3020000a
```
The output should say `3020000a` then it has worked

All three models need a FAT32 formated SD-card inserted with `bootcode.bin`

### Raspberry Pi Model 3B+
This model should work out of the box, but otherwise do the same as Model 1, 2 and 3B.
But it doesn't need a SD-card.

### Raspberry Pi Model 4
For the Raspberry Pi 4 it needs a need EEPROM bootloader.
It can be installed via the `Raspberry Pi Imager` which can be downloaded from the [Official Raspberry Pi](https://www.raspberrypi.com/software/) website


## Individual images for different purposes
**We have some different images for the different purposes in the inventory file**

### Configuration of ML_SCREEN

Installed packages:
- xserver-xorg
- x11-xserver-utils
- xinit (I think this can be removed)
- feh
- openbox
- lightdm-login-greeter (maybe)

```
pi@e51b1483:~ $ cat .xserverrc
#!/bin/sh

exec /usr/bin/X -listen tcp "$@"
```

```
pi@e51b1483:~ $ cat .xinitrc
#!/bin/sh

xsetroot -solid white &
sh ~/.fehbg &
openbox --config-file /home/pi/.config/openbox/bare.xml
```



## Nice things which we need to use in scripts


Grep the Model from a RPI
```
pi@rpi-master:~ $ cat /proc/cpuinfo | grep Model | cut -d ':' -f 2 | sed -e 's/^[ \t]*//'
Raspberry Pi 3 Model B Plus Rev 1.3
```


Grep the S/N from a RPI
```
pi@rpi-master:~ $ cat /proc/cpuinfo | grep Serial | cut -d ':' -f 2 | sed -e 's/^[ \t]*//' | sed -E 's/.*(.{8})$/\1/'
e51b1483
```


## License
MIT

