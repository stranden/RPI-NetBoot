# RPI-NetBoot
Boot a Raspberry Pi from the network via TFTP and mounting /boot and /root from a NFS server


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

NFS export targets /etc/exports
```
/srv/rpi/nfs/ec6be72b/ml_screen *(rw,sync,insecure,no_subtree_check,no_root_squash)
/srv/rpi/tftp/ec6be72b *(rw,sync,insecure,no_subtree_check,no_root_squash)
```

In order to boot a Raspberry Pi off the network. There are some constrains which needs to be forfilled.

| Raspberry Pi model    | Able to network boot                  |
| --------------------- | ------------------------------------- |
| Raspberry Pi 1        | Yes - Needs SD-card with bootcode.bin |
| Raspberry Pi 2        | Yes - Needs SD-card with bootcode.bin |
| Raspberry Pi 3B       | Yes - Needs SD-card with bootcode.bin |
| Raspberry Pi 3B+      | Yes |
| Raspberry Pi 4        | Yes |

For Raspberry Pi models 1, 2 and 3B there are some steps in order to boot off the network
They all need to boot from the USB which includes the PXE boot

Append `program_usb_boot_mode=1` to `/boot/config.txt``
```
echo program_usb_boot_mode=1 | sudo tee -a /boot/config.txt
```

Reboot the PI and check if it worked as it should with `vcgencmd otp_dump | grep 17:`
```
pi@raspberrypi:~ $ vcgencmd otp_dump | grep 17:
17:3020000a
```
The output should say `3020000a` then it has worked