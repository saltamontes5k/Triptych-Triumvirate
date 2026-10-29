-- Global Lua callbacks run independently of zone-local Perl callbacks.
-- Preserve Crescent player.pl and all its existing task/cast/door callbacks.
local global_bixie_scenes=require('achievement_quest_bixie_scenes')
local prior_bixie_enter=event_enter_zone
function event_enter_zone(e)
 if prior_bixie_enter then prior_bixie_enter(e) end
 global_bixie_scenes.player_sync(e.self)
end
local prior_bixie_signal=event_signal
function event_signal(e)
 if global_bixie_scenes.player_signal(e) then return end
 if prior_bixie_signal then return prior_bixie_signal(e) end
end
