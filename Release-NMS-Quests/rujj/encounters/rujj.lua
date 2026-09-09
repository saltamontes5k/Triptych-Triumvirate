-- Encounter: LDoN Raid: Rujarkian Hills: War March of Imal Ojun
-- Zone: rujj / (version 50)
--
-- Cast (pre-placed): Steelslave/Ojun legions, the three captains appointed by the
-- Warlord (#Captain_Grelnik 273749, #Captain_Kalin 273761, #Captain_Hurklin 273772),
-- and #Warlord_Imal_Ojun (273736). An orcish reward chest is pre-placed in the zone.
--
-- Flow: the raid disrupts the warlord's army. Slaying the three captains crumbles the
-- force; finishing #Warlord_Imal_Ojun ends the war march and wins the raid.

local warlord_down = false;

function Captain_Death(e)
  eq.zone_emote(MT.Yellow, "A captain of Imal Ojun falls; the orcish war drums falter.")
end

function Warlord_Death(e)
  if warlord_down then
    return
  end
  warlord_down = true;
  eq.zone_emote(MT.Yellow, "Warlord Imal Ojun is slain. Without their warlord the orcish army scatters.")
  eq.zone_emote(MT.Yellow, "Your victory has shattered the shroud of magic surrounding the dungeon's treasure")

  local dz = eq.get_expedition()
  if dz and dz.valid then
    dz:AddReplayLockout(eq.seconds("4d12h"))
      eq.zone_emote(MT.Yellow, "The Wayfarers take note of your victory.")
      local __cl = eq.get_entity_list():GetClientList()
      if __cl then
        for _, __c in __cl.entries do
          __c:UpdateLDoNPoints(4, 5)
        end
      end
  end
end

function event_encounter_load(e)
  eq.register_npc_event('rujj', Event.death_complete, 273749, Captain_Death);
  eq.register_npc_event('rujj', Event.death_complete, 273761, Captain_Death);
  eq.register_npc_event('rujj', Event.death_complete, 273772, Captain_Death);
  eq.register_npc_event('rujj', Event.death_complete, 273736, Warlord_Death);
end
