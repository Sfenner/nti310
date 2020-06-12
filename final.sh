#!/bin/bash

#syslog
gcloud compute instances create rsyslog-server2 \
--image-family centos-7 \
--image-project centos-cloud \
--zone us-central1-a \
--machine-type f1-micro \
--scopes cloud-platform \
--metadata-from-file startup-script=/home/sfenner89/nti310/logsrv.sh \
--private-network-ip=10.128.0.31

sleep 20s


#LDAP
gcloud compute instances create ldap2 \
--image-family centos-7 \
--image-project centos-cloud \
--zone us-central1-a \
--tags "http-server","https-server" \
--machine-type f1-micro \
--scopes cloud-platform \
--metadata-from-file startup-script=/home/sfenner89/nti310/LDAP-automated.sh \
--private-network-ip=10.128.0.30

sleep 20s


#postgres server
gcloud compute instances create postgres1 \
--image-family centos-7 \
--image-project centos-cloud \
--zone us-central1-a \
--tags "http-server","https-server" \
--machine-type f1-micro \
--scopes cloud-platform \
--metadata-from-file startup-script=/home/sfenner89/nti310/postgres.sh \
--private-network-ip=10.128.0.29

sleep 20s


#Django
gcloud compute instances create django2 \
--image-family centos-7 \
--image-project centos-cloud \
--zone us-central1-a \
--tags "http-server","https-server" \
--machine-type f1-micro \
--scopes cloud-platform \
--metadata-from-file startup-script=/home/sfenner89/nti310/django.sh \
--private-network-ip=10.128.0.28

sleep 20s

#nfs server
gcloud compute instances create nfs2 \
--image-family centos-7 \
--image-project centos-cloud \
--zone us-central1-a \
--machine-type f1-micro \
--scopes cloud-platform \
--metadata-from-file startup-script=/home/sfenner89/nti310/nfsserver.sh \
--private-network-ip=10.128.0.27

#sleep for 30s allowing servers to boot before clients
sleep 30s

#ldapandnsfclient1
gcloud compute instances create ldapandnsfclient1 \
--image-family ubuntu-1804-lts \
--image-project gce-uefi-images  \
--zone us-central1-a \
--machine-type f1-micro \
--scopes cloud-platform \
--metadata-from-file startup-script=/home/sfenner89/nti310/ldap_client.sh \
--private-network-ip=10.128.0.26

#ubuntu with ldap and nsf
gcloud compute instances create ldapandnsfclient2 \
--image-family ubuntu-1804-lts \
--image-project gce-uefi-images  \
--zone us-central1-a \
--machine-type f1-micro \
--scopes cloud-platform \
--metadata-from-file startup-script=/home/sfenner89/nti310/ldap_client.sh \
--private-network-ip=10.128.0.25

sleep 20

#nagiosserver
gcloud compute instances create nagios server \
--image-family centos-7 \
--image-project centos-cloud \
--zone us-central1-a \
--machine-type f1-micro \
--scopes cloud-platform
--metadata-from-file startup-script=/home/sfenner89/NTI-320/nagios.sh \
--private-network-ip=10.128.0.24

sleep 20s

#cactiserver
gcloud compute instances create cacti server \
--image-family centos-7 \
--image-project centos-cloud \
--zone us-central1-a \
--machine-type f1-micro \
--scopes cloud-platform
--metadata-from-file startup-script=/home/sfenner89/NTI-320/cactiserver.sh \
--private-network-ip=10.128.0.23
