#!/usr/bin/env bash

# bootstrap_ubuntu.sh

# Fetches my repo for customizing an Ubuntu environment to ~/sProvision
# Intended for interactive use; will prompt password for samarmehta.com if needs to get github key

GITKEY="id_rsa_github"
PROVISION="sProvision"

set -e  # exit on any error

if [[ ! $(id -u) -eq 0 ]] ; then
    echo "ERROR: Please call this script as root." 1>&2
    exit 1
fi

if [[ ! -f $HOME/.ssh/$GITKEY ]] ; then     # fetch my github key
    echo "Fetching samar's github key ..."
    pushd .
    install -d -o $SUDO_USER -g $SUDO_USER -m 700 $HOME/.ssh
    cd $HOME/.ssh
    scp samar@samarmehta.com:/home/samar/.ssh/$GITKEY $GITKEY    
    chown $SUDO_USER:$SUDO_USER $GITKEY
    chmod 600 $HOME/.ssh/$GITKEY
    ssh-keygen -y -f $GITKEY > $GITKEY.pub     # regenerate public key
    popd
fi

echo "Confirming git available ..."
apt update
apt install -y git

eval $(ssh-agent)
ssh-add $HOME/.ssh/$GITKEY

install -d -o $SUDO_USER -g $SUDO_USER -m 700 $HOME/$PROVISION
cd $HOME/$PROVISION
if [[ ! $(git rev-parse --is-inside-work-tree) ]] ; then
    echo "Installing provisioning script ..."
    cd ..
    git clone git@github.com:sbmehta/$PROVISION.git
    chown -R $SUDO_USER:$SUDO_USER $HOME/$PROVISION
else
    git remote update
    if [[ $(git status --porcelain --untracked-files=no) ]] ; then
	echo "WARNING: local provisioning repo differs from latest. Update manually if desired.\n"
    fi
fi

echo "Provision repo available at ~/$PROVISION"
