#!/usr/bin/env bash

# provision.sh

assert_root() {
    if [[ $EUID -ne 0 ]] ; then
	echo "ERROR: this script must be run as root."
	exit 1
    fi
}

echo

case $1 in
    dotfiles)
	echo "Linking dotfiles ..."
	ln -sfb sProvision/.zshrc      $HOME
	ln -sfb sProvision/.emacs      $HOME
	ln -sfb sProvision/.profile    $HOME
	ln -sfb sProvision/.bashrc     $HOME
	ln -sfb sProvision/.gitconfig  $HOME
	;;
    ubuntu_light)
	assert_root
	apt update && apt upgrade
	apt install -y zsh                           # preferred environment
	apt install -y curl wget                     # data transfer
	apt install -y neofetch                      # misc utilities

        # CHECK: if installing these pulls, gcc, should move to heavy
	apt install -y liblzma-dev libncurses5-dev libncursesw5-dev libz-dev libbz2-dev   # needed for samtools
	
	chsh -s '/bin/zsh' "${USER}"
	;;
    ubuntu_heavy)
	assert_root

	INSTALLME="Miniconda3-latest-Linux-x86_64.sh"
	curl -O https://repo.continuum.io/miniconda/$INSTALLME
	sha256sum $INSTALLME  # verify SHA
	bash $INSTALLME       # run though install
	rm $INSTALLME
	
	apt install -y emacs gcc make                # dev toolchain
	apt install -y certbot ca-certificates       # certificates
	apt install -y software-properties-common    # tools for adding/removing PPAs
        apt install -y ca-certificates

	
	
	add-apt-respository -y ppa:biosyntax/ppa     # prettification
	apt install -y biosyntax-less
	
	;;
    help|*)
	echo "provision.sh dotfiles        Link dotfiles in home directory."
	echo "provision.sh ubuntu16        (sudo) Add private apt repos to allow "
	echo "provision.sh ubuntu_light    (sudo) Simple Ubuntu v>=18 stuff; minimal ~50MB space/bandwidth requirements."
	echo "provision.sh ubuntu_heavy    (sudo) Run after ubuntu_light to add larger packages; ~500MB."
	echo "provision.sh help            Help string; this command."
	;;
esac

echo


