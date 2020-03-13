#used to correlate events useful when machine goes down

#!/bin/bash
sed -i 's/#$UDPServerRun 514/$UDPServerRun 514/g' /etc/rsyslog.conf
sed -i 's/#$InputTCPServerRun 514/$InputTCPServerRun 514/g' /etc/rsyslog.conf
sed -i 's/#$ModLoad imtcp/$ModLoad imtcp/g' /etc/rsyslog.conf
sed -i 's/#$ModLoad imudp/$ModLoad imudp/g' /etc/rsyslog.conf
setenforce 0 # disable se linux
systemctl restart rsyslog
netstat -antup | grep 514

echo "*.info;mail.none;authpriv.none;cron.none   @10.128.0.5" >> /etc/rsyslog.conf && systemctl restart rsyslog.service
