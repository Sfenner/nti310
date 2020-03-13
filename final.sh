
#syslog
gcloud compute instances create rsyslog-server2 \
--image-family centos-7 \
--image-project centos-cloud \
--zone us-central1-a \
--tags "http-server","https-server" \
--machine-type f1-micro \
--scopes cloud-platform \
--metadata-from-file startup-script=/home/sfenner89/nti310/logsrv.sh \
--private-network-ip=10.128.0.5

#postgres server
gcloud compute instances create LDAP2 \
--image-family centos-8 \
--image-project centos-cloud \
--zone us-central1-a \
--tags "http-server","https-server" \
--machine-type f1-micro \
--scopes cloud-platform \
--metadata-from-file startup-script=/home/sfenner89/nti310/postgres_on_centos8.sh\
--private-network-ip=10.128.0.12

#LDAP
gcloud compute instances create ldap2 \
--image-family centos-7 \
--image-project centos-cloud \
--zone us-central1-a \
--tags "http-server","https-server" \
--machine-type f1-micro \
--scopes cloud-platform \
--metadata-from-file startup-script=/home/sfenner89/nti310/LDAP-automated.sh \
--private-network-ip=10.128.0.7

#Django
gcloud compute instances create django2 \
--image-family centos-7 \
--image-project centos-cloud \
--zone us-central1-a \
--tags "http-server","https-server" \
--machine-type f1-micro \
--scopes cloud-platform \
--metadata-from-file startup-script=/home/sfenner89/nti310/django.sh \
--private-network-ip=10.128.0.8

#nfs server
gcloud compute instances create nfs2 \
--image-family centos-7 \
--image-project centos-cloud \
--zone us-central1-a \
--tags "http-server","https-server" \
--machine-type f1-micro \
--scopes cloud-platform \
--metadata-from-file startup-script=/home/sfenner89/nti310/nfsserver.sh \
--private-network-ip=apt-get install nfs-client



#ldapandnsfclient1
gcloud compute instances create ldapandnsfclient1 \
--image-family ubuntu 18.0.4 \
--image-project centos-cloud \
--zone us-central1-a \
--tags "http-server","https-server" \
--machine-type f1-micro \
--scopes cloud-platform \
--metadata-from-file startup-script=/home/sfenner89/nti310/ldap_client.sh \
--private-network-ip=10.128.0.13

#ubuntu with ldap and nsf
gcloud compute instances create ldapandnsfclient2 \
--image-family ubuntu 18.0.4 \
--image-project centos-cloud \
--zone us-central1-a \
--tags "http-server","https-server" \
--machine-type f1-micro \
--scopes cloud-platform \
--metadata-from-file startup-script=/home/sfenner89/nti310/ldap_client.sh \
--private-network-ip=10.128.0.16

