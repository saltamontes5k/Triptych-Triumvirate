-- Sixton Farqudot (460500) -- MMM raid opener, mechanotus instance v1.
-- Rasper: raidMMM.html — "It starts with Sixton... Split him away from
-- Meldrath, kill him, and then the event begins in earnest."
-- His death signals #Meldrath_The_Malignant (365034) to become vulnerable.

function event_spawn(e)
	eq.set_timer("hailcheck", 30000)
end

function event_combat(e)
	if e.joined then
		eq.zone_emote(15, "Sixton Farqudot says, 'The Warmarshal's hounds have come to my master's door. Shred them!'")
		eq.stop_timer("hailcheck")
	else
		eq.set_timer("resetcheck", 30000)
	end
end

function event_timer(e)
	if e.timer == "resetcheck" then
		if not e.self:IsEngaged() then
			eq.stop_timer("resetcheck")
			e.self:Heal()
			eq.zone_emote(15, "Sixton Farqudot straightens his plates. The breach grows quiet.")
		end
	elseif e.timer == "hailcheck" then
		eq.stop_timer("hailcheck")
		eq.zone_emote(15, "Sixton Farqudot bars the way deeper into the mansion hall.")
	end
end

function event_death_complete(e)
	eq.zone_emote(15, "Sixton Farqudot clatters to the floor. Beyond him, Meldrath the Malignant stirs on his throne.")
	eq.signal(460590, 2006) -- tell the zone controller Sixton is down
end
