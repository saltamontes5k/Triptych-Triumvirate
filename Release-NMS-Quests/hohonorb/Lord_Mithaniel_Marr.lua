function event_item(e)
	local item_lib = require("items");
	if (item_lib.check_turn_in(e.trade, {item1 = 81554, item2 = 81547, item3 = 976017, item4 = 820655})) then 
		e.self:Say(string.format("%s! How dare you profane this place with such heinous artifacts!", e.other:GetCleanName()));
        e.self:Say("What... What is this... Who... I don't... My faithful... MY FRIENDS! HOW DARE HE!");
        e.self:Shout("CAZIC, HOW DARE YOU! THE LIGHT WILL CLEANSE YOU!");
        eq.world_emote(MT.Red, "FROGLOKS! GUKTAN! MY FAITHFUL FRIENDS! I REMEMBER. WE REMEMBER!");
        eq.world_emote(MT.Yellow, "Guktan characters may now be created by all players.");
        eq.world_wide_signal_client("froglok-unlock");
        eq.set_data("froglok-unlock", 1);
    end	
end
