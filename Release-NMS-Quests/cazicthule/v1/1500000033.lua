local item_lib = require("items");
function event_trade(e)
	if ( item_lib.check_turn_in(e.trade, {item1 = 8720}) ) then -- Phobonomicon of Thul Tae Ew
		eq.zone_emote(7, "A loud explosion sends ripples of energy through the air! Matter seems to lose its substance, but quickly solidifies. A shriek fills your ears, followed by the pounding sound of drums!");
		eq.spawn2(1500000145, 0, 0, e.self:GetX(), e.self:GetY(), e.self:GetZ(), 0); -- horror construct
		eq.depop_with_timer();
	end
	item_lib.return_items(e.self, e.other, e.trade);
end
