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
