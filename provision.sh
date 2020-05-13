#!/usr/bin/env bash

# provision.sh

assert_root() {
    if [ $EUID -ne 0 ] ; then
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
	
	chsh -s '/bin/zsh' "${USER}"
	;;
    ubuntu_medium)
	assert_root

	# Start with Miniconda
	cd $HOME
	VERSION="Miniconda3-py37_4.8.2-Linux-x86_64.sh"
	HASH="957d2f0f0701c3d1335e3b39f235d197837ad69a944fa6f5d8ad2c686b69df3b"
	wget https://repo.continuum.io/miniconda/$VERSION -O miniconda.sh
	if ! echo "$HASH  miniconda.sh" | sha256sum --check --status ; then
	    echo "ERROR: checksum failed in downloading $VERSION"
	    exit 1
	fi
	bash miniconda.sh -b -p $HOME/miniconda
	rm miniconda.sh
	source $HOME/miniconda/bin/activate
	conda init
	
	apt install -y emacs gcc make                # dev toolchain
	apt install -y certbot ca-certificates       # certificates
	apt install -y software-properties-common    # tools for adding/removing PPAs
		
	add-apt-respository -y ppa:biosyntax/ppa     # prettification
	apt install -y biosyntax-less
	
	;;
    help|*)
	echo "provision.sh dotfiles        Link dotfiles in home directory."
	echo "provision.sh ubuntu16        (sudo) Add private apt repos to allow "
	echo "provision.sh ubuntu_light    (sudo) Minimal Ubuntu v>=18 stuff; ~25 MB download, ~100MB disk."
	echo "provision.sh ubuntu_medium   (sudo) Run after ubuntu_light to add larger packages; ~280MB download, ~1GB disk."
	echo "provision.sh help            Help string; this command."
	;;
esac

echo
exit 0


