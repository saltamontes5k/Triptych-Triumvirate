--[[
nms_fabled_toolkit.lua - shared Balance guards for the Fabled Encounters
program (reference/Fabled-Loot-Design.xlsx, Mechanics + Boss Tuning sheets).

Every Fabled encounter script requires this module and calls the same
guards The_Fabled_Lord_Nagafen.lua carries inline. All state lives in
entity variables on the boss itself, so the module is stateless and safe
to share across scripts/zones (one NPC instance per expedition zone).

Exports:
    toolkit.apply_group_hp(e)      -- once per spawn: max_hp x (0.5 + 0.083 x members)
    toolkit.start_fight_clock(e)   -- on combat join: clear the enrage counter
    toolkit.enrage_tick(e)         -- every 60s in combat: +10% damage per minute after 15
    toolkit.reset_fight(e)         -- on wipe (10s out of combat): undo ramps, clear counters
    toolkit.flag_on_death(e, flag) -- on death: A Faded Memory (26000) grants the subflag
                                   -- under the FNagafen progression stage
]]

local memory = require("nms_memory");

local toolkit = {};

local function has_var(e, name)
	local v = e.self:GetEntityVariable(name);
	return v ~= nil and v ~= "";
end

--Group-size HP scaling (Boss Tuning sheet): 1 member = 58%, 3 = 75%,
--6 = ~100%. HP only -- damage never scales. Applied once per spawn;
--also captures the base hit range so the soft enrage always ramps from
--the npc_types values (ModifyNPCStat persists across combat).
function toolkit.apply_group_hp(e)
	if (has_var(e, "fabled_hp_scaled")) then
		return;
	end
	e.self:SetEntityVariable("fabled_hp_scaled", "1");
	e.self:SetEntityVariable("original_max_hp", e.self:GetMaxHP());
	e.self:SetEntityVariable("original_min_hit", e.self:GetNPCStat("min_hit"));
	e.self:SetEntityVariable("original_max_hit", e.self:GetNPCStat("max_hit"));

	local members = 6;
	local target = e.self:GetTarget();
	if (target) then
		local dz = target:GetExpedition();
		if (dz and dz.valid) then
			members = dz:GetMemberCount();
		end
	end
	if (members < 1) then members = 1; end
	if (members > 6) then members = 6; end

	local new_max = math.ceil(e.self:GetMaxHP() * (0.5 + 0.083 * members));
	e.self:ModifyNPCStat("max_hp", tostring(new_max));
	e.self:SetHP(e.self:GetMaxHP());
end

--Soft enrage (Boss Tuning Balance guards): +10% damage per minute after
--15 minutes of combat, no hard enrage. Driven by a 60s boss timer.
function toolkit.start_fight_clock(e)
	e.self:SetEntityVariable("enrage_minutes", "0");
end

function toolkit.enrage_tick(e)
	local minutes = tonumber(e.self:GetEntityVariable("enrage_minutes") or "0") + 1;
	e.self:SetEntityVariable("enrage_minutes", tostring(minutes));
	if (minutes <= 15) then
		return;
	end

	local ramps = minutes - 15;
	local omin = tonumber(e.self:GetEntityVariable("original_min_hit") or "0");
	local omax = tonumber(e.self:GetEntityVariable("original_max_hit") or "0");
	local mult = 1.1 ^ ramps;
	e.self:ModifyNPCStat("min_hit", tostring(math.ceil(omin * mult)));
	e.self:ModifyNPCStat("max_hit", tostring(math.ceil(omax * mult)));
	eq.zone_emote(MT.Emote, "The memory's fury grows beyond all containment!");
end

function toolkit.reset_fight(e)
	e.self:SetEntityVariable("enrage_minutes", "0");
	--undo any soft-enrage ramp so the next attempt starts from base
	local omin = e.self:GetEntityVariable("original_min_hit");
	local omax = e.self:GetEntityVariable("original_max_hit");
	if (omin ~= nil and omin ~= "" and omax ~= nil and omax ~= "") then
		e.self:ModifyNPCStat("min_hit", tostring(math.floor(tonumber(omin))));
		e.self:ModifyNPCStat("max_hit", tostring(math.floor(tonumber(omax))));
	end
end

--Flag on death (Mechanics sheet): A Faded Memory (26000) spawns on the
--corpse; its hail grants SetSubflag('FNagafen', <flag>) per the approved
--Fabled flag scheme.
function toolkit.flag_on_death(e, flag)
	memory.spawn(e, "FNagafen", flag);
end

return toolkit;
