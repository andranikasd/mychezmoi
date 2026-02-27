# ── Standard bash completion ──────────────────────────────────────────────────
# Requires: brew install bash-completion@2
[[ -r "/opt/homebrew/etc/profile.d/bash_completion.sh" ]] && \
  source "/opt/homebrew/etc/profile.d/bash_completion.sh"

# ── Carapace — rich completions with descriptions for 500+ commands ───────────
# Requires: brew install carapace
# Cached: regenerated only when carapace binary changes or cache is empty.
if command -v carapace &>/dev/null; then
  _cc="$HOME/.cache/carapace_bash.sh"
  if [[ ! -s "$_cc" || "$(command -v carapace)" -nt "$_cc" ]]; then
    mkdir -p "$HOME/.cache"
    carapace _carapace bash > "$_cc" 2>/dev/null || rm -f "$_cc"
  fi
  [[ -s "$_cc" ]] && source "$_cc" 2>/dev/null || true
  unset _cc
fi

# ── Git completion for the 'g' alias ──────────────────────────────────────────
_setup_git_alias_completion() {
  local fn
  fn=$(complete -p git 2>/dev/null | sed -n 's/.*-F \([^ ]*\).*/\1/p')

  case "$fn" in
    _comp_complete_load|_completion_loader|carapace)
      COMP_LINE="git " COMP_POINT=4 COMP_WORDS=(git "") COMP_CWORD=1 \
        "$fn" git "" git 2>/dev/null
      COMPREPLY=()
      fn=$(complete -p git 2>/dev/null | sed -n 's/.*-F \([^ ]*\).*/\1/p')
      ;;
  esac

  if declare -f __git_complete &>/dev/null; then
    __git_complete g __git_main 2>/dev/null || true
    return
  fi

  for fn in __git_wrap__git_main __git_main _git; do
    if declare -f "$fn" &>/dev/null; then
      complete -o bashdefault -o default -o nospace -F "$fn" g
      return
    fi
  done
}
_setup_git_alias_completion
unset -f _setup_git_alias_completion

# ── kubectl — cached completion ───────────────────────────────────────────────
if command -v kubectl &>/dev/null; then
  _kc="$HOME/.cache/kubectl_completion.bash"
  _kv="$HOME/.cache/kubectl_completion.version"
  _kver=$(kubectl version --client 2>/dev/null | head -1)
  if [[ ! -f "$_kc" || "$(< "$_kv" 2>/dev/null)" != "$_kver" ]]; then
    mkdir -p "$HOME/.cache"
    kubectl completion bash > "$_kc" 2>/dev/null
    printf '%s\n' "$_kver" > "$_kv"
  fi
  [[ -f "$_kc" ]] && source "$_kc"
  complete -o default -F __start_kubectl k
  unset _kc _kv _kver
fi

# ── asdf ──────────────────────────────────────────────────────────────────────
[[ -f "/opt/homebrew/opt/asdf/libexec/asdf.sh" ]] && \
  source "/opt/homebrew/opt/asdf/libexec/asdf.sh"
