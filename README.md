# setup personalized Ubuntu environment

## Bootstrap (run as user)
`
source <(curl -s https://raw.githubusercontent.com/sbmehta/sProvision/master/provision_debian.sh) bootstrap
                                                         ## >> (snapshot1) apt update, install git, init sProvision
$HOME/sProvision/provision_debian.sh setup_basic         ## >> (snapshot2) zsh, .zshrc, wsl.conf, etc.
$HOME/sProvision/provision_debian.sh setup_dev           ## >> (snapshot3) docker, emacs, miniconda, prompt, etc.
$HOME/sProvision/provision_debian.sh setup_full          ## >> (snapshot4) conda {pylint, ...}
`
