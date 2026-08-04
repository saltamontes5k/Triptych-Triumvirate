local BIC_ITEM      = 52154;
local KEYMASTER_ID  = 282116;

function event_player_pickup(e)
  if e.item:GetID() == BIC_ITEM then
    eq.signal(KEYMASTER_ID,1)
  end
end
