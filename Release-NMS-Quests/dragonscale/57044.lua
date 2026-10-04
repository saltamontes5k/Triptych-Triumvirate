-- a brownie guard (57044) -- SoF faction task "The Rescue" (300205).
-- Hand-written: guards summoned by Agilica despawn if left idle; the
-- depop timer is cancelled once combat starts.

function event_spawn(e)
	eq.set_timer("rescue_depop", 6 * 60 * 1000)
end

function event_combat(e)
	if e.joined then
		eq.stop_timer("rescue_depop")
	end
end

function event_timer(e)
	if e.timer == "rescue_depop" then
		eq.depop()
	end
end
