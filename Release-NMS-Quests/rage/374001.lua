-- rage/374001.lua - a dark initiate (Sverag zone-in)
-- Prophecy of Ro: the nine trophy deliveries, with the upstream
-- controller-gated rotation. Spawn condition 1 in rage decides which single
-- delivery this contact withholds (1 = skulls, 2 = giant). The legacy
-- aggregate task 303198 stays available to players already carrying it.
local por = require("por_helper");

local trophy_ids = {};
for _, entry in ipairs(por.trophy_tasks) do trophy_ids[entry[1]] = true; end

local function on_duty(c, npc)
	return por.can_offer(c, npc, 374, 374001, 105981, 70);
end

local function blocked_task()
	return por.trophy_blocked[eq.get_spawn_condition("rage", 0, 1)];
end

local function pay_trophy(c, task_id)
	local key = "por.trophy_reward." .. task_id;
	if (tonumber(c:GetBucket(key)) or 0) == 0 and por.grant_rewards(c, "rage") > 0 then
		c:SetBucket(key, "1");
		c:Message(15, "The rage recognizes your trophy. A spell is yours.");
	end
end

function event_say(e)
	local t = e.message:lower();
	local c = e.other;

	-- Catch completions that happened while this script was not loaded.
	for _, entry in ipairs(por.trophy_tasks) do
		if c:IsTaskCompleted(entry[1]) then pay_trophy(c, entry[1]); end
	end

	if t:find("hail") then
		e.self:Say("So. You would walk the Stronghold of Rage with power worthy of it. The armies that march on Sverag carry tokens of their rage. Ask me about [trophies] and I will name those I will accept.");
	elseif t:find("troph") or t:find("work") or t:find("can prove") then
		if not on_duty(c, e.self) then return; end
		local blocked = blocked_task();
		local choices = {};
		for _, entry in ipairs(por.trophy_tasks) do
			if entry[1] ~= blocked then choices[#choices + 1] = entry[1]; end
		end
		if #choices > 0 then c:TaskSelectorFromNPC(e.self, choices); end
	elseif t:find("rage") or t:find("spell") or t:find("power") or t:find("legacy") then
		-- Legacy aggregate path, kept intact for in-flight players.
		if not c:IsTaskActive(por.tasks.the_rage_within) and not c:IsTaskCompleted(por.tasks.the_rage_within) then
			c:AssignTask(por.tasks.the_rage_within);
			e.self:Say("Ears, paws, heads, tentacles - whatever the armies of the Devastation carry. Four trophies. Go.");
		elseif c:IsTaskCompleted(por.tasks.the_rage_within) and (tonumber(c:GetBucket("por.rage_within_reward")) or 0) == 0 then
			if por.grant_rewards(c, "rage") > 0 then
				c:SetBucket("por.rage_within_reward", "1");
				e.self:Say("I feel it in you now. The rage recognizes its own. Wield it well.");
			end
		end
	end
end

function event_task_complete(e)
	if not trophy_ids[e.task_id] then return; end
	local c = e.other;
	if not c or not c.valid then return; end
	pay_trophy(c, e.task_id);
end
