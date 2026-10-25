--[[
	Xebuxoruk, The Forsaken (1120001288) -- an evil time-manipulated clone of
	Zebuxoruk. Activates in potimea at (125, 3, 182) once Quarm has fallen and
	the post-Quarm Druzzil Ro dialogue completes (world qglobal
	"xebuxoruk_unlock", set by potimeb/Druzzil_Ro.lua). His spawn point
	(respawntime 600s) always spawns him; while locked or on cooldown he depops
	himself here on every tick, so activation lands within ~10 minutes of the
	unlock and repop follows the same cadence once the 72h defeat cooldown
	("xebuxoruk_cooldown", set below on death) expires.

	Phase 1 (100-70%): every 5% an echo of a classic-era raid boss tears loose
	and joins the fight (stats overridden to level 75 / 1M hp).
	Phase 2 (70-50%): time runs backwards (heals 8% max hp every other tick),
	alternating with accelerated time (Time Distortion haste for 10s).
	Phase 3 (<50%): heals to full, then every 7% lost two collapsing stars
	appear -- kill both within 50s or they converge for 5000 damage on
	everyone on his hate list within 250 units.
]]

local xeb_id = 1120001288;

local ERA_ORDER = {"Classic", "Kunark", "Velious", "Luclin", "PoP"}

local ERA_POOLS = {
	Classic = {
		{73057,  "Lady Vox"},
		{32040,  "Lord Nagafen"},
		{63062,  "Garanel Rucksif"},
		{2001,   "Fippy Darkpaw"},
		{72003,  "Cazic Thule"},
		{76007,  "Innoruuk"},
		{71058,  "Sirran the Lunatic"},
	},
	Kunark = {
		{108048, "Phara Dar"},
		{89154,  "Trakanon"},
		{86014,  "Gorenaire"},
		{105182, "Venril Sathir"},
		{97009,  "an odd mole"},
		{103055, "Queen Velazul Di`zok"},
	},
	Velious = {
		{124155, "Vulak`Aerr"},
		{117047, "Qarrgy Scallopgobbler"},
		{127098, "Tunare"},
		{113457, "The Avatar of War"},
		{113215, "King Tormax"},
		{114106, "Lord Yelinak"},
	},
	Luclin = {
		{163075, "Grieg Veneficus"},
		{158006, "Aten Ha Ra"},
		{156075, "Yelloweyes"},
		{162227, "Emperor Ssraeshza"},
		{164078, "Thought Horror Overfiend"},
		{179037, "The Itraer Vius"},
	},
	PoP = {
		{208074, "Aerin`Dar"},
		{220006, "Lord Mithaniel Marr"},
		{205091, "Grummus"},
		{206067, "Xanamech Nezmirthafen"},
		{206074, "Manaetic Behemoth"},
		{218038, "Tantisala Jaggedtooth"},
	},
}

local ERA_BOSS_HP = 1000000
local ERA_BOSS_LEVEL = 75

local ECHO_MIN_HIT = 730
local ECHO_MAX_HIT = 1572

local ADD_SPEECH = "You will not evade me, %s!"

local STAR_NPC_TYPE_ID = 223237
local STARS_PER_WAVE = 2

local SPELL_TIME_DISTORTION = 3873
local HASTE_DURATION_MS = 10000

local SPELL_FROZEN_IN_TIME = 6654
local CONVERGE_DAMAGE = 5000
local CONVERGE_RANGE = 250

local STAR_TIMEOUT_MS = 50000
local PHASE2_TICK_MS = 20000
local PHASE3_BEAT_PCT = 7

local PHASE2_HEAL_PCT = 0.08
local SPAWN_OFFSET = 8

local STAR_MIN_DIST = 20
local STAR_MAX_DIST = 80

-- The fight happens where he stands, on the rise above the portal ring.
local ARENA_X = 125
local ARENA_Y = 3
local ARENA_RADIUS = 130
local ZONE_EMOTE_COLOR = 15

local WIPE_LINES = {
	"Xebuxoruk's presence fades as time steadies. Your time is over.",
}

local KILL_LINES = {
	"Xebuxoruk falls to his knees as the fabric of time ripples and shakes one last time before stabilizing.",
	"Xebuxoruk almost seems to smirk as he gasps. 'Time... is an illusion... hero.'",
}

local xeb_state

local function new_state()
	return {
		phase = 1,
		echo_index = 0,
		phase2_ticks = 0,
		star_waves = 0,
		waves = {},
		adds = {},
		ended = false,
	}
end

local function is_unlocked()
	local qglobals = eq.get_qglobals();
	return qglobals.xebuxoruk_unlock == "1" and qglobals.xebuxoruk_cooldown == nil
end

local function find_add(add)
	local npc = eq.get_entity_list():GetNPCByID(add.id)
	if npc.valid and npc:GetNPCTypeID() == add.type then return npc end
	return nil
end

local function despawn_adds()
	if not xeb_state then return end
	for _, add in ipairs(xeb_state.adds) do
		local npc = find_add(add)
		if npc then npc:Depop() end
	end
	xeb_state.adds = {}
end

local function show_end_line(lines)
	if xeb_state and not xeb_state.ended then
		xeb_state.ended = true
		for _, line in ipairs(lines) do
			eq.zone_emote(ZONE_EMOTE_COLOR, line)
		end
	end
end

local function event_emote(self, text)
	eq.zone_emote(ZONE_EMOTE_COLOR, self:GetCleanName() .. " " .. text)
end

local function converge_damage(self)
	local ids = {}
	for entry in self:GetHateListByDistance(CONVERGE_RANGE).entries do
		if entry.ent.valid then table.insert(ids, entry.ent:GetID()) end
	end
	local list = eq.get_entity_list()
	for _, id in ipairs(ids) do
		local target = list:GetMob(id)
		if target.valid and not target:IsCorpse() then
			target:Damage(self, CONVERGE_DAMAGE, SPELL_FROZEN_IN_TIME, Skill.Evocation, false)
		end
	end
end

local function apply_haste(self)
	self:SpellFinished(SPELL_TIME_DISTORTION, self)
	eq.set_timer("haste_end", HASTE_DURATION_MS)
end

local function reset_haste(self)
	eq.stop_timer("haste_end")
	self:BuffFadeBySpellID(SPELL_TIME_DISTORTION)
end

local function clamp_to_arena(x, y)
	local dx, dy = x - ARENA_X, y - ARENA_Y
	local dist = math.sqrt(dx * dx + dy * dy)
	if dist <= ARENA_RADIUS then return x, y end
	local scale = ARENA_RADIUS / dist
	return ARENA_X + dx * scale, ARENA_Y + dy * scale
end

local function spawn_near(self, npc_type_id, min_dist, max_dist)
	min_dist = min_dist or SPAWN_OFFSET
	max_dist = max_dist or min_dist
	local x, y, z = self:GetX(), self:GetY(), self:GetZ()
	local sx, sy
	for _ = 1, 5 do
		local angle = math.random() * 2 * math.pi
		local dist = min_dist + math.random() * (max_dist - min_dist)
		sx, sy = x + dist * math.cos(angle), y + dist * math.sin(angle)
		local dx, dy = sx - ARENA_X, sy - ARENA_Y
		if dx * dx + dy * dy <= ARENA_RADIUS * ARENA_RADIUS then break end
	end
	sx, sy = clamp_to_arena(sx, sy)

	local mob = eq.spawn2(npc_type_id, 0, 0, sx, sy, z, 0):CastToNPC()
	if mob.valid and xeb_state then
		table.insert(xeb_state.adds, {id = mob:GetID(), type = npc_type_id})
	end
	return mob
end

function evt_xeb_spawn(e)
	if not is_unlocked() then
		-- Still locked, or the 72h defeat cooldown is running: go back to
		-- sleep until the next respawn tick.
		e.self:Depop()
		return
	end

	xeb_state = new_state()
	eq.set_next_hp_event(95)
	eq.zone_emote(ZONE_EMOTE_COLOR, "The hourglass inverts. Xebuxoruk, The Forsaken tears free of the timeline and opens his eyes.")
end

function evt_xeb_say(e)
	if e.message:findi("hail") then
		e.self:Say("A reflection... an afterthought... a mote of dust clinging to the hourglass. You dare address ME? I am what he was always meant to be. Come. Let time unmake you.");
	end
end

function evt_xeb_combat(e)
	if e.joined then

		if xeb_state == nil then
			xeb_state = new_state()
			eq.set_next_hp_event(95)
		end
		e.self:Emote("smirks, 'Your time is nearly spent!'")
	else
		eq.stop_all_timers()

		if e.self:GetHP() <= 0 then return end

		show_end_line(WIPE_LINES)
		despawn_adds()
		reset_haste(e.self)
		e.self:SetHP(e.self:GetMaxHP())
		xeb_state = new_state()
		eq.set_next_hp_event(95)
	end
end

function handle_phase1(self, threshold)
	if threshold == 70 then
		enter_phase2(self)
		return
	end

	eq.set_next_hp_event(threshold - 5)

	xeb_state.echo_index = xeb_state.echo_index + 1
	local era = ERA_ORDER[xeb_state.echo_index]
	local pool = ERA_POOLS[era]
	local pick = pool[math.random(#pool)]

	local mob = spawn_near(self, pick[1])
	local top = self:GetHateTop()
	if mob.valid then
		mob:ClearItemList()
		mob:SetNPCFactionID(0)
		mob:SetLevel(ERA_BOSS_LEVEL)
		mob:ModifyNPCStat("max_hp", tostring(ERA_BOSS_HP))
		mob:ModifyNPCStat("min_hit", tostring(ECHO_MIN_HIT))
		mob:ModifyNPCStat("max_hit", tostring(ECHO_MAX_HIT))
		mob:SetHP(mob:GetMaxHP())
		if top.valid then
			mob:AddToHateList(top, 1)
			mob:Say(string.format(ADD_SPEECH, top:GetCleanName()))
		end
	else
		eq.debug("WARNING: failed to spawn " .. pick[2] .. " (" .. era .. ", id " .. pick[1] .. ")")
	end
end

function enter_phase2(self)
	xeb_state.phase = 2
	xeb_state.phase2_ticks = 0
	event_emote(self, "winces, time splinters and echoes...")
	eq.set_timer("phase2_tick", PHASE2_TICK_MS)
	eq.set_next_hp_event(50)
end

function evt_xeb_timer(e)
	if e.timer == "haste_end" then
		reset_haste(e.self)
	elseif xeb_state == nil then

		eq.stop_timer(e.timer)
	elseif e.timer == "phase2_tick" then
		phase2_tick(e.self)
	elseif xeb_state.waves[e.timer] then
		star_timeout(e.self, e.timer)
	else
		eq.stop_timer(e.timer)
	end
end

function phase2_tick(self)
	if xeb_state.phase ~= 2 then
		eq.stop_timer("phase2_tick")
		return
	end

	xeb_state.phase2_ticks = xeb_state.phase2_ticks + 1
	if xeb_state.phase2_ticks % 2 == 1 then
		event_emote(self, "warps and shimmers as time moves backwards.")
		local heal_amt = math.floor(self:GetMaxHP() * PHASE2_HEAL_PCT)
		self:SetHP(math.min(self:GetHP() + heal_amt, self:GetMaxHP()))
	else
		event_emote(self, "blurs as time accelerates.")
		apply_haste(self)
	end
end

function star_timeout(self, timer)
	eq.stop_timer(timer)
	local stars = xeb_state.waves[timer]
	xeb_state.waves[timer] = nil
	if xeb_state.phase ~= 3 then return end

	local survivors = false
	for _, add in ipairs(stars) do
		local star = find_add(add)
		if star then
			survivors = true
			star:Depop()
		end
	end
	if not survivors then return end

	eq.zone_emote(ZONE_EMOTE_COLOR, "Collapsing stars converge and time shatters!")
	converge_damage(self)
end

function enter_phase3(self)
	eq.stop_timer("phase2_tick")
	reset_haste(self)
	xeb_state.phase = 3

	eq.zone_emote(ZONE_EMOTE_COLOR,
		"Time fractures and warps as Xebuxoruk staggers. His wounds disappear and cracks appear in the air around him.")
	self:SetHP(self:GetMaxHP())

	eq.set_next_hp_event(100 - PHASE3_BEAT_PCT)
end

function handle_phase3_beat(self, threshold)
	eq.zone_emote(ZONE_EMOTE_COLOR,
		"Some collapsing stars appear, their furious energy warping time itself!")
	local top = self:GetHateTop()
	xeb_state.star_waves = xeb_state.star_waves + 1
	local timer = "star_wave_" .. xeb_state.star_waves
	local stars = {}
	for _ = 1, STARS_PER_WAVE do
		local star = spawn_near(self, STAR_NPC_TYPE_ID, STAR_MIN_DIST, STAR_MAX_DIST)
		if star.valid then
			table.insert(stars, {id = star:GetID(), type = STAR_NPC_TYPE_ID})
			if top.valid then star:AddToHateList(top, 1) end
		end
	end
	xeb_state.waves[timer] = stars
	eq.set_timer(timer, STAR_TIMEOUT_MS)

	if threshold - PHASE3_BEAT_PCT > 0 then
		eq.set_next_hp_event(threshold - PHASE3_BEAT_PCT)
	end
end

function evt_xeb_hp(e)
	if e.hp_event == nil then return end

	if xeb_state == nil then xeb_state = new_state() end
	local self = e.self

	if xeb_state.phase == 1 then
		handle_phase1(self, e.hp_event)
	elseif xeb_state.phase == 2 and e.hp_event == 50 then
		enter_phase3(self)
	elseif xeb_state.phase == 3 then
		handle_phase3_beat(self, e.hp_event)
	end
end

function evt_xeb_death_complete(e)
	eq.stop_all_timers()
	despawn_adds()
	show_end_line(KILL_LINES)

	-- World-shared 72h defeat cooldown; qglobal expires on its own, so his
	-- next spawn tick after expiry (600s respawn) reactivates him.
	eq.target_global("xebuxoruk_cooldown", "1", "H72", 0, 0, 0)
end

function event_encounter_load(e)
	eq.register_npc_event("xebuxoruk_clone", Event.spawn,          xeb_id, evt_xeb_spawn);
	eq.register_npc_event("xebuxoruk_clone", Event.say,            xeb_id, evt_xeb_say);
	eq.register_npc_event("xebuxoruk_clone", Event.combat,         xeb_id, evt_xeb_combat);
	eq.register_npc_event("xebuxoruk_clone", Event.hp,             xeb_id, evt_xeb_hp);
	eq.register_npc_event("xebuxoruk_clone", Event.timer,          xeb_id, evt_xeb_timer);
	eq.register_npc_event("xebuxoruk_clone", Event.death_complete, xeb_id, evt_xeb_death_complete);
end
