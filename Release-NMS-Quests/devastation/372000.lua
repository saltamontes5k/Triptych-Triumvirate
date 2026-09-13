-- devastation/372000.lua - Oathmir the Outcast
-- Prophecy of Ro: assigns Samples of Corruption and twists the Silent Harmonic Chime.
local por = require("por_helper");

function event_say(e)
	local t = e.message:lower();
	if t:find("hail") then
		e.self:Say("Our people know some earth magic, and I might be able to work on this chime for you, but I must ask for your help first. I am lost, but I feel that I have a purpose here. It is difficult to explain to someone that has never been part of the cycle what it is like to be taken from it. I have lost all rage and have been left with emptiness. I no longer feel the desire to be with Her in the tower. I felt the rage leaving me slowly from the moment I was chosen as Vessel. She touched me then, instilling me with her rage, but it did not feel right to me. It was somehow tainted, impure. I could not accept it and the moment I rejected her rage all of my rage started to flow away from me. Something is very wrong with our goddess. Her rage is no longer pure, though it may be my own heart that is corrupt. Perhaps you can find out what has happened. Perhaps you can get into the tower and find out what has gone wrong.");
	elseif t:find("tell me about the chime") or t:find("chime") then
		e.self:Say("That chime is tuned to the Plane of Music, but its magic has been crushed. I can reshape it, but I must first know what has corrupted my goddess. Enter Sullon Zek's tower and bring me proof. Say that you [can find out] and I will send you.");
	elseif t:find("can find out") then
		if not e.other:HasItem(por.items.enraged_flesh_charm) then
			e.self:Say("You cannot enter the tower without the Enraged Flesh Charm. Grand Librarian Maelin in the Plane of Knowledge can prepare one, if you are worthy.");
			return;
		end
		if e.other:IsTaskCompleted(por.tasks.samples_of_corruption) then
			e.self:Say("You have already brought me the proof I needed. Give me the Silent Harmonic Chime and I will do what I can.");
		elseif not e.other:IsTaskActive(por.tasks.samples_of_corruption) then
			e.other:AssignTask(por.tasks.samples_of_corruption);
			e.other:SummonFixedItem(por.items.runed_silver_box);
			e.self:Say("Take this chest to store any clues you may find. Gather the corrupted blood within the tower, seal the box, and return to me should you [need another].");
		end
	elseif t:find("need another") then
		e.other:SummonFixedItem(por.items.runed_silver_box);
		e.self:Say("Here is another chest. Do not lose this one.");
	elseif t:find("enter the tower") or t:find("razorthorn") or t:find("i am ready") then
		if por.enter(e.other, "ragea", "Razorthorn, Tower of Sullon Zek", 1, 6, "6h") then
			e.self:Say("The tower opens before you. Find the proof of corruption within and bring it to me.");
		end
	elseif t:find("sullon") or t:find("raid") then
		if not e.other:HasItem(por.items.enraged_flesh_charm) then
			e.self:Say("You would need the Enraged Flesh Charm to walk the tower, and the rage of her greatest servants to draw her out.");
		elseif (tonumber(e.other:GetBucket("por.sullon_key")) or 0) == 0 then
			e.self:Say("Bring Grand Librarian Maelin three Legendary Berserker Bones. Only then will the goddess take notice of you.");
		else
			if por.enter(e.other, "ragea", "Sullon Zek, Mistress of Rage", 1, 54, "6h", "3d") then
				e.self:Say("The tower trembles. Sullon Zek comes. Prove your rage!");
			end
		end
	elseif t:find("hero") or t:find("challenge") then
		if e.other:IsTaskCompleted(por.tasks.heroes_challenge) then
			if not e.other:HasItem(85610) then
				e.other:SummonFixedItem(85610); -- Mark of Oroshar
			end
			e.self:Say("A worthy display. Take this mark of Oroshar, and wear it with pride.");
		else
			if por.enter(e.other, "ragea", "Hero's Challenge", 1, 24, "6h") then
				e.other:AssignTask(por.tasks.heroes_challenge);
				e.self:Say("Prove yourself, then. Best the heroes of the stronghold and return to me.");
			end
		end
	end
end

function event_trade(e)
	local item_lib = require("items");
	local c = e.other;

	-- Sealed Runed Silver Box: proof of the corruption, completes Samples of Corruption
	if item_lib.check_turn_in(e.trade, { item1 = por.items.sealed_runed_silver_box }) then
		c:UpdateTaskActivity(por.tasks.samples_of_corruption, 1, 1);
		e.self:Say("The corruption is divine in origin. . . This confirms my fears. Something has poisoned the rage of Sullon Zek herself.");
		return;
	end

	-- Silent Harmonic Chime: twisted once Samples of Corruption is done
	if item_lib.check_turn_in(e.trade, { item1 = por.items.silent_harmonic_chime }) then
		if c:IsTaskCompleted(por.tasks.samples_of_corruption) then
			e.self:Say("Yes, I think I understand. This is tuned to a place, but that place is not as I expected, much like my experience with Her. I think I can change this, make it more receptive to unexpected versions of the original place.");
			e.self:Emote("takes the pieces of the chime individually and rolls them between thumb and forefinger. Each time he does there is a loud and visible explosion and a creaking sound. These explosions are contained within the thick calluses of the giant's finger pads. Oathmir hums throughout, a deep sound like distant earthquakes.");
			e.self:Say("That might work for you, though I'm afraid I had to crush the magic that was there before to make the adjustment.");
			c:SummonFixedItem(por.items.twisted_chime_first);
		else
			e.self:Say("I cannot work the chime until I know what has gone wrong within the tower. Bring me proof of the corruption first.");
			c:SummonFixedItem(por.items.silent_harmonic_chime);
		end
		return;
	end

	item_lib.return_items(e.self, e.other, e.trade);
end
