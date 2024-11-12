#!/bin/bash
################################################################################
# Script for installing Odoo 18 on Ubuntu 24.04
# Author: Adapted from Yenthe666's script
################################################################################

## Update and upgrade
echo -e "\n---- Update and Upgrade ----"
sudo apt update && sudo apt upgrade -y

## Install required dependencies
echo -e "\n---- Install Python, pip, and necessary libraries ----"
sudo apt install python3 python3-pip build-essential wget git python3-dev libxml2-dev libxslt1-dev zlib1g-dev libsasl2-dev libldap2-dev libssl-dev libjpeg-dev libjpeg8-dev libpng-dev libpq-dev libffi-dev libblas-dev libatlas-base-dev libatlas3-base -y

## Install and configure PostgreSQL
echo -e "\n---- Install PostgreSQL ----"
sudo apt install postgresql postgresql-client -y

echo -e "\n---- Creating PostgreSQL User ----"
sudo -u postgres createuser -s odoo

## Download Odoo 18
echo -e "\n---- Downloading Odoo 18 ----"
sudo git clone https://www.github.com/odoo/odoo --depth 1 --branch 18.0 --single-branch /odoo/odoo-server

## Install Python requirements
echo -e "\n---- Installing Python Requirements ----"
sudo pip3 install -r /odoo/odoo-server/requirements.txt

## Create Odoo user
echo -e "\n---- Creating Odoo System User ----"
sudo adduser --system --home=/odoo --group odoo

## Create custom addons directory
echo -e "\n---- Create Custom Addons Directory ----"
sudo mkdir /odoo/custom/addons
sudo chown -R odoo: /odoo/custom/addons

## Set permissions
echo -e "\n---- Setting Permissions ----"
sudo chown -R odoo: /odoo/*
sudo chmod 755 -R /odoo/*

## Create server config file
echo -e "\n---- Create Odoo Config File ----"
sudo cp /odoo/odoo-server/debian/odoo.conf /etc/odoo.conf
sudo chown odoo: /etc/odoo.conf
sudo chmod 640 /etc/odoo.conf

# Edit the configuration file
sudo tee -a /etc/odoo.conf > /dev/null <<EOT
[options]
   ; Add custom addons path
   addons_path = /odoo/odoo-server/addons,/odoo/custom/addons
   admin_passwd = admin_password_here
   db_host = False
   db_port = False
   db_user = odoo
   db_password = False
   logfile = /var/log/odoo/odoo.log
EOT

## Create a log directory
echo -e "\n---- Create Log Directory ----"
sudo mkdir /var/log/odoo
sudo chown odoo:root /var/log/odoo

## Configure systemd for Odoo
echo -e "\n---- Configuring Odoo as a Service ----"
sudo tee /etc/systemd/system/odoo.service > /dev/null <<EOF
[Unit]
Description=Odoo
Documentation=http://www.odoo.com
[Service]
# Ubuntu service
Type=simple
User=odoo
ExecStart=/odoo/odoo-server/odoo-bin -c /etc/odoo.conf
[Install]
WantedBy=default.target
EOF

echo -e "\n---- Start Odoo Service ----"
sudo systemctl enable odoo
sudo systemctl start odoo

echo -e "\n---- Odoo 18 Installation Complete ----"
echo "You can access your Odoo instance at http://<your_server_IP>:8069"
