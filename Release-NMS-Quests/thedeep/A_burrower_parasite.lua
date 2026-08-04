-- A burrower parasite in The Burrower Beast event

local EVENT_MOBS			= {164118,164104,164100,164108,164085,164089,164111};

function event_spawn(e)
	eq.set_timer('depop', 60 * 60 * 1000);
end

function event_timer(e)
	if e.timer == 'depop' then
		cleanup();
		eq.depop();
	end
end

function event_death_complete(e)
	cleanup();
end

function cleanup()
	for _, mob in ipairs(EVENT_MOBS) do
		eq.depop_all(mob);
	end
end
