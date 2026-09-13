-- items: 17900, 17138, 2017138
local GM_TROPHIES = {
	{ keyword = "poison",        skill = 56, item = 2024071, name = "Grandmaster Assassin's Vial",    tradeskill = "Poison Making" },
	{ keyword = "tinkering",     skill = 57, item = 2009255, name = "Grandmaster Tinker's Spanner",   tradeskill = "Tinkering" },
	{ keyword = "alchemy",       skill = 59, item = 2065123, name = "Grandmaster's Medicine Bag",     tradeskill = "Alchemy" },
	{ keyword = "baking",        skill = 60, item = 2009251, name = "Grandmaster Baker's Spoon",      tradeskill = "Baking" },
	{ keyword = "tailoring",     skill = 61, item = 2009246, name = "Grandmaster Tailor's Needle",    tradeskill = "Tailoring" },
	{ keyword = "blacksmithing", skill = 63, item = 2009248, name = "Grandmaster Smith's Hammer",     tradeskill = "Blacksmithing" },
	{ keyword = "fletching",     skill = 64, item = 2009249, name = "Grandmaster Fletcher's Knife",   tradeskill = "Fletching" },
	{ keyword = "brewing",       skill = 65, item = 2009252, name = "Grandmaster Brewer's Corker",    tradeskill = "Brewing" },
	{ keyword = "jewelry",       skill = 68, item = 2009254, name = "Grandmaster Jeweler's Eyeglass", tradeskill = "Jewelry Making" },
	{ keyword = "pottery",       skill = 69, item = 2009253, name = "Grandmaster Potter's Sculpter",  tradeskill = "Pottery" },
};

local TOF_CURRENCY_ID = 6;
local TROPHY_PRICE = 200;
local TROPHY_SKILL_CAP = 300;

function event_say(e)
	if(e.message:findi("hail")) then
		e.self:Say("Hail! Nice to see ya, friend. I've got a fine selection of spankin' good spells, perhaps you'd be interested? I also deal in Grandmaster [trophies], if your craft is good enough. Or maybe you'd like to learn how to make the [bag] from your Grandmaster Trade items a little more permanent?");

	elseif(e.message:findi("bag")) then
		e.self:Say("Its a very sturdy bag, but I'm afraid that it's only temporary. If you'd like to get a more permanent bag, just hand me your summoned one and I'll trade it out you.");

	elseif(e.message:findi("trophies")) then
		e.self:Say("I keep a stock of Grandmaster trophy tools for the trades I respect. Max your tradeskill to " .. TROPHY_SKILL_CAP .. " and bring " .. TROPHY_PRICE .. " Triunes of Fate, then just say 'buy' and the trade name -- tailoring, blacksmithing, fletching, baking, brewing, jewelry, pottery, tinkering, poison, or alchemy.");

	elseif(e.message:findi("buy")) then
		local matched = nil;
		for _, trophy in ipairs(GM_TROPHIES) do
			if(e.message:findi(trophy.keyword)) then
				matched = trophy;
				break;
			end
		end

		if(matched == nil) then
			e.self:Say("I didn't catch which trade you meant. Try 'buy' followed by tailoring, blacksmithing, fletching, baking, brewing, jewelry, pottery, tinkering, poison, or alchemy.");
			return;
		end

		if(e.other:CountItem(matched.item) > 0) then
			e.self:Say("You've already got a " .. matched.name .. ". Sell that one first if you want another.");
			return;
		end

		if(e.other:GetSkill(matched.skill) < TROPHY_SKILL_CAP) then
			e.self:Say("Come back once your " .. matched.tradeskill .. " is maxed out. I only deal with the best.");
			return;
		end

		if(e.other:GetAlternateCurrencyValue(TOF_CURRENCY_ID) < TROPHY_PRICE) then
			e.self:Say("That'll be " .. TROPHY_PRICE .. " Triunes of Fate for the " .. matched.name .. ". Come back when you've got them.");
			return;
		end

		e.other:RemoveAlternateCurrencyValue(TOF_CURRENCY_ID, TROPHY_PRICE);
		e.other:SummonFixedItem(matched.item);
		e.self:Say("A fine choice. Here is your " .. matched.name .. ".");
	end
end

function event_trade(e)
	local item_lib = require("items");
	if(item_lib.check_turn_in(e.trade, {item1 = 17900})) then	--Grandmaster's Satchel
		e.self:Say("Here's a more permanent bag.");				--Text made up, no reference
		e.other:Ding();
		e.other:SummonFixedItem(2017138);						--Grandmaster's Carry-All (Legendary)
	end
	item_lib.return_items(e.self, e.other, e.trade)
end

-------------------------------------------------------------------------------------------------
-- Converted to .lua using MATLAB converter written by Stryd
-- Find/replace data for .pl --> .lua conversions provided by Speedz, Stryd, Sorvani and Robregen
-------------------------------------------------------------------------------------------------
