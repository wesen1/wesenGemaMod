#!/bin/bash

# Install the lua server with the install script
/vagrant/install.sh /home/vagrant/lua_server <<END
y
y
n
y
n
y
root
root
password
password
END


# Install the gema server test framework dependencies
sudo apt-get install -y luarocks

luarocks install luacov
luarocks install luaunit
luarocks install mach


# Install LDoc
luarocks install penlight
luarocks install ldoc


# Create links for the lua files
ln -fs /vagrant/src/wesenGemaMod /home/vagrant/lua_server/lua/scripts

rm -rf /home/vagrant/lua_server/lua/config
ln -fs /vagrant/src/config /home/vagrant/lua_server/lua

ln -fs /vagrant/src/main.lua /home/vagrant/lua_server/lua/scripts


# Create links for the test server configuration
rm -rf /home/vagrant/lua_server/config
ln -fs /vagrant/test\ server/config /home/vagrant/lua_server/config

rm -rf /home/vagrant/lua_server/packages/maps/servermaps/incoming
ln -fs /vagrant/test\ server/maps /home/vagrant/lua_server/packages/maps/servermaps/incoming


# Redirect logs to logfile
mkdir -p /vagrant/test\ server/log
ln -fs /vagrant/test\ server/log /var/log/assaultcube

echo -e "\n\n# Custom Rules" >> /etc/rsyslog.conf
echo ":programname, isequal, AssaultCube /var/log/assaultcube/assaultcube_server.log" >> /etc/rsyslog.conf
/etc/init.d/rsyslog restart
