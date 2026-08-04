-- Skyshrine Velious Armor - Wizard
local quest_helper		= require('velious_quest_helper');
local SKYSHRINE_ARMOR	= quest_helper.SKYSHRINE_ARMOR;

local QUEST_TEXT = {
	hail	= "Greetings to you. I seek one who calls himself a [wizard]. What do you call yourself, manling?",
	wizard	= "Excellent. Are you sure enough of your skills to undertake my [tasks]? If not, get out of my sight!",
	tasks	= "I thought so. One should never back down from a challenge. Once you have completed them I will have a [cap], a [robe], [sleeves], [wristbands], [gloves], [leggings] and [boots].",
};

QUEST_TEXT = quest_helper.merge_tables(QUEST_TEXT, quest_helper.SKYSHRINE_SILK_TEXT);

local QUEST_ITEMS = {
    quest_helper:silk_helmet(SKYSHRINE_ARMOR.Silk_Turban,		31154),	-- Items: Icicle Circlet
    quest_helper:silk_chest(SKYSHRINE_ARMOR.Silk_Robe,			31155),	-- Items: Robe of Icicles
    quest_helper:silk_arms(SKYSHRINE_ARMOR.Silk_Sleeves,		31156),	-- Items: Icicle Sleeves
    quest_helper:silk_bracer(SKYSHRINE_ARMOR.Silk_Wristband,	31157),	-- Items: Icicle Bracelet
    quest_helper:silk_gloves(SKYSHRINE_ARMOR.Silk_Gloves,		31158),	-- Items: Icicle Gloves
    quest_helper:silk_legs(SKYSHRINE_ARMOR.Silk_Pantaloons,		31159),	-- Items: Icicle Pantaloons
    quest_helper:silk_boots(SKYSHRINE_ARMOR.Silk_Boots,			31160)	-- Items: Icicle Boots
};

function event_say(e)
	quest_helper.quest_text(e, QUEST_TEXT, 1);
end

function event_trade(e)
    quest_helper:quest_turn_in(e, 1, QUEST_ITEMS, quest_helper.skyshrine_armor_success);
end
