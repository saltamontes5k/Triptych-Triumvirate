-- #Commander_Hardsteel (441704) -- You Might Poke an Eye Out (301109).
-- Can trigger a devastating AE (live: 12k; modelled with Static Bolt 7630
-- at full force + emote warning).

function event_combat(e)
	if e.joined then
		e.self:SetTimer("shock", 30000)
	else
		e.self:StopTimer("shock")
	end
end

function event_timer(e)
	if e.timer == "shock" then
		eq.zone_emote(15, "Hardsteel's frame crackles -- STATIC SURGE incoming!")
		e.self:CastSpell(7630, e.self:GetID())
	end
end
