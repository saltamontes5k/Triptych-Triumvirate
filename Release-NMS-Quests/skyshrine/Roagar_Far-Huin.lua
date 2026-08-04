-- Skyshrine Velious Armor - Berserker
local quest_helper		= require('velious_quest_helper');
local SKYSHRINE_ARMOR	= quest_helper.SKYSHRINE_ARMOR;

local QUEST_ITEMS={
	quest_helper:melee_helmet(SKYSHRINE_ARMOR.Chain_Coif,		55324),	-- Items: Coif of Fire's Fury
	quest_helper:melee_chest(SKYSHRINE_ARMOR.Chain_Tunic,		55325),	-- Items: Tunic of Fire's Fury
	quest_helper:melee_arms(SKYSHRINE_ARMOR.Chain_Sleeves,		55326),	-- Items: Sleeves of Fire's Fury
	quest_helper:melee_bracer(SKYSHRINE_ARMOR.Chain_Bracer,		55327),	-- Items: Bracer of Fire's Fury
	quest_helper:melee_gloves(SKYSHRINE_ARMOR.Chain_Gauntlets,	55328),	-- Items: Gauntlets of Fire's Fury
	quest_helper:melee_legs(SKYSHRINE_ARMOR.Chain_Leggings,		55329),	-- Items: Leggings of Fire's Fury
	quest_helper:melee_boots(SKYSHRINE_ARMOR.Chain_Boots,		55330)	-- Items: Boots of Fire's Fury
};

function event_say(e)
	if e.other:GetFaction(e.self) == 1 then -- Ally
		if e.message:findi("hail") then
			e.self:Say("I seek one who fights with rage in their eyes and fury in their arms, are you such a [Berserker]?");
		elseif e.message:findi("berserker") then
			e.self:Say("I will aid you with armor befitting one of your temperment. I have a  [helm], [tunic], [sleeves], [bracers], [gauntlets], [leggings], and [boots] for you.");
		elseif e.message:findi("helm") then
			e.self:Say("Your enemies shall shake with fear at the sight of the helm I shall forge. I only require you to obtain three Crushed Corals and an Unadorned Chain Helm.");
		elseif e.message:findi("tunic") then
			e.self:Say("I shall forge a tunic and infuse it with the rage of Dozekar the Cursed. You must bring me three Flawless Diamonds and an Unadorned Chain Tunic.");
		elseif e.message:findi("sleeves") then
			e.self:Say("Your fury shall be unmatched when wearing the sleeves I shall create. Provide me with three Flawed Emeralds and a pair of Unadorned Chain Vambraces.");
		elseif e.message:findi("bracers") then
			e.self:Say("To forge a mighty bracer, I will need three Crushed Flame Emeralds and an Unadorned Chain Bracer.");
		elseif e.message:findi("gauntlets") then
			e.self:Say("You shall crush the life from your enemies while wearing the gauntlets I can create from three Crushed Topazes and a pair of Unadorned Chain Gauntlets.");
		elseif e.message:findi("leggings") then
			e.self:Say("Fury and swiftness shall be your ally while wearing leggings of my forging. Bring me three Flawed Sea Sapphires and a pair of Unadorned Chain Leggings and they shall be yours.");
		elseif e.message:findi("boots") then
			e.self:Say("To better pursue those who flee before you, wear these boots. I will need three Crushed Black Marbles and a pair of Unadorned Chain Boots to complete them.");
		end
	else
		e.self:Say("You must prove your dedication to the Claws of Veeshan before I will speak to you.");
	end
end

function event_trade(e)
	quest_helper:quest_turn_in(e, 1, QUEST_ITEMS, quest_helper.skyshrine_armor_success);
end
