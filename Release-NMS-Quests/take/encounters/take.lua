-- Encounter: LDoN Raid: Takish-Hiz: The Palace Grounds
-- Zone: take / (version 50)
--
-- Cast (pre-placed): escort defenders/trash/traps, enraged jeweled guards (251904),
-- and the three Guard rooms led by:
--   Master_of_the_Guard     (251901) - northwest
--   Tactician_of_the_Guard  (251902) - southwest
--   Champion_of_the_Guard   (251903) - northeast
--
-- Flow (doc): the three defender elementals escort to their guard rooms, four waves of
-- five enraged guards are defeated in each room, then each Guard leader falls. Slaying
-- all three Guard leaders wins the raid; the reward chest appears in the room south of
-- the Master. Defeat Tactician and Champion before the Master to earn all chests.

local won = false;
local down = {};

function Guard_Death(e)
  down[e.self:GetNPCTypeID()] = true;
  local all = true;
  for _, id in ipairs({ 251901, 251902, 251903 }) do
    if not down[id] then all = false; break end
  end
  if all and not won then
    won = true;
    eq.zone_emote(MT.Yellow, "The Guard leadership is broken and the Palace Grounds fall quiet.")
    eq.zone_emote(MT.Yellow, "Your victory has shattered the shroud of magic surrounding the dungeon's treasure")
    eq.spawn2(251905, 0, 0, e.self:GetX(), e.self:GetY(), e.self:GetZ(), e.self:GetHeading()) -- #Palace_Grounds_Chest
    local dz = eq.get_expedition()
    if dz and dz.valid then dz:AddReplayLockout(eq.seconds("4d12h")) end
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
  eq.register_npc_event('take', Event.death_complete, 251901, Guard_Death);
  eq.register_npc_event('take', Event.death_complete, 251902, Guard_Death);
  eq.register_npc_event('take', Event.death_complete, 251903, Guard_Death);
end
