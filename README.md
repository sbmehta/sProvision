# setup personalized Ubuntu environment

## Bootstrap (run as user)
`
source <(curl -s https://raw.githubusercontent.com/sbmehta/sProvision/master/provision_debian.sh) bootstrap
                                                         ## >> (snapshot1) apt update, install git, init sProvision
provision_debian.sh setup_basic         ## >> (snapshot2) zsh, curl, wget, neofetch, keychain, {dotfiles}
provision_debian.sh setup_dev           ## >> (snapshot3) docker, emacs, miniconda, powerlevel10k
provision_debian.sh setup_python        ## >> conda {jupyterlab, notebook, numpy, scipy, pandas, matplotlib ,...}
`
