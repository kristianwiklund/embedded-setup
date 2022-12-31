#!/bin/bash

echo "Creating uninstall script"
cat install.sh | grep -v uninstall | egrep "(apt-get|echo)" | grep -v pio | grep -v RIOT | grep -v pico | grep -v platformio | sed -e 's/Install/Remov/g' -e 's/install/remove/g' > uninstall.sh
echo "sudo apt-get autoremove" >> uninstall.sh
echo "echo Remove ~/pico, ~/src/RIOT, and platformio manually" >> uninstall.sh

chmod 755 uninstall.sh

#-----

echo "Installing basic environment"
sudo apt-get -qq install --no-install-recommends curl wget 
sudo apt-get -qq install python3 python3-pip python3-venv
git config --global pull.rebase false # this is how I roll

#-----
echo "Installing emacs with modes"
sudo apt-get remove -qq nano # this makes the editor default to vi instead, my preference
# no-install-recommends on emacs prevents X11 emacs from being installed. I dislike X11 emacs...
sudo apt-get -qq install --no-install-recommends emacs-nox elpa-yaml-mode elpa-markdown-mode 
touch ~/.emacs

if ! grep -Fq melpa  ~/.emacs
then
    cat >> ~/.emacs < 'END'
(add-to-list 'package-archives '("gnu" . "https://elpa.gnu.org/packages/"))
(add-to-list 'package-archives '("nongnu" . "https://elpa.nongnu.org/packages/"))
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/"))
END

emacs --eval="(progn (package-initialize)(package-install 'arduino-mode)(kill-emacs))"
   
#-----

if ! grep -Fq .local/bin  ~/.profile
then
    echo "Adding $HOME/.local/bin to path"
    echo "PATH=\$PATH:\$HOME/.local/bin" >> ~/.profile
    PATH=$PATH:$HOME/.local/bin
fi


#-----
echo "Installing native build tools"
sudo apt-get -qq install --no-install-recommends build-essential

#-----

echo "Installing AVR build tools"
sudo apt-get -qq install avr-libc gcc-avr gdb-avr binutils-avr
sudo apt-get -qq install avrdude

#-----

echo "Installing preconditions for avrdudess"
echo "Get the latest version of avrdudess from https://github.com/ZakKemble/AVRDUDESS/releases"
sudo apt-get -qq install mono-complete

#-----
echo "Installing OpenOCD"
sudo apt-get -qq install openocd

#-----

echo "Installing tooling for IKEA Tradfri development"
sudo apt-get -qq install gcc-arm-none-eabi

#-----

echo "Installing tooling for rpi pico"

# Official quick install script - which is exceptionally slow and noisy
#wget -O /tmp/pico_setup.sh https://raw.githubusercontent.com/raspberrypi/pico-setup/master/pico_setup.sh
#chmod +x /tmp/pico_setup.sh
# I do not enjoy vscode - hence not installing it
# openocd is already installed, don't run the pi install variant
#(cd ~; SKIP_OPENOCD=1 SKIP_VSCODE=1 /tmp/pico_setup.sh)
#rm -f /tmp/pico_setup.sh

# shallow clone of the pico repo
echo "...pico sdk with examples"
mkdir -p ~/pico
(cd ~/pico; git clone https://github.com/raspberrypi/pico-sdk.git --depth 1 --branch master)
(cd ~/pico/pico-sdk; git submodule update --depth 1 --init)
(cd ~/pico/; git clone https://github.com/raspberrypi/pico-examples.git --depth 1 --branch master)

echo "...pico toolchain"

sudo apt-get -qq install cmake gcc-arm-none-eabi libnewlib-arm-none-eabi build-essential libstdc++-arm-none-eabi-newlib

echo "Pico env installed to ~/pico (rpi default location)"

echo "Installing RIOT-OS to ~/src/RIOT"
mkdir -p ~/src
(cd ~/src; git clone https://github.com/RIOT-OS/RIOT.git --depth 1)
sudo apt-get -qq install graphviz graphviz-dev
sudo apt-get -qq remove python3-typing-extensions
pip3 install --quiet twisted pyserial graphviz typing-extensions


if ! [ -d ~/.platformio ]
then
    echo "Installing pio command line using convenience script"
    curl -fsSL https://raw.githubusercontent.com/platformio/platformio-core-installer/master/get-platformio.py -o get-platformio.py
    python3 get-platformio.py
    
    echo "Installing pio cli to .profile"
    if ! grep -Fq platformio ~/.profile
    then
	echo "PATH=\$PATH:\$HOME/.platformio/penv/bin" >> ~/.profile
    fi
else
    echo "Platformio already installed in ~/.platformio - Updating platformio"
    $HOME/.platformio/penv/bin/pio upgrade
fi

echo "Log out and log in to update paths!"
