# ── macOS polyfill ────────────────────────────────────────────────────────────
command -v tac &>/dev/null || tac() { tail -r -- "$@"; }

# ── Environment ───────────────────────────────────────────────────────────────
export EDITOR='nvim'
export VISUAL='nvim'
export PAGER='less'
export LESS='-RFXi --mouse'
export LANG='en_US.UTF-8'
export LC_ALL='en_US.UTF-8'
export CLICOLOR=1
GPG_TTY=$(tty); export GPG_TTY

# ── PATH ──────────────────────────────────────────────────────────────────────
export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:$PATH"
export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"
export PATH="$HOME/.antigravity/antigravity/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"
export PATH="/opt/homebrew/opt/node@20/bin:$PATH"  # pinned: update when upgrading Node
export PATH="/opt/homebrew/opt/sqlite/bin:$PATH"
export PATH="/opt/homebrew/opt/icu4c@78/bin:$PATH"  # pinned: required by Ruby/Python native gems
export PATH="/opt/homebrew/opt/icu4c@78/sbin:$PATH"

# ── Compiler flags ────────────────────────────────────────────────────────────
export LDFLAGS="-L/opt/homebrew/lib"
export CPPFLAGS="-I/opt/homebrew/include"

# ── Tool config paths ─────────────────────────────────────────────────────────
export RIPGREP_CONFIG_PATH="$HOME/.config/ripgrep/config"

# ── bat ───────────────────────────────────────────────────────────────────────
if command -v bat &>/dev/null; then
  export MANPAGER="sh -c 'col -bx | bat -l man -p'"
fi
