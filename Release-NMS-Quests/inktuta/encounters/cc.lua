local cursecallers = 6
local curse_callers     = {296053,296054,296055,296056,296057,296058}
local curse_bearers     = {296059,296060,296061,296062,296063,296064}

function init()
	cursecallers = 6
  eq.spawn2(296017,0,0,0,0,0,0) 				--#curse_trigger
  eq.spawn2(296053,0,0,-2,-961,-127,498) 		--Fhqwhgads
  eq.spawn2(296054,0,0,-7,-852,-127,254) 		--Kiamquz
  eq.spawn2(296055,0,0,-209,-970,-127,0)		--Qibaiz
  eq.spawn2(296056,0,0,-146,-994,-127,2)  	--Requarak
  eq.spawn2(296057,0,0,-145,-828,-127,248)    --Towzaqu
  eq.spawn2(296058,0,0,-218,-853,-127,258)    --Xavonique
end

function reset(re_init)
  eq.debug("Resetting Encounter: Cursecallers")
	eq.stop_all_timers()
	eq.depop(296017) --#curse_trigger

	--Cursecallers
	for i = 1,6,1 do
		eq.depop(curse_callers[i])
	end
	
	--Cursebearers
	for i = 1,6,1 do
		eq.depop_all(curse_bearers[i])
	end

	if re_init then
		init()
	end
end


function chain_agro()
	for i = 1,6,1 do
		eq.signal(curse_callers[i], 1)
    eq.signal(curse_bearers[i], 1)
	end
end

function winner()
	eq.signal(296070, 296017)
	reset(false)
end

function trigger_timer(e)
	if e.timer == 'spawn' then
		for i = 1,6,1 do
			if eq.get_entity_list():IsMobSpawnedByNpcTypeID(curse_callers[i]) then
					if not eq.get_entity_list():IsMobSpawnedByNpcTypeID(curse_bearers[i]) then
						eq.spawn2(curse_bearers[i],0,0,42,-912,-126,390)
					end
			else
				eq.depop_all(curse_bearers[i])
			end
		end
  elseif e.timer == 'reset' then
    reset(true)
  end
end

function trigger_signal(e)
  if e.signal == 1 then
    if not eq.has_timer('spawn') then
      eq.set_timer("spawn", 60 * 1000) --1 minute to Curse Bearers
    end
  elseif e.signal == 2 then
    if not eq.has_timer('reset') then
      eq.set_timer('reset', 2 * 60 * 1000) --2 minutes to reset
    end
  elseif e.signal == 3 then
    if eq.has_timer('reset') then
      eq.stop_timer('reset')
    end
  end
end

function caller_combat(e)
	if e.joined then
    eq.signal(296017, 3)
    eq.signal(296017, 1)
		chain_agro()
	else
    eq.signal(296017, 2)
	end
end

function caller_timer(e)
	if e.timer == "reset" then
    reset(true)
	end
end

function caller_signal(e)
	if e.signal == 1 then
		if e.self:GetTarget().null then
			target = eq.get_entity_list():GetRandomClient(e.self:GetX(), e.self:GetY(), e.self:GetZ(), 1000*1000)
			e.self:AddToHateList(target, 1)
		end
	end
end

function caller_death_complete(e)
	cursecallers = cursecallers - 1
	el = eq.get_entity_list()
	local is_a_caller_alive = false
	for i = 1,6,1 do
		if el:GetMobByNpcTypeID(curse_callers[i]) then
			is_a_caller_alive = true
			break
		end
	end
	if cursecallers == 0 or not is_a_caller_alive then
		winner()
	end
end

function bearer_spawn(e)
	e.self:ModifyNPCStat("runspeed", "0.3")
	eq.set_timer("increase", 10 * 1000) --Every 10s, increase speed slightly
	target = eq.get_entity_list():GetRandomClient(e.self:GetX(), e.self:GetY(), e.self:GetZ(), 1000*1000)
	target:Message(MT.Magenta, eq.ChooseRandom("The thoughts of a cursed trusik invade your mind, 'You will share my fate. Do not attempt to resist. I am coming for you.'","The thoughts of a cursed trusik invade your mind, 'You will not escape me so easily.'"))
	e.self:AddToHateList(target, 1000000)
  e.self:ModSkillDmgTaken(51, 200)       -- throwing
end

function bearer_timer(e)
	if e.timer == 'increase' then
		new_speed = e.self:GetNPCStat('runspeed') + 0.1
		e.self:ModifyNPCStat("runspeed", tostring(new_speed))
	elseif e.timer == 'reset' then
		reset(true)
	elseif e.timer == 'tether' then
		if e.self:GetX() < -325 then
			e.self:CastSpell(3230, e.self:GetID()) --Spell: Balance of the Nameless
			e.self:GotoBind()
			e.self:WipeHateList()
			e.self:ModifyNPCStat("runspeed", "3.0") --If players try to re-engage, they're doing shenanigans maybe.  Punishment!
		end
	end
end

function bearer_damage_given(e)
	if e.spell_id == 2156 then
		e.self:Shout("Die!")
		eq.depop()
	end
end

function bearer_combat(e)
	if e.joined then
		if e.self:GetNPCStat('runspeed') >= 3.0 then
			eq.local_emote({e.self:GetX(), e.self:GetY(), e.self:GetZ()}, MT.Yellow, 500, "The cursebearer advances with incredible speed. Nothing natural could possibly move that fast.")
		end
		eq.set_timer("tether", 3 * 1000) --Check tether every 3 seconds
	  eq.signal(296017, 3)
  else
		eq.stop_timer("tether")
    eq.signal(296017, 2)
	end
end

function bearer_signal(e)
	if e.signal == 1 then
		if e.self:GetTarget().null then
			target = eq.get_entity_list():GetRandomClient(e.self:GetX(), e.self:GetY(), e.self:GetZ(), 1000*1000)
			e.self:AddToHateList(target, 1)
		end
	end
end

function event_encounter_load(e)
	--#curse_trigger
	eq.register_npc_event('cc', Event.signal, 296017, trigger_signal)
	eq.register_npc_event('cc', Event.timer, 296017, trigger_timer)
	
	--Cursecallers
	for i = 1,6,1 do
		eq.register_npc_event('cc', Event.combat, curse_callers[i], caller_combat)
		eq.register_npc_event('cc', Event.timer, curse_callers[i], caller_timer)
		eq.register_npc_event('cc', Event.signal, curse_callers[i], caller_signal)
		eq.register_npc_event('cc', Event.death_complete, curse_callers[i], caller_death_complete)
	end
	
	--Cursebearers
	for i = 1,6,1 do
		eq.register_npc_event('cc', Event.damage_given, curse_bearers[i], bearer_damage_given)
		eq.register_npc_event('cc', Event.combat, curse_bearers[i], bearer_combat)
		eq.register_npc_event('cc', Event.timer, curse_bearers[i], bearer_timer)
		eq.register_npc_event('cc', Event.spawn, curse_bearers[i], bearer_spawn)
    eq.register_npc_event('cc', Event.signal, curse_bearers[i], bearer_signal)
	end
	
	init()
end
