-- Hive_Watcher_Brindel (485210) -- Brell's Rest war camp.
--   * Arthicrex group mission 304002 (Venting the Hive).
--   * T6 keyed raids: "Cliknar Hive Guardians" (Arthicrex v1) and
--     "The Cliknar Queen" (Arthicrex v2; needs the Guardians flag).
--     Both consume one Coin of Brell. Rasper: miscRaidProg.html.
local prog = require("uf_progression")

local TASK = prog.TASK_HIVE
local KEY = prog.ITEM.coin

local guardians_dz = prog.dz("Cliknar Hive Guardians", "arthicrex", 1,
	{ 521.18, -1633.82, 200.0 })
local queen_dz = prog.dz("The Cliknar Queen", "arthicrex", 2,
	{ 521.18, -1633.82, 200.0 })

local function mission_gate(e)
	if not prog.task_done(e.other, TASK) then
		return false, "You know nothing of the hive's ways yet. Finish "
			.. "[Venting the Hive] before I send a raid into Arthicrex."
	end
	return true
end

function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("Hail, " .. e.other:GetCleanName() .. ". I watch the hive "
			.. "so the hive does not watch us. Ask me about a [task], the "
			.. "hive's [guardians], or the [queen] herself.")
	elseif e.message:findi("task") or e.message:findi("work") or e.message:findi("offer") then
		e.self:Say("This duty I can entrust to you, " .. e.other:GetCleanName() .. ".")
		eq.task_selector({ TASK })
	elseif e.message:findi("guardian") then
		local ok, why = mission_gate(e)
		if not ok then
			e.self:Say(why)
			return
		end
		e.self:Say("Four guardians ward the brood galleries. Hand me one "
			.. "[Coin of Brell] and I will open their hall.")
	elseif e.message:findi("queen") then
		if not prog.has_flag(e.other, prog.FLG.hive_guardians) then
			e.self:Say("The queen's chamber lies past her guardians. Break "
				.. "them first, then we will speak of her.")
			return
		end
		e.self:Say("So the guardians are broken. Hand me one [Coin of Brell] "
			.. "and the royal chamber opens. She will know you are coming -- "
			.. "she always knows.")
	elseif e.message:findi("raid") then
		e.self:Say("Say [guardians] or [queen] and be clear about which.")
	elseif e.message:findi("ready") or e.message:findi("enter") then
		prog.ready(e)
	end
end

function event_trade(e)
	local item_lib = require("items")
	if item_lib.check_turn_in(e.trade, { item1 = KEY }) then
		-- Queen coin takes priority when the player has earned it; the
		-- say-links above steer intent, so offer whichever the raider is
		-- flagged for (queen first -- it is the harder request).
		if prog.has_flag(e.other, prog.FLG.hive_guardians) then
			prog.request_raid(e, queen_dz, 80, nil)
			return
		end
		local ok, why = mission_gate(e)
		if not ok then
			e.other:SummonItem(KEY)
			e.self:Say(why)
			return
		end
		prog.request_raid(e, guardians_dz, 80, nil)
		return
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
