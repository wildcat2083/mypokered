#!/bin/bash

# Can Change to Needed python ex "python" "python2" "python3"
PYTHON="python2.7"

# Dependants Needed to Compile Pokemon Game
DEPS="git bison byacc flex make gcc gettext pkg-config libpng-dev $PYTHON build-essential"

# The Specific Pokemon git Repository
GITREPO="https://github.com/wildcat2083/mypokered.git"

# Current Working directory for the source code itself
WDIR="mypokered"

# Handles file ownership when running as sudo
USER="$SUDO_USER"

# Clears the screen
clear

# If sudo ./mon.sh remove is typed the script un-installs everything
if [ "$1" = "remove" ]; then
clear
echo "Deleting Game Folders and Dependants"
	if ls ./*.gbc; then
	rm -rf ./*.gbc
	fi &>/dev/null
rm -rf ./$WDIR &>/dev/null
#apt-get --purge -y remove $DEPS &>/dev/null
#apt -y autoremove &>/dev/null
clear
echo "Done!!!"
exit 0
fi

# Checks for existing folder (mypokered) if not starts downloading deps and source
if [ ! -d ./$WDIR ]; then
echo "Downloading and Installing Depends and Source"
apt update &>/dev/null
apt install -y $DEPS &>/dev/null
git clone $GITREPO &>/dev/null
fi

# Checks again for Proper Directory
if [ ! -d ./$WDIR ]; then
clear
echo "Did not download"
echo "Try Running sudo ./mon.sh"
exit 0
fi

# Check for Existing compiled rom if so delete it
if ls ./*.gbc; then
rm -rf ./*.gbc
fi &>/dev/null

# Builds the Pokemon Roms for Red and Blue Customized of course
clear
echo "Building Custom Pokemon Red/Blue ROMs"
make clean -C $WDIR &>/dev/null
make all -C $WDIR &>/dev/null

# Copies and Renames roms to current working directory
cp -rf ./$WDIR/*.gbc ./ &>/dev/null
mv pokered.gbc Pokemon\ Red.gbc # The Slash and space is intentional (Represents a space in words ex. "bite me") :P
mv pokeblue.gbc Pokemon\ Blue.gbc
chown $USER:$USER "Pokemon Red.gbc"
chown $USER:$USER "Pokemon Blue.gbc"
chown -R $USER:$USER ./$WDIR

# Finishing up
clear
echo "Done!!!"

exit 0
