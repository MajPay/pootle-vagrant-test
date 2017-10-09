Translation Server
==================

## Prerequisites

- [Install vagrant](https://www.vagrantup.com/docs/)
- [Install VirtualBox](https://www.virtualbox.org/)

## Installation

1) Run `vagrant up`
2) ssh into vagrant `vagrant ssh`
3) change the directory to `/vagrant`
4) run `source env/bin/activate`
5) make sure rqworker is up (if not: `pootle rqworker &`)
6) run `pootle createsuperuser` and insert your login credentials
7) make sure pootle server is running and listening on :8000 (if not: `pootle runserver --nostatic --noreload &`)
8) goto `http://translate.dev:8041`

### Live Environment

Use bootstrap.sh as template for server configuration but remember to adjust certain settings.

## Resources:

- [Pootle installation](http://docs.translatehouse.org/projects/pootle/en/latest/server/installation.html)
- [(not working) Vagrant example with ansible, redis and nginx](https://github.com/enahum/pootle-vagrant)
- [Docker implementation](https://github.com/JannKleen/pootle-docker)
- [Docker implementation with cronjob examples](https://github.com/1drop/pootle)
- [Custom Translation Servers for TYPO3 Extensions](https://docs.typo3.org/typo3cms/CoreApiReference/Internationalization/Translation/Index.html#custom-translation-servers)

