-- Shaman Cudgel Quest 4 & 5
function event_say(e)
	local Shaman_Cudgel_Progress	= e.other:GetBucket("Shaman_Cudgel")

	if e.message:findi("Hail") then
		e.self:Emote("shows the signs of a great mystic. You can feel the power resonating from his aura. 'Greetings and may the cursed blessings of Cazic-Thule be yours. What may I do for you this fine evening? Perhaps I can [cure disease] or [heal] you, perhaps even [purge toxins] from your system?");
	elseif e.message:findi("cure disease") then
		e.self:Say("Your malady shall dissipate once you deliver to me one giant blood sac.");
	elseif e.message:findi("heal") then
		e.self:Say("I can call upon the power of the ancients to mend your wounds if you can deliver to me two brittle Iksar skulls.");
	elseif e.message:findi("purge toxins") then
		e.self:Say("The toxins shall surely be purged from your system when I have proof of your allegiance to the empire. Let that proof be one goblin watcher signal torch.");
	elseif e.other:GetFaction(e.self) <= 4 then
		if Shaman_Cudgel_Progress == "3" and e.message:findi("rok nilok") then
			if e.other:GetLevel() >= 18 then
				e.self:Emote("lowers his head in sorrow. 'let us have a moment of peace. I cannot find the words to describe the unspeakable act of the gods which took the lives of the legendary Crusaders of Rok Nilok. You must find the answers for yourself. All I can do is await their return.'");
			else
				e.self:Say("Come back when you are more experienced and you can assist us.");
			end
		elseif e.message:findi("galdon vok nir?") then
			e.self:Say("He is a merchant hiding in The Overthere. He is greedy and will not give the skull up easily. Seek him out and ask him what he would [trade] for the skull.");
		end
	end
end

function event_trade(e)
	local item_lib					= require("items");
	local Shaman_Cudgel_Progress	= e.other:GetBucket("Shaman_Cudgel")

	if e.other:GetFaction(e.self) <= 4 then
		if Shaman_Cudgel_Progress == "3" and e.other:GetLevel() >= 18 and item_lib.check_turn_in(e.trade, {item1 = 12736, item2 = 5143}) then -- Items: Full C.O.R.N. Chest, Iron Cudgel of the Mystic
			e.self:Emote("'s voice booms loudly and does not sound the same as before. 'You have brought the skulls back to the empire. For this you shall be rewarded. You are now a prophet of the Temple of Terror. Go and find the Skulls of Di Nozok. I shall wait within Zand. Bring them along with your iron cudgel of the prophet.'");
			e.other:SetBucket("Shaman_Cudgel", "4");	-- Flag: Completed all of Cudgel Quest 4
			e.other:Message(MT.Yellow, "You have received a quest flag.");
			e.other:Faction(445, 10);					-- Faction: Scaled Mystics
			e.other:Faction(441, 10);					-- Faction: Legion of Cabilis
			e.other:SummonItem(5144);					-- Item: Iron Cudgel of the Prophet
			e.other:QuestReward(e.self,{exp = 100000});
		end
	end

	if item_lib.check_turn_in(e.trade, {item1 = 12671}) then -- Item: Giant Blood Sac
		e.self:Emote("grabs from his beltpouch a fine dust and cakes the slimy blood sac with it. He then punctures the sac and smears the blood upon your chest. Your chest tingles. Your fill your lungs and exhale a bitter mist.");
		e.self:CastSpell(213,e.other:GetID());	-- Spell: Cure Disease
		e.other:Faction(445, 1);				-- Faction: Scaled Mystics
		e.other:Faction(441, 1);				-- Faction: Legion of Cabilis
	elseif(item_lib.check_turn_in(e.trade, {item1 = 12739, item2 = 12739})) then -- Items: 2x Brittle Iksar Skull
		e.self:Emote("takes the skulls and holds them before your wounds. They shatter into a fine glowing powder and you feel your wounds being cauterized with no visible flame upon them.");
		e.self:CastSpell(17,e.other:GetID());	-- Spell: Light Healing
		e.other:Faction(445, 1);				-- Faction: Scaled Mystics
		e.other:Faction(441, 1);				-- Faction: Legion of Cabilis
	elseif(item_lib.check_turn_in(e.trade, {item1 = 12441})) then -- Item: Watcher Signal Torch
		e.self:Emote("chants in an unknown tongue as he takes a dagger and slits your forearm. He then takes a tiny glowing vein worm from his beltpouch and forces it into the open wound. You feel the worm explode within. The pain is unbearable, but then, a coolness courses through your body.");
		e.self:CastSpell(203,e.other:GetID());	-- Spell: Cure Poison
		e.other:Faction(445, 1);				-- Faction: Scaled Mystics
		e.other:Faction(441, 1);				-- Faction: Legion of Cabilis
	end
	item_lib.return_items(e.self, e.other, e.trade);
end
