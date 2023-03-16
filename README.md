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