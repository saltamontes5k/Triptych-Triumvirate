local binding = require("rof2_dodh_poisonmaster_bindings")[354311]
if binding then
    local poisonmaster = require("rof2_dodh_poisonmaster").bind(binding)
    event_spawn = poisonmaster.spawn
    event_damage_taken = poisonmaster.damage
    event_hp = poisonmaster.hp
    event_timer = poisonmaster.timer
end
