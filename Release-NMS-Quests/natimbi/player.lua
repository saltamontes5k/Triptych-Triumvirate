function event_click_door(e)
local kt_flag = tonumber(e.self:GetAccountBucket("god.flags.kt")) or 0
  local door_id = e.door:GetDoorID();
  if door_id == 1 then
    if kt_flag == 1 then
      if not e.self:HasZoneFlag(293) then
        e.self:SetZoneFlag(293)
      end
    end
  end
end
