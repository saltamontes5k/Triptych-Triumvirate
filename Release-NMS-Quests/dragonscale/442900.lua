local dragonscale=require('achievement_quest_dragonscale')
function event_killed_merit(e)return dragonscale.guard_killed(e)end
function event_timer(e)return dragonscale.guard_timer(e)end
