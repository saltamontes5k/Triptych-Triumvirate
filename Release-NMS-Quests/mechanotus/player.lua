-- mechanotus/player.lua -- the Majestic Mansion entrance (doorid 300).
-- Faithful 8-tooth puzzle: clicking the door reports how many teeth of
-- the configurable Clockwork Key (36445) are aligned; the key is slid
-- one tooth per click (global/items/8838.lua) with a 6s tooth advance.
-- At 8/8 the key is keyringed and the door zones you into the Mansion.
local prog = require("sof_progression")

local MANSION_DOOR = 300

-- mansion static zone-in, main entry hall (TUNABLE)
local MANSION_IN = { x = 0, y = 430, z = 52, h = 0 }

function event_click_door(e)
	if e.door:GetDoorID() ~= MANSION_DOOR then
		return
	end

	-- key already on the keyring: just go in
	if e.other:KeyRingCheck(prog.ITEM.key_configurable) then
		e.other:MovePC(437, MANSION_IN.x, MANSION_IN.y, MANSION_IN.z, MANSION_IN.h)
		return
	end

	-- carrying the unconfigured key: report alignment, admit at 8/8
	if e.other:CountItem(prog.ITEM.key_configurable) > 0 then
		local teeth, tooth, _ = prog.lock_load(e.other)
		local aligned = prog.lock_aligned(teeth)
		if aligned >= 8 then
			e.other:KeyRingAdd(prog.ITEM.key_configurable)
			e.other:Message(15, "All eight teeth align. With a satisfying "
				.. "clunk the great door recognizes your key -- it is "
				.. "yours forever.")
			e.other:MovePC(437, MANSION_IN.x, MANSION_IN.y, MANSION_IN.z, MANSION_IN.h)
		else
			e.other:Message(15, string.format(
				"The great clockwork door hums as you press the key "
				.. "against it. %d of the eight teeth appear properly "
				.. "aligned. (You are adjusting the %s tooth.)", aligned,
				({ "first", "second", "third", "fourth", "fifth", "sixth",
					"seventh", "eighth" })[tooth]))
		end
		return
	end

	-- no key at all
	e.other:Message(13, "The door is sealed by a clockwork lock with "
		.. "eight movable teeth. It wants a very particular key.")
end

-- ---------------------------------------------------------------------------
-- Spy Reports (300036): observing Siege Inspector Huttle (436175). While a
-- player holding the task stays moderately close (but not too close) to
-- Huttle while he is stationary, observations accrue one per minute; at
-- six the inspection notes appear on the player's cursor.
-- ---------------------------------------------------------------------------
local fort = require("sof_fortress")

local HUTTLE_ID = fort.NPC.huttle
local TASK_OBSERVE_ACT = 1 -- activity 1 of 300036 (scripted, activitytype 255)

function event_load(e)
	eq.set_timer("huttle_watch", 10000)
end

function event_timer(e)
	if e.timer ~= "huttle_watch" then return end
	local task = fort.TASK_SPY_REPORTS
	if not e.self:IsTaskActive(task)
		or fort.activity_done(e.self, task, TASK_OBSERVE_ACT) then
		return
	end
	local huttle = eq.get_entity_list():GetNPCByNPCTypeID(HUTTLE_ID)
	if huttle == nil then return end
	local dist = huttle:CalculateDistance(e.self:GetX(), e.self:GetY(), e.self:GetZ())
	-- "moderately close": within 60; "too close" (< 25): he snaps shut
	if dist > 60 or dist < 25 then return end

	local now = os.time()
	local raw = fort.get(e.self, fort.BUCKET.observe)
	local count, last = 0, 0
	if raw ~= nil then
		local c, l = raw:match("(%d+)|(%d+)")
		count, last = tonumber(c) or 0, tonumber(l) or 0
	end
	if now - last < 60 then return end
	count = count + 1
	fort.set(e.self, fort.BUCKET.observe, count .. "|" .. now)
	if count >= 6 then
		e.self:SummonItem(fort.ITEM.siege_notes)
		fort.bump(e.self, task, TASK_OBSERVE_ACT, 1)
		fort.set(e.self, fort.BUCKET.observe, "0|" .. now)
		e.self:Message(15, "Your sixth observation complete -- Siege Engine Inspection Notes appear on your cursor.")
	else
		e.self:Message(15, "This one seems to be coming along nicely. (" .. count .. "/6 observations)")
	end
end
