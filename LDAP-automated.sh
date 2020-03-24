#!/bin/bash

for file in $( ls /etc/yum.repos.d/ ); do mv /etc/yum.repos.d/$file /etc/yum.repos.d/$file.bak; done


echo "[nti-310-epel]
name=NTI310 EPEL
baseurl=http://34.71.91.10/epel
gpgcheck=0
enabled=1" >> /etc/yum.repos.d/local-repo.repo

echo "[nti-310-base]
name=NTI310 BASE
baseurl=http://34.71.91.10/base
gpgcheck=0
enabled=1" >> /etc/yum.repos.d/local-repo.repo

echo "[nti-310-extras]
name=NTI310 EXTRAS
baseurl=http://34.71.91.10/extras/
gpgcheck=0
enabled=1" >> /etc/yum.repos.d/local-repo.repo

echo "[nti-310-updates]
name=NTI310 UPDATES
baseurl=http://34.71.91.10/updates/
gpgcheck=0
enabled=1" >> /etc/yum.repos.d/local-repo.repo

yum install -y git
cd /tmp
git clone https://github.com/nic-instruction/hello-nti-310.git

yum install -y openldap-servers openldap-clients

cp /usr/share/openldap-servers/DB_CONFIG.example /var/lib/ldap/DB_CONFIG
chown ldap. /var/lib/ldap/DB_CONFIG

systemctl enable slapd
systemctl start slapd

yum install -y httpd phpldapadmin

#Let's SELinux know what is going on
setsebool -P httpd_can_connect_ldap on

systemctl enable httpd
systemctl start httpd

sed -i 's,Require local,#Require local\n   Require all granted,g' /etc/httpd/conf.d/phpldapadmin.conf

unalias cp
cp /etc/phpldapadmin/config.php /etc/phpldapadmin/config.php.orig
grep 'config.*blowfish' /etc/phpldapadmin/config.php.orig   #$config->custom->session['blowfish'] = 'c42d049ec980e8b043931a7aa544143b';  # Autogenerated for ldap
rightkey=$( grep 'config.*blowfish' /etc/phpldapadmin/config.php.orig )
cp /tmp/hello-nti-310/config/config.php /etc/phpldapadmin/config.php

sed -i "s/\$config->custom->session\['blowfish'\] = '6ad4614a51893aaf046e2057e7870ae4'\;  # Autogenerated for ldap-c/$rightkey/g" /etc/phpldapadmin/config.php # fix the key
chown ldap:apache /etc/phpldapadmin/config.php

systemctl restart httpd

echo "phpldapadmin is now up and running"
echo "we are configuring ldap and ldapadmin"

#Generates and stores new passwd securely
#newsecret=$(slappasswd -g)
newsecret="password"
newhash=$(slappasswd -s "$newsecret")
echo -n "$newsecret" > /root/ldap_admin_pass
chmod 0600 /root/ldap_admin_pass

echo -e "dn: olcDatabase={2}hdb,cn=config
changetype: modify
replace: olcSuffix
olcSuffix: dc=nti310,dc=local
\n
dn: olcDatabase={2}hdb,cn=config
changetype: modify
replace: olcRootDN
olcRootDN: cn=ldapadm,dc=nti310,dc=local
\n
dn: olcDatabase={2}hdb,cn=config
changetype: modify
replace: olcRootPW
olcRootPW: $newhash" > db.ldif

ldapmodify -Y EXTERNAL -H ldapi:/// -f db.ldif

#Auth restriction

echo 'dn: olcDatabase={1}monitor,cn=config
changetype: modify
replace: olcAccess
olcAccess: {0}to * by dn.base="gidNumber=0+uidNumber=0,cn=peercred,cn=external, cn=auth" read by dn.base="cn=ldapadm,dc=nti310,dc=local" read by * none' > monitor.ldif

ldapmodify -Y EXTERNAL -H ldapi:/// -f monitor.ldif

#Generates Certs

openssl req -new -x509 -nodes -out /etc/openldap/certs/nti310ldapcert.pem -keyout /etc/openldap/certs/nti310ldapkey.pem -days 365 -subj "/C=US/ST=WA/L=Seattle/O=SCC/OU=IT/CN=nti310.local"
 
chown -R ldap. /etc/openldap/certs/nti*.pem

echo -e "dn: cn=config
changetype: modify
replace: olcTLSCertificateFile
olcTLSCertificateFile: /etc/openldap/certs/nti310ldapcert.pem
\n
dn: cn=config
changetype: modify
replace: olcTLSCertificateKeyFile
olcTLSCertificateKeyFile: /etc/openldap/certs/nti310ldapkey.pem" > certs.ldif

ldapmodify -Y EXTERNAL -H ldapi:/// -f certs.ldif

#Test to see if cert config works
slaptest -u
echo "it works"

unalias cp

ldapadd -Y EXTERNAL -H ldapi:/// -f /etc/openldap/schema/cosine.ldif
ldapadd -Y EXTERNAL -H ldapi:/// -f /etc/openldap/schema/nis.ldif
ldapadd -Y EXTERNAL -H ldapi:/// -f /etc/openldap/schema/inetorgperson.ldif

#Creates group and people structure base

echo -e "dn: dc=nti310,dc=local
dc: nti310
objectClass: top
objectClass: domain
\n
dn: cn=ldapadm,dc=nti310,dc=local
objectClass: organizationalRole
cn: ldapadm
description: LDAP Manager
\n
dn: ou=People,dc=nti310,dc=local
objectClass: organizationalUnit
ou: People
\n
dn: ou=Group,dc=nti310,dc=local
objectClass: organizationalUnit
ou: Group" > base.ldif

setenforce 0

ldapadd -x -W -D "cn=ldapadm,dc=nti310,dc=local" -f base.ldif -y /root/ldap_admin_pass

systemctl restart httpd

echo "*.info;mail.none;authpriv.none;cron.none   @10.128.0.5" >> /etc/rsyslog.conf && systemctl restart rsyslog.service
