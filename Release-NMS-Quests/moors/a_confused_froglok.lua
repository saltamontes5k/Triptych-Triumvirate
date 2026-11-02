-- moors/a_confused_froglok.lua
-- King of the Monsters (moors v40): the confused froglok. Harmless (no
-- melee), hopelessly lost, and it follows whatever drakkin whelp it sees
-- because it is confused. Do not eat it: when it dies to the kaiju it
-- bursts (stock Venom Blast, target-AE centered on the killer) for a huge
-- portion of the Moorwalker's hitpoints -- two bursts will kill. Signal
-- 110 to the controller for the flavor line.

local CONTROLLER  = 1520001970
local POISON_BLAST = 11684 -- Venom Blast: target-AE, -500

function event_spawn(e)
	e.self:SetDisableMelee(true)
	eq.set_timer("befriend", 2000)
end

function event_timer(e)
	if e.timer ~= "befriend" then
		return
	end
	-- follow the nearest live whelp; SetFollowID clears itself when the
	-- target dies, and the next tick re-follows whoever is closest
	local target = nil
	local best = 999999999
	local npcs = eq.get_entity_list():GetNPCList()
	for npc in npcs.entries do
		if npc.valid and npc:GetNPCTypeID() >= 1520001971 and npc:GetNPCTypeID() <= 1520001976 then
			local dx = npc:GetX() - e.self:GetX()
			local dy = npc:GetY() - e.self:GetY()
			local d = dx * dx + dy * dy
			if d < best then
				best = d
				target = npc
			end
		end
	end
	if target then
		e.self:SetFollowID(target:GetID())
		e.self:SetFollowCanRun(true)
		e.self:SetFollowDistance(50)
	end
end

function event_death(e)
	local killer = eq.get_entity_list():GetClientByID(e.killer_id)
	if killer and killer:GetRace() == 436 then
		-- SpellFinished, not CastSpell: the froglok is dying and cannot
		-- finish a cast bar. The blast is centered on the killer.
		e.self:SpellFinished(POISON_BLAST, killer)
		killer:Message(13, "The confused froglok pops like a rotten bladder. Venom washes over you in a wave. That, you will regret.")
		eq.signal(CONTROLLER, 110)
	end
	return 0
end
