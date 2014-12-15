#!/bin/sh                                                                     
#


echo "Please enter the new hostname: " &&
read input_hostname &&
echo "Please enter the new locale IP: " &&
read input_local_IP &&
echo "Please enter the new external IP: " &&
read input_ext_IP &&


sudo sh -c "echo '$input_hostname' > /etc/hostname" &&
less /etc/hostname &&
sudo sh -c "sed -i -e 's/template/$input_hostname/' /etc/hosts && sed -i -e 's/5\.135\.240\.219/$input_ext_IP/' /etc/hosts" &&
less /etc/hosts &&
sudo sh -c "sed -i -e 's/192\.168\.1\.1/$input_local_IP/' /etc/network/interfaces" &&
sudo sh -c "sed -i -e 's/5\.135\.240\.210/$input_ext_IP/' /etc/network/interfaces" &&
sudo nano -c /etc/network/interfaces &&
sudo rm /etc/ssh/ssh_host_* &&
sudo /usr/sbin/dpkg-reconfigure openssh-server &&

sudo /usr/sbin/locale-gen &&
sudo /usr/sbin/dpkg-reconfigure locales 


echo "now you should sudo /sbin/shutdown -r now && exit ;-)" 

