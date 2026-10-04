-- #Mechalossus (439707) -- Mechalossus (301112) mission boss.
-- Timed trash adds; Field Engineer Fingibble emotes over the fight; on the
-- 4th emote Mechalossus awakens (rage heal + elite guard).

local ADD_NPC = 439057   -- a lab worker (mezzable)

function event_combat(e)
	if e.joined then
		e.self:SetEntityVariable("fingibble", "0")
		e.self:SetTimer("fingibble", 30000)
		eq.zone_emote(15, "Mechalossus sleeps no longer. The workshop shakes.")
	else
		e.self:StopTimer("fingibble")
	end
end

function event_timer(e)
	if e.timer == "fingibble" then
		local n = tonumber(e.self:GetEntityVariable("fingibble") or "0") or 0
		n = n + 1
		e.self:SetEntityVariable("fingibble", tostring(n))
		if n == 1 then
			eq.zone_emote(15, "A voice crackles overhead: 'Field report -- big robot awake. Advice: run. Ha! Mechalossus, smash them softly.'")
		elseif n == 2 then
			eq.zone_emote(15, "Fingibble: 'Feed it the spare parts!'")
		elseif n == 3 then
			eq.zone_emote(15, "Fingibble: 'Two more turns of the crank and it will be ANGRY!'")
		elseif n == 4 then
			eq.zone_emote(15, "Mechalossus AWAKENS. Its eyes burn white!")
			e.self:Heal(25)
			e.self:CastSpell(7934, e.self:GetID()) -- Steam Shield
		else
			eq.zone_emote(15, "Fingibble: 'Keep it busy! The paperwork on a full awakening is ENORMOUS.'")
		end
		-- trash add stream, mezzable
		local x, y, z = e.self:GetX(), e.self:GetY(), e.self:GetZ()
		for i = 1, 2 do
			local mob = eq.spawn2(ADD_NPC, 0, 0, x + math.random(-40, 40),
				y + math.random(-40, 40), z, 0)
			if mob ~= nil then
				local t = e.self:GetTarget()
				if t ~= nil then mob:AddToHateList(t, 1) end
			end
		end
	end
end

function event_death_complete(e)
	eq.zone_emote(15, "Mechalossus slumps into spare parts. Fingibble whistles innocently from somewhere.")
end
