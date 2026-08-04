--Ukun Bloodfeaster
local bloodfeaster = 297082
local mauler = 297200
local stonemite = 297207

local adds = 0

function spawn_stonemites()
	for i = 1, 10 do
		if adds < 30 then
			eq.spawn2(stonemite, 0, 0, 255.47, 431.62, -420.87, 0)
			adds = adds + 1
		end
	end
end


function tether(e, force)
	if force or e.self:GetY() < 242 or e.self:GetX() < 110 or e.self:GetX() > 340 then
		e.self:CastSpell(3791, e.self:GetID())
		e.self:GotoBind()
		e.self:WipeHateList()
	end
end

function chain_agro(e)
	local target = eq.get_entity_list():GetRandomClient(e.self:GetX(), e.self:GetY(), e.self:GetZ(), 1000 * 1000)
	e.self:AddToHateList(target, 1)
end
	

function reset()
	--Despawn everything except the bloodfeaster
  eq.stop_all_timers()
	eq.depop_all(stonemite)
	eq.depop_all(mauler)
	eq.signal(bloodfeaster, 1)
end

function init()
	-- Respawn the maulers
	eq.spawn2(297200, 0, 0, 261, 406, -420.02, 160)
	eq.spawn2(297200, 0, 0, 232, 412, -419.9, 200)
	eq.spawn2(297200, 0, 0, 241.56, 444.08, -420.77, 217.25)
end

function mauler_signal(e)
	if e.signal == 2 then
		chain_agro(e)
	end
end

function mauler_combat(e)
	if e.joined then
		eq.stop_timer('reset')
		eq.set_timer('tether', 3 * 1000)
		eq.signal(bloodfeaster, 2)
		eq.signal(stonemite, 2)
		eq.signal(mauler, 2)
	else
		eq.stop_timer('tether')
    if not eq.has_timer('reset') then
		  eq.set_timer('reset', 2 * 60 * 1000)
    end
	end
end

function mauler_timer(e)
	if e.timer == 'tether' then
		tether(e, false)
	elseif e.timer == 'reset' then
    eq.stop_timer('reset')
		reset()
	end
end

function mauler_spawn(e)
  e.self:SetSpecialAbility(24, 0)
  e.self:SetSpecialAbility(35, 0)
	e.self:ModSkillDmgTaken(0, 10)
	e.self:ModSkillDmgTaken(2, 10)
	e.self:ModSkillDmgTaken(36, -10)
	e.self:ModSkillDmgTaken(77, -10)
	e.self:ModSkillDmgTaken(28, 10)
	e.self:ModSkillDmgTaken(7, 10)
end

function stonemite_combat(e)
	if e.joined then
		eq.stop_timer('reset')
		eq.set_timer('tether', 3 * 1000)
		eq.signal(bloodfeaster, 2)
		eq.signal(stonemite, 2)
		eq.signal(mauler, 2)
	else
	  if not eq.has_timer('reset') then
	    eq.set_timer('reset', 2 * 60 * 1000)
    end
	end
end

function stonemite_timer(e)
	if e.timer == 'tether' then
		tether(e, false)
	elseif e.timer == 'reset' then
    eq.stop_timer('reset')
		reset()
	end
end

function stonemite_death(e)
	adds = adds - 1
end

function stonemite_signal(e)
	if e.signal == 2 then
		chain_agro(e)
	end
end

function stonemite_spawn(e)
	chain_agro(e)
end

function bloodfeaster_spawn(e)
	e.self:ModSkillDmgTaken(0, 10)
	e.self:ModSkillDmgTaken(2, 10)
	e.self:ModSkillDmgTaken(36, -10)
	e.self:ModSkillDmgTaken(77, -10)
	e.self:ModSkillDmgTaken(28, 10)
	e.self:ModSkillDmgTaken(7, 10)
end

function bloodfeaster_signal(e)
	if e.signal == 1 then
		tether(e, true)
		init()
	elseif e.signal == 2 then
		chain_agro(e)
	end
end

function bloodfeaster_combat(e)
	if e.joined then
		eq.stop_timer('reset')
		eq.set_timer('tether', 3 * 1000)
		eq.set_timer('mites',  30 * 1000)
		eq.signal(bloodfeaster, 2)
		eq.signal(stonemite, 2)
		eq.signal(mauler, 2)
	else
    eq.stop_timer('mites')
	  if not eq.has_timer('reset') then
	    eq.set_timer('reset', 2 * 60 * 1000)
    end
	end
end

function bloodfeaster_timer(e)
	if e.timer == 'reset' then
    eq.stop_timer('reset')
		reset()
	elseif e.timer == 'tether' then
		tether(e, false)
	elseif e.timer == 'mites' then
		spawn_stonemites()
	end
end

function bloodfeaster_death(e)
	reset()
end

function event_encounter_load(e)
	eq.register_npc_event("bloodfeaster", Event.death_complete, bloodfeaster, bloodfeaster_death)
	eq.register_npc_event("bloodfeaster", Event.timer, bloodfeaster, bloodfeaster_timer)
	eq.register_npc_event("bloodfeaster", Event.combat, bloodfeaster, bloodfeaster_combat)
	eq.register_npc_event("bloodfeaster", Event.signal, bloodfeaster, bloodfeaster_signal)
	eq.register_npc_event("bloodfeaster", Event.spawn, bloodfeaster, bloodfeaster_spawn)
	
	eq.register_npc_event("bloodfeaster", Event.death_complete, stonemite, stonemite_death)
	eq.register_npc_event("bloodfeaster", Event.timer, stonemite, stonemite_timer)
	eq.register_npc_event("bloodfeaster", Event.combat, stonemite, stonemite_combat)
	eq.register_npc_event("bloodfeaster", Event.signal, stonemite, stonemite_signal)
	eq.register_npc_event("bloodfeaster", Event.spawn, stonemite, stonemite_spawn)
	
	eq.register_npc_event("bloodfeaster", Event.spawn, mauler, mauler_spawn)
	eq.register_npc_event("bloodfeaster", Event.timer, mauler, mauler_timer)
	eq.register_npc_event("bloodfeaster", Event.combat, mauler, mauler_combat)
	eq.register_npc_event("bloodfeaster", Event.signal, mauler, mauler_signal)
	
	reset()
end
