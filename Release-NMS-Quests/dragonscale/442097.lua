-- Gimblefixx (442097) -- Secrets of Faydwer progression, stage 1.
-- "The Search for the Ultimate Story" -> leads to King Ak`Anon and the
-- Clockwork Key chain. Deliver activities (task 301000, activities 0-2)
-- are engine-driven; this script hands out the Clockwork Key once they
-- are done and handles the story beats of the hail chain.
local prog = require("sof_progression")

local function tasks_available(e)
	return not e.other:IsTaskCompleted(prog.TASK_SEARCH)
end

function event_say(e)
	if e.message:findi("hail") then
		-- chain beats: seal shown after the king (activity 5), etc.
		if prog.activity_done(e.other, prog.TASK_SEARCH, 4)
			and not prog.activity_done(e.other, prog.TASK_SEARCH, 5) then
			e.self:Say("You carry the seal of our King! Show Gurtrude the "
				.. "Spymaster in Fortress Mechanotus -- tell her I sent you. "
				.. "The Warmarshal can take you to her camp.")
		elseif e.other:IsTaskActive(prog.TASK_SEARCH)
			and prog.activity_done(e.other, prog.TASK_SEARCH, 2)
			and not prog.activity_done(e.other, prog.TASK_SEARCH, 3) then
			e.self:Say("You found all three silver parts! Here is the "
				.. "[Clockwork Key] I mentioned. Take it to King Ak`Anon -- "
				.. "he is held on the east side, behind the great door.")
		elseif tasks_available(e) then
			e.self:Say("Hail, " .. e.other:GetCleanName() .. ". Meldrath's "
				.. "Majestic Mansion is sealed tight, but an old story "
				.. "suggests the way in. It's a [deal] if you help me prove it.")
		else
			e.self:Say("Hail, " .. e.other:GetCleanName() .. ". The mansion "
				.. "doors know your key now. There is nothing more I need.")
		end
	elseif e.message:findi("deal") or e.message:findi("story")
		or e.message:findi("task") then
		if tasks_available(e) then
			e.self:Say("The minotaurs of Dragonspire carry silver clockwork "
				.. "parts older than their horns. Bring me a crank handle, a "
				.. "silverthread sack and a small clockwork device, and I "
				.. "will show you the [way into the mansion].")
			eq.task_selector({ prog.TASK_SEARCH })
		else
			e.self:Say("You have done your part, friend.")
		end
	elseif e.message:findi("way into the mansion")
		or e.message:findi("clockwork key") then
		e.self:Say("The parts open an old workbench of mine. From it I can "
			.. "cut a key. The King's chamber door is east of here; the "
			.. "Mansion itself demands a key with [movable teeth], cut by "
			.. "Gurtrude's own hand.")
	elseif e.message:findi("movable teeth") then
		e.self:Say("Eight teeth, each sliding between eight positions. Click "
			.. "the Mansion door and count what is aligned, adjust one tooth "
			.. "at a time on the key, and wait a breath between teeth. Only "
			.. "Gurtrude cuts such keys.")
	end
end

function event_trade(e)
	local item_lib = require("items")
	-- hand the Clockwork Key (36444) once the three delivers are in
	if e.other:IsTaskActive(prog.TASK_SEARCH)
		and prog.activity_done(e.other, prog.TASK_SEARCH, 0)
		and prog.activity_done(e.other, prog.TASK_SEARCH, 1)
		and prog.activity_done(e.other, prog.TASK_SEARCH, 2)
		and not prog.activity_done(e.other, prog.TASK_SEARCH, 3)
		and not prog.has_flag(e.other, prog.FLG.key_akanon) then
		e.other:SummonItem(prog.ITEM.key_mechanotus)
		prog.set(e.other, prog.FLG.key_akanon, 1)
		e.self:Say("There -- your [Clockwork Key]. The King waits behind the "
			.. "east door. Tell him Gimblefixx still keeps the faith.")
		return
	end
	item_lib.return_items(e.self, e.other, e.trade)
end

function event_task_complete(e)
	if e.task_id == prog.TASK_SEARCH then
		e.other:Message(15, "Gimblefixx's story is proven. The Mansion "
			.. "awaits its key.")
	end
end
