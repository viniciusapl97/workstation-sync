#!/bin/bash
# Monta o meu Omarchy num PC recém-instalado com o que uso no notebook:
# ferramentas, pacotes, plugins, configs, wallpapers, ícones e repositórios.
# Pode rodar de novo: cada etapa pula o que já está feito, e todo arquivo
# substituído vai antes para ~/.local/state/workstation-sync/backup-<data>.
#
#   ./setup.sh                    todas as etapas, na ordem
#   ./setup.sh configs plugins    só essas
set -euo pipefail
cd "$(dirname "$0")"
HERE=$PWD

STEPS=(ferramentas github pacotes plugins configs wallpapers icones padroes repos fim)
BACKUP="$HOME/.local/state/workstation-sync/backup-$(date +%F-%H%M%S)"
export PATH="$HOME/.local/share/mise/shims:$HOME/.local/bin:$PATH"

say() { printf '\n\033[1;36m==>\033[0m \033[1m%s\033[0m\n' "$*"; }
warn() { printf '  \033[1;33m!\033[0m %s\n' "$*"; WARNINGS+=("$*"); }
WARNINGS=()

lines() { sed 's/#.*//; s/[[:space:]]*$//' "$1" | grep -v '^$'; }

backup() { # caminho em ~ que vai ser substituído
  [[ -e $1 || -L $1 ]] || return 0
  local rel=${1#"$HOME"/}
  mkdir -p "$BACKUP/$(dirname "$rel")"
  mv -- "$1" "$BACKUP/$rel"
}

put() { # caminho relativo a ~: copia de home/ se mudou
  local src="$HERE/home/$1" dest="$HOME/$1"
  [[ -f $dest ]] && cmp -s "$src" "$dest" && return 1
  backup "$dest"
  mkdir -p "$(dirname "$dest")"
  cp -p -- "$src" "$dest"
}

step_ferramentas() {
  say "Ferramentas do mise (claude, codex, copilot, gh, node, opencode, uv)"
  put .config/mise/config.toml || true
  mise install --yes
}

step_github() {
  say "GitHub"
  command -v gh >/dev/null || sudo pacman -S --needed --noconfirm github-cli
  gh auth status >/dev/null 2>&1 || gh auth login --git-protocol https --web
  gh auth setup-git
  git config --global user.name >/dev/null || git config --global user.name "Vini"
  git config --global user.email >/dev/null || git config --global user.email "163370127+viniciusapl97@users.noreply.github.com"
  echo "  $(gh api user --jq .login)"
}

step_pacotes() {
  say "Pacotes"
  local missing=() failed=() p pkg cmd
  while read -r p _; do
    [[ $p == \!* || $p == @* ]] && continue
    pacman -Qq "$p" >/dev/null 2>&1 || missing+=("$p")
  done < <(lines packages.txt)
  if ((${#missing[@]})); then
    echo "  instalando: ${missing[*]}"
    if ! yay -S --needed --noconfirm "${missing[@]}"; then
      # Um pacote quebrado (AUR) não pode travar os outros.
      for p in "${missing[@]}"; do
        pacman -Qq "$p" >/dev/null 2>&1 || yay -S --needed --noconfirm "$p" || failed+=("$p")
      done
    fi
  else
    echo "  todos já instalados"
  fi
  while read -r pkg cmd; do
    pkg=${pkg#@}
    pacman -Qq "$pkg" >/dev/null 2>&1 && continue
    echo "  $cmd"
    $cmd || failed+=("$pkg")
  done < <(lines packages.txt | grep '^@')
  for p in "${failed[@]}"; do warn "pacote não instalou: $p"; done
}

step_plugins() {
  say "Plugins do Omarchy shell"
  local id src post dir
  while read -r id src post; do
    dir="$HOME/.config/omarchy/plugins/$id"
    if [[ -d $dir ]]; then
      if [[ -d $dir/.git ]]; then
        git -C "$dir" pull --ff-only -q || warn "$id: pull não é fast-forward"
      fi
      echo "  $id (já estava)"
      continue
    fi
    if [[ $src != - ]]; then
      omarchy-plugin-add "$src" --enable --yes || { warn "$id: não instalou"; continue; }
    fi
    if [[ -n $post ]]; then
      (cd "$([[ -d $dir ]] && echo "$dir" || echo "$HOME")" && eval "$post") || warn "$id: '$post' falhou"
    fi
    [[ -d $dir ]] && echo "  $id" || warn "$id: a pasta $dir não apareceu"
  done < <(lines plugins.txt)
}

step_configs() {
  say "Configs"
  local p n=0 udev=0
  while IFS= read -r p; do
    if [[ $p == /* ]]; then
      # Arquivo de sistema: sem backup em ~, só instala se mudou.
      cmp -s "system$p" "$p" 2>/dev/null && continue
      sudo install -Dm644 "system$p" "$p"
      [[ $p == /etc/udev/* ]] && udev=1
      n=$((n + 1)); continue
    fi
    if [[ $p == .local/state/mybar/state.json && -f $HOME/$p ]]; then
      # Mescla: mantém o que só existe aqui (favoritos, cidade do clima).
      local merged; merged=$(jq -s '.[0] * .[1]' "$HOME/$p" "home/$p")
      [[ $merged == "$(jq . "$HOME/$p")" ]] && continue
      mkdir -p "$BACKUP/$(dirname "$p")" && cp -p "$HOME/$p" "$BACKUP/$p"
      cat >"$HOME/$p" <<<"$merged"   # mesmo inode: o MyBar observa o arquivo
      n=$((n + 1)); continue
    fi
    put "$p" && n=$((n + 1))
  done < <(lines files.txt)
  echo "  $n arquivos atualizados"
  if ((udev)); then sudo udevadm control --reload && sudo udevadm trigger; fi

  # input.lua é da máquina (layout escolhido no instalador); só acrescenta isto.
  local input="$HOME/.config/hypr/input.lua" mark="-- workstation-sync: teclados"
  if [[ -f $input ]] && ! grep -q "resolve_binds_by_sym" "$input"; then
    cat >>"$input" <<EOF

$mark
-- Atalhos pelo símbolo digitado, não pela posição da tecla: com layouts
-- diferentes por teclado (keyboard.lua: us intl no R85HE), o "/" de um virava
-- ";" no outro e Super+/ não funcionava.
hl.config({ input = { resolve_binds_by_sym = true } })
EOF
    echo "  input.lua: resolve_binds_by_sym"
  fi

  systemctl --user daemon-reload
  if command -v bt-agent >/dev/null; then
    systemctl --user enable --now bt-agent.service >/dev/null 2>&1 || warn "bt-agent.service não ativou"
  fi
}

step_wallpapers() {
  say "Wallpapers e temas"
  local bg="$HOME/.config/omarchy/backgrounds"
  if [[ -d $bg/.git ]]; then
    git -C "$bg" pull --ff-only -q || warn "wallpapers: pull não é fast-forward"
  else
    if [[ -d $bg && -n $(ls -A "$bg") ]]; then
      if [[ -e $bg.antes ]]; then backup "$bg"; else mv -- "$bg" "$bg.antes"; fi
    fi
    if [[ -d $bg ]]; then rmdir "$bg"; fi
    git clone -q https://github.com/viniciusapl97/wallpapers "$bg"
  fi
  "$bg/install.sh"
}

step_icones() {
  say "Ícones Reversal"
  if compgen -G "$HOME/.local/share/icons/Reversal-*-dark" >/dev/null; then
    echo "  já instalados"
    return
  fi
  local tmp; tmp=$(mktemp -d)
  git clone -q --depth 1 https://github.com/yeyushengfan258/Reversal-icon-theme "$tmp/reversal"
  # Só as cores que o hook icon-theme.sh escolhe (sem black e brown).
  (cd "$tmp/reversal" && ./install.sh -t default blue cyan green grey lightblue orange pink purple red >/dev/null)
  rm -rf "$tmp"
  echo "  $(compgen -G "$HOME/.local/share/icons/Reversal*" | wc -l) variantes"
}

step_padroes() {
  say "Apps padrão"
  omarchy-default-terminal kitty >/dev/null && echo "  terminal: kitty"
  if pacman -Qq brave-bin >/dev/null 2>&1; then omarchy-default-browser brave >/dev/null && echo "  navegador: brave"; fi
  omarchy-default-agent claude >/dev/null 2>&1 && echo "  agente: claude"
}

step_repos() {
  say "Repositórios"
  ./sync-repos.sh
}

step_fim() {
  say "Conferindo"
  if Hyprland --verify-config -c "$HOME/.config/hypr/hyprland.lua" 2>&1 | grep -q "config ok"; then
    echo "  config do Hyprland ok"
  else
    Hyprland --verify-config -c "$HOME/.config/hypr/hyprland.lua" 2>&1 | tail -15
    warn "config do Hyprland com erro (backup em ${BACKUP/#$HOME/\~})"
  fi
  if [[ -n ${HYPRLAND_INSTANCE_SIGNATURE:-} ]]; then
    hyprctl reload >/dev/null
    omarchy-restart-shell >/dev/null 2>&1 || true
    # Reaplica o tema para rodar os hooks (ícones, Zen) com tudo instalado.
    local theme; theme=$(cat "$HOME/.local/state/omarchy/current/theme.name" 2>/dev/null || true)
    if [[ -n $theme ]] && omarchy-theme-set "$theme" >/dev/null 2>&1; then echo "  tema $theme reaplicado"; fi
  fi
}

run=("$@")
((${#run[@]})) || run=("${STEPS[@]}")
for s in "${run[@]}"; do
  declare -F "step_$s" >/dev/null || { echo "Etapa desconhecida: $s (etapas: ${STEPS[*]})" >&2; exit 1; }
done

[[ $EUID -ne 0 ]] || { echo "Rode como seu usuário, não como root." >&2; exit 1; }
command -v omarchy-theme-set >/dev/null || { echo "Instale o Omarchy primeiro." >&2; exit 1; }

for s in "${run[@]}"; do "step_$s"; done

say "Pronto"
if ((${#WARNINGS[@]})); then
  echo "Avisos:"; printf '  - %s\n' "${WARNINGS[@]}"
fi
[[ -d $BACKUP ]] && echo "Arquivos substituídos: ${BACKUP/#$HOME/\~}"
cat <<'EOF'
Fica à mão (veja o README): chaves SSH, monitores (MyBar → Tela, Super+P),
layout do teclado deste PC (painel Keyboard), cidade do clima no MyBar,
parear o celular no Flux e os Galaxy Buds.
EOF
