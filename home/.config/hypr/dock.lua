-- Frosted-glass blur behind the MyDock shell plugin (layer "mydock").
--
-- Hyprland's blur is a global switch, so it is turned on here and then opted
-- back out for every window: the dock stays the only blurred surface.
-- Delete this file (and its require in hyprland.lua) to drop the blur.
hl.config({
  decoration = {
    blur = {
      enabled = true,
      size = 12,
      passes = 3,
      noise = 0.015,
      contrast = 1.0,
      brightness = 1.0,
      vibrancy = 0.35,
      -- O cache de blur (new_optimizations) reaproveita o que já foi borrado
      -- quando só um pedaço da tela muda. Num vidro que anima ou que fica em
      -- cima de uma tela que redesenha inteira (hover no notch, troca de
      -- monitor/área) ele reaproveita região errada por um frame — o vidro
      -- "pisca". Recalcular sempre custa um pouco de GPU e não pisca.
      -- Voltar ao padrão: apagar a linha abaixo.
      new_optimizations = false,
    },
  },
})

hl.window_rule({ match = { class = ".*" }, no_blur = true })

hl.layer_rule({ match = { namespace = "^mydock$" }, blur = true, ignore_alpha = 0.1 })

-- Kitty gets the same frosted glass as the dock.
hl.window_rule({ match = { class = "^kitty$" }, no_blur = false })

-- Nautilus: GTK can't make just its background translucent, so the whole
-- window gets compositor opacity (text included) plus the dock's blur.
hl.window_rule({ match = { class = "^org.gnome.Nautilus$" }, no_blur = false, opacity = "0.85 0.85" })
