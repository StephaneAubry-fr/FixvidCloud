#!/bin/bash
wget -O- https://www.virtualbox.org/download/oracle_vbox_2016.asc | \
gpg --dearmor | \
tee /usr/share/keyrings/oracle-virtualbox-2016.gpg > /dev/null

gpg --no-default-keyring \
--keyring /usr/share/keyrings/oracle-virtualbox-2016.gpg \
--fingerprint

echo "deb [arch=amd64 signed-by=/usr/share/keyrings/oracle-virtualbox-2016.gpg] \
https://download.virtualbox.org/virtualbox/debian $(lsb_release -cs) contrib" | \
tee /etc/apt/sources.list.d/virtualbox.list

apt-get update
apt-get install -y virtualbox-7.1