# ── Navigation ────────────────────────────────────────────────────────────────
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias ~='cd ~'
alias -- -='cd -'

# ── ls / eza ──────────────────────────────────────────────────────────────────
if command -v eza &>/dev/null; then
  alias ls='eza --group-directories-first'
  alias l='eza -l --git --group-directories-first'
  alias ll='eza -la --git --group-directories-first'
  alias la='eza -a --group-directories-first'
  alias lt='eza --tree --level=3 --group-directories-first'
  alias llt='eza --tree --level=3 -la --git'
else
  alias ls='ls -G'
  alias l='ls -lhF'
  alias ll='ls -lahF'
  alias la='ls -AF'
fi

# ── bat ───────────────────────────────────────────────────────────────────────
# `cat` is left as the standard cat. Use `b` for syntax-highlighted output,
# or `bat` directly. bat is still used by fzf previews and MANPAGER.
if command -v bat &>/dev/null; then
  alias b='bat'
fi

# ── Git ───────────────────────────────────────────────────────────────────────
alias g='git'
alias gs='git status -sb'
alias ga='git add'
alias gc='git commit'
alias gca='git commit --amend'
alias gco='git checkout'
alias gb='git branch'
alias gd='git diff'
alias gds='git diff --staged'
alias gl='git log --oneline --graph --decorate --color'
alias gll='git log --graph --pretty=format:"%C(magenta)%h%Creset -%C(red)%d%Creset %s %C(dim green)(%cr) %C(cyan)<%an>%Creset" --abbrev-commit'
alias gp='git push'
alias gpl='git pull'
alias gst='git stash'
alias gsp='git stash pop'

# ── Docker ────────────────────────────────────────────────────────────────────
alias d='docker'
alias dc='docker compose'
alias dps='docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"'
alias dclean='docker system prune -f'

# ── Kubernetes ────────────────────────────────────────────────────────────────
alias k='kubectl'
alias kgp='kubectl get pods'
alias kgpa='kubectl get pods -A'
alias kgs='kubectl get svc'
alias kgn='kubectl get nodes'
alias kd='kubectl describe'
alias kl='kubectl logs'
alias ke='kubectl exec -it'
alias kctx='kubectl config use-context'
alias kns='kubectl config set-context --current --namespace'

# ── Utilities ─────────────────────────────────────────────────────────────────
alias grep='grep --color=auto'
alias diff='diff --color=auto'
alias df='df -h'
alias du='du -h'
alias mkdir='mkdir -pv'
alias watch='watch -c'
alias myip='curl -s ifconfig.me && echo'
alias localip='ipconfig getifaddr en0'
alias ports='lsof -i -P -n | grep LISTEN'
alias copy='pbcopy'
alias paste='pbpaste'
alias o='open'
alias oo='open .'
alias reload='exec -l bash'
alias path='echo "$PATH" | tr ":" "\n"'
alias vi='nvim'
alias vim='nvim'
alias py='python3'
alias pip='pip3'
alias brewup='brew update && brew upgrade && brew cleanup'
