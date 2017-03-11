#!/usr/bin/env bash

# ************************************************************
# *        Maintains debian/jessie64 Operating System        *
# ************************************************************

# ********************  Adds Dotdeb repository  ****************************************
echo "deb http://packages.dotdeb.org jessie all" >> /etc/apt/sources.list;
echo "deb-src http://packages.dotdeb.org jessie all" >> /etc/apt/sources.list;

# Fetch and install the Dotdeb repository GnuPG key
wget -qO- https://www.dotdeb.org/dotdeb.gpg | sudo apt-key add -;
# **************************************************************************************

# ********************   Adds mysql 5.7 repository  ************************************
echo "deb http://repo.mysql.com/apt/debian jessie mysql-5.7" >> /etc/apt/sources.list;

# Fetch and install mysql GPG key
sudo apt-key adv --keyserver pgp.mit.edu --recv-keys 5072E1F5
# **************************************************************************************

# ********************  Basic Operations  **********************************************
# Fixes broken dependencies
sudo apt-get -f install;
# Removes unnecessary packages
sudo apt-get -y autoremove;
# Cleans repository cache
sudo apt-get clean all;
# Update packages
sudo apt-get -y update;
# Upgrade packages
sudo apt-get -y upgrade;
# **************************************************************************************

# Installs nginx web server
sudo apt-get -y install nginx;

# Installs php7.0 and packages
sudo apt-get -y install php7.0 php7.0-fpm php7.0-cli \
                        php7.0-curl php7.0-gd php7.0-json php7.0-mcrypt php7.0-mbstring;

# Installs mysql-server 5.7
echo "mysql-server mysql-community-server/root-pass password root" | sudo debconf-set-selections;
echo "mysql-server mysql-community-server/re-root-pass password root" | sudo debconf-set-selections;
sudo apt-get -y install mysql-server;

# Installs handy utilities
sudo apt-get -y install htop pcregrep siege;
# **************************************************************************************

# Configures php7.0
sudo rm -f "/etc/php/7.0/fpm/pool.d/www.conf";
sudo mv "/tmp/php-fpm.conf" "/etc/php/7.0/fpm/php-fpm.conf";
sudo mv "/tmp/php-pool-html.conf" "/etc/php/7.0/fpm/pool.d/html.conf";

# Configures nginx web server
sudo rm -f "/etc/nginx/sites-available/default";
sudo rm -f "/etc/nginx/sites-enabled/default";
sudo mv "/tmp/nginx-html.conf" "/etc/nginx/sites-available/html.conf";
cd "/etc/nginx/sites-enabled";
sudo ln -s "../sites-available/html.conf";
# **************************************************************************************

# Restart services
sudo systemctl restart php7.0-fpm.service;
sudo systemctl restart nginx.service;
sudo systemctl restart mysql.service;
# **************************************************************************************
