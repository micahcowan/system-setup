#!/bin/sh

set -e -u -C

# Does sudo exist on this system?
if test "$(id -u)" -eq 0; then
    alias asroot=''
elif type -P sudo 2>/dev/null; then
    alias asroot=sudo
else
    asroot() {
        su -c "$(q "$@")"
    }

    q() {
        printf '%s\n' "$*" | sed -e s/\'/\''\\'\'\'/g -e s/^/\'/ -e s/\$/\'/
    }
fi

exec </dev/null

export DEBCONF_FRONTEND=noninteractive

set -x

asroot apt-get update
asroot apt-get upgrade --yes
apt-cache dumpavail | asroot dpkg --update-avail /dev/stdin
asroot dpkg --set-selections < ./pkg-selections
asroot apt-get dselect-upgrade --yes
