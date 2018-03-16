#!/bin/bash

###################
# Functions
###################

#
# Returns whether the script was executed with root.
# Source: https://stackoverflow.com/a/21372328
#
# @return Bool True: User is root
#              False: User is not root
#
isRoot()
{
  if [[ $(id -u) != 0 ]]; then
    return 1
  else
    return 0
  fi
}

#
# Returns an absolute path from a path string.
#
# @param String $1 The path string
#
getAbsolutePath()
{
  pathString="$1"

  if [[ $pathString == "/"* ]]; then

    # If the path starts with a slash it is already an absolute path
    absoluteDirectory=$pathString
  else
    # If the path does not start with a slash it is a relative path
    # Therefore the current working directory (absolute path) is added in front of it
    absoluteDirectory="$PWD/$pathString"
  fi

  echo $absoluteDirectory
}

#
# Asks a yes no question and returns the user decision.
#
# @param String $1 The yes/no question
#
# @return int 0: The user answerd yes
#             1: The user answered no
#
askYesNoQuestion()
{
  echo "$1 (Yes|No)"
  read userDecision

  #
  # Convert user input to lowercase
  # Source: https://stackoverflow.com/a/11392488
  #  
  userDecision=$(echo "$userDecision" | tr '[:upper:]' '[:lower:]')

  if [[ "$userDecision" == "yes" ]] || [[ "$userDecision" == "y" ]]; then
    return 0
  else
    return 1
  fi
}


###################
# Script
###################

# TODO: Default: supress output, if --verbose don't supress output

## Check whether the user is root
if ! $(isRoot); then
  echo "Please run as root"
  exit
fi


## Determine the directories

# Argument $0 is the path to the script
installerDirectory="$(getAbsolutePath $(dirname $0))"

# Argument $1 is the output directory as specified by the user
outputDirectory="$(getAbsolutePath $1)"


if [ ! -d $outputDirectory ]; then

  question="The output directory $outputDirectory doesn't exist. Shall it be created?"
  if askYesNoQuestion "$question"; then
    mkdir -p "$outputDirectory"
  else
    exit
  fi

fi


## Ask for confirmation to install the gema server
question="This sript will install an AssaultCube lua server with wesen's gema mod to $outputDirectory. Continue?"
if ! askYesNoQuestion "$question"; then
  exit
fi


## Install AssaultCube Server

cd "$outputDirectory"
mkdir "tmp"

apt-get update

echo "Installing AssaultCube server dependencies"
apt-get install -y libsdl1.2debian

echo "Downloading AssaultCube"
wget https://github.com/assaultcube/AC/releases/download/v1.2.0.2/AssaultCube_v1.2.0.2.tar.bz2 -P "tmp"

echo "Extracting AssaultCube"
tar -xvf tmp/AssaultCube_v1.2.0.2.tar.bz2 -C ./
mv AssaultCube_v1.2.0.2 lua_server


## Install Lua mod

echo "Installing packages that are necessary to build lua mod"
apt-get install -y lib32z1-dev g++ lua5.1-dev unzip

echo "Downloading lua mod"
wget https://github.com/wesen1/AC-Lua/archive/master.zip -P "tmp"

cd tmp

echo "Extracting lua mod"
unzip master.zip

echo "Building lua mod"

# "Fix" compile error in Lua mod by commenting out the line below and build the executable
sed -i "s/static inline float round(float x) { return floor(x + 0.5f); }/\/\/&/" AC-Lua-master/src/tools.h

cd AC-Lua-master
sh build.sh

echo "Moving the built executable to the AssaultCube folder"
mv linux_release/linux_64_server ../../lua_server/bin_unix/linux_64_server

cd ../..


## Install database
question="Shall the database for wesen's gema mod be installed?"
if askYesNoQuestion "$question"; then

  #
  # Check whether mysql or mariadb is already installed
  # Source: https://stackoverflow.com/a/677212s
  #
  if ! hash mysql >/dev/null 2>&1; then

    echo "Installing mariadb-server"
    apt-get install -y mariadb-server

    echo "Setting root user password to 'root'"
    mysql -u root -Bse "UPDATE mysql.user SET Password=PASSWORD('root') WHERE User='root';"

  fi

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

fi


## Install wesen's gema mod

echo "Installing dependencies for wesen's gema mod"
apt-get install -y lua-filesystem lua-sql-mysql

question="Copy the gema mod to lua/scripts folder?"
if askYesNoQuestion "$question"; then

  echo "Copying gema mod ..."
  cp -r "$installerDirectory/lua" "lua_server"

fi


## Delete unnecessary AssaultCube files
question="Delete unnecessary files from AssaultCube folder?"
if askYesNoQuestion "$question"; then

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


## Delete temporary files
question="Delete the temporary files?"
if askYesNoQuestion "$question"; then
  echo "Removing temporary files ..."
  rm -rf "$outputDirectory/tmp"
fi


## Print information

echo "Go to https://assault.cubers.net/docs/server.html to learn how to configure your server"
echo "Navigate to $outputDirectory and type \"sh server.sh\" to start the server"
