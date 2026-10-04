-- Temple_Warden_Halgrim (490100) -- Brell's Rest war camp.
-- Requests the three Brell's Temple raids (Rasper: miscRaidProg.html):
--   * Trial of Deconstruction (v1): one Emblem of Brell (consumed).
--   * Trial of Creation (v2): one Emblem + the Deconstruction flag.
--   * An Audience with Brell Serilis (v3): both trial flags +
--     one Amulet of Brell (consumed).
local prog = require("uf_progression")

local KEY_EMBLEM = prog.ITEM.emblem
local KEY_AMULET = prog.ITEM.amulet

local decon_dz = prog.dz("Trial of Deconstruction", "brellstemple", 1,
	{ 125.75, 589.75, 20.0 })
local creation_dz = prog.dz("Trial of Creation", "brellstemple", 2,
	{ 125.75, 589.75, 20.0 })
local audience_dz = prog.dz("An Audience with Brell Serilis", "brellstemple", 3,
	{ 125.75, 589.75, 20.0 })

function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("Hail, " .. e.other:GetCleanName() .. ". The temple of "
			.. "Brell holds two [trials] and, for those the trials approve, "
			.. "an [audience] with the King Under the World himself.")
	elseif e.message:findi("deconstruction") or e.message:findi("trial") then
		e.self:Say("The Trial of [Deconstruction] unmakes what the temple "
			.. "builds; the Trial of [Creation] finishes what Brell left "
			.. "broken. Say which you are [ready] to bargain for.")
	elseif e.message:findi("creation") then
		if not prog.has_flag(e.other, prog.FLG.trial_decon) then
			e.self:Say("Creation is not offered to those who have not first "
				.. "unmade. Pass the [Deconstruction] trial.")
			return
		end
		e.self:Say("Hand me one [Emblem of Brell] and the Creation chamber "
			.. "opens to your raid.")
	elseif e.message:findi("audience") then
		if not prog.has_flag(e.other, prog.FLG.trial_decon)
			or not prog.has_flag(e.other, prog.FLG.trial_creation) then
			e.self:Say("No one stands before Brell Serilis without both "
				.. "trials behind them. The [Deconstruction] and "
				.. "[Creation] trials, then we speak.")
			return
		end
		e.self:Say("Both trials behind you -- rare. Hand me one [Amulet of "
			.. "Brell] and I will petition the temple to open its innermost "
			.. "hall. Mind your manners in there.")
	elseif e.message:findi("ready") or e.message:findi("enter") then
		prog.ready(e)
	end
end

function event_trade(e)
	local item_lib = require("items")
	-- Deconstruction
	if item_lib.check_turn_in(e.trade, { item1 = KEY_EMBLEM })
		and not prog.has_flag(e.other, prog.FLG.trial_decon) then
		prog.request_raid(e, decon_dz, 80, nil)
		return
	end
	-- Creation
	if item_lib.check_turn_in(e.trade, { item1 = KEY_EMBLEM })
		and prog.has_flag(e.other, prog.FLG.trial_decon) then
		prog.request_raid(e, creation_dz, 80, nil)
		return
	end
	-- Audience
	if item_lib.check_turn_in(e.trade, { item1 = KEY_AMULET }) then
		if not prog.has_flag(e.other, prog.FLG.trial_decon)
			or not prog.has_flag(e.other, prog.FLG.trial_creation) then
			e.other:SummonItem(KEY_AMULET)
			e.self:Say("The amulet is not enough. Both [trials] first.")
			return
		end
		prog.request_raid(e, audience_dz, 80, nil)
		return
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
