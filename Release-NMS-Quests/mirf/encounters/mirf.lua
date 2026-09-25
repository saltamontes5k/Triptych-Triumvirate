-- Encounter: LDoN Raid: Miragul's Menagerie: The Forgotten Wastes
-- Zone: mirf / version 50. Cast reused from mirc, placed at map-derived interior points.
local boss_down = false;

function Boss_Death(e)
  if boss_down then return end
  boss_down = true;
  eq.zone_emote(MT.Yellow, "The Frostfoot archpriest is slain. The wastes fall silent.");
  eq.zone_emote(MT.Yellow, "Your victory has shattered the shroud of magic surrounding the dungeon's treasure");

  local dz = eq.get_expedition()
  if dz and dz.valid then
    dz:AddReplayLockout(eq.seconds("4d12h"))
    eq.zone_emote(MT.Yellow, "The Wayfarers take note of your victory.")
    local __cl = eq.get_entity_list():GetClientList()
    if __cl then
      for _, __c in __cl.entries do
        __c:UpdateLDoNPoints(2, 5)
      end
    end
  end

  eq.spawn2(893, 0, 0, e.self:GetX(), e.self:GetY(), e.self:GetZ(), e.self:GetHeading()) -- a chest
end

function event_encounter_load(e)
  eq.register_npc_event('mirf', Event.death_complete, 242008, Boss_Death);
end
