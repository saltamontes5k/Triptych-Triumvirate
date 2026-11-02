-- skyshrine/#Midnight_Snack_Controller.lua
-- NMS monster mission: Old Man McKenzie's Midnight Snack (skyshrine v41).
--   * shrouds every expedition member who zones in (>= 5s after zone-in, the
--     client's deferred OP_Shroud window) into the Dwarven Ghost 40 form
--     (shrouds.id 504 -- the stock Tiger Beast 40 berserker kit on the
--     Garanel Rucksif hull, race 117 texture 3). Stripped on win/fail;
--     global_player.pl is the safety net for every other exit path,
--   * the maze is the shrine's top level (z 373-409): 24 frosted cakes sit
--     on its floor like so many pills, and four colored ones hunt the ghost
--     -- Sad (icy-blue drake), Mad (ruby-red drake), Glad (the shimmering
--     drake, the most yellow hull the client owns) and Bad (the drixie).
--     Nobody hunts by faction here: every poll the controller force-feeds
--     each living chaser hate on the ghost, and keeps them invulnerable,
--   * every fourth cake eaten wakes the Sugar Rage: an invulnerable golem
--     comes up out of the floor to chase you, the living chasers scatter to
--     their home corners (depop + respawn -- a fresh spawn carries no hate),
--     drop invulnerability and stay put for 45 seconds. Frightened ghosts
--     can be eaten,
--   * a chaser kill only counts when the shrouded ghost lands it (chaser
--     scripts signal 100+color here); a cake death only counts for the
--     ghost (cake script signals 200 here),
--   * fail = the clock runs out, a member dies (skyshrine/player.pl routes
--     here), or everyone zones out. Failures never lock out; the expedition
--     is torn down,
--   * win = all four colored ones eaten AND all 24 cakes: 18h replay
--     lockout, the shroud stripped, four McKenzie's Special Brews (41408),
--     ride home to PoK.
-- Version 0 Skyshrine (the world zone) is untouched; the v41 instance is
-- empty but for this controller and the runtime cast.

local SNACK_VERSION  = 41
local SNACK_SHROUD   = 504
local SKYSHRINE_ID   = 114 -- zoneidnumber (canonical), not zone.id
local BREW_ITEM      = 41408 -- McKenzie's Special Brew (alternate_currency 18)

local MISSION_SECONDS = 600 -- ten minutes of maze
local POLL_MS       = 1000
local SHROUD_POLLS  = 5     -- shroud work runs on the 5s cadence
local SEND_HOME_MS  = eq.seconds("10s") * 1000

local WINDOW_SECONDS = 45   -- the frightened window per Sugar Rage
local RAGE_EVERY     = 4    -- every Nth cake wakes the golem

local CAKE_ID   = 1520001984
local GOLEM_ID  = 1520001983
local POK_ID    = 202
local POK_HOME  = { x = 263, y = 69, z = -125.375, h = 0 }

-- Chasers: npc id, display color, home corner (the frightened scatter
-- target). Homes are walkable floor points sampled from the zone's own
-- collision geometry (Maps/base/skyshrine.map, z 373-409 level).
local CHASERS = {
	{ id = 1520001979, name = "the Sad One",  home = { x = -1116.2, y = 1308.8, z = 401.7 } },
	{ id = 1520001980, name = "the Mad One",  home = { x = -433.2,  y = 848.0,  z = 377.8 } },
	{ id = 1520001981, name = "the Glad One", home = { x = -121.6,  y = 709.7,  z = 402.8 } },
	{ id = 1520001982, name = "the Bad One",  home = { x = -679.7,  y = 1066.6, z = 402.8 } },
}

-- 24 frosted cakes: walkable maze-level floor points, east halls (z 373)
-- and west maze proper (z 398).
local CAKES = {
	{ x = -1122.9, y = 1297.8, z = 408.8 },
	{ x = -118.3,  y = 709.7,  z = 373.8 },
	{ x = -669.7,  y = 1068.2, z = 398.8 },
	{ x = -439.8,  y = 823.0,  z = 373.8 },
	{ x = -901.6,  y = 1167.0, z = 398.8 },
	{ x = -523.1,  y = 972.9,  z = 378.8 },
	{ x = -1060.2, y = 1177.0, z = 398.8 },
	{ x = -763.0,  y = 1164.5, z = 398.8 },
	{ x = -568.1,  y = 821.3,  z = 373.8 },
	{ x = -203.2,  y = 702.1,  z = 398.8 },
	{ x = -479.8,  y = 898.0,  z = 373.8 },
	{ x = -568.1,  y = 898.0,  z = 373.8 },
	{ x = -972.9,  y = 1177.3, z = 398.8 },
	{ x = -689.7,  y = 1136.2, z = 398.8 },
	{ x = -832.7,  y = 1154.5, z = 398.8 },
	{ x = -1097.9, y = 1232.8, z = 398.8 },
	{ x = -509.8,  y = 821.3,  z = 373.8 },
	{ x = -421.5,  y = 898.0,  z = 373.8 },
	{ x = -466.5,  y = 976.3,  z = 378.8 },
	{ x = -166.6,  y = 721.4,  z = 373.8 },
	{ x = -538.1,  y = 871.3,  z = 373.8 },
	{ x = -451.5,  y = 871.3,  z = 373.8 },
	{ x = -1099.4, y = 1194.1, z = 398.8 },
	{ x = -1092.9, y = 1271.2, z = 408.8 },
}

local CAKE_TOTAL = #CAKES

-- The maze talks. One line per cake, cycling; the milestones get their own.
local CAKE_LINES = {
	"You eat the cake. The cake does not notice.",
	"Sweet. Dense. A little like forgiveness.",
	"The colored ones are watching. They are always watching.",
	"EIGHT CAKES -- says the old reptile at the base of your skull -- and the hole is still there.",
	"Somewhere behind the walls, something glad is still glad.",
	"You have eaten more cake than feeling. This is the correct order.",
	"The maze does not care. That is why you came here.",
	"The cakes do not run. The cakes never ran. That was the whole appeal.",
}
local RAGE_LINES = {
	"SUGAR RAGE -- ANCIENT REPTILIAN BRAIN -- IT COMES UP OUT OF THE FLOOR.",
	"The floor gives up a golem. It has your name in its mouth.",
	"Something in the sugar remembered being wronged.",
}

-- state: "idle" (waiting for the first shrouded ghost) -> "hunting" ->
-- "won" / "failed"
local state        = "idle"
local seen_unshrouded = {} -- char_id -> true (present last shroud poll)
local prepared     = {}    -- char_id -> true once the ghost is dressed
local cakes_eaten  = 0
local eaten        = { false, false, false, false }
local ticks_left   = MISSION_SECONDS
local empty_polls  = 0
local window_open  = false
local window_ticks = 0
local cake_line    = 0

local function chaser_dead(npc)
	local type_id = npc:GetNPCTypeID()
	for i, chaser in ipairs(CHASERS) do
		if type_id == chaser.id then
			return true, i
		end
	end
	return false, 0
end

local function cleanup_cast()
	for _, chaser in ipairs(CHASERS) do
		eq.depop(chaser.id)
	end
	eq.depop(CAKE_ID)
	eq.depop(GOLEM_ID)
end

-- expedition members currently in this zone
local function members_in_zone()
	local members = {}
	local clients = eq.get_entity_list():GetClientList()
	for client in clients.entries do
		if client.valid then
			local dz = client:GetExpedition()
			if dz.valid
				and dz:GetZoneID() == SKYSHRINE_ID
				and dz:GetZoneVersion() == SNACK_VERSION then
				table.insert(members, client)
			end
		end
	end
	return members
end

local function ghosts_in_zone(members)
	local ghosts = {}
	for _, client in ipairs(members) do
		if client:GetRace() == 117 then
			table.insert(ghosts, client)
		end
	end
	return ghosts
end

-- Monster missions dismiss pets: the ghost form is not supposed to have
-- one, and a player pet would make short work of the colored ones.
local function dismiss_pets(client)
	local pet = client:GetPet()
	if pet and pet.valid then
		pet:Depop()
	end
end

local function all_chasers_dead()
	for _, dead in ipairs(eaten) do
		if not dead then
			return false
		end
	end
	return true
end

local function snack_complete()
	return all_chasers_dead() and cakes_eaten >= CAKE_TOTAL
end

-- The frightened window: the golem rises, the living chasers scatter to
-- their corners (depop + respawn -- a fresh spawn carries no hate), lose
-- invulnerability and stay put until the rage drains.
local function open_window(ghost)
	if window_open then
		window_ticks = WINDOW_SECONDS -- another cake: the rage holds longer
		return
	end
	window_open = true
	window_ticks = WINDOW_SECONDS
	for i, chaser in ipairs(CHASERS) do
		if not eaten[i] then
			eq.depop(chaser.id)
			eq.spawn2(chaser.id, 0, 0, chaser.home.x, chaser.home.y, chaser.home.z, 0)
		end
	end
	local golem = eq.spawn2(GOLEM_ID, 0, 0,
		ghost:GetX() + math.random(-30, 30),
		ghost:GetY() + math.random(-30, 30),
		ghost:GetZ(), 0)
	if golem and golem.valid then
		golem:SetInvul(true)
	end
	eq.set_timer("snack_rage_end", WINDOW_SECONDS * 1000)
	eq.zone_emote(13, RAGE_LINES[math.random(#RAGE_LINES)])
end

local function close_window()
	window_open = false
	eq.stop_timer("snack_rage_end")
	eq.depop(GOLEM_ID)
	eq.zone_emote(15, "The rage drains back into the floor. The colored ones harden their hearts -- and their hides.")
end

-- win: 18h replay lockout, shrouds stripped, four Brews each, ride home.
-- Reached from either authority: skyshrine/player.pl relaying the task
-- completion, or this controller's own tally.
local function win_snack()
	if state == "won" or state == "failed" then
		return
	end
	state = "won"
	close_window()
	local exp = eq.get_expedition()
	if exp.valid then
		exp:AddReplayLockout(eq.seconds("18h"))
	end
	eq.zone_emote(15, "The last colored one slides down, and the maze goes quiet. It does not thank you. Mazes never do.")
	for _, client in ipairs(ghosts_in_zone(members_in_zone())) do
		client:RemoveShroud()
		client:SummonItem(BREW_ITEM, 4)
		client:Message(15, "Old Man McKenzie's voice, somewhere behind your eyes: 'There. Now you know what I know. The eating never fills the hole -- but the eating is good.' Four bottles of the Special Brew find your hand.")
	end
	eq.set_timer("snack_send_home", SEND_HOME_MS)
end

-- Instant fail: red text everywhere, shrouds stripped, cast swept, boot.
-- Any loss condition routes here: clock run out, member death
-- (skyshrine/player.pl), or the maze emptied of ghosts.
local function fail_snack(reason)
	if state == "failed" or state == "won" then
		return
	end
	state = "failed"
	close_window()
	cleanup_cast()
	eq.zone_emote(MT.Red, "The maze keeps its cakes. " .. reason .. " Old Man McKenzie's Midnight Snack has FAILED.")
	for _, client in ipairs(members_in_zone()) do
		client:SendMarqueeMessage(MT.Red, 255, 1000, 1500, 4000, "THE MAZE WINS")
		client:Message(MT.Red, "The ghost sloughs off you like frost in the sun. McKenzie says nothing. Somehow that is worse.")
		client:SendSound()
		client:RemoveShroud()
	end
	eq.set_timer("snack_fail_kick", 5000)
end

local function start_snack()
	state = "hunting"
	ticks_left = MISSION_SECONDS
	cakes_eaten = 0
	eaten = { false, false, false, false }
	cake_line = 0
	for _, point in ipairs(CAKES) do
		eq.spawn2(CAKE_ID, 0, 0, point.x, point.y, point.z, 0)
	end
	for _, chaser in ipairs(CHASERS) do
		eq.spawn2(chaser.id, 0, 0, chaser.home.x, chaser.home.y, chaser.home.z, 0)
	end
	eq.zone_emote(15, "The maze remembers being walked. Twenty-four cakes sit in its corridors, round and sweet and completely unaware of what they are. Four colored ones open their eyes. RUN.")
end

function event_spawn(e)
	state = "idle"
	seen_unshrouded = {}
	prepared = {}
	cakes_eaten = 0
	eaten = { false, false, false, false }
	ticks_left = MISSION_SECONDS
	empty_polls = 0
	window_open = false
	window_ticks = 0
	cake_line = 0
	eq.set_timer("snack_poll", POLL_MS)
	eq.set_timer("snack_shroud", SHROUD_POLLS * POLL_MS)
end

function event_signal(e)
	if e.signal == 200 then
		-- a cake script reporting the ghost ate it
		if state == "hunting" then
			cakes_eaten = cakes_eaten + 1
			if cakes_eaten >= CAKE_TOTAL then
				eq.zone_emote(15, "That was the last cake. The maze is empty of everything but you and what hunts you.")
				if snack_complete() then
					win_snack()
				end
				return
			end
			if cakes_eaten % RAGE_EVERY == 0 then
				local members = members_in_zone()
				local ghosts = ghosts_in_zone(members)
				if #ghosts > 0 then
					open_window(ghosts[1])
				end
			else
				cake_line = cake_line + 1
				eq.zone_emote(15, CAKE_LINES[(cake_line % #CAKE_LINES) + 1])
			end
			if cakes_eaten == math.floor(CAKE_TOTAL / 2) then
				eq.zone_emote(15, "Half the cakes are gone. The hole in you is exactly the size it was. EAT.")
			end
			if snack_complete() then
				win_snack()
			end
		end
	elseif e.signal >= 101 and e.signal <= 104 then
		-- a chaser script reporting a shrouded ghost's kill (100 + color)
		if state == "hunting" then
			local which = e.signal - 100
			eaten[which] = true
			eq.zone_emote(15, CHASERS[which].name .. " is eaten. Somewhere a color goes out.")
			if snack_complete() then
				win_snack()
			end
		end
	elseif e.signal == 1 and (state == "hunting" or state == "idle") then
		-- skyshrine/player.pl: the Midnight Snack task completed
		win_snack()
	elseif e.signal == 2 and (state == "hunting" or state == "idle") then
		fail_snack("The ghost has fallen.")
	end
end

function event_timer(e)
	if e.timer == "snack_poll" then
		if state == "failed" or state == "won" then
			return
		end
		local members = members_in_zone()

		if state == "hunting" then
			-- a dead expedition member loses the snack on the spot (backup
			-- for skyshrine/player.pl event_death, which routes to the same
			-- fail path)
			for _, client in ipairs(members) do
				if client:GetHP() <= 0 then
					client:RemoveShroudSilent()
					fail_snack("The ghost has fallen.")
					return
				end
			end

			-- the maze emptied of ghosts: zone-out, bind release, whatever
			-- -- an unattended binge is a lost binge
			if #members == 0 then
				empty_polls = empty_polls + 1
				if empty_polls >= 2 then
					fail_snack("The ghost has left the maze.")
					return
				end
			else
				empty_polls = 0
			end

			-- the clock
			ticks_left = ticks_left - 1
			if ticks_left <= 0 then
				fail_snack("Ten minutes, and the maze still holds its cakes.")
				return
			elseif ticks_left == 60 then
				eq.zone_emote(15, "One minute left, and the hole is still hungry.")
			elseif ticks_left == 10 then
				eq.zone_emote(15, "Ten seconds!")
			end

			-- the frightened window
			if window_open then
				window_ticks = window_ticks - 1
				if window_ticks <= 0 then
					close_window()
				end
			end

			-- invulnerability and pursuit. The controller owns both: the
			-- colored ones are untouchable while the rage sleeps, and no
			-- faction decides who they hunt -- the ghost does.
			local ghosts = ghosts_in_zone(members)
			local npcs = eq.get_entity_list():GetNPCList()
			for npc in npcs.entries do
				if npc.valid then
					local dead, index = chaser_dead(npc)
					if dead and not eaten[index] then
						if window_open then
							npc:SetInvul(false)
						else
							npc:SetInvul(true)
							for _, ghost in ipairs(ghosts) do
								npc:AddToHateList(ghost, 50, 0)
							end
						end
					elseif npc:GetNPCTypeID() == GOLEM_ID then
						-- Sugar Rage: unkillable, and only ever hungry for
						-- the ghost
						npc:SetInvul(true)
						for _, ghost in ipairs(ghosts) do
							npc:AddToHateList(ghost, 50, 0)
						end
					end
				end
			end
		end
	elseif e.timer == "snack_shroud" then
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
			if client:GetRace() ~= 117 then
				if seen_unshrouded[id] then
					client:ApplyShroud(SNACK_SHROUD)
					dismiss_pets(client)
					-- Live-like: the shroud strips the real character's
					-- buffs so nothing rides along into the ghost.
					client:BuffFadeAll()
					prepared[id] = true
					seen_unshrouded[id] = nil
					client:Message(15, "Cold and appetite close over you. You are the ghost now -- not the dead kind, the hungry kind. Eat every cake in the maze. Fear the colored ones. Fear the Sugar Rage more, and remember: rage makes them soft.")
				else
					seen_unshrouded[id] = true
				end
			elseif not prepared[id] then
				-- Persisted shroud: the character logged out as the ghost,
				-- so LoadAndApplyShroudState already re-applied race 117.
				prepared[id] = true
				dismiss_pets(client)
				client:BuffFadeAll()
			end
		end

		if state == "idle" then
			local ghosts = ghosts_in_zone(members)
			if #ghosts > 0 then
				start_snack()
			end
		end
	elseif e.timer == "snack_rage_end" then
		if state == "hunting" and window_open then
			close_window()
		end
	elseif e.timer == "snack_send_home" then
		cleanup_cast()
		for _, client in ipairs(members_in_zone()) do
			client:MovePC(POK_ID, POK_HOME.x, POK_HOME.y, POK_HOME.z, POK_HOME.h)
		end
		eq.depop()
	elseif e.timer == "snack_fail_kick" then
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
