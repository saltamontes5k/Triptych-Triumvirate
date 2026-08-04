function event_spawn(e)
	eq.set_timer("depop",20 * 60 * 1000); -- 20 Minutes
	e.self:SetRunning(true);
end

function event_timer(e)
	eq.depop();
end

function event_combat(e)
	if e.joined then
		e.self:Say("The time fer talk is over.  Raise yer guard!!");
		eq.signal(12082,1);
		eq.signal(12154,1);
	end
end

function event_trade(e)
	local item_lib = require("items");
	item_lib.return_items(e.self, e.other, e.trade)
end
