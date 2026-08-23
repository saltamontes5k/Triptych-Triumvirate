function event_say(e)
	if e.message:findi("hail") then
		e.self:Emote(" glances at you and smiles, revealing slightly pointed teeth. He is an older dark elf, wrinkles creasing his face. 'Yes. What can Jerith do for you?'");
	elseif e.message:findi("Osaftars") then
		e.self:Say("Osaftars did you say? Jerith knows this name. Osaftars is a scourge of the seas. He takes what he wants and does what he wants. He is a captain of a ship. Yes, Jerith does believe the ship's name was the Stormwave. It can probably be found in the port town of [Dulak].");
	elseif e.message:findi("Dulak") then
		e.self:Say("Dulak is a pirate town on the island of Broken Skull Rock. A dangerous place. There is a ship that Jerith has taken to get there from the shores of the Stonebrunt Mountains.");
	end
end

function event_trade(e)
	local item_lib = require("items");
    item_lib.return_items(e.self, e.other, e.trade)
end