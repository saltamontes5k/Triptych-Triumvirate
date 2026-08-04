function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("Hello.  Be careful what you say to Iva.  She has been rather touchy lately.  She seems as if she is waiting for something to happen.  What. I know not.");
	end
end

function event_trade(e)
	local item_lib = require("items");
    item_lib.return_items(e.self, e.other, e.trade)
end
