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
export GPG_TTY=$(tty)

# ── PATH ──────────────────────────────────────────────────────────────────────
export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:$PATH"
export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"
export PATH="$HOME/.antigravity/antigravity/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"
export PATH="/opt/homebrew/opt/node@20/bin:$PATH"
export PATH="/opt/homebrew/opt/sqlite/bin:$PATH"
export PATH="/opt/homebrew/opt/icu4c@78/bin:$PATH"
export PATH="/opt/homebrew/opt/icu4c@78/sbin:$PATH"

# ── Compiler flags ────────────────────────────────────────────────────────────
export LDFLAGS="-L/opt/homebrew/lib"
export CPPFLAGS="-I/opt/homebrew/include"
