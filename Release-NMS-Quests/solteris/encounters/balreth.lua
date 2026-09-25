--[[
Rear Guard Captain Balreth (Solteris event 3, island 2) - 421040.
The "balance event": golem splits 1 -> 2 -> 4 -> 8(->16 live) with 5% sync.

Core mechanics (Rasper's guide), permissively tuned:
  * Each split tier must be taken to 20%; golems within a tier must stay
    within 5% HP of each other when the first one reaches 20%.
  * Balance failure: the tier heals 5%, powers up, and Uncontrollable
    Golems (421043) spawn - one per two expedition members. Destroying them
    still wins (the guide's updated fail mechanic), so overgeared groups
    can burn through.
  * Small expeditions (<6 members) cap the split tree at 4 golems instead
    of 8/16 so a solo player can physically keep them synced.
  * Dervish adds (421084) trickle in and a 6k zone AE goes off every 100s.

Split tiers live on the controller entity var balreth_tier:
  0 = Balreth, 1 = a_gargantuan_golem (421041), 2 = a_massive_golem (421042)
]]

local CONTROLLER = 421000;
local CHEST      = 421092;
local SIGNAL_KEY = 1003;

local BALRETH       = 421040;
local GOLEM_LARGE   = 421041;
local GOLEM_SMALL   = 421042;
local GOLEM_UNCTRL  = 421043;
local DERVISH       = 421084;

function expedition_size()
	local expedition = eq.get_expedition();
	if expedition.valid then
		return math.max(1, expedition:GetMemberCount());
	end
	return 1;
end

function get_tier()
	local ctrl = eq.get_entity_list():GetNPCByNPCTypeID(CONTROLLER);
	if ctrl ~= nil then
		return tonumber(ctrl:GetEntityVariable("balreth_tier") or "0") or 0;
	end
	return -1;  -- controller missing: treat as non-instanced, do nothing
end

function set_tier(t)
	local ctrl = eq.get_entity_list():GetNPCByNPCTypeID(CONTROLLER);
	if ctrl ~= nil then
		ctrl:SetEntityVariable("balreth_tier", tostring(t));
	end
end

function live_golems()
	local list = {};
	local el = eq.get_entity_list();
	for _, id in ipairs({ BALRETH, GOLEM_LARGE, GOLEM_SMALL }) do
		local npc = el:GetNPCByNPCTypeID(id);
		if npc ~= nil then
			table.insert(list, npc);
		end
	end
	return list;
end

function split_at(golem, tier)
	-- spawn children around the parent's position
	local kids = {};
	if tier == 0 then
		kids = { GOLEM_LARGE, GOLEM_LARGE };
	elseif tier == 1 then
		kids = { GOLEM_SMALL, GOLEM_SMALL, GOLEM_SMALL, GOLEM_SMALL };
	else
		-- final split: 8 for full raids, 4 for small expeditions
		local count = 8;
		if expedition_size() < 6 then
			count = 4;
		end
		for i = 1, count do
			table.insert(kids, GOLEM_SMALL);
		end
	end

	for i, kid in ipairs(kids) do
		local ang = (i / #kids) * 6.283;
		local npc = eq.spawn2(kid, 0, 0,
			golem:GetX() + math.cos(ang) * 25,
			golem:GetY() + math.sin(ang) * 25,
			golem:GetZ(), 0);
		if npc ~= nil then
			npc:SetEntityVariable("golem_tier", tostring(tier + 1));
			if tier >= 2 then
				npc:SetHP(math.floor(npc:GetMaxHP() * 0.55));  -- late tiers start damaged
			end
		end
	end

	eq.zone_emote(MT.Red, "The golem splits apart, its fragments rising again!");
end

function balance_fail(golems)
	-- heal the tier, power it up, and spawn killable fail adds
	local adds = math.max(1, math.floor(expedition_size() / 2));
	for _, g in ipairs(golems) do
		g:Heal();
		g:Emote("swells with uncontrolled energy!");
	end
	for i = 1, adds do
		local ang = (i / adds) * 6.283;
		eq.spawn2(GOLEM_UNCTRL, 0, 0,
			golems[1]:GetX() + math.cos(ang) * 60,
			golems[1]:GetY() + math.sin(ang) * 60,
			golems[1]:GetZ(), 0);
	end
	eq.zone_emote(MT.Red, "The balance is broken! Uncontrollable Golems pour from the shattered fragments - destroy them!");
end

function Balreth_Combat(e)
	if e.joined then
		e.self:SetTimerMS("zoneae", 100 * 1000);
		e.self:SetTimerMS("dervish", 45 * 1000);
		e.self:SetTimerMS("phase", 3 * 1000);
		e.self:Emote("rumbles, 'None shall pass the rear guard.'");
	else
		e.self:StopTimer("zoneae");
		e.self:StopTimer("dervish");
		e.self:StopTimer("phase");
	end
end

function Balreth_Timer(e)
	if e.timer == "zoneae" then
		local target = e.self:GetTarget();
		if target ~= nil then
			e.self:CastSpell(11666, target:GetID());  -- Ground Punch (zone AE stand-in)
		end
		e.self:SetTimerMS("zoneae", 100 * 1000);
	elseif e.timer == "dervish" then
		-- keep a couple of dervishes trickling in while golems live
		if #live_golems() > 0 and not eq.get_entity_list():IsMobSpawnedByNpcTypeID(DERVISH) then
			eq.spawn2(DERVISH, 0, 0,
				e.self:GetX() + math.random(-50, 50),
				e.self:GetY() + math.random(-50, 50),
				e.self:GetZ(), 0);
		end
		e.self:SetTimerMS("dervish", 45 * 1000);
	elseif e.timer == "phase" then
		local golems = live_golems();
		if #golems == 0 then
			return;  -- everything dead; death handler finishes the event
		end

		local lowest = 100;
		for _, g in ipairs(golems) do
			local pct = g:GetHPRatio();
			if pct < lowest then
				lowest = pct;
			end
		end

		if lowest <= 20 then
			local tier = get_tier();
			local highest = 0;
			for _, g in ipairs(golems) do
				local pct = g:GetHPRatio();
				if pct > highest then
					highest = pct;
				end
			end

			-- sync check: only enforce for multi-golem tiers with 6+ members
			if #golems > 1 and highest - lowest > 5 and expedition_size() >= 6 then
				balance_fail(golems);
			else
				set_tier(tier + 1);
				for _, g in ipairs(golems) do
					split_at(g, tier);
					g:Depop();
				end
			end
		end

		e.self:SetTimerMS("phase", 3 * 1000);
	end
end

function Golem_Death(e)
	-- completion: any tier golem died and no true golems remain.
	-- Covers both the full split tree and straight burn-throughs of Balreth.
	if not eq.get_entity_list():IsMobSpawnedByNpcTypeID(BALRETH)
	   and not eq.get_entity_list():IsMobSpawnedByNpcTypeID(GOLEM_LARGE)
	   and not eq.get_entity_list():IsMobSpawnedByNpcTypeID(GOLEM_SMALL) then
		set_tier(0);  -- reset for the next attempt in this instance
		eq.depop_all(GOLEM_UNCTRL);
		eq.depop_all(DERVISH);

		local expedition = eq.get_expedition();
		local x, y, z = e.self:GetX(), e.self:GetY(), e.self:GetZ();
		if expedition.valid then
			local chest = eq.unique_spawn(CHEST, 0, 0, x, y, z + 5, 0);
			if chest ~= nil then
				expedition:SetLootEventBySpawnID(chest:GetID(), "Rear Guard Captain Balreth");
			end
		end
		eq.signal(CONTROLLER, SIGNAL_KEY);
	end
end

function Uncontrollable_Death(e)
	eq.zone_emote(MT.Red, "An Uncontrollable Golem collapses!");
end

function event_encounter_load(e)
	eq.register_npc_event('balreth', Event.combat,         BALRETH,      Balreth_Combat);
	eq.register_npc_event('balreth', Event.timer,          BALRETH,      Balreth_Timer);
	eq.register_npc_event('balreth', Event.death_complete, BALRETH,      Golem_Death);
	eq.register_npc_event('balreth', Event.death_complete, GOLEM_LARGE,  Golem_Death);
	eq.register_npc_event('balreth', Event.death_complete, GOLEM_SMALL,  Golem_Death);
	eq.register_npc_event('balreth', Event.death_complete, GOLEM_UNCTRL, Uncontrollable_Death);
end

function event_encounter_unload(e)
end
