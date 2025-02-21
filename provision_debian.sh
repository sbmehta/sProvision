#!/usr/bin/env bash

## provision_debian.sh

#set -e

echo

make_symlinks () {
    echo "Linking dotfiles (backup if exists) ..." 

    # should these be source'd instead of symlinked to allow local mods?
    ln -sfb $HOME/sProvision/.bashrc     $HOME
    ln -sfb $HOME/sProvision/.emacs      $HOME
    ln -sfb $HOME/sProvision/.gitconfig  $HOME
    ln -sfb $HOME/sProvision/.profile    $HOME
    ln -sfb $HOME/sProvision/.zshrc      $HOME
    ln -sfb $HOME/sProvision/.p10k.zsh   $HOME
    
    ln -sfb $HOME/sProvision/sshconfig   $HOME/.ssh/config
}


if [ "$UID" -eq 0 ] ; then
    echo
    echo "WARNING: running as root can have unexpected effects."
    echo	 
fi


case $1 in
    bootstrap)   # interactive; asks for passwords
	## (1) install git, (2) local copy my git key, (3) create local provision repo
	## As a side effect, updates then cleans the apt cache
	GITKEY="id_rsa_github"
	PROVISION="sProvision"
	KEYSERVER="samarmehta.com"
	KEYUSER="samar"
	
	echo
	echo "Enter LOCAL sudo password to make sure git up to date ..."
	sudo apt update
	sudo apt install -y git openssh-client
	sudo apt autoclean

	mkdir -p $HOME/.ssh
	touch $HOME/.ssh/known_hosts
	
	echo
	echo "Enter $KEYUSER@$KEYSERVER password to fetch samar's github key ..."
	ssh-keygen -R $KEYSERVER
	ssh-keyscan -H $KEYSERVER >> $HOME/.ssh/known_hosts
	rsync $KEYUSER@$KEYSERVER:/home/samar/.ssh/id_rsa_github{,.pub} $HOME/.ssh

	echo
 	echo "Enter samar's ID_RSA_GITHUB password to test github key ..."
	eval $(ssh-agent)
	ssh-add $HOME/.ssh/$GITKEY
	ssh-keygen -R github.com
	ssh-keyscan -H github.com >> $HOME/.ssh/known_hosts
	
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
    
    setup_basic)
	sudo apt update
	sudo apt install -y zsh                           # preferred environment
	sudo apt install -y curl wget                     # data transfer
	sudo apt install -y neofetch keychain             # misc utilities
	sudo apt autoclean && sudo apt autoremove

	make_symlinks

	cat $HOME/sProvision/wsl.conf | sudo tee -a /etc/wsl.conf # simple defaults for wsl
 
   	sudo chsh -s '/bin/zsh' "${USER}"

	echo "Note: Changes to wsl.conf require rebooting the distro."
	;;

    relink_dotfiles)
	make_simlinks
	;;
    
    setup_dev)

	git clone --depth=1 https://github.com/romkatv/powerlevel10k.git $HOME/powerlevel10k

	sudo apt update && sudo apt upgrade -y
	
	# Start with Miniconda
	cd $HOME
	rm -r $HOME/miniconda3
	mkdir -p $HOME/miniconda3
	wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O $HOME/miniconda3/miniconda.sh
	bash $HOME/miniconda3/miniconda.sh -b -u -p $HOME/miniconda3
	rm $HOME/miniconda3/miniconda.sh
	
	## note: .zshrc & .bashrc should already have conda initialization; otherwise run "conda init 'shellname'"
	
	sudo apt install -y gcc make                      # dev toolchain
	sudo apt install -y emacs                         # preferred editor
	sudo apt install -y certbot ca-certificates       # certificates
	sudo apt install -y software-properties-common    # tools for adding/removing PPAs
	sudo apt install -y apt-transport-https

	curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
	sudo apt update
 	sudo apt install docker-ce
 	
	mkdir -p $HOME/.config
	
	mkdir $HOME/.config/docker-zsh-completion
	curl -L https://raw.githubusercontent.com/docker/docker-ce/master/components/cli/contrib/completion/zsh/_docker > $HOME/.config/docker-zsh-completion/_docker

	git clone https://github.com/esc/conda-zsh-completion $HOME/.config/conda-zsh-completion

	;;
	
    setup_python)

	conda config --add channels defaults
	conda config --add channels conda-forge
        conda update -y conda
	conda update -y --all

	conda install -y pylint
	conda install -y numpy scipy pandas statsmodels scikit-learn
	conda install -y matplotlib seaborn bokeh
	conda install -y notebook jupyterlab
	#conda install -y google-cloud-sdk
	
	conda clean -y --all

	;;


    setup_haskell)
	curl --proto '=https' --tlsv1.2 -sSf https://get-ghcup.haskell.org | sh

	;;
    
    setup_R)
	sudo apt install r-base r-base-dev -y
	conda install -c conda-forge r-essentials

	;;
	
    help|*)
	echo "provision_debian.sh help              Help string; this command."
	echo "provision_debian.sh bootstrap         (interactive) Sets up git and clones my provisioning repo."
	echo "provision_debian.sh relink_dotfiles   Fixes links to ink home dir dotfiles & .ssh config to provisioning repo."
	echo "provision_debian.sh setup_basic       Installs {curl,keychain,neofetch,wget,zsh}; ~5-25 MB download, ~15-100MB disk. Sets default shell to zsh. links /etc/wsl.conf to provisioning repo."
	echo "provision_debian.sh setup_dev         Installs packages {conda, emacs, docker, gcc, powerlevel10k, etc.}; ~350MB download, ~1.5GB disk."
	echo "provision_debian.sh setup_python      Sets up common python packages under conda"
	;;
esac

echo
