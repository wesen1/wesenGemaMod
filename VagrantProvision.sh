#!/bin/bash

# Install the lua server with the install script
cd /vagrant
./install.sh /home/vagrant <<END
y
n
y
n
END

# Create a link to the lua folder of the project in the lua_server folder
ln -fs /vagrant/lua /home/vagrant/lua_server
