# ~/.zshrc: executed by zsh(1)

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.            
# Initialization code that may require console input (password prompts, [y/n]               
# confirmations, etc.) must go above this block; everything else may go below.              
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then      
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"               
fi                                                                                          

if [[ ! -o interactive ]]; then
   # Insert commands for non-interactive shells here.
   return
fi

if [[ -o login ]]; then
    # Insert commands to be run at login only here.
    echo "Login ZSH"
fi
echo "Configuring ZSH"

########## HISTORY  ####################
setopt histignorealldups sharehistory
HISTSIZE=5000
SAVEHIST=5000
HISTFILE=~/.zsh_history

########## PROMPT (if Powerlevel10k fails)
autoload -U colors && colors
autoload -Uz promptinit && promptinit
PROMPT="%{$fg_bold[green]%}%n%F{white}@%F{146}%M%{$fg_no_bold[white]%}:%~> "
RPROMPT="%*"

########## DISPLAY #####################
if [[ -x /usr/bin/dircolors ]]; then
    [ -r ~/dotfiles/.dir_colors ] && eval "$(dircolors -b ~/dotfiles/.dir_colors)" || eval "$(dircolors -b)"
fi

########## COMPLETION  #################
fpath+=$HOME/.config/conda-zsh-completion
fpath+=$HOME/.config/docker-zsh-completion
autoload -Uz compinit && compinit -u

zstyle ':completion:*' auto-description 'specify: %d'
zstyle ':completion:*' completer _expand _complete _correct _approximate
zstyle ':completion::complete:*' use-cache 1
zstyle ':completion:*' format 'Completing %d'
zstyle ':completion:*' group-name ''
zstyle ':completion:*' menu select
# eval "$(dircolors -b)"
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' list-colors ''
zstyle ':completion:*' list-prompt %SAt %p: Hit TAB for more, or the character to insert%s
zstyle ':completion:*' matcher-list '' 'm:{a-z}={A-Z}' 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=* l:|=*'
zstyle ':completion:*' menu select=long
zstyle ':completion:*' select-prompt %SScrolling active: current selection at %p%s
zstyle ':completion:*' use-compctl false
zstyle ':completion:*' verbose true

zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;31'
zstyle ':completion:*:kill:*' command 'ps -u $USER -o pid,%cpu,tty,cputime,cmd'

zstyle ":conda_zsh_completion:*" use-groups true

# create a zkbd compatible hash;
# to add other keys to this hash, see: man 5 terminfo
typeset -A key
key[Home]=${terminfo[khome]}
key[End]=${terminfo[kend]}
key[Insert]=${terminfo[kich1]}
key[Delete]=${terminfo[kdch1]}
key[Up]=${terminfo[kcuu1]}
key[Down]=${terminfo[kcud1]}
key[Left]=${terminfo[kcub1]}
key[Right]=${terminfo[kcuf1]}
key[PageUp]=${terminfo[kpp]}
key[PageDown]=${terminfo[knp]}

# setup keys accordingly
[[ -n "${key[Home]}"     ]]  && bindkey  "${key[Home]}"     beginning-of-line
[[ -n "${key[End]}"      ]]  && bindkey  "${key[End]}"      end-of-line
[[ -n "${key[Insert]}"   ]]  && bindkey  "${key[Insert]}"   overwrite-mode
[[ -n "${key[Delete]}"   ]]  && bindkey  "${key[Delete]}"   delete-char
[[ -n "${key[Up]}"       ]]  && bindkey  "${key[Up]}"       history-beginning-search-backward
[[ -n "${key[Down]}"     ]]  && bindkey  "${key[Down]}"     history-beginning-search-forward
[[ -n "${key[Left]}"     ]]  && bindkey  "${key[Left]}"     backward-char
[[ -n "${key[Right]}"    ]]  && bindkey  "${key[Right]}"    forward-char
[[ -n "${key[PageUp]}"   ]]  && bindkey  "${key[PageUp]}"   beginning-of-buffer-or-history
[[ -n "${key[PageDown]}" ]]  && bindkey  "${key[PageDown]}" end-of-buffer-or-history

# Use emacs keybindings even if our EDITOR is set to vi
bindkey -e

# Finally, make sure the terminal is in application mode, when zle is
# active. Only then are the values from $terminfo valid.
if (( ${+terminfo[smkx]} )) && (( ${+terminfo[rmkx]} )); then
    function zle-line-init () {
        #printf '%s' "${terminfo[smkx]}"
	echoti smkx
    }
    function zle-line-finish () {
        #printf '%s' "${terminfo[rmkx]}"
	echoti rmkx
    }
    zle -N zle-line-init
    zle -N zle-line-finish
fi

########## BROAD environment  ##########
#if [[ -f /broad/software/dotkit/etc/systype ]]; then
#
#   # Modified from Broad's default .bashrc -- note this won't work for SUSE systems
#
#   # Set up dotkit
#    eval `/broad/software/dotkit/init -b`
#  
#   if [[ -o login ]]; then          # Login shells
#       if [[ "x$RUN_ONCE" == "x"  ]]; then
#           export RUN_ONCE="1"
#           # Load the default dotkits to set up basic Broad user environment
#           use -q default
#       fi
#   fi
# 
#   if [[ -o interactive ]]; then    # Interactive shells
#       use -q default++
#   fi
# fi


########## ALIASES  ####################
alias ls='ls -aF --color=auto'

########## PATH  #######################
#export PATH="$HOME/.local/bin:$PATH"

########## SSH  ########################
eval $(keychain --timeout 60 --eval id_rsa_github)

## without using keychain: (though this doesn't reuse agents)
#if [ -z "$SSH_AUTH_SOCK" ] ; then
#    eval `ssh-agent -s -t 1h`
#    ssh-add
#fi

########## Biosyntax ###################
export HIGHLIGHT="/usr/share/source-highlight"
export LESSOPEN="| $HIGHLIGHT/src-hilite-lesspipe-bio.sh %s"
export LESS=" -R "

alias lessbio='less -NSi -# 10'

# Explicit call of  <file format>-less for piping data
# i.e:  samtools view -h aligned_hits.bam | sam-less
# Core syntaxes (default)
alias clustal-less='source-highlight -f esc --lang-def=$HIGHLIGHT/clustal.lang --outlang-def=$HIGHLIGHT/bioSyntax.outlang     --style-file=$HIGHLIGHT/fasta.style | lessbio'
alias bed-less='source-highlight     -f esc --lang-def=$HIGHLIGHT/bed.lang     --outlang-def=$HIGHLIGHT/bioSyntax.outlang     --style-file=$HIGHLIGHT/sam.style   | lessbio'
alias fa-less='source-highlight      -f esc --lang-def=$HIGHLIGHT/fasta.lang   --outlang-def=$HIGHLIGHT/bioSyntax.outlang     --style-file=$HIGHLIGHT/fasta.style | lessbio'
alias fq-less='source-highlight      -f esc --lang-def=$HIGHLIGHT/fastq.lang   --outlang-def=$HIGHLIGHT/bioSyntax.outlang     --style-file=$HIGHLIGHT/fasta.style | lessbio'
alias gtf-less='source-highlight     -f esc --lang-def=$HIGHLIGHT/gtf.lang     --outlang-def=$HIGHLIGHT/bioSyntax-vcf.outlang --style-file=$HIGHLIGHT/vcf.style   | lessbio'
alias pdb-less='source-highlight     -f esc --lang-def=$HIGHLIGHT/pdb.lang     --outlang-def=$HIGHLIGHT/bioSyntax-vcf.outlang --style-file=$HIGHLIGHT/pdb.style   | lessbio'
alias sam-less='source-highlight     -f esc --lang-def=$HIGHLIGHT/sam.lang     --outlang-def=$HIGHLIGHT/bioSyntax.outlang     --style-file=$HIGHLIGHT/sam.style   | lessbio'
alias vcf-less='source-highlight     -f esc --lang-def=$HIGHLIGHT/vcf.lang     --outlang-def=$HIGHLIGHT/bioSyntax-vcf.outlang --style-file=$HIGHLIGHT/vcf.style   | lessbio'
alias bam-less='sam-less'

# Auxillary syntaxes (uncomment to activate)
#alias fai-less='source-highlight      -f esc --lang-def=$HIGHLIGHT/faidx.lang    --outlang-def=$HIGHLIGHT/bioSyntax.outlang   --style-file=$HIGHLIGHT/sam.style   | lessbio'
#alias flagstat-less='source-highlight -f esc --lang-def=$HIGHLIGHT/flagstat.lang --outlang-def=$HIGHLIGHT/bioSyntax.outlang   --style-file=$HIGHLIGHT/sam.style   | lessbio'


########## POWERLEVEL10k ###############
[[ -d "$HOME/powerlevel10k" ]] && source "$HOME/powerlevel10k/powerlevel10k.zsh-theme"

[[ ! -f "$HOME/.p10k.zsh" ]] || source "$HOME/.p10k.zsh"    # To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.

########## FINALIZE ####################
if type "neofetch" &> /dev/null; then
    neofetch
fi
cd ~


if [ -d "$HOME/miniconda" ] ; then
    # >>> conda initialize >>>
    # !! Contents within this block are managed by 'conda init' !!
    __conda_setup="$('/home/samar/miniconda/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
    if [ $? -eq 0 ]; then
	eval "$__conda_setup"
    else
	if [ -f "/home/samar/miniconda/etc/profile.d/conda.sh" ]; then
	    . "/home/samar/miniconda/etc/profile.d/conda.sh"
	else
	    export PATH="/home/samar/miniconda/bin:$PATH"
	fi
    fi
    unset __conda_setup
    # <<< conda initialize <<<
fi
