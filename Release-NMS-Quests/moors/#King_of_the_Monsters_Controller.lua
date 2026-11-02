-- moors/#King_of_the_Monsters_Controller.lua
-- NMS monster mission: Old Man McKenzie's King of the Monsters (moors v40).
--   * shrouds every expedition member who zones in (>= 5s after zone-in, the
--     client's deferred OP_Shroud window) into the Western Moorwalker 40 form
--     (shrouds.id 503 -- the stock Basilisk Beast 40 stats with a race-436
--     basilisk hull). Stripped on win/fail; global_player.pl is the safety
--     net for every other exit path,
--   * drakkin whelps (six colors) spawn on a 10s cadence at the Crescent
--     Reach zone line from a shuffled 30-card deck (five per color) and
--     beeline for the Plane of Knowledge stone; moors wildlife hunts them
--     for free (McKenzie's Prey faction, migration v281),
--   * the confused froglok spawns once near the stone and follows the
--     nearest whelp because he is confused; eating him is the kaiju's
--     problem (his script, not this one),
--   * a whelp kill only counts when the shrouded player lands it (whelp
--     scripts signal 100+color here); every qualifying bite is a yellow
--     "Delicious!",
--   * fail = any whelp touches the stone, the five minutes run out, a
--     member dies (moors/player.pl routes here), or everyone zones out.
--     Failures never lock out; the expedition is torn down,
--   * win = two devoured of every color: 18h replay lockout, the shroud
--     stripped, one McKenzie's Special Brew (41408) each, ride home to PoK.
-- Version 0 Blightfire Moors (the world zone, and the real Western
-- Moorwalker) is untouched.

local HUNT_VERSION  = 40
local HUNT_SHROUD   = 503
local MOORS_ID      = 395 -- zoneidnumber (canonical), not zone.id
local BREW_ITEM     = 41408 -- McKenzie's Special Brew (alternate_currency 18)

local STONE = { x = -1378.8, y = -612.8 } -- the OBJ_POK_BOOK_ door in moors
local STONE_RADIUS = 100
local LINE = { x = 3730, y = -945, z = -46 } -- Crescent Reach zone line
local LINE_JITTER = 40
local MISSION_SECONDS = 300

local COLOR_NPCS  = { 1520001971, 1520001972, 1520001973, 1520001974, 1520001975, 1520001976 }
local COLOR_NAMES = { "green", "red", "blue", "white", "gold", "black" }
local FROGLOK_ID  = 1520001977
local POK_ID      = 202
local POK_HOME    = { x = 263, y = 69, z = -125.375, h = 0 }

local POLL_MS       = 1000
local SHROUD_POLLS  = 5    -- shroud work runs on the 5s cake cadence
local SPAWN_MS      = eq.seconds("10s") * 1000
local SEND_HOME_MS  = eq.seconds("10s") * 1000
local DECK_PER_COLOR = 5

-- state: "idle" (waiting for the first shrouded Moorwalker) -> "hunting" ->
-- "won" / "failed"
local state = "idle"
local seen_unshrouded = {} -- char_id -> true (present last shroud poll)
local prepared      = {}   -- char_id -> true once the kaiju is dressed
local deck          = {}   -- shuffled whelp colors left to spawn
local devoured      = { 0, 0, 0, 0, 0, 0 }
local ticks_left    = MISSION_SECONDS
local empty_polls   = 0

local function is_whelp(npc)
	local type_id = npc:GetNPCTypeID()
	for _, id in ipairs(COLOR_NPCS) do
		if type_id == id then
			return true
		end
	end
	return false
end

local function whelp_color(npc)
	local type_id = npc:GetNPCTypeID()
	for color, id in ipairs(COLOR_NPCS) do
		if type_id == id then
			return color
		end
	end
	return 0
end

local function cleanup_prey()
	for _, id in ipairs(COLOR_NPCS) do
		eq.depop(id)
	end
	eq.depop(FROGLOK_ID)
end

-- expedition members currently in this zone
local function members_in_zone()
	local members = {}
	local clients = eq.get_entity_list():GetClientList()
	for client in clients.entries do
		if client.valid then
			local dz = client:GetExpedition()
			if dz.valid
				and dz:GetZoneID() == MOORS_ID
				and dz:GetZoneVersion() == HUNT_VERSION then
				table.insert(members, client)
			end
		end
	end
	return members
end

local function kaijus_in_zone(members)
	local kaijus = {}
	for _, client in ipairs(members) do
		if client:GetRace() == 436 then
			table.insert(kaijus, client)
		end
	end
	return kaijus
end

-- Monster missions dismiss pets: the shroud form is not supposed to have
-- one, and a player pet would make short work of the whelps.
local function dismiss_pets(client)
	local pet = client:GetPet()
	if pet and pet.valid then
		pet:Depop()
	end
end

local function hunt_complete()
	for i = 1, 6 do
		if devoured[i] < 2 then
			return false
		end
	end
	return true
end

-- win: 18h replay lockout, shrouds stripped, one Brew each, ride home.
-- Reached from either authority: moors/player.pl relaying the task
-- completion, or this controller's own devoured tally.
local function win_hunt()
	state = "won"
	local exp = eq.get_expedition()
	if exp.valid then
		exp:AddReplayLockout(eq.seconds("18h"))
	end
	eq.zone_emote(15, "The last whelp slides down. Western Moorwalker's hunt is finished, and the moors remember.")
	for _, client in ipairs(kaijus_in_zone(members_in_zone())) do
		client:RemoveShroud()
		client:SummonItem(BREW_ITEM, 1)
		client:Message(15, "Old Man McKenzie's voice rolls across the flats: 'HA! Twelve! Twelve whelps, not one at the stone, and the froglok still waddles about somewhere. You'll do. The Brew's in your hand -- mind you don't spill it.'")
	end
	eq.set_timer("king_send_home", SEND_HOME_MS)
end

local function spawn_whelp()
	if #deck == 0 then
		return
	end
	local color = table.remove(deck)
	local dx = math.random(-LINE_JITTER, LINE_JITTER)
	local dy = math.random(-LINE_JITTER, LINE_JITTER)
	eq.spawn2(COLOR_NPCS[color], 0, 0, LINE.x + dx, LINE.y + dy, LINE.z, 0)
end

local function spawn_froglok()
	local dx = math.random(-150, 150)
	local dy = math.random(-150, 150)
	eq.spawn2(FROGLOK_ID, 0, 0, STONE.x + dx, STONE.y + dy, 25, 0)
end

-- Instant fail: red text everywhere, shrouds stripped, prey swept, boot.
-- Any loss condition routes here: stone touched, clock run out, member
-- death (moors/player.pl), or the moors emptied of kaiju.
local function fail_hunt(reason)
	if state == "failed" or state == "won" then
		return
	end
	state = "failed"
	cleanup_prey()
	eq.zone_emote(MT.Red, "The hunt is lost. " .. reason .. " Old Man McKenzie's King of the Monsters has FAILED.")
	for _, client in ipairs(members_in_zone()) do
		client:SendMarqueeMessage(MT.Red, 255, 1000, 1500, 4000, "THE HUNT IS LOST")
		client:Message(MT.Red, "The Moorwalker's shape sloughs off you like old mud. McKenzie will hear about this.")
		client:SendSound()
		client:RemoveShroud()
	end
	eq.set_timer("king_fail_kick", 5000)
end

local function start_hunt(kaijus)
	state = "hunting"
	ticks_left = MISSION_SECONDS
	-- the deck: five of every color, shuffled
	deck = {}
	for color = 1, 6 do
		for _ = 1, DECK_PER_COLOR do
			deck[#deck + 1] = color
		end
	end
	for i = #deck, 2, -1 do
		local j = math.random(i)
		deck[i], deck[j] = deck[j], deck[i]
	end
	eq.set_timer("king_spawn", SPAWN_MS)
	spawn_froglok()
	eq.zone_emote(15, "The flats shudder. Whelps are spilling out of Crescent Reach, and the moors remember what they are for.")
end

function event_spawn(e)
	state = "idle"
	seen_unshrouded = {}
	prepared = {}
	deck = {}
	devoured = { 0, 0, 0, 0, 0, 0 }
	ticks_left = MISSION_SECONDS
	empty_polls = 0
	eq.set_timer("king_poll", POLL_MS)
	eq.set_timer("king_shroud", SHROUD_POLLS * POLL_MS)
end

function event_signal(e)
	if e.signal >= 101 and e.signal <= 106 then
		-- a whelp script reporting a shrouded player's kill (100 + color)
		local color = e.signal - 100
		if state == "hunting" then
			devoured[color] = devoured[color] + 1
			eq.zone_emote(15, "Delicious!")
			if hunt_complete() then
				win_hunt()
			end
		end
	elseif e.signal == 110 and state == "hunting" then
		eq.zone_emote(13, "That was not a whelp.")
	elseif e.signal == 1 and (state == "hunting" or state == "idle") then
		-- moors/player.pl: the King of the Monsters task completed
		win_hunt()
	elseif e.signal == 2 and (state == "hunting" or state == "idle") then
		fail_hunt("The kaiju has fallen.")
	end
end

function event_timer(e)
	if e.timer == "king_poll" then
		if state == "failed" or state == "won" then
			return
		end
		local members = members_in_zone()

		if state == "hunting" then
			-- a dead expedition member loses the hunt on the spot (backup
			-- for moors/player.pl event_death, which routes to the same
			-- fail path)
			for _, client in ipairs(members) do
				if client:GetHP() <= 0 then
					client:RemoveShroudSilent()
					fail_hunt("The kaiju has fallen.")
					return
				end
			end

			-- the moors emptied of kaiju: zone-out, bind release, whatever
			-- -- an unattended hunt is a lost hunt
			if #members == 0 then
				empty_polls = empty_polls + 1
				if empty_polls >= 2 then
					fail_hunt("The kaiju has left the moors.")
					return
				end
			else
				empty_polls = 0
			end

			-- the clock
			ticks_left = ticks_left - 1
			if ticks_left <= 0 then
				fail_hunt("Five minutes, and the flats are still crawling with live whelps.")
				return
			elseif ticks_left == 60 then
				eq.zone_emote(15, "One minute left, and the stone still waits.")
			elseif ticks_left == 10 then
				eq.zone_emote(15, "Ten seconds!")
			end

			-- any whelp that touches the stone ends it
			local npcs = eq.get_entity_list():GetNPCList()
			for npc in npcs.entries do
				if npc.valid and is_whelp(npc) then
					local dx = npc:GetX() - STONE.x
					local dy = npc:GetY() - STONE.y
					if dx * dx + dy * dy < STONE_RADIUS * STONE_RADIUS then
						local color = whelp_color(npc)
						fail_hunt("A " .. (COLOR_NAMES[color] or "drakkin") .. " whelp has touched the Plane of Knowledge stone.")
						return
					end
				end
			end
		end
	elseif e.timer == "king_shroud" then
		if state == "failed" or state == "won" then
			return
		end
		local members = members_in_zone()

		-- Drop prepared markers for characters who left the instance so a
		-- later re-entry is treated as a fresh shroud session.
		local present = {}
		for _, client in ipairs(members) do present[client:CharacterID()] = true end
		for cid in pairs(prepared) do if not present[cid] then prepared[cid] = nil end end

		for _, client in ipairs(members) do
			dismiss_pets(client)
			local id = client:CharacterID()
			if client:GetRace() ~= 436 then
				if seen_unshrouded[id] then
					client:ApplyShroud(HUNT_SHROUD)
					dismiss_pets(client)
					-- Live-like: the shroud strips the real character's
					-- buffs so nothing rides along into the basilisk.
					client:BuffFadeAll()
					prepared[id] = true
					seen_unshrouded[id] = nil
					client:Message(15, "Scale and stone close over you. You are Western Moorwalker now -- forty feet of grumpy basilisk, and the moors' last hope. Eat the whelps before they reach the stone. Two of every color. Do NOT eat the froglok.")
				else
					seen_unshrouded[id] = true
				end
			elseif not prepared[id] then
				-- Persisted shroud: the character logged out as the kaiju,
				-- so LoadAndApplyShroudState already re-applied race 436.
				prepared[id] = true
				dismiss_pets(client)
				client:BuffFadeAll()
			end
		end

		if state == "idle" then
			local kaijus = kaijus_in_zone(members)
			if #kaijus > 0 then
				start_hunt(kaijus)
			end
		end
	elseif e.timer == "king_spawn" then
		if state == "hunting" then
			spawn_whelp()
			if #deck == 0 then
				eq.stop_timer("king_spawn")
			end
		end
	elseif e.timer == "king_send_home" then
		cleanup_prey()
		for _, client in ipairs(members_in_zone()) do
			client:MovePC(POK_ID, POK_HOME.x, POK_HOME.y, POK_HOME.z, POK_HOME.h)
		end
		eq.depop()
	elseif e.timer == "king_fail_kick" then
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
