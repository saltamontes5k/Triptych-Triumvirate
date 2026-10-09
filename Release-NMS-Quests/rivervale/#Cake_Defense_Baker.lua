-- rivervale/#Cake_Defense_Baker.lua
-- NMS test monster mission: the Fool's Gold Cake Defense (rivervale v202).
-- Wave state machine for the birthday-cake defense:
--   * shrouds every expedition member who zones in (>= 5s after zone-in, the
--     client's deferred OP_Shroud window) into the Birthday Cake 25 form, then
--     coats them in "Sticky Icing" (121870, flavour/slow) AND roots them with
--     "Parsing Root" (13836) -- the real immobilizer, since a speed debuff is
--     floored around -85% and cannot actually stop the client. Both are recast
--     if they ever fade and stripped on win/fail/death,
--   * waits indefinitely -- there is no prep timer; the defense starts when a
--     member says "I am delicious" (rivervale/player.lua forwards the phrase),
--   * then sends three waves of hungry adventurers in a ring around the cakes
--     (four per wave for a solo cake, +1 per extra cake; npc_aggro 1 makes
--     them charge and the poll re-fixates as a backup), with a one-minute
--     pause between waves,
--   * all three waves cleared = victory (18h replay lockout, +30 baking skill
--     while under the cap -- maxed bakers still get the flavour line --
--     unshroud, ride back to the Bazaar),
--   * a member death fails the defense instantly -- detected by the poll
--     itself (GetHP <= 0) and by event_death in rivervale/player.lua; the
--     dead player's icing is stripped so the bind release is their real self.
-- Balance knobs: WAVE_SIZE_BASE / WAVE_SIZE_MULT (wave size), the npc_types
-- stats (v121), INTERWAVE_MS (pause between waves) below.

local CAKE_VERSION   = 202
local CAKE_SHROUD_ID = 500
local RIVERVALE_ID   = 19 -- zoneidnumber (canonical), not zone.id
local STICKY_ICING   = 121870
-- The actual immobilizer. Sticky Icing is only a -7000% SE_MovementSpeed snare
-- (SPA 3): mob.cpp _GetRunSpeed floors a snare at -85% and the RoF2 client does
-- the same, so the cake could still crawl. "Parsing Root" (13836) is a stock
-- BENEFICIAL, unresistable, PERMANENT SE_Root (SPA 99). It roots the client
-- outright, cannot break on damage (TryRootFadeByDamage only runs for
-- detrimental roots) and cannot break on the per-tick player root check
-- (resisttype 0 -> ResistSpell returns 100). It already exists in the client's
-- spells_us.txt, so unlike a new/edited spell it needs no export or
-- shared-memory regen.
local CAKE_ROOT      = 13836 -- Parsing Root (beneficial unresistable perma-root)

local CAKE_CENTER = { x = -134, y = -61, z = 3 } -- outside the Fool's Gold

local WAVE_NPC_IDS = { 1520001810, 1520001811, 1520001812 } -- peckish/famished/ravenous
local WAVE_SIZE_BASE = 3          -- base adventurers per wave = 3 + cakes present
local WAVE_SIZE_MULT = 1          -- tuned: 4 adventurers for a solo cake
local RING_OFFSETS   = {
	{  35,   0 }, {   0,  35 }, { -35,   0 }, {   0, -35 },
	{  25,  25 }, { -25,  25 }, {  25, -25 }, { -25, -25 },
	{  35,  15 }, {  35, -15 }, { -35,  15 }, { -35, -15 },
	{  15,  35 }, { -15,  35 }, {  15, -35 }, { -15, -35 },
}

local INTERWAVE_MS = eq.seconds("60s") * 1000 -- one minute between waves
local POLL_MS      = 5000
local SEND_HOME_MS = eq.seconds("10s") * 1000

local BAZAAR_ID     = 151
local BAZAAR_HOME   = { x = 185, y = -835, z = 4, h = 390 }
local BAKING_SKILL  = 56
local BAKING_CAP    = 300

-- Maxed-baker booby prize: the skill reward is capped, so a master baker
-- gets an ability point plus a full stack of a random baking component.
local BOOBY_PRIZES = {
	{ id = 13046, stack = 100, name = "fruit" },      -- Fruit
	{ id = 13088, stack = 100, name = "snake eggs" }, -- Snake Egg
}

-- The baker's idle wisdom. Says one on every SAY_EVERY_N_POLLS-th poll while
-- the defense hasn't started.
local BAKER_LINES = {
	"Become one with the dough, little ones. Let the frosting guide you.",
	"I am a tiny cake. You are a tiny cake. Together, we are a bakery.",
	"The oven of destiny bakes us all, my crumbly friends.",
	"Do not fear the fork. Fear only a life without sprinkles.",
	"When your party is ready, declare your deliciousness. The oven hears all.",
}
local SAY_EVERY_N_POLLS = 6 -- ~30s

-- state: "idle" (waiting for the ready phrase) -> "wave" (n = 1..3) ->
-- "prep" (inter-wave pause) -> "won" / "failed"
local state = "idle"
local wave  = 0
local seen_unshrouded = {} -- char_id -> true (present last poll)
local prepared = {}        -- char_id -> true once icing/root are applied
local poll_count = 0

local function wave_npcs_alive()
	local count = 0
	local npcs = eq.get_entity_list():GetNPCList()
	for npc in npcs.entries do
		if npc.valid and wave > 0 and npc:GetNPCTypeID() == WAVE_NPC_IDS[wave] then
			count = count + 1
		end
	end
	return count
end

-- expedition members currently in this zone (cakes in waiting and in the fight)
local function members_in_zone()
	local members = {}
	local clients = eq.get_entity_list():GetClientList()
	for client in clients.entries do
		if client.valid then
			local dz = client:GetExpedition()
			if dz.valid
				and dz:GetZoneID() == RIVERVALE_ID
				and dz:GetZoneVersion() == CAKE_VERSION then
				table.insert(members, client)
			end
		end
	end
	return members
end

local function cakes_in_zone(members)
	local cakes = {}
	for _, client in ipairs(members) do
		if client:GetRace() == 629 then
			table.insert(cakes, client)
		end
	end
	return cakes
end

local function send_home(members)
	for _, client in ipairs(members) do
		client:MovePC(BAZAAR_ID, BAZAAR_HOME.x, BAZAAR_HOME.y, BAZAAR_HOME.z, BAZAAR_HOME.h)
	end
end

local function cleanup_waves()
	for _, id in ipairs(WAVE_NPC_IDS) do
		eq.depop(id)
	end
end

local function spawn_wave()
	local cakes = cakes_in_zone(members_in_zone())
	local count = math.min((WAVE_SIZE_BASE + #cakes) * WAVE_SIZE_MULT, #RING_OFFSETS)
	local tier  = WAVE_NPC_IDS[wave]
	eq.zone_emote(15, string.format("Wave %d: hungry adventurers crest the hill, eyes fixed on the cakes!", wave))
	for i = 1, count do
		local off = RING_OFFSETS[i]
		eq.spawn2(tier, 0, 0, CAKE_CENTER.x + off[1], CAKE_CENTER.y + off[2], CAKE_CENTER.z, 0)
	end
end

local function strip_icing(client)
	client:BuffFadeBySpellID(CAKE_ROOT)
	client:BuffFadeBySpellID(STICKY_ICING)
end

-- Instant fail: waves pulled, icing off, unshroud, everyone home. Any member
-- death routes here (poll detection or rivervale/player.lua event_death).
local function fail_defense()
	state = "failed"
	cleanup_waves()
	eq.zone_emote(15, "A cake has been eaten. The Fool's Gold Cake Defense is LOST -- the hungry adventurers of Rivervale drag the crumbs off toward the tavern.")
	for _, client in ipairs(members_in_zone()) do
		-- Deliver the failure first: RemoveShroud re-sends the profile and can
		-- wipe chat that is still pending for a client that just died.
		client:Message(15, "The Cake Defense has FAILED -- a cake has been eaten. There is no replay lockout this time; regroup, rebuy your abilities and try again.")
		strip_icing(client)
		client:RemoveShroud()
	end
	eq.set_timer("cake_send_home", SEND_HOME_MS)
	local exp = eq.get_expedition()
	if exp.valid then
		exp:SetLocked(true, 2) -- lock so late joiners can't wander in
	end
end

function event_spawn(e)
	state = "idle"
	wave  = 0
	seen_unshrouded = {}
	prepared = {}
	poll_count = 0
	eq.set_timer("cake_poll", POLL_MS)
end

function event_signal(e)
	if e.signal == 1 and state == "idle" then
		-- a member said "I am delicious" (forwarded by rivervale/player.lua)
		state = "wave"
		wave  = 1
		eq.zone_emote(15, "The cakes have declared their deliciousness. The hungry adventurers of Rivervale take that personally.")
		spawn_wave()
	elseif e.signal == 2 and (state == "prep" or state == "wave") then
		fail_defense()
	end
end

function event_timer(e)
	if e.timer == "cake_poll" then
		if state == "failed" or state == "won" then
			return
		end
		poll_count = poll_count + 1

		local members = members_in_zone()

		-- A dead expedition member fails the defense on the spot (backup for
		-- event_death, which routes to the same fail path).
		for _, client in ipairs(members) do
			if client:GetHP() <= 0 then
				strip_icing(client)
				client:RemoveShroudSilent()
				fail_defense()
				return
			end
		end

		local cakes = cakes_in_zone(members)

		-- Shroud members who were already present last poll (guarantees the
		-- 5s zone-settle window before OP_Shroud flies), then coat them in
		-- Sticky Icing, then rooted with Parsing Root. Both are recast if they fade.
		-- Drop prepared markers for characters who left the instance so a
		-- later re-entry is treated as a fresh shroud session.
		local present = {}
		for _, client in ipairs(members) do present[client:CharacterID()] = true end
		for cid in pairs(prepared) do if not present[cid] then prepared[cid] = nil end end

		for _, client in ipairs(members) do
			local id = client:CharacterID()
			if client:GetRace() ~= 629 then
				if seen_unshrouded[id] then
					client:ApplyShroud(CAKE_SHROUD_ID)
					-- Live-like: the shroud strips the real character's buffs
					-- (their damage shields / haste / speed buffs would ride
					-- along otherwise), then the icing goes on alone.
					client:BuffFadeAll()
					local ok_icing = e.self:CastSpell(STICKY_ICING, client:GetID())
					local ok_root  = e.self:CastSpell(CAKE_ROOT, client:GetID())
					prepared[id] = true
					eq.debug(string.format("[cake] fresh %s: icing=%s root=%s castIcing=%s castRoot=%s",
						client:GetName(), tostring(client:FindBuff(STICKY_ICING)), tostring(client:FindBuff(CAKE_ROOT)),
						tostring(ok_icing), tostring(ok_root)))
					client:Message(15, "Sugar crust hardens over you. You are the cake now -- delicious, immobile, and defended only by your wits. Take your time buying abilities; when your party is ready, say 'I am delicious' and the feast begins.")
					seen_unshrouded[id] = nil
				else
					seen_unshrouded[id] = true
				end
			else
				seen_unshrouded[id] = nil
				if not prepared[id] then
					-- Persisted shroud: the character logged out as a cake, so
					-- LoadAndApplyShroudState already re-applied race 629 and the
					-- apply path above never runs. Strip the real buffs and coat/
					-- root here so a persisted cake is prepared exactly once.
					prepared[id] = true
					client:BuffFadeAll()
					local ok_icing = e.self:CastSpell(STICKY_ICING, client:GetID())
					local ok_root  = e.self:CastSpell(CAKE_ROOT, client:GetID())

					eq.debug(string.format("[cake] persisted %s: icing=%s root=%s castIcing=%s castRoot=%s",
						client:GetName(), tostring(client:FindBuff(STICKY_ICING)), tostring(client:FindBuff(CAKE_ROOT)),
						tostring(ok_icing), tostring(ok_root)))
				else
					local need_icing = not client:FindBuff(STICKY_ICING)
					local need_root  = not client:FindBuff(CAKE_ROOT)
					if need_icing then
						e.self:CastSpell(STICKY_ICING, client:GetID())
					end
					if need_root then
						e.self:CastSpell(CAKE_ROOT, client:GetID())
					end
					if need_icing or need_root then
						eq.debug(string.format("[cake] recast %s: needed icing=%s root=%s -> icing=%s root=%s",
							client:GetName(), tostring(need_icing), tostring(need_root),
							tostring(client:FindBuff(STICKY_ICING)), tostring(client:FindBuff(CAKE_ROOT))))
					end
				end
			end
		end

		-- Idle chatter from the baker.
		if state == "idle" and poll_count % SAY_EVERY_N_POLLS == 0 and #cakes > 0 then
			e.self:Say(BAKER_LINES[math.random(1, #BAKER_LINES)])
		end

		if state == "wave" then
			-- backup fixation: keep the wave on the cakes even if natural
			-- aggro loses them
			local npcs = eq.get_entity_list():GetNPCList()
			for npc in npcs.entries do
				if npc.valid and npc:GetNPCTypeID() == WAVE_NPC_IDS[wave] then
					for _, cake in ipairs(cakes) do
						npc:AddToHateList(cake, 100, 0)
					end
				end
			end
			if wave_npcs_alive() == 0 then
				local cleared = wave
				wave = wave + 1
				if wave > 3 then
					state = "won"
					local exp = eq.get_expedition()
					if exp.valid then
						exp:AddReplayLockout(eq.seconds("18h"))
					end
					eq.zone_emote(15, "The last adventurer staggers away, unbearably full. The cake has survived the Fool's Gold Cake Defense!")
					for _, cake in ipairs(cakes) do
						strip_icing(cake)
						cake:RemoveShroud()
						local skill = cake:GetSkill(BAKING_SKILL)
						if skill < BAKING_CAP then
							local gain = math.min(30, BAKING_CAP - skill)
							cake:IncreaseSkill(BAKING_SKILL, gain)
							cake:Message(15, string.format("Wendel's voice echoes from the Bazaar: 'Magnificent! You have learned %d points of baking you will never get from a book.'", gain))
						else
							-- Maxed baking: the skill reward is capped, so hand out the booby
							-- prize instead -- an ability point and a full stack of a random
							-- baking component (fruit or snake eggs).
							local prize = BOOBY_PRIZES[math.random(1, #BOOBY_PRIZES)]
							cake:AddAAPoints(1)
							cake:SummonItem(prize.id, prize.stack)
							cake:Message(15, string.format("Wendel's voice echoes from the Bazaar: 'Magnificent! You bake like a god already -- there is nothing left for me to teach you, so take this instead: a stack of %s and a lesson in ability. You have learned much about baking today.'", prize.name))
						end
					end
					eq.set_timer("cake_send_home", SEND_HOME_MS)
				else
					state = "prep"
					eq.set_timer("cake_next_wave", INTERWAVE_MS)
					eq.zone_emote(15, string.format("Wave %d devoured! The smell of victory only makes them hungrier -- another course approaches.", cleared))
				end
			end
		end
	elseif e.timer == "cake_next_wave" then
		if state ~= "prep" then
			return
		end
		state = "wave"
		spawn_wave()
	elseif e.timer == "cake_send_home" then
		cleanup_waves()
		send_home(members_in_zone())
		eq.depop()
	end
end
