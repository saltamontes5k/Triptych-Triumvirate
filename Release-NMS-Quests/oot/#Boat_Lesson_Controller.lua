-- oot/#Boat_Lesson_Controller.lua
-- NMS monster mission: Old Man McKenzie's Boat Lesson (oot v29).
--   * shrouds every expedition member who zones in (>= 5s after zone-in, the
--     client's deferred OP_Shroud window) into the Rusty Steamboat 40 form
--     (shrouds.id 502 -- the level-40 imp wizard stats, shrouds 67, with a
--     race-141 rowboat hull) and keeps them levitating on stock Levitation
--     (2894, the targetable twin of the form's own Flight spell 7530, which
--     is self-only so the controller cannot cast it for them). Recast if it
--     fades; stripped on win/fail,
--   * McKenzie's jealous memories are hostile ships (race 533): once the
--     first boat is shrouded they spawn near the boats -- 1 + boats present
--     -- and top back up on a 60s cadence, fixated on the boats as a backup.
--     Sinking them is optional; the run is decided by the task,
--   * the Boat Lesson task (800004) tracks the five island docks as explore
--     activities inside oot v29; oot/player.pl relays each dock as a stage
--     emote and the task completion as the win signal,
--   * any member death fails the lesson instantly (oot/player.pl event_death,
--     backed by the GetHP poll here); the dead player's shroud is stripped so
--     the bind release is their real self,
--   * win = 18h replay lockout, a McKenzie's Special Brew (41408, the
--     alternate currency McKenzie's own shop spends), 1 AA point, unshroud,
--     ride home to PoK.
-- Version 0 Ocean of Tears (the world zone) is untouched.

local BOAT_VERSION   = 29
local BOAT_SHROUD_ID = 502
local OOT_ID         = 69 -- zoneidnumber (canonical), not zone.id
local BOAT_TASK_ID   = 800004
local LEVITATION     = 2894 -- stock targetable Levitation (Flight 7530 is self-only)
local BREW_ITEM      = 41408 -- McKenzie's Special Brew (alternate_currency 18)
local BREW_REWARD    = 1
local SHIP_NPC_IDS   = { 1520001950, 1520001951 }
local POK_ID         = 202
local POK_HOME       = { x = 263, y = 69, z = -125.375, h = 0 }

local SHIP_RING_OFFSETS = {
	{  60,   0 }, {   0,  60 }, { -60,   0 }, {   0, -60 },
	{  45,  45 }, { -45,  45 }, {  45, -45 }, { -45, -45 },
	{  80,  20 }, {  80, -20 }, { -80,  20 }, { -80, -20 },
	{  20,  80 }, { -20,  80 }, {  20, -80 }, { -20, -80 },
}

local POLL_MS       = 5000
local SEND_HOME_MS  = eq.seconds("10s") * 1000
local SHIP_REPLENISH_POLLS = 12 -- one hostile ship every ~60s while short

-- state: "idle" (waiting for the first shrouded boat) -> "sailing" ->
-- "won" / "failed"
local state = "idle"
local seen_unshrouded = {} -- char_id -> true (present last poll)
local prepared = {}        -- char_id -> true once levitation is applied
local polls_since_ship = 0

local function is_ship(npc)
	local type_id = npc:GetNPCTypeID()
	for _, ship_id in ipairs(SHIP_NPC_IDS) do
		if type_id == ship_id then
			return true
		end
	end
	return false
end

local function ship_npcs_alive()
	local count = 0
	local npcs = eq.get_entity_list():GetNPCList()
	for npc in npcs.entries do
		if npc.valid and is_ship(npc) then
			count = count + 1
		end
	end
	return count
end

-- expedition members currently in this zone
local function members_in_zone()
	local members = {}
	local clients = eq.get_entity_list():GetClientList()
	for client in clients.entries do
		if client.valid then
			local dz = client:GetExpedition()
			if dz.valid
				and dz:GetZoneID() == OOT_ID
				and dz:GetZoneVersion() == BOAT_VERSION then
				table.insert(members, client)
			end
		end
	end
	return members
end

local function boats_in_zone(members)
	local boats = {}
	for _, client in ipairs(members) do
		if client:GetRace() == 141 then
			table.insert(boats, client)
		end
	end
	return boats
end

-- Monster missions dismiss pets: a level-62 pet would sink the jealous fleet
-- on its own, and the shroud form is not supposed to have one. RemovePet()
-- only detaches the owner, so depop the pet mob itself.
local function dismiss_pets(client)
	local pet = client:GetPet()
	if pet and pet.valid then
		pet:Depop()
	end
end

local function strip_levitation(client)
	client:BuffFadeBySpellID(LEVITATION)
end

local function spawn_ship_near(boat)
	local off = SHIP_RING_OFFSETS[math.random(1, #SHIP_RING_OFFSETS)]
	local ship_id = SHIP_NPC_IDS[math.random(1, #SHIP_NPC_IDS)]
	eq.spawn2(ship_id, 0, 0, boat:GetX() + off[1], boat:GetY() + off[2], boat:GetZ(), 0)
end

local function target_ship_count(boats)
	return 1 + #boats -- a solo rowboat faces two; every extra boat spawns another
end

local function cleanup_ships()
	for _, id in ipairs(SHIP_NPC_IDS) do
		eq.depop(id)
	end
end

-- Instant fail: ships pulled, levitation off, unshroud, kick. Any member
-- death routes here (poll detection or oot/player.pl event_death).
local function fail_lesson()
	state = "failed"
	cleanup_ships()
	-- Defeat must be unmissable: red zone text, a red marquee on every boat,
	-- a sound, and then a hard boot from the expedition.
	eq.zone_emote(MT.Red, "The hull gives way. Old Man McKenzie's Boat Lesson has FAILED.")
	for _, client in ipairs(members_in_zone()) do
		client:SendMarqueeMessage(MT.Red, 255, 1000, 1500, 4000, "YOU ARE SUNK")
		client:Message(MT.Red, "YOU ARE SUNK. The jealous ships circle once, satisfied, and sail off.")
		client:SendSound()
		strip_levitation(client)
		client:RemoveShroud()
	end
	eq.set_timer("boat_fail_kick", 5000)
end

function event_spawn(e)
	state = "idle"
	seen_unshrouded = {}
	prepared = {}
	polls_since_ship = 0
	eq.set_timer("boat_poll", POLL_MS)
end

function event_signal(e)
	if e.signal == 1 and (state == "sailing" or state == "idle") then
		-- a member finished the Boat Lesson task (relayed by oot/player.pl)
		state = "won"
		local exp = eq.get_expedition()
		if exp.valid then
			exp:AddReplayLockout(eq.seconds("18h"))
		end
		eq.zone_emote(15, "The last dock slides past. The jealous ships turn away, outmaneuvered and outlived. Old Man McKenzie's Boat Lesson is complete!")
		for _, boat in ipairs(boats_in_zone(members_in_zone())) do
			strip_levitation(boat)
			boat:RemoveShroud()
			boat:SummonItem(BREW_ITEM, BREW_REWARD)
			boat:AddAAPoints(1)
			boat:Message(15, "Old Man McKenzie's voice carries across the water: 'Huh. Maybe there's hope for your generation yet. One bottle of the Special Brew and a point of enlightenment -- spend them wisely.'")
		end
		eq.set_timer("boat_send_home", SEND_HOME_MS)
	elseif e.signal == 2 and (state == "sailing" or state == "idle") then
		fail_lesson()
	end
end

function event_timer(e)
	if e.timer == "boat_poll" then
		if state == "failed" or state == "won" then
			return
		end

		local members = members_in_zone()

		-- A dead expedition member fails the lesson on the spot (backup for
		-- event_death, which routes to the same fail path).
		for _, client in ipairs(members) do
			if client:GetHP() <= 0 then
				strip_levitation(client)
				client:RemoveShroudSilent()
				fail_lesson()
				return
			end
		end

		local boats = boats_in_zone(members)

		-- Shroud members who were already present last poll (guarantees the
		-- 5s zone-settle window before OP_Shroud flies), then levitate them.
		-- Drop prepared markers for characters who left the instance so a
		-- later re-entry is treated as a fresh shroud session.
		local present = {}
		for _, client in ipairs(members) do present[client:CharacterID()] = true end
		for cid in pairs(prepared) do if not present[cid] then prepared[cid] = nil end end

		for _, client in ipairs(members) do
			-- No pets in the mission, including ones summoned after the shroud.
			dismiss_pets(client)
			local id = client:CharacterID()
			if client:GetRace() ~= 141 then
				if seen_unshrouded[id] then
					client:ApplyShroud(BOAT_SHROUD_ID)
					dismiss_pets(client)
					-- Live-like: the shroud strips the real character's buffs
					-- (their damage shields / haste / speed buffs would ride
					-- along otherwise), then the levitation goes on alone.
					client:BuffFadeAll()
					local ok_lev = e.self:CastSpell(LEVITATION, client:GetID())
					prepared[id] = true
					eq.debug(string.format("[boat] fresh %s: race=%s lev=%s castLev=%s",
						client:GetName(), tostring(client:GetRace()), tostring(client:FindBuff(LEVITATION)), tostring(ok_lev)))
					client:Message(15, "Barnacled planks close over you. You are the boat now -- a battered little rowboat with a wizard's temper. Float past the docks of every island, and do not get sunk. Buy your abilities while you float; the jealous ships are already out there.")
					seen_unshrouded[id] = nil
				else
					seen_unshrouded[id] = true
				end
			else
				seen_unshrouded[id] = nil
				if not prepared[id] then
					-- Persisted shroud: the character logged out as a boat, so
					-- LoadAndApplyShroudState already re-applied race 141 and
					-- the apply path above never runs. Strip the real buffs and
					-- levitate here so a persisted boat is prepared once.
					prepared[id] = true
					dismiss_pets(client)
					client:BuffFadeAll()
					e.self:CastSpell(LEVITATION, client:GetID())
				else
					-- keep the hull riding the surface: recast if it faded
					if not client:FindBuff(LEVITATION) then
						e.self:CastSpell(LEVITATION, client:GetID())
					end
				end
			end
		end

		if state == "idle" and #boats > 0 then
			state = "sailing"
			polls_since_ship = 0
			eq.zone_emote(15, "Sails slide over the horizon -- McKenzie's jealous memories have found you.")
			for _, boat in ipairs(boats) do
				spawn_ship_near(boat)
			end
			spawn_ship_near(boats[math.random(1, #boats)])
		end

		if state == "sailing" then
			-- backup fixation: keep the ships on the boats even if natural
			-- aggro loses them
			local npcs = eq.get_entity_list():GetNPCList()
			for npc in npcs.entries do
				if npc.valid and is_ship(npc) then
					for _, boat in ipairs(boats) do
						npc:AddToHateList(boat, 100, 0)
					end
				end
			end

			-- top the jealous fleet back up while boats remain afloat
			polls_since_ship = polls_since_ship + 1
			if #boats > 0 and ship_npcs_alive() < target_ship_count(boats)
				and polls_since_ship >= SHIP_REPLENISH_POLLS then
				polls_since_ship = 0
				spawn_ship_near(boats[math.random(1, #boats)])
			end
		end
	elseif e.timer == "boat_send_home" then
		cleanup_ships()
		for _, client in ipairs(members_in_zone()) do
			client:MovePC(POK_ID, POK_HOME.x, POK_HOME.y, POK_HOME.z, POK_HOME.h)
		end
		eq.depop()
	elseif e.timer == "boat_fail_kick" then
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
