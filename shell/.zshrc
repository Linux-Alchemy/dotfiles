# ==============================================
# THE OMARCHY ZSH CONFIG
# "Don't Panic."
# ==============================================

# 1. History Configuration
# Zsh doesn't save history by default. We must tell it to.
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt appendhistory
setopt sharehistory     # Share history across terminals instantly
setopt incappendhistory # Write to history file immediately, not at exit

# 2. Completion System
# This enables the fancy Tab-completion
autoload -Uz compinit
compinit

# 3. Import Omarchy Aliases
# We source your existing bash aliases because Zsh is polite and understands them.
if [ -f "$HOME/.local/share/omarchy/default/bash/aliases" ]; then
    source "$HOME/.local/share/omarchy/default/bash/aliases"
fi

# 4. Starship Prompt
# Launch the prompt engine
eval "$(starship init zsh)"

# 4.5 Initialize zoxide
eval "$(zoxide init zsh)"

# 5. Plugins
#
# zsh-autosuggestions plugin
if [[ -f /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh ]]; then
    source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
fi

# syntax highlighting plugin
if [[ -f /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]]; then
    source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fi


# 6. Keybinding Fixes
# Arch/Zsh sometimes confuse the Delete/Home/End keys. This fixes them.
bindkey "^[[3~" delete-char
bindkey "^[[H" beginning-of-line
bindkey "^[[F" end-of-line
# Enable Ctrl+Left/Right Arrow for jumping words
bindkey "^[[1;5C" forward-word
bindkey "^[[1;5D" backward-word

# 7. Aliases
#
alias py="python"
#
# An alias + function to check for venv and activate.
invoke() {
  if [ -d ".venv" ]; then
    source .venv/bin/activate
    echo "The environment has been summoned..."
  else
    echo "There is no power here. No .venv folder either."
  fi
}

# Generated for envman. Do not edit.
[ -s "$HOME/.config/envman/load.sh" ] && source "$HOME/.config/envman/load.sh"
