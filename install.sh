#!/bin/bash

echo "Installing basic sane environment"
sudo apt-get remove -qq nano # this makes the editor default to vi instead, my preference
sudo apt-get install -qq --no-install-recommends emacs-nox elpa-yaml-mode elpa-markdown-mode 
sudo apt-get install -qq --no-install-recommends curl wget 

echo "Installing native build tools"
sudo apt-get install -qq --no-install-recommends build-essential

echo "Installing AVR build tools"
sudo apt-get install -qq avr-libc gcc-avr gdb-avr binutils-avr
sudo apt-get install -qq avrdude

echo "Installing preconditions for avrdudess"
echo "Get the latest version of avrdudess from https://github.com/ZakKemble/AVRDUDESS/releases"
sudo apt-get install -qq mono-complete

echo "Installing OpenOCD"
sudo apt-get install -qq openocd

echo "Installing tooling for IKEA Tradfri development"
sudo apt-get install -qq gcc-arm-none-eabi

echo "Creating uninstall script"
cat install.sh | grep -v curl | sed -e 's/Install/Remov/g' -e 's/install/remove/g' > uninstall.sh
echo "sudo apt-get autoremove" >> uninstall.sh
chmod 755 uninstall.sh


