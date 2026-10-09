-- sod_raids.lua -- shared helpers for the SoD raid expeditions.
-- Rasper: raidOG2/raidKith/raidKunark1/raidRathe3/raidKorafax/raidDiscord.
-- Rules + expedition request flow: plugins/NMS_sod_utils.pl (%SOD_RAIDS).
-- Structure follows the Steam Factory raid encounters (438610.lua).

local M = {}

-- Expedition loot-event names (also the expedition lockout names).
M.EVENT = {
    ROTT       = "Rottrued",
    BAHGRESH   = "Bahgresh",
    COUNCIL    = "Council",
    ERIAK      = "Eriak",
    PALLORAX   = "Pallorax",
    AVATAR     = "Avatar",
    KSATHRAX   = "Ksathrax",
    MINDBLIGHT = "Mindblight",
    MALARIAN   = "Malarian",
    CORE       = "CrystalCore",
}

-- Chest npc ids (Treasure_of_* punch chests; loot economy out of scope).
M.CHEST = {
    ROTT       = 478740,
    BAHGRESH   = 478741,
    COUNCIL    = 478742,
    ERIAK      = 478743,
    PALLORAX   = 478744,
    AVATAR     = 478745,
    KSATHRAX   = 478746,
    MINDBLIGHT = 478747,
    MALARIAN   = 478748,
    CORE       = 478749,
}

-- Per-instance controller npc ids (an_anchor_of_the_timeshear).
M.CTRL = {
    ROTT       = 478730,
    BAHGRESH   = 478731,
    COUNCIL    = 478732,
    ERIAK      = 478733,
    PALLORAX   = 478734,
    AVATAR     = 478735,
    KSATHRAX   = 478736,
    MINDBLIGHT = 478737,
    MALARIAN   = 478738,
    CORE       = 478739,
}

-- Event-spawned add npc ids (reused PEQ SoD trash where noted).
M.ADD = {
    ritualist = 478705,
    priest    = 478706,
    kyv       = { 478702, 478703, 478704 },
    sentinel  = 478720,   -- riftseeker sentinel (Pallorax portals)
    acolyte   = 478721,
    maniac    = 478722,
    projection= 478723,   -- Venomous Projection (Ksathrax 50%)
    tunat     = 478724,
    mindgnawer= 478725,
    ooze      = 478726,
    ratuk     = 470002,   -- reused PEQ ra`tuk bonecleaver
    ikaav     = 470005,   -- reused PEQ ikaav corrupter
    broodling = 478759,   -- Queen Malarian brood waves
    coresieger= 478761,   -- Crystal Core Rallosian assault waves
    shard     = 478762,   -- Crystal Core 50%/25% splits
}

-- Spawning an add near a mob; returns spawn id or nil.
function M.spawn_add(npc_id, near, jitter, dz_offset)
    local mob = eq.spawn2(npc_id, 0, 0,
        near:GetX() + math.random(-(jitter or 40), jitter or 40),
        near:GetY() + math.random(-(jitter or 40), jitter or 40),
        (dz_offset and near:GetZ() + dz_offset) or near:GetZ(), 0)
    return mob
end

-- Punch chest at the corpse; the controller registered the loot event.
function M.spawn_chest(e, chest_id)
    local chest = eq.unique_spawn(chest_id, 0, 0,
        e.self:GetX(), e.self:GetY(), e.self:GetZ() + 5, 0)
    return chest
end

-- Clients within a flat radius of (x, y), alive.
function M.alive_clients(x, y, radius)
    local out = {}
    local clients = eq.get_entity_list():GetClientList()
    if not clients then return out end
    for client in clients.entries do
        if client and client:GetHPRatio() > 0
            and math.abs(client:GetX() - x) <= (radius or 300)
            and math.abs(client:GetY() - y) <= (radius or 300) then
            out[#out + 1] = client
        end
    end
    return out
end

-- Random alive client near (x, y), or nil.
function M.random_client(x, y, radius)
    local t = M.alive_clients(x, y, radius)
    if #t == 0 then return nil end
    return t[math.random(#t)]
end

-- SetInvul is build-dependent; wrap it so a missing binding never errors.
function M.set_invul(mob, state)
    pcall(function() mob:SetInvul(state) end)
end

-- Damage wrapper: house convention (skill 28, no spell id).
function M.hit(mob, client, amount)
	client:Damage(mob, amount, 0, 28)
end

-- Council members (A Council Divided). The anchor marks 4 of the 8
-- Discord-aligned at boot; those four emit a 10k AE while engaged.
function M.councilor_engaged(e)
	if e.self:GetEntityVariable("discord") == "1" then
		eq.set_timer("ae", 30000)
	end
end

function M.councilor_timer(e)
	if e.timer == "ae" then
		if e.self:GetEntityVariable("discord") ~= "1" or not e.self:IsEngaged() then
			eq.stop_timer("ae")
			return
		end
		eq.zone_emote(15, e.self:GetCleanName() .. " calls down the wrath of the Discord!")
		for _, client in ipairs(M.alive_clients(e.self:GetX(), e.self:GetY(), 150)) do
			M.hit(e.self, client, 10000)
		end
	end
end

return M
