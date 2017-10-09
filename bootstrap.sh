#!/usr/bin/env bash

# some flags and options to run provision without stdin prompts
debconf-set-selections <<< 'mysql-server mysql-server/root_password password root'
debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password root'

apt-get update -q
apt-get install -q -y redis-server
apt-get install -q -y mysql-server
apt-get install -q -y nginx

# @see http://docs.translatehouse.org/projects/pootle/en/latest/server/requirements.html#requirements-packages
apt-get install -q -y build-essential libxml2-dev libxslt-dev python-dev python-pip zlib1g-dev

# @see http://docs.translatehouse.org/projects/pootle/en/latest/server/requirements.html#system-requirements-for-customising-static-resources
apt-get install -q -y nodejs npm
update-alternatives --install /usr/bin/node node /usr/bin/nodejs 99

# @see http://docs.translatehouse.org/projects/pootle/en/latest/server/installation.html#setting-up-the-virtual-environment
apt-get install -q -y python-virtualenv
cd /vagrant
virtualenv env
source env/bin/activate

# dont run pip install as root on production machines!
pip install --upgrade pip setuptools
# --pre --process-dependency-links = install alpha/beta/rc
pip install Pootle

# additional modules
apt-get install -q -y python-mysqldb
apt-get install -q -y libmysqlclient-dev
pip install MySQL-python
# this does not work
# pip install --pre --process-dependency-links Pootle[git]
pip install django-tastypie

# add www-data user to ubuntu group and vice versa to avoid permission issues
adduser www-data ubuntu
adduser ubuntu www-data

# configurations
rm -f /etc/mysql/mysql.conf.d/99-local.cnf
cp /vagrant/config/mysql/my.cnf /etc/mysql/mysql.conf.d/99-local.cnf
cp /vagrant/config/nginx/default.conf /etc/nginx/sites-enabled/default

# make sure services are running with current configurations
systemctl restart redis-server.service
systemctl restart mysql.service
systemctl restart nginx.service

# provision mysql
CHECK_MYSQL_USER=$(mysql --user="root" --password="root" -N -e "SELECT EXISTS(SELECT * FROM mysql.user WHERE user = 'pootle')")
if [ $CHECK_MYSQL_USER != "1" ]; then
    mysql --user="root" --password="root" -e "CREATE DATABASE pootle DEFAULT CHARACTER SET utf8 DEFAULT COLLATE utf8_general_ci"
    mysql --user="root" --password="root" -e "CREATE USER 'pootle'@'localhost' identified by 'wFF9FApowMIMDoR74yFNZg=='"
    mysql --user="root" --password="root" -e "GRANT ALL PRIVILEGES ON pootle.* TO 'pootle'@'%' IDENTIFIED BY 'wFF9FApowMIMDoR74yFNZg=='"
    mysql_tzinfo_to_sql /usr/share/zoneinfo | mysql --user="root" --password="root" mysql
fi

# init pootle
if [ ! -f /vagrant/env/pootle.conf ]; then
    pootle init
fi
# use correct config
rm -f /vagrant/env/pootle.conf
ln -s /vagrant/config/pootle/pootle.conf /vagrant/env/pootle.conf
rm -f /vagrant/env/lib/python2.7/site-packages/pootle/urls.py
ln -s /vagrant/config/pootle/urls.py /vagrant/env/lib/python2.7/site-packages/pootle/urls.py
rm -f /vagrant/env/lib/python2.7/site-packages/pootle/api
ln -s /vagrant/api /vagrant/env/lib/python2.7/site-packages/pootle/.
# start pootle background worker
pootle rqworker &
pootle migrate
CHECK_MYSQL_POOTLE=$(mysql --user="pootle" --password="wFF9FApowMIMDoR74yFNZg==" pootle -N -e "SELECT COUNT(*) FROM pootle_app_language")
if [ $CHECK_MYSQL_POOTLE = "0" ]; then
    pootle initdb
fi

# start pootle server
# this command will not be invoked! you have to start the server manually...
# nostatic = static files will be served by nginx
# noreload = dont check python files for changes (decrease cpu usage)
pootle runserver --nostatic --noreload &
