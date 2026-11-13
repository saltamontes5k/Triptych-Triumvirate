-- NPCID 223169
--Phase 1 - Terlok of Earth Trial
--potimeb

local ring = require("potime_ring")

local event_counter = 0;
local terlok = false;

local event_mobs = {223106,223119,223147};

--specify trial boundaries for player check routine
local min_x = -75;
local max_x = 90;
local min_y = 1573;
local max_y = 1695;
local player_limit = 18;	

-- 1-hour wipe cooldown state: WING_N keys the shared reset_at stamp, and the
-- wipe detector arms a stamp when no living raider stands in the wing bounds.
local WING_N = 1;
local wing_armed = false;
local wipe_ticks = 0;
local win_announced = false;

function event_spawn(e)
	-- create a proximity to set the spawn timer
	event_counter = 0;
	local xloc = e.self:GetX();
	local yloc = e.self:GetY();
	eq.set_proximity(xloc - 80, xloc + 80, yloc - 60, yloc + 60);
end

function event_enter(e)
	if tonumber(eq.get_zone():GetVariable("Terlok of Earth")) or 0 > 0 then
		eq.zone_emote(14,"You have already completed the Trial of Earth!");
	else
		-- a wing that wiped may not re-arm for one hour
		local reset_at = tonumber(eq.get_data(eq.get_zone_instance_id() .. "-wing-" .. WING_N .. "-reset_at")) or 0
		local since_wipe = os.time() - reset_at
		if reset_at > 0 and since_wipe < 3600 then
			e.other:Message(MT.LightGray, string.format("The Trial of Earth refuses to begin again so soon. It will accept challengers again in %i minutes.", math.ceil((3600 - since_wipe) / 60)));
			return;
		end
		wing_armed = true;
		wipe_ticks = 0;
		for index, mob in ipairs(event_mobs) do
			eq.depop_all(mob);
		end
		-- tell zone_status phase 1 was started
		eq.signal(223097,1,5*1000);
		-- wait 45 seconds before spawning the mobs.
		eq.clear_proximity();
		eq.set_timer("Phase1Earth",10000);
		eq.set_timer("player_count",5 * 1000);	--check to ensure only 18 players in trial area
	end
end

function event_timer(e)
	if ring.handle_timer(e) then return end

	if(e.timer == "Phase1Earth") then
		-- spawn first wave of 3 a_pile_of_living_rubble
		eq.spawn2(223106,0,0,70.3,1644.5,493.7,371);
		eq.spawn2(223106,0,0,70.3,1664.5,493.7,371);
		eq.spawn2(223106,0,0,70.3,1624.5,493.7,371);
		eq.stop_timer("Phase1Earth");
	elseif(e.timer == "player_count") then
		CheckPlayerCount(e);
		CheckWipe(e);
	end
end

function event_signal(e)
	-- signal 1 comes from the phase 1 a_rock_shaped_assassin
	-- and is used to increment a counter so we know when to spawn the next wave.
	if (e.signal == 1) then
		event_counter = event_counter + 1;
		-- spawn Terlok_of_Earth
		if (event_counter == 6) then

			-- Check on which version to spawn
			local expedition = eq.get_expedition()
			if expedition.valid then
				local terlok_bucket = tonumber(eq.get_zone():GetVariable("Terlok of Earth")) or 0
				if terlok_bucket == 0 then
					eq.unique_spawn(223119,0,0,70.3,1644.5,493.7,371); 	--Terlok_of_Earth (223119)
				else
					eq.unique_spawn(223238,0,0,70.3,1644.5,493.7,371);		--#Shadow_of_Terlok (223238)  PH version
				end
			end
			--event_counter = 0;
		end
	-- signal 2 comes from Terlok_of_Earth
	elseif (e.signal == 2) then
		terlok = true;
	end
	TrialWinCheck(e);
end

function TrialWinCheck(e)	--to make successful end event once both boss and adds are dead
	if win_announced then return end
	if terlok and not eq.get_entity_list():IsMobSpawnedByNpcTypeID(223147) and not eq.get_entity_list():IsMobSpawnedByNpcTypeID(223106) then
		win_announced = true;
		wing_armed = false;
		-- tell zone_status
		--eq.signal(223097,223169); -- Add Loot Lockout for Phase 1 Wing
		--eq.signal(223097,2); -- Increment Phase 1 Wing Counter
		eq.zone_emote(MT.LightGray,"Ethereal mists gather at the far wall, causing it to fade in and out of focus.");

		-- hand the wing back to the Ring of Time.
		ring.finish(e, 20000, min_x, max_x, min_y, max_y);
	end
end

function CheckPlayerCount(e)
	local player_list = eq.get_entity_list():GetClientList();
	local count = 0;
	if(player_list ~= nil) then
		for pc in player_list.entries do
			if pc:GetX() >= min_x and pc:GetX() <= max_x and pc:GetY() >= min_y and pc:GetY() <= max_y and not pc:GetGM() then
				count = count + 1;
				if count > player_limit then 
					pc:MovePC(219,-37,-110,13,0);	--boot to Time A
				end
			end
		end
	end
end

-- A wing counts as wiped when no living raider stands inside its bounds for
-- three consecutive player_count ticks (15 seconds). The stamp drives the
-- 1-hour re-arm cooldown and hands the raid back an hour of fail timer.
function CheckWipe(e)
	if not wing_armed then
		return;
	end
	local alive = 0;
	local player_list = eq.get_entity_list():GetClientList();
	if player_list ~= nil then
		for pc in player_list.entries do
			if pc.valid and not pc:GetGM() and pc:GetHP() > 0
				and pc:GetX() >= min_x and pc:GetX() <= max_x
				and pc:GetY() >= min_y and pc:GetY() <= max_y then
				alive = alive + 1;
			end
		end
	end
	if alive == 0 then
		wipe_ticks = wipe_ticks + 1;
		if wipe_ticks >= 3 then
			wing_armed = false;
			eq.signal(223097, 100 + WING_N, 0);
			eq.zone_emote(MT.LightGray, "The Trial of Earth falls silent; its hourglass turns over. If the trial must begin again, an hour must first pass.");
		end
	else
		wipe_ticks = 0;
	end
end
			
