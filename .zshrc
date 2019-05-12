# ~/.zshrc: executed by zsh(1)


if [[ ! -o interactive ]]; then
   return                         # Insert commands for non-interactive shells here.
fi

if [[ -o login ]]; then
  echo "Login ZSH"             # Insert commands for login shells here.
fi
echo "Configuring ZSH"


########## HISTORY  ####################
setopt histignorealldups sharehistory
HISTSIZE=5000
SAVEHIST=5000
HISTFILE=~/.zsh_history


########## PROMPT  #####################
autoload -Uz promptinit
autoload -U colors && colors
promptinit
PROMPT="%{$fg_bold[green]%}%n%F{white}@%F{146}%M%{$fg_no_bold[white]%}:%~> "
RPROMPT="%*"


########## DISPLAY #####################
if [ -x /usr/bin/dircolors ]; then
    test -r ~/dotfiles/.dir_colors && eval "$(dircolors -b ~/dotfiles/.dir_colors)" || eval "$(dircolors -b)"
fi


########## COMPLETION  #################
autoload -Uz compinit
compinit -u

zstyle ':completion:*' auto-description 'specify: %d'
zstyle ':completion:*' completer _expand _complete _correct _approximate
zstyle ':completion:*' format 'Completing %d'
zstyle ':completion:*' group-name ''
zstyle ':completion:*' menu select
eval "$(dircolors -b)"
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
if [[ -f /broad/software/dotkit/etc/systype ]]; then

  # Modified from Broad's default .bashrc -- n ote this won't work for SUSE systems

  # Set up dotkit
  eval `/broad/software/dotkit/init -b`
  
  if [[ -o login ]]; then          # Login shells
      if [[ "x$RUN_ONCE" == "x"  ]]; then
          export RUN_ONCE="1"
          # Load the default dotkits to set up basic Broad user environment
          use -q default
      fi
  fi
  
  if [[ -o interactive ]]; then    # Interactive shells
      use -q default++
  fi
fi


########## PLUGINS  ####################
eval "$(ssh-agent -s)"

########## ALIASES  ####################
alias ls='ls -aF --color=auto'

alias sjupyter='jupyter notebook --no-browser --port=8889 &'


########## PATH  #######################
export PATH="$HOME/anaconda3/bin:$PATH"


########## FINALIZE ####################
if type "neofetch" &> /dev/null; then
    neofetch
fi
