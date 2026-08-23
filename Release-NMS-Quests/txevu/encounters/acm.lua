--Ancient Cragbeast Matriarch (NMS)
local thread_manager = require("thread_manager")

local bearer_list = {297173, 297055, 297190, 297051, 297054, 297050, 297208, 297142, 297053, 297052, 297141, 297191}
local handler = 297048 
local matriarch = 297056
local hatchling = 297210

local bearer_sw = {669.00, -115.00, -351.52, 0}
local bearer_s = {641.00, -115.00, -351.52, 0}
local bearer_se = {615.00, -115.00, -350.9, 0}
local bearer_nw = {669.00, 115.00, -353.9, 256}
local bearer_n = {641.00, 115.00, -353.9, 256}
local bearer_ne = {615.00, 115.00, -353.9, 256}
local handler_n = {641.00, 80.00, -364.9, 256}
local handler_s = {641.00, -80.00, -360.27, 0}
local acm = {627.00, 0.00, -364.77, 118}

local sw = 0
local s = 0
local se = 0
local nw = 0
local n = 0
local ne = 0

local adds = false
local combat = false
local ae = false

function chain_agro(e)
  local target = eq.get_entity_list():GetRandomClient(e.self:GetX(), e.self:GetY(), e.self:GetZ(), 200 * 200)
  e.self:AddToHateList(target, 1)
end

function pick_bearer(locs)
	--Pick a random bearer
  local idx = math.random(#bearer_list)
  local spawn_id = table.remove(bearer_list, idx)
  eq.spawn2(spawn_id, 0, 0, unpack(locs))
  return spawn_id
end

function reset()
	--Despawn everything
	eq.depop_all(handler)
	eq.depop_all(hatchling)
	
  bearer_list = {297173, 297055, 297190, 297051, 297054, 297050, 297208, 297142, 297053, 297052, 297141, 297191}
	for i = 1, #bearer_list do
		eq.depop_all(bearer_list[i])
    eq.signal(matriarch, bearer_list[i] + 1000000)
	end
end

function init_event()
	eq.spawn2(handler, 0, 0, unpack(handler_n)) --North Handler 
	eq.spawn2(handler, 0, 0, unpack(handler_s)) --South Handler
	sw = pick_bearer(bearer_sw) --Southwest Bearer
	s = pick_bearer(bearer_s) --South Bearer
	se = pick_bearer(bearer_se) --Southeast Bearer
	nw = pick_bearer(bearer_nw) --Northwest Bearer
	n = pick_bearer(bearer_n) --North Bearer
	ne = pick_bearer(bearer_ne) --Northeast Bearer
end

function bearer_spawn(e)
	eq.signal(matriarch, e.self:GetNPCTypeID())
end

function bearer_death(e)
	if sw == e.self:GetNPCTypeID() then
		sw = 0
		eq.signal(matriarch, 1)
	elseif s == e.self:GetNPCTypeID() then
		s = 0
		eq.signal(matriarch, 2)
	elseif se == e.self:GetNPCTypeID() then
		se = 0
		eq.signal(matriarch, 3)
	elseif nw == e.self:GetNPCTypeID() then
		nw = 0
		eq.signal(matriarch, 4)
	elseif n == e.self:GetNPCTypeID() then
		n = 0
		eq.signal(matriarch, 5)
	elseif ne == e.self:GetNPCTypeID() then
		ne = 0
		eq.signal(matriarch, 6)
	end
	eq.signal(matriarch, e.self:GetNPCTypeID() + 1000000)
  table.insert(bearer_list, e.self:GetNPCTypeID())
end

function handler_combat(e)
  if e.joined then
	  eq.set_timer('leash', 3 * 1000)
    eq.signal(handler, 1)
    eq.signal(matriarch, 10)
  else
    eq.stop_timer('leash')
  end
end

function handler_signal(e)
  if e.signal == 1 then
    chain_agro(e)
  end
end

function handler_death(e)
	eq.stop_timer('leash')
end

function handler_timer(e)
	if e.timer == 'leash' then
		if e.self:GetX() >= 700 then
			e.self:GotoBind()
			e.self:WipeHateList()
		end
	end
end

function matriarch_death(e)
	-- Despawn everything because the players won
	eq.stop_all_timers()
	reset()
end

function matriarch_combat(e)
	if e.joined then
		combat = true
		if adds then
			eq.set_timer('hatchlings', 35 * 1000)
		end
		if ae then
			eq.set_timer('aoe', math.random(5, 60) * 1000)
		end
		eq.stop_timer("reset")
    eq.signal(handler, 1)
	else
		combat = false
		eq.stop_timer("hatchlings")
		eq.stop_timer("aoe")
		eq.set_timer("reset", 2 * 60 * 1000)
	end
end

function matriarch_timer(e)
	if e.timer == "hatchlings" then
		local x,y,z,h = e.self:GetX(), e.self:GetY(), e.self:GetZ(), e.self:GetHeading();
		eq.zone_emote(MT.Yellow, "In search of food, cragebeast hatchlings scurry out from beneath the Ancient Cragbeast Matriarch")
		eq.spawn2(hatchling, 0, 0, x, y + 5, z, h)
		eq.spawn2(hatchling, 0, 0, x + 5, y, z, h)
		eq.spawn2(hatchling, 0, 0, x + 5, y + 5, z, h)
	elseif e.timer == 'aoe' then
		eq.stop_timer('aoe')
		local target = e.self:GetTarget()
		if target.valid then
			e.self:CastSpell(1239, target:GetID()) --Devouring Conflagration
		end
	elseif e.timer == 'sw' then
		eq.stop_timer('sw')
		sw = pick_bearer(bearer_sw)
	elseif e.timer == 's' then
		eq.stop_timer('s')
		s = pick_bearer(bearer_s)
	elseif e.timer == 'se' then
		eq.stop_timer('se')
		se = pick_bearer(bearer_se)
	elseif e.timer == 'nw' then
		eq.stop_timer('nw')
		nw = pick_bearer(bearer_nw)
	elseif e.timer == 'n' then
		eq.stop_timer('n')
		n = pick_bearer(bearer_n)
	elseif e.timer == 'ne' then
		eq.stop_timer('ne')
		ne = pick_bearer(bearer_ne)
	elseif e.timer == 'reset' then
    eq.stop_timer('reset')
    e.self:CastSpell(3230, e.self:GetID())
		e.self:WipeHateList()
    reset()
    eq.set_timer('respawn', 2 * 1000)
  elseif e.timer == 'respawn' then
    eq.stop_timer('respawn')
    init_event()
	end
end

function matriarch_signal(e)
	local repop = 2 * 60 * 1000
	if e.signal == 1 then
		eq.set_timer('sw', repop)
	elseif e.signal == 2 then
		eq.set_timer('s', repop)
	elseif e.signal == 3 then
		eq.set_timer('se', repop)
	elseif e.signal == 4 then
		eq.set_timer('nw', repop)
	elseif e.signal == 5 then
		eq.set_timer('n', repop)
	elseif e.signal == 6 then
		eq.set_timer('ne', repop)
  elseif e.signal == 10 then
    chain_agro(e)
	elseif e.signal == 297173 then
		e.self:ModSkillDmgTaken(0, -75) -- 1h blunt
		e.self:ModSkillDmgTaken(1, -75) -- 1h slashing
		e.self:ModSkillDmgTaken(2, -75) -- 2h blunt
		e.self:ModSkillDmgTaken(3, -75) -- 2h slashing
		e.self:ModSkillDmgTaken(7, -75) -- archery
		e.self:ModSkillDmgTaken(8, -75) -- backstab
		e.self:ModSkillDmgTaken(10, -75) -- bash
		e.self:ModSkillDmgTaken(21, -75) -- dragon punch
		e.self:ModSkillDmgTaken(23, -75) -- eagle strike
		e.self:ModSkillDmgTaken(26, -75) -- flying kick
		e.self:ModSkillDmgTaken(28, -75) -- hand to hand
		e.self:ModSkillDmgTaken(30, -75) -- kick
		e.self:ModSkillDmgTaken(36, -75) -- piercing
		e.self:ModSkillDmgTaken(38, -75) -- round kick
		e.self:ModSkillDmgTaken(52, -75) -- tiger claw
		e.self:ModSkillDmgTaken(74, -75) -- frenzy
	elseif e.signal == 1297173 then
		e.self:ModSkillDmgTaken(0, 0) -- 1h blunt
		e.self:ModSkillDmgTaken(1, 0) -- 1h slashing
		e.self:ModSkillDmgTaken(2, 0) -- 2h blunt
		e.self:ModSkillDmgTaken(3, 0) -- 2h slashing
		e.self:ModSkillDmgTaken(7, 0) -- archery
		e.self:ModSkillDmgTaken(8, 0) -- backstab
		e.self:ModSkillDmgTaken(10, 0) -- bash
		e.self:ModSkillDmgTaken(21, 0) -- dragon punch
		e.self:ModSkillDmgTaken(23, 0) -- eagle strike
		e.self:ModSkillDmgTaken(26, 0) -- flying kick
		e.self:ModSkillDmgTaken(28, 0) -- hand to hand
		e.self:ModSkillDmgTaken(30, 0) -- kick
		e.self:ModSkillDmgTaken(36, 0) -- piercing
		e.self:ModSkillDmgTaken(38, 0) -- round kick
		e.self:ModSkillDmgTaken(52, 0) -- tiger claw
		e.self:ModSkillDmgTaken(74, 0) -- frenzy
	elseif e.signal == 297055 then
		e.self:SetSpecialAbility(SpecialAbility.rampage, 1)
		e.self:SetSpecialAbilityParam(SpecialAbility.rampage, 0, 27)
	elseif e.signal == 1297055 then
		e.self:SetSpecialAbility(SpecialAbility.rampage, 0)
	elseif e.signal == 297190 then
		e.self:SetSpecialAbility(SpecialAbility.flurry, 1)
		e.self:SetSpecialAbilityParam(SpecialAbility.flurry, 0, 50)
	elseif e.signal == 1297190 then
		e.self:SetSpecialAbility(SpecialAbility.flurry, 0)
	elseif e.signal == 297051 then
		e.self:ModifyNPCStat("min_hit", "1150")
		e.self:ModifyNPCStat("max_hit", "4000")
	elseif e.signal == 1297051 then
		e.self:ModifyNPCStat("min_hit", "850")
		e.self:ModifyNPCStat("max_hit", "2750")
	elseif e.signal == 297054 then
		e.self:ModifyNPCStat("combat_hp_regen", "6000")
	elseif e.signal == 1297054 then
		e.self:ModifyNPCStat("combat_hp_regen", "100")
	elseif e.signal == 297050 then
		adds = true
		if combat then
			eq.set_timer("hatchling", 35 * 1000)
		end
	elseif e.signal == 1297050 then
		adds = false
		eq.stop_timer("hatchling")
	elseif e.signal == 297208 then
		ae = true
		if combat then
			eq.set_timer("ae", math.random(5, 60) * 1000)
		end
	elseif e.signal == 1297208 then
		ae = false
		eq.stop_timer("ae")
	elseif e.signal == 297142 then
		e.self:ModifyNPCStat("attack_delay", "12")
	elseif e.signal == 1297142 then
		e.self:ModifyNPCStat("attack_delay", "17")
	elseif e.signal == 297053 then
		e.self:SetSpecialAbility(SpecialAbility.area_rampage, 1)
		e.self:SetSpecialAbilityParam(SpecialAbility.area_rampage, 0, 17)
	elseif e.signal == 1297053 then
		e.self:SetSpecialAbility(SpecialAbility.area_rampage, 0)
	elseif e.signal == 297052 then
		e.self:AddAISpell(0, 1248, 1024, -1, 30, -1) -- Spiritual Echo, in combat buff
	elseif e.signal == 1297052 then
		e.self:RemoveAISpell(1248) -- Spiritual Echo
	elseif e.signal == 297141 then
		e.self:ModifyNPCStat("mr", "236")
		e.self:ModifyNPCStat("fr", "236")
		e.self:ModifyNPCStat("cr", "236")
		e.self:ModifyNPCStat("pr", "236")
		e.self:ModifyNPCStat("dr", "236")
	elseif e.signal == 1297141 then
		e.self:ModifyNPCStat("mr", "136")
		e.self:ModifyNPCStat("fr", "136")
		e.self:ModifyNPCStat("cr", "136")
		e.self:ModifyNPCStat("pr", "136")
		e.self:ModifyNPCStat("dr", "136")
	elseif e.signal == 297191 then
		e.self:AddAISpell(0, 1249, 1024, -1, 30, -1) -- Bristling Armament, in combat buff
	elseif e.signal == 1297191 then
		e.self:RemoveAISpell(1249) -- Bristling Armament
  end
end
		
function event_encounter_load(e)
	eq.register_npc_event("acm", Event.signal, matriarch, matriarch_signal)
	eq.register_npc_event("acm", Event.timer, matriarch, matriarch_timer)
	eq.register_npc_event("acm", Event.combat, matriarch, matriarch_combat)
	eq.register_npc_event("acm", Event.death, matriarch, matriarch_death)
	
	eq.register_npc_event("acm", Event.timer, handler, handler_timer)
	eq.register_npc_event("acm", Event.death, handler, handler_death)
  eq.register_npc_event("acm", Event.combat, handler, handler_combat)
  eq.register_npc_event("acm", Event.signal, handler, handler_signal)
	
	for i = 1, #bearer_list do
		eq.register_npc_event("acm", Event.death, bearer_list[i], bearer_death)
		eq.register_npc_event("acm", Event.spawn, bearer_list[i], bearer_spawn)
  end
  reset()
  init_event()
end
