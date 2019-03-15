# Warning
Coffeestatus is no longer maintained. I switched to sway and waybar. I will not push code here anymore.

# coffeestatus
## What is coffeestatus?
coffeestatus is a simple status generator to be used with any i3-compatible bars. It comes with a few modules that should be enough for any kind of day to day uses.
![Coffeestatus screenshot](https://raw.githubusercontent.com/cafehaine/coffeestatus/master/screenshot.png)
## How do I install this?
Just clone this repo and then run `sudo ./install.sh`.

If you are using archlinux or any pacman-based distro you can install the Aur package `coffeestatus-git`.
## What are the included modules?
A few notable modules are:
 - mpd - It displays the current mpd track and it's progress, allows you to change the volume, skip to next track, play/pause and go to previous track.
 - mem - It displays the current memory usage on your system
 - pulse - It displays the current volume of your active pulseaudio sink. Sadly it is kinda hard to setup. Check [the wiki page for the pulse module](https://github.com/cafehaine/coffeestatus/wiki/pulse-module) for more info on how to set it up.

For a complete list of the included modules check [this wiki page](https://github.com/cafehaine/coffeestatus/wiki/Modules)
## I created a few modules, do you want to include them in coffeestatus?
Yes! However for your modules to be included they should follow a few rules:
 - Your module should use at most 1 luarock (this is to keep this installation easy for most users)
 - Your module should not rely on executing binaries (or if it does it should have an interval of at least 1 minute)
 - It should have a fixed width (this is mostly to prevent the bar from changing length all the time)

