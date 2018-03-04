#!/bin/bash

cp luastatus.lua /usr/bin/luastatus
chmod +x /usr/bin/luastatus

cp default_conf.json /etc/luastatus_conf.json

mkdir -p /usr/share/luastatus/modules
cp modules/* /usr/share/luastatus/modules/

