#!/usr/bin/env bash

# provision_ubuntu.sh

set -e

echo

assert_user() {
    case $1 in
	root)
	    if [ "$UID" -ne 0 ] && [ "$EUID" -ne 0 ] ; then
		echo "ERROR: must be run with root privileges."
		exit 1
	    fi	    
	    ;;
	user)
	    if [ "$UID" -eq 0 ] || [ "$EUID" -eq 0 ] ; then
		echo "ERROR: can not be run with root privileges."
		exit 1
	    fi
	    ;;
	sudo)
	    if [ "$EUID" -ne 0 ] || [ -z "$SUDO_USER" ] ; then  # EUID is 0 even if called as sudo?
		echo "ERROR: must be called using sudo from a user account."
		exit 1
	    fi
	    ;;
    esac
}


case $1 in
    test)
	## Dummy case
	assert_user "sudo"
	;;
    
    bootstrap)   # call from desired uer account; interactive asks for passwords
	## (1) install git, (2) local copy my git key, (3) create local provision repo
	## As a side effect, updates then cleans the apt cache
	assert_user "user"       ## ?? what if want to use machine/container as root??
	GITKEY="id_rsa_github"
	PROVISION="sProvision"

	echo
	echo "Enter LOCAL sudo password to make sure git up to date ..."
	sudo apt update
	sudo apt install -y git
	sudo apt clean

	echo
	echo "Enter SAMAR@SAMARMEHTA.COM password to fetch samar's github key ..."
	rsync samar@samarmehta.com:/home/samar/.ssh/id_rsa_github\{,.pub\} $HOME/.ssh

	echo
 	echo "Enter samar's ID_RSA_GITHUB password to use github key ..."
	eval $(ssh-agent)
	ssh-add $HOME/.ssh/$GITKEY

	echo
	echo "Installing provisioning script ..."
	if [[ -d $HOME/$PROVISION ]]; then     # if already there, offer to delete
	    read -p "Overwrite existing data at ~/$PROVISION?" confirm
	    if [[ "$confirm" =~ "^[Yy]" ]]; then
	       rm -rf $HOME/$PROVISION
	    fi
	fi

	if [[ ! -d $HOME/$PROVISION ]]; then    # only still here if user said don't overwrite
	    install -d -o $USER -g $USER -m 700 $HOME/$PROVISION
	    git clone git@github.com:sbmehta/$PROVISION.git $HOME/$PROVISION
	    echo "Provision repo available at ~/$PROVISION"
	fi

	;;
    
    linkconfig)  # should these be source'd instead of symlinked to allow local mods?
	assert_user "user"
	echo "Linking dotfiles (backup if exists) ..." 

	ln -sfb $HOME/sProvision/.bashrc     $HOME
	ln -sfb $HOME/sProvision/.emacs      $HOME
	ln -sfb $HOME/sProvision/.gitconfig  $HOME
	ln -sfb $HOME/sProvision/.profile    $HOME
	ln -sfb $HOME/sProvision/.zshrc      $HOME
	ln -sfb $HOME/sProvision/.p10k.zsh   $HOME

        ln -sfb $HOME/sProvision/sshconfig   $HOME/.ssh/config
	;;
    
    setup_first)
	assert_user "root"
	apt update && apt upgrade -y
	apt install -y zsh                           # preferred environment
	apt install -y curl wget                     # data transfer
	apt install -y neofetch keychain             # misc utilities
	apt autoclean && apt autoremove
	
	cat $HOME/sProvision/wsl.conf >> /etc/wsl.conf  # simple defaults; no effect if not on wsl
	
cd 	chsh -s '/bin/zsh' "${USER}"

	echo "Note: Changes to wsl.conf require rebooting the distro."
	;;
    
    setup_second)
	assert_user "root"

	git clone --depth=1 https://github.com/romkatv/powerlevel10k.git $HOME/powerlevel10k
	
	apt update && apt upgrade -y
	apt install -y gcc make                      # dev toolchain
	apt install -y emacs
	apt install -y certbot ca-certificates       # certificates
	apt install -y software-properties-common    # tools for adding/removing PPAs
	apt install -y apt-transport-https

	curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
	add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
	apt update
	apt -y install docker-ce
	
	add-apt-repository -y ppa:biosyntax/ppa     # prettification
	apt update
	apt install -y biosyntax-less

	mkdir $HOME/.config/docker-zsh-completion
	curl -L https://raw.githubusercontent.com/docker/docker-ce/master/components/cli/contrib/completion/zsh/_docker > $HOME/.config/docker-zsh-completion/_docker
	;;
    
    conda)
	assert_user "user"

	# need to compare size if run pre-/post- medium provision (i.e,. does this download a 2nd Python distribution?)
	
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
	conda config --add channels defaults
	conda config --add channels bioconda
	conda config --add channels conda-forge
        conda update -y conda
	conda update -y --all
	conda clean -y --all

	mkdir -p $HOME/.config
	cd $HOME/.config
	git clone https://github.com/esc/conda-zsh-completion

	#conda init zsh      # i think i already included all this in .zshrc?		
	;;
    
    help|*)
	echo "provision_ubuntu.sh bootstrap      (user/interactive) Sets up git and clones my provisioning repo."
	echo "provision_ubuntu.sh linkconfig     (user) Link home dir dotfiles & .ssh config to provisioning repo."
	echo "provision_ubuntu.sh setup_first    (sudo) Installs {zsh,curl,wget,keychain,neofetch}; ~5-25 MB download, ~15-100MB disk. Sets default shell to zsh. links /etc/wsl.conf to provisioning repo."
	echo "provision_ubuntu.sh setup_second   (sudo) Run after setup_first to add larger packages {emacs, docker, powerlevel10k, gcc, etc.}; ~280MB download, ~1GB disk."
	echo "provision_ubuntu.sh conda          (user) Sets up a basic miniconda distribution; ?? size."
	echo "provision_ubuntu.sh help           Help string; this command."
	;;
esac

echo

