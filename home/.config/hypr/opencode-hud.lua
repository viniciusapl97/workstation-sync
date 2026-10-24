-- opencode HUD no Hyprland (configuração em Lua, Hyprland 0.50+).
--
-- No Wayland um app não escolhe a própria posição nem fica "sempre no topo":
-- quem decide é o compositor. Estas regras fazem o widget flutuar, aparecer
-- em todas as áreas de trabalho (pin) e ficar no canto superior direito,
-- como no Windows; a dashboard abre flutuando, centralizada.
--
-- Copie para ~/.config/hypr/ e carregue no hyprland.lua, do mesmo jeito que
-- os outros arquivos de lá (no Omarchy: require("hypr.opencode-hud")).
-- (scripts/install-linux.sh faz a cópia e mostra a linha.)

hl.window_rule({
  match = { title = "^opencode HUD widget$" },
  float = true,
  pin = true,
  border_size = 0,
  opacity = "1 1",
  move = { "(monitor_w-window_w-16)", "(monitor_h*0.05)" },
})

hl.window_rule({
  match = { title = "^opencode HUD$" },
  float = true,
  center = true,
  size = { 1100, 720 },
})
