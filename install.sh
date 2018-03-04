#!/bin/bash

# exit on error
set -o errexit

# install bin
cp luastatus.lua /usr/bin/luastatus
chmod +x /usr/bin/luastatus

# install default config
cp default_conf.json /etc/luastatus_conf.json

# install base modules
mkdir -p /usr/share/luastatus/modules
cp modules/* /usr/share/luastatus/modules/

