cd
ls
ls
cd
cd /
ls
rm -rf rpi-vanilla-master.tar 
cd /nfs/
ls
cd vanilla-master/
ls
rm -rf *
ls
dphys-swapfile swapoff
dphys-swapfile uninstall
update-rc.d dphys-swapfile remove
exit
rm /etc/ssh/ssh_host_*
dpkg-reconfigure openssh-server
exit
