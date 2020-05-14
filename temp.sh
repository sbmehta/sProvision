#!/usr/bin/env bash

echo USER=$USER
echo LOGNAME=$LOGNAME
echo UID=$UID
echo EUID=$EUID
echo SUDO_USER=$SUDO_USER


if [[ ! $(id -u) -eq 0 ]] || [[ -z "$SUDO_USER" ]] ; then
    echo "ERROR: Please call this script using sudo."
    exit 1
fi
