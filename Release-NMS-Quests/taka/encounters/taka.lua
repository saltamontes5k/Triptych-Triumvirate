-- Encounter: LDoN Raid: Takish-Hiz: Sunken Library
-- Zone: taka / (version 50)
--
-- Cast (pre-placed): Geomantic Compact trash (prodigies, Royal guardians, Jeweled
-- Guard heroes, Sands of Life/Knowledge, stoneservants, golems), the guardian
-- Jeweled Guardian Bathas (70), and the geomancer behind the rite, Geomancer Paara (80).
--
-- Flow: the raid fights through the Sunken Library to the final ritual; slaying
-- Geomancer Paara ends the rite and wins the raid (replay lockout granted).
-- Reward chest spawns are intentionally omitted until takish raid loot is defined.

local won = false;

function Paara_Death(e)
  if won then
    return
  end
  won = true;
  eq.zone_emote(MT.Yellow, "Geomancer Paara's ritual collapses; the sands fall still and the Sunken Library grows quiet.")
  eq.zone_emote(MT.Yellow, "Your victory has shattered the shroud of magic surrounding the dungeon's treasure")

  local dz = eq.get_expedition()
  if dz and dz.valid then
    dz:AddReplayLockout(eq.seconds("4d12h"))
      eq.zone_emote(MT.Yellow, "The Wayfarers take note of your victory.")
      local __cl = eq.get_entity_list():GetClientList()
      if __cl then
        for _, __c in __cl.entries do
          __c:UpdateLDoNPoints(5, 5)
        end
      end
  end
end

function event_encounter_load(e)
  -- Geomancer Paara exists as two npc rows (per zone version); watch both.
  eq.register_npc_event('taka', Event.death_complete, 231778, Paara_Death);
  eq.register_npc_event('taka', Event.death_complete, 231830, Paara_Death);
end
