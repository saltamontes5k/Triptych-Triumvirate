-- Encounter: LDoN Raid: The Rujarkian Hills: Wind Bridges
-- Zone: rujc / version 50. Cast reused from rujd v50, placed at map-derived interior points.
local boss_down = false;

function Boss_Death(e)
  if boss_down then return end
  boss_down = true;
  eq.zone_emote(MT.Yellow, "Taskmaster Velrek is slain. The Rujarkian bridges fall silent.");
  eq.zone_emote(MT.Yellow, "Your victory has shattered the shroud of magic surrounding the dungeon's treasure");

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

  eq.spawn2(273721, 0, 0, e.self:GetX(), e.self:GetY(), e.self:GetZ(), e.self:GetHeading()) -- an_orcish_chest
end

function event_encounter_load(e)
  eq.register_npc_event('rujc', Event.death_complete, 245199, Boss_Death);
end
