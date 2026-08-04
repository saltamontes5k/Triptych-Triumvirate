local entered = 0;

function event_spawn(e)
	local xloc = e.self:GetX();
	local yloc = e.self:GetY();
	eq.set_proximity(xloc - 10, xloc + 10, yloc - 10, yloc + 10);
end

function event_enter(e)
	if not entered then
		e.self:Say("Ah, you made it, "..e.other:GetName()..". I am most impressed.");
		entered = 1;
	end
end

-- There is a delay to most of his dialog.. for dramatics maybe however, only adding it to the final trigger functions to prevent spamming.
function event_say(e)
	local inktuta_noq_bonus_flag = tonumber(eq.get_data("inktuta_noq_bonus_flag-"..eq.get_zone_instance_id())) or 0
	local inktuta_bonus_loot = tonumber(eq.get_data("inktuta_bonus_loot-"..eq.get_zone_instance_id())) or 0
	
	if e.message:findi("hail") then
		e.self:Emote("raises a hand to indicate silence. 'Shhh. Do not speak. I already know why you have come, and rest assured, the sentinel you seek is nearby.'");
		e.self:Say("The only thing standing in your way is me, humble Noqufiel.' He bows deeply, scraping the floor, then continues. 'But I would like to know one thing. My question is this: do you [plan to kill me], or were you interested in garnering my assistance while [keeping me alive]? Or do you [truly understand]...? Which is it, exactly?'");
		elseif e.message:findi("truly understand") then
		e.self:Say("Well done! You continue to impress me, " .. e.other:GetCleanName() .. ". My companions are impressed as well. You see, I'm not the only vengeful spirit trapped in this decrepit temple. Have a look around.");
		e.self:Say("You stand among the deceased. Does this suprirse you? All of us - Kelekdrix, myself, the other trusik are dead. We have been dead for years. When it became apparent that we were doomed, in an act of purest mercy I slew my brother and sisters - every last one, before passing away of starvation myself. Many of my companions still walk these halls, unaware of their fate or unwilling to accept what occurred. Others were driven mad by the idea of it. These pitiful souls did not understand the strength that could be harnessed by embracing undeath.");
		if inktuta_noq_bonus_flag == 0 then
			local bonus_loot_value = tostring(inktuta_bonus_loot + 64);
			eq.set_data("inktuta_bonus_loot-"..eq.get_zone_instance_id(), bonus_loot_value,tostring(eq.seconds("6h")));
			eq.set_data("inktuta_noq_bonus_flag-"..eq.get_zone_instance_id(), "1",tostring(eq.seconds("6h")));
		end
		eq.signal(296052,1,5 * 1000);
	elseif e.message:findi("keeping me alive") then
		e.self:Emote("smirks. 'That's terribly kind of you, ".. e.other:GetName() ..". Were I still alive, such a benevolent gesture would bring a warm tear to my eye, but as you will soon realize, that is no longer the case.'")
		if inktuta_noq_bonus_flag == 0 then
			local bonus_loot_value = tostring(inktuta_bonus_loot + 32);
			eq.set_data("inktuta_bonus_loot-"..eq.get_zone_instance_id(), bonus_loot_value,tostring(eq.seconds("6h")));
			eq.set_data("inktuta_noq_bonus_flag-"..eq.get_zone_instance_id(), "1",tostring(eq.seconds("6h")));
		end
		eq.signal(296052,1,5 * 1000);
	elseif e.message:findi("plan to kill") then
		e.self:Say("You stand among the deceased. Does this surprise you? All of us - Kelekdrix, myself, the other trusik are dead. We have been dead for years. When it became apparent that we were doomed, in an act of purest mercy I slew my brother and sisters - every last one, before passing away of starvation myself. Many of my companions still walk these halls, unaware of their fate or unwilling to accept what occurred. Others were driven mad by the idea of it. These pitiful souls did not understand the strength that could be harnessed by embracing undeath.");
		if inktuta_noq_bonus_flag == 0 then
			local bonus_loot_value = tostring(inktuta_bonus_loot + 16);
			eq.set_data("inktuta_bonus_loot-"..eq.get_zone_instance_id(), bonus_loot_value,tostring(eq.seconds("6h")));
			eq.set_data("inktuta_noq_bonus_flag-"..eq.get_zone_instance_id(), "1",tostring(eq.seconds("6h")));
		end
		eq.signal(296052,1,5 * 1000);
	end
end

function event_signal(e)
	local x,y,z,h = e.self:GetX(), e.self:GetY(), e.self:GetZ(), e.self:GetHeading();

	e.self:Emote("clenches his fist, 'And the curse you've no doubt heard about. Do you yet understand?'");
	e.self:Say("I am the curse.");
	e.self:Emote("steps through the flames and vanishes.");
  eq.load_encounter("cc")
	eq.depop();
end
