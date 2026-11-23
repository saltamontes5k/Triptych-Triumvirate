local trailing = require("rof2_dodh_trailing")

function event_spawn(e)
    if e.self:GetSpawnPointID() == 263795 then
        eq.set_timer("trailing_longshadow", 1000)
    end
end

function event_timer(e)
    if e.timer == "trailing_longshadow" and e.self:GetSpawnPointID() == 263795 then
        trailing.tick(e.self)
    end
end
