#!/usr/bin/env bash

# bootstrap_ubuntu.sh

# Fetches my repo for customizing an Ubuntu environment to ~/sProvision
# Intended for interactive use; will prompt passwords for id_rsa_github, sudo

if [[ $(id -u) -eq 0 ]] ; then
    printf "ERROR: Please do not call this script with root privileges\n\n"
    exit 1
fi

if [[ ! -f ~/.ssh/id_rsa_github ]] ; then
   printf "ERROR: Requires private key ~/.ssh/id_rsa_github\n\n"
   exit 1
else
   ssh-add -l | grep L5Q7R8TIRv1/cszJwSPlrLbsGzhCu+dKF2QUH2Aq2D8 || ssh-add ~/.ssh/id_rsa_github
fi

printf "Upgrading packages ..."
#sudo apt update
#sudo apt upgrade
sudo apt install -y git

if [[ ! -d ~/sProvision ]] ; then
    mkdir ~/sProvision
fi
cd ~/sProvision
if [[ ! $(git rev-parse --is-inside-work-tree) ]] ; then
    printf "Installing provisioning script ...\n"
    git init
    git remote add origin git@github.com:sbmehta/sProvision.git
    git branch --set-upstream-to=origin/master master
    git pull
else
    git remote update
    if [[ $(git status --porcelain --untracked-files=no) ]] ; then
	printf "WARNING: local provisioning repo differs from latest. Update manually if desired."
	exit 1
    fi
fi

printf "Provision repo available at ~/sProvision \n"
