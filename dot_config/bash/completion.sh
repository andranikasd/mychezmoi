# ── Standard bash completion ──────────────────────────────────────────────────
[[ -r "/opt/homebrew/etc/profile.d/bash_completion.sh" ]] && \
  source "/opt/homebrew/etc/profile.d/bash_completion.sh"

# ── Git completion for the 'g' alias ─────────────────────────────────────────
for _gfn in __git_wrap__git_main _git __git_main; do
  if declare -f "$_gfn" &>/dev/null; then
    complete -o bashdefault -o default -o nospace -F "$_gfn" g
    break
  fi
done
unset _gfn

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

# ── gum Tab completion (bash 4+) ─────────────────────────────────────────────
if command -v gum &>/dev/null && [[ "${BASH_VERSINFO[0]}" -ge 4 ]]; then

  export GUM_FILTER_INDICATOR_FOREGROUND="#cba6f7"
  export GUM_FILTER_SELECTED_PREFIX_FOREGROUND="#a6e3a1"
  export GUM_FILTER_UNSELECTED_PREFIX_FOREGROUND="#585b70"
  export GUM_FILTER_MATCH_FOREGROUND="#89b4fa"
  export GUM_FILTER_PROMPT_FOREGROUND="#cba6f7"
  export GUM_FILTER_PROMPT="  "
  export GUM_FILTER_INDICATOR="▶ "
  export GUM_FILTER_SELECTED_PREFIX="✓ "
  export GUM_FILTER_UNSELECTED_PREFIX="  "
  export GUM_FILTER_HEIGHT=15
  export GUM_FILTER_BORDER="rounded"
  export GUM_FILTER_BORDER_FOREGROUND="#313244"
  export GUM_FILTER_HEADER_FOREGROUND="#a6adc8"

  _gum_tab() {
    local line="${READLINE_LINE:0:$READLINE_POINT}"
    local cur cmd selected

    [[ "$line" =~ [[:space:]]$ ]] && cur="" || cur="${line##*[[:space:]]}"
    local prefix="${line:0:${#line}-${#cur}}"
    cmd="${line%%[[:space:]]*}"

    # Try registered completion function first (git, kubectl, docker, etc.)
    local -a _comps=()
    local _compfunc
    _compfunc=$(complete -p -- "$cmd" 2>/dev/null | sed -n 's/.*-F \([^ ]*\).*/\1/p')
    if [[ -n "$_compfunc" ]]; then
      local -a _cwords=()
      read -ra _cwords <<< "$line"
      [[ "$line" =~ [[:space:]]$ ]] && _cwords+=('')
      local _ccword=$(( ${#_cwords[@]} - 1 ))
      local _cprev="${_cwords[$(( _ccword - 1 ))]:-}"
      COMP_LINE="$line" COMP_POINT="${#line}" \
        COMP_WORDS=("${_cwords[@]}") COMP_CWORD="$_ccword" \
        "$_compfunc" "$cmd" "$cur" "$_cprev" 2>/dev/null
      _comps=("${COMPREPLY[@]}")
    fi

    if [[ ${#_comps[@]} -eq 1 ]]; then
      selected="${_comps[0]}"
    elif [[ ${#_comps[@]} -gt 1 ]]; then
      selected=$(printf '%s\n' "${_comps[@]}" \
        | gum filter --value="$cur" --header="$cmd")
    else
      case "$cmd" in
        cd|pushd|rmdir)
          selected=$(fd --type d --hidden --follow --exclude .git --exclude node_modules . 2>/dev/null \
            | gum filter --value="$cur" --header="cd  directory")
          [[ -n "$selected" ]] && selected="${selected%/}/"
          ;;
        *)
          selected=$(fd --hidden --follow --exclude .git . 2>/dev/null \
            | gum filter --value="$cur" --header="  file / directory")
          [[ -n "$selected" && -d "$selected" ]] && selected="${selected%/}/"
          ;;
      esac
    fi

    if [[ -n "$selected" ]]; then
      READLINE_LINE="${prefix}${selected}"
      READLINE_POINT="${#READLINE_LINE}"
    fi
  }

  bind -x '"\t": _gum_tab'
fi