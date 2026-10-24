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

-- The side items' floating glass cards (layer "mybar-popup", Bar.qml: Música,
-- IAs): frosted glass, like the dock. ignore_alpha keeps the fully
-- transparent part of its fixed-size window (around the card) unblurred.
--
-- no_anim: the card animates itself (interno, em GlassCard.qml). Sem isso o
-- Hyprland aplica também o fade de camada (layersIn/layersOut) por cima, e a
-- opacidade do vidro atravessa duas vezes o limiar do ignore_alpha — o blur
-- entra e sai no meio da animação. É o mesmo motivo dos no_anim acima.
hl.layer_rule({ match = { namespace = "^mybar-popup$" }, blur = true, ignore_alpha = 0.1, no_anim = true })
