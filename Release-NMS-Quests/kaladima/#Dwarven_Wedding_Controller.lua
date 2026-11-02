-- kaladima/#Dwarven_Wedding_Controller.lua
-- NMS monster mission: the Dwarven Keg Wedding (kaladima v25).
--
-- State machine for the pacifist wedding:
--   * shrouds every expedition member who zones in (>= 5 polls after zone-in,
--     the client's deferred OP_Shroud window) into the Dwarven Keg of Beer 25
--     form (shrouds.id 501, race 377 = Barrel, BRL / brl_ch, neutral). No
--     root: the keg has to waddle around the guild hall to reach the guests.
--   * idle until a keg says "pour the first round" (kaladima/player.lua
--     forwards the phrase as signal 10),
--   * walks the group through five ordered checkpoints:
--       1. Stale Brew  (Malaise 8300)   on the Matron
--       2. Beer Bubbles (Levitate 261) on BOTH uncles
--       3. Pass Out    (Sleep II 7532)  on the Best Man
--       4. Brewmaster's Bidding (Beguile 182) on the Brewmaster
--       5. Keg Blast   (Gale Force 8328) on all seven objectors
--     The checkpoint buffs are also polled, so a pre-cast or a missed script
--     signal still counts.
--   * after checkpoint 4, a larger group gets extra wedding tasks before the
--     objectors, based on the keg count at that moment:
--       2+ Aunts (levitate both), 3+ Father-in-law (malo), 4+ Groom (charm),
--       5+ Bridesmaids (mez both), 6 Grandparents (levitate both).
--   * any wedding-guest death fails instantly (signal 99 from
--     a_wedding_guest.lua, plus the poll's HP/presence check) -- "alcohol kills",
--   * a keg death fails instantly (signal 98 from player.lua, plus the poll),
--   * all seven objectors hit = victory: 18h replay lockout, +30 Brewing and
--     +30 Alcohol Tolerance (capped at 300; a master gets an AA point), then
--     unshroud and ride back to the Bazaar.
--
-- Balance knobs: objector npc_types stats and the RING offsets below.

local KALADIMA_ID   = 60  -- zoneidnumber (canonical), not zone.id
local KEG_VERSION   = 25
local KEG_SHROUD_ID = 501
local KEG_RACE      = 377 -- Barrel (BRL / brl_ch, neutral)
local BAZAAR_ID     = 151
local BAZAAR_HOME   = { x = 185, y = -835, z = 4, h = 390 }
local KEG_CENTER    = { x = 396, y = 44, z = 9 }

local CONTROLLER_ID = 1520001920
local MATRON        = 1520001900
local UNCLE1        = 1520001901
local UNCLE2        = 1520001902
local BEST_MAN      = 1520001903
local BREWMASTER    = 1520001904
local PRIEST        = 1520001905

-- Optional extra-quest guests, spawned by begin_extras() for larger groups.
local AUNT1         = 1520001917
local AUNT2         = 1520001918
local FATHER        = 1520001919
local GROOM         = 1520001921
local BRIDE1        = 1520001922
local BRIDE2        = 1520001923
local GRAND1        = 1520001924
local GRAND2        = 1520001925

local GUEST_TYPES = {
	MATRON, UNCLE1, UNCLE2, BEST_MAN, BREWMASTER, PRIEST,
	1520001906, 1520001907, 1520001908, 1520001909,
}

local OBJECTOR_TYPES = {
	1520001910, 1520001911, 1520001912, 1520001913,
	1520001914, 1520001915, 1520001916,
}

local GUEST_LOOKUP = {}
for _, t in ipairs(GUEST_TYPES) do
	GUEST_LOOKUP[t] = true
end

local MALAISE    = 8300 -- Stale Brew (malo)
local LEVITATE   = 261  -- Beer Bubbles (single-target Levitate)
local SLEEP      = 7532 -- Pass Out
local CHARM      = 182  -- Brewmaster's Bidding
local CHARM_ALT  = 300
local GALE_FORCE = 8328 -- Keg Blast

local BREWING_SKILL = 65
local ALCOHOL_SKILL = 66
local SKILL_CAP     = 300

local SIGNAL_MATRON          = 1
local SIGNAL_UNCLE1          = 2
local SIGNAL_UNCLE2          = 3
local SIGNAL_BEST_MAN        = 4
local SIGNAL_BREWMASTER      = 5
local SIGNAL_START           = 10
local SIGNAL_OBJECTOR_BASE   = 20
local SIGNAL_PLAYER_DEATH    = 98
local SIGNAL_GUEST_DEATH     = 99

local POLL_MS            = 1000
local SHROUD_TICKS       = 5
local OBJECTOR_DELAY_MS  = 3000
local SEND_HOME_MS       = 10000
local FAIL_KICK_MS       = 5000

local RING = {
	{  18,   0 }, {   0,  18 }, { -18,   0 }, {   0, -18 },
	{  13,  13 }, { -13,  13 }, {  13, -13 },
}

-- One extra wedding task per additional keg, in order. Each task names the NPC
-- types it needs, the spell that settles them, the guest-script signals, and
-- the spawn points used when the task begins (the guests are dynamic).
local EXTRA_TASKS = {
	{
		name = "the Aunts", npcs = { AUNT1, AUNT2 }, spell = LEVITATE,
		signals = { 30, 31 },
		spawns = { { 380, 28, 9, 0 }, { 412, 28, 9, 0 } },
		instruction = "The Aunts are too excited to stay on the floor. Cast Beer Bubbles (levitate) on BOTH Aunts.",
		say = "Aunt Hilde: I am already floating on the inside!",
	},
	{
		name = "the Father-in-law", npcs = { FATHER }, spell = MALAISE,
		signals = { 32 },
		spawns = { { 396, 64, 9, 0 } },
		instruction = "The Father-in-law is warded against the priest. Cast Stale Brew (malo) on him.",
		say = "Father-in-law Grund: No priest is blessing me while these wards hold!",
	},
	{
		name = "the Groom", npcs = { GROOM }, spell = CHARM,
		signals = { 33 },
		spawns = { { 396, 48, 9, 192 } },
		instruction = "The Groom is getting cold feet. Cast Brewmaster's Bidding (charm) on him before he runs.",
		say = "the Groom: I... I need some air. And a horse. And a head start.",
	},
	{
		name = "the Bridesmaids", npcs = { BRIDE1, BRIDE2 }, spell = SLEEP,
		signals = { 34, 35 },
		spawns = { { 378, 46, 9, 0 }, { 414, 46, 9, 0 } },
		instruction = "The Bridesmaids are hysterical. Cast Pass Out (mez) on BOTH of them.",
		say = "Bridesmaid Inga: Oh, the horror! The horror of it all!",
	},
	{
		name = "the Grandparents", npcs = { GRAND1, GRAND2 }, spell = LEVITATE,
		signals = { 36, 37 },
		spawns = { { 384, 66, 9, 0 }, { 408, 66, 9, 0 } },
		instruction = "The Grandparents cannot dance. Cast Beer Bubbles (levitate) on BOTH of them.",
		say = "Grandfather Odin: My old feet have not left the floor in forty years!",
	},
}

-- state: idle -> phase1 -> phase2 -> phase3 -> phase4 -> phase4_done ->
--        extras -> extras_done -> phase5 -> won / failed
local state              = "idle"
local seen_ticks         = {} -- char_id -> polls seen while unshrouded
local prepared           = {} -- char_id -> true once the keg form is on
local guests_ready       = false
local objectors_spawned  = false
local objector_hits      = {}
local uncle1_lev         = false
local uncle2_lev         = false
local extra_tasks        = 0
local extra_phase        = 0
local extra_hits         = {}
local poll_count         = 0

local function members_in_zone()
	local members = {}
	local clients = eq.get_entity_list():GetClientList()
	for client in clients.entries do
		if client.valid then
			local dz = client:GetExpedition()
			if dz.valid
				and dz:GetZoneID() == KALADIMA_ID
				and dz:GetZoneVersion() == KEG_VERSION then
				table.insert(members, client)
			end
		end
	end
	return members
end

local function kegs_in_zone(members)
	local kegs = {}
	for _, client in ipairs(members) do
		if client:GetRace() == KEG_RACE then
			table.insert(kegs, client)
		end
	end
	return kegs
end

local function find_npc(npc_type)
	return eq.get_entity_list():GetMobByNpcTypeID(npc_type)
end

local function say_npc(npc_type, text)
	local npc = find_npc(npc_type)
	if npc and npc.valid then
		npc:Say(text)
	end
end

local function depop_objectors()
	for _, npc_type in ipairs(OBJECTOR_TYPES) do
		eq.depop(npc_type)
	end
end

local function dismiss_pets(client)
	local pet = client:GetPet()
	if pet and pet.valid then
		pet:Depop()
	end
end

local function send_home(members)
	for _, client in ipairs(members) do
		client:MovePC(BAZAAR_ID, BAZAAR_HOME.x, BAZAAR_HOME.y, BAZAAR_HOME.z, BAZAAR_HOME.h)
	end
end

local function grant_reward(client)
	local brewing = client:GetSkill(BREWING_SKILL) or 0
	local alcohol = client:GetSkill(ALCOHOL_SKILL) or 0
	local bgain = math.min(30, math.max(0, SKILL_CAP - brewing))
	local again = math.min(30, math.max(0, SKILL_CAP - alcohol))

	if bgain > 0 then
		client:SetSkill(BREWING_SKILL, brewing + bgain)
	end
	if again > 0 then
		client:SetSkill(ALCOHOL_SKILL, alcohol + again)
	end

	if bgain == 0 and again == 0 then
		client:AddAAPoints(1)
		client:Message(15, "Dorgan's voice echoes from the Bazaar: 'You are already a master of the keg -- there is nothing left to teach you. Take an ability point instead.'")
	else
		client:Message(15, string.format(
			"Dorgan's voice echoes from the Bazaar: 'Magnificent! You have learned %d points of Brewing (now %d/%d) and %d points of Alcohol Tolerance (now %d/%d).'",
			bgain, brewing + bgain, SKILL_CAP, again, alcohol + again, SKILL_CAP))
	end
end

local function fail(reason)
	if state == "won" or state == "failed" then
		return
	end
	state = "failed"
	depop_objectors()

	-- Release a charmed brewmaster so the fail cleanup cannot leave a pet
	-- running around the instance for the five second boot delay.
	local brew = find_npc(BREWMASTER)
	if brew and brew.valid then
		brew:BuffFadeBySpellID(CHARM)
		brew:BuffFadeBySpellID(CHARM_ALT)
	end

	eq.zone_emote(MT.Red, "The Dwarven Keg Wedding has FAILED. " .. reason)
	for _, client in ipairs(members_in_zone()) do
		client:SendMarqueeMessage(MT.Red, 255, 1000, 1500, 4000, "THE WEDDING IS RUINED")
		client:Message(MT.Red, "THE DWARVEN KEG WEDDING HAS FAILED.")
		client:Message(MT.Red, reason)
		client:SendSound()
		-- Only strip the keg shroud's own buff coat; a late-joining group
		-- member who never got shrouded should keep their real buffs.
		if client:GetRace() == KEG_RACE then
			client:BuffFadeAll()
		end
		client:RemoveShroud()
	end

	eq.set_timer("keg_fail_kick", FAIL_KICK_MS)
end

local function win()
	if state == "won" or state == "failed" then
		return
	end

	-- A dying keg must not win on a signal that raced the death poll.
	local kegs = kegs_in_zone(members_in_zone())
	local alive = false
	for _, keg in ipairs(kegs) do
		if keg:GetHP() > 0 then
			alive = true
			break
		end
	end
	if not alive then
		fail("The keg has been spilled. The wedding cannot continue.")
		return
	end

	state = "won"
	depop_objectors()

	local exp = eq.get_expedition()
	if exp.valid then
		exp:AddReplayLockout(eq.seconds("18h"))
	end

	eq.zone_emote(15, "The seven objectors are blown clean out of the hall. The Priest of Brell pronounces the union. The keg has saved the wedding!")
	for _, client in ipairs(kegs) do
		client:BuffFadeAll()
		client:RemoveShroud()
		grant_reward(client)
	end

	eq.set_timer("keg_send_home", SEND_HOME_MS)
end

local function apply_keg(client)
	dismiss_pets(client)
	client:ApplyShroud(KEG_SHROUD_ID)
	if client:GetRace() ~= KEG_RACE then
		client:Message(MT.Red, "The keg form refuses you. You must be at least level 25.")
		return
	end
	client:BuffFadeAll()
	dismiss_pets(client)
	client:Message(15, "You are the keg now -- a dwarven keg of beer, tapped and ready. Open your AA window (V) and spend your monster points on the keg's gifts. When you are ready, say 'pour the first round'.")
end

local function start_phase1()
	state = "phase1"
	uncle1_lev = false
	uncle2_lev = false
	eq.zone_emote(15, "The Priest of Brell raises his hands. The Matron's wards swallow the blessing.")
	say_npc(PRIEST, "Brell's light cannot reach her through those wards!")
	say_npc(MATRON, "These old wards have kept me safe for a century. They will not yield to a keg.")
	for _, client in ipairs(kegs_in_zone(members_in_zone())) do
		client:Message(15, "CHECKPOINT 1/5: The Matron's wards are too strong. Cast Stale Brew (malo) on the Matron so the priest's spells can take hold.")
	end
end

local function complete_phase1()
	if state ~= "phase1" then
		return
	end
	state = "phase2"
	uncle1_lev = false
	uncle2_lev = false
	eq.zone_emote(15, "The Matron's wards fall. The priest's blessing takes hold.")
	say_npc(PRIEST, "The wards are down! Brell's blessing flows!")
	say_npc(MATRON, "Well. About time someone brought a proper keg.")
	for _, client in ipairs(kegs_in_zone(members_in_zone())) do
		client:Message(15, "CHECKPOINT 1/5 complete. CHECKPOINT 2/5: The uncles are too heavy-footed to dance. Cast Beer Bubbles (levitate) on BOTH uncles.")
	end
end

local function complete_phase2()
	if state ~= "phase2" then
		return
	end
	state = "phase3"
	eq.zone_emote(15, "Both uncles drift off the floor, giggling.")
	say_npc(UNCLE1, "I can see the ceiling!")
	say_npc(UNCLE2, "I can see the ceiling too!")
	for _, client in ipairs(kegs_in_zone(members_in_zone())) do
		client:Message(15, "CHECKPOINT 2/5 complete. CHECKPOINT 3/5: The Best Man is winding up for a speech. Cast Pass Out (mez) on him.")
	end
end

local function complete_phase3()
	if state ~= "phase3" then
		return
	end
	state = "phase4"
	eq.zone_emote(15, "The Best Man's speech dies in a snore.")
	say_npc(BEST_MAN, "I have known Hilda since... since... zzz...")
	for _, client in ipairs(kegs_in_zone(members_in_zone())) do
		client:Message(15, "CHECKPOINT 3/5 complete. CHECKPOINT 4/5: The Brewmaster refuses to tap the keg. Cast Brewmaster's Bidding (charm) on him.")
	end
end

local function complete_phase4()
	if state ~= "phase4" then
		return
	end
	state = "phase4_done"

	local brew = find_npc(BREWMASTER)
	if brew and brew.valid then
		brew:BuffFadeBySpellID(CHARM)
		brew:BuffFadeBySpellID(CHARM_ALT)
		brew:Say("Aye... aye, I'll tap it. Just... stop looking at me like that.")
	end

	eq.zone_emote(15, "The Brewmaster stumps over to the keg and drives the tap home.")
	for _, client in ipairs(kegs_in_zone(members_in_zone())) do
		client:Message(15, "CHECKPOINT 4/5 complete. The tap is in!")
	end

	eq.set_timer("keg_after_brewmaster", OBJECTOR_DELAY_MS)
end

local function spawn_objectors()
	objectors_spawned = true
	objector_hits = {}
	local kegs = kegs_in_zone(members_in_zone())
	for i, npc_type in ipairs(OBJECTOR_TYPES) do
		local off = RING[i]
		local mob = eq.spawn2(npc_type, 0, 0, KEG_CENTER.x + off[1], KEG_CENTER.y + off[2], KEG_CENTER.z, 0)
		if mob and mob.valid then
			for _, keg in ipairs(kegs) do
				mob:AddToHateList(keg, 100, 0)
			end
		end
	end
end

local function start_objectors()
	if state ~= "phase4_done" and state ~= "extras_done" then
		return
	end
	state = "phase5"
	spawn_objectors()
	eq.zone_emote(15, "The hall doors bang open. Seven dwarves storm in, objecting to the union!")
	for _, client in ipairs(kegs_in_zone(members_in_zone())) do
		client:Message(15, "CHECKPOINT 5/5: Seven objectors! Hit each of them with Keg Blast (Gale Force). Do NOT kill anyone -- a dead guest ends the wedding.")
	end
end

local function spawn_extra_npcs(task)
	for i, npc_type in ipairs(task.npcs) do
		if not find_npc(npc_type) then
			local s = task.spawns[i]
			eq.spawn2(npc_type, 0, 0, s[1], s[2], s[3], s[4] or 0)
		end
	end
end

local function instruct_extra(phase)
	local task = EXTRA_TASKS[phase]
	if not task then
		return
	end
	extra_phase = phase
	extra_hits[phase] = {}
	spawn_extra_npcs(task)
	eq.zone_emote(15, "The wedding needs more than a keg: settle " .. task.name .. ".")
	for _, client in ipairs(kegs_in_zone(members_in_zone())) do
		client:Message(15, string.format("EXTRA CHECKPOINT %d/%d: %s", phase, extra_tasks, task.instruction))
	end
	for _, npc_type in ipairs(task.npcs) do
		say_npc(npc_type, task.say)
	end
end

local function complete_extra(phase)
	if state ~= "extras" or phase ~= extra_phase then
		return
	end
	local task = EXTRA_TASKS[phase]

	if task.spell == CHARM then
		for _, npc_type in ipairs(task.npcs) do
			local npc = find_npc(npc_type)
			if npc and npc.valid then
				npc:BuffFadeBySpellID(CHARM)
				npc:BuffFadeBySpellID(CHARM_ALT)
			end
		end
	end

	eq.zone_emote(15, string.format("EXTRA CHECKPOINT %d/%d complete: %s settled.", phase, extra_tasks, task.name))
	if phase < extra_tasks then
		instruct_extra(phase + 1)
	else
		state = "extras_done"
		eq.zone_emote(15, "The last extra guest is settled. The hall turns as one...")
		eq.set_timer("keg_objectors", OBJECTOR_DELAY_MS)
	end
end

local function handle_extra_signal(sig)
	if state ~= "extras" then
		return
	end
	local task = EXTRA_TASKS[extra_phase]
	for _, s in ipairs(task.signals) do
		if s == sig then
			extra_hits[extra_phase][sig] = true
			local count = 0
			for _ in pairs(extra_hits[extra_phase]) do
				count = count + 1
			end
			if count >= #task.signals then
				complete_extra(extra_phase)
			end
			return
		end
	end
end

local function begin_extras()
	if state ~= "phase4_done" then
		return
	end
	local kegs = kegs_in_zone(members_in_zone())
	if #kegs == 0 then
		return
	end
	extra_tasks = math.min(#kegs - 1, #EXTRA_TASKS)
	if extra_tasks <= 0 then
		start_objectors()
		return
	end
	state = "extras"
	extra_phase = 1
	eq.zone_emote(15, "The ceremony is not over yet. The wedding has more guests to settle.")
	instruct_extra(1)
end

local function scan_guests()
	local seen = {}
	local dead = false
	local npcs = eq.get_entity_list():GetNPCList()
	for npc in npcs.entries do
		if npc.valid then
			local t = npc:GetNPCTypeID()
			if GUEST_LOOKUP[t] then
				if npc:GetHP() <= 0 then
					dead = true
				end
				seen[t] = true
			end
		end
	end
	return seen, dead
end

function event_spawn(e)
	state             = "idle"
	seen_ticks        = {}
	prepared          = {}
	guests_ready      = false
	objectors_spawned = false
	objector_hits     = {}
	uncle1_lev        = false
	uncle2_lev        = false
	extra_tasks       = 0
	extra_phase       = 0
	extra_hits        = {}
	poll_count        = 0
	eq.set_timer("keg_poll", POLL_MS)
end

function event_signal(e)
	if state == "won" or state == "failed" then
		return
	end

	if e.signal == SIGNAL_START then
		if state ~= "idle" then
			return
		end
		if not guests_ready then
			for _, client in ipairs(kegs_in_zone(members_in_zone())) do
				client:Message(15, "The wedding party is still gathering. Give them a moment, then say 'pour the first round' again.")
			end
			return
		end
		if #kegs_in_zone(members_in_zone()) == 0 then
			return
		end
		start_phase1()
	elseif e.signal == SIGNAL_MATRON then
		if state == "phase1" then
			complete_phase1()
		end
	elseif e.signal == SIGNAL_UNCLE1 then
		if state == "phase2" then
			uncle1_lev = true
			if uncle2_lev then
				complete_phase2()
			end
		end
	elseif e.signal == SIGNAL_UNCLE2 then
		if state == "phase2" then
			uncle2_lev = true
			if uncle1_lev then
				complete_phase2()
			end
		end
	elseif e.signal == SIGNAL_BEST_MAN then
		if state == "phase3" then
			complete_phase3()
		end
	elseif e.signal == SIGNAL_BREWMASTER then
		if state == "phase4" then
			complete_phase4()
		end
	elseif e.signal >= 30 and e.signal <= 37 then
		handle_extra_signal(e.signal)
	elseif e.signal >= SIGNAL_OBJECTOR_BASE and e.signal <= SIGNAL_OBJECTOR_BASE + 6 then
		if state == "phase5" then
			objector_hits[e.signal - SIGNAL_OBJECTOR_BASE] = true
			local count = 0
			for i = 0, 6 do
				if objector_hits[i] then
					count = count + 1
				end
			end
			if count == 7 then
				win()
			end
		end
	elseif e.signal == SIGNAL_PLAYER_DEATH then
		fail("The keg has been spilled. The wedding cannot continue.")
	elseif e.signal == SIGNAL_GUEST_DEATH then
		fail("A wedding guest has been killed. Alcohol kills.")
	end
end

function event_timer(e)
	if e.timer == "keg_poll" then
		if state == "won" or state == "failed" then
			return
		end
		poll_count = poll_count + 1

		local members = members_in_zone()
		if #members == 0 then
			return
		end
		local kegs = kegs_in_zone(members)

		-- A dead expedition member fails the wedding on the spot (backup for
		-- player.lua's event_death, which routes to the same fail path).
		for _, client in ipairs(members) do
			if client:GetHP() <= 0 then
				client:BuffFadeAll()
				client:RemoveShroudSilent()
				fail("The keg has been spilled. The wedding cannot continue.")
				return
			end
		end

		-- Shroud members after a 5 poll settle window, then coat the real
		-- character's buffs away. A persisted keg (logged out during the
		-- mission) is prepared once on zone-in.
		for _, client in ipairs(members) do
			local id = client:CharacterID()
			if client:GetRace() ~= KEG_RACE then
				seen_ticks[id] = (seen_ticks[id] or 0) + 1
				if seen_ticks[id] >= SHROUD_TICKS then
					seen_ticks[id] = nil
					apply_keg(client)
					prepared[id] = true
				end
			else
				seen_ticks[id] = nil
				if not prepared[id] then
					prepared[id] = true
					dismiss_pets(client)
					client:BuffFadeAll()
					client:Message(15, "You are the keg now -- a dwarven keg of beer, tapped and ready. Open your AA window (V) and spend your monster points on the keg's gifts. When you are ready, say 'pour the first round'.")
				end
			end
		end

		-- Pacifism: any guest death or disappearance ends the wedding.
		local seen, dead = scan_guests()
		if dead then
			fail("A wedding guest has been killed. Alcohol kills.")
			return
		end
		if not guests_ready then
			local all = true
			for _, t in ipairs(GUEST_TYPES) do
				if not seen[t] then
					all = false
					break
				end
			end
			if all then
				guests_ready = true
			end
		else
			for _, t in ipairs(GUEST_TYPES) do
				if not seen[t] then
					fail("A wedding guest has vanished from the hall.")
					return
				end
			end
		end

		-- Checkpoint poll (backup for a missed script signal or a pre-cast).
		if state == "phase1" then
			local matron = find_npc(MATRON)
			if matron and matron.valid and matron:FindBuff(MALAISE) then
				complete_phase1()
			end
		elseif state == "phase2" then
			local u1 = find_npc(UNCLE1)
			local u2 = find_npc(UNCLE2)
			if u1 and u2 and u1.valid and u2.valid and u1:FindBuff(LEVITATE) and u2:FindBuff(LEVITATE) then
				complete_phase2()
			end
		elseif state == "phase3" then
			local best = find_npc(BEST_MAN)
			if best and best.valid and best:FindBuff(SLEEP) then
				complete_phase3()
			end
		elseif state == "phase4" then
			local brew = find_npc(BREWMASTER)
			if brew and brew.valid and brew:FindBuff(CHARM) then
				complete_phase4()
			end
		elseif state == "extras" then
			local task = EXTRA_TASKS[extra_phase]
			local all = true
			for _, npc_type in ipairs(task.npcs) do
				local npc = find_npc(npc_type)
				if not (npc and npc.valid and npc:FindBuff(task.spell)) then
					all = false
					break
				end
			end
			if all then
				complete_extra(extra_phase)
			end
		elseif state == "phase5" and objectors_spawned then
			for _, npc_type in ipairs(OBJECTOR_TYPES) do
				local npc = find_npc(npc_type)
				if npc and npc.valid then
					for _, keg in ipairs(kegs) do
						npc:AddToHateList(keg, 100, 0)
					end
				end
			end
		end

		if state == "idle" and poll_count % 30 == 0 and #kegs > 0 then
			say_npc(PRIEST, "When the keg is ready, the ceremony begins.")
		end
	elseif e.timer == "keg_after_brewmaster" then
		begin_extras()
	elseif e.timer == "keg_objectors" then
		start_objectors()
	elseif e.timer == "keg_send_home" then
		depop_objectors()
		send_home(members_in_zone())
		eq.depop()
	elseif e.timer == "keg_fail_kick" then
		local exp = eq.get_expedition()
		if exp.valid then
			exp:SetLocked(true, 2)
			exp:RemoveAllMembers()
		end
		eq.depop()
	end
end
