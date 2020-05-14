# ~/.bashrc

case $- in
    *i*)
        ;;
    *)  return            # Insert commands for non-interactive shells here
        ;;
esac

if shopt -q login_shell; then # Insert commands for login shells here
#  echo "Redirect from BASH"
#  export SHELL=/bin/zsh  
#  exec /bin/zsh -l
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
if [[ -d /broad ]]; then
    use Anaconda
    use UGER
    use .google-cloud-sdk

    #use Python-2.7
    source ~/dx-toolkit/environment
    dx login --token  gTJ25OGvoOPGbRKISuEQRuS3iPV9eNrC --noprojects  # samar_all_20200423
    #dx select project-FPgF38Q0bg5f24jb13v65Pf1     # LASV_NIG_METAGENOMICS_part_deux
    dx select project-FpJPppj0KQf5X20VBPYJX9Gp     # H3_KGH_SARS-COV-2 BATCH 2

    . /broad/software/free/Linux/redhat_6_x86_64/pkgs/anaconda_2.3.0-jupyter/etc/profile.d/conda.sh
fi


########## PLUGINS  ####################


########## ALIASES  ####################
alias ls='ls -aF --color=auto'

alias passwd=yppasswd


########## PATH  #######################
#if [[ -d ~/ncbi-toolkit ]] ; then
#   export PATH=${PATH}:/home/samar/ncbi-toolkit
#fi


########## SSH  ########################
if [ -z "$SSH_AUTH_SOCK" ] ; then
    eval `ssh-agent -s -t 1h`     # timeout in an hour
fi

########## FINALIZE ####################
if type "neofetch" &> /dev/null; then
    neofetch
fi
