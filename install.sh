#!/bin/bash
file="vh.sh"
symlink="vh"
sudo chmod +x $file
sudo cp $file /usr/bin/
sudo cp template.conf /usr/bin/
if [ -e /usr/bin/$symlink ]; then
  echo "Removing existing symlink"
  sudo rm -r /usr/bin/$symlink
fi
sudo ln -s /usr/bin/$file /usr/bin/$symlink
if [ $? -eq 0 ]; then
  echo "Installed vh :)"
else
  echo "Installation of vh failed :("
fi

file="vhu.sh"
symlink="vhu"
sudo chmod +x $file
sudo cp $file /usr/bin/
sudo cp template.conf /usr/bin/
if [ -e /usr/bin/$symlink ]; then
  echo "Removing existing symlink"
  sudo rm -r /usr/bin/$symlink
fi
sudo ln -s /usr/bin/$file /usr/bin/$symlink
if [ $? -eq 0 ]; then
  echo "Installed vhu :)"
else
  echo "Installation of vhu failed :("
fi
