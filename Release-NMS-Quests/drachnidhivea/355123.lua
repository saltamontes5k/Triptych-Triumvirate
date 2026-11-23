local scenes = require("rof2_dodh_scene_driver")

function event_damage_taken(e)
    return scenes.damage(e)
end
