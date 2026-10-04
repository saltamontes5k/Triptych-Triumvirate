-- Fissure_Watcher_Korvi (483100) -- Cooling Chamber, the fractured fissure.
-- Trigger for the T6 open raid "The Beast Below". Rasper: miscRaidProg.html.
-- 72h world cooldown held in the global data bucket "uf.open.beast".
local prog = require("uf_progression")

local BEAST = prog.NPC.beast
local KEY = "uf.open.beast"

function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("Careful where you stand -- this [fissure] breathes. "
			.. "Something vast lives in the coolant below. If your warband "
			.. "is set for it, [peer] into the fissure and wake it.")
	elseif e.message:findi("peer") or e.message:findi("fissure") then
		local up = eq.get_entity_list():IsMobSpawnedByNpcTypeID(BEAST)
		if up then
			e.self:Say("It is already awake -- get clear of the spray!")
			return
		end
		local ready, remain = prog.world_ready(KEY)
		if not ready then
			e.self:Say(string.format(
				"The beast sulks in the deep coolant still. Return in about "
				.. "%d hours.", math.ceil(remain / 3600)))
			return
		end
		prog.world_start(KEY, 72)
		eq.spawn2(BEAST, 0, 0, e.self:GetX() - 20, e.self:GetY() + 15,
			e.self:GetZ(), 0)
		eq.zone_emote(15, "Coolant geysers skyward as THE BEAST BELOW surfaces!")
	end
end

function event_trade(e)
	local item_lib = require("items")
	item_lib.return_items(e.self, e.other, e.trade)
end
