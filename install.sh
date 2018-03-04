#!/bin/bash

# exit on error
set -o errexit

# install bin
cp luastatus.lua ${INSTALLROOT}/usr/bin/luastatus
chmod +x ${INSTALLROOT}/usr/bin/luastatus

# install default config
cp default_conf.json ${INSTALLROOT}/etc/luastatus_conf.json

# install base modules
mkdir -p /usr/share/luastatus/modules
cp modules/* ${INSTALLROOT}/usr/share/luastatus/modules/

