local mission = require('rof2_dodh_mission_corpse')

function event_death_zone(e)
    mission.notebook_death(e)
end
