# ─────────────────────────────────────────────────────────────────────────────
#  Brewfile — managed by chezmoi
#  Apply: brew bundle --file ~/dotfiles/Brewfile
# ─────────────────────────────────────────────────────────────────────────────

# ── Shell & terminal ──────────────────────────────────────────────────────────
brew "bash"                # bash 5 (macOS ships 3.2)
brew "bash-completion@2"  # programmable tab completion (required for git, kubectl, etc.)
brew "tmux"
brew "starship"       # prompt
brew "gum"            # interactive shell UI (tab completion)
brew "carapace"       # shell completions with descriptions (500+ commands)
brew "direnv"         # per-directory env vars
brew "zoxide"         # smart cd
brew "thefuck"        # command correction

# ── File & search ─────────────────────────────────────────────────────────────
brew "fzf"            # fuzzy finder (Ctrl+R, Ctrl+T, Alt+C)
brew "fd"             # fast find
brew "eza"            # better ls
brew "bat"            # better cat
brew "tree"
brew "gnu-sed"        # gsed (BSD sed is missing -r flag)
brew "gawk"
brew "ripgrep"

# ── Git ───────────────────────────────────────────────────────────────────────
brew "git"
brew "git-delta"      # syntax-highlighted diffs
brew "lazygit"        # TUI git client

# ── Editors ───────────────────────────────────────────────────────────────────
brew "neovim"

# ── Cloud & infra ─────────────────────────────────────────────────────────────
brew "awscli"
brew "helm"
brew "kubernetes-cli" # kubectl
brew "krew"           # kubectl plugin manager
brew "k9s"            # k8s TUI
brew "kind"           # local k8s clusters
brew "colima"         # container runtime (Docker Desktop alternative)

# ── Languages & runtimes ──────────────────────────────────────────────────────
brew "asdf"           # version manager (node, python, ruby, go, ...)
brew "go"
brew "node@20"

# ── Utilities ─────────────────────────────────────────────────────────────────
brew "chezmoi"        # dotfile manager
brew "jq"
brew "yq"
brew "wget"
brew "curl"
brew "htop"
brew "watch"
brew "mosh"           # mobile shell (SSH over UDP)
brew "dos2unix"
brew "cowsay"

# ── Fonts ─────────────────────────────────────────────────────────────────────
cask "font-jetbrains-mono-nerd-font"

# ── Apps ──────────────────────────────────────────────────────────────────────
# Note: install manually on a new Mac to avoid sudo prompts during bootstrap
# cask "iterm2"
# cask "visual-studio-code"
