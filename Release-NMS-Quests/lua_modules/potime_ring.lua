--[[
potime_ring.lua - Plane of Time trial wing helper.

A cleared wing's trigger would normally just depop and leave the group to walk
back. On a one- or two-person run there is no raid to shuffle between wings, so
instead we give them a short window to loot and then send everyone still
standing in that wing back to the Ring of Time in potimea to click the next
dial.

Usage from a trial trigger (potimeb/phase_one_*.lua):
    local ring = require("potime_ring")
    ...
    ring.finish(e, 20000, min_x, max_x, min_y, max_y)  -- replaces eq.depop()
    ...
    function event_timer(e)
        if ring.handle_timer(e) then return end
        ... existing timers ...
    end
]]

local POTIMEA_ZONE = 219;
local RING_LOC = { x = -37, y = -110, z = 6.08, h = 0.0 };

local pending = {};

local M = {};

-- Schedule the return.  The bounds keep the port inside the wing this trigger
-- owns, so a partner still fighting a different wing is not pulled out.
function M.finish(e, delay_ms, min_x, max_x, min_y, max_y)
    -- TrialWinCheck (earth) runs on every signal, so only arm the return once.
    if pending[e.self:GetID()] then
        return;
    end

    pending[e.self:GetID()] = {
        min_x = min_x, max_x = max_x,
        min_y = min_y, max_y = max_y,
    };

    eq.get_entity_list():MessageClose(
        e.self, true, 100, MT.LightGray,
        "The Ring of Time reaches for you; the way back opens in a moment.");

    eq.set_timer("ring_return", delay_ms or 20000);
end

-- Call at the top of the trial trigger's event_timer.
function M.handle_timer(e)
    if e.timer ~= "ring_return" then
        return false;
    end

    eq.stop_timer("ring_return");

    local bounds = pending[e.self:GetID()];
    pending[e.self:GetID()] = nil;

    if bounds and bounds.min_x then
        local client_list = eq.get_entity_list():GetClientList();
        if client_list ~= nil then
            for c in client_list.entries do
                if c.valid and not c:GetGM() then
                    local x, y = c:GetX(), c:GetY();
                    if x >= bounds.min_x and x <= bounds.max_x
                       and y >= bounds.min_y and y <= bounds.max_y then
                        c:Message(MT.Yellow, "The ring of time reclaims you.");
                        c:MovePC(POTIMEA_ZONE, RING_LOC.x, RING_LOC.y, RING_LOC.z, RING_LOC.h);
                    end
                end
            end
        end
    end

    eq.depop();
    return true;
end

return M;
