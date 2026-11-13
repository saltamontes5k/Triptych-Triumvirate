--[[
potime_ring.lua - Plane of Time trial wing helper.

A cleared wing's trigger depops after a short loot window. This module used to
also port everyone still standing in the wing back to the Ring of Time in
potimea to click the next dial; that auto-port is gone by request -- the
surprise trip out of the instance to the shared zone broke runs mid-fight.
The group walks or gates out on their own schedule; all the wing doors are
unlocked, so nothing is gated behind the old round trip.

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

local pending = {};

local M = {};

-- Schedule the trigger depop.  The bounds stay in the signature so the trial
-- triggers do not change; nothing is ported anymore.
function M.finish(e, delay_ms, min_x, max_x, min_y, max_y)
    -- TrialWinCheck (earth) runs on every signal, so only arm the depop once.
    if pending[e.self:GetID()] then
        return;
    end

    pending[e.self:GetID()] = {
        min_x = min_x, max_x = max_x,
        min_y = min_y, max_y = max_y,
    };

    eq.get_entity_list():MessageClose(
        e.self, true, 100, MT.LightGray,
        "The Ring of Time releases the wing; the way onward is your own.");

    eq.set_timer("ring_return", delay_ms or 20000);
end

-- Call at the top of the trial trigger's event_timer.
function M.handle_timer(e)
    if e.timer ~= "ring_return" then
        return false;
    end

    eq.stop_timer("ring_return");
    pending[e.self:GetID()] = nil;

    eq.depop();
    return true;
end

return M;
