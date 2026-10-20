#!/bin/bash
# Roda NESTE notebook: traz para home/ a versão atual dos arquivos de files.txt
# e avisa de pacotes e plugins instalados aqui que ainda não estão nas listas.
# Depois é só revisar o `git diff` e commitar.
set -euo pipefail
cd "$(dirname "$0")"

# Plugins que não uso mais: saem também do shell.json copiado.
UNUSED='^(hancore\.shibumi\..*|pix\.bar|omaplug|v1ni\.workspaces)$'

lines() { sed 's/#.*//; s/[[:space:]]*$//' "$1" | grep -v '^$'; }

rm -rf home system
n=0
while IFS= read -r p; do
  if [[ $p == /* ]]; then src=$p dest="system$p"; else src="$HOME/$p" dest="home/$p"; fi
  [[ -f $src ]] || { echo "  ! não existe: $src"; continue; }
  mkdir -p "$(dirname "$dest")"
  case $p in
    .config/omarchy/shell.json)
      jq --arg re "$UNUSED" \
        'walk(if type == "array" then map(select((type == "object" and (.id? | type) == "string" and (.id | test($re))) | not)) else . end)' \
        "$src" >"$dest" ;;
    .local/state/mybar/state.json)
      # Favoritos vêm do repositório de wallpapers; cidade e contadores ficam aqui.
      jq 'del(.favoriteThemes, .weatherCity, .notifSeen)' "$src" >"$dest" ;;
    *) cp -p -- "$src" "$dest" ;;
  esac
  n=$((n + 1))
done < <(lines files.txt)
echo "$n arquivos em home/ e system/"

# Pacotes explícitos daqui que não vêm do Omarchy nem estão em packages.txt.
known=$( { lines packages.txt | awk '{print $1}' | sed 's/^[!@]//'
  grep -hv '^\s*#' "${OMARCHY_PATH:-/usr/share/omarchy}"/install/omarchy-*.packages | awk 'NF {print $1}'
  pactree -u omarchy 2>/dev/null; } | sort -u)
new=$(comm -23 <(pacman -Qqe | sort) <(echo "$known"))
[[ -z $new ]] || { echo "Pacotes fora de packages.txt (adicione, ou marque com !):"; sed 's/^/  /' <<<"$new"; }

# Plugins instalados aqui que não estão em plugins.txt.
listed=$(lines plugins.txt | awk '{print $1}')
for d in "$HOME"/.config/omarchy/plugins/*/; do
  id=$(basename "$d")
  [[ $id =~ $UNUSED ]] || grep -qxF "$id" <<<"$listed" ||
    echo "  plugin fora de plugins.txt: $id ($(git -C "$d" remote get-url origin 2>/dev/null || echo 'sem repositório'))"
done
