#!/usr/bin/env bash

# ************************************************************
# *        Maintains debian/jessie64 Operating System        *
# ************************************************************

# ********************  Manage repositories  ****************************************
REPOSITORIES="
# Debian jessie repositories
deb http://httpredir.debian.org/debian jessie main
deb-src http://httpredir.debian.org/debian jessie main

deb http://security.debian.org/ jessie/updates main
deb-src http://security.debian.org/ jessie/updates main

# Repository for php7.0
deb http://packages.dotdeb.org jessie all
deb-src http://packages.dotdeb.org jessie all

# Repository for mysql-server 5.7
deb http://repo.mysql.com/apt/debian jessie mysql-5.7

# Repository for PostgreSQL 9.6
deb http://apt.postgresql.org/pub/repos/apt/ jessie-pgdg main

";

# Add repositories to sources.list
printf "$REPOSITORIES" > /etc/apt/sources.list;

# Fetches and installs the Dotdeb repository GnuPG key
wget -qO- https://www.dotdeb.org/dotdeb.gpg | sudo apt-key add -;

# Fetches and installs mysql GPG key
sudo apt-key adv --keyserver pgp.mit.edu --recv-keys 5072E1F5

# Imports PostgreSQL 9.6 repository signing key
wget -qO- https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -;
# **************************************************************************************

# ********************  Basic Operations  **********************************************
# Fixes broken dependencies
sudo apt -f install;
# Removes unnecessary packages
sudo apt-get -y autoremove;
# Cleans repository cache
sudo apt-get clean all;
# Update packages
sudo apt -y update;
# Upgrade packages
sudo apt -y upgrade;
# **************************************************************************************

# Installs dependent packages
sudo apt install zlib1g-dev;

# Installs handy utilities
sudo apt -y install htop pcregrep unzip siege;

# Installs nginx web server
sudo apt -y install nginx;

# Installs php7.0 and packages
sudo apt -y install php7.0 php7.0-fpm php7.0-cli php7.0-xdebug \
                        php7.0-curl php7.0-gd php7.0-json php7.0-mcrypt php7.0-mbstring php7.0-mysql php7.0-pgsql;
# **************************************************************************************

# Configures nginx web server
if [ -f /etc/nginx/sites-available/default ]; then
    sudo rm -f "/etc/nginx/sites-available/default";
    sudo rm -f "/etc/nginx/sites-enabled/default";
fi

sudo mv "/tmp/nginx-html.conf" "/etc/nginx/sites-available/html.conf";
sudo mv "/tmp/nginx-symfony.conf" "/etc/nginx/sites-available/symfony.conf";
sudo mv "/tmp/nginx-yii.conf" "/etc/nginx/sites-available/yii.conf";

if [ ! -f /etc/nginx/sites-enabled/html.conf ]; then
    sudo ln -s "../sites-available/html.conf" "/etc/nginx/sites-enabled/";
fi

if [ ! -f /etc/nginx/sites-enabled/symfony.conf ]; then
    sudo ln -s "../sites-available/symfony.conf" "/etc/nginx/sites-enabled/";
fi

if [ ! -f /etc/nginx/sites-enabled/yii.conf ]; then
    sudo ln -s "../sites-available/yii.conf" "/etc/nginx/sites-enabled/";
fi
# **************************************************************************************

# Configures php7.0
if [ -f /etc/php/7.0/fpm/pool.d/www.conf ]; then
    sudo rm -f "/etc/php/7.0/fpm/pool.d/www.conf";
fi

sudo mv "/tmp/php-fpm.conf" "/etc/php/7.0/fpm/php-fpm.conf";
sudo mv "/tmp/php-pool-html.conf" "/etc/php/7.0/fpm/pool.d/html.conf";
# **************************************************************************************

# Installs mysql-server 5.7, phpMyAdmin 4.6.6 and configures it
echo "mysql-community-server mysql-community-server/data-dir select ''" | sudo debconf-set-selections;
echo "mysql-server mysql-community-server/root-pass password root" | sudo debconf-set-selections;
echo "mysql-server mysql-community-server/re-root-pass password root" | sudo debconf-set-selections;
sudo apt -y install mysql-server;

sudo mv "/tmp/nginx-pma.conf" "/etc/nginx/sites-available/pma.conf";

if [ ! -f /etc/nginx/sites-enabled/pma.conf ]; then
    sudo ln -s "../sites-available/pma.conf" "/etc/nginx/sites-enabled/";
fi

if [ ! -d /usr/share/phpMyAdmin ]; then
    wget -O /tmp/pma.zip https://files.phpmyadmin.net/phpMyAdmin/4.7.0/phpMyAdmin-4.7.0-all-languages.zip;
    sudo unzip -d /tmp/pma /tmp/pma.zip;
    sudo mv /tmp/pma/* /usr/share/phpMyAdmin;
    sudo rm -rf /tmp/pma*;
fi
# **************************************************************************************

# Installs PostgreSQL 9.6, phpPgAdmin 5.1 and configures pga virtual host
sudo apt -y install postgresql phppgadmin;

sudo mv "/tmp/nginx-pga.conf" "/etc/nginx/sites-available/pga.conf";

if [ ! -f /etc/nginx/sites-enabled/pga.conf ]; then
    sudo ln -s "../sites-available/pga.conf" "/etc/nginx/sites-enabled/";
fi
# **************************************************************************************

# Installs python3.6
if [ ! -f /usr/local/bin/python3.6 ]; then
    mkdir -p /home/vagrant/Downloads/python3.6;
    wget -O /home/vagrant/Downloads/python3.6.tar.xz https://www.python.org/ftp/python/3.6.1/Python-3.6.1.tar.xz;
    tar -xf /home/vagrant/Downloads/python3.6.tar.xz -C /home/vagrant/Downloads/python3.6;
    cd /home/vagrant/Downloads/python3.6/Python-3.6.1;
    ./configure;
    make altinstall;
    rm /home/vagrant/Downloads/python3.6.tar.xz;
fi
# **************************************************************************************

# Restart services
sudo systemctl restart php7.0-fpm.service;
sudo systemctl restart nginx.service;
sudo systemctl restart mysql.service;
sudo systemctl restart postgresql.service
# **************************************************************************************

# CREATES PostgreSQL user admin (password admin) and grants all privileges on database called admin
sudo -u postgres psql -c "CREATE DATABASE admin ENCODING 'UTF8' LC_COLLATE='en_US.UTF-8' LC_CTYPE = 'en_US.UTF-8'" 2> /dev/null;
sudo -u postgres psql -c "CREATE ROLE admin WITH LOGIN PASSWORD 'admin'" 2> /dev/null;
sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE admin TO admin" 2> /dev/null;
# **************************************************************************************
