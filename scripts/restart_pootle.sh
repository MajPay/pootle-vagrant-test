#!/usr/bin/env bash

sudo killall -v pootle
if [ ! -x "$(command -v pootle)" ]
then
    source /vagrant/bin/activate
fi

pootle rqworker &
pootle runserver --nostatic --noreload &