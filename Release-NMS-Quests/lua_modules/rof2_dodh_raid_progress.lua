local M = {}
local blood_events = {
    bloodeye = true, shyra = true, council = true, sendaii = true, draygun = true,
}
local tier_events = {
    { "graniteclaw", "redfang", "sisters", "hatchet" },
    { "devlin", "tris", "roley", "performer" },
}
local expiry = 5 * 24 * 60 * 60
local prefix = "dodh_blood:"

function M.rank(client)
    local count = 0
    for event in pairs(blood_events) do
        if client:GetBucket(prefix .. event) == "1" then count = count + 1 end
    end
    if client:GetBucket(prefix .. "backflag") == "1" or client:GetBucket(prefix .. "mayong") == "1" then
        return 5
    end
    return math.max(count, math.min(5, client:GetAA(1378)))
end

function M.sync_aa(client)
    local target = M.rank(client)
    if target > client:GetAA(1378) then
        client:GrantAlternateAdvancementAbility(488, target, true)
    end
end

function M.blood_immune(client)
    return client:GetBucket(prefix .. "mayong") == "1"
end

function M.same_instance(client, name, zone_id, version)
    if not client or not client.valid then return nil end
    local zone = eq.get_zone()
    if zone:GetZoneID() ~= zone_id or zone:GetInstanceVersion() ~= version or zone:GetInstanceID() <= 0 then
        return nil
    end
    local dz = client:GetExpedition()
    if dz.valid and dz:GetName() == name and dz:GetZoneID() == zone_id and dz:GetZoneVersion() == version
        and dz:GetInstanceID() == zone:GetInstanceID() then return dz end
end

-- Only an event controller that has already checked its native terminal receipt calls this.
function M.commit_blood(dz, event, zone_id, version)
    if not blood_events[event] or not dz or not dz.valid then return false end
    local lockout = "Darkhollow blood victory: " .. event
    if dz:HasLockout(lockout) then return false end
    dz:AddLockout(lockout, expiry)
    -- Verify the actual expedition and physical participation. Native lockout covers
    -- the expedition roster; durable Blood achievements use the narrower participants.
    for client in eq.get_entity_list():GetClientList().entries do
        if M.same_instance(client, dz:GetName(), zone_id, version) then
            client:SetBucket(prefix .. event, "1")
            M.sync_aa(client)
        end
    end
    return true
end

function M.has_tier(dz, tier)
    if not dz or not dz.valid or not tier_events[tier] then return false end
    for _, event in ipairs(tier_events[tier]) do
        if not dz:HasLockout("Demi-Plane: " .. event) then return false end
    end
    return true
end

-- Record only validated owning encounter transitions or exact native terminal deaths.
function M.commit_tier(dz, event, tier)
    if not dz or not dz.valid or dz:GetZoneID() ~= 351 or dz:GetZoneVersion() ~= 1
        or (tier == 2 and not M.has_tier(dz, 1)) then return false end
    local allowed = false
    for _, candidate in ipairs(tier_events[tier] or {}) do
        if candidate == event then allowed = true end
    end
    local lockout = "Demi-Plane: " .. event
    if not allowed or dz:HasLockout(lockout) then return false end
    dz:AddLockout(lockout, expiry)
    return true
end

return M
