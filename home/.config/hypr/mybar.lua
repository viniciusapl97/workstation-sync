-- MyBar notch (layer "mybar").
--
-- The notch is solid black now, so it gets no blur: blurring the layer
-- frosted the soft shadow pixels into a light rim around the notch.
-- Kept (and still required from hyprland.lua) as the place for future
-- MyBar layer rules. Anchor the pattern so "mybar-reserve" is not matched.

-- The notch's music bars window (layer "mybar-eq"): it has to appear and go
-- in place, without Hyprland's layer animation.
hl.layer_rule({ match = { namespace = "^mybar-eq$" }, no_anim = true })

-- Rounded screen corners (layer "mybar-corner", ScreenCorners.qml): static
-- windows, they must appear in place without the layer open animation.
hl.layer_rule({ match = { namespace = "^mybar-corner$" }, no_anim = true })

-- Lyrics' own window (layer "mybar-lyrics", Bar.qml): it appears when a song
-- starts, so it must show in place without the layer open animation.
hl.layer_rule({ match = { namespace = "^mybar-lyrics$" }, no_anim = true })
