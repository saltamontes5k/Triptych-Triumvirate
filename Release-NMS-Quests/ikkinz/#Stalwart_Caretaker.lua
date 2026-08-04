-- items: 60234
function event_say(e)
	eq.zone_emote(MT.White,"The stone worker does not move. It almost seems not to have any purpose at all, yet it blocks the door behind it.");
end

function event_trade(e)
	local item_lib = require("items");
	if(item_lib.check_turn_in(e.trade, {item1 = 60234})) then
		e.self:Emote("motions towards the door behind it. You have passed the first test.");
		eq.zone_emote(MT.White,"Only research can solve the mystery of the runed glyphs");
		eq.ZoneMarquee(10,510,1,1,6000,"Only research can solve the mystery of the runed glyphs");
		eq.zone_emote(MT.Yellow,"Stone grinds against stone and the door slides open");
		eq.get_entity_list():FindDoor(15):SetLockPick(0);
		eq.get_entity_list():FindDoor(16):SetLockPick(0);
		eq.get_entity_list():FindDoor(15):ForceOpen(e.self);
		eq.get_entity_list():FindDoor(16):ForceOpen(e.self);
	end
end

function event_say(e)
	if(e.message:findi("hail")) then
		e.self:Say("An adventurer... " .. e.other:GetName() .. ". Have you done your [research]?");
	elseif(e.message:findi("research")) then
		e.self:Say("Did it lead you to any clues on how to read the runed glyphs? Did you find the key? The [Runic Inscription]?");
	elseif(e.message:findi("runic inscription")) then
		e.self:Say("I know I've seen it before... but it's been a long time. Do you know [who has it]?");
	elseif(e.message:findi("who has it")) then
		e.self:Say("I caught a rogue trying to pick my non existent pockets... he seemed certain that [I have it].");
	elseif(e.message:findi("i have it")) then
		e.self:Say("You do?! Well in that case...");	
			e.self:Emote("motions towards the door behind it. You have passed the first test.");
			eq.zone_emote(MT.White,"Only time can solve the mystery of the runed glyphs");
			eq.ZoneMarquee(10,510,1,1,6000,"Only time can solve the mystery of the runed glyphs");
			eq.zone_emote(MT.Yellow,"Stone grinds against stone and the door slides open");
			eq.get_entity_list():FindDoor(15):SetLockPick(0);
			eq.get_entity_list():FindDoor(16):SetLockPick(0);
			eq.get_entity_list():FindDoor(15):ForceOpen(e.self);
			eq.get_entity_list():FindDoor(16):ForceOpen(e.self);
	end
end