task_ids = require('task_ids')

function event_enter_zone(e)
	if not e.self:IsTaskActive(task_ids.oow_hollows) and not e.self:IsTaskCompleted(task_ids.oow_hollows) then
		e.self:AssignTask(task_ids.oow_hollows)
	end
end

function event_click_door(e)
  local door_id = e.door:GetDoorID();
  if (door_id == 2) then  
      e.self:MovePC(302, -2017.2, 17.26,205.8,126); -- Zone: draniksscar
  end
end
