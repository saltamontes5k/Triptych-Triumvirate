-- an aged minotaur (436731) -- Lost Lumpling. Beats him to 35% and he
-- goes inactive (refuses to fight); hail him and say "lost lumpling".
-- The speak activity (300034) credits on the hail itself.

function event_combat(e)
	if e.joined then
		e.self:SetTimerMS("yieldcheck", 2000)
	else
		e.self:StopTimer("yieldcheck")
	end
end

function event_timer(e)
	if e.timer == "yieldcheck" then
		if e.self:GetEntityVariable("inactive") == "1" then
			e.self:WipeHateList()
			return
		end
		if e.self:GetHPRatio() <= 35 then
			e.self:SetEntityVariable("inactive", "1")
			e.self:WipeHateList()
			e.self:StopTimer("yieldcheck")
			e.self:Say("*thunk* ... enough. ENOUGH. The old bull yields. "
				.. "*huffs* Speak your errand, small thing.")
		end
	end
end

function event_say(e)
	if e.message:findi("lost lumpling") then
		if e.self:GetEntityVariable("inactive") == "1" then
			e.self:Say("*huff* The little one? She sang where the machines "
				.. "sing. Foundry halls, past the crossroads. Follow the "
				.. "song, if your legs are brave.")
		else
			e.self:Say("*snort* The bull does not chat mid-bout.")
		end
	end
end
