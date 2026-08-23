function event_timer(e)
	if(e.timer=="Leash") then
		eq.stop_timer("Leash");
		e.self:WipeHateList();
		e.self:MoveTo(-5984, 1653, 155.5, 100, true)
	else
		eq.set_timer("Leash", 30 * 1000);
	end
end

function event_combat(e)
    if not e.joined then
        eq.set_timer("Leash", 30 * 1000);
    else
        eq.stop_timer("Leash");
    end
end

function event_spawn(e)
	eq.set_timer("Leash", 60 * 1000);

end