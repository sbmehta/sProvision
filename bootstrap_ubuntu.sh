#!/usr/bin/env bash

# bootstrap_ubuntu0.sh

if [[ ! -f ~/.ssh/id_rsa_github ]] ; then
   printf "ERROR: Requires private key ~/.ssh/id_rsa_github\n\n"
   exit
fi

printf "Upgrading packages ..."
apt update
apt upgrade
apt install -y git

printf "Installing provisioning script ...\n"
if [[ ! -d ~/sProvision ]] ; then
    mkdir ~/sProvision
fi
cd ~/sProvision
if [[ ! git rev-parse --is-inside-work-tree ]] ; then
    
fi

printf "\n"
