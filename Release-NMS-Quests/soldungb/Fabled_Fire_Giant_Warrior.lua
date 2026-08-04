--Fabled Fire Giant Warrior (1120001080)

--we have spawned! lets roar!
function event_spawn(e)
	
	e.self:Shout("Protect Lord Nagafen!");
	eq.set_timer("CheckBindPoint", 1000);
end

--when someone is trying to send us a message... ignore for now
function event_signal(e)
	
end

--we are rooted, dun care :p
function event_waypoint_arrive(e)

end

-- when combat starts/ends.  Joins = starts, else = ends
function event_combat(e)
	
	if (e.joined) then

	else

	end
end

function event_timer(e)
	
	if(e.timer == "CheckBindPoint") then
		eq.stop_timer(e.timer);
		if (e.self:CalculateDistance(e.self:GetSpawnPointX(), e.self:GetSpawnPointY(), e.self:GetSpawnPointZ()) >75) then
			e.self:Shout("I must protect the Lord, you cannot trick me!");
			e.self:GotoBind();
			e.self:WipeHateList();
		end
		eq.set_timer("CheckBindPoint", 1000);
	end

	
end

function event_hp(e)
	
end

function event_death_complete(e)

	e.self:Shout("I didn't get paid enough for this...");
	eq.zone_emote(MT.Emote, "The Giant Warrior's Corpse falls into the magma, spashing it everywhere! (Everyone takes 3,000 damage!!!)");
	e.self:CameraEffect(500,5);
	e.self:DamageAreaClients(3000,300);
	
end
