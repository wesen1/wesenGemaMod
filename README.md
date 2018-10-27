wesenGemaMod
============

Description
-----------

Gema mod for AssaultCube Lua servers.

Saves the times that players needed to score on a gema map in a database and provides several commands that the players can use.


Installation
------------

````./install.sh <output directory>````


Setup development environment
-----------------------------

* Install vagrant and virtualbox
* Navigate to the project folder in a console and type ````vagrant up```` to initialize the vagrant box
* Next type ````vagrant ssh```` to connect to the vagrant box
* Now inside the vagrant box type ````cd lua_server````
* Finally type ````./server.sh````

After that you should be able to connect to your test server by typing ````/connect localhost```` ingame.

### Connecting to the database ###

Address: 127.0.0.1 <br>
Port: 3306 <br>
User: root <br>
Password: root
