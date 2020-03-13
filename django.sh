#!/bin/bash
#fun django tutorial https://data-flair.training/blogs/django-migrations-and-database-connectivity/

yum -y install python-pip python-devel gcc postgresql-devel postgresql-contrib
pip install --upgrade pip
pip install virtualenv
mkdir /opt/nti310
cd /opt/nti310
virtualenv nti310env
source nti310env/bin/activate
pip install django psycopg2
django-admin.py startproject nti310 .
#vim /opt/nti310/nti310/setting.py
perl -i -0pe "BEGIN{undef $/;} s/        'ENGINE':.*db.sqlite3'\),/        'ENGINE': 'django.db.backends.postgresql_psycopg2',\n        'NAME': 'nti310',\n        'USER': 'nti310user',\n        'PASSWORD': 'password',\n        'HOST': 'postgres',\n        'PORT': '5432',/smg" /opt/nti310/nti310/settings.py
