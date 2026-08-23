-- Shaman Cudgel Quest 8
function event_death_complete(e)
	eq.unique_spawn(105187,0,0,e.self:GetX(),e.self:GetY(),e.self:GetZ()); -- NPC: the_spirit_of_Rile
end

function event_trade(e)
	local item_lib = require("items");
	item_lib.return_items(e.self, e.other, e.trade)
end
