-- Encounter: LDoN Raid: Miragul's Menagerie: Spider Den
-- Zone: mirc / (version 0)
--
-- Cast (pre-placed): Frostfoot goblins/spiders, and the three goblin leaders:
--   Sage_Venos (242353), Oracle_Brofam (242354), Warlord_Petrad (242355)
-- Win when all three leaders are slain and the captives are safe.

local won = false;
local down = {};

function Boss_Death(e)
  down[e.self:GetNPCTypeID()] = true;
  local all = true;
  for _, id in ipairs({ 242353, 242354, 242355 }) do
    if not down[id] then all = false; break end
  end
  if all and not won then
    won = true;
    eq.zone_emote(MT.Yellow, "The Frostfoot leaders are dead; the surviving Wayfarers are freed from the Spider Den.")
    eq.zone_emote(MT.Yellow, "Your victory has shattered the shroud of magic surrounding the dungeon's treasure")
    local dz = eq.get_expedition()
    if dz and dz.valid then dz:AddReplayLockout(eq.seconds("4d12h")) end
      eq.zone_emote(MT.Yellow, "The Wayfarers take note of your victory.")
      local __cl = eq.get_entity_list():GetClientList()
      if __cl then
        for _, __c in __cl.entries do
          __c:UpdateLDoNPoints(2, 5)
        end
      end
  end
end

function event_encounter_load(e)
  eq.register_npc_event('mirc', Event.death_complete, 242353, Boss_Death);
  eq.register_npc_event('mirc', Event.death_complete, 242354, Boss_Death);
  eq.register_npc_event('mirc', Event.death_complete, 242355, Boss_Death);
end
