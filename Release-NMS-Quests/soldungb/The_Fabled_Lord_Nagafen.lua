--Fabled Lord Nagafen (1120001072, soldungb expedition version 2)
--Tuned to the FRoK stat block in reference/Fabled-Loot-Design.xlsx:
--L67, 400k HP, 250-1000 hit, AC 520 (Boss Tuning sheet). On top of the
--original phase fight this adds the Balance guards from the same sheet:
--group-size HP scaling HP x (0.5 + 0.083 x members) at first aggro,
--telegraphed magma waves (emote 2.5s ahead of the cast), and a soft
--enrage (+10% damage per minute after 15 minutes, no hard enrage).

local memory = require("nms_memory");

local phase = 1;
local current_target = nil;
local ignore_reengage = false;
local ignore_disengage = false;
local hate_to_add = 3000;

local function e_self_var_set(e, name)
	local v = e.self:GetEntityVariable(name);
	return v ~= nil and v ~= "";
end

--Group-size HP scaling (Boss Tuning sheet): 1 member = 58%, 3 = 75%,
--6 = ~100%. HP only -- damage never scales. Applied once per spawn;
--also captures the base hit range here so the soft enrage always ramps
--from the npc_types values (ModifyNPCStat persists across combat).
local function scale_hp_to_group(e)
	if (e_self_var_set(e, "fabled_hp_scaled")) then
		return;
	end
	e.self:SetEntityVariable("fabled_hp_scaled", "1");
	e.self:SetEntityVariable("original_max_hp", e.self:GetMaxHP());
	e.self:SetEntityVariable("original_min_hit", e.self:GetNPCStat("min_hit"));
	e.self:SetEntityVariable("original_max_hit", e.self:GetNPCStat("max_hit"));

	local members = 6;
	local target = e.self:GetTarget();
	if (target) then
		local dz = target:GetExpedition();
		if (dz and dz.valid) then
			members = dz:GetMemberCount();
		end
	end
	if (members < 1) then members = 1; end
	if (members > 6) then members = 6; end

	local new_max = math.ceil(e.self:GetMaxHP() * (0.5 + 0.083 * members));
	e.self:ModifyNPCStat("max_hp", tostring(new_max));
	e.self:SetHP(e.self:GetMaxHP());
end

--Soft enrage: +10% damage per minute after 15 minutes of combat (no
--hard enrage). Ramps are cumulative from the base hit range.
local function soft_enrage_tick(e)
	local minutes = tonumber(e.self:GetEntityVariable("enrage_minutes") or "0") + 1;
	e.self:SetEntityVariable("enrage_minutes", tostring(minutes));
	if (minutes <= 15) then
		return;
	end

	local ramps = minutes - 15;
	local omin = tonumber(e.self:GetEntityVariable("original_min_hit") or "250");
	local omax = tonumber(e.self:GetEntityVariable("original_max_hit") or "1000");
	local mult = 1.1 ^ ramps;
	e.self:ModifyNPCStat("min_hit", tostring(math.ceil(omin * mult)));
	e.self:ModifyNPCStat("max_hit", tostring(math.ceil(omax * mult)));
	eq.zone_emote(MT.Emote, "Lord Nagafen's fury grows beyond all containment!");
end

local function reset_enrage(e)
	e.self:SetEntityVariable("enrage_minutes", "0");
	--undo any soft-enrage ramp so the next attempt starts from base
	local omin = e.self:GetEntityVariable("original_min_hit");
	local omax = e.self:GetEntityVariable("original_max_hit");
	if (omin ~= nil and omin ~= "" and omax ~= nil and omax ~= "") then
		e.self:ModifyNPCStat("min_hit", tostring(math.floor(tonumber(omin))));
		e.self:ModifyNPCStat("max_hit", tostring(math.floor(tonumber(omax))));
	end
end

--we have spawned! lets roar!
function event_spawn(e)
	phase = 1;
	e.self:Emote(" ROARS!");
	e.self:Shout("The terror of lavastorm has arrived!");
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
		e.self:Emote(" ROARS!");
		e.self:Shout("I am Lord Nagafen! You will become my evening snack!");
		--lets get some pressure on the tank, and anyone who is stupid enough
		--be in front of the mob :)
		eq.set_timer("TankAEDMG", math.random(1000,3000));
		--design Balance guards: group-scaled HP + soft enrage clock
		scale_hp_to_group(e);
		reset_enrage(e);
		eq.set_timer("Enrage", 60000);
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
		eq.stop_timer("AEFire");
		eq.stop_timer("Enrage");
		eq.set_timer("reset",10000);
	end
end

function event_timer(e)

	if(e.timer == "TankAEDMG") then

		eq.stop_timer(e.timer);
		eq.set_timer("TankAEDMG",10000);
		--Fire beam, 6k -250 FR resist. 300 resist diff is about 40% partial resist and 60% full
		--AOE dmg around the tank
		e.self:CastSpell(42231,e.self:GetTarget():GetID());

	elseif (e.timer == "AE") then

		eq.stop_timer(e.timer);
		--telegraph the magma wave 2.5s ahead (Boss Tuning Balance guards)
		eq.zone_emote(MT.Emote, "Magma bubbles up around the dragon... take cover!");
		eq.set_timer("AEFire", 2500);

	elseif (e.timer == "AEFire") then

		eq.stop_timer(e.timer);
		--big bada boom time, once every 30 sec (15 under 25%)
		--magama wave, 5k -800 FR damage, 300 range
		eq.zone_emote(MT.Emote, "The dragon thrashes about causing magma to go everywhere!");
		e.self:CameraEffect(1000,5);
		e.self:CastSpell(23150,e.self:GetID())
		--lets not overlap our tank buster AE with the 60 sec AE
		eq.stop_timer("TankAEDMG");
		eq.set_timer("TankAEDMG",6000);
		--lets go again in 30 sec!
		if(phase == 7 ) then
			--if under 25% change to every 15 seconds
			eq.set_timer("AE", 15000);
		else
			--if above 25% every 30 sec
			eq.set_timer("AE", 30000);
		end

	elseif (e.timer == "Enrage") then

		eq.set_timer("Enrage", 60000);
		soft_enrage_tick(e);

	elseif (e.timer == "SpawnGiants") then

		eq.stop_timer(e.timer);
		SpawnGiants(e);

	elseif (e.timer == "reset") then
		eq.stop_timer(e.timer);
		e.self:SetHP(e.self:GetMaxHP())
		phase = 1;
		reset_enrage(e);
		eq.set_next_hp_event(90);
		--depop all fire giants and Rokyl
		DepopAdds(e);
	end
end

function SpawnGiants(e)
	local xloc = e.self:GetX()+75;
	local yloc = e.self:GetY()+25;
	local zloc = e.self:GetZ();
	local heading = e.self:GetHeading();
	-- sanity depop
	eq.depop_all(1120001080);
		eq.zone_emote(MT.Emote,"Fire giants show up to protect their lord!");
	-- spawn randomly around Nagafen.

	eq.spawn2(1120001080,0,0,xloc + math.random(-50,50),yloc + math.random(-50,50),zloc,heading);
	eq.spawn2(1120001080,0,0,xloc + math.random(-50,50),yloc + math.random(-50,50),zloc,heading);
	eq.spawn2(1120001080,0,0,xloc + math.random(-50,50),yloc + math.random(-50,50),zloc,heading);
	eq.spawn2(1120001080,0,0,xloc + math.random(-50,50),yloc + math.random(-50,50),zloc,heading);
	eq.spawn2(1120001080,0,0,xloc + math.random(-50,50),yloc + math.random(-50,50),zloc,heading);
	eq.spawn2(1120001080,0,0,xloc + math.random(-50,50),yloc + math.random(-50,50),zloc,heading);
	--eq.spawn2(1120001080,0,0,xloc + math.random(-50,50),yloc + math.random(-50,50),zloc,heading);
	--eq.spawn2(1120001080,0,0,xloc + math.random(-50,50),yloc + math.random(-50,50),zloc,heading);
	--eq.spawn2(1120001080,0,0,xloc + math.random(-50,50),yloc + math.random(-50,50),zloc,heading);
	--eq.spawn2(1120001080,0,0,xloc + math.random(-50,50),yloc + math.random(-50,50),zloc,heading);
end

function SpawnRokyl(e)

	local xloc = e.self:GetX();
	local yloc = e.self:GetY();
	local zloc = e.self:GetZ();
	local heading = e.self:GetHeading();
	-- sanity depop
	eq.depop_all(1120001078);
	-- spawn randomly around Nagafen.
	eq.spawn2(1120001078,0,0,xloc +75,yloc + 25,zloc,heading);


end

function DepopAdds(e)

	eq.depop_all(1120001078); --rokyl
	eq.depop_all(1120001080); --fire giants
	eq.depop_all(1120001079); --crysal

end

function event_hp(e)
	if (e.hp_event <= 90 and phase == 1) then
		phase = 2;
		e.self:Shout("'I THOUGHT YOU WEREN'T AFRAID OF ME ANYMORE!");
		--terrifying roar, -1k resist poison, 300 range
		e.self:CastSpell(6790,e.self:GetID());
		--get get a target randomly
		current_target = e.self:GetHateDamageTop(e.self);
		--wipe the hate list
		ignore_reengage=true;
		ignore_disengage=true;
		e.self:WipeHateList();
		--add 3k new threat to the random target
		--e.self:AddToHateList(current_target,2000);

		eq.set_next_hp_event(85);

	elseif (e.hp_event <= 85 and phase == 2) then
		phase = 3;
		e.self:Shout("'I THOUGHT YOU WEREN'T AFRAID OF ME ANYMORE!");
		--terrifying roar, -1k resist poison, 300 range
		e.self:CastSpell(6790,e.self:GetID());
		--get get a target randomly
		current_target = e.self:GetHateRandom();
		--wipe the hate list
		ignore_reengage=true;
		ignore_disengage=true;
		e.self:WipeHateList();
		--add 3k new threat to the random target
		--e.self:AddToHateList(current_target,3000);
		eq.set_next_hp_event(80);
	elseif (e.hp_event <=80 and phase == 3) then
		phase = 4;
		e.self:Shout("'I THOUGHT YOU WEREN'T AFRAID OF ME ANYMORE!");
		-- remove red head
		--terrifying roar, -1k resist poison, 300 range
		e.self:CastSpell(6790,e.self:GetID());
		--get get a target randomly
		current_target = e.self:GetHateRandom();
		--wipe the hate list
		ignore_reengage=true;
		ignore_disengage=true;
		e.self:WipeHateList();
		--add 3k new threat to the random target
		--e.self:AddToHateList(current_target,3000);
		eq.set_next_hp_event(75);

	elseif (e.hp_event <= 75 and phase == 4) then
		phase =5;
		e.self:Shout("ROKYL! PUT THAT CRYSTAL DOWN AND FIGHT!");
		--SPAWN Rokyl
		SpawnRokyl(e);
		eq.set_next_hp_event(50);
	elseif (e.hp_event <= 50 and phase ==5) then
		phase = 6;
		e.self:Shout("THIS IS NOT HOW I WILL BE REMEMBERED!");
		eq.set_timer("AE", math.random(1000,3000));
		eq.set_next_hp_event(25);
	elseif (e.hp_event <= 25 and phase == 6) then
		phase = 7;
		eq.stop_timer("AE");
		--eq.set_timer("AE", math.random(1000,3000));
		e.self:Shout("GUARDS! Assist me!");
		e.self:CameraEffect(2000,5);
		eq.zone_emote(MT.Emote,"Thundering footsteps can be heard in the distance.");
		eq.set_timer("SpawnGiants",120000);
	end
end

function event_death_complete(e)

	e.self:Shout("So then... my fate is sealed... until we meet again.");
	DepopAdds(e);
	eq.stop_timer("AE");
	eq.stop_timer("AEFire");
	eq.stop_timer("Enrage");
	eq.stop_timer("TankAEDMG");
	--the Fabled kill flag: A Faded Memory (26000) spawns and grants
	--SetSubflag('FNagafen','fabled_nagafen') on hail (user decision 2026-11-07)
	memory.spawn(e, "FNagafen", "fabled_nagafen");
	eq.world_emote(15, "The Fabled Nagafen memory has faded....for now.");

end
