--[[
Irrissa the Seer (Solteris event 5, island 3) - 421055, with four
a_trueborn_summoner (421056) escorts and their a_portal_attendant (421057)
retinues.

Core mechanics (Rasper's guide), permissively tuned:
  * Four summoners stand by the portal. As Irrissa descends (98/96/94/92%)
    one activates and must be killed quickly; a killed summoner's four
    attendants join the fight. A summoner that survives its window heals
    full and summons a dervish enforcer instead.
  * The Seer's Touch (11733) lands on random targets - silence + dd; the
    victim should run out from the raid.
  * Irrissa "travels in time": at thresholds she blinks (aggro wipe + brief
    invulnerable window), and at 40%/10% she drags damaged copies of her
    past selves into the fight.
  * Killing Irrissa completes the event.

Summoner/attendant state is tracked via entity variables on the mobs.
]]

local CONTROLLER = 421000;
local CHEST      = 421094;
local SIGNAL_KEY = 1005;

local IRISSA     = 421055;
local SUMMONER   = 421056;
local ATTENDANT  = 421057;
local ENFORCER   = 421084;  -- dervish summoned by a forgotten summoner

local GATES      = { 98, 96, 94, 92 };
local TOUCH      = 11733;   -- The Seer's Touch

-- summoners stand around the portal near Irrissa (-1121, 3255, 2659)
local SUMMONER_POS = {
	{ -1161, 3215, 2659 }, { -1081, 3215, 2659 },
	{ -1161, 3295, 2659 }, { -1081, 3295, 2659 },
}

function expedition_size()
	local expedition = eq.get_expedition();
	if expedition.valid then
		return math.max(1, expedition:GetMemberCount());
	end
	return 1;
end

function Irrissa_Spawn(e)
	-- summon the four summoner escorts
	for i, pos in ipairs(SUMMONER_POS) do
		local npc = eq.spawn2(SUMMONER, 0, 0, pos[1], pos[2], pos[3], 0);
		if npc ~= nil then
			npc:SetEntityVariable("summoner_slot", tostring(i));
			npc:SetEntityVariable("summoner_state", "waiting");  -- waiting | active | done
		end
	end
end

function Irrissa_Combat(e)
	if e.joined then
		e.self:SetTimerMS("touch", 20 * 1000);
		e.self:SetTimerMS("phase", 2 * 1000);
		e.self:Emote("unfolds from the future, her many eyes settling on the present.");
	else
		e.self:StopTimer("touch");
		e.self:StopTimer("phase");
	end
end

function live_summoners()
	local out = {};
	for _, npc in pairs(eq.get_entity_list():GetNPCList() or {}) do
		if npc ~= nil and npc:GetNPCTypeID() == SUMMONER then
			table.insert(out, npc);
		end
	end
	return out;
end

function activate_summoner(irissa)
	for _, npc in ipairs(live_summoners()) do
		if (npc:GetEntityVariable("summoner_state") or "") == "waiting" then
			npc:SetEntityVariable("summoner_state", "active");
			npc:SetRunning(true);
			npc:Emote("a trueborn summoner hurries toward the portal!");
			return;
		end
	end
end

function Irrissa_Timer(e)
	if e.timer == "touch" then
		local victim = eq.get_entity_list():GetRandomClient(
			e.self:GetX(), e.self:GetY(), e.self:GetZ(), 500);
		if victim ~= nil then
			e.self:CastSpell(TOUCH, victim:GetID());
			victim:Message(MT.Red, "The Seer's Touch consumes you - run far from Irrissa!");
		end
		e.self:SetTimerMS("touch", 25 * 1000);
	elseif e.timer == "phase" then
		local pct = e.self:GetHPRatio();

		-- summoner gates
		local gate_index = tonumber(e.self:GetEntityVariable("gate_index") or "1") or 1;
		if gate_index <= #GATES and pct <= GATES[gate_index] then
			e.self:SetEntityVariable("gate_index", tostring(gate_index + 1));
			activate_summoner(e.self);
			e.self:SetTimerMS("gate_check", 5 * 1000);
		end

		-- time-copy thresholds
		local marks = e.self:GetEntityVariable("time_mark") or "";
		local function marked(tag)
			return string.find(marks, tag, 1, true) ~= nil;
		end
		local function mark(tag)
			e.self:SetEntityVariable("time_mark", marks .. tag .. ";");
		end

		if pct <= 40 and not marked("40") then
			mark("40");
			e.self:Emote("tears through time - a past self stumbles into the present!");
			local copy = eq.spawn2(IRISSA, 0, 0,
				e.self:GetX() + 60, e.self:GetY() + 30, e.self:GetZ(), 0);
			if copy ~= nil then
				copy:SetEntityVariable("time_copy", "1");
				copy:SetHP(math.floor(copy:GetMaxHP() * 0.20));
				local t = e.self:GetTarget();
				if t ~= nil then
					copy:AddToHateList(t, 1);
				end
			end
		elseif pct <= 10 and not marked("10") then
			mark("10");
			e.self:Emote("another shard of Irrissa's past tears free!");
			local copy = eq.spawn2(IRISSA, 0, 0,
				e.self:GetX() - 60, e.self:GetY() + 30, e.self:GetZ(), 0);
			if copy ~= nil then
				copy:SetEntityVariable("time_copy", "1");
				copy:SetHP(math.floor(copy:GetMaxHP() * 0.30));
				local t = e.self:GetTarget();
				if t ~= nil then
					copy:AddToHateList(t, 1);
				end
			end
		end

		e.self:SetTimerMS("phase", 2 * 1000);
	elseif e.timer == "gate_check" then
		-- punish summoners left alive past their window
		for _, npc in ipairs(live_summoners()) do
			if (npc:GetEntityVariable("summoner_state") or "") == "active" then
				npc:SetEntityVariable("summoner_state", "done");
				npc:Heal();
				npc:Emote("the summoner finishes its calling - a dervish enforcer tears through!");
				eq.spawn2(ENFORCER, 0, 0, npc:GetX() + 10, npc:GetY() + 10, npc:GetZ(), 0);
			end
		end
	end
end

function Irrissa_Death(e)
	-- time copies may outlive the real body; only the main kill completes
	if e.self:GetEntityVariable("time_copy") == "1" then
		eq.zone_emote(MT.Red, "A past echo of Irrissa collapses into sand.");
		return;
	end

	eq.depop_all(SUMMONER);
	eq.depop_all(ATTENDANT);
	eq.depop_all(ENFORCER);

	local expedition = eq.get_expedition();
	local x, y, z = e.self:GetX(), e.self:GetY(), e.self:GetZ();
	if expedition.valid then
		local chest = eq.unique_spawn(CHEST, 0, 0, x, y, z + 5, 0);
		if chest ~= nil then
			expedition:SetLootEventBySpawnID(chest:GetID(), "Irrissa the Seer");
		end
	end
	eq.signal(CONTROLLER, SIGNAL_KEY);
end

function Summoner_Death(e)
	if e.self:GetEntityVariable("summoner_state") ~= "done" then
		e.self:SetEntityVariable("summoner_state", "done");
		eq.zone_emote(MT.Red, "The summoner falls - its portal attendants rush to avenge it!");
		for i = 1, 4 do
			eq.spawn2(ATTENDANT, 0, 0,
				e.self:GetX() + math.random(-25, 25),
				e.self:GetY() + math.random(-25, 25),
				e.self:GetZ(), 0);
		end
	end
end

function event_encounter_load(e)
	eq.register_npc_event('irissa', Event.spawn,          IRISSA,    Irrissa_Spawn);
	eq.register_npc_event('irissa', Event.combat,         IRISSA,    Irrissa_Combat);
	eq.register_npc_event('irissa', Event.timer,          IRISSA,    Irrissa_Timer);
	eq.register_npc_event('irissa', Event.death_complete, IRISSA,    Irrissa_Death);
	eq.register_npc_event('irissa', Event.death_complete, SUMMONER,  Summoner_Death);
end

function event_encounter_unload(e)
end
