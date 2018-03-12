#!/bin/bash

# TODO: Default: supress output, if --verbose don't supress output

#
# If the user is not root abort
# Source: https://stackoverflow.com/a/21372328
#
if [[ $(id -u) != 0 ]]; then
  echo "Please run as root"
  exit
fi

outputDirectory=$1
if [ ! -d $outputDirectory ]; then
  echo "Error: The specified output directory does not exist."
  exit
fi

installerDirectory=$PWD

echo "This sript will install an AssaultCube lua server with wesen's gema mod to $outputDirectory. Continue? (Yes|No)"
read continueInstallation;

#
# Convert user input to lowercase
# Source: https://stackoverflow.com/a/11392488
#
continueInstallation=$(echo "$continueInstallation" | tr '[:upper:]' '[:lower:]')

if [ "$continueInstallation" != "yes" ] && [ "$continueInstallation" != "y" ]; then
  exit
fi


cd "$outputDirectory"
mkdir "tmp"

apt-get update

# Install AssaultCube
echo "Installing AssaultCube server dependencies"
apt-get install -y libsdl1.2debian

echo "Downloading AssaultCube"
wget https://github.com/assaultcube/AC/releases/download/v1.2.0.2/AssaultCube_v1.2.0.2.tar.bz2 -P "tmp"

echo "Extracting AssaultCube"
tar -xvf tmp/AssaultCube_v1.2.0.2.tar.bz2 -C ./
mv AssaultCube_v1.2.0.2 lua_server


# Install Lua mod
echo "Installing packages that are necessary to build lua mod"
apt-get install -y lib32z1-dev g++ lua5.1-dev unzip

echo "Downloading lua mod"
wget https://github.com/wesen1/AC-Lua/archive/master.zip -P "tmp"

cd tmp

echo "Extracting lua mod"
unzip master.zip

echo "Building lua mod"
# "Fix" compile error in Lua mod and build the executable
sed -i "s/static inline float round(float x) { return floor(x + 0.5f); }/\/\/&/" AC-Lua-master/src/tools.h
cd AC-Lua-master
sh build.sh

echo "Moving the built executable to the AssaultCube folder"
mv linux_release/linux_64_server ../../lua_server/bin_unix/linux_64_server

cd ../..


# Install database
echo "Installing mariadb-server"

# TODO: Detect existing mariadb/mysql installation and ask for root password
apt-get install -y mariadb-server

echo "Configuring database"

echo "Setting root user password to 'root'"
mysql -u root -Bse "UPDATE mysql.user SET Password=PASSWORD('root') WHERE User='root';"

echo "Restricting root user login to localhost"
mysql -u root -Bse "DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');"

echo "Deleting users without user name"
mysql -u root -Bse "DELETE FROM mysql.user WHERE User='';"

echo "Removing test data base"
mysql -u root -Bse "DELETE FROM mysql.db WHERE Db='test' OR Db='test_%';"          

# Import database
echo "Initializing database for wesen's gema mod"
sql="CREATE DATABASE assaultcube_gema;
     USE assaultcube_gema;
     SOURCE $installerDirectory/assaultcube_gema.sql;"
mysql -u root -Bse "$sql"

# Create new user for lua mod
echo "Creating a new user for wesen's gema mod"
sql="CREATE USER 'assaultcube'@'localhost' IDENTIFIED BY 'password';
     GRANT ALL PRIVILEGES ON assaultcube_gema.* TO 'assaultcube'@'localhost';
     FLUSH PRIVILEGES;"
mysql -u root -Bse "$sql"


# Install wesen gema mod
echo "Installing dependencies for wesen's gema mod"
apt-get install -y lua-filesystem lua-sql-mysql

echo "Copy the gema mod to lua/scripts folder? (Yes|No)"
read copyGemaMod

copyGemaMod=$(echo "$copyGemaMod" | tr '[:upper:]' '[:lower:]')

if [ "copyGemaMod" == "yes" ] || [ "copyGemaMod" == "y" ]
then

  # TODO: Make current user own the directory instead of root
  cp -r "$installerDirectory/lua" "lua_server"

fi


echo "Delete unnecessary files from AssaultCube folder? (Yes|No)"
read deleteFiles

deleteFiles=$(echo "$deleteFiles" | tr '[:upper:]' '[:lower:]')

if [ "$deleteFiles" == "yes" ] || [ "$deleteFiles" == "y" ]
then

  echo "Removing unnecessary files from AssaultCube folder ..."

  rm -rf lua_server/assaultcube.sh
  rm -rf lua_server/bin_unix/linux_64_client
  rm -rf lua_server/bin_unix/linux_client 
  rm -rf lua_server/bot
  rm -rf lua_server/changelog.txt
  rm -rf lua_server/docs
  rm -rf lua_server/mods/
  rm -rf lua_server/README.html
  rm -rf lua_server/screenshots/
  rm -rf lua_server/scripts/
  rm -rf lua_server/server_wizard.sh
  rm -rf lua_server/source/

  rm -f lua_server/config/admin.cfg
  rm -f lua_server/config/autoexec.cfg
  rm -f lua_server/config/autosave.cfg
  rm -f lua_server/config/compatibility.cfg
  rm -f lua_server/config/convert_mapconfig.sh
  rm -f lua_server/config/default_map_settings.cfg
  rm -f lua_server/config/defaults.cfg
  rm -f lua_server/config/docs.cfg
  rm -f lua_server/config/dyngamma.cfg
  rm -f lua_server/config/faq.cfg
  rm -f lua_server/config/favourites.cfg
  rm -f lua_server/config/firstrun.cfg
  rm -f lua_server/config/font.cfg
  rm -f lua_server/config/font_default.cfg
  rm -f lua_server/config/font_monospace.cfg
  rm -f lua_server/config/font_serif.cfg
  rm -f lua_server/config/keymap.cfg
  rm -f lua_server/config/locale.cfg
  rm -f lua_server/config/menus_bot.cfg
  rm -f lua_server/config/menus.cfg
  rm -f lua_server/config/menus_edit.cfg
  rm -f lua_server/config/menus_multiplayer.cfg
  rm -f lua_server/config/menus_settings.cfg
  rm -f lua_server/config/menus_voicecom.cfg
  rm -f lua_server/config/on_quit.cfg
  rm -f lua_server/config/parsestring.cfg
  rm -f lua_server/config/pcksources.cfg
  rm -f lua_server/config/prefabs.cfg
  rm -f lua_server/config/resetbinds.cfg
  rm -f lua_server/config/scontext.cfg
  rm -f lua_server/config/scripts.cfg
  rm -f lua_server/config/securemaps.cfg
  rm -f lua_server/config/sounds.cfg
  rm -f lua_server/config/survival.cfg

  rm -rf lua_server/packages/crosshairs
  rm -rf lua_server/packages/locale

fi


# Delete temporary files
echo "Delete the temporary files? (Yes|No)"
read deleteTemporaryFiles

deleteTemporaryFiles=$(echo "$deleteTemporaryFiles" | tr '[:upper:]' '[:lower:]')

if [ "$deleteTemporaryFiles" == "yes" ] || [ "$deleteTemporaryFiles" == "y" ]; then
  echo "Removing temporary files ..."
  rm -rf "$outputDirectory/tmp"
fi


# TODO: remove default maps?
# TODO: Configure server? => Show message how to configure server and how to start server
# Start the server
# cd lua_server
# sh server.sh
