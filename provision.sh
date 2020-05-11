#!/usr/bin/env bash

# provision.sh

case $1 in
    dotfiles)
	echo "\n"
	echo "Linking dotfiles ..."
	ln -sfb ~/sProvision/.zshrc      $HOME
	ln -sfb ~/sProvision/.emacs      $HOME
	ln -sfb ~/sProvision/.profile    $HOME
	ln -sfb ~/sProvision/.bashrc     $HOME
	ln -sfb ~/sProvision/.gitconfig  $HOME
	echo "\n"
	;;
    ubuntu0)
	echo "\n"
	echo "Installing minimal software ..."
	apt update && apt upgrade
	apt install zsh                    # preferred environment
	apt install curl wget              # data transfer
	apt install lsb-release            # misc utilities

	chsh -s '/bin/zsh' "${USER}"
	echo "\n"
	;;
    ubuntu1)
	apt install -y gcc make            # dev toolchain
	apt install -y emacs               # preferred environment
	
	apt install -y software-properties-common    # tools for adding/removing PPAs
	;;
    help)
	echo "\n"
	echo "provision.sh dotfiles        Link dotfiles in home directory."
	echo "provision.sh ubuntu0         (sudo) Set up Ubuntu v>16 environment for the first time; minimal space/bandwidth requirements."
	echo "provision.sh ubuntu1         (sudo) Run after ubuntu0 to add larger packages; ~500MB."
	echo "provision.sh help            Help string; this command."
	echo "\n"
	;;
esac


