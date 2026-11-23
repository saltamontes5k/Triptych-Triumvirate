--KT fern click for Berserker 1.5
-- items: 16949
task_ids = require('task_ids')
function event_click_door(e)
  local door_id = e.door:GetDoorID();
	if(door_id == 25 or door_id == 26 or door_id == 27) then
	  local qglobals = eq.get_qglobals(e.self);
		if(e.self:HasClass(Class.BERSERKER) and qglobals["kt_" .. door_id .. "fern"] == nil) then
				e.self:SummonItem(16949); --Taelosian Fern Sample 
				eq.set_global("kt_" .. door_id .. "fern","1",3,"H1")
		end
	end
end

function event_enter_zone(e)
  qvic_flag = tonumber(e.self:GetAccountBucket("god.flags.qvic")) or 0
  if not e.self:HasZoneFlag(Zone.qvic) then
    if (e.self:HasItem(60176) and e.self:HasItem(60252)) or qvic_flag == 1 then
      e.self:SetZoneFlag(Zone.qvic)
      e.self:SetAccountBucket("god.flags.qvic", "1")
      e.self:Message(MT.LightBlue, "The magical barrier protecting Qvic appears to have weakened, allowing access.")
    end
  end
end

-- These clue pieces are ground spawns, so looting them is what advances the
-- task. The task engine only auto-credits Loot activities for corpse loot, so
-- the ground-spawn pickups are credited here, along with the follow-up Deliver
-- activities (Tublik no longer requires a hand-in for these items).
function event_player_pickup(e)
  local item_id = e.item:GetID()
  if item_id == 60162 or item_id == 60163 or item_id == 60164 or item_id == 60165 then
    e.self:UpdateTaskActivity(task_ids.tublik_task, 7, 1)   -- Frayed Flesh Scraps looted
    e.self:UpdateTaskActivity(task_ids.tublik_task, 8, 4)   -- no hand-in needed
  elseif item_id == 60167 or item_id == 60168 or item_id == 60169 then
    e.self:UpdateTaskActivity(task_ids.tublik_task, 11, 1)  -- trial temple clues looted
    e.self:UpdateTaskActivity(task_ids.tublik_task, 12, 3)  -- no hand-in needed
  end
end

