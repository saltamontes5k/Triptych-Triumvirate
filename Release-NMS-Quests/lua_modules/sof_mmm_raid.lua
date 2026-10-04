-- [[
-- sof_mmm_raid.lua -- shared helpers for the Meldrath's Majestic Mansion
-- raid (mechanotus instance version 1). Rasper: raidMMM.html.
-- Generated companions live in quests/mechanotus/46*.lua.
-- ]]

local M = {}

M.CONTROLLER = 460590

M.NPC = {
    breakneck = 460510, grinder_trooper = 460511, grinder_elite = 460512,
    prototype = 460520, drone = 460521, engineer = 460522,
    brinda = 460530, meg_enforcer = 460531, oil_slick = 460532, meg = 460533,
    password_enforcer = 460534,
    krond = 460540, slaver = 460541, henchotaur = 460542,
    fudindle = 460550, geartop = 460551, tiny_top = 460552, abs = 460553,
    patch = 460554, steamsuit = 460555, bargangle = 460556,
    reanim_breakneck = 460560, reanim_krond = 460561,
    reanim_brinda = 460562, reanim_bargangle = 460563,
    support_unit = 460570,
}

-- event key -> chest npc type and lockout/event name
M.CHEST = { [2001] = 460580, [2002] = 460581, [2003] = 460582, [2004] = 460583, [2005] = 460584 }
M.EVENT_NAME = {
    [2001] = "Meldrath's Mansion: Breakneck",
    [2002] = "Meldrath's Mansion: Battle Room",
    [2003] = "Meldrath's Mansion: Doctor Brinda Sprocket",
    [2004] = "Meldrath's Mansion: Krond the Longhorn",
    [2005] = "Meldrath's Mansion: Bargangle Tinkerson",
}

function M.alive_clients(cx, cy, r)
    local out = {}
    local list = eq.get_entity_list():GetClientList()
    if not list then return out end
    for c in list.entries do
        if c and c:GetHPRatio() > 0
            and math.abs(c:GetX() - cx) <= r and math.abs(c:GetY() - cy) <= r then
            out[#out + 1] = c
        end
    end
    return out
end

function M.signal(key)
    eq.signal(M.CONTROLLER, key)
end

-- spawn this event's punchable chest at the encounter and protect its loot
function M.spawn_chest(enc, key)
    local exp = eq.get_expedition()
    if not exp.valid then return end
    local c = eq.unique_spawn(M.CHEST[key], 0, 0, enc:GetX(), enc:GetY(), enc:GetZ() + 5, 0)
    if c then exp:SetLootEventBySpawnID(c:GetID(), M.EVENT_NAME[key]) end
end

function M.spawn_add(npc_type, x, y, z, target)
    local m = eq.spawn2(npc_type, 0, 0, x, y, z, 0)
    if m and target then m:AddToHateList(target, 1000, 10000) end
    return m
end

function M.clear_list(ids)
    local el = eq.get_entity_list()
    for _, id in ipairs(ids) do
        local m = el:GetNPCByID(id)
        if m and m.valid then m:Depop() end
    end
end

function M.raw_damage(src, clients, amount, spell_id)
    for _, c in ipairs(clients) do
        pcall(function() c:Damage(src, amount, 0, spell_id or 28) end)
    end
end

return M
