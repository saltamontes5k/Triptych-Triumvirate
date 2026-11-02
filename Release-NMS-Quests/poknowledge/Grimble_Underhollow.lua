-- poknowledge/Grimble_Underhollow.lua
-- Frostefreeze: joke Frostfell ice cream expedition (frostcrypt version 220,
-- migration v294 / 20261031_frostefreeze.sql). Grimble is cheerful about his
-- five kids in a way that never quite adds up. No shroud: players go in as
-- themselves; under about 75 winters he suggests bringing friends.
-- Turn-ins: 20 of any ice cream (75005/75006/75007) -> the EXISTING glamour
-- 701463 ("Glamour - 'Ice Cream Cone'"); 10 Rock Candy (64352) -> bonus glamour.

local EXPEDITION_NAME = "The Frostefreeze Ice Cream Social"
local FLAVORS   = { [75005] = true, [75006] = true, [75007] = true }
local SCOOPS    = 20
local CANDY     = 64352
local CANDY_PCS = 10
local GLAMOUR   = 701463

local compass    = { zone = "frostcrypt", x = 0, y = -40, z = 2 }
local safereturn = { zone = "poknowledge", x = 497, y = -30, z = -90, h = 250 }
local zonein     = { x = 2, y = -30, z = 2, h = 0 }

local frostefreeze = {
	expedition = { name = EXPEDITION_NAME, min_players = 1, max_players = 6 },
	instance   = { zone = "frostcrypt", version = 220, duration = eq.seconds("2h") },
	compass    = compass,
	safereturn = safereturn,
	zonein     = zonein
}

local function on_frostefreeze_expedition(client)
	local dz = client:GetExpedition()
	return dz.valid and dz:GetName() == EXPEDITION_NAME
end

-- Counts scoops (or candy pieces) across the four trade slots. Stackable items
-- carry their count in charges; plain items are one apiece. item_data keeps
-- every handed slot so the engine hand-in can give non-matching items back.
local function count_trade(e, wanted)
	local counts, item_data, total = {}, {}, 0
	for x = 1, 4 do
		local inst = e.trade["item" .. x]
		if inst and inst.valid then
			local id = inst:GetID()
			if wanted[id] then
				local n = inst:GetCharges()
				if n < 1 then n = 1 end
				counts[id] = (counts[id] or 0) + n
				total = total + n
			end
			item_data[x] = inst
		end
	end
	return counts, item_data, total
end

-- Consumes exactly `needed` of what was handed in, split across whichever
-- flavors arrived, through the engine hand-in queue (NPC::CheckHandin is
-- count- and slot-agnostic). Anything extra goes back with return_items.
local function consume(e, counts, item_data, needed)
	local required = {}
	for id, n in pairs(counts) do
		local take = math.min(n, needed)
		required[id] = take
		needed = needed - take
		if needed == 0 then break end
	end
	if needed > 0 then return false end
	return e.trade.self:CheckHandin(e.trade.other, {}, required, item_data)
end

function event_say(e)
	if e.message:findi("hail") then
		e.self:Say(string.format(
			"Oh! Hello, %s. You look like someone with a healthy appetite. My five kids are simply DESPERATE for ice cream, and I have found the most perfect little spot for churning it. Ask me about the [ice cream].",
			e.other:GetCleanName()))
	elseif e.message:findi("ice cream") then
		if on_frostefreeze_expedition(e.other) then
			e.self:Say("Your social is already assembling! Say [" .. eq.say_link("ready") .. "] and in you go.")
			return
		end
		e.self:Say("The place used to be somebody's crypt, but the previous tenants have been very quiet about it lately. The giants out there practically churn the stuff themselves. Say [" .. eq.say_link("ready") .. "] and I'll show you in -- straight in as you are, no funny business. Bring back twenty scoops for the kids. Any flavor.")
		if e.other:GetLevel() < 75 then
			e.self:Say("Oh -- you've seen fewer than seventy-five winters, haven't you. Bring friends. The freezers bite.")
		end
	elseif e.message:findi("ready") then
		if on_frostefreeze_expedition(e.other) then
			e.other:MovePCDynamicZone(e.other:GetExpedition():GetZoneID())
			return
		end
		local dz = e.other:CreateExpedition(frostefreeze)
		if dz.valid then
			e.self:Say("In you go! The little ones will be so pleased. Everyone say [" .. eq.say_link("ready") .. "] to follow. Twenty scoops! They're counting!")
		end
	elseif e.message:findi("kids") then
		e.self:Say("Five of them. Sweet as anything. You have seen kids before, yes? Of course you have. Everyone has seen kids.")
	end
end

function event_trade(e)
	local item_lib = require("items")

	local counts, item_data, total = count_trade(e, FLAVORS)
	if total >= SCOOPS and consume(e, counts, item_data, SCOOPS) then
		e.self:Say("Twenty scoops! Oh, the children will sing of this day. Here -- a cone of your very own. It makes any weapon look delicious.")
		e.other:SummonItem(GLAMOUR, 1)
		item_lib.return_items(e.self, e.other, e.trade)
		return
	end

	local candy_counts, candy_data, candy_total = count_trade(e, { [CANDY] = true })
	if candy_total >= CANDY_PCS and consume(e, candy_counts, candy_data, CANDY_PCS) then
		e.self:Say("Rock candy! The kids crack it on the porch steps. Here, take another cone for the road.")
		e.other:SummonItem(GLAMOUR, 1)
		item_lib.return_items(e.self, e.other, e.trade)
		return
	end

	if total > 0 then
		e.self:Say("That's only " .. total .. " scoops, though. The kids counted twice. They always count twice.")
	elseif candy_total > 0 then
		e.self:Say("Ten pieces, sweet. The porch steps are patient.")
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
