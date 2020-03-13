#!/bin/bash
# from the client (ubuntu machine)

apt-get install nfs-client

showmount -e 10.128.0.30     #where $ipaddress is the ip of your nfs server
mkdir /mnt/test
echo "10.128.0.30:/var/nfsshare/testing        /mnt/test       nfs     defaults 0 0" >> /etc/fstab
mount -a
#*profit*
echo "*.info;mail.none;authpriv.none;cron.none   @10.128.0.5" >> /etc/rsyslog.conf && systemctl restart rsyslog.service
