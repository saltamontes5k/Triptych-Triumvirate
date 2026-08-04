local war_started = false

function event_spawn(e)
	if tostring(eq.get_zone_instance_version()) ~= eq.get_rule("Custom:StaticInstanceVersion") then -- Only spawn Badain in non-respawning dz
		e.self:Depop();
	end
	war_started = false
end

function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("Hail, outlander. Unless ye have orders from the Dain, leave me be. I must man my post.");
	end
end

function event_trade(e)
	local item_lib = require("items");

	if not war_started and item_lib.check_turn_in(e.trade, {item1 = 30369, item2= 1567}) then -- 9th ring and declaration of war
		e.other:SummonItem(30369);
		e.self:Say(string.format("I'll be right with you, %s.",e.other:GetCleanName()));
		e.self:AddItem(30645, 0, true);
		e.self:DoAnim(41);
		e.self:Emote("breathes deeply and blows into an ornate horn.");
		eq.set_timer("smallPause", 2500);
		war_started = true
	end
	item_lib.return_items(e.self, e.other, e.trade);
end

function event_timer(e)
	if e.timer == "smallPause" then
		eq.stop_timer("smallPause")
		eq.zone_emote(1, 'The sound of a mighty horn echoes through the area. All local inhabitants scurry to take cover.');
		eq.load_encounter("RingTen");
	end
end
