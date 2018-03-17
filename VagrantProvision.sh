#!/bin/bash

# Install the lua server with the install script
/vagrant/install.sh /home/vagrant <<END
y
y
n
y
n
END

# Create a link to the lua folder of the project in the lua_server folder
ln -fs /vagrant/lua /home/vagrant/lua_server

rm -rf /home/vagrant/lua_server/config
ln -fs /vagrant/test\ server/config /home/vagrant/lua_server/config

rm -rf /home/vagrant/lua_server/packages/maps/official
rm -rf /home/vagrant/lua_server/packages/maps/servermaps/incoming
ln -fs /vagrant/test\ server/maps /home/vagrant/lua_server/packages/maps/servermaps/incoming

