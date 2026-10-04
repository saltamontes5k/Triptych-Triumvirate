-- Dulia Jestes -- local-summon pets for bards and enchanters.
-- One global script serves both spawns (freportw 9061 / freeportwest 383172) because the
-- global quest lookup matches on NPC name (zone/quest_parser_collection.cpp).
--
-- Rung 1: hand in the three epic 1.0 weapons -> both initial scrolls.
-- Rung 2: locked behind rung 1, hand in a Globe of Discordant Energy -> both advanced scrolls.
--
-- Deliberately class-agnostic. Dulia consumes the relics and hands over the scrolls; figuring
-- out which one you can actually scribe is the player's problem.

local items = require("items")

local EPICS = { item1 = 28034, item2 = 20542, item3 = 10650 } -- Orb of Mastery, Singing Short Sword, Staff of the Serpent
local GLOBE = { item1 = 47100 }                               -- Globe of Discordant Energy

local BUCKET_INITIAL  = "dulia.localpets.initial"
local BUCKET_ADVANCED = "dulia.localpets.advanced"

local SCROLL_GROUPIE_INITIAL = 990230 -- Song: Summon Groupie
local SCROLL_LOCAL_INITIAL   = 990231 -- Spell: Summon Friendly Local
local SCROLL_GROUPIE_RK2     = 990232 -- Song: Summon Groupie Rk. II
local SCROLL_LOCAL_RK2       = 990233 -- Spell: Summon Friendly Local Rk. II

function event_say(e)
	if e.message:findi("hail") then
		e.self:Say(
			"Dulia looks you over with a collector's eye. 'You have the look of someone who " ..
			"knows how a creature can simply... appear. I have spent years chasing that trick. " ..
			"Show me the old proofs and I might share what I have learned.' " ..
			"Her fingers twitch as she adds, 'Bring me the relics of [the masters], " ..
			"and if you impress me, ask about the [globe].'"
		)
	elseif e.message:findi("masters") then
		e.self:Say(
			"'Three relics, all at once: an Orb of Mastery, a Singing Short Sword, " ..
			"and a Staff of the Serpent. Do not waste my time with imitations.'"
		)
	elseif e.message:findi("globe") then
		e.self:Say(
			"'A Globe of Discordant Energy, torn from the Citadel of Anguish. " ..
			"But not before you have shown me the relics. I will not skip steps.'"
		)
	end
end

function event_trade(e)
	local first_done    = e.other:GetBucket(BUCKET_INITIAL) == "1"
	local advanced_done = e.other:GetBucket(BUCKET_ADVANCED) == "1"

	if not first_done and items.check_turn_in(e.trade, EPICS) then
		e.other:SummonFixedItem(SCROLL_GROUPIE_INITIAL)
		e.other:SummonFixedItem(SCROLL_LOCAL_INITIAL)
		e.other:SetBucket(BUCKET_INITIAL, "1")
		e.self:Emote(
			"Dulia's breath catches as the three relics hit the table. She runs her hands " ..
			"over them, then presses two brittle scrolls into your palm. 'First rung. " ..
			"Come back with a Globe and I will show you the rest.'"
		)
	elseif first_done and not advanced_done and items.check_turn_in(e.trade, GLOBE) then
		e.other:SummonFixedItem(SCROLL_GROUPIE_RK2)
		e.other:SummonFixedItem(SCROLL_LOCAL_RK2)
		e.other:SetBucket(BUCKET_ADVANCED, "1")
		e.self:Emote(
			"Dulia cradles the Globe, whispering to the discord trapped inside. The air " ..
			"shivers and two sharper scrolls appear in her open hand. 'There. No zone can " ..
			"hide a friend from you now.'"
		)
	end

	items.return_items(e.self, e.other, e.trade)
end
