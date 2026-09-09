-- Encounter: LDoN Raid: Mistmoore Catacombs: Scion Lair of Fury
-- Zone: mmcf / (version 50)
--
-- Cast (pre-placed): Scion summoners and elite guardians, and the three raid leaders:
--   #Sfisithik_the_Light_Devourer (258481)
--   #Grortrakien_the_Mutilator     (258514)
--   #Halusant_the_Nightblood       (258519)
-- Win when all three are slain.

local won = false;
local down = {};

function Boss_Death(e)
  down[e.self:GetNPCTypeID()] = true;
  local all = true;
  for _, id in ipairs({ 258481, 258514, 258519 }) do
    if not down[id] then all = false; break end
  end
  if all and not won then
    won = true;
    eq.zone_emote(MT.Yellow, "The Scion leaders are destroyed and the Trueborn scheme collapses.")
    eq.zone_emote(MT.Yellow, "Your victory has shattered the shroud of magic surrounding the dungeon's treasure")
    local dz = eq.get_expedition()
    if dz and dz.valid then dz:AddReplayLockout(eq.seconds("4d12h")) end
      eq.zone_emote(MT.Yellow, "The Wayfarers take note of your victory.")
      local __cl = eq.get_entity_list():GetClientList()
      if __cl then
        for _, __c in __cl.entries do
          __c:UpdateLDoNPoints(3, 5)
        end
      end
  end
end

function event_encounter_load(e)
  eq.register_npc_event('mmcf', Event.death_complete, 258481, Boss_Death);
  eq.register_npc_event('mmcf', Event.death_complete, 258514, Boss_Death);
  eq.register_npc_event('mmcf', Event.death_complete, 258519, Boss_Death);
end
