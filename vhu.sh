#!/bin/bash
user="$(whoami)"
path="$(pwd)"
sites=`cat /etc/hosts | grep www.* | sed 's/^[0-9\.\ \t]*//' | sed 's/www\..*$//'`
echo "Uninstalling VirtualHost for $user"
echo "---------sites--installed---------"
echo -e "$sites"
echo "----------------------------------"

echo "Enter website name"
read site

if [[ $a != *"waves.com "* ]]; then
  echo -e "\n$site is not installed using vh :("
  exit
fi

echo "Removing Apache config for $site.conf"
sudo a2dissite $site.conf
sudo rm -f /etc/apache2/sites-available/$site.conf

if [ -d "/var/www/html/$site" ]; then
  echo "Removing LocalPath /var/www/html/$site/"
  sudo rm -r /var/www/html/$site
fi

echo "Removing $site from /etc/hosts"
sudo sed -i -e "s/^.*www\.$site.*$//g" /etc/hosts
sudo service apache2 restart

if [ $? -eq 0 ]; then
  echo "Successfully uninstalled VirtualHost $site"
else
  echo "Uninstalling VirtualHost failed!"
fi
