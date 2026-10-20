#!/bin/bash
# Tema de ícones independente do Omarchy (que troca para uma variante do Yaru a
# cada tema). Roda depois dele e aplica o pack escolhido aqui:
#   reversal Reversal-<cor do accent do tema>-dark / sem -dark em temas claros
#            (instalado em ~/.local/share/icons pelo install.sh do autor)
#   suru     Suru++ (escuro) / Suru++-Light em temas claros
#            (removido; reinstalar de github.com/gusbemacbe/suru-plus)
#   colloid  Colloid-<cor do accent do tema>-Dark / -Light
#            (precisa do pacote: omarchy pkg aur add colloid-icon-theme-git)
ICON_PACK="reversal"
set -uo pipefail

colors="$HOME/.local/state/omarchy/current/theme/colors.toml"
mode=$(omarchy-theme-color --file "$colors" mode 2>/dev/null)

has_theme() { [[ -d /usr/share/icons/$1 || -d $HOME/.local/share/icons/$1 ]]; }

# Accent colour -> colour name (empty = the pack's default blue).
accent_color() {
  python3 - "$(omarchy-theme-color --file "$colors" accent 2>/dev/null)" <<'PY'
import colorsys, sys
h = sys.argv[1].lstrip("#")
if len(h) != 6:
    print(""); sys.exit()
r, g, b = (int(h[i:i + 2], 16) / 255 for i in (0, 2, 4))
hue, light, sat = colorsys.rgb_to_hls(r, g, b)
deg = hue * 360
if sat < 0.18 or light < 0.12 or light > 0.92: print("grey")
elif deg < 12 or deg >= 345: print("red")
elif deg < 42:  print("orange")
elif deg < 68:  print("yellow")
elif deg < 160: print("green")
elif deg < 195: print("teal")
elif deg < 255: print("")
elif deg < 290: print("purple")
else:           print("pink")
PY
}

case "$ICON_PACK" in
  reversal)
    # Reversal has no yellow or teal: nearest are orange and cyan.
    color=$(accent_color)
    case "$color" in yellow) color=orange ;; teal) color=cyan ;; esac
    theme="Reversal${color:+-$color}$([[ $mode == light ]] || echo -dark)"
    has_theme "$theme" || theme="Reversal$([[ $mode == light ]] || echo -dark)"
    ;;
  suru)
    theme=$([[ $mode == light ]] && echo "Suru++-Light" || echo "Suru++")
    ;;
  colloid)
    accent=$(omarchy-theme-color --file "$colors" accent 2>/dev/null)
    color=$(python3 - "$accent" <<'PY'
import colorsys, sys
h = sys.argv[1].lstrip("#")
if len(h) != 6:
    print(""); sys.exit()
r, g, b = (int(h[i:i + 2], 16) / 255 for i in (0, 2, 4))
hue, light, sat = colorsys.rgb_to_hls(r, g, b)
deg = hue * 360
if sat < 0.18 or light < 0.12 or light > 0.92: print("Grey")
elif deg < 12 or deg >= 345: print("Red")
elif deg < 42:  print("Orange")
elif deg < 68:  print("Yellow")
elif deg < 160: print("Green")
elif deg < 195: print("Teal")
elif deg < 255: print("")        # Colloid's default is blue
elif deg < 290: print("Purple")
else:           print("Pink")
PY
)
    suffix=$([[ $mode == light ]] && echo Light || echo Dark)
    theme="Colloid${color:+-$color}-$suffix"
    has_theme "$theme" || theme="Colloid-$suffix"
    ;;
esac

has_theme "$theme" && gsettings set org.gnome.desktop.interface icon-theme "$theme"
