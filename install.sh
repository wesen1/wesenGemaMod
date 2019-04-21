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
  if [ $(id -u) != 0 ]; then
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

  if [[ "$pathString" == "/"* ]]; then

    # If the path starts with a slash it is already an absolute path
    absoluteDirectory=$pathString
  else
    # If the path does not start with a slash it is a relative path
    # Therefore the current working directory (absolute path) is added in front of it
    absoluteDirectory="$(pwd)/$pathString"
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

  if [ "$userDecision" == "yes" ] || [ "$userDecision" == "y" ]; then
    return 0
  else
    return 1
  fi
}

#
# Creates all directories in the path that do not exist and changes the owner to
# the user who executed the script.
# Must use this function because mkdir and install apply owner options only to the
# last created directory
#
# @param String $1 The directory path
# @param String $2 The user name of the user who executed the script
#
createDirectoriesRecursive()
{
  directoryPath=""

  #
  # Split directory path by "/"
  #
  # https://stackoverflow.com/a/918898
  for directory in $(echo $1 | tr "/" " ")
  do

    directoryPath="$directoryPath/$directory"

    if [ ! -d $directoryPath ]; then
      mkdir "$directoryPath"
      chown "$2" "$directoryPath"
      chgrp "$2" "$directoryPath"
    fi

  done
}

#
# Reads a password from the command line and saves it in the global variable $password.
#
# @param String $1 The description of the user for which the password will be used
#
readPassword()
{
  password="1"
  confirmPassword="2"
  isFirstCycle=1

  while [ "$password" != "$confirmPassword" ]; do

    if [ $isFirstCycle == 1 ]; then
      isFirstCycle=0
    else
      echo "The passwords did not match. Please try again."
    fi

    echo -e "\n"
    read -p "Enter a password for $1: " -s password
    echo -en "\n"
    read -p "Confirm the password for $1: " -s confirmPassword
    echo -e "\n"

  done
}


###################
# Script
###################

## Check whether the user is root
if ! $(isRoot); then
  echo "Please run as root"
  exit
fi


## Determine the username

#
# See https://unix.stackexchange.com/a/137217
#
userName="${SUDO_USER:-$USER}"


## Determine the directories

# Argument $0 is the path to the script
installerDirectory="$(getAbsolutePath $(dirname $0))"

# Argument $1 is the output directory as specified by the user
outputDirectory="$(getAbsolutePath $1)"


if [ ! -d $outputDirectory ]; then

  question="The output directory $outputDirectory doesn't exist. Shall it be created?"
  if askYesNoQuestion "$question"; then
    createDirectoriesRecursive "$outputDirectory" "$userName"
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

apt-get update

echo "Installing AssaultCube server dependencies ..."
apt-get install -y libsdl1.2debian

mkdir "$installerDirectory/tmp"

if [ ! -f "$installerDirectory/tmp/AssaultCube_v1.2.0.2.tar.bz2" ]; then
  echo "Downloading AssaultCube ..."
  wget https://github.com/assaultcube/AC/releases/download/v1.2.0.2/AssaultCube_v1.2.0.2.tar.bz2 -P "$installerDirectory/tmp"
fi

echo "Extracting AssaultCube ..."
tar -xvf "$installerDirectory/tmp/AssaultCube_v1.2.0.2.tar.bz2" -C "$outputDirectory" --strip-components=1


## Install Lua mod

echo "Installing packages that are necessary to build lua mod ..."
apt-get install -y lib32z1-dev g++ lua5.1-dev unzip

if [ ! -f "$installerDirectory/tmp/master.zip" ]; then
  echo "Downloading lua mod ..."
  wget https://github.com/wesen1/AC-Lua/archive/master.zip -P "$installerDirectory/tmp"
fi

if [ ! -d "$installerDirectory/tmp/AC-Lua-master" ]; then
  echo "Extracting lua mod ..."
  unzip -d "$installerDirectory/tmp/" "$installerDirectory/tmp/master.zip"
fi

if [ ! -f "$installerDirectory/tmp/AC-Lua-master/linux_release/linux_64_server" ]; then

  echo "Building lua mod ..."
  cd "$installerDirectory/tmp/AC-Lua-master"

#   "Fix" compile error in Lua mod by commenting out the line below and build the executable
  sed -i "s/static inline float round(float x) { return floor(x + 0.5f); }/\/\/&/" src/tools.h

  sh build.sh
  cd
fi

echo "Moving the built executable to the AssaultCube folder ..."
cp "$installerDirectory/tmp/AC-Lua-master/linux_release/linux_64_server" "$outputDirectory/bin_unix/linux_64_server"


## Install wesen's gema mod

echo "Installing dependencies for wesen's gema mod ..."
apt-get install -y luarocks lua-filesystem lua-sql-mysql

luarocks install luaorm

createDirectoriesRecursive "$outputDirectory/lua/scripts" "$userName"
createDirectoriesRecursive "$outputDirectory/lua/config" "$userName"

question="Copy the gema mod to lua/scripts folder?"
if askYesNoQuestion "$question"; then

  echo "Copying gema mod ..."
  createDirectoriesRecursive "$outputDirectory/lua/scripts/wesenGemaMod"
  cp -r "$installerDirectory/src/wesenGemaMod" "$outputDirectory/lua/scripts"
  cp "$installerDirectory/src/main.lua" "$outputDirectory/lua/scripts/main.lua"
  cp -r "$installerDirectory/src/config" "$outputDirectory/lua"

fi


## Delete unnecessary AssaultCube files
question="Delete unnecessary files from AssaultCube folder?"
if askYesNoQuestion "$question"; then

  echo "Removing unnecessary files from AssaultCube folder ..."

  rm -rf "$outputDirectory/assaultcube.sh"
  rm -rf "$outputDirectory/bin_unix/linux_64_client"
  rm -rf "$outputDirectory/bin_unix/linux_client "
  rm -rf "$outputDirectory/bot"
  rm -rf "$outputDirectory/changelog.txt"
  rm -rf "$outputDirectory/docs"
  rm -rf "$outputDirectory/mods/"
  rm -rf "$outputDirectory/README.html"
  rm -rf "$outputDirectory/screenshots/"
  rm -rf "$outputDirectory/scripts/"
  rm -rf "$outputDirectory/server_wizard.sh"
  rm -rf "$outputDirectory/source/"

  rm -f "$outputDirectory/config/admin.cfg"
  rm -f "$outputDirectory/config/autoexec.cfg"
  rm -f "$outputDirectory/config/autosave.cfg"
  rm -f "$outputDirectory/config/compatibility.cfg"
  rm -f "$outputDirectory/config/convert_mapconfig.sh"
  rm -f "$outputDirectory/config/default_map_settings.cfg"
  rm -f "$outputDirectory/config/defaults.cfg"
  rm -f "$outputDirectory/config/docs.cfg"
  rm -f "$outputDirectory/config/dyngamma.cfg"
  rm -f "$outputDirectory/config/faq.cfg"
  rm -f "$outputDirectory/config/favourites.cfg"
  rm -f "$outputDirectory/config/firstrun.cfg"
  rm -f "$outputDirectory/config/font.cfg"
  rm -f "$outputDirectory/config/font_default.cfg"
  rm -f "$outputDirectory/config/font_monospace.cfg"
  rm -f "$outputDirectory/config/font_serif.cfg"
  rm -f "$outputDirectory/config/keymap.cfg"
  rm -f "$outputDirectory/config/locale.cfg"
  rm -f "$outputDirectory/config/menus_bot.cfg"
  rm -f "$outputDirectory/config/menus.cfg"
  rm -f "$outputDirectory/config/menus_edit.cfg"
  rm -f "$outputDirectory/config/menus_multiplayer.cfg"
  rm -f "$outputDirectory/config/menus_settings.cfg"
  rm -f "$outputDirectory/config/menus_voicecom.cfg"
  rm -f "$outputDirectory/config/on_quit.cfg"
  rm -f "$outputDirectory/config/parsestring.cfg"
  rm -f "$outputDirectory/config/pcksources.cfg"
  rm -f "$outputDirectory/config/prefabs.cfg"
  rm -f "$outputDirectory/config/resetbinds.cfg"
  rm -f "$outputDirectory/config/scontext.cfg"
  rm -f "$outputDirectory/config/scripts.cfg"
  rm -f "$outputDirectory/config/securemaps.cfg"
  rm -f "$outputDirectory/config/sounds.cfg"
  rm -f "$outputDirectory/config/survival.cfg"

  rm -rf "$outputDirectory/packages/crosshairs"
  rm -rf "$outputDirectory/packages/locale"

fi


## Delete temporary files
question="Delete the temporary files?"
if askYesNoQuestion "$question"; then
  echo "Removing temporary files ..."
  rm -rf "$installerDirectory/tmp"
fi


## Change the owner of all files in the output directory
chown -R "$userName" "$outputDirectory"
chgrp -R "$userName" "$outputDirectory"


## Install database
question="Shall the database for wesen's gema mod be installed?"
if askYesNoQuestion "$question"; then

  #
  # Check whether mysql or mariadb is already installed
  # Source: https://stackoverflow.com/a/677212s
  #
  if ! hash mysql >/dev/null 2>&1; then

    echo "Installing mariadb-server ..."
    apt-get install -y mariadb-server

    readPassword "the 'root' database user"
    rootUserPassword="$password"

    echo "Setting root user password ..."
    mysql -u root -Bse "UPDATE mysql.user SET Password=PASSWORD('$rootUserPassword') WHERE User='root';"

  fi

  # Import database
  echo "Initializing database for wesen's gema mod ..."
  sql="CREATE DATABASE assaultcube_gema;"
  mysql -u root -Bse "$sql"

  # Create new user for lua mod
  readPassword "the gemamod database user"
  gemamodUserPassword="$password"

  echo "Creating a new user for wesen's gema mod ..."
  sql="CREATE USER 'assaultcube'@'localhost' IDENTIFIED BY '$gemamodUserPassword';
       GRANT ALL PRIVILEGES ON assaultcube_gema.* TO 'assaultcube'@'localhost';
       FLUSH PRIVILEGES;"
  mysql -u root -Bse "$sql"

  # Write the gemamod user password to the gemamod config file
  gemamodConfigPath="$outputDirectory/lua/config/gemamod.cfg"

  if [ -f "$gemamodConfigPath" ]; then
    echo "Setting password in config file ..."

    # See https://stackoverflow.com/a/20568559
    sed -i "s/^\(dataBasePassword=\).*/\1$gemamodUserPassword/" "$gemamodConfigPath"
  fi

else
  echo "The database will not be installed. You have to adjust lua/config/gemamod.cfg manually."
fi


## Print information
echo -en "\n\nInstallation complete.\n"
echo "Go to https://assault.cubers.net/docs/server.html to learn how to configure your server"
echo "Navigate to $outputDirectory and type \"sh server.sh\" to start the server"
