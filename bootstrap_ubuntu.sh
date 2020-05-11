#!/usr/bin/env bash

# bootstrap_ubuntu.sh

if [[ ! -f ~/.ssh/id_rsa_github ]] ; then
   printf "ERROR: Requires private key ~/.ssh/id_rsa_github\n\n"
   exit 1
fi

if [[ $(id -u) -ne 0 ]] ; then
    printf "ERROR: Please run with root privileges\n\n"
    exit 1
fi

printf "Upgrading packages ..."
#apt update
#apt upgrade
apt install -y git

if [[ ! -d ~/sProvision ]] ; then
    mkdir ~/sProvision
fi
cd ~/sProvision
if [[ ! $(git rev-parse --is-inside-work-tree) ]] ; then
    printf "Installing provisioning script ...\n"
    git init
    git remote add origin git@github.com:sbmehta/sProvision.git
    git pull origin master
else
    
fi

printf "Provision repo available at ~/sProvision \n"
