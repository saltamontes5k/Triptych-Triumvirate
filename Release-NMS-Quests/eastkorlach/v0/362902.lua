local flights = require("rof2_dodh_flights")

function event_damage_taken(e)
    return flights.damage(e)
end

function event_timer(e)
    flights.tick(e)
end
