-- Molas (física de mola amortecida) nas animações do Hyprland, como as do
-- notch do MyBar. Valores do esquema Material 3 (o mesmo do vídeo da Dynamic
-- Island): "spatial" para o que se move (janelas, workspaces), "effects" com
-- amortecimento 1.0 (sem quique) para o que só aparece/some.
-- Para voltar ao padrão do Omarchy: tire `require("hypr.motion")` do hyprland.lua.

-- Escolha feita no MyBar (Configurações → Movimento → Animação das janelas):
-- uma palavra em ~/.local/state/mybar/window-motion ("spring" ou "omarchy").
-- O MyBar só escreve esse arquivo e manda `hyprctl reload`; este arquivo nunca
-- é reescrito por ele. Sem o arquivo (ou com outra coisa nele), ficam as molas.
local function mybar_window_motion()
  local ok, value = pcall(function()
    local f = io.open(os.getenv("HOME") .. "/.local/state/mybar/window-motion", "r")
    if not f then return nil end
    local s = f:read("*l")
    f:close()
    return s
  end)
  return ok and value or nil
end
if mybar_window_motion() == "omarchy" then return end

hl.curve("md3_spatial_fast",    { type = "spring", mass = 1, stiffness = 600,  dampening = 49 })
hl.curve("md3_spatial_default", { type = "spring", mass = 1, stiffness = 300,  dampening = 30 })
hl.curve("md3_spatial_slow",    { type = "spring", mass = 1, stiffness = 160,  dampening = 25 })
hl.curve("md3_effects_fast",    { type = "spring", mass = 1, stiffness = 3800, dampening = 123 })
hl.curve("md3_effects_default", { type = "spring", mass = 1, stiffness = 1600, dampening = 80 })
hl.curve("md3_effects_slow",    { type = "spring", mass = 1, stiffness = 800,  dampening = 57 })
hl.curve("md3_standard",          { type = "bezier", points = { { 0.2, 0.0 }, { 0.0, 1.0 } } })
hl.curve("md3_emphasized_accel",  { type = "bezier", points = { { 0.3, 0.0 }, { 0.8, 0.15 } } })

hl.animation({ leaf = "windows",     enabled = true, speed = 5, spring = "md3_spatial_default" })
hl.animation({ leaf = "windowsIn",   enabled = true, speed = 5, spring = "md3_spatial_default", style = "popin 92%" })
hl.animation({ leaf = "windowsOut",  enabled = true, speed = 2, spring = "md3_spatial_default", style = "popin 92%" })
hl.animation({ leaf = "windowsMove", enabled = true, speed = 5, spring = "md3_spatial_default" })

-- Camadas (menus, notificações de outros apps): só fade, em curva — opacidade não pode quicar.
hl.animation({ leaf = "layers",    enabled = true, speed = 3,   bezier = "md3_standard", style = "fade" })
hl.animation({ leaf = "layersIn",  enabled = true, speed = 3,   bezier = "md3_standard", style = "fade" })
hl.animation({ leaf = "layersOut", enabled = true, speed = 2.5, bezier = "md3_emphasized_accel", style = "fade" })

hl.animation({ leaf = "fade",    enabled = true, speed = 2, spring = "md3_effects_default" })
hl.animation({ leaf = "fadeOut", enabled = true, speed = 2, spring = "md3_spatial_default" })

-- Workspaces: mantém a transição vertical (estilo Niri) que já estava no looknfeel.lua.
hl.animation({ leaf = "workspaces",        enabled = true, speed = 5,   spring = "md3_spatial_default", style = "slidevert" })
hl.animation({ leaf = "specialWorkspace",  enabled = true, speed = 3.5, spring = "md3_spatial_default", style = "slidevert" })
