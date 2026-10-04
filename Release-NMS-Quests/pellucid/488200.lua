-- Burrow_Watcher_Tilra (488200) -- Pellucid Grotto, the trembling burrow.
-- Trigger for the T6 open raid "The Unburrowing". Rasper: miscRaidProg.html.
-- 72h world cooldown held in the global data bucket "uf.open.burrow".
local prog = require("uf_progression")

local UNBURROWING = prog.NPC.unburrowing
local KEY = "uf.open.burrow"

function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("Shh. The ground here [moves] -- something beneath is "
			.. "digging toward the foundations of the world. If your "
			.. "warband is set for it, tell me to [dig] it out.")
	elseif e.message:findi("dig") or e.message:findi("move") then
		local up = eq.get_entity_list():IsMobSpawnedByNpcTypeID(UNBURROWING)
		if up then
			e.self:Say("It is already among us -- look to the tunnels!")
			return
		end
		local ready, remain = prog.world_ready(KEY)
		if not ready then
			e.self:Say(string.format(
				"The burrow is collapsed and the deep things are wary. "
				.. "Return in about %d hours.", math.ceil(remain / 3600)))
			return
		end
		prog.world_start(KEY, 72)
		eq.spawn2(UNBURROWING, 0, 0, e.self:GetX() + 20, e.self:GetY() - 20,
			e.self:GetZ(), 0)
		eq.zone_emote(15, "The burrow bursts open -- THE UNBURROWING HAS COME!")
	end
end

function event_trade(e)
	local item_lib = require("items")
	item_lib.return_items(e.self, e.other, e.trade)
end
