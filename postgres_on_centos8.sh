#!/bin/bash
sudo su
yum -y install python2-pip python3-pip python2-devel python3-devel gcc postgresql-server postgresql-devel postgresql-contrib

postgresql-setup initdb

systemctl start postgreql

sed -i 's,host    all             all             127.0.0.1/32            ident,host    all             all             127.0.0.1/32            md5,g' /var/lib/pgsql/data/pg_hba.conf
sed -i 's,host    all             all             ::1/128                 ident,host    all             all             ::1/128                 md5,g' /var/lib/pgsql/data/pg_hba.conf


systemctl restart postgresql

systemctl enable postgresql

echo "alter user postgres superuser;
CREATE DATABASE nti310;
CREATE USER nti310user WITH PASSWORD 'password';
ALTER ROLE nti310user SET client_encoding TO 'utf8';
ALTER ROLE nti310user SET default_transaction_isolation TO 'read committed';
ALTER ROLE nti310user SET timezone TO 'UTC';
GRANT ALL PRIVILEGES ON DATABASE nti310 TO nti310user;" > /tmp/tempfile

sudo -u postgres /bin/psql -f /tmp/tempfil

yum -y install httpd

systemctl enable httpd
systemctl start httpd
yum install -y mod_ssl

setsebool -P httpd_can_network_connect on
setsebool -P httpd_can_network_connect_db on

 sudo yum install -y php php-pgsql


sed -i "s/#listen_addresses = 'localhost'/listen_addresses = '*'/g" /var/lib/pgsql/data/postgresql.conf          # take traffic from anywhere not just localhost
sed -i 's/#port = 5432/port = 5432/g' /var/lib/pgsql/data/postgresql.conf 

echo "CREATE USER pgdbuser CREATEDB ENCRYPTED PASSWORD 'pgdbpass';                                               # password
CREATE DATABASE mypgdb OWNER pgdbuser;
GRANT ALL PRIVILEGES ON DATABASE mypgdb TO pgdbuser;" > /tmp/phpmyadmin

sudo -u postgres /bin/psql -f /tmp/phpmyadmin

yum -y install https://download.postgresql.org/pub/repos/yum/10/redhat/rhel-8-x86_64/phpPgAdmin-5.6-11.rhel8.noarch.rpm

systemctl restart httpd

sed -i 's/Require local/Require all granted/g' /etc/httpd/conf.d/phpPgAdmin.conf
sed -i 's/Deny from all/Allow from all/g' /etc/httpd/conf.d/phpPgAdmin.conf                                   #only do behind firewall in actual production
sed -i "s/$conf\['servers'\]\[0\]\['host'\] = '';/$conf['servers'][0]['host'] = 'localhost';/g" /etc/phpPgAdmin/config.inc.php-dist
sed -i "s/$conf\['owned_only'\] = false;/$conf['owned_only'] = true;/g" /etc/phpPgAdmin/config.inc.php-dist
cp /etc/phpPgAdmin/config.inc.php-dist /etc/phpPgAdmin/config.inc.php

systemctl restart httpd
systemctl restart postgresql

sed -i "s/host    all             all             127.0.0.1\/32            md5/host    all             all             0.0.0.0\/0               md5/g" /var/lib/pgsql/data/pg_hba.conf

#make sure your user has full permissions:
echo "alter user nti310user createdb;" > /tmp/authfile
sudo -u postgres /bin/psql -f /tmp/authfile

#change ownership of the NTI310 db
echo "ALTER DATABASE nti310 OWNER
TO nti310user; " > /tmp/changeowner
sudo -u postgres /bin/psql -f /tmp/changeowner

#from django
python manage.py startapp Cars
echo "class Specs(models.Model):
    name = models.CharField(max_length = 20)
    price = models.DecimalField(max_digits=8, decimal_places=2)
    weight = models.PositiveIntegerField()" >> Cars/models.py
  
# put sed into the INSTALLED_APPS variable
sed -i "40i \ \ \ \ 'Cars'," nti310/settings.py

python manage.py makemigrations Cars
python manage.py migrate Cars
echo "from django.contrib.auth import get_user_model; User = get_user_model(); User.objects.create_superuser('admin', 'admin@newproject.com','NTI300NTI300')" | python manage.py shell   
python manage.py runserver 0.0.0:8000
python manage.py makemigrations
python manage.py migrate

echo "*.info;mail.none;authpriv.none;cron.none   @10.128.0.35" >> /etc/rsyslog.conf && systemctl restart rsyslog.service
