#!/bin/bash

apt-get update

# Install docker-compose which should be used to run the test server
apt-get install -y docker-compose


# Install all wesenGemaMod dependencies for the unit tests
apt-get install -y luarocks
apt-get install -y lua-sql-mysql

luarocks install ac-luaserver
luarocks install luaorm
luarocks install sleep

# Install the dependencies for the test framework
luarocks install luacov
luarocks install luacov-html
luarocks install wluaunit

# Install LDoc
luarocks install penlight
luarocks install ldoc

# Install luacheck
luarocks install luacheck


# Setup the test-server files that are linked into the wesenGemaMod docker container
archiveFilePath="/vagrant/tmp/AssaultCube_v1.2.0.2.tar.bz2"
archiveMainDirectoryName="AssaultCube_v1.2.0.2"
outputDirectory="/vagrant/test-server"

if [ ! -f "$archiveFilePath" ]; then
  echo "Downloading AssaultCube ..."
  wget https://github.com/assaultcube/AC/releases/download/v1.2.0.2/AssaultCube_v1.2.0.2.tar.bz2 -P "/vagrant/tmp"
fi

if [ ! -d "$outputDirectory" ]; then
  mkdir "$outputDirectory"
fi

filesToExtract=(
  # Extract the default config files
  "$archiveMainDirectoryName/config/forbidden.cfg"
  "$archiveMainDirectoryName/config/maprot.cfg"
  "$archiveMainDirectoryName/config/motd_en.txt"
  "$archiveMainDirectoryName/config/nicknameblacklist.cfg"
  "$archiveMainDirectoryName/config/serverblacklist.cfg"
  "$archiveMainDirectoryName/config/servercmdline.txt"
  "$archiveMainDirectoryName/config/serverinfo_en.txt"
  "$archiveMainDirectoryName/config/serverkillmessages.cfg"
  "$archiveMainDirectoryName/config/serverpwd.cfg"

  # Extract the default server packages
  "$archiveMainDirectoryName/packages/audio/ambience"
  "$archiveMainDirectoryName/packages/maps"
  "$archiveMainDirectoryName/packages/models/mapmodels"
  "$archiveMainDirectoryName/packages/textures"
)

tar -xvf "$archiveFilePath" -C "$outputDirectory/" --strip-components=1 "${filesToExtract[@]}" --keep-old-files


# Setup the vagrant user to be able to use "docker" and "docker-compose" commands
groupadd docker
usermod -aG docker vagrant
