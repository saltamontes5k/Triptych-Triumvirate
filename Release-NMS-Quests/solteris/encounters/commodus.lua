--[[
Commodus, Solar Construct (Solteris event 6, island 3) - 421065 with the
eight Aspects (421066-421073).

Core mechanics (Rasper's guide), permissively tuned:
  * Four Aspects (Temperance/Justice/Wisdom/Fortitude) start active; the
    other four awaken when one falls to 50%.
  * Aspects must be kept within 8% HP of each other - the straggler that
    falls behind powers up (heal + ATK). A periodic siphon shuffles 5%
    between random Aspects to fight the raid's sync.
  * Liquid Magma (421080) spawns in pairs while the Aspects live.
  * Ground Strike (11962) on a cycle; Solar Strike (11960) lands on the
    tank and must be cured within 30s.
  * At 45% Convergence of the Sun (421081) orbs join; kill them fast or
    they detonate a short stun AE.
  * Commodus himself activates when all eight Aspects are destroyed.
]]

local CONTROLLER = 421000;
local CHEST      = 421095;
local SIGNAL_KEY = 1006;

local COMMODUS     = 421065;
local ASPECTS      = { 421066, 421067, 421068, 421069, 421070, 421071, 421072, 421073 };
local ASPECT_NAMES = {
	[421066] = "Temperance", [421067] = "Justice",   [421068] = "Wisdom",
	[421069] = "Fortitude",  [421070] = "Courage",   [421071] = "Devotion",
	[421072] = "Ambition",   [421073] = "Resourcefulness",
}

-- Aspect positions (Brewall map POIs negated)
local ASPECT_POS = {
	{ 421066, -1805, 4512, 2632 }, { 421067, -1470, 4515, 2631 },
	{ 421068, -1741, 4611, 2643 }, { 421069, -1539, 4604, 2643 },
	{ 421070, -1596, 4759, 2643 }, { 421071, -1692, 4755, 2643 },
	{ 421072, -1742, 4693, 2643 }, { 421073, -1537, 4696, 2643 },
}

local ASPECT_FIRST = { 421066, 421067, 421068, 421069 };  -- awake at the start
local MAGMA        = 421080;
local CONVERGENCE  = 421081;

function expedition_size()
	local expedition = eq.get_expedition();
	if expedition.valid then
		return math.max(1, expedition:GetMemberCount());
	end
	return 1;
end

function live_aspects()
	local out = {};
	for _, id in ipairs(ASPECTS) do
		local npc = eq.get_entity_list():GetNPCByNPCTypeID(id);
		if npc ~= nil then
			table.insert(out, npc);
		end
	end
	return out;
end

function Commodus_Spawn(e)
	-- wake the first four Aspects
	for _, id in ipairs(ASPECT_FIRST) do
		for _, pos in ipairs(ASPECT_POS) do
			if pos[1] == id then
				eq.spawn2(id, 0, 0, pos[2], pos[3], pos[4], 0);
			end
		end
	end
	eq.zone_emote(MT.Red, "Commodus's Aspects awaken, wreathed in solar fire!");
end

function Aspect_Combat(e)
	if e.joined then
		if (e.self:GetEntityVariable("aspect_timers") or "") ~= "1" then
			e.self:SetEntityVariable("aspect_timers", "1");
			e.self:SetTimerMS("strike", math.random(20, 40) * 1000);
			e.self:SetTimerMS("siphon", 75 * 1000);
		end
	else
		e.self:StopTimer("strike");
		e.self:StopTimer("siphon");
	end
end

function Aspect_Timer(e)
	if e.timer == "strike" then
		local target = e.self:GetTarget();
		if target ~= nil then
			e.self:CastSpell(11962, target:GetID());  -- Ground Strike
		end
		e.self:SetTimerMS("strike", 24 * 1000);
	elseif e.timer == "siphon" then
		local aspects = live_aspects();
		if #aspects >= 2 then
			local gain = aspects[math.random(1, #aspects)];
			local lose = aspects[math.random(1, #aspects)];
			if gain:GetID() ~= lose:GetID() then
				gain:Heal(math.floor(gain:GetMaxHP() * 0.05));
				lose:Damage(math.floor(lose:GetMaxHP() * 0.05), 0, lose);
				eq.zone_emote(MT.Red, "An Aspect of Commodus shakes violently as its life-force is siphoned!");
			end
		end
		e.self:SetTimerMS("siphon", 75 * 1000);
	end
end

function Aspect_Death(e)
	-- wake the dormant Aspects once one of the first four hits the ground
	local any_awake = false;
	for _, id in ipairs(ASPECT_FIRST) do
		if eq.get_entity_list():IsMobSpawnedByNpcTypeID(id) then
			any_awake = true;
			break;
		end
	end

	if not any_awake then
		for _, pos in ipairs(ASPECT_POS) do
			if not eq.get_entity_list():IsMobSpawnedByNpcTypeID(pos[1]) then
				eq.spawn2(pos[1], 0, 0, pos[2], pos[3], pos[4], 0);
			end
		end
		eq.zone_emote(MT.Red, "The remaining Aspects of Commodus awaken!");
	end

	-- all Aspects down: Commodus himself activates
	if #live_aspects() == 0 then
		local commodus = eq.get_entity_list():GetNPCByNPCTypeID(COMMODUS);
		if commodus ~= nil then
			commodus:Emote("solar fire erupts across his frame. 'You have my attention, mortals.'");
		end
	end
end

function Commodus_Combat(e)
	if e.joined then
		-- cannot be fought while any Aspect lives
		if #live_aspects() > 0 then
			e.self:Heal();
			if e.other ~= nil then
				e.self:RemoveFromHateList(e.other);
			end
			e.self:Say("My Aspects are not yet finished with you.");
			return;
		end

		e.self:SetTimerMS("strike", 15 * 1000);
		e.self:SetTimerMS("solar", 40 * 1000);
		e.self:SetTimerMS("magma", 45 * 1000);
		e.self:SetTimerMS("phase", 3 * 1000);
	else
		e.self:StopTimer("strike");
		e.self:StopTimer("solar");
		e.self:StopTimer("magma");
		e.self:StopTimer("phase");
	end
end

function Commodus_Timer(e)
	if e.timer == "strike" then
		local target = e.self:GetTarget();
		if target ~= nil then
			e.self:CastSpell(11962, target:GetID());  -- Ground Strike
		end
		e.self:SetTimerMS("strike", 24 * 1000);
	elseif e.timer == "solar" then
		local target = e.self:GetTarget();
		if target ~= nil then
			e.self:CastSpell(11960, target:GetID());  -- Solar Strike (cure or 32k dot)
			target:Message(MT.Red, "Solar Strike burns in your veins - cure it within 30 seconds!");
		end
		e.self:SetTimerMS("solar", 40 * 1000);
	elseif e.timer == "magma" then
		local cap = math.min(10, 2 + expedition_size());
		local count = 0;
		for _, npc in pairs(eq.get_entity_list():GetNPCList() or {}) do
			if npc ~= nil and npc:GetNPCTypeID() == MAGMA then
				count = count + 1;
			end
		end
		if count < cap then
			for i = 1, 2 do
				eq.spawn2(MAGMA, 0, 0,
					e.self:GetX() + math.random(-60, 60),
					e.self:GetY() + math.random(-60, 60),
					e.self:GetZ(), 0);
			end
			eq.zone_emote(MT.Red, "Liquid Magma bubbles up from the ruined throne room!");
		end
		e.self:SetTimerMS("magma", 45 * 1000);
	elseif e.timer == "phase" then
		local pct = e.self:GetHPRatio();

		if pct <= 45 and (tonumber(e.self:GetEntityVariable("convergence_on") or "0") or 0) == 0 then
			e.self:SetEntityVariable("convergence_on", "1");
			e.self:SetTimerMS("convergence", 30 * 1000);
		end

		e.self:SetTimerMS("phase", 3 * 1000);
	elseif e.timer == "convergence" then
		local n = math.min(5, 2 + math.floor(expedition_size() / 3));
		for i = 1, n do
			eq.spawn2(CONVERGENCE, 0, 0,
				e.self:GetX() + math.random(-80, 80),
				e.self:GetY() + math.random(-80, 80),
				e.self:GetZ(), 0);
		end
		eq.zone_emote(MT.Red, "Convergences of the Sun streak down toward the raid - destroy them before they detonate!");
		e.self:SetTimerMS("convergence", 45 * 1000);
	end
end

function Convergence_Death(e)
	eq.zone_emote(MT.Red, "A Convergence of the Sun is snuffed out!");
end

function Commodus_Death(e)
	eq.depop_all(MAGMA);
	eq.depop_all(CONVERGENCE);

	local expedition = eq.get_expedition();
	local x, y, z = e.self:GetX(), e.self:GetY(), e.self:GetZ();
	if expedition.valid then
		local chest = eq.unique_spawn(CHEST, 0, 0, x, y, z + 5, 0);
		if chest ~= nil then
			expedition:SetLootEventBySpawnID(chest:GetID(), "Commodus, Solar Construct");
		end
	end
	eq.signal(CONTROLLER, SIGNAL_KEY);
end

function event_encounter_load(e)
	eq.register_npc_event('commodus', Event.spawn,          COMMODUS,    Commodus_Spawn);
	eq.register_npc_event('commodus', Event.combat,         COMMODUS,    Commodus_Combat);
	eq.register_npc_event('commodus', Event.timer,          COMMODUS,    Commodus_Timer);
	eq.register_npc_event('commodus', Event.death_complete, COMMODUS,    Commodus_Death);

	for _, id in ipairs(ASPECTS) do
		eq.register_npc_event('commodus', Event.combat,         id, Aspect_Combat);
		eq.register_npc_event('commodus', Event.timer,          id, Aspect_Timer);
		eq.register_npc_event('commodus', Event.death_complete, id, Aspect_Death);
	end

	eq.register_npc_event('commodus', Event.death_complete, CONVERGENCE, Convergence_Death);
end

function event_encounter_unload(e)
end
