-- powar: The Grandmaster — the chess event behind the mid-north wall.
-- 13-minute hard limit (Bonzz pow.htm): pieces spawn onto the board while
-- the Grandmaster sits; he goes active on engage. Beat him before the clock
-- or the game resets. Drops: Fiery Helm of Rallos Zek and three more pieces
-- of the set (loot table PoWar_Grandmaster).
local P = require("powar_shared")

local TIME_LIMIT_MS = 13 * 60 * 1000
local pieces = { 1520001006, 1520001015, P.NPC.knight, P.NPC.rook }
local running = false

local function clear_pieces(x, y, z)
  local list = eq.get_entity_list():GetNPCList()
  if list == nil then return end
  for npc in list.entries do
    if npc.valid then
      local id = npc:GetNPCTypeID()
      if id == P.NPC.knight or id == P.NPC.rook or id == 1520001006 or id == 1520001015 then
        -- only depop the event's chess pieces (within 60 units of the board),
        -- never the field's own pawns and crows
        if npc:CalculateDistance(x, y, z) < 60 then
          npc:Depop()
        end
      end
    end
  end
end

function event_spawn(e)
  running = false
  eq.stop_timer("clock")
  eq.stop_timer("wave")
  e.self:Emote("sits at a board older than the castle, considering a piece that has not moved in an age.")
end

function event_combat(e)
  if e.joined and not running then
    running = true
    eq.set_timer("clock", TIME_LIMIT_MS)
    eq.set_timer("wave", 20000)
    eq.zone_emote(15, "The Grandmaster reaches for the board. 'White opens. You are black - and black is losing.' The game begins: thirteen minutes!")
  elseif not e.joined and running then
    running = false
    eq.stop_timer("clock")
    eq.stop_timer("wave")
    clear_pieces(e.self:GetX(), e.self:GetY(), e.self:GetZ())
    e.self:SetHP(e.self:GetMaxHP())
    eq.zone_emote(15, "The Grandmaster sweeps the board clean. 'Resignation accepted. The game resets.'")
  end
end

function event_timer(e)
  if e.timer == "wave" then
    local x, y, z = e.self:GetX(), e.self:GetY(), e.self:GetZ()
    local n = math.random(2, 4)
    for i = 1, n do
      local piece = pieces[math.random(1, #pieces)]
      eq.unique_spawn(piece, 0, 0, x + math.random(-40, 40), y + math.random(-40, 40), z, 0)
    end
    local calls = { "A pawn advances diagonally!", "A rook takes the long file!", "A knight jumps the line!", "The board shifts - pieces close from two sides!" }
    e.self:ZoneEmote(15, calls[math.random(1, #calls)])
  elseif e.timer == "clock" then
    running = false
    eq.stop_timer("wave")
    clear_pieces(e.self:GetX(), e.self:GetY(), e.self:GetZ())
    e.self:SetHP(e.self:GetMaxHP())
    eq.zone_emote(15, "The Grandmaster turns the hourglass. 'Time. A perfect game - and you were not playing it.'")
  end
end

function event_death(e)
  running = false
  eq.stop_timer("clock")
  eq.stop_timer("wave")
  clear_pieces(e.self:GetX(), e.self:GetY(), e.self:GetZ())
  eq.zone_emote(15, "The Grandmaster topples like a taken king. 'Check,' the board seems to say, 'mate.'")
end
