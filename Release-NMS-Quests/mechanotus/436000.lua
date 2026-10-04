-- Lamperious Cogwittle (436000) -- Lost Lumpling (300034), the long
-- openFortress arc. Simplified chain: pouch combine -> Bloodwolf staged
-- hails (escort replaced by spawns), ooze ring, gardener, Steam Factory
-- song, aged minotaur, Jemi's S.H.I.P. expedition, Veltar.
local fort = require("sof_fortress")

local TASKS = { fort.TASK_LUMPLING }

function event_say(e)
	if e.message:findi("hail") then
		if e.other:IsTaskActive(fort.TASK_LUMPLING)
			and not fort.activity_done(e.other, fort.TASK_LUMPLING, 0) then
			e.self:Say("You found the tracker? Derek Wolfblood in Dragonscale "
				.. "Hills. Tell him 'Lost Lumpling' and do what he asks.")
		elseif e.other:IsTaskActive(fort.TASK_LUMPLING)
			and fort.activity_done(e.other, fort.TASK_LUMPLING, 5)
			and not fort.activity_done(e.other, fort.TASK_LUMPLING, 6) then
			e.self:Say("The pouch is ready? Give it here -- I can wake the "
				.. "Bloodwolf's spirit to follow the trail.")
		else
			e.self:Say("Hail, " .. e.other:GetCleanName() .. ". My little "
				.. "Lumpling is [lost]. Lost in all this smoke and iron. "
				.. "Will nobody help a mad old gnome?")
		end
	elseif e.message:findi("lost") or e.message:findi("lumpling") then
		if not e.other:IsTaskCompleted(fort.TASK_LUMPLING)
			and not e.other:IsTaskActive(fort.TASK_LUMPLING) then
			e.self:Say("Then find her! Start with Derek [Wolfblood] in "
				.. "Dragonscale Hills -- he can set you on the scent.")
			eq.task_selector(TASKS)
		elseif e.other:IsTaskActive(fort.TASK_LUMPLING) then
			e.self:Say("The trail is still warm. Follow it, and mind the "
				.. "gardener's huts west of here.")
		end
	elseif e.message:findi("wolfblood") then
		e.self:Say("A tracker of some renown, for a human. Dragonscale "
			.. "Hills, by the windmill.")
	end
end

function event_task_accepted(e)
	e.other:Message(15, "Cogwittle presses a crumpled map into your hands. "
		.. "Start with Derek Wolfblood in Dragonscale Hills.")
end

function event_trade(e)
	local item_lib = require("items")
	-- stage: the combined Bloodwolf Spirit Pouch wakes the Bloodwolf
	if e.other:IsTaskActive(fort.TASK_LUMPLING)
		and fort.activity_done(e.other, fort.TASK_LUMPLING, 4) then
		if e.trade and e.trade.click1 == fort.ITEM.pouch then
			e.self:Say("There -- the scent is bound. The Bloodwolf waits by "
				.. "the gardener's huts to the west. Hail him and he will "
				.. "snuff out Lumpling's trail.")
			eq.spawn2(fort.NPC.bloodwolf, 0, 0, -1062, 719, 476, 250) -- gardens (TUNABLE)
			eq.signal(fort.NPC.cogwittle, 0)
			return
		end
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
