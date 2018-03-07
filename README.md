# wesenGemaMod

## Description

Gema mod for AssaultCube Lua servers.

The records are saved in a minimal database and the commands are built in a way that allows you to easily add new commands.


### Known problems:

* When players use "/gonext" the time displayed in the vote will be some random big number
* Players can not vote too often when their votes do not pass a few times in a row


## Installation

- Check out bootstrap.sh
- Adjust main.lua (database information)


## Setup development environment

* Install vagrant and virtualbox
* Navigate to the project folder in a console and type ````vagrant up```` to initialize the vagrant box
* Next type ````vagrant ssh```` to connect to the vagrant box
* Now inside the vagrant box type ````cd AssaultCube_v.1.2.0.2````
* Finally type ````./server.sh````

After that you should be able to connect to your test server by typing ````/connect localhost```` ingame.

