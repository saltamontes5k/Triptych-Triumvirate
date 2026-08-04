function event_spawn(e)
    -- Set a timer to depop in 1800 seconds (30 minutes)
    eq.set_timer("depop_timer", 1800 * 1000) -- milliseconds
end

function event_timer(e)
    if e.timer == "depop_timer" then
        eq.stop_timer("depop_timer")
        eq.depop()
    end
end
