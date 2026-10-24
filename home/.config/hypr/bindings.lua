-- Keep only your personal keybinding overrides here. Add new bindings or
-- unbind defaults before replacing them.

-- See current bindings and descriptions:
--   omarchy menu keybindings --print

-- To disable every Omarchy default binding, set this in
-- ~/.config/hypr/hyprland.lua before require("default.hypr.omarchy"), then add
-- only the bindings you want below:
--   omarchy_default_bindings = false

-- To disable all preinstalled app/webapp bindings, set:
--   omarchy_preinstalled_bindings = false

-- Add a new binding.
-- o.bind("SUPER + SHIFT + R", "SSH", "alacritty -e ssh your-server")

-- Change an existing binding by unbinding it first, then binding the key again.
-- This example changes SUPER+SPACE from the launcher to the Omarchy root menu.
-- hl.unbind("SUPER + SPACE")
-- o.bind("SUPER + SPACE", "Omarchy menu", "omarchy-menu toggle root")

-- Disable a default binding without replacing it.
-- hl.unbind("SUPER + SHIFT + B")

-- Logitech MX Keys examples:
-- o.bind("SUPER + SHIFT + S", nil, "omarchy-capture-screenshot")
-- o.bind("SUPER + H", nil, "voxtype record toggle")
-- o.bind("SUPER + PERIOD", nil, "omarchy-shell shell toggle omarchy.emojis")

-- Atalhos vindos do Niri
o.bind("SUPER + B", "Browser", { omarchy = "browser" })
o.bind("SUPER + E", "File manager (Yazi)", "kitty -e yazi")

-- Super+Q fecha janela (Super+W continua funcionando)
o.bind("SUPER + Q", "Close window", hl.dsp.window.close())

-- Super+T abre terminal (era: alternar flutuante/lado a lado)
hl.unbind("SUPER + T")
o.bind("SUPER + T", "Terminal", { omarchy = "terminal" })

-- Super+V alterna flutuante (era: colar universal)
hl.unbind("SUPER + V")
o.bind("SUPER + V", "Toggle window floating/tiling", hl.dsp.window.float({ action = "toggle" }))

-- Super+Shift+F tela cheia (era: gerenciador de arquivos, agora em Super+E)
hl.unbind("SUPER + SHIFT + F")
o.bind("SUPER + SHIFT + F", "Full screen", hl.dsp.window.fullscreen({ mode = "fullscreen" }))

-- Super+Ctrl+setas move a janela (era: foco em grupo de janelas)
hl.unbind("SUPER + CTRL + LEFT")
hl.unbind("SUPER + CTRL + RIGHT")
o.bind("SUPER + CTRL + LEFT", "Swap window to the left", hl.dsp.window.swap({ direction = "l" }))
o.bind("SUPER + CTRL + RIGHT", "Swap window to the right", hl.dsp.window.swap({ direction = "r" }))

-- Super+W colar universal (era: fechar janela, agora em Super+Q)
-- Mesma lógica do default/hypr/bindings/clipboard.lua: Shift+Insert em terminais, Ctrl+V no resto
local function universal_paste()
  local window = hl.get_active_window()
  local is_terminal = false
  for _, tag in ipairs((window and window.tags) or {}) do
    if tag:gsub("%*$", "") == "terminal" then is_terminal = true end
  end
  local mods, key = "CTRL", "V"
  if is_terminal then mods, key = "SHIFT", "Insert" end
  hl.dispatch(hl.dsp.send_key_state({ mods = mods, key = key, state = "down" }))
  hl.timer(function()
    hl.dispatch(hl.dsp.send_key_state({ mods = mods, key = key, state = "up" }))
  end, { timeout = 50, type = "oneshot" })
end
hl.unbind("SUPER + W")
o.bind("SUPER + W", "Universal paste", universal_paste)

-- Super+PgUp/PgDown navega entre áreas de trabalho
o.bind("SUPER + Prior", "Previous workspace", hl.dsp.focus({ workspace = "e-1" }))
o.bind("SUPER + Next", "Next workspace", hl.dsp.focus({ workspace = "e+1" }))

-- Super+Shift+Enter troca papel de parede no notch do MyBar (era: browser, agora em Super+B)
hl.unbind("SUPER + SHIFT + RETURN")
o.bind("SUPER + SHIFT + RETURN", "Background switcher", "omarchy-shell mybar open walls")

-- Super+Espaço abre o menu do Omarchy dentro do notch do MyBar (era: menu original do Omarchy, que segue ativo para os seletores dos scripts)
hl.unbind("SUPER + SPACE")
o.bind("SUPER + SPACE", "Omarchy menu", "omarchy-shell mybar menu root")

-- Super+Esc abre a view de energia no notch do MyBar (era: menu System do Omarchy)
hl.unbind("SUPER + ESCAPE")
o.bind("SUPER + ESCAPE", "System menu", "omarchy-shell mybar open power")

-- Super+N abre o bloco de notas do MyBar (mesma abertura do Super+Espaço; repete para fechar)
o.bind("SUPER + N", "Notas", "omarchy-shell mybar open notes")
o.bind("SUPER + K", "Comandos", "omarchy-shell mybar open palette")

-- Super+M minimiza a janela em foco (vai pro workspace escondido "minimized"; o ícone dela aparece no canto direito do MyBar para restaurar)
o.bind("SUPER + M", "Minimize window", hl.dsp.window.move({ workspace = "special:minimized", follow = false }))

-- Super+Shift+Espaço troca de tema no notch do MyBar (era: mostrar/esconder barra)
hl.unbind("SUPER + SHIFT + SPACE")
o.bind("SUPER + SHIFT + SPACE", "Theme menu", "omarchy-shell mybar open looks")

-- Super+/ abre o control center do MyBar (era: aumentar a escala do monitor)
hl.unbind("SUPER + SLASH")
o.bind("SUPER + SLASH", "Control center", "omarchy-shell mybar open system")

-- Super+Shift+C liga/desliga "manter acordado" (era: calendário do HEY; o calendário agora fica no notch)
hl.unbind("SUPER + SHIFT + C")
o.bind("SUPER + SHIFT + C", "Stay awake", "omarchy-shell mybar stayAwake")

-- Super+Shift+T mostra/esconde a barra
o.bind_toggle("SUPER + SHIFT + T", "Toggle top bar", "bar")

-- Áreas de trabalho dinâmicas estilo Niri, presas ao monitor em foco: PgDown na
-- última área ocupada daquela tela cria uma nova vazia; nunca leva o cursor para
-- a tela do apoio nem traz área de outra tela para debaixo dele.
local function workspace_step(dir, move)
  return function()
    local cur = hl.get_active_workspace()
    local mon = cur.monitor and cur.monitor.name
    local ids = {}
    for _, w in ipairs(hl.get_workspaces()) do
      if w.id > 0 and (w.windows > 0 or w.id == cur.id) and (not mon or (w.monitor and w.monitor.name == mon)) then ids[#ids + 1] = w.id end
    end
    table.sort(ids)
    local target
    if dir > 0 then
      for _, id in ipairs(ids) do if id > cur.id then target = id break end end
      if not target and cur.windows > 0 then target = cur.id + 1 end
    else
      for i = #ids, 1, -1 do if ids[i] < cur.id then target = ids[i] break end end
    end
    if not target then return end
    if move then
      -- Janela maximizada levaria o estado junto e travaria a navegação na área de destino
      local win = hl.get_active_window()
      if win and win.fullscreen and win.fullscreen ~= 0 then
        hl.dispatch(hl.dsp.window.fullscreen({ mode = "maximized" }))
      end
      hl.dispatch(hl.dsp.window.move({ workspace = tostring(target) }))
    else
      hl.dispatch(hl.dsp.focus({ workspace = tostring(target) }))
    end
  end
end
hl.unbind("SUPER + Prior")
hl.unbind("SUPER + Next")
o.bind("SUPER + Prior", "Previous workspace", workspace_step(-1))
o.bind("SUPER + Next", "Next workspace (creates new)", workspace_step(1))

-- Super+` troca o foco entre a tela de trabalho e a tela de apoio (aperta de
-- novo e volta) — a área de apoio fica na tela do notebook, tomada pelo vídeo,
-- Discord e WhatsApp. Com uma tela só, leva direto para a área de apoio.
hl.unbind("SUPER + GRAVE")
o.bind("SUPER + GRAVE", "Trocar de tela (trabalho ⇄ apoio)", function()
  local workspaces = require("hypr.workspaces")
  local internal, external = workspaces.displays()
  local target

  if internal and external then
    local cur = hl.get_active_monitor()
    target = (cur and cur.name == external) and internal or external
    hl.dispatch(hl.dsp.focus({ monitor = target }))
  else
    local cur = hl.get_active_workspace()

    if cur and cur.name == "apoio" then
      workspaces.focus_work()
    else
      hl.dispatch(hl.dsp.focus({ workspace = "name:apoio" }))
    end
  end
end)

-- Super+Shift+` manda a janela em foco para a área de apoio e mantém o foco
-- onde está (a janela aparece na tela interna, o trabalho continua o mesmo)
o.bind("SUPER + SHIFT + GRAVE", "Mover janela para a área de apoio", hl.dsp.window.move({ workspace = "name:apoio", follow = false }))

-- Super+Alt+R reaplica a divisão de áreas entre as telas (útil se algo ficou
-- fora do lugar depois de conectar/desconectar monitor ou mudar a disposição)
o.bind("SUPER + ALT + R", "Reorganizar áreas entre as telas", function()
  require("hypr.workspaces").reconcile(true)
end)

-- Super+F maximiza como o Niri: ocupa a tela mantendo barra e bordas (era: tela cheia, agora em Super+Shift+F)
hl.unbind("SUPER + F")
o.bind("SUPER + F", "Maximize", "omarchy-maximize-toggle")

-- Super+Delete alterna layout dwindle/scrolling (era: Super+L)
hl.unbind("SUPER + L")
o.bind("SUPER + Delete", "Toggle workspace layout", "omarchy-hyprland-workspace-layout-toggle")

-- Super+L bloqueia a tela, como no Windows (Super+Ctrl+L continua funcionando)
o.bind("SUPER + L", "Lock system", "omarchy-system-lock")

-- Super+Ctrl+↑/↓ move a janela para a área de trabalho anterior/próxima (cria uma nova no fim)
-- Super+Ctrl+←/→ continuam movendo a janela dentro da área
o.bind("SUPER + CTRL + UP", "Move window to previous workspace", workspace_step(-1, true))
o.bind("SUPER + CTRL + DOWN", "Move window to next workspace", workspace_step(1, true))

-- Yazi no lugar do Nautilus (Super+Alt+Shift+F continua abrindo o Nautilus)
hl.unbind("SUPER + SHIFT + F")
o.bind("SUPER + SHIFT + F", "File manager (Yazi)", "kitty -e yazi")

-- Super+P: escolher modo de tela, como no Windows (era: pseudo window)
hl.unbind("SUPER + P")
-- Super+Tab: áreas de trabalho abertas e os apps de cada uma, no notch do MyBar
-- (era: próximo workspace; Super+Shift+Tab e Super+Ctrl+Tab continuam do Omarchy)
hl.unbind("SUPER + TAB")
o.bind("SUPER + TAB", "Áreas de trabalho", "omarchy-shell mybar open workspaces")

-- Super+P abre a view "Tela" no notch do MyBar (modos do Windows, disposição arrastável e ajustes de cada tela)
o.bind("SUPER + P", "Display mode", "omarchy-shell mybar open display")
o.bind("SUPER + ALT + J", "Fones JBL", "omarchy-shell mybar open jbl")
o.bind("SUPER + MOD5 + code:44", "Fones JBL (AltGr)", "omarchy-shell mybar open jbl")
-- Super+Alt+N alterna o notch entre grudado no topo e flutuante (com animação)
o.bind("SUPER + ALT + N", "Notch grudado/flutuante", "omarchy-shell mybar notchStyle toggle")
-- Alt direito = AltGr (MOD5) no ABNT2: os atalhos Super+Alt do MyBar ganham um gêmeo pela tecla física
o.bind("SUPER + MOD5 + code:57", "Notch grudado/flutuante (AltGr)", "omarchy-shell mybar notchStyle toggle")
-- Super+Alt+. abre as Configurações do MyBar (também pela engrenagem da faixa de hover)
o.bind("SUPER + ALT + PERIOD", "Configurações do MyBar", "omarchy-shell mybar open settings")
-- Mesmo atalho com o Alt direito (AltGr no ABNT2: vira MOD5 e muda o símbolo do ponto, então vai pela tecla física)
o.bind("SUPER + MOD5 + code:60", "Configurações do MyBar (AltGr)", "omarchy-shell mybar open settings")

-- Agentes de IA num kitty, abrindo em ~/Projects
o.bind("SUPER + ALT + C", "Claude Code", "kitty --directory " .. os.getenv("HOME") .. "/Projects bash -ic 'claude; exec bash'")
o.bind("SUPER + ALT + O", "opencode", "kitty --directory " .. os.getenv("HOME") .. "/Projects bash -ic 'opencode; exec bash'")


-- Alt+Print: para a gravação se estiver gravando; senão abre as opções de gravação no notch do MyBar (era: menu flutuante do Omarchy)
hl.unbind("ALT + PRINT")
o.bind("ALT + PRINT", "Screenrecording", "omarchy-capture-screenrecording --stop-recording || omarchy-shell mybar menu trigger.capture.screenrecord")

-- Super+Alt+M abre o player de música no notch do MyBar (e o gêmeo pelo AltGr no ABNT2)
o.bind("SUPER + ALT + M", "Player de música", "omarchy-shell mybar open media")
o.bind("SUPER + MOD5 + code:58", "Player de música (AltGr)", "omarchy-shell mybar open media")
