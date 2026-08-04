-- Thurg Velious Armor - Berserker
local quest_helper	= require('velious_quest_helper');
local THURG_ARMOR	= quest_helper.THURG_ARMOR;

local QUEST_TEXT = {
	hail	= "Well met, -race! I am Glatigi. If ye seek ta join our ranks, I welcome ye with open arms and have an offer to make if you are interested. If ye seek to be our enemy, I hope ye can run swifter than my archers arrows. My elite Berserkers are in sore need of some enchanted armor. Unfortunately, I can’t spare the men to go out and fetch me the components. If you can do this for me, I’ll gladly reward you with a piece of it. I need materials for a [coif], a [tunic], [sleeves], [bracers], [gauntlets], [leggings], and [boots].",
};

QUEST_TEXT = quest_helper.merge_tables(QUEST_TEXT, quest_helper.THURG_CHAIN_TEXT);

local QUEST_ITEMS = {
	quest_helper:melee_boots(THURG_ARMOR.Chain_Boots,		55323),	-- Items: Icefury Boots
	quest_helper:melee_legs(THURG_ARMOR.Chain_Leggings,		55322),	-- Items: Icefury Greaves
	quest_helper:melee_gloves(THURG_ARMOR.Chain_Gauntlets,	55321),	-- Items: Icefury Gauntlets
	quest_helper:melee_bracer(THURG_ARMOR.Chain_Bracer,		55320),	-- Items: Icefury Bracer
	quest_helper:melee_arms(THURG_ARMOR.Chain_Sleeves,		55319),	-- Items: Icefury Sleeves
	quest_helper:melee_chest(THURG_ARMOR.Chain_Tunic,		55318),	-- Items: Icefury Tunic
	quest_helper:melee_helmet(THURG_ARMOR.Chain_Coif,		55317)	-- Items: Icefury Coif
};

function event_say(e)
	quest_helper.quest_text(e, QUEST_TEXT, 3);
end

function event_trade(e)
	quest_helper:quest_turn_in(e, 3, QUEST_ITEMS, quest_helper.thurg_armor_success);
end
