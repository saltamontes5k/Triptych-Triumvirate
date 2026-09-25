--[[
NMS progression helper: spawns the progression memory hail mob (NPC 26000)
on a raid boss corpse, sets its flag/stage entity variables, and records the
killer's guild id (pets resolve to their owner; GMs are ignored) so
global/26000.pl can announce first guild kills via plugin::MemoryCongrats.

Usage (from an NPC death_complete event):
    local memory = require("nms_memory");
    memory.spawn(e, stage, flag);                    -- spawns at e.self's corpse
    memory.spawn(e, stage, flag, stage2, flag2);     -- second hail pair
    memory.spawn(e, stage, flag, nil, nil, x, y, z, h); -- fixed position
    memory.spawn_at(killer, x, y, z, h, stage, flag, stage2, flag2); -- explicit
]]

local MEMORY_NPC = 26000;

local function killer_guild_id(killer)
	if killer == nil or not killer.valid then
		return 0;
	end

	if killer:IsPet() then
		killer = killer:GetOwner();
	end

	if killer == nil or not killer.valid or not killer:IsClient() then
		return 0;
	end

	local client = killer:CastToClient();
	if client:Admin() >= 80 then
		return 0;
	end

	return eq.get_guild_id_by_char_id(client:CharacterID());
end

local function spawn_at(e_other, x, y, z, h, stage, flag, stage2, flag2)
	local memory_npc = eq.spawn2(MEMORY_NPC, 0, 0, x, y, z, h);
	if memory_npc == nil then
		return nil;
	end

	memory_npc:SetEntityVariable("Stage-Name", stage);
	memory_npc:SetEntityVariable("Flag-Name", flag);

	if stage2 ~= nil and flag2 ~= nil then
		memory_npc:SetEntityVariable("Stage-Name-2", stage2);
		memory_npc:SetEntityVariable("Flag-Name-2", flag2);
	end

	local guild_id = killer_guild_id(e_other);
	if guild_id > 0 then
		memory_npc:SetEntityVariable("Killer-Guild-ID", tostring(guild_id));
	end

	return memory_npc;
end

local function spawn(e, stage, flag, stage2, flag2, x, y, z, h)
	if x == nil then
		x = e.self:GetX();
		y = e.self:GetY();
		z = e.self:GetZ() + 10;
		h = e.self:GetHeading();
	end

	return spawn_at(e.other, x, y, z, h, stage, flag, stage2, flag2);
end

return {
	spawn = spawn,
	spawn_at = spawn_at,
	killer_guild_id = killer_guild_id,
};
