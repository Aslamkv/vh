#!/bin/bash
create (){
  user="$(whoami)"
  script=`basename "$0"`
  path=`dirname "$0"`/.$script
  site=$1

  if [ ! -f "$path/template.conf" ]; then
    echo 'Missing template.conf' $path
    exit;
  fi

  echo "Creating VirtualHost $site for $user"

  if [ -d "/var/www/html/$site" ] || [ -f "etc/apache2/sites-available/$site.conf" ]; then
    read -p "Do you want to replace exisiting site $site? (y/n) " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Nn]$ ]]; then
      echo "Creation cancelled"
      exit;
    fi
  fi

  while :
  do
    ip="127.$(($RANDOM % 255)).$(($RANDOM % 255)).$(($RANDOM % 255))"
    if ! grep -Fq $ip /etc/hosts; then
      break;
    fi
  done
  echo "Binding $site with generated ip $ip"

  cp $path/template.conf $path/$site.conf
  sed -i -e "s/\$template/$site/g" $path/$site.conf
  echo "LocalPath /var/www/html/$site/"
  sudo mv $path/$site.conf /etc/apache2/sites-available/
  if [ ! -d "/var/www/html/$site" ]; then
    sudo mkdir /var/www/html/$site
  fi
  sudo chown -R $user:www-data /var/www/html/$site
  sudo chmod -R 775 /var/www/html/$site
  sudo a2ensite $site.conf
  sudo sed -i -e "s/^.*www\.$site.*$//g" /etc/hosts
  sudo sh -c "echo \"$ip $site www.$site #vh\" >> /etc/hosts"
  sudo service apache2 restart
  if [ $? -eq 0 ]; then
    echo ''>/var/www/html/$site/index.php
    if [ ! -z "$GDMSESSION" ]; then
      nautilus "/var/www/html/$site/"
      if [ -x "$(command -v atom)" ]; then
        echo "Launching atom with $site"
        atom "/var/www/html/$site/"
      fi
      if [ -x "$(command -v firefox)" ]; then
        echo "Launching firefox with $site"
        firefox -private -url "$site"
      fi
    fi
    echo "Successfully configured VirtualHost $site with local ip $ip"
  else
    echo "VirtualHost configuration failed!"
  fi
}

remove (){
  user="$(whoami)"
  path="$(pwd)"
  sites=`cat /etc/hosts | grep .*\#vh$ | sed 's/^[0-9\.\ \t]*//' | sed 's/www\..*$//'`
  if [ ${#sites} -lt 1 ]; then
    echo "No websites found"
    exit;
  fi

  echo "Installed websites"
  echo -e "$sites"
  echo ""

  echo "Uninstalling VirtualHost for $user"
  echo "Enter website name"
  read site

  if [ ${#site} -lt 1 ]; then
    echo "Website name cannot be empty!"
    exit;
  fi

  if [ ! -f /etc/apache2/sites-available/$site.conf ] || [ ! -d /var/www/html/$site ]; then
    echo -e "\n$site is not installed using vh :("
    exit
  fi

  echo "Removing Apache config for $site.conf"
  sudo a2dissite $site.conf
  sudo rm -f /etc/apache2/sites-available/$site.conf

  if [ -d "/var/www/html/$site" ]; then
    read -p "Do you want to remove LocalPath /var/www/html/$site? (y/n) " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
      echo "Removing LocalPath /var/www/html/$site/"
      sudo rm -r /var/www/html/$site
    fi
  fi

  echo "Removing $site from /etc/hosts"
  sudo sed -i -e "s/^.*www\.$site.*$//g" /etc/hosts
  sudo service apache2 restart

  if [ $? -eq 0 ]; then
    echo "Successfully uninstalled VirtualHost $site"
  else
    echo "Uninstalling VirtualHost $site failed!"
  fi
}

if [ "$1" == "create" ]; then
  site=$2
  if [ ${#site} -lt 1 ]; then
    echo "Website name cannot be empty!"
    exit;
  fi
  create $site
  exit;
fi
if [ "$1" == "remove" ]; then
  remove
  exit;
fi

echo "Usage"
echo "Create: vh create <website_name>"
echo "Remove: vh remove"
