#!/usr/bin/env bash

# ************************************************************
# *        Maintains debian/jessie64 Operating System        *
# ************************************************************

# ********************  Basic Operations  ********************
# Fixes broken dependencies
sudo apt-get -f install
# Removes unnecessary packages
sudo apt-get -y autoremove
# Cleans repository cache
sudo apt-get clean all
# Update packages
sudo apt-get -y update
# Upgrade packages
sudo apt-get -y upgrade
# ************************************************************
