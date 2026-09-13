--poknowledge/Grand_Librarian_Maelin.lua NPCID 202125
-- Plane of Power elemental flagging + epic hooks (pre-existing).
-- Prophecy of Ro: Quest Keeper for the Razorthorn access chain
--   "Saga Skins" (3000) -> "Preparing Your New Skins" (3001) -> "Become the Vessel" (3002)
--   handing in the five Enraged Flesh armor pieces, then saying "enraged flesh charm",
--   grants the Enraged Flesh Charm that opens Razorthorn, Tower of Sullon Zek.
local por = require("por_helper");

-- Is the traded set made up entirely of the given item id? (1..4 slots)
local function trade_all_of(e, item_id)
	local n = 0;
	for i = 1, 4 do
		local inst = e.trade["item" .. i];
		if inst and inst.valid then
			if inst:GetID() ~= item_id then
				return 0;
			end
			n = n + 1;
		end
	end
	return n;
end

-- Build a check_turn_in table for n copies of item_id (n clamped to 4).
local function n_of(item_id, n)
	if n > 4 then n = 4; end
	local t = {};
	for i = 1, n do
		t["item" .. i] = item_id;
	end
	return t;
end

local function por_trade(e, item_lib)
	local c = e.other;

	------------------------------------------------------------
	-- Sullon Zek raid key: the three Legendary Berserker Bones
	------------------------------------------------------------
	if item_lib.check_turn_in(e.trade, { item1 = 88102, item2 = 88103, item3 = 88104 }) then
		c:SetBucket("por.sullon_key", "1");
		e.self:Say("Three Legendary Berserker Bones! These will be enough to draw Sullon Zek's attention. Go to Oathmir the Outcast in the Devastation and tell him you are ready.");
		return true;
	end

	------------------------------------------------------------
	-- Become the Vessel: turning in the five armor pieces
	------------------------------------------------------------
	if c:IsTaskActive(por.tasks.become_the_vessel) then
		for _, armor_id in ipairs(por.armor) do
			if item_lib.check_turn_in(e.trade, {item1 = armor_id}) then
				local act = por.activity.vessel_armor[armor_id];
				if act then
					c:UpdateTaskActivity(por.tasks.become_the_vessel, act, 1);
				end
				e.self:Say("The rage-touched armor will make a fine vessel's charm. Hand me the rest and I will begin the work.");
				return true;
			end
		end
		-- Not an armor piece; fall through to other handling.
	end

	------------------------------------------------------------
	-- Preparing Your New Skins: materials + skin -> armor
	------------------------------------------------------------
	if c:IsTaskActive(por.tasks.preparing_your_new_skins) then
		if trade_all_of(e, por.items.bone_tattoo_comb) > 0 then
			item_lib.check_turn_in(e.trade, {item1 = por.items.bone_tattoo_comb});
			c:UpdateTaskActivity(por.tasks.preparing_your_new_skins, por.activity.prep_comb, 1);
			e.self:Say("A fine comb! Now bring me five vials of Warrior's Blood and five handfuls of Battleground Soot.");
			return true;
		end

		local blood = trade_all_of(e, por.items.warriors_blood);
		if blood > 0 then
			item_lib.check_turn_in(e.trade, n_of(por.items.warriors_blood, blood));
			c:UpdateTaskActivity(por.tasks.preparing_your_new_skins, por.activity.prep_blood, blood);
			e.self:Say("Good. I still need Warrior's Blood and Battleground Soot.");
			return true;
		end

		local soot = trade_all_of(e, por.items.battleground_soot);
		if soot > 0 then
			item_lib.check_turn_in(e.trade, n_of(por.items.battleground_soot, soot));
			c:UpdateTaskActivity(por.tasks.preparing_your_new_skins, por.activity.prep_soot, soot);
			e.self:Say("Good. I still need Warrior's Blood and Battleground Soot.");
			return true;
		end

		for skin_id, armor_id in pairs(por.skin_to_armor) do
			if item_lib.check_turn_in(e.trade, {item1 = skin_id}) then
				c:SummonFixedItem(armor_id);
				local act = por.prep_skin_activity[skin_id];
				if act then
					c:UpdateTaskActivity(por.tasks.preparing_your_new_skins, act, 1);
				end
				e.self:Say("There, a piece of enraged flesh armor. Wear all five and you may pass for one of the Rage-born.");
				return true;
			end
		end
		return false;
	end

	------------------------------------------------------------
	-- Saga Skins: skin -> translation, translations -> book, book -> reward
	------------------------------------------------------------
	if item_lib.check_turn_in(e.trade, {item1 = por.items.saga_skin_translations_vol1, item2 = por.items.saga_skin_translations_vol2}) then
		if (tonumber(c:GetBucket("por.rage_reward")) or 0) == 0 then
			local granted = por.grant_rewards(c, "rage");
			if granted > 0 then
				c:SetBucket("por.rage_reward", "1");
			end
		end
		if not c:IsTaskActive(por.tasks.preparing_your_new_skins) and not c:IsTaskCompleted(por.tasks.preparing_your_new_skins) then
			c:AssignTask(por.tasks.preparing_your_new_skins);
		end
		c:UpdateTaskActivity(por.tasks.saga_skins, por.activity.saga_vol1, 1);
		c:UpdateTaskActivity(por.tasks.saga_skins, por.activity.saga_vol2, 1);
		e.self:Say("Well, these are very interesting! I have learned a great deal, and I have something for you as well. Bring me a Bone Tattoo Comb, five vials of Warrior's Blood, and five handfuls of Battleground Soot, and I will prepare your new skins.");
		return true;
	end

	if c:IsTaskActive(por.tasks.saga_skins) then
		-- skin -> translation (skin is handed back alongside the translation)
		for skin_id, translation_id in pairs(por.skin_to_translation) do
			if item_lib.check_turn_in(e.trade, {item1 = skin_id}) then
				c:SummonFixedItem(skin_id);
				c:SummonFixedItem(translation_id);
				e.self:Say("Fascinating. I have written down what the patterns say. Keep both the skin and my notes.");
				return true;
			end
		end

		-- translations -> bound book
		local tc = {};
		local idx = 1;
		local is_translation = {};
		for _, id in ipairs(por.translations) do is_translation[id] = true; end
		for i = 1, 4 do
			local inst = e.trade["item" .. i];
			if inst and inst.valid and is_translation[inst:GetID()] then
				tc["item" .. idx] = inst:GetID();
				idx = idx + 1;
			end
		end
		if idx > 1 and item_lib.check_turn_in(e.trade, tc) then
			local have = tonumber(c:GetBucket("por.saga_translations")) or 0;
			have = math.min(9, have + (idx - 1));
			c:SetBucket("por.saga_translations", tostring(have));
			e.self:Say(string.format("Translation received. I now hold %d of the nine passages.", have));
			if have >= 9 and not c:HasItem(por.items.saga_skin_translations_vol1) then
				c:SummonFixedItem(por.items.saga_skin_translations_vol1);
				c:SummonFixedItem(por.items.saga_skin_translations_vol2);
				e.self:Say("By the gods, it is a complete saga! I have bound the nine passages into two volumes. Hand them back to me and I will show you the rite of the Vessel.");
			end
			return true;
		end
	end

	return false;
end

function event_say(e)
	local text = e.message:lower();
	local on_saga   = e.other:IsTaskActive(por.tasks.saga_skins) or e.other:IsTaskCompleted(por.tasks.saga_skins);
	local on_prep   = e.other:IsTaskActive(por.tasks.preparing_your_new_skins) or e.other:IsTaskCompleted(por.tasks.preparing_your_new_skins);
	local on_vessel = e.other:IsTaskActive(por.tasks.become_the_vessel) or e.other:IsTaskCompleted(por.tasks.become_the_vessel);

	if text:find("saga skin") then
		if not (e.other:IsTaskActive(por.tasks.saga_skins) or e.other:IsTaskCompleted(por.tasks.saga_skins)) then
			e.other:AssignTask(por.tasks.saga_skins);
		end
		e.self:Say("The warriors of the Plane of Rage wear their history on their hides. Bring me any of those strangely patterned skins and I will translate the markings for you.");
		return;
	elseif text:find("become the vessel") then
		if e.other:IsTaskCompleted(por.tasks.preparing_your_new_skins) and not e.other:IsTaskCompleted(por.tasks.become_the_vessel) then
			if not e.other:IsTaskActive(por.tasks.become_the_vessel) then
				e.other:AssignTask(por.tasks.become_the_vessel);
			end
			e.self:Say("Wear the enraged flesh armor and sit before the door of Sullon Zek's tower. Let the rage fill you, vent it upon the stronghold, then return to the tower to receive her judgment.");
			return;
		elseif not e.other:IsTaskCompleted(por.tasks.preparing_your_new_skins) then
			e.self:Say("You are not yet prepared to become the Vessel. Bring me the materials for your armor first.");
			return;
		end
	elseif text:find("enraged flesh charm") then
		if e.other:IsTaskCompleted(por.tasks.become_the_vessel) then
			if not e.other:HasItem(por.items.enraged_flesh_charm) then
				e.other:SummonFixedItem(por.items.enraged_flesh_charm);
				e.self:Say("Ah, yes. Here is the charm I promised you. May it grant you passage into the tower of Sullon Zek.");
			else
				e.self:Say("You already carry the Enraged Flesh Charm.");
			end
		end
		return;
	elseif text:find("hail") and (on_saga or on_prep or on_vessel) then
		e.self:Say("Ah, you again. Have you more saga skins for me, or are you ready to [become the vessel]?");
		return;
	end

	local qglobals = eq.get_qglobals(e.other);
	if eq.is_task_active(500220) then
		if e.message:findi("trick or treat") then
			e.self:Say("Ah, here you go. Fresh from the Sugar Assembalage 2000.");
			e.other:SummonItem(eq.ChooseRandom(84091 ,84092, 84093, 84087, 84087, 84087, 84087, 84087, 84087));
			eq.update_task_activity(500220, 1, 1);
		end
	end

	if e.other:HasItem(29165) then --Quintessence of Elements
		if e.message:findi("Hail") then
			e.self:Say("The Quintessence! Oh my this is amazing! I have come into contact with Chronographer Muon in the realm of innovation. Go to him, show him you have the power to activate machine. I shall meet you there, this I must see!");
		end
	else
		local flags = {
			["pop.flags.aerin"] = 1,
			["pop.flags.adler"] = 1,
			["pop.flags.agnarr"] = 1,
			["pop.flags.askr"] = 4,
			["pop.flags.bertox"] = 1,
			["pop.flags.codecay"] = 2,
			["pop.flags.construct"] = 1,
			["pop.flags.elder"] = 1,
			["pop.flags.faye"] = 1,
			["pop.flags.garn"] = 1,
			["pop.flags.grummus"] = 1,
			["pop.flags.hedge"] = 1,
			["pop.flags.marr"] = 1,
			["pop.flags.mavuin"] = 1,
			["pop.flags.poxbourne"] = 1,
			["pop.flags.saryrn"] = 2,
			["pop.flags.shadyglade"] = 1,
			["pop.flags.terris"] = 1,
			["pop.flags.tribunal"] = 1,
			["pop.flags.trell"] = 1,
			["pop.flags.valor"] = 1,
			["pop.flags.rallos"] = 1
		}

		local flags_missing = {}
		
		local all_requirements_met = true
		for flag, required_value in pairs(flags) do
			local current_bucket = tonumber(e.other:GetAccountBucket(flag)) or 0
			if current_bucket ~= required_value then
				flags_missing[flag] = {current_bucket, required_value}
				all_requirements_met = false
			end
		end
		if all_requirements_met then --Elemental Pre-Flagging
			if e.message:findi("hail") then
				local lore_link = eq.silent_say_link("lore")
				local information_link = eq.silent_say_link("information")
				e.self:Say(
					string.format(
						"Welcome back my friends. I assure you that I have been studying the Cipher of Druzzil very diligently. Did you happen to find any [%s] or [%s] that I could look at?",
						lore_link,
						information_link
					)
				);
			elseif e.message:findi("lore") then
				e.self:Say("A parchment of Rallos'? Let me read it, it says that Rallos was not alone in his feelings about mortals. Solusek Ro also holds stake in the war to be led on Norrath. Not only this but he is channeling power from his father's plane into his own. He is taking that power and intensifying it through an artifact of great power, and then focusing it onto one point. It is a detailed as a crystal that burns with all the powers of the plane of fire. It is said to have the ability to turn the face of Norrath into a charred wasteland. They plan for a manaetic behemoth to carry and deposit it upon Norrath. You must stop these plans, you must stop Solusek!");
			elseif e.message:findi("information") then
				e.self:Say("There is no way to escape from the prison that is The Plane of Time. I am sorry but your quest for information ends here. Time is something that none of us can escape. That is however.. back when my explorations of the Planes were more common, I would travel searching for knowledge and lore to bring back to Tanaan. I stumbled into the Plane of Innovation. It was a great marvel to see indeed. I found the creator of all things mechanical. Meldrath the Marvelous was a kind and just gnome. We spent many weeks together discussing all of his devices. This included a machine that would allow you to open a tear into a period of time and enter into that time. The machine was more of a flight of whimsy though as the power necessary to power such a machine was enormous. He jokingly equated needing the very essence of the elements to power it.");
				e.self:Emote("Maelin takes a deep breath and continues");
				e.self:Say("I can see now that he was not joking at all. Let us suppose that you travelers could venture into the Elemental Planes and retrieve this essence; and form it into one powerful conglomeration. You could open a tear into the period of time before Zebuxoruk was imprisoned. There is no way you can free him from his stasis now, but if you were to halt the Pantheon at the time of imprisonment. Hah! It could work I do believe. Forgive me, but my old gnomish heart is alive with the excitement of possibilities. Gather up your strength friends, travel into the deep elements. You will need all of your wits about you. Find the very essence of the elementals, and fuse them into one. How to combine them I do not know, and can only wish you luck on finding that information. If you can accomplish this please come get me. I would like to record the events as they take place!");
				e.other:SetAccountBucket("pop.flags.librarian", "1");
				e.other:Message(MT.LightBlue, "You receive a character flag!");
			end
		else
			e.self:Say("You lack the necessary requirements for me to speak with you.")
			e.other:Message(MT.Yellow, "Your missing flags are as follows:")
			for flag, _ in pairs(flags_missing) do
				local flag_name = string.gsub(flag, "pop.flags.", "")
				local current_value = flags_missing[flag][1]
				local required_value = flags_missing[flag][2]
				e.other:Message(
					MT.Yellow,
					string.format(
						"Flag: %s Current: %d Required: %d",
						flag_name,
						current_value,
						required_value
					)
				)
			end
		end
	end

	if e.message:findi("tome") then
		if qglobals["shadowknight_epic"] == "1" then
			e.self:Say("Yes, I seem to recall having such a tome. But evil it is. I don't hand out such dangerous knowledge to just anyone. However. . . I am curious about something and perhaps you can help me. A prominent professor of biology and I have a bet as to how a certain creature from the Realm of Discord, known as a murkglider breeds. He believes they give live birth, and I believe they are egg layers. Unfortunately, I have been so busy here, that I have not been able to make arrangements to travel there and observe the creatures more. If you could travel to the Realm of Discord and [" ..eq.say_link('find an egg', false, 'find an egg') .. "] for me, I will give you the book you seek.");
		elseif e.message:findi("find an egg") then
			e.self:Say("I appreciate your help with this! The creature I was supposed to study are most commonly known as murkgliders. The easiest way to describe them is that they look like large, floating octopuses. See if you can hunt down any breeding murkgliders and return an egg to me that I can study. You might want to bring some companions along, as this might be a dangerous task.");
		end
	elseif e.message:findi("Jeb Lumsed sent me") then
		if (qglobals["ench_epic"] == "2") then
			e.self:Say("This is from Jeb, you say? I will set my best researchers on it at once. We have recently made some discoveries that he should be aware of. Here, take this note down to Lobaen, she will retrieve them for you.");
			e.other:SummonItem(52950); --Note to Lobaen
		end
	end
end

function event_trade(e)
	local item_lib = require("items");

	if por_trade(e, item_lib) then
		return;
	end

	local qglobals = eq.get_qglobals(e.other);
	if qglobals["shadowknight_epic"] == "1" and item_lib.check_turn_in(e.trade, {item1 = 55900}) then --hand in Gelatinous Murkglider Egg (Drops from Murkglider Breeder in Ruined City of Dranik)
		e.self:Say("I knew they were egg-layers! Ha, this is one gnome who hates losing a bet and thanks to you I wont! This is the tome you seek. Please bring it back to me when you are done.");
		e.other:SummonItem(20520); --The Silent Gods
	end
	item_lib.return_items(e.self, e.other, e.trade);
end
