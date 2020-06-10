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
	    echo "$SUDO_USER"
	    if [ "$EUID" -ne 0 ] || [ -z "$SUDO_USER" ] ; then  # EUID is 0 even if called as sudo?
		echo "ERROR: must be called using sudo from a user account."
		exit 1
	    fi
	    ;;
    esac
}


case $1 in
    test)
	assert_user "sudo"
	;;
    
    bootstrap)   # call as sudo from desired uer account (not directly as root); interactive asks for passwords
	assert_user "sudo"
	GITKEY="id_rsa_github"
	PROVISION="sProvision"

	if [[ ! -f $HOME/.ssh/$GITKEY ]] ; then     # fetch my github key
	    echo "Fetching samar's github key ..."
	    pushd . 1> /dev/null
	    install -d -o $SUDO_USER -g $SUDO_USER -m 700 $HOME/.ssh
	    cd $HOME/.ssh
	    scp samar@samarmehta.com:/home/samar/.ssh/$GITKEY $GITKEY    
	    ssh-keygen -y -f $GITKEY > $GITKEY.pub     # regenerate public key
	    chown $SUDO_USER:$SUDO_USER $GITKEY $GITKEY.pub
	    chmod 600 $GITKEY $GITKEY.pub
	    popd 1> /dev/null
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
	;;
    
    linkconfig)  # should these be source'd instead of symlinked to allow local mods?
	assert_user "user"
	echo "Linking dotfiles ..."

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
	
	chsh -s '/bin/zsh' "${USER}"

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
	echo "provision_ubuntu.sh bootstrap      (sudo) Sets up git and clones my provisioning repo."
	echo "provision_ubuntu.sh linkconfig     (user) Link home dir dotfiles, .ssh config to this repo."
	echo "provision_ubuntu.sh setup_first    (sudo) Minimal Ubuntu v>=18 stuff; ~5-25 MB download, ~15-100MB disk. Sets $SUDO_USER shell to zsh & adds /etc/wsl.conf default settings."
	echo "provision_ubuntu.sh setup_second   (sudo) Run after ubuntu_light to add larger packages; ~280MB download, ~1GB disk."
	echo "provision_ubuntu.sh conda          (user) Sets up a basic miniconda distribution; ?? size."
	echo "provision_ubuntu.sh help           Help string; this command."
	;;
esac

echo
exit 0
