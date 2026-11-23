local scene = require("rof2_dodh_demi_controller")
local admission = require("rof2_dodh_demi_admission")
local tier_one = require("rof2_dodh_demi_tier_one")
local tier_two = require("rof2_dodh_demi_tier_two")
local mayong = require("rof2_dodh_demi_mayong")

function event_encounter_load(e)
    for key, hooks in pairs(tier_one) do scene.hooks[key] = hooks end
    for key, hooks in pairs(tier_two) do scene.hooks[key] = hooks end
    scene.hooks.mayong = mayong
    local npc_types = {[351118] = true, [351165] = true}
    for key, id in pairs(scene.bindings) do
        if type(id) == "number" and key:sub(1, 5) == "DEMI_" then npc_types[id] = true end
    end
    for _, player in ipairs(scene.layout.performer.band) do npc_types[player.type] = true end
    for _, room in ipairs(scene.layout.roley.branch_rooms) do
        if room.zombie then npc_types[room.zombie] = true end
    end
    for id in pairs(npc_types) do
        eq.register_npc_event(Event.damage_taken, id, scene.damage)
        eq.register_npc_event(Event.say, id, scene.say)
        eq.register_npc_event(Event.aggro_say, id, scene.say)
    end
    eq.set_timer("dodh_demi_tick", 1000, e.encounter)
    eq.set_timer("dodh_demi_mists", 300000, e.encounter)
end

function event_timer(e)
    if e.timer == "dodh_demi_tick" then
        scene.tick()
    elseif e.timer == "dodh_demi_mists" then
        for client in eq.get_entity_list():GetClientList().entries do admission.apply_mists(client) end
    end
end
