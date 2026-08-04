local KEY_RESPAWN_TIME  = 90 * 60 * 1000
local SPAWN_LOCATIONS   = {
	[1] = {52154, -1,   -201,  1,  0, 5400000},
	[2] = {52154, -129,  625,  71, 0, 5400000},
	[3] = {52154. -736, -327,  0,  0, 5400000},
	[4] = {52154, -172, -233,  18, 0, 5400000},
	[5] = {52154, -678,  495, -36, 0, 5400000}
};

function event_spawn(e)
	eq.set_timer("replenish", 3 * 1000)
end

function event_timer(e)
   eq.stop_timer(e.timer)
   if e.timer == "replenish" then
      eq.create_ground_object(unpack(SPAWN_LOCATIONS[math.random(1, #SPAWN_LOCATIONS)]))
   end
end

function event_signal(e)
  if e.signal == 1 then
    eq.debug("key picked up")
    eq.set_timer("replenish", KEY_RESPAWN_TIME)
  end
end
