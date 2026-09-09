function event_spawn(e)
	eq.set_timer("Depop", 600 * 1000) -- 10 Minutes
end

function event_timer(e)
	if e.timer == "Depop" then
		eq.stop_timer("Depop")
		eq.depop()
	end
end

function event_say(e)
	if e.message:findi("Hail") then
		local xegony_bucket = tonumber(e.other:GetAccountBucket("pop.flags.xegony")) or 0
		e.other:SummonItem(29164) -- Item: Amorphous Cloud of Air
		if xegony_bucket == 0 then
			e.other:SetAccountBucket("pop.flags.xegony", "1")
			e.other:Message(MT.LightBlue, "You receive a character flag!")
		else
			e.self:Say("It looks like we've already spoken.")
		end

		-- NMS progression: Xegony is one of the five elemental gods gating Dragons of Norrath
		-- (and LDoN). This essence is hailed after the Xegony encounter; spawn the memory NPC
		-- (global/26000.pl) so the killer can claim the DoN subflag.
		local memory_npc = eq.spawn2(26000, 0, 0, e.self:GetX(), e.self:GetY(), e.self:GetZ(), e.self:GetHeading())
		if memory_npc ~= nil then
			memory_npc:SetEntityVariable("Flag-Name", "xegony")
			memory_npc:SetEntityVariable("Stage-Name", "DoN")
		end
	end
end