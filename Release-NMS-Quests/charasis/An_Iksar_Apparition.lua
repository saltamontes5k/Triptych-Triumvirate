--Shaman Cudgel Quest 8

function event_trade(e)
	local item_lib					= require("items");
	local Shaman_Cudgel_Progress	= e.other:GetBucket("Shaman_Cudgel")

	if e.other:GetLevel() >= 50 and Shaman_Cudgel_Progress == "8.2" and item_lib.check_turn_in(e.trade, {item1 = 30994}) then	-- Item: Iksar Relics
		eq.unique_spawn(105182,0,0,e.self:GetX(),e.self:GetY(),e.self:GetZ(),e.self:GetHeading());	-- NPC: Venril_Sathir
		eq.unique_spawn(105186,0,0,-13,-658,8,100);													-- NPC: an Arisen Disciple
		eq.unique_spawn(105183,0,0,13,-658,8,160);													-- NPC: an Arisen Priest
		eq.unique_spawn(105184,0,0,13,-690,8,228);													-- NPC: an Arisen Necromancer
		eq.unique_spawn(105185,0,0,-13,-690,8,34);													-- NPC: an Arisen Acolyte
		eq.depop_with_timer();
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
