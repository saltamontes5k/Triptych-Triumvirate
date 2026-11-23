-- soldungb/#Defending_the_Lair_Controller.lua
-- NMS monster mission: Old Man McKenzie's Defending the Lair (soldungb v44).
-- The simplest of the McKenzie hallucinations: EVERYBODY is Lord Nagafen --
-- the whole group wears the dragon (spirit template 140555, the v457 form) --
-- and one greedy adventuring party of eight comes up the hall for the hoard.
-- Toast all eight and the dream pays out: 18h replay lockout, one McKenzie's
-- Special Brew (41408) each, the treasure chest stands open for a 60-second
-- loot window, then everyone rides home to PoK.
--   * shrouds every expedition member >= 5s after zone-in (the client's
--     deferred OP_Shroud window) and re-applies after a revive; the raid
--     starts 10s after the first dragon is wearing scales -- no says needed,
--   * the say-driven dragon abilities (breath/roar/bellow/heal/nuke/tap --
--     the fun of being a real dragon) live in soldungb/player.pl,
--   * a dead dragon is revived every 30s with Revive (391, no XP loss): in a
--     delusion you do not really lose. The only fail is abandoning the lair,
--   * the task's 0/8 kill counter updates for the task holder; the census
--     here is the win authority.
-- Balance knobs: the raider npc_types stats (v457), REZ_POLLS, SEND_HOME_MS.
-- soldungb/player.pl owns the ability says and the death-strip; this script
-- owns the encounter.

local LAIR_VERSION    = 44
local SOLDUNGB_ID     = 32 -- zoneidnumber (canonical), not zone.id
local POK_ID          = 202
local POK_HOME        = { x = 263, y = 69, z = -125.375, h = 0 } -- McKenzie's spot
local DRAGON_TEMPLATE = 140555 -- spirit template: Lord Nagafen (race 49)
local DRAGON_RACE     = 49
local BREW_ITEM       = 41408 -- McKenzie's Special Brew (alternate_currency 18)
local CHEST_ID        = 1520002019
local REZ_SPELL       = 391   -- Revive (no XP loss)

local LAIR_CENTER = { x = -871, y = -1395, z = 104.88 } -- Lord Nagafen's own hoard spot

-- The greedy adventuring party: eight raiders (v457 npc_types), fixed size
-- like the other McKenzie counters (twelve whelps, twenty-four cakes).
local PARTY = { 1520002011, 1520002012, 1520002013, 1520002014,
                1520002015, 1520002016, 1520002017, 1520002018 }
local RING_OFFSETS = {
	{  60,   0 }, {   0,  60 }, { -60,   0 }, {   0, -60 },
	{  85,  30 }, {  85, -30 }, { -85,  30 }, { -85, -30 },
}

local POLL_MS        = 1000
local SHROUD_POLLS   = 5  -- shroud work runs on the 5s cake cadence
local START_POLLS    = 10 -- the raid starts 10s after the first dragon wears scales
local REZ_POLLS      = 30 -- a dead dragon is revived every 30s
local SEND_HOME_MS   = eq.seconds("60s") * 1000 -- the live ~60s loot window
local KICK_MS        = 5000

-- state: "setup" (dragons dressing) -> "raid" -> "won" / "failed"
local state = "setup"
local seen_unshrouded = {} -- char_id -> true (present last shroud poll)
local start_countdown = -1 -- -1 = no dragon shrouded yet
local empty_polls   = 0
local rez_countdown = REZ_POLLS

local function party_alive()
	local count = 0
	local npcs = eq.get_entity_list():GetNPCList()
	for npc in npcs.entries do
		if npc.valid then
			local type_id = npc:GetNPCTypeID()
			for _, id in ipairs(PARTY) do
				if type_id == id then
					count = count + 1
					break
				end
			end
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
				and dz:GetZoneID() == SOLDUNGB_ID
				and dz:GetZoneVersion() == LAIR_VERSION then
				table.insert(members, client)
			end
		end
	end
	return members
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

-- Shroud work: apply the dragon to every member (two-poll deferred, the
-- cake's OP_Shroud window), with the persisted-shroud relog path (race
-- already matches -> the engine already re-applied the form).
local function shroud_work(members)
	local present = {}
	for _, client in ipairs(members) do present[client:CharacterID()] = true end
	for cid in pairs(seen_unshrouded) do
		if not present[cid] then seen_unshrouded[cid] = nil end
	end

	for _, client in ipairs(members) do
		dismiss_pets(client)
		local id = client:CharacterID()
		if client:GetRace() == DRAGON_RACE then
			seen_unshrouded[id] = nil
		elseif seen_unshrouded[id] then
			client:ApplySpiritShroud(DRAGON_TEMPLATE)
			dismiss_pets(client)
			-- Live-like: the shroud strips the real character's buffs so
			-- nothing rides along into the hallucination.
			client:BuffFadeAll()
			seen_unshrouded[id] = nil
		else
			seen_unshrouded[id] = true
		end
	end
end

local function cleanup_party()
	for _, id in ipairs(PARTY) do
		eq.depop(id)
	end
	eq.depop(CHEST_ID)
end

-- Instant fail: the raid is swept, shrouds off, red text, hard boot. In a
-- delusion you do not really lose -- only abandoning the lair routes here.
local function fail_dream(reason)
	if state == "failed" or state == "won" then
		return
	end
	state = "failed"
	cleanup_party()
	eq.zone_emote(MT.Red, "The dream slips away. " .. reason .. " Old Man McKenzie's Defending the Lair has FAILED.")
	for _, client in ipairs(members_in_zone()) do
		client:SendMarqueeMessage(MT.Red, 255, 1000, 1500, 4000, "THE DREAM SLIPS AWAY")
		client:Message(MT.Red, "THE DREAM SLIPS AWAY.")
		client:Message(MT.Red, reason .. " You are cast out of the hallucination.")
		client:SendSound()
		client:RemoveSpiritShroud()
	end
	eq.set_timer("lair_fail_kick", KICK_MS)
end

local function spawn_party()
	eq.zone_emote(15, "Up the hall come eight treasure-hunters, eyes fixed on the hoard. You have fire. They have ideas.")
	for i, id in ipairs(PARTY) do
		local off = RING_OFFSETS[i]
		eq.spawn2(id, 0, 0, LAIR_CENTER.x + off[1], LAIR_CENTER.y + off[2], LAIR_CENTER.z, 0)
	end
end

-- win: lockout, Brew each, the chest for the 60s loot window, ride home.
local function win_dream()
	state = "won"
	local exp = eq.get_expedition()
	if exp.valid then
		exp:AddReplayLockout(eq.seconds("18h"))
	end
	eq.zone_emote(15, "The last treasure-hunter runs for the tunnel, on fire. The hoard stands, and being a real dragon is EVERYTHING McKenzie promised.")
	eq.spawn2(CHEST_ID, 0, 0, LAIR_CENTER.x + 40, LAIR_CENTER.y + 40, LAIR_CENTER.z, 0)
	for _, client in ipairs(members_in_zone()) do
		client:RemoveSpiritShroud()
		client:SummonItem(BREW_ITEM, 1)
		client:Message(15, "Old Man McKenzie's voice rolls up from the deep of the lair: 'HA! Eight greedy little two-legs, and the hoard never moved. One Brew for the dragon -- and mind you, the gloves and the trinket those vermin never clawed are in my shop, priced in Brew.'")
	end
	eq.set_timer("lair_send_home", SEND_HOME_MS)
end

function event_spawn(e)
	state = "setup"
	seen_unshrouded = {}
	start_countdown = -1
	empty_polls   = 0
	rez_countdown = REZ_POLLS
	eq.set_timer("lair_poll", POLL_MS)
end

function event_timer(e)
	if e.timer == "lair_poll" then
		if state == "failed" or state == "won" then
			return
		end
		local members = members_in_zone()

		-- an abandoned lair is a lost lair
		if #members == 0 then
			empty_polls = empty_polls + 1
			if empty_polls >= 2 then
				fail_dream("The lair stands empty.")
				return
			end
		else
			empty_polls = 0
		end

		-- shroud work on the 5s cadence
		if state == "setup" then
			shroud_work(members)

			-- the raid starts 10s after the first dragon is wearing scales
			if start_countdown < 0 then
				for _, client in ipairs(members) do
					if client:GetRace() == DRAGON_RACE and client:GetHP() > 0 then
						start_countdown = START_POLLS
						eq.zone_emote(15, "Scale and fire close over you. You are Lord Nagafen now -- ALL of you; do not ask how the dream works. The gold is YOURS.")
						eq.zone_emote(15, "Your dragon abilities wait in the AA window (Lava Breath, Dragon Roar, Dragon Bellow, Perfect Heal, Dragon Gaze, Dragon Drain) -- and the old words still work: say breath, roar, bellow, heal, nuke, or tap.")
						break
					end
				end
			elseif start_countdown > 0 then
				start_countdown = start_countdown - 1
				if start_countdown == 0 then
					state = "raid"
					spawn_party()
				end
			end
		elseif state == "raid" then
			-- shroud work keeps running so a revive (or a late join) dresses
			shroud_work(members)

			-- revive dead dragons every 30s (Revive 391, no XP loss)
			rez_countdown = rez_countdown - 1
			if rez_countdown <= 0 then
				rez_countdown = REZ_POLLS
				for _, client in ipairs(members) do
					if client:GetHP() <= 0 then
						e.self:CastSpell(REZ_SPELL, client:GetID())
						client:Message(15, "The dream knits you back together. To your feet, worm -- the hoard is still yours.")
					end
				end
			end

			-- backup fixation: keep the party on the nearest dragon even if
			-- natural aggro loses them
			local npcs = eq.get_entity_list():GetNPCList()
			for npc in npcs.entries do
				if npc.valid then
					local is_raider = false
					local type_id = npc:GetNPCTypeID()
					for _, id in ipairs(PARTY) do
						if type_id == id then
							is_raider = true
							break
						end
					end
					if is_raider then
						local best, bestd = nil, nil
						for _, client in ipairs(members) do
							if client:GetHP() > 0 then
								local dx = npc:GetX() - client:GetX()
								local dy = npc:GetY() - client:GetY()
								local d2 = dx * dx + dy * dy
								if not bestd or d2 < bestd then
									best, bestd = client, d2
								end
							end
						end
						if best then
							npc:AddToHateList(best, 100, 0)
						end
					end
				end
			end

			if party_alive() == 0 then
				win_dream()
			end
		end
	elseif e.timer == "lair_send_home" then
		-- the loot window ran out: sweep the lair and ride home to McKenzie
		cleanup_party()
		for _, client in ipairs(members_in_zone()) do
			client:MovePC(POK_ID, POK_HOME.x, POK_HOME.y, POK_HOME.z, POK_HOME.h)
		end
		eq.depop()
	elseif e.timer == "lair_fail_kick" then
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
