# ── fzf ───────────────────────────────────────────────────────────────────────
if command -v fzf &>/dev/null; then
  eval "$(fzf --bash)"
  export FZF_DEFAULT_OPTS="
    --height=50% --layout=reverse --border=rounded --info=inline --cycle
    --prompt='> ' --pointer='>' --marker='*'
    --color=fg:#cdd6f4,bg:#1e1e2e,hl:#89b4fa
    --color=fg+:#cdd6f4,bg+:#313244,hl+:#89b4fa
    --color=info:#a6e3a1,prompt:#cba6f7,pointer:#f38ba8
    --color=marker:#a6e3a1,spinner:#f38ba8,header:#89b4fa
    --color=border:#313244
    --bind=ctrl-d:preview-down,ctrl-u:preview-up,ctrl-a:select-all"
  if command -v fd &>/dev/null; then
    export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
    export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
    export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'
  fi
  export FZF_CTRL_T_OPTS="--preview '([[ -d {} ]] && eza --tree --color=always --icons {}) || bat --color=always --line-range :100 {} 2>/dev/null || echo {}'"
  export FZF_ALT_C_OPTS="--preview 'eza --tree --color=always --icons {} | head -50'"
fi

# ── direnv ────────────────────────────────────────────────────────────────────
if command -v direnv &>/dev/null; then eval "$(direnv hook bash)"; fi

# ── zoxide ────────────────────────────────────────────────────────────────────
if command -v zoxide &>/dev/null; then eval "$(zoxide init bash)"; fi

# ── delta (git pager) ─────────────────────────────────────────────────────────
if command -v delta &>/dev/null; then export GIT_PAGER='delta'; fi

# ── Starship prompt ───────────────────────────────────────────────────────────
if command -v starship &>/dev/null; then eval "$(starship init bash)"; fi
