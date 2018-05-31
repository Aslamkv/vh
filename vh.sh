#!/bin/bash
user="$(whoami)"
path="$(pwd)"
echo "Creating VirtualHost for $user"
echo "Enter website name"
read site
echo "Enter local IP"
read ip
sudo cp /usr/bin/template.conf $path/$site.conf
sudo sed -i -e "s/\$template/$site/g" $path/$site.conf
echo "LocalPath /var/www/html/$site/"
sudo mv $path/$site.conf /etc/apache2/sites-available/
if [ ! -d "/var/www/html/$site" ]; then
  sudo mkdir /var/www/html/$site
fi
sudo chown -R $user:$user /var/www/html/$site
sudo chmod -R 775 /var/www/html/$site
sudo a2ensite $site.conf
sudo sed -i -e "s/^.*www\.$site\.com.*$//g" /etc/hosts
sudo sh -c "echo \"$ip $site.com www.$site.com\" >> /etc/hosts"
sudo service apache2 restart
if [ $? -eq 0 ]; then
  echo "Successfully configured VirtualHost $site with local ip $ip"
  nautilus "/var/www/html/$site/"
  if [ -x "$(command -v atom)" ]; then
    echo "Launching atom with $site"
    atom "/var/www/html/$site/"
  fi
  if [ -x "$(command -v firefox)" ]; then
    echo "Launching firefox with $site"
    firefox -private -url "$site.com"
  fi
else
  echo "VirtualHost configuration failed!"
fi
