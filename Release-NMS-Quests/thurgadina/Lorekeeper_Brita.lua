-- Thurg Velious Armor - Enchanter
local quest_helper	= require('velious_quest_helper');
local THURG_ARMOR	= quest_helper.THURG_ARMOR;

local QUEST_TEXT = {
	hail		= "Greetings to you.  I seek those who call themselves [enchanters].  Are you an enchanter?",
	enchanter	= "I thought so.  I have several tasks for you accomplish.  Once you have completed them I will have a [cap], a [robe], [sleeves], [wristbands], [gloves], [leggings] and [boots] to reward you with.",
};

QUEST_TEXT = quest_helper.merge_tables(QUEST_TEXT, quest_helper.THURG_SILK_TEXT);

local QUEST_ITEMS = {
	quest_helper:silk_boots(THURG_ARMOR.Silk_Boots,			31083),	-- Items: Beguiler's Slippers
	quest_helper:silk_legs(THURG_ARMOR.Silk_Pantaloons,		31082),	-- Items: Beguiler's Trousers
	quest_helper:silk_gloves(THURG_ARMOR.Silk_Gloves,		31081),	-- Items: Beguiler's Gloves
	quest_helper:silk_bracer(THURG_ARMOR.Silk_Wristband,	31080),	-- Items: Beguiler's Wristguard
	quest_helper:silk_arms(THURG_ARMOR.Silk_Sleeves,		31079),	-- Items: Beguiler's Sleeves
	quest_helper:silk_chest(THURG_ARMOR.Silk_Robe,			31078),	-- Items: Beguiler's Robe
	quest_helper:silk_helmet(THURG_ARMOR.Silk_Turban,		31077)	-- Items: Beguiler's Crown
};

function event_say(e)
	quest_helper.quest_text(e, QUEST_TEXT, 3);
end

function event_trade(e)
	local item_lib = require('items');

	if item_lib.check_turn_in(e.trade, {item1 = 1427, item2 = 1417}) then -- Items: Ulthork Meat Pie, Brita's Napkin
		e.self:Say("Ohh, that's better. I get so touchy when I'm hungry. I should probably go apologize to Derrin for being snappy. Please return this to Mordin for me.");
		e.other:QuestReward(e.self,{exp = 150000});
		e.other:SummonItem(1424);	-- Item: Used Pie Tin
		e.other:Faction(406, 20);	-- Faction: Coldain
		e.other:Faction(405, 20);	-- Faction: Dain
		e.other:Faction(419, -60);	-- Faction: Kromrif
		e.other:Faction(448, -60);	-- Faction: Kromzek
	elseif item_lib.check_turn_in(e.trade, {item1 =  1427}) then -- Item: Ulthork Meat Pie
		e.self:Say("Ohh, that's better. I get so touchy when I'm hungry. I should probably go apologize to Derrin for being snappy.");
		e.other:QuestReward(e.self,{exp = 5000});
	end
	quest_helper:quest_turn_in(e, 3, QUEST_ITEMS, quest_helper.thurg_armor_success);
end
