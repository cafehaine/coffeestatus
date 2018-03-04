#!/bin/bash

# exit on error
set -o errexit

# install bin
mkdir -p ${INSTALLROOT}/usr/bin
cp luastatus.lua ${INSTALLROOT}/usr/bin/luastatus
chmod 755 ${INSTALLROOT}/usr/bin/luastatus

# install default config
mkdir -p ${INSTALLROOT}/etc
cp default_conf.json ${INSTALLROOT}/etc/luastatus_conf.json
chmod 644 ${INSTALLROOT}/etc/luastatus_conf.json

# install base modules
mkdir -p ${INSTALLROOT}/usr/share/luastatus/modules
cp modules/* ${INSTALLROOT}/usr/share/luastatus/modules/
chmod 644 ${INSTALLROOT}/usr/share/luastatus/modules/*

