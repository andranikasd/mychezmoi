# ── Directory helpers ─────────────────────────────────────────────────────────

# Make dir and cd into it
mkcd() { mkdir -p "$@" && cd "$_"; }

# cd then list
cl() { cd "$1" && ll; }

# cd N levels up:  up    → ../   up 3 → ../../../
up() {
  local n="${1:-1}" p=""
  for (( i=0; i<n; i++ )); do p="../$p"; done
  cd "$p"
}

# Open a throw-away temp directory
scratch() {
  local d; d=$(mktemp -d)
  echo "Scratch: $d"
  cd "$d"
}

# ── File helpers ──────────────────────────────────────────────────────────────

# Disk usage sorted descending
dusz() { du -sh "${1:-.}"/* 2>/dev/null | sort -rh | head -20; }

# Serve current directory over HTTP
serve() { python3 -m http.server "${1:-8000}"; }

# Extract any archive
extract() {
  [[ ! -f "$1" ]] && { echo "'$1' is not a valid file"; return 1; }
  case "$1" in
    *.tar.bz2) tar xjf "$1" ;;   *.tar.gz)  tar xzf "$1" ;;
    *.tar.xz)  tar xJf "$1" ;;   *.tar)     tar xf  "$1" ;;
    *.tgz)     tar xzf "$1" ;;   *.bz2)     bunzip2 "$1" ;;
    *.gz)      gunzip  "$1" ;;   *.zip)     unzip   "$1" ;;
    *.7z)      7z x    "$1" ;;   *) echo "'$1' cannot be extracted" ;;
  esac
}

# ── Process helpers ───────────────────────────────────────────────────────────

# Fuzzy kill a process
fkill() {
  local pid
  pid=$(ps -ef | sed 1d | fzf -m --header='Select process to kill' | awk '{print $2}')
  [[ -n "$pid" ]] && echo "$pid" | xargs kill -"${1:-9}" && echo "Killed $pid"
}

# ── Git helpers ───────────────────────────────────────────────────────────────

# Fuzzy stage files
gadd() {
  git status -s | fzf -m --ansi \
    --header='Space to select, Enter to add' \
    --preview 'git diff --color=always {2}' \
    | awk '{print $2}' | xargs git add && git status -sb
}

# Fuzzy checkout branch
gfco() {
  local branch
  branch=$(git branch -a | fzf --height=40% --reverse \
    | sed 's/^[* ]*//' | sed 's|remotes/[^/]*/||')
  [[ -n "$branch" ]] && git checkout "$branch"
}

# ── Misc ──────────────────────────────────────────────────────────────────────

# thefuck — lazy load so Python startup doesn't slow shell init
fuck() { eval "$(thefuck --alias 2>/dev/null)"; fuck "$@"; }