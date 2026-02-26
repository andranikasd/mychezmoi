# ── chezmoi dotfiles smoke-test image ────────────────────────────────────────
# Build:  docker build -t dotfiles-test .
# Run:    docker run --rm -it dotfiles-test           # interactive shell
# Test:   docker build --progress=plain --no-cache -t dotfiles-test .

FROM ubuntu:24.04

ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y --no-install-recommends \
        bash curl git tmux ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# ── Non-root user ─────────────────────────────────────────────────────────────
RUN useradd -m -s /bin/bash dot
USER dot
ENV HOME=/home/dot
ENV PATH="/home/dot/.local/bin:$PATH"
WORKDIR $HOME

# ── chezmoi ───────────────────────────────────────────────────────────────────
RUN sh -c "$(curl -fsLS get.chezmoi.io)" -- -b "$HOME/.local/bin"

# ── Source files ──────────────────────────────────────────────────────────────
COPY --chown=dot:dot . $HOME/.local/share/chezmoi/

# Minimal config — no real secrets, just template data
RUN mkdir -p "$HOME/.config/chezmoi" && printf \
    'sourceDir = "%s/.local/share/chezmoi"\n\n[data]\n  name = "Docker Test"\n  email = "test@example.com"\n' \
    "$HOME" > "$HOME/.config/chezmoi/chezmoi.toml"

# Apply dotfiles — skip run_* scripts (they require Homebrew / macOS)
RUN chezmoi apply --exclude=scripts

# ── Smoke tests ───────────────────────────────────────────────────────────────

# 1. Git config was rendered from the template
RUN grep -q "Docker Test" "$HOME/.gitconfig" \
    && echo "✓ .gitconfig rendered"

# 2. Each bash module sources without fatal errors.
#    Modules are sourced directly (they have no interactive-shell guard).
#    Suppress stderr: bind(1) warns on non-tty; tty(1) warns when no terminal.
RUN for mod in exports aliases functions completion prompt; do \
        bash -c "source \$HOME/.config/bash/${mod}.sh" 2>/dev/null \
        && echo "✓ ${mod}.sh"; \
    done

# 3. Tmux config was placed at the expected path
RUN [ -s "$HOME/.config/tmux/tmux.conf" ] \
    && echo "✓ tmux.conf applied"

# ── Interactive entry point ───────────────────────────────────────────────────
LABEL org.opencontainers.image.description="chezmoi dotfiles smoke-test"
CMD ["bash", "--login"]
