# RPI-NetBoot
Boot a Raspberry Pi from the network via TFTP and mounting /boot and /root from a NFS server

pi@rpi-master:~ $ cat /proc/cpuinfo | grep Model | cut -d ':' -f 2 | sed -e 's/^[ \t]*//'
Raspberry Pi 3 Model B Plus Rev 1.3
pi@rpi-master:~ $ cat /proc/cpuinfo | grep Serial | cut -d ':' -f 2 | sed -e 's/^[ \t]*//'
00000000e51b1483