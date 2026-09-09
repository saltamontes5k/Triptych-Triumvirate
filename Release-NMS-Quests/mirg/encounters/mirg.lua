-- Encounter: LDoN Raid: Miragul's Menagerie: Folly of Miragul's Ambition
-- Zone: mirg / (version 0)
--
-- Cast: the menagerie's planar specimens/holgresh/skeletal scholars with the sentient
-- magic of the Menagerie, #The_Synarcana (262207 / 262208), lurking at its heart.
-- The Synarcana is script-spawned on encounter load near the zone-in, then must be slain.

local won = false;

function Synarcana_Death(e)
  if won then return end
  won = true;
  eq.zone_emote(MT.Yellow, "The Synarcana unravels; the sentient magic of Miragul's Menagerie scatters and dies.")
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

function event_encounter_load(e)
  local el = eq.get_entity_list()
  if not el:IsMobSpawnedByNpcTypeID(262208) and not el:IsMobSpawnedByNpcTypeID(262207) then
    eq.spawn2(262208, 0, 0, 482, 28, 76.125, 218) -- #The_Synarcana (level 72)
  end
  eq.register_npc_event('mirg', Event.death_complete, 262208, Synarcana_Death);
  eq.register_npc_event('mirg', Event.death_complete, 262207, Synarcana_Death);
end
