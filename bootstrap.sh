apt-get update
apt-get install -y unzip libsdl1.2debian lib32z1-dev g++ lua5.1-dev lua-filesystem lua-sql-mysql mariadb-server

# unzip => unzip AC-Lua-master
# libsdl1.2debian => Assaultcube server
# lib32z1-dev g++ lua5.1-dev => Build Lua mod
# lua-filesystem lua-sql-mysql => Lua libraries that my lua mod uses
# mariadb-server => database usage

# Download and extract assaultcube
wget https://github.com/assaultcube/AC/releases/download/v1.2.0.2/AssaultCube_v1.2.0.2.tar.bz2
tar -xvf AssaultCube_v1.2.0.2.tar.bz2 

# Download and extract lua mod
wget https://github.com/UKnowMe/AC-Lua/archive/master.zip
unzip master.zip

# "Fix" compile error in Lua mod and build the executable
sed -i "s/static inline float round(float x) { return floor(x + 0.5f); }/\/\/&/" AC-Lua-master/src/tools.h
cd AC-Lua-master
sh build.sh
cd ..

# Move the built executable to the AssaultCube folder
mv AC-Lua-master/linux_release/linux_64_server AssaultCube_v1.2.0.2/bin_unix/linux_64_server 

# Make a link to the lua folder of the project in the server folder
ln -fs /vagrant/lua AssaultCube_v1.2.0.2/


# Install the database

commands=""

# Setup mariadb-server
commands="$commands
          UPDATE mysql.user SET Password=PASSWORD('root') WHERE User='root';
          DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');
          DELETE FROM mysql.user WHERE User='';
          DELETE FROM mysql.db WHERE Db='test' OR Db='test_%';"

# Create new user for lua mod
commands="$commands
          CREATE USER 'assaultcube'@'localhost' IDENTIFIED BY 'password';
          GRANT ALL PRIVILEGES ON * . * TO 'assaultcube'@'localhost';
          FLUSH PRIVILEGES;"

# Import database
commands="$commands
          CREATE DATABASE assaultcube_gema;
          USE assaultcube_gema;
          SOURCE /vagrant/assaultcube_gema.sql;"

mysql -u root -Bse "$commands"


# Delete unneeded files and folders
rm -f master.zip
rm -rf AC-Lua-master
rm -f AssaultCube_v1.2.0.2.tar.bz2

# TODO: remove default maps

## Delete unneeded assaultcube files
rm -rf AssaultCube_v1.2.0.2/assaultcube.sh
rm -rf AssaultCube_v1.2.0.2/bin_unix/linux_64_client
rm -rf AssaultCube_v1.2.0.2/bin_unix/linux_client 
rm -rf AssaultCube_v1.2.0.2/bot
rm -rf AssaultCube_v1.2.0.2/changelog.txt
rm -rf AssaultCube_v1.2.0.2/docs
rm -rf AssaultCube_v1.2.0.2/mods/
rm -rf AssaultCube_v1.2.0.2/README.html
rm -rf AssaultCube_v1.2.0.2/screenshots/
rm -rf AssaultCube_v1.2.0.2/scripts/
rm -rf AssaultCube_v1.2.0.2/server_wizard.sh
rm -rf AssaultCube_v1.2.0.2/source/

cd AssaultCube_v1.2.0.2/config

rm -f admin.cfg
rm -f autoexec.cfg
rm -f autosave.cfg
rm -f compatibility.cfg
rm -f convert_mapconfig.sh
rm -f default_map_settings.cfg
rm -f defaults.cfg
rm -f docs.cfg
rm -f dyngamma.cfg
rm -f faq.cfg
rm -f favourites.cfg
rm -f firstrun.cfg
rm -f font.cfg
rm -f font_default.cfg
rm -f font_monospace.cfg
rm -f font_serif.cfg
rm -f keymap.cfg
rm -f locale.cfg
rm -f menus_bot.cfg
rm -f menus.cfg
rm -f menus_edit.cfg
rm -f menus_multiplayer.cfg
rm -f menus_settings.cfg
rm -f menus_voicecom.cfg
rm -f on_quit.cfg
rm -f parsestring.cfg
rm -f pcksources.cfg
rm -f prefabs.cfg
rm -f resetbinds.cfg
rm -f scontext.cfg
rm -f scripts.cfg
rm -f securemaps.cfg
rm -f sounds.cfg
rm -f survival.cfg

cd ..
rm -rf packages/crosshairs
rm -rf packages/locale
        

# TODO: Configure server

# Start the server
# cd AssaultCube_v1.2.0.2
# sh server.sh &
