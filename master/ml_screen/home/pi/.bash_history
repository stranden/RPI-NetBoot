sudo raspi-config 
sudo apt update
sudo apt upgrade
sudo apt install vim
sudo mkdir -p /nfs/vanilla-master
sudo apt install rsync
sudo rsync -xa --progress --exclude /nfs / /nfs/vanilla-master
sudo tar -cpf /rpi-vanilla-master /nfs/vanilla-master
sudo poweroff
ls /
ls -al
ls -al /
sudo tar -cpf /rpi-vanilla-master.tar /nfs/vanilla-master
ls- al
ls -al /
sudo rm /rpi-vanilla-master
ls -al /
scp /rpi-vanilla-master.tar henrik@172.20.60.50:/home/henrik/rpi-vanilla-master.tar
echo program_usb_boot_mode=1 | sudo tee -a /boot/config.txt
tail /boot/config.txt 
sudo reboot
vcgencmd otp_dump | grep 17:
sudo poweroff 
ls
cd rpi
cd /boot/
ls
ls -al
scp -r . root@172.20.60.50:/srv/rpi/tftp
scp -r /boot/ root@172.20.60.50:/srv/rpi/tftp
scp -r /boot/* root@172.20.60.50:/srv/rpi/tftp
sudo poweroff
sudo vim /etc/network/interfaces.d/eth0 
sudo reboot
ip addr
sudo raspi-config 
