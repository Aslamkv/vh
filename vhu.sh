#!/bin/bash
user="$(whoami)"
path="$(pwd)"
echo "Uninstalling VirtualHost for $user"
echo "Enter website name"
read site

echo "Removing Apache config fot $site.conf"
sudo a2dissite $site.conf
sudo rm -f /etc/apache2/sites-available/$site.conf

if [ -d "/var/www/html/$site" ]; then
  echo "Removing LocalPath /var/www/html/$site/"
  sudo rm -r /var/www/html/$site
fi

echo "Removing $site from /etc/hosts"
sudo sed -i -e "s/^.*www\.$site\.com.*$//g" /etc/hosts
sudo service apache2 restart

if [ $? -eq 0 ]; then
  echo "Successfully uninstalled VirtualHost $site"
else
  echo "Uninstalling VirtualHost failed!"
fi
