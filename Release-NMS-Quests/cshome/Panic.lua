--Panic (223201)

local phase = 1;
local current_target = nil;
local ignore_reengage = false;
local ignore_disengage = false;
local hate_to_add = 2000;

--we have spawned! Emote and shout!
function event_spawn(e)
	phase = 1;
	e.self:Emote(" 's presence is heavy with Fear.");
	e.self:Shout("The Guktan do not exist. The Guktan never existed... and soon, neither will you!");
	eq.set_next_hp_event(90);
	
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
		--check to see if we purposefully wiped the hate list, if so ignore this
		if(ignore_reengage) then
			ignore_reengage=false;
			return;
		end
		phase = 1;
		e.self:Emote(" let's loose a low gutteral laugh.");
		e.self:Shout("TREMBLE BEFORE ME! You will ALL be forgotten!");
		--lets get some pressure on the tank, and anyone around them
		eq.set_timer("TankAEDMG", math.random(1000,3000));
		eq.stop_timer("reset");
		
	else
		--check to see if we purposefully wiped the hate list, if so ignore this
		if(ignore_disengage) then
			ignore_disengage=false;
			return;
		end
		--check to see if we purposefully wiped the hate list, if so ignore this
		eq.stop_timer("TankAEDMG");
		eq.stop_timer("AE");
		eq.set_timer("reset",10000);
	end
end

function event_timer(e)

	if(e.timer == "TankAEDMG") then

		eq.stop_timer(e.timer);
		eq.set_timer("TankAEDMG",10000);
		--Word of the Reaver
		--AOE dmg around the tank
		e.self:CastSpell(17355,e.self:GetTarget():GetID());
	
	elseif (e.timer == "AE") then

		eq.stop_timer(e.timer);
		--Once every 60 seconds, AoE Lifetap, Manatap, Blind, 100% snare
		eq.zone_emote(MT.Emote, "You feel your heart race as your vision turns black!");
		e.self:CameraEffect(1000,5);
		e.self:CastSpell(17039,e.self:GetID())
		--No Overlap of AoE
		eq.stop_timer("TankAEDMG");
		eq.set_timer("TankAEDMG",10000);
		--lets go again in 30 sec!
		if(phase == 7 ) then
			--if under 25% change to every 15 seconds
			eq.set_timer("AE", 20000);
		else
			--if above 25% every 30 sec
			eq.set_timer("AE", 30000);
		end
		

	elseif (e.timer == "reset") then
		eq.stop_timer(e.timer);
		e.self:SetHP(e.self:GetMaxHP())
		phase = 1;
		eq.set_next_hp_event(90);
		--depop all adds incase there are leftovers
		DepopAdds(e);
	end
end

function SpawnAll(e)
	local xloc = e.self:GetX()+75;
	local yloc = e.self:GetY()+25;
	local zloc = e.self:GetZ();
	local heading = e.self:GetHeading();
	-- sanity depop
	eq.depop_all(1120001111);
	eq.depop_all(1120001113);
	eq.depop_all(1120001112);
		eq.zone_emote(MT.Emote,"WHAT DO YOU FEEL?!");
	-- spawn randomly around Panic.
	
	eq.spawn2(1120001111,0,0,xloc + math.random(-50,50),yloc + math.random(-50,50),zloc,heading); --Fright
	eq.spawn2(1120001113,0,0,xloc + math.random(-50,50),yloc + math.random(-50,50),zloc,heading); --Terror
	eq.spawn2(1120001112,0,0,xloc + math.random(-50,50),yloc + math.random(-50,50),zloc,heading); --Dread
end
	
function SpawnFright(e)

	local xloc = e.self:GetX();
	local yloc = e.self:GetY();
	local zloc = e.self:GetZ();
	local heading = e.self:GetHeading();
	-- sanity depop
	eq.depop_all(1120001111);
	-- spawn randomly around Panic.
	eq.spawn2(1120001111,0,0,xloc +75,yloc + 25,zloc,heading);
	

end
function SpawnTerror(e)

	local xloc = e.self:GetX();
	local yloc = e.self:GetY();
	local zloc = e.self:GetZ();
	local heading = e.self:GetHeading();
	-- sanity depop
	eq.depop_all(1120001113);
	-- spawn randomly around Panic.
	eq.spawn2(1120001113,0,0,xloc +75,yloc + 25,zloc,heading);
	

end
function SpawnDread(e)

	local xloc = e.self:GetX();
	local yloc = e.self:GetY();
	local zloc = e.self:GetZ();
	local heading = e.self:GetHeading();
	-- sanity depop
	eq.depop_all(1120001112);
	-- spawn randomly around Panic.
	eq.spawn2(1120001112,0,0,xloc +75,yloc + 25,zloc,heading);
	

end


function DepopAdds(e)

	eq.depop_all(1120001111); --Fright
	eq.depop_all(1120001113); --Terror
	eq.depop_all(1120001112); --Dread

end

function event_hp(e)
	if (e.hp_event <= 90 and phase == 1) then
		phase = 2;
		e.self:Shout("'You're not SCARED are you?!");
		--Word of Soultheft, 3 to 4kDD 5 Second Stun
		e.self:CastSpell(17658,e.self:GetID());
		--get get a target randomly
		current_target = e.self:GetHateDamageTop(e.self);
		--wipe the hate list
		ignore_reengage=true;
		ignore_disengage=true;
		e.self:WipeHateList();
		--add 3k new threat to the random target
		e.self:AddToHateList(current_target,2000);
		
		eq.set_next_hp_event(85);
	
	elseif (e.hp_event <= 85 and phase == 2) then
		phase = 3;
		e.self:Shout("'You're not SCARED are you?!");
		--Word of Soultheft, 3 to 4kDD 5 Second Stun
		e.self:CastSpell(17658,e.self:GetID());
		--get get a target randomly
		current_target = e.self:GetHateRandom();
		--wipe the hate list
		ignore_reengage=true;
		ignore_disengage=true;
		e.self:WipeHateList();
		--add 3k new threat to the random target
		e.self:AddToHateList(current_target,3000);
		eq.set_next_hp_event(80);
	elseif (e.hp_event <=80 and phase == 3) then
		phase = 4;
		e.self:Shout("'You're not SCARED are you?!");
		-- remove red head
		--Word of Soultheft, 3 to 4kDD 5 Second Stun
		e.self:CastSpell(17658,e.self:GetID());
		--get get a target randomly
		current_target = e.self:GetHateRandom();
		--wipe the hate list
		ignore_reengage=true;
		ignore_disengage=true;
		e.self:WipeHateList();
		--add 3k new threat to the random target
		e.self:AddToHateList(current_target,3000);
		eq.set_next_hp_event(75);

	elseif (e.hp_event <= 75 and phase == 4) then
		phase =5;
		e.self:Shout("WHAT IS PANIC WITHOUT FRIGHT?!");
		--SPAWN Fright
		SpawnFright(e);
		eq.set_next_hp_event(50);
	elseif (e.hp_event <= 50 and phase ==5) then
		phase = 6;
		e.self:Shout("WHAT IS PANIC WITHOUT TERROR?!");
		--SPAWN Terror
		SpawnTerror(e);
		eq.set_next_hp_event(25);
	elseif (e.hp_event <= 25 and phase == 6) then
		phase = 7;
		e.self:Shout("WHAT IS PANIC WITHOUT DREAD?!");
		--SPAWN Dread
		SpawnDread(e);
	elseif (e.hp_event <= 3 and phase == 7) then
		phase = 8;
		e.self:Shout("TOGETHER WE ARE FEAR!");
		--SPAWN ALL 3
		SpawnAll(e);
	end
end

function event_death_complete(e)

	e.self:Shout("You may have defeated me, but you will never forget me...");
	DepopAdds(e);
	eq.stop_timer("AE");
	eq.stop_timer("TankAEDMG");
	eq.world_emote(15, "As Panic fades, you remember the Apocryphal words of Fear itself. These words alone are not enough... but your Ally remembers what will be.");

end
