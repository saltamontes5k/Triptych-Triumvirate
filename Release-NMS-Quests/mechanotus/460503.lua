-- an_emergency_repair_mechanic (460503) -- MMM raid phase 1 add,
-- mechanotus instance v1. Rasper: raidMMM.html — emergency repair mechanics
-- "path to Meldrath, if they reach him they will heal him".
-- Implementation: channels for 25s; if it completes the channel,
-- #Meldrath_The_Malignant (365034) fully repairs. Kill it before the cast ends.

local MELDRATH = 365034
local CHANNEL_MS = 25000

function event_spawn(e)
	e.self:SetEntityVariable("repairing", "0")
	eq.set_timer("repair", CHANNEL_MS)
end

function event_timer(e)
	if e.timer == "repair" then
		if e.self:GetEntityVariable("repairing") == "0" then
			e.self:SetEntityVariable("repairing", "1")
			e.self:Emote("begins an emergency repair sequence!")
			eq.set_timer("repair", CHANNEL_MS)
		else
			local meldrath = eq.get_entity_list():GetNPCByNPCTypeID(MELDRATH)
			if meldrath and meldrath.valid and meldrath:GetHPRatio() > 0 then
				meldrath:Heal()
				eq.zone_emote(15, "The repair mechanic reaches Meldrath. His frame screams as the damage knits shut!")
			end
			e.self:Depop()
		end
	end
end

function event_combat(e)
	if e.joined then
		-- interrupted channel: restart once back out of combat
		e.self:SetEntityVariable("repairing", "0")
		eq.stop_timer("repair")
	end
end

function event_death_complete(e)
	eq.zone_emote(15, "The repair mechanic collapses in a shower of gears.")
end
