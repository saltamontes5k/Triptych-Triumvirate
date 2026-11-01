local M=require('achievement_quest_bixies')
local S=require('achievement_quest_bixie_scenes')
function event_spawn(e) S.spawn(e) end
function event_say(e) M.say(e) end
function event_trade(e) M.trade(e) end
function event_task_accepted(e) M.accepted(e) end
function event_timer(e) S.timer(e) end
function event_death_complete(e) S.death_complete(e) end
function event_despawn(e) S.despawn(e) end
function event_combat(e) S.combat(e) end

-- Mesa cross-zone route; preserve the NPC's existing quests and callbacks.
local mesa_cross_before_say=event_say
function event_say(e)
 if mesa_cross_before_say then mesa_cross_before_say(e)end
 require('achievement_quest_mesa').cross_say(e)
end
