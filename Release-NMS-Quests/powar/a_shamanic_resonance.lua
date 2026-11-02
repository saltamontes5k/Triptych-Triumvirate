-- powar: a shamanic resonance — the four shrine crystals in Castle Tamrel.
-- Attackable always; destructible in spirit only while a Strategic Colossus
-- walks (Bonzz pow.htm). When all four fall with the colossus present,
-- High Tactician Drelg comes out of the shrine.
local P = require("powar_shared")
local item_lib = require("items")

local STRATEGIC = 97472 -- Strategic Colossus

local function colossus_present()
  local list = eq.get_entity_list():GetNPCList()
  if list == nil then return false end
  for npc in list.entries do
    if npc.valid and npc:GetNPCTypeID() == P.NPC.colossus then return true end
  end
  return false
end

local function crystals_dead()
  return tonumber(eq.get_data("pow-crystals-dead")) or 0
end

function event_say(e)
  -- the crystal answers only the deployment of the colossus
end

function event_trade(e)
  local c = e.other
  if item_lib.check_turn_in(e.trade, { item1 = STRATEGIC }) then
    eq.set_data("pow-colossus-owner", tostring(c:CharacterID()))
    eq.unique_spawn(P.NPC.colossus, 0, 0, e.self:GetX() + 20, e.self:GetY(), e.self:GetZ(), 0)
    eq.zone_emote(15, "The Strategic Colossus unfolds with a groan of old war. Orcs fill it like marrow. It turns toward Castle Tamrel's shrine.")
    P.say(e, "The colossus walks. Break the four shamanic resonances of the shrine - south room, the room south of it, the back room west, and the northeast room - and Drelg will come out to see who is breaking his crystals.")
  else
    item_lib.return_items(e.self, e.other, e.trade)
  end
end

function event_death(e)
  local dead = crystals_dead() + 1
  eq.set_data("pow-crystals-dead", tostring(dead))
  if not colossus_present() then
    eq.zone_emote(15, "The resonance shatters - and the shards crawl back together. Without the Strategic Colossus, the shrine rebuilds itself.")
    return
  end
  if dead >= 4 and (eq.get_data("pow-drelg-up") or "") ~= "1" then
    eq.set_data("pow-drelg-up", "1")
    eq.unique_spawn(P.NPC.drelg, 0, 0, -1665, -1525, 25, 0)
    eq.zone_emote(15, "High Tactician Drelg emerges from the shrine, and the honor guard rises with him!")
  else
    eq.zone_emote(15, "A shamanic resonance shatters. " .. (4 - dead) .. " remain.")
  end
end
