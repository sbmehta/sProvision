# ~/.bashrc

case $- in
    *i*)
        ;;
    *)  return            # Insert commands for non-interactive shells here
        ;;
esac

if shopt -q login_shell; then # Insert commands for login shells here
  echo "Redirect from BASH"
  export SHELL=/bin/zsh  
  exec /bin/zsh -l
fi

echo "Configure BASH"

########## HISTORY  ####################
HISTCONTROL=ignoreboth  # ignore dup lines or lines starting with space
shopt -s histappend     # append to the history file, don't overwrite it
HISTSIZE=5000
HISTFILESIZE=5000
HISTFILE=~/.bash_history


########## PROMPT  #####################
# set a fancy prompt (non-color, unless we know we "want" color)
color_prompt=yes
if [ "$color_prompt" = yes ]; then
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u\[\033[1;37m\]@\h:\[\033[00;37m\]\w\[\033[00m\]\$ '
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt


########## DISPLAY #####################
shopt -s checkwinsize # check win size after each command and update LINES+COLUMNS if necessary

if [ -x /usr/bin/dircolors ]; then # color support for ls
    test -r ~/dotfiles/.dir_colors && eval "$(dircolors -b ~/dotfiles/.dir_colors)" || eval "$(dircolors -b)"
fi

# Colorize GCC warnings and errors:
# export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'


########## COMPLETION  #################
shopt -s extglob

# If set, the pattern "**" used in a pathname expansion context will match all files and zero or more directories and subdirectories.
#shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# enable programmable completion
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi


########## BROAD environment  ##########
# On Broad servers, most of this is set up in .bashrc (and .bash_login, if not bypassed)
use Anaconda
use UGER

#use Python-2.7
source ~/dx-toolkit/environment
#dx login --token 1AeDbmL5hBVlsdEeqfuF9GK2Hbeq8lF3 --noprojects  # samar's admin token through 2018-08-08
#dx select project-F5z8Jpj0Yqp6fFpXGfJVBg3b                     # LASV/FUO 15-17 project
#dx select project-FBFkzxj0YJ80114YGQ0yJZJx                     # CLEAN LASV/FUO 15-17 project
#dx select project-Bq29k680jy1JF3gvkk3Gjf11                      # Sabeti_Lab project

. /broad/software/free/Linux/redhat_6_x86_64/pkgs/anaconda_2.3.0-jupyter/etc/profile.d/conda.sh


########## PLUGINS  ####################


########## ALIASES  ####################
alias ls='ls -aF --color=auto'

alias passwd=yppasswd

########## PATH  #######################
export PATH="$HOME/anaconda3/bin:$PATH"


########## FINALIZE ####################
if type "neofetch" &> /dev/null; then
    neofetch
fi
