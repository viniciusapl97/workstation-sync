-- Áreas de trabalho com e sem monitor externo.
--
-- Um modelo só, igual nas duas situações:
--
--   1 … 10   trabalho  → no monitor externo quando ele está conectado, na tela
--                        do notebook quando não está.
--   apoio    → vídeo, Discord e WhatsApp: mora sempre na tela do notebook
--                        (área com nome, não número, para nunca colidir com a
--                        expansão 1…10 e para aparecer escrita no Super+Tab).
--
-- O Hyprland não mantém essa divisão sozinho: área nova nasce no monitor em foco
-- e, ao conectar ou desconectar uma tela, cada área fica onde caiu. Quem garante
-- o modelo é o reconciliador abaixo (M.reconcile): ele lê as telas ativas e move
-- o que estiver fora do lugar. É idempotente — rodar duas vezes seguidas não
-- muda nada — e roda ao conectar/desconectar monitor, no início da sessão e em
-- SUPER + ALT + R (atalho em bindings.lua).
--
-- Nada aqui depende de hotplug para o dia a dia: com uma tela só, as áreas 1…10
-- e a de apoio ficam todas na tela do notebook, e os mesmos atalhos continuam
-- valendo. Conectar o monitor só muda de tela o que é de trabalho.

local M = {}

local SUPPORT = "apoio"        -- área de apoio (nome da área)
local RECENT = {}              -- áreas de trabalho usadas, da mais recente para a mais antiga

local function is_internal(name)
  return name:find("^eDP") or name:find("^LVDS") or name:find("^DSI")
end

-- Guarda a ordem de uso das áreas de trabalho: ao conectar uma tela, o foco
-- volta para a área em que ele estava, e não para uma que ficou vazia.
local function remember(id)
  for index, value in ipairs(RECENT) do
    if value == id then
      table.remove(RECENT, index)
      break
    end
  end

  table.insert(RECENT, 1, id)

  while #RECENT > 8 do
    table.remove(RECENT)
  end
end

-- Tela do notebook e monitor externo ativos agora (nil quando ausente).
function M.displays()
  local internal, external
  for _, monitor in ipairs(hl.get_monitors()) do
    if is_internal(monitor.name) then
      internal = internal or monitor.name
    else
      external = external or monitor.name
    end
  end

  return internal, external
end

-- Tela do trabalho e tela do apoio agora.
function M.targets()
  local internal, external = M.displays()

  return external or internal, internal or external
end

-- Espelhamento: as duas telas mostram a mesma coisa, então dividir áreas entre
-- elas não faz sentido. O Hyprland não expõe `mirrorOf` na API Lua, mas a tela
-- espelhada recebe a geometria da origem — mesma posição e mesmo tamanho.
function M.mirroring()
  local seen = {}

  for _, monitor in ipairs(hl.get_monitors()) do
    local key = ("%d:%d:%d:%d"):format(monitor.width, monitor.height, monitor.x, monitor.y)

    if seen[key] then
      return true
    end

    seen[key] = true
  end

  return false
end

-- Devolve o foco para a área de trabalho em uso: a mais recente que ainda tem
-- janelas; sem histórico, foca a tela de trabalho.
function M.focus_work()
  local work = select(1, M.targets())

  if not work then
    return
  end

  local target_id

  for _, id in ipairs(RECENT) do
    for _, workspace in ipairs(hl.get_workspaces()) do
      if tostring(workspace.id) == id and (workspace.windows or 0) > 0 then
        target_id = id
        break
      end
    end
    if target_id then break end
  end

  if target_id then
    hl.dispatch(hl.dsp.focus({ workspace = target_id }))
  else
    hl.dispatch(hl.dsp.focus({ monitor = work }))
  end
end

-- Move cada área para a tela certa. Devolve quantas mudaram de tela.
-- focus = true devolve o foco para a área de trabalho em uso (é o que se quer
-- depois de conectar ou desconectar uma tela).
function M.reconcile(focus)
  local work, support = M.targets()

  if not work or M.mirroring() then
    return 0
  end

  local workspaces = hl.get_workspaces()
  local moved, has_support = 0, false

  for _, workspace in ipairs(workspaces) do
    if workspace.name == SUPPORT then
      has_support = true
      break
    end
  end

  -- A área de apoio primeiro: se ela não existe e a tela do notebook fica sem
  -- nenhuma área, o Hyprland cria uma no lugar assim que a última área de
  -- trabalho sai — e sobra uma área de trabalho solta na tela interna. Com uma
  -- tela só ela é uma área como as outras, então só faz sentido com duas.
  -- Criar exige focar a área, então só acontece quando o foco já vai ser
  -- devolvido no fim (as passadas de acompanhamento não mexem no foco).
  if not has_support and support ~= work and focus then
    hl.dispatch(hl.dsp.focus({ workspace = "name:" .. SUPPORT }))
    workspaces = hl.get_workspaces()
    moved = moved + 1
  end

  for _, workspace in ipairs(workspaces) do
    local target

    if workspace.name == SUPPORT then
      target = support
    elseif (workspace.id or 0) > 0 then
      target = work
    end
    -- Área especial/scratchpad (id negativo) ou nomeada desconhecida: fica onde está.

    if target and workspace.monitor and workspace.monitor.name ~= target then
      hl.dispatch(hl.dsp.workspace.move({ workspace = workspace.name, monitor = target }))
      moved = moved + 1
    end
  end

  if focus then
    M.focus_work()
  end

  return moved
end

-- Uma passada agora e duas depois: ao conectar, o Hyprland ainda cria e
-- rearranja áreas nos primeiros instantes, e uma passada só pegaria o meio.
local function settle(focus)
  M.reconcile(focus)
  hl.timer(function() M.reconcile(false) end, { timeout = 400, type = "oneshot" })
  hl.timer(function() M.reconcile(false) end, { timeout = 1500, type = "oneshot" })
end

hl.on("workspace.active", function()
  local workspace = hl.get_active_workspace()

  if workspace and (workspace.id or 0) > 0 and (workspace.windows or 0) > 0 then
    remember(tostring(workspace.id))
  end
end)

hl.on("monitor.added", function() settle(true) end)
hl.on("monitor.removed", function() settle(true) end)
hl.on("hyprland.start", function()
  hl.timer(function() settle(true) end, { timeout = 1500, type = "oneshot" })
end)

-- A área de apoio nasce na tela do notebook. Com o painel interno desligado
-- (modo "só externo"), a regra cai no monitor em foco, que é o externo.
local work_monitor, pair_monitor = M.targets()
hl.workspace_rule({ workspace = "name:" .. SUPPORT, monitor = pair_monitor or "eDP-1", persistent = true })

-- Áreas numeradas nascem na tela de trabalho, não na tela em foco: sem isto,
-- Super+3 (ou 3 dentro do Super+Tab) com o foco no apoio criava a área 3 no
-- painel do notebook, furando a divisão até o próximo Super+Alt+R. A regra vale
-- para criação e é reavaliada a cada reload — todo modo de tela do MyBar dá
-- reload, então ela acompanha conectar/desconectar monitor.
if work_monitor then
  for id = 1, 10 do
    hl.workspace_rule({ workspace = tostring(id), monitor = work_monitor })
  end
end

-- Apps que moram na área de apoio, aberto de onde for: ficam lá sem roubar o
-- foco (silent) — o vídeo começa a tocar no monitor de apoio e o trabalho
-- continua na tela em uso.
local SUPPORT_APPS = {
  "[Ww]hatsapp",
  "[Dd]iscord",
  "^mpv$",
  "^vlc$",
  "^celluloid$",
  "^haruna$",
}

for _, class in ipairs(SUPPORT_APPS) do
  o.window({ class = class }, { workspace = "name:" .. SUPPORT .. " silent" })
end

return M
