-- 294141
-- Ikky Raid 1
-- Database Version 3
local doorman_1 = nil;
local doorman_2 = nil;
local doorman_3 = nil;
local priests = 0;
local defenders = 0;
function event_spawn(e)
  doorman_1 = eq.spawn2(294632, 0, 0, 218, -336, -2.77, 0.00); -- NPC: doorman
  doorman_2 = eq.spawn2(294632, 0, 0, 90, -412, -2.77, 0.00); -- NPC: doorman

  doorman_3 = eq.spawn2(294633, 0, 0, 240, -496, -2.87, 0.00); -- NPC: doorman
  
  -- Set a timer to check the zone; this is needed
  -- in case the zone crashes to reset the doormen 
  -- properly.  Can't reliably do a entity check as 
  -- the zone is booting up; so we'll do the check 5 sec 
  -- after it boots up; all the mobs should be spawned by 
  -- then.
  eq.set_timer("checkdoors", 5 * 1000 );
end

function event_timer(e)
  if (e.timer == "checkdoors") then
    eq.stop_timer(e.timer);
    eq.signal(294141, 1); -- NPC: #Trigger_Ikkinz_1
  end
end

function event_signal(e)
  eq.debug("signal: " .. tostring(e.signal))
  if e.signal == 10 then
    priests = priests + 1
    eq.debug("priests: " .. tostring(priests))
  elseif e.signal == 20 then
    defenders = defenders + 1
    eq.debug("defenders: " .. tostring(defenders))
  else
    if not eq.get_entity_list():IsMobSpawnedByNpcTypeID(294574) and not eq.get_entity_list():IsMobSpawnedByNpcTypeID(294338) then 
      -- Check Priest of Righteousness
      eq.get_entity_list():FindDoor(2):SetLockPick(0);
      eq.get_entity_list():FindDoor(3):SetLockPick(0);
      eq.get_entity_list():FindDoor(4):SetLockPick(0);
      eq.get_entity_list():FindDoor(5):SetLockPick(0);

      eq.depop_all(294632);
    end

    if not eq.get_entity_list():IsMobSpawnedByNpcTypeID(294339) and not eq.get_entity_list():IsMobSpawnedByNpcTypeID(294575) then 
      -- Check Defender of Righteousness
      eq.get_entity_list():FindDoor(6):SetLockPick(0);
      eq.get_entity_list():FindDoor(7):SetLockPick(0);

      eq.depop_all(294633);
    end
  end
  if priests == 3 and defenders == 2 then
      eq.signal(294340, 1) --Custodian of Righteousness
  end
end
