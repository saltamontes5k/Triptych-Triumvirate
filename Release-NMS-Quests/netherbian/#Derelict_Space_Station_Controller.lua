-- netherbian/#Derelict_Space_Station_Controller.lua
-- NMS monster mission: Old Man McKenzie's Derelict Space Station (netherbian
-- v66).
--   * shrouds every expedition member who zones in (>= 5s after zone-in, the
--     client's deferred OP_Shroud window) into the Master Officer Wizard
--     Armor 40 form (shrouds.id 505 -- the stock Goblin Wizard 40 stats with
--     a race-323 animated armor hull). Stripped on win/fail;
--     global_player.pl is the safety net for every other exit path,
--   * the infestation is pre-spawned by migration v284: 152 combat points,
--     one spawnentry each, respawntime 604800 (a full clear with no repop --
--     a respawn would make the mission incompletable). 58 Leapers of the
--     Dark hide until a Master Officer gets close (their scripts), 73
--     fungal fiends and 21 zombies of the old crew are aggressive,
--   * a kill only counts when the shrouded Master Officer lands it (mob
--     scripts signal 10/20/30 here); every qualifying kill gets an emote,
--   * fail = a member dies (netherbian/player.pl routes here) or the station
--     empties of Master Officers. Failures never lock out; the expedition is
--     torn down,
--   * win = every tally complete: 18h replay lockout, the shroud stripped,
--     one McKenzie's Special Brew (41408) each, ride home to PoK.
-- Version 0 Netherbian Lair (the world zone) is untouched.

local STATION_VERSION = 66
local STATION_SHROUD  = 505
local NETHERBIAN_ID   = 161 -- zoneidnumber (canonical), not zone.id
local BREW_ITEM       = 41408 -- McKenzie's Special Brew (alternate_currency 18)

local LEAPER_ID = 1520001986
local FIEND_ID  = 1520001987
local ZOMBIE_ID = 1520001988
local POK_ID    = 202
local POK_HOME  = { x = 263, y = 69, z = -125.375, h = 0 }

-- The exact per-family spawn counts migration v284 emits (one spawnentry per
-- point); the task activities carry the same numbers.
local GOALS = { [LEAPER_ID] = 58, [FIEND_ID] = 73, [ZOMBIE_ID] = 21 }

local POLL_MS      = 1000
local SHROUD_POLLS = 5    -- shroud work runs on the 5s moors cadence
local SEND_HOME_MS = eq.seconds("10s") * 1000

-- state: "idle" (waiting for the first shrouded Master Officer) -> "purging"
-- -> "won" / "failed"
local state = "idle"
local seen_unshrouded = {} -- char_id -> true (present last shroud poll)
local prepared      = {}   -- char_id -> true once the armor is worn
local killed        = { [LEAPER_ID] = 0, [FIEND_ID] = 0, [ZOMBIE_ID] = 0 }
local empty_polls   = 0

local SIGNALS = { [10] = LEAPER_ID, [20] = FIEND_ID, [30] = ZOMBIE_ID }

-- expedition members currently in this zone
local function members_in_zone()
	local members = {}
	local clients = eq.get_entity_list():GetClientList()
	for client in clients.entries do
		if client.valid then
			local dz = client:GetExpedition()
			if dz.valid
				and dz:GetZoneID() == NETHERBIAN_ID
				and dz:GetZoneVersion() == STATION_VERSION then
				table.insert(members, client)
			end
		end
	end
	return members
end

local function officers_in_zone(members)
	local officers = {}
	for _, client in ipairs(members) do
		if client:GetRace() == 323 then
			table.insert(officers, client)
		end
	end
	return officers
end

-- Monster missions dismiss pets: the shroud form is not supposed to have
-- one, and a player pet would make short work of the infestation.
local function dismiss_pets(client)
	local pet = client:GetPet()
	if pet and pet.valid then
		pet:Depop()
	end
end

local function purge_complete()
	for id, goal in pairs(GOALS) do
		if killed[id] < goal then
			return false
		end
	end
	return true
end

-- win: 18h replay lockout, shrouds stripped, one Brew each, ride home.
-- Reached from either authority: netherbian/player.pl relaying the task
-- completion, or this controller's own kill tally.
local function win_station()
	state = "won"
	local exp = eq.get_expedition()
	if exp.valid then
		exp:AddReplayLockout(eq.seconds("18h"))
	end
	eq.zone_emote(15, "The station goes quiet. The Mildew remembers nothing, the crew clocks out, and the Watchful Spark begins a very long speech.")
	for _, client in ipairs(officers_in_zone(members_in_zone())) do
		client:RemoveShroud()
		client:SummonItem(BREW_ITEM, 1)
		client:AddAAPoints(1)
		client:Message(15, "Old Man McKenzie's voice rolls through the armor: 'HA! Every last one! The Brew's in your hand, Master Officer -- mind you don't spill it.'")
	end
	eq.set_timer("station_send_home", SEND_HOME_MS)
end

-- Instant fail: red text everywhere, shrouds stripped, boot. Any loss
-- condition routes here: member death (netherbian/player.pl), or the station
-- emptied of Master Officers.
local function fail_station(reason)
	if state == "failed" or state == "won" then
		return
	end
	state = "failed"
	eq.zone_emote(MT.Red, "The station is lost. " .. reason .. " Old Man McKenzie's Derelict Space Station has FAILED.")
	for _, client in ipairs(members_in_zone()) do
		client:SendMarqueeMessage(MT.Red, 255, 1000, 1500, 4000, "THE STATION IS LOST")
		client:Message(MT.Red, "The armor sloughs off you like wet brass. McKenzie will hear about this.")
		client:SendSound()
		client:RemoveShroud()
	end
	eq.set_timer("station_fail_kick", 5000)
end

local function start_purge()
	state = "purging"
	eq.zone_emote(15, "Somewhere in the dark, a Watchful Spark says: 'Master Officers on deck. The Mildew is SO pleased.'")
end

function event_spawn(e)
	state = "idle"
	seen_unshrouded = {}
	prepared = {}
	killed = { [LEAPER_ID] = 0, [FIEND_ID] = 0, [ZOMBIE_ID] = 0 }
	empty_polls = 0
	eq.set_timer("station_poll", POLL_MS)
	eq.set_timer("station_shroud", SHROUD_POLLS * POLL_MS)
end

function event_signal(e)
	local mob_id = SIGNALS[e.signal]
	if mob_id and state == "purging" then
		if killed[mob_id] < GOALS[mob_id] then
			killed[mob_id] = killed[mob_id] + 1
			if e.signal == 10 then
				eq.zone_emote(15, "A Leaper of the Dark was never there. Now it isn't anywhere.")
			elseif e.signal == 20 then
				eq.zone_emote(15, "The Mildew loses a bloom.")
			else
				eq.zone_emote(15, "The crew clocks out.")
			end
			if purge_complete() then
				win_station()
			end
		end
	elseif e.signal == 1 and (state == "purging" or state == "idle") then
		-- netherbian/player.pl: the Derelict Space Station task completed
		win_station()
	elseif e.signal == 2 and (state == "purging" or state == "idle") then
		fail_station("A Master Officer has fallen.")
	end
end

function event_timer(e)
	if e.timer == "station_poll" then
		if state == "failed" or state == "won" then
			return
		end
		local members = members_in_zone()

		if state == "purging" then
			-- a dead expedition member loses the purge on the spot (backup
			-- for netherbian/player.pl event_death, which routes to the same
			-- fail path)
			for _, client in ipairs(members) do
				if client:GetHP() <= 0 then
					client:RemoveShroudSilent()
					fail_station("A Master Officer has fallen.")
					return
				end
			end

			-- the station emptied of Master Officers: zone-out, bind release,
			-- whatever -- an unattended purge is a lost purge
			if #members == 0 then
				empty_polls = empty_polls + 1
				if empty_polls >= 2 then
					fail_station("The Master Officers have left the station.")
					return
				end
			else
				empty_polls = 0
			end
		end
	elseif e.timer == "station_shroud" then
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
			if client:GetRace() ~= 323 then
				if seen_unshrouded[id] then
					client:ApplyShroud(STATION_SHROUD)
					dismiss_pets(client)
					-- Live-like: the shroud strips the real character's
					-- buffs so nothing rides along into the armor.
					client:BuffFadeAll()
					prepared[id] = true
					seen_unshrouded[id] = nil
					client:Message(15, "Brass closes over you. You are a Master Officer now -- animated armor, level 40, wizard to the solder. Purge the Mildew, silence the Leapers of the Dark, cull the crew. Every last one. And do NOT fire the station.")
				else
					seen_unshrouded[id] = true
				end
			elseif not prepared[id] then
				-- Persisted shroud: the character logged out as the armor,
				-- so LoadAndApplyShroudState already re-applied race 323.
				prepared[id] = true
				dismiss_pets(client)
				client:BuffFadeAll()
			end
		end

		if state == "idle" then
			local officers = officers_in_zone(members)
			if #officers > 0 then
				start_purge()
			end
		end
	elseif e.timer == "station_send_home" then
		for _, client in ipairs(members_in_zone()) do
			client:MovePC(POK_ID, POK_HOME.x, POK_HOME.y, POK_HOME.z, POK_HOME.h)
		end
		eq.depop()
	elseif e.timer == "station_fail_kick" then
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
