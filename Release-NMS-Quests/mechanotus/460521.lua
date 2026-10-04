-- [[
-- a_color_steamdrone (460521) -- Battle Room drone (non-hostile).
-- Rasper: raidMMM.html. Players target a drone and say Left / Right /
-- Forward to walk it off a forbidden colour tile; each move strains it.
-- The drone's colour lives in an entity variable set when spawned.
-- ]]

local DRONE_HP_STEP = 0.06 -- 6% per command

function event_say(e)
    local msg = string.lower(e.message or "")
    if not (msg:find("left") or msg:find("right") or msg:find("forward")) then
        return
    end
    local x, y, z = e.self:GetX(), e.self:GetY(), e.self:GetZ()
    if msg:find("left") then
        e.self:MoveTo(x + 15, y, z, 0)
    elseif msg:find("right") then
        e.self:MoveTo(x - 15, y, z, 0)
    else
        e.self:MoveTo(x, y + 15, z, 0)
    end
    local col = e.self:GetEntityVariable("color")
    pcall(function()
        local hp = e.self:GetHP() - math.floor(e.self:GetMaxHP() * DRONE_HP_STEP)
        if hp < 1 then hp = 1 end
        e.self:SetHP(hp)
    end)
    e.self:Emote("whirs and drifts, losing pressure. (" .. (col or "?") .. ")")
    if e.self:GetHPRatio() <= 1 then
        eq.zone_emote(13, "A drained steamdrone stops responding to commands.")
    end
end
