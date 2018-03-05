#!/bin/bash

# exit on error
set -o errexit

# install bin
install -d "${INSTALLROOT}"/usr/bin
install -m755 coffeestatus.lua "${INSTALLROOT}"/usr/bin/coffeestatus

# install default config
install -d "${INSTALLROOT}"/etc
install -m644 default_conf.json "${INSTALLROOT}"/etc/coffeestatus_conf.json

# install base modules
install -m644 -D modules/* "${INSTALLROOT}"/usr/share/coffeestatus/modules/

