-- Change the default Omarchy look'n'feel.

-- https://wiki.hypr.land/Configuring/Basics/Variables/#general
-- hl.config({
--   general = {
--     -- No gaps between windows or borders.
--     gaps_in = 0,
--     gaps_out = 0,
--     border_size = 0,
--
--     -- Change to niri-like side-scrolling layout.
--     layout = "scrolling",
--   },
-- })

-- https://wiki.hypr.land/Configuring/Basics/Variables/#decoration
-- hl.config({
--   decoration = {
--     -- Use round window corners.
--     rounding = 8,
--
--     -- Dim unfocused windows (0.0 = no dim, 1.0 = fully dimmed).
--     dim_inactive = true,
--     dim_strength = 0.15,
--   },
-- })

-- https://wiki.hypr.land/Configuring/Basics/Variables/#animations
-- hl.config({
--   animations = {
--     -- Disable all animations.
--     enabled = false,
--   },
-- })

-- https://wiki.hypr.land/Configuring/Basics/Variables/#layout
-- hl.config({
--   layout = {
--     -- Avoid overly wide single-window layouts on wide screens.
--     single_window_aspect_ratio = { 1, 1 },
--   },
-- })

-- https://wiki.hypr.land/Configuring/Layouts/Scrolling-Layout/
-- hl.config({
--   scrolling = {
--     -- See only one column per screen instead of two.
--     column_width = 0.97,
--   },
-- })

-- Transição vertical entre áreas de trabalho (estilo Niri)
hl.animation({ leaf = "workspaces", enabled = true, speed = 4, bezier = "easeOutQuint", style = "slidevert" })

-- Scrolling como layout padrão de todas as áreas de trabalho
-- (Super+L ainda alterna uma área específica para dwindle).
hl.config({
  general = {
    layout = "scrolling",
  },
})

-- Scrolling: duas colunas ocupam exatamente a tela, igual ao dwindle (padrão Omarchy: 0.49).
-- Uma janela sozinha mantém meia tela de largura e fica centralizada
-- (fullscreen_on_one_column = false); com duas ou mais, dividem a tela.
hl.config({
  scrolling = {
    column_width = 0.5,
    fullscreen_on_one_column = false,
  },
})

-- >>> omaland managed block >>>
-- Written by Omaland. Safe to hand-edit: Omaland re-reads this block
-- every time it opens, and only ever rewrites what's between the fences.
hl.config({
  decoration = {
    rounding = 20,
  },
})
-- <<< omaland managed block <<<

-- Border only on the focused window: unfocused ones get a transparent border.
hl.config({
  general = {
    col = {
      inactive_border = "rgba(00000000)",
    },
  },
})

-- Focus, in the glass language of MyBar/MyDock:
--   - a faint white "glass rim" on the focused window (unfocused stay borderless),
--   - unfocused windows slightly dimmed,
--   - a soft, diffuse shadow all around every window (stronger on the focused one).
hl.config({
  general = {
    col = {
      active_border = "rgba(ffffff55)",
    },
  },
  decoration = {
    dim_inactive = true,
    dim_strength = 0.12,
    shadow = {
      enabled = true,
      range = 28,
      render_power = 3,
      scale = 1.0,
      offset = "0 4",
      color = "rgba(00000070)",
      color_inactive = "rgba(00000040)",
    },
  },
})

-- Terminal (kitty) as a dark glass card: no rim (rounding comes from the global 20).
hl.window_rule({ match = { class = "^kitty$" }, border_size = 0 })

-- Floating-card spacing: 14 px to the screen edges, 12 px between windows (6 + 6).
hl.config({
  general = {
    gaps_out = 14,
    gaps_in = 6,
  },
})
