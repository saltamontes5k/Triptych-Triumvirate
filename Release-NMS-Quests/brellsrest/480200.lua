-- Grave_Watcher_Muddick (480200) -- Brell's Rest war camp, Fippy's grave.
-- Trigger for the T6 open raid "Fippy's Revenge". Rasper: miscRaidProg.html.
-- 72h world cooldown held in the global data bucket "uf.open.fippy".
local prog = require("uf_progression")

local FIPPY = prog.NPC.fippy
local KEY = "uf.open.fippy"

function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("Keep your voice low, stranger -- this is [Fippy]'s grave. "
			.. "The gnoll kings do not rest easy under Brell's own ground. "
			.. "If your warband is set for it, say you will [disturb] the grave.")
	elseif e.message:findi("disturb") or e.message:findi("fippy") then
		local up = eq.get_entity_list():IsMobSpawnedByNpcTypeID(FIPPY)
		if up then
			e.self:Say("He walks already! To arms -- and mind the shamans.")
			return
		end
		local ready, remain = prog.world_ready(KEY)
		if not ready then
			e.self:Say(string.format(
				"The grave will not give up its king again so soon. "
				.. "Return in about %d hours.", math.ceil(remain / 3600)))
			return
		end
		prog.world_start(KEY, 72)
		eq.spawn2(FIPPY, 0, 0, e.self:GetX() + 25, e.self:GetY() + 10,
			e.self:GetZ(), 0)
		eq.zone_emote(15, "The grave mound splits open. Fippy Darkpaw rises, "
			.. "crowned in grave-dirt and fury. FIPPY'S REVENGE BEGINS!")
	end
end

function event_trade(e)
	local item_lib = require("items")
	item_lib.return_items(e.self, e.other, e.trade)
end
