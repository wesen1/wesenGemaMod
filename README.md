wesenGemaMod
============

Description
-----------

Gema mod for AssaultCube Lua servers.

Saves the times that players needed to score on a gema map in a database and provides several commands that the players can use.


Usage
-----

The code in this repository is used to build a docker image which is distributed to [dockerhub](https://hub.docker.com/r/wesen1/assaultcube-wesen-gema-mod-server).
That docker image contains a AssaultCube Lua Server with wesenGemaMod installed, the database is not included and must be provided by a different docker container for example.

You should at least overwrite `/ac-server/lua/config/config.lua` with a custom config, just copy `src/config/config.lua` and link it into your container.

Other overwrite candidates are:

* /ac-server/config: The server config files (See [AssaultCube Guide](https://assault.cubers.net/docs/server.html))
* /ac-server/packages: The packages (maps, map models, textures, etc)

See https://github.com/wesen1/ac-gema-server-setup for a usage example.

Note that all files that are only stored inside the docker container are gone once you stop it, so the files or directories that you want to keep should be linked into the container from the outside.


Setup development environment
-----------------------------

* Install vagrant and virtualbox
* Navigate to the project folder in a console and type `vagrant up` to initialize the vagrant box
* Next type `vagrant ssh` to connect to the vagrant box
* Now inside the vagrant box type `cd /vagrant`
* Finally type `docker-compose up`

After that you should be able to connect to your test server by typing `/connect localhost` ingame.


Note that the following files will be automatically created during the setup:

* test-server/config: The config files of your test-server
* test-server/packages: The packages of your test-server (maps, map models, textures, etc)
