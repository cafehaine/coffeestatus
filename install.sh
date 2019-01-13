#!/bin/bash

# exit on error
set -o errexit

# install bin
install -d "${INSTALLROOT}"/usr/bin
install -m755 coffeestatus.lua "${INSTALLROOT}"/usr/bin/coffeestatus

# install default config
install -d "${INSTALLROOT}"/etc
install -m644 default_conf.json "${INSTALLROOT}"/etc/coffeestatus_conf.json

# install the output handlers
install -d "${INSTALLROOT}"/usr/lib/coffeestatus/output_handlers

output_handlers=("i3")
for out in "${output_handlers[@]}"; do
	install -m644 output_handlers/"$out.lua" "${INSTALLROOT}"/usr/lib/coffeestatus/output_handlers/
done

# install base modules
install -d "${INSTALLROOT}"/usr/lib/coffeestatus/modules

modules=("bat" "clock" "df" "mem" "mpd" "pango_demo" "pulse" "text")
for mod in "${modules[@]}"; do
	install -m644 modules/"$mod.lua" "${INSTALLROOT}"/usr/lib/coffeestatus/modules/
done
