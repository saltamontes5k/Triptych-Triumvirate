-- beholder/#Pottery_Trial_Controller.lua
-- Mudshoes' Pottery Trial (beholder v80). Tradeskill shroud mission #2,
-- spun off the Fool's Gold Cake Defense (rivervale/#Cake_Defense_Baker.lua).
-- Five-stage state machine instead of three tower-defense waves:
--   boot   - waiting for the first shrouded golem
--   stage1 - the escape: water elementals + gnomish magician camp the
--            entrance and one-shot the tiny golem (any death fails); the
--            runaway halfling potter is invulnerable until she lands ONE
--            hit on a golem (the shaping) -- a surviving wound right next
--            to the potter ports everyone to the shaping yard
--   stage2 - the shaping: kill 10 shaper's hands (4 hunters roam grid
--            1520000002, 6 passive wait); the hands flee when hurt. Grow
--            (44032, +30% size, instant) + Clay Toughening I (44033)
--   stage3 - the baking: kill 10 fire elementals; 4 kiln flames
--            (1520001999, melee/magic/client-harm immune) are scenery and
--            do not count. Grow again + Toughening II (44034) + the pot
--            illusion (race 379, a_clay_vase -- SendIllusionPacket, race
--            only, so the grown size survives)
--   stage4 - the reckoning: port back to the entrance and one-shot the
--            magician, the potter and the water elementals, who never
--            despawned and whose sliver HP is now trivial
-- Any member death fails the trial (poll + beholder/player.lua event_death);
-- 18h replay lockout and Pottery (skill 69) +30 capped at 300 on a win.
-- Balance knobs: actor stats (v287), the grow/toughening ids below, counts.

local VERSION        = 80
local SHROUD_ID      = 506
local BEHOLDER_ID    = 16 -- zoneidnumber (canonical), not zone.id
local GROW_SPELL     = 44032 -- Kiln Growth: instant SE_ModelSize +30%
local TOUGHEN_1      = 44033 -- Clay Toughening I (+400 max HP)
local TOUGHEN_2      = 44034 -- Clay Toughening II (+1200 max HP)
local POT_RACE       = 379   -- the a_clay_vase model: the kiln-fired pot illusion
local SHROUD_SIZE    = 2.0   -- keep in sync with shrouds.size (506)

local POTTER_ID       = 1520001992
local MAGE_ID         = 1520001993
local WATER_ID        = 1520001994
local HAND_HUNTER_ID  = 1520001996
local HAND_PASSIVE_ID = 1520001997
local FIRE_ID         = 1520001998
local FLAME_ID        = 1520001999
local ALL_ACTORS = { POTTER_ID, MAGE_ID, WATER_ID, HAND_HUNTER_ID, HAND_PASSIVE_ID, FIRE_ID, FLAME_ID }

local ENTRANCE    = { x = -1840, y = 720,  z = 9 }  -- the original spot / zonein
local MAGE_CAMP   = { x = -1830, y = 735,  z = 9 }
local POTTER_SPOT = { x = -1650, y = 550,  z = 6 }
local SHAPING     = { x = 17,    y = -105, z = 7 }  -- stage 2
local KILN        = { x = -588,  y = 510,  z = 71 } -- stage 3

local ELEMENTAL_GRID = 1520000001
local HUNTER_GRID    = 1520000002

local BAZAAR_ID   = 151
local BAZAAR_HOME = { x = 185, y = -835, z = 4, h = 390 }

local POLL_MS      = 5000
local SEND_HOME_MS = eq.seconds("10s") * 1000
local EMPTY_POLLS_TO_FAIL = 2

local POTTERY_SKILL = 69 -- 69 = Pottery (60 is Baking)
local POTTERY_CAP   = 300

-- At-cap booby prize: a master potter gets an ability point plus a full
-- stack of a random kiln component.
local BOOBY_PRIZES = {
	{ id = 16900, stack = 20, name = "small blocks of clay" }, -- Small Block of Clay
	{ id = 16906, stack = 20, name = "firing sheets" },        -- Firing Sheet
	{ id = 13006, stack = 20, name = "water flasks" },         -- Water Flask
}

-- Pimm's long-distance coaching, every NAG_EVERY_N_POLLS-th stage-1 poll.
local PIMM_LINES = {
	"Pimm's voice echoes from the Bazaar: 'The potter is IN the gorge, not AT the entrance. Deeper, golem, deeper!'",
	"Pimm's voice echoes from the Bazaar: 'Dodge the water, find the wheel. You ARE the wheel's project.'",
	"Pimm's voice echoes from the Bazaar: 'Stay adaptable! That is the entire secret!'",
}
local NAG_EVERY_N_POLLS = 36 -- ~3 minutes

-- state: "boot" -> "stage1" -> "stage2" -> "stage3" -> "stage4" -> "won"/"failed"
local state = "boot"
local seen_unshrouded = {} -- char_id -> true (present last poll)
local prepared = {}        -- char_id -> true once dressed
local illusion_sent = {}   -- char_id -> true once the pot illusion went out
local empty_polls = 0
local poll_count = 0

local function stage_number()
	-- state is "stage1".."stage4" whenever this is consulted
	return tonumber(string.sub(state, -1)) or 1
end

-- expedition members currently in this zone (golems in waiting and in the fight)
local function members_in_zone()
	local members = {}
	local clients = eq.get_entity_list():GetClientList()
	for client in clients.entries do
		if client.valid then
			local dz = client:GetExpedition()
			if dz.valid
				and dz:GetZoneID() == BEHOLDER_ID
				and dz:GetZoneVersion() == VERSION then
				table.insert(members, client)
			end
		end
	end
	return members
end

-- The form is race 17 (clay golem); after the stage-3 pot illusion the same
-- character reads race 379. Both races only ever occur while shrouded here.
local function in_form(client)
	local race = client:GetRace()
	return race == 17 or race == POT_RACE
end

local function golems_in_zone(members)
	local golems = {}
	for _, client in ipairs(members) do
		if in_form(client) then
			table.insert(golems, client)
		end
	end
	return golems
end

local function count_npc_types(ids)
	local count = 0
	local npcs = eq.get_entity_list():GetNPCList()
	for npc in npcs.entries do
		if npc.valid then
			for _, id in ipairs(ids) do
				if npc:GetNPCTypeID() == id then
					count = count + 1
					break
				end
			end
		end
	end
	return count
end

local function find_npc(npc_id)
	local npcs = eq.get_entity_list():GetNPCList()
	for npc in npcs.entries do
		if npc.valid and npc:GetNPCTypeID() == npc_id then
			return npc
		end
	end
	return nil
end

-- Monster missions dismiss pets: a real pet would solo the mission, and the
-- shroud form is not supposed to have one. RemovePet() only detaches the
-- owner, so depop the pet mob itself.
local function dismiss_pets(client)
	local pet = client:GetPet()
	if pet and pet.valid then
		pet:Depop()
	end
end

local function strip_dressing(client)
	client:BuffFadeBySpellID(TOUGHEN_1)
	client:BuffFadeBySpellID(TOUGHEN_2)
end

-- Growth is instant (no buff slot to FindBuff), so track it by the observable:
-- the engine multiplies current size by base/100 and self-caps at two growths
-- from base size (spell_effects.cpp SE_ModelSize), so one cast per poll until
-- the stage target is reached is idempotent even after a mid-run relog (which
-- resets the shroud, and with it the size).
local GROW_TARGET_2 = SHROUD_SIZE * 1.3 * 0.95  -- stage 2: one growth
local GROW_TARGET_3 = SHROUD_SIZE * 1.69 * 0.95 -- stage 3+: two growths

-- Cast what the stage expects and repair what faded (toughening buffs recast
-- when FindBuff fails, cake-style; grow/illusion re-applied when missing).
local function dress_golem(client, stage)
	dismiss_pets(client)
	if stage >= 2 and not client:FindBuff(TOUGHEN_1) then
		e.self:CastSpell(TOUGHEN_1, client:GetID())
	end
	if stage >= 3 and not client:FindBuff(TOUGHEN_2) then
		e.self:CastSpell(TOUGHEN_2, client:GetID())
	end
	if stage >= 3 and client:GetSize() < GROW_TARGET_3 then
		e.self:CastSpell(GROW_SPELL, client:GetID())
	elseif stage == 2 and client:GetSize() < GROW_TARGET_2 then
		e.self:CastSpell(GROW_SPELL, client:GetID())
	end
	if stage >= 3 and not illusion_sent[client:CharacterID()] then
		-- Race-only illusion: the grown size survives because the size key is
		-- left at its current value.
		client:SendIllusionPacket({ race = POT_RACE })
		illusion_sent[client:CharacterID()] = true
	end
end

-- Instant fail: actors pulled, buffs off, unshroud, everyone booted. Any
-- member death routes here (poll detection or beholder/player.lua event_death).
local function fail_trial()
	state = "failed"
	for _, id in ipairs(ALL_ACTORS) do
		eq.depop(id)
	end
	eq.zone_emote(MT.Red, "The clay cracks one time too many. Mudshoes' Pottery Trial has FAILED.")
	for _, client in ipairs(members_in_zone()) do
		client:SendMarqueeMessage(MT.Red, 255, 1000, 1500, 4000, "THE POTTERY TRIAL HAS FAILED")
		client:Message(MT.Red, "THE POTTERY TRIAL HAS FAILED.")
		client:Message(MT.Red, "Your clay is unfit for the kiln. You are cast out of the expedition.")
		client:SendSound()
		strip_dressing(client)
		client:RemoveShroud()
	end
	eq.set_timer("pottery_fail_kick", 5000)
end

local function move_members(members, spot)
	for _, client in ipairs(members) do
		client:MovePCInstance(BEHOLDER_ID, VERSION, spot.x, spot.y, spot.z, 0)
	end
end

local function spawn_stage1()
	-- The magician and his water elementals never leave the entrance; their
	-- sliver HP is what makes the finale one-shot, their damage is what makes
	-- stage 1 lethal. Elemental count scales with the party.
	local golems = golems_in_zone(members_in_zone())
	local elementals = math.min(2 + #golems, 10)
	local ring = {
		{ 0, 35 }, { 35, 0 }, { 0, -35 }, { -35, 0 },
		{ 25, 25 }, { -25, 25 }, { 25, -25 }, { -25, -25 },
		{ 45, 10 }, { 10, 45 },
	}
	eq.spawn2(MAGE_ID, 0, 0, MAGE_CAMP.x, MAGE_CAMP.y, MAGE_CAMP.z, 0)
	for i = 1, elementals do
		local off = ring[i]
		eq.spawn2(WATER_ID, ELEMENTAL_GRID, 0, MAGE_CAMP.x + off[1], MAGE_CAMP.y + off[2], MAGE_CAMP.z, 0)
	end
	local potter = eq.spawn2(POTTER_ID, 0, 0, POTTER_SPOT.x, POTTER_SPOT.y, POTTER_SPOT.z, 0)
	if potter and potter.valid then
		-- Invulnerable until she lands the shaping hit: a golem that decided to
		-- fight back could otherwise kill her (45 HP) and soft-lock stage 1.
		potter:SetInvul(true)
	end
	eq.zone_emote(15, "Water hisses against clay as the magician's elementals turn toward the new arrival. Somewhere deeper in the gorge, a wheel is spinning.")
end

local function spawn_stage2()
	-- 10 hands: 4 hunters roam grid 1520000002 (spawned on its waypoints), 6
	-- passive ones stand and wait. No FleeingImmunity: the hands flee when
	-- hurt, by design.
	local hunter_spots = {
		{ 135, -100 }, { 20, -205 }, { -100, -110 }, { 15, -15 },
	}
	for _, spot in ipairs(hunter_spots) do
		eq.spawn2(HAND_HUNTER_ID, HUNTER_GRID, 0, spot[1], spot[2], SHAPING.z, 0)
	end
	local passive_offsets = {
		{ 40, 0 }, { -40, 0 }, { 0, 40 }, { 0, -40 }, { 28, 28 }, { -28, -28 },
	}
	for _, off in ipairs(passive_offsets) do
		eq.spawn2(HAND_PASSIVE_ID, 0, 0, SHAPING.x + off[1], SHAPING.y + off[2], SHAPING.z, 0)
	end
	eq.zone_emote(15, "The shaping yard: reanimated hands knead at the air, waiting for wet clay. Ten of them must be driven off before the wheel turns again.")
end

local function spawn_stage3()
	-- 10 countable fire elementals in a ring; 4 kiln flames between them are
	-- immortal scenery ('ABZ') and do not count.
	local fire_ring = {
		{ 45, 0 }, { 0, 45 }, { -45, 0 }, { 0, -45 },
		{ 32, 32 }, { -32, 32 }, { 32, -32 }, { -32, -32 },
		{ 50, 18 }, { 18, 50 },
	}
	for _, off in ipairs(fire_ring) do
		eq.spawn2(FIRE_ID, 0, 0, KILN.x + off[1], KILN.y + off[2], KILN.z, 0)
	end
	local flames = { { 15, 0 }, { 0, 15 }, { -15, 0 }, { 0, -15 } }
	for _, off in ipairs(flames) do
		eq.spawn2(FLAME_ID, 0, 0, KILN.x + off[1], KILN.y + off[2], KILN.z, 0)
	end
	eq.zone_emote(15, "The kiln floor: fire everywhere, and most of it refuses to be shaped. Ten flames will bend; the rest simply burn.")
end

local function win_trial()
	state = "won"
	local exp = eq.get_expedition()
	if exp.valid then
		exp:AddReplayLockout(eq.seconds("18h"))
	end
	eq.zone_emote(15, "The kiln ward falls silent. Pimm's voice echoes from the Bazaar: 'Magnificent! Fire it, glaze it, ship it!'")
	for _, client in ipairs(golems_in_zone(members_in_zone())) do
		strip_dressing(client)
		client:RemoveShroud()
		local skill = client:GetSkill(POTTERY_SKILL)
		if skill < POTTERY_CAP then
			local gain = math.min(30, POTTERY_CAP - skill)
			local newvalue = skill + gain
			-- SetSkill saves character_skills and sends OP_SkillUpdate; the old
			-- IncreaseSkill did neither, so the reward silently vanished on zone.
			client:SetSkill(POTTERY_SKILL, newvalue)
			eq.debug(string.format("[pottery] reward %s: skill %d (Pottery) %d -> %d", client:GetName(), POTTERY_SKILL, skill, newvalue))
			client:Message(15, string.format("Pimm's voice echoes from the Bazaar: 'Magnificent! You have learned %d points of Pottery (now %d/%d) -- knowledge no book will give you.'", gain, newvalue, POTTERY_CAP))
		else
			-- Maxed pottery: the skill reward is capped, so hand out the booby
			-- prize instead -- an ability point and a stack of a kiln component.
			local prize = BOOBY_PRIZES[math.random(1, #BOOBY_PRIZES)]
			client:AddAAPoints(1)
			client:SummonItem(prize.id, prize.stack)
			client:Message(15, string.format("Pimm's voice echoes from the Bazaar: 'Magnificent! You throw clay like a god already -- there is nothing left for me to teach you, so take this instead: a stack of %s and a lesson in ability. You have learned much about pottery today.'", prize.name))
		end
	end
	eq.set_timer("pottery_send_home", SEND_HOME_MS)
end

local function to_stage2(members)
	state = "stage2"
	eq.zone_emote(15, "The potter seizes you mid-swing and throws you on the wheel. The world spins -- clay flies -- and you come out BIGGER.")
	move_members(members, SHAPING)
	for _, golem in ipairs(golems_in_zone(members)) do
		dress_golem(golem, 2)
	end
	spawn_stage2()
end

local function to_stage3(members)
	state = "stage3"
	eq.zone_emote(15, "Shaped at last, you are carried to the kiln and the fire takes you. The clay body hardens -- and grows again.")
	move_members(members, KILN)
	for _, golem in ipairs(golems_in_zone(members)) do
		dress_golem(golem, 3)
	end
	spawn_stage3()
end

local function to_stage4(members)
	state = "stage4"
	-- The potter loses her shaping-day invulnerability: now she is a target.
	local potter = find_npc(POTTER_ID)
	if potter then
		potter:SetInvul(false)
	end
	eq.zone_emote(15, "Baked, glazed, and furious, you are carried back to the mouth of the gorge and set down. The magician's camp is right there. Collect.")
	move_members(members, ENTRANCE)
	for _, golem in ipairs(golems_in_zone(members)) do
		dress_golem(golem, 4)
	end
end

function event_spawn(e)
	state = "boot"
	seen_unshrouded = {}
	prepared = {}
	illusion_sent = {}
	empty_polls = 0
	poll_count = 0
	eq.set_timer("pottery_poll", POLL_MS)
end

function event_signal(e)
	if e.signal == 2 and state ~= "boot" and state ~= "won" and state ~= "failed" then
		-- a member died (beholder/player.lua event_death)
		fail_trial()
	end
end

function event_timer(e)
	if e.timer == "pottery_poll" then
		if state == "failed" or state == "won" then
			return
		end
		poll_count = poll_count + 1

		local members = members_in_zone()
		if #members == 0 then
			empty_polls = empty_polls + 1
			if empty_polls >= EMPTY_POLLS_TO_FAIL then
				fail_trial()
			end
			return
		end
		empty_polls = 0

		-- A dead expedition member fails the trial on the spot (backup for
		-- event_death, which routes to the same fail path).
		for _, client in ipairs(members) do
			if client:GetHP() <= 0 then
				strip_dressing(client)
				client:RemoveShroudSilent()
				fail_trial()
				return
			end
		end

		-- Shroud members who were already present last poll (guarantees the 5s
		-- zone-settle window before OP_Shroud flies), then dress every golem
		-- for the CURRENT stage -- so a late joiner or a mid-run relog catches
		-- up, and dressing stays idempotent (FindBuff / size checks / the
		-- once-only illusion flag).
		local present = {}
		for _, client in ipairs(members) do present[client:CharacterID()] = true end
		for cid in pairs(prepared) do if not present[cid] then prepared[cid] = nil end end
		for cid in pairs(illusion_sent) do if not present[cid] then illusion_sent[cid] = nil end end

		for _, client in ipairs(members) do
			local id = client:CharacterID()
			if not in_form(client) then
				if seen_unshrouded[id] then
					client:ApplyShroud(SHROUD_ID)
					dismiss_pets(client)
					-- Live-like: the shroud strips the real character's buffs
					-- (their haste / regen / shields would ride along otherwise).
					client:BuffFadeAll()
					illusion_sent[id] = nil
					prepared[id] = true
					seen_unshrouded[id] = nil
					client:Message(15, "Wet clay closes over you. You are a tiny clay golem now -- soft, slow, and extremely breakable. The water elementals at the entrance WILL kill you in one hit. Find the potter and let her shape you.")
				else
					seen_unshrouded[id] = true
				end
			else
				seen_unshrouded[id] = nil
				prepared[id] = true
			end
		end

		local golems = golems_in_zone(members)

		if state == "boot" then
			if #golems > 0 then
				state = "stage1"
				spawn_stage1()
			end
		else
			for _, golem in ipairs(golems) do
				dress_golem(golem, stage_number())
			end

			if state == "stage1" then
				-- The potter landed the shaping hit: a golem below max HP while
				-- the potter is right on top of it. Elemental hits kill outright
				-- (fail path), so any surviving wound next to the potter is hers.
				local potter = find_npc(POTTER_ID)
				if not potter then
					-- A golem that fought back through the invulnerability gap
					-- (or any despawn edge): put her back rather than soft-lock.
					potter = eq.spawn2(POTTER_ID, 0, 0, POTTER_SPOT.x, POTTER_SPOT.y, POTTER_SPOT.z, 0)
					if potter and potter.valid then
						potter:SetInvul(true)
					end
				else
					for _, golem in ipairs(golems) do
						local dx = golem:GetX() - potter:GetX()
						local dy = golem:GetY() - potter:GetY()
						if golem:GetHP() < golem:GetMaxHP() and (dx * dx + dy * dy) < 3600 then
							to_stage2(members)
							return
						end
					end
				end
				if poll_count % NAG_EVERY_N_POLLS == 0 then
					e.self:Say(PIMM_LINES[math.random(1, #PIMM_LINES)])
				end
			elseif state == "stage2" then
				if count_npc_types({ HAND_HUNTER_ID, HAND_PASSIVE_ID }) == 0 then
					to_stage3(members)
				end
			elseif state == "stage3" then
				if count_npc_types({ FIRE_ID }) == 0 then
					to_stage4(members)
				end
			elseif state == "stage4" then
				if count_npc_types({ POTTER_ID, MAGE_ID, WATER_ID }) == 0 then
					win_trial()
				end
			end
		end
	elseif e.timer == "pottery_send_home" then
		for _, id in ipairs(ALL_ACTORS) do
			eq.depop(id)
		end
		for _, client in ipairs(members_in_zone()) do
			client:MovePC(BAZAAR_ID, BAZAAR_HOME.x, BAZAAR_HOME.y, BAZAAR_HOME.z, BAZAAR_HOME.h)
		end
		eq.depop()
	elseif e.timer == "pottery_fail_kick" then
		-- Hard boot: removing every member tears the expedition down and the
		-- dynamic zone teleports the clients out to the safe return.
		local exp = eq.get_expedition()
		if exp.valid then
			exp:SetLocked(true, 2)
			exp:RemoveAllMembers()
		end
		eq.depop()
	end
end
