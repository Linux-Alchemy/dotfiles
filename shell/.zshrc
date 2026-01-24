# ==============================================
# THE OMARCHY ZSH CONFIG
# ==============================================

# 1. History Configuration
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
# source existing bash aliases because Zsh is polite and understands them.
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
# Arch/Zsh sometimes confuse the Delete/Home/End keys.
bindkey "^[[3~" delete-char
bindkey "^[[H" beginning-of-line
bindkey "^[[F" end-of-line
# Enable Ctrl+Left/Right Arrow for jumping words
bindkey "^[[1;5C" forward-word
bindkey "^[[1;5D" backward-word
# Tmux keybind fixes
bindkey "^[[1~" beginning-of-line
bindkey "^[[4~" end-of-line


# 7. Aliases

alias la='eza -lah --icons --group-directories-first'
alias tree='eza --tree --icons --group-directories-first'

alias py="python"
alias pvenv="python3 -m venv .venv"

# ==============================================
# PYTHON PROJECT MANAGEMENT
# ==============================================

# Initialize a new Python project with modern workflow
# Creates: .venv, .gitignore, pyproject.toml, requirements.txt, requirements-dev.txt
pyinit() {
  local project_name=$(basename "$PWD" | tr '-' '_')

  echo "Initializing Python project: $project_name"

  # Create virtual environment
  python3 -m venv .venv

  # Setup gitignore
  touch .gitignore
  grep -qxF ".venv/" .gitignore || echo ".venv/" >> .gitignore
  grep -qxF "*.egg-info/" .gitignore || echo "*.egg-info/" >> .gitignore
  grep -qxF "__pycache__/" .gitignore || echo "__pycache__/" >> .gitignore

  # Upgrade pip and install pip-tools
  .venv/bin/python -m pip install -U pip pip-tools -q

  # Create pyproject.toml
  cat > pyproject.toml << EOF
[build-system]
requires = ["setuptools>=61.0"]
build-backend = "setuptools.build_meta"

[project]
name = "$project_name"
version = "0.1.0"
requires-python = ">=3.10"
dependencies = []

[project.optional-dependencies]
dev = ["ipython", "pytest", "ruff"]

[tool.ruff]
line-length = 88

[tool.pytest.ini_options]
testpaths = ["tests"]
EOF

  # Generate lockfiles
  .venv/bin/pip-compile -q --strip-extras -o requirements.txt pyproject.toml
  .venv/bin/pip-compile -q --strip-extras --extra dev -o requirements-dev.txt pyproject.toml

  # Install everything
  .venv/bin/pip-sync -q requirements.txt requirements-dev.txt

  echo ""
  echo "Project initialized. Files created:"
  echo "  - .venv/              (virtual environment)"
  echo "  - .gitignore          (updated)"
  echo "  - pyproject.toml      (add dependencies here)"
  echo "  - requirements.txt    (lockfile - don't edit)"
  echo "  - requirements-dev.txt (dev lockfile - don't edit)"
  echo ""
  echo "Next steps:"
  echo "  1. Run 'invoke' to activate the environment"
  echo "  2. Add dependencies to pyproject.toml [project] dependencies = []"
  echo "  3. Run 'pysync' to install them"
}

# Recompile and sync dependencies after editing pyproject.toml
pysync() {
  if [ ! -f "pyproject.toml" ]; then
    echo "No pyproject.toml found. Are you in a project directory?"
    return 1
  fi

  if [ ! -d ".venv" ]; then
    echo "No .venv found. Run pyinit first."
    return 1
  fi

  echo "Recompiling dependencies..."
  .venv/bin/pip-compile -q --strip-extras -o requirements.txt pyproject.toml
  .venv/bin/pip-compile -q --strip-extras --extra dev -o requirements-dev.txt pyproject.toml

  echo "Syncing environment..."
  .venv/bin/pip-sync -q requirements.txt requirements-dev.txt

  echo "Dependencies updated and synced."
}

# Migrate an existing project from requirements.txt to pyproject.toml
pymigrate() {
  if [ ! -f "requirements.txt" ]; then
    echo "No requirements.txt found to migrate."
    return 1
  fi

  if [ -f "pyproject.toml" ]; then
    echo "pyproject.toml already exists. Aborting to avoid overwrite."
    return 1
  fi

  local project_name=$(basename "$PWD" | tr '-' '_')

  echo "Migrating project: $project_name"

  # Ensure pip-tools is installed
  if [ ! -f ".venv/bin/pip-compile" ]; then
    .venv/bin/python -m pip install -U pip pip-tools -q
  fi

  # Create pyproject.toml template
  cat > pyproject.toml << EOF
[build-system]
requires = ["setuptools>=61.0"]
build-backend = "setuptools.build_meta"

[project]
name = "$project_name"
version = "0.1.0"
requires-python = ">=3.10"
dependencies = [
    # TODO: Add your DIRECT dependencies here
    # Check requirements.txt.bak for reference - but only add what YOU installed
    # Example: "requests", "flask>=2.0"
]

[project.optional-dependencies]
dev = ["ipython", "pytest", "ruff"]

[tool.ruff]
line-length = 88

[tool.pytest.ini_options]
testpaths = ["tests"]
EOF

  # Backup old requirements.txt
  mv requirements.txt requirements.txt.bak

  echo ""
  echo "Created pyproject.toml for '$project_name'"
  echo ""
  echo "Old requirements.txt backed up to: requirements.txt.bak"
  echo ""
  echo "Next steps:"
  echo "  1. Edit pyproject.toml - add ONLY your direct dependencies"
  echo "  2. Run 'pysync' to generate new lockfiles and install"
  echo "  3. Delete requirements.txt.bak once you're happy"
}

# Activate the virtual environment
invoke() {
  if [ -d ".venv" ]; then
    source .venv/bin/activate
    echo "The environment has been summoned..."
  else
    echo "There is no power here. No .venv folder either."
  fi
}

# Start IPython REPL with activated environment
repl() {
  invoke
  python -m IPython
}

# Generated for envman. Do not edit.
[ -s "$HOME/.config/envman/load.sh" ] && source "$HOME/.config/envman/load.sh"
