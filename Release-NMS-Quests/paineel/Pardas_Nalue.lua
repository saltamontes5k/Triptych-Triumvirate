function event_say(e)
	if e.message:findi("Hail") then
		e.self:Say("Oh. hello there. " .. e.other:GetName() .. "!  I have been absolutely slaving all day to choose a new [advertisement] for my wonderful store here.  Care to hear what I have?");
	elseif e.message:findi("advertisement?") then
		e.self:Say("Excellent!  Here goes.  Come to Pardas Nalue's Sinfully Handsome Tailor!  You can get everything you need to be just as good looking as Pardas.  Well. almost everything!  So. do you [like it]?");
	elseif e.message:findi("like") or e.message:findi("yes") then
		e.self:Say("I just knew you would!  Come on folks. let's watch the money just come pouring in!  Isn't this absolutely fabulous?!");
	elseif e.message:findi("didn") or e.message:findi("no") then
		e.self:Say("Fine, then!  See if I will ever share my wonderful ideas with you again!  Hrmph!");
		e.self:DoAnim(30);
	end
end

function event_trade(e)
	local item_lib = require("items");
    item_lib.return_items(e.self, e.other, e.trade)
end
