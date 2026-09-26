#!/usr/bin/env bash
# Clona ou atualiza meus repositórios. Não mexe em dotfiles. Seguro para rodar várias vezes.
set -euo pipefail

GH_USER=viniciusapl97

# destino | repo
REPOS=(
  "$HOME/Projects/study-platform|$GH_USER/study-platform"
  "$HOME/Projects/fatec-bot|$GH_USER/fatec-bot"
  "$HOME/Projects/niri-monitor|$GH_USER/niri-monitor"
  "$HOME/Projects/workstation-sync|$GH_USER/workstation-sync"
  "$HOME/.local/share/noctalia-plugins/ai-usage|$GH_USER/ai-usage"
  "$HOME/.local/share/noctalia-plugins/github-activity|$GH_USER/github-activity"
  "$HOME/cliamp|bjarneo/cliamp"
  "$HOME/spotify-controller|NarkAgni/spotify-controller"
)

say() { printf '\033[1;36m==>\033[0m %s\n' "$*"; }

install_pkgs() {
  if command -v pacman >/dev/null; then sudo pacman -S --needed --noconfirm "$@"
  elif command -v dnf >/dev/null; then sudo dnf install -y "$@"
  else echo "Instale manualmente: $*" >&2; exit 1; fi
}

command -v git >/dev/null || install_pkgs git
if ! command -v gh >/dev/null; then
  command -v pacman >/dev/null && install_pkgs github-cli || install_pkgs gh
fi

gh auth status >/dev/null 2>&1 || gh auth login --git-protocol https --web
gh auth setup-git

for entry in "${REPOS[@]}"; do
  IFS='|' read -r dir repo <<<"$entry"
  if [[ -d $dir/.git ]]; then
    say "Atualizando $repo"
    git -C "$dir" fetch --all --prune -q
    if [[ -n $(git -C "$dir" status --porcelain) ]]; then
      echo "  ! alterações locais, pulei o pull"
    else
      git -C "$dir" pull --ff-only -q || echo "  ! pull não é fast-forward, resolva manualmente"
    fi
  else
    say "Clonando $repo"
    mkdir -p "$(dirname "$dir")"
    gh repo clone "$repo" "$dir" -- -q
  fi
done

say "Status"
for entry in "${REPOS[@]}"; do
  dir=${entry%%|*}
  printf '  %-55s %s\n' "${dir/#$HOME/\~}" "$(git -C "$dir" status -sb | head -1)"
done
