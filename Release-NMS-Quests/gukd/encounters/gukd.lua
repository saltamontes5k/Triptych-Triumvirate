-- Encounter: LDoN Raid: Deepest Guk: The Mushroom Grove
-- Zone: gukd / version 50. Cast reused from gukc, placed at map-derived interior points.
local boss_down = false;

function Boss_Death(e)
  if boss_down then return end
  boss_down = true;
  eq.zone_emote(MT.Yellow, "The cursed Korta leader falls. The grove's corruption begins to recede.");
  eq.zone_emote(MT.Yellow, "Your victory has shattered the shroud of magic surrounding the dungeon's treasure");

  local dz = eq.get_expedition()
  if dz and dz.valid then
    dz:AddReplayLockout(eq.seconds("4d12h"))
    eq.zone_emote(MT.Yellow, "The Wayfarers take note of your victory.")
    local __cl = eq.get_entity_list():GetClientList()
    if __cl then
      for _, __c in __cl.entries do
        __c:UpdateLDoNPoints(1, 5)
      end
    end
  end

  eq.spawn2(893, 0, 0, e.self:GetX(), e.self:GetY(), e.self:GetZ(), e.self:GetHeading()) -- a chest
end

function event_encounter_load(e)
  eq.register_npc_event('gukd', Event.death_complete, 239289, Boss_Death);
end
