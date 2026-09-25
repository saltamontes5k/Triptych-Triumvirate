--[[
Mayong's Mistresses (Solteris event 1, island 1) - Althea (421001),
Brenda (421002), Christine (421003) and the Guardians of the Nine Primes.

Core mechanics (Rasper's guide), permissively tuned:
  * Hail a sister to hear which Primes remain; say "prime N" to summon that
    guardian on its platform (any order, multiple up at once).
  * Each guardian killed credits an artifact toward the 9 needed.
  * All 9 dead -> the sisters duel; a random survivor attacks, augmented by
    the artifacts of the sisters that fell.
  * Killing the surviving sister spawns the event chest and the lockout.
  * No 5-minute fail timer: the event stays triggerable until finished
    (solo/multiclass friendly).

State is kept on the per-instance zone controller (421000) entity variables:
  mistresses_artifacts = killed guardian count
  mistresses_duel      = 1 once the duel has resolved
]]

local CONTROLLER = 421000;
local CHEST      = 421090;
local SIGNAL_KEY = 1001;

local SISTERS = { [421001] = "Althea", [421002] = "Brenda", [421003] = "Christine" };

-- Guardian of the Nth Prime -> npc_type, artifact item, platform position
-- (Brewall map POIs negated; see 20260921_tbs_solteris_raid.sql).
local PRIMES = {
	{ 421030, 52692, -614, -636, 104 },  -- First Prime  (drachnid)
	{ 421031, 52693, -614, -743, 104 },  -- Second Prime (drachnid)
	{ 421032, 52694, -683, -826, 104 },  -- Third Prime  (werewolf)
	{ 421033, 52695, -789, -844, 104 },  -- Fourth Prime (werewolf)
	{ 421034, 52696, -881, -791, 104 },  -- Fifth Prime  (vampire)
	{ 421035, 52697, -918, -690, 104 },  -- Sixth Prime  (vampire)
	{ 421036, 52698, -881, -589, 104 },  -- Seventh Prime (gargoyle)
	{ 421037, 52699, -789, -536, 104 },  -- Eighth Prime (werewolf)
	{ 421038, 52700, -683, -554, 104 },  -- Ninth Prime  (gargoyle)
}

local ORDINALS = { "First", "Second", "Third", "Fourth", "Fifth", "Sixth",
	"Seventh", "Eighth", "Ninth" };

function get_controller()
	return eq.get_entity_list():GetNPCByNPCTypeID(CONTROLLER);
end

function artifact_count()
	local ctrl = get_controller();
	if ctrl ~= nil then
		return tonumber(ctrl:GetEntityVariable("mistresses_artifacts") or "0") or 0;
	end
	return 0;
end

function remaining_primes()
	local out = {};
	for i, p in ipairs(PRIMES) do
		if not eq.get_entity_list():IsMobSpawnedByNpcTypeID(p[1]) then
			table.insert(out, i);
		end
	end
	return out;
end

function summon_prime(n)
	local p = PRIMES[n];
	if p == nil then
		return false;
	end
	if eq.get_entity_list():IsMobSpawnedByNpcTypeID(p[1]) then
		return false;
	end
	local guardian = eq.unique_spawn(p[1], 0, 0, p[3], p[4], p[5], 0);
	if guardian ~= nil then
		guardian:SetEntityVariable("prime_index", tostring(n));
	end
	eq.zone_emote(MT.Red, "The Guardian of the " .. ORDINALS[n] .. " Prime answers the call of its mistresses!");
	return true;
end

function Sister_Say(e)
	if SISTERS[e.self:GetNPCTypeID()] == nil then
		return;
	end

	if e.message:find("hail") or e.message:find("help") then
		local remaining = remaining_primes();
		local list = "-";
		if #remaining > 0 then
			list = table.concat(remaining, ", ");
		end
		e.self:Say("The Guardians of the Nine Primes hold our artifacts. Say 'prime N' and I will call one forth. " ..
			tostring(artifact_count()) .. " of 9 artifacts are claimed. Remaining: " .. list);
		return;
	end

	local n = e.message:match("prime%s+(%d)");
	if n ~= nil then
		n = tonumber(n);
		if summon_prime(n) then
			e.self:Say("Awaken, Guardian of the " .. ORDINALS[n] .. " Prime!");
		else
			e.self:Say("That Guardian already walks, or answers to another number.");
		end
	end
end

function Guardian_Death(e)
	local ctrl = get_controller();
	if ctrl == nil then
		return;
	end

	local count = artifact_count() + 1;
	ctrl:SetEntityVariable("mistresses_artifacts", tostring(count));

	eq.zone_emote(MT.Red, "An artifact of the Primes is claimed! (" .. tostring(count) .. "/9)");

	if count >= 9 and (tonumber(ctrl:GetEntityVariable("mistresses_duel") or "0") or 0) == 0 then
		ctrl:SetEntityVariable("mistresses_duel", "1");
		eq.zone_emote(MT.Red, "The artifacts are gathered. The mistresses turn on one another!");
		-- start the duel clock on a living sister so it fires exactly once
		for id, _ in pairs(SISTERS) do
			local npc = eq.get_entity_list():GetNPCByNPCTypeID(id);
			if npc ~= nil then
				npc:SetTimerMS("duel", 10 * 1000);
				break;
			end
		end
	end
end

function Sister_Timer(e)
	if e.timer == "duel" then
		e.self:StopTimer("duel");

		-- random survivor of the sister duel
		local alive = {};
		for id, _ in pairs(SISTERS) do
			if eq.get_entity_list():GetNPCByNPCTypeID(id) ~= nil then
				table.insert(alive, id);
			end
		end

		if #alive == 0 then
			return;
		end

		local winner_id = alive[math.random(1, #alive)];
		for id, _ in pairs(SISTERS) do
			if id ~= winner_id then
				eq.depop_all(id);
			end
		end

		local winner = eq.get_entity_list():GetNPCByNPCTypeID(winner_id);
		if winner ~= nil then
			winner:SetEntityVariable("duel_winner", "1");
			winner:Emote("drinks in the stolen artifacts and turns on you with fury!");
			eq.zone_emote(MT.Red, SISTERS[winner_id] .. " stands triumphant, wreathed in the power of the Primes. Slay her!");
		end
	end
end

function Sister_Death(e)
	local ctrl = get_controller();
	local is_duel = false;
	if ctrl ~= nil then
		is_duel = (tonumber(ctrl:GetEntityVariable("mistresses_duel") or "0") or 0) == 1;
	end

	if not is_duel then
		-- sisters killed out of order: punish the skip by resetting progress
		eq.zone_emote(MT.Red, "The sisters shriek as one - the artifacts scatter back to the Primes!");
		if ctrl ~= nil then
			ctrl:SetEntityVariable("mistresses_artifacts", "0");
			ctrl:SetEntityVariable("mistresses_duel", "0");
		end
		for i, p in ipairs(PRIMES) do
			eq.depop_all(p[1]);
		end
		return;
	end

	-- duel winner slain: event complete
	for i, p in ipairs(PRIMES) do
		eq.depop_all(p[1]);
	end

	local expedition = eq.get_expedition();
	local x, y, z = e.self:GetX(), e.self:GetY(), e.self:GetZ();
	if expedition.valid then
		local chest = eq.unique_spawn(CHEST, 0, 0, x, y, z + 5, 0);
		if chest ~= nil then
			expedition:SetLootEventBySpawnID(chest:GetID(), "Mayong's Mistresses");
		end
	end
	eq.signal(CONTROLLER, SIGNAL_KEY);
end

function event_encounter_load(e)
	for id, _ in pairs(SISTERS) do
		eq.register_npc_event('mistresses', Event.say,            id, Sister_Say);
		eq.register_npc_event('mistresses', Event.timer,          id, Sister_Timer);
		eq.register_npc_event('mistresses', Event.death_complete, id, Sister_Death);
	end
	for i, p in ipairs(PRIMES) do
		eq.register_npc_event('mistresses', Event.death_complete, p[1], Guardian_Death);
	end
end

function event_encounter_unload(e)
end
