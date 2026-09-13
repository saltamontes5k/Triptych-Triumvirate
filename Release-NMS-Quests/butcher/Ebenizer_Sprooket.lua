--Frostfell A Gift for Tinam (task 612004)

function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("What do you want?");
	elseif e.message:findi("clockwork dolly") then
        if e.other:IsTaskActive(612004) then
            e.self:Say("My one of a kind clockwork dolly? Bah, why should I [give] it to you?");
        end
	elseif e.message:findi("give") then
        if e.other:IsTaskActive(612004) then
            e.self:Say("Bah! Ebenizer is silent a moment, then a grin appears on his face. I'll tell you what. There is a special gem I want from Butcherblock Mountains. The only dwarf who mines this gem hates me and won't give me the gem. If you can get me that gem, I will give you the dolly. You will find this dwarf along the southern edge of the Butcherblock Mountains.");
        end
    end
end

function event_trade(e)
    local item_lib = require("items");
    if e.other:IsTaskActivityActive(612004,9) then -- Frostfell A Gift for Tinam task activity 9 active
        if item_lib.check_turn_in(e.trade, {item1 = 87541}) then -- Horgram's Gem
			e.self:Say("You're back? I thought you would never come back. I have never seen anyone act so kindly before. Here take the dolly.")
			e.other:UpdateTaskActivity(612004,9,1); -- Frostfell A Gift for Tinam task activity 9 complete
            e.other:SummonItem(87545); -- Clockwork Dolly
		end
    end
    item_lib.return_items(e.self, e.other, e.trade);
end