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
  # -s: only source if file exists AND is non-empty
  [[ -s "$_cc" ]] && source "$_cc" 2>/dev/null || true
  unset _cc
fi

# ── Git completion for the 'g' alias ─────────────────────────────────────────
# bash-completion@2 and carapace both lazy-load completions.  We trigger the
# load here so the real completion function is known and can be copied to 'g'.
_setup_git_alias_completion() {
  local fn
  fn=$(complete -p git 2>/dev/null | sed -n 's/.*-F \([^ ]*\).*/\1/p')

  # Trigger any lazy-loader (bash-completion v2 = _comp_complete_load, etc.)
  case "$fn" in
    _comp_complete_load|_completion_loader|carapace)
      COMP_LINE="git " COMP_POINT=4 COMP_WORDS=(git "") COMP_CWORD=1 \
        "$fn" git "" git 2>/dev/null
      COMPREPLY=()
      fn=$(complete -p git 2>/dev/null | sed -n 's/.*-F \([^ ]*\).*/\1/p')
      ;;
  esac

  # git's own __git_complete helper is the most reliable way to alias
  if declare -f __git_complete &>/dev/null; then
    __git_complete g __git_main 2>/dev/null || true
    return
  fi

  # Fallback: directly copy the registered function to 'g'
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

# ── gum Tab completion (bash 4+ required for bind -x) ────────────────────────
# Tab opens a live-filtered gum picker populated by:
#   • The command's registered completion function (bash-completion@2 / carapace)
#   • Carapace provides "word\tdescription" pairs — shown aligned in gum
#   • Fallback: fd file/directory picker when no completion is registered
if command -v gum &>/dev/null && [[ "${BASH_VERSINFO[0]}" -ge 4 ]]; then

  export GUM_FILTER_TEXT_FOREGROUND="#cdd6f4"            # list item text (white)
  export GUM_FILTER_CURSOR_TEXT_FOREGROUND="#cdd6f4"     # selected item text
  export GUM_FILTER_MATCH_FOREGROUND="#89b4fa"           # matched chars highlight
  export GUM_FILTER_INDICATOR_FOREGROUND="#cba6f7"       # cursor indicator
  export GUM_FILTER_SELECTED_PREFIX_FOREGROUND="#a6e3a1" # checked item prefix
  export GUM_FILTER_UNSELECTED_PREFIX_FOREGROUND="#585b70"
  export GUM_FILTER_PROMPT_FOREGROUND="#cba6f7"
  export GUM_FILTER_PLACEHOLDER_FOREGROUND="#585b70"
  export GUM_FILTER_HEADER_FOREGROUND="#a6adc8"
  export GUM_FILTER_BORDER_FOREGROUND="#45475a"
  export GUM_FILTER_PROMPT="  "
  export GUM_FILTER_INDICATOR="▶ "
  export GUM_FILTER_SELECTED_PREFIX="✓ "
  export GUM_FILTER_UNSELECTED_PREFIX="  "
  export GUM_FILTER_HEIGHT=15
  export GUM_FILTER_BORDER="rounded"

  _gum_tab() {
    local line="${READLINE_LINE:0:$READLINE_POINT}"
    local cur cmd selected

    [[ "$line" =~ [[:space:]]$ ]] && cur="" || cur="${line##*[[:space:]]}"
    local prefix="${line:0:${#line}-${#cur}}"
    cmd="${line%%[[:space:]]*}"

    # ── 1. Gather completions from the registered function ────────────────────
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
      COMPREPLY=()

      # bash-completion v2 lazy-loader: re-check if the real fn is now registered
      if [[ ${#_comps[@]} -eq 0 ]]; then
        local _realfunc
        _realfunc=$(complete -p -- "$cmd" 2>/dev/null | sed -n 's/.*-F \([^ ]*\).*/\1/p')
        if [[ -n "$_realfunc" && "$_realfunc" != "$_compfunc" ]]; then
          COMP_LINE="$line" COMP_POINT="${#line}" \
            COMP_WORDS=("${_cwords[@]}") COMP_CWORD="$_ccword" \
            "$_realfunc" "$cmd" "$cur" "$_cprev" 2>/dev/null
          _comps=("${COMPREPLY[@]}")
          COMPREPLY=()
        fi
      fi
    fi

    # ── 2. Save terminal state (gum is a TUI and may alter terminal modes) ────
    local _stty_save
    _stty_save=$(stty -g 2>/dev/null)

    # ── 3. Show picker ────────────────────────────────────────────────────────
    if [[ ${#_comps[@]} -eq 1 ]]; then
      # Exactly one match — accept without opening gum
      selected="${_comps[0]%%$'\t'*}"   # strip description if carapace added one

    elif [[ ${#_comps[@]} -gt 1 ]]; then
      # Detect carapace-style "word\tdescription" pairs
      local _has_desc=false _c
      for _c in "${_comps[@]}"; do
        [[ "$_c" == *$'\t'* ]] && { _has_desc=true; break; }
      done

      if [[ "$_has_desc" == true ]]; then
        # Align descriptions with column(1), then strip the description after
        # the user picks — column uses 2-space padding between fields.
        selected=$(printf '%s\n' "${_comps[@]}" \
          | column -t -s $'\t' \
          | gum filter --value="$cur" --header=" $cmd" 2>/dev/null)
        # Strip everything from the first double-space onward (the description)
        selected="${selected%%  *}"
        selected="${selected%% }"    # remove any trailing space
      else
        selected=$(printf '%s\n' "${_comps[@]}" \
          | gum filter --value="$cur" --header=" $cmd" 2>/dev/null)
      fi

    else
      # No completion function results — fd-based file/dir picker
      case "$cmd" in
        cd|pushd|rmdir)
          selected=$(fd --type d --hidden --follow \
            --exclude .git --exclude node_modules . 2>/dev/null \
            | gum filter --value="$cur" --header="cd  directory" 2>/dev/null)
          [[ -n "$selected" ]] && selected="${selected%/}/"
          ;;
        *)
          selected=$(fd --hidden --follow --exclude .git . 2>/dev/null \
            | gum filter --value="$cur" \
                --header="  file / directory" 2>/dev/null)
          [[ -n "$selected" && -d "$selected" ]] && selected="${selected%/}/"
          ;;
      esac
    fi

    # ── 4. Restore terminal state ─────────────────────────────────────────────
    [[ -n "$_stty_save" ]] && stty "$_stty_save" 2>/dev/null

    # ── 5. Update readline buffer ─────────────────────────────────────────────
    if [[ -n "$selected" ]]; then
      READLINE_LINE="${prefix}${selected}"
      READLINE_POINT="${#READLINE_LINE}"
    fi
  }

  bind -x '"\t": _gum_tab'
fi
