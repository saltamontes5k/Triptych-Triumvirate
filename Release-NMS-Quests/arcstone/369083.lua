-- arcstone/369083.lua - Spirit of Ao the Fourth Born
-- Prophecy of Ro: offers the three Skylance arc tasks and refines the Tarnished Chime.
local por = require("por_helper");

local function offer_skylance(c, npc)
	if not c:IsTaskCompleted(por.tasks.skylance_library) and not c:IsTaskActive(por.tasks.skylance_library) then
		c:AssignTask(por.tasks.skylance_library);
		npc:Say("Seek the tower of Skylance and recover the Codex Artifice from its library.");
	elseif not c:IsTaskCompleted(por.tasks.skylance_oubliette) and not c:IsTaskActive(por.tasks.skylance_oubliette) then
		c:AssignTask(por.tasks.skylance_oubliette);
		npc:Say("Descend into the oubliette beneath Skylance and recover the Prototype Egg of Tallongast.");
	elseif not c:IsTaskCompleted(por.tasks.skylance_laboratory) and not c:IsTaskActive(por.tasks.skylance_laboratory) then
		c:AssignTask(por.tasks.skylance_laboratory);
		npc:Say("Take the egg to the laboratory and incubate it, then recover the chime within.");
	end
end

function event_say(e)
	local t = e.message:lower();
	if t:find("hail") then
		e.self:Say("Greetings, traveler. I am Ao, the Fourth Born of the [scrykin lineage].");
	elseif t:find("scrykin lineage") then
		e.self:Say("We scrykin mark the attempts of Druzzil Ro to create organic life from magic. We are living creatures, just like you, but we are each born with a terrible [flaw].");
	elseif t:find("flaw") then
		e.self:Say("We absorb ambient energy from the Plane of Magic. This makes us more powerful as we age, but also more hideous, more unpredictable, even more dangerous. All but the youngest of scrykin have become twisted monsters, creatures consumed by paranoia and delusion. I alone avoided this degeneration by abandoning my physical body and becoming a spirit. This was not an easy process, but it was the only way I could fulfill my promise to Druzzil. She has commanded me to help you and your [group] find the lost chime of Ayonae, the goddess of music.");
	elseif t:find("group") or t:find("help") or t:find("chime") then
		e.self:Say("Enter the tower of Skylance and do as my student Arkahn bids. Recover the [Codex Artifice] from the library, the [Prototype Egg] from the oubliette, and the chime from the laboratory.");
		offer_skylance(e.other, e.self);
	elseif t:find("codex") or t:find("prototype egg") then
		offer_skylance(e.other, e.self);
	elseif t:find("skylance") or t:find("enter the tower") or t:find("open the way") then
		if por.enter(e.other, "skylance", "Skylance", 1, 6, "6h") then
			e.self:Say("The way into Skylance is open. Seek Arkahn within, and recover what Ayonae lost.");
		end
	elseif t:find("reward") or t:find("spell") or t:find("knowledge") then
		if e.other:IsTaskCompleted(por.tasks.skylance_library)
			and e.other:IsTaskCompleted(por.tasks.skylance_oubliette)
			and e.other:IsTaskCompleted(por.tasks.skylance_laboratory) then
			if (tonumber(e.other:GetBucket("por.skylance_reward")) or 0) == 0 then
				if por.grant_rewards(e.other, "skylance") > 0 then
					e.other:SetBucket("por.skylance_reward", "1");
				end
			end
			e.self:Say("You have recovered all three relics. The knowledge of the Plane of Magic is yours to command. Use it wisely.");
		else
			e.self:Say("Return when the Codex, the Egg, and the Laboratory's secret are all in hand.");
		end
	end
end

function event_trade(e)
	local item_lib = require("items");
	local c = e.other;

	-- The Codex Artifice: completes "Skylance: The Library" (task 3010, activity 1)
	if c:IsTaskActive(por.tasks.skylance_library)
		and item_lib.check_turn_in(e.trade, { item1 = por.items.codex_artifice }) then
		e.self:Say("The Codex Artifice, taken from Arkahn's own library. The words of Druzzil Ro rest in your hands. You have done well.");
		c:UpdateTaskActivity(por.tasks.skylance_library, 1, 1);
		return;
	end

	-- The Prototype Egg of Tallongast: completes "Skylance: The Oubliette" (task 3011, activity 1)
	if c:IsTaskActive(por.tasks.skylance_oubliette)
		and item_lib.check_turn_in(e.trade, { item1 = por.items.prototype_egg }) then
		e.self:Say("The Prototype Egg of Tallongast. A life unmade, and now a secret recovered. Bring it to the laboratory next.");
		c:UpdateTaskActivity(por.tasks.skylance_oubliette, 1, 1);
		return;
	end

	-- Tarnished Chime -> Harmonic Chime
	if item_lib.check_turn_in(e.trade, { item1 = por.items.tarnished_chime }) then
		e.self:Emote("cleans the chime that you recovered from Tallongast the Prototype. 'There,' he says. 'This should be much more useful for you now.'");
		c:SummonFixedItem(por.items.harmonic_chime);
		return;
	end

	item_lib.return_items(e.self, e.other, e.trade);
end
