-- Lebounde ab Dolmen [Artisan] -- Halas
-- Recreation of Live quest "The Artisan's Prize" (Allakhazam quest 8120).
--
-- 1) Hand in all 12 Artisan's Seals, one per tradeskill. The trade window only
--    holds four items, so seals accumulate across trades (bucket-tracked).
--    The seals are also stocked on his merchant list; on Live they were
--    commonly bought in the Bazaar.
-- 2) Combine Earring of the Solstice (28771) + Signet of the Arcane (16257) or
--    Signet of Might (16255) + Eron's Jewelry (36550 mana / 36557 defense) in
--    the Transmutation Case (9020013) -> Expensive Mistake (9020014).
--    The combine cannot fail (nofail recipe).
-- 3) Hand in the Expensive Mistake -> Artisan's Prize (9020015).
--    The first completer on the server triggers a Halas proclamation.

local SEAL_IDS = {
	9020001, -- Alchemy
	9020002, -- Baking
	9020003, -- Brewing
	9020004, -- Fishing
	9020005, -- Fletching
	9020006, -- Jewelcrafting
	9020007, -- Poisoncrafting
	9020008, -- Pottery
	9020009, -- Research
	9020010, -- Smithing
	9020011, -- Tailoring
	9020012, -- Tinkering
}
local SEAL_NAMES = {
	"Alchemy", "Baking", "Brewing", "Fishing", "Fletching", "Jewelcrafting",
	"Poisoncrafting", "Pottery", "Research", "Smithing", "Tailoring", "Tinkering",
}
local CASE = 9020013     -- Item: Transmutation Case
local MISTAKE = 9020014  -- Item: Expensive Mistake
local PRIZE = 9020015    -- Item: Artisan's Prize
local BUCKET_PROGRESS = "artisan_prize_progress" -- 12-char bitstring of collected seals
local BUCKET_DONE = "artisan_prize"              -- set once the prize is claimed

local function say(e, text)
	e.other:Message(MT.NPCQuestSay, "Lebounde ab Dolmen says, '" .. text .. "'")
end

local function progress_bits(e)
	local bits = e.other:GetBucket(BUCKET_PROGRESS)
	if #bits ~= 12 then
		bits = "000000000000"
	end
	return bits
end

local function count_bits(bits)
	local n = 0
	for i = 1, 12 do
		if bits:sub(i, i) == "1" then
			n = n + 1
		end
	end
	return n
end

function event_say(e)
	if e.message:findi("hail") then
		say(e, "Ah, " .. e.other:GetCleanName() .. "! Good t' see yeh. Back fer more [work]?")
	elseif e.message:findi("work") then
		say(e, "If yeh can prove t' be a true craftsman then meh finest [prize] is yer's. Bring meh one [seal] from each o' the twelve trades - alchemy, baking, brewing, fishing, fletching, jewelcrafting, poisoncrafting, pottery, research, smithing, tailoring, and tinkering. I keep a few o' each in meh own stock fer those with deep pockets, if yeh'd rather not earn 'em.")
	elseif e.message:findi("seal") then
		say(e, "One seal per trade, and only the true master o' that trade need apply. All twelve, Lebounde's table, no fewer. Say [progress] and I'll tell yeh which ones yeh still owe meh.")
	elseif e.message:findi("progress") then
		local bits = progress_bits(e)
		local have, lack = {}, {}
		for i = 1, 12 do
			if bits:sub(i, i) == "1" then
				table.insert(have, SEAL_NAMES[i])
			else
				table.insert(lack, SEAL_NAMES[i])
			end
		end
		if #lack == 12 then
			say(e, "Yeh owe meh all twelve seals yet, " .. e.other:GetCleanName() .. ". Every trade: alchemy, baking, brewing, fishing, fletching, jewelcrafting, poisoncrafting, pottery, research, smithing, tailoring, tinkering.")
		elseif #lack == 0 then
			say(e, "All twelve seals are mine. Ask me about the [case] if yeh've gone and lost it.")
		else
			say(e, "Delivered: " .. table.concat(have, ", ") .. ". Still owed: " .. table.concat(lack, ", ") .. ".")
		end
	elseif e.message:findi("prize") then
		say(e, "Meh finest prize is an ear-worn trinket, melded from a Solstice Earring, Taldarius' Signet, and Eron's Jewelry. Gather all three and I'll lend yeh meh Transmutation [case]. Worn close t' the head, Artisan's Finesse keeps a steady hand on yer work and makes the good folk o' Halas right fond o' yeh.")
	elseif e.message:findi("case") then
		local bits = progress_bits(e)
		local done = e.other:GetBucket(BUCKET_DONE) ~= ""
		if done then
			say(e, "Yeh already wear meh finest work, crafter. Meh case has done its part.")
		elseif bits == "111111111111" then
			if e.other:CountItem(CASE) == 0 then
				e.other:SummonItem(CASE)
				say(e, "Lost meh case, did yeh? Careful now - that's rare Tanaan work. Meld yer Solstice Earring, yer Signet, and Eron's Jewelry within it, and bring meh whatever comes out.")
			else
				say(e, "Yeh still hold meh case. Meld yer Solstice Earring, Taldarius' Signet, and Eron's Jewelry within it, then bring meh the result.")
			end
		else
			say(e, "Meh case goes only t' those who've earned meh trust with all twelve [seals].")
		end
	end
end

function event_trade(e)
	local item_lib = require("items")
	local done = e.other:GetBucket(BUCKET_DONE) ~= ""

	-- Accept any not-yet-collected seals from this trade (four slots per trade,
	-- so the twelve seals accumulate across visits).
	if not done then
		local bits = progress_bits(e)
		local collected = count_bits(bits)
		local new_collected = false
		for i = 1, 12 do
			if bits:sub(i, i) == "0" then
				if item_lib.check_turn_in(e.trade, { item1 = SEAL_IDS[i] }) then
					bits = bits:sub(1, i - 1) .. "1" .. bits:sub(i + 1)
					collected = collected + 1
					new_collected = true
				end
			end
		end
		if new_collected then
			e.other:SetBucket(BUCKET_PROGRESS, bits)
			if collected >= 12 then
				if e.other:CountItem(CASE) == 0 then
					e.other:SummonItem(CASE)
				end
				say(e, "Every seal, and not a forgery among 'em! Yeh truly are a craftsman o' the highest order. Now listen close: take this Transmutation Case. If luck's on yer side and yeh got a steady hand, yeh should be able t' meld t'gether yer Solstice Earring, Taldarius' Signet, and Eron's Jewelry. Bring meh whatever comes out o' it.")
			else
				say(e, collected .. " o' twelve seals delivered. Keep 'em coming - say [progress] if yer losing count.")
			end
		end
	end

	-- The Expensive Mistake is proof of the meld -> Artisan's Prize
	if item_lib.check_turn_in(e.trade, { item1 = MISTAKE }) then
		local first = e.other:GetBucket(BUCKET_DONE) == ""
		e.other:SetBucket(BUCKET_DONE, "1")
		e.other:QuestReward(e.self, { itemid = PRIZE })
		say(e, "Ha! An Expensive Mistake, if e'er I saw one - but it's PROOF yeh melded the three t'gether with yer own hands. Here: meh finest prize, the Artisan's Prize. Wear it proud, crafter.")
		if first then
			eq.world_emote(15, "Heralds of Halas proclaim to all Norrath: " .. e.other:GetCleanName() .. " has proven a true craftsman before Lebounde ab Dolmen and claimed his finest work - the Artisan's Prize!")
		end
	end

	item_lib.return_items(e.self, e.other, e.trade)
end
