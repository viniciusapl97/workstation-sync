#!/usr/bin/env bash
# Clona ou atualiza meus projetos em ~/Projects. Não mexe em configs. Seguro para rodar várias vezes.
set -euo pipefail

GH_USER=viniciusapl97

# destino | repo
REPOS=(
  "$HOME/Projects/workstation-sync|$GH_USER/workstation-sync"
  "$HOME/Projects/mesa|$GH_USER/mesa"
  "$HOME/Projects/prancha|$GH_USER/prancha"
  "$HOME/Projects/app-faculdade|$GH_USER/app-faculdade"
  "$HOME/Projects/sela|$GH_USER/sela"
  "$HOME/Projects/study-platform|$GH_USER/study-platform"
  "$HOME/Projects/fatec-bot|$GH_USER/fatec-bot"
  "$HOME/Projects/finance_agent|jabiraka/finance_agent"
)

# Lista específica desta máquina (mesmo formato, uma entrada por linha; # comenta)
LOCAL_LIST=${XDG_CONFIG_HOME:-$HOME/.config}/workstation-sync/repos
if [[ -f $LOCAL_LIST ]]; then
  REPOS=()
  while IFS= read -r line; do
    [[ $line =~ ^[[:space:]]*(#|$) ]] && continue
    REPOS+=("${line//\$HOME/$HOME}")
  done <"$LOCAL_LIST"
fi

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
