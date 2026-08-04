function event_spawn(e)
    eq.set_timer("repeat", 3 * 1000);
end

function event_timer(e)
    e.self:DoAnim(58); -- Emote: Dance
end

function event_trade(e)
	local item_lib = require("items");
    item_lib.return_items(e.self, e.other, e.trade)
end
