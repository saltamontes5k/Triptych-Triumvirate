function event_say(e)
	if e.other:GetFaction(e.self) < 6 then
		if e.message:findi("hail") then
			e.self:Say("Uggg. You needz [keyz]? Rrrrrrr.");
		elseif e.message:findi("key") then
			e.self:Say("Uggggg. Take dis keyz.");
			if not e.other:HasItem(6378) then
				e.other:SummonItem(6378); -- Item: Bone Crafted Key
			end
		end
	else
		e.self:Say(eq.ChooseRandom("I didn't know Slime could speak common.  Go back to the sewer before I lose my temper.","Is that your BREATH, or did something die in here?  Now go away!","I wonder how much I could get for the tongue of a blithering fool?  Leave before I decide to find out for myself.","Oh look..a talking lump of refuse..how novel!"));
	end
end

function event_trade(e)
	local item_lib = require("items");
    item_lib.return_items(e.self, e.other, e.trade)
end
