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
    linkconfig)  # should these be source'd instead of symlinked to allow local mods?
	echo "Linking dotfiles ..."
	ln -sfb $HOME/sProvision/.zshrc      $HOME
	ln -sfb $HOME/sProvision/.emacs      $HOME
	ln -sfb $HOME/sProvision/.profile    $HOME
	ln -sfb $HOME/sProvision/.bashrc     $HOME
	ln -sfb $HOME/sProvision/.gitconfig  $HOME
        ln -sfb $HOME/sProvision/sshconfig   $HOME/.ssh/config
	;;
    ubuntu_light)
	assert_root
	apt update && apt upgrade
	apt install -y zsh                           # preferred environment
	apt install -y curl wget                     # data transfer
	apt install -y neofetch keychain             # misc utilities

	cat wsl.conf >> /etc/wsl.conf  # simple defaults; no effect if not on wsl
	
	chsh -s '/bin/zsh' "${USER}"

	echo "Note: Cchanges to wsl.conf require rebooting the distro.")
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

	apt update
	apt install -y gcc make                      # dev toolchain
	apt install -y docker emacs
	apt install -y certbot ca-certificates       # certificates
	apt install -y software-properties-common    # tools for adding/removing PPAs
	apt install -y apt-transport-https
	
	add-apt-respository -y ppa:biosyntax/ppa     # prettification
	apt update
	apt install -y biosyntax-less

	source $HOME/miniconda/bin/activate
	conda init zsh
	
	;;
    help|*)
	echo "provision.sh linkconfig      (user) Link home dir dotfiles, .ssh config to this repo."
	echo "provision.sh ubuntu_light    (sudo) Minimal Ubuntu v>=18 stuff; ~25 MB download, ~100MB disk. Also sets user shell to zsh & adds /etc/wsl.conf default settings."
	echo "provision.sh ubuntu_medium   (sudo) Run after ubuntu_light to add larger packages; ~280MB download, ~1GB disk."
	echo "provision.sh help            Help string; this command."
	;;
esac

echo
exit 0


# 	echo "provision.sh ubuntu16        (sudo) Add private apt repos to allow "
