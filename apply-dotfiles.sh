#!/usr/bin/env bash
# Aplica meus dotfiles (chezmoi) — feitos para Fedora + niri + noctalia.
# Mostra o diff e pede confirmação antes de sobrescrever qualquer coisa.
set -euo pipefail

REPO=https://github.com/viniciusapl97/dotfiles.git

if ! command -v chezmoi >/dev/null; then
  if command -v dnf >/dev/null; then sudo dnf install -y chezmoi
  elif command -v pacman >/dev/null; then sudo pacman -S --needed --noconfirm chezmoi
  else sh -c "$(curl -fsLS get.chezmoi.io)" -- -b "$HOME/.local/bin"; export PATH=$HOME/.local/bin:$PATH; fi
fi

if [[ -d $HOME/.local/share/chezmoi/.git ]]; then
  chezmoi update --apply=false
else
  chezmoi init "$REPO"
fi

chezmoi diff --no-pager || true
read -rp "Aplicar essas mudanças? [y/N] " a
[[ $a == [yY] ]] && chezmoi apply -v || echo "Nada aplicado."
