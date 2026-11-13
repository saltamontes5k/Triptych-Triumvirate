-- NPCID 223172
--Phase 1 - Anar of Water Trial
--potimeb

local ring = require("potime_ring")

local event_counter = 0;
local event_mobs = {223092,223093,223104,223091,223100,223115};

--specify trial boundaries for player check routine
local min_x = -75;
local max_x = 90;
local min_y = 805;
local max_y = 920;
local player_limit = 18;	

-- 1-hour wipe cooldown state: WING_N keys the shared reset_at stamp, and the
-- wipe detector arms a stamp when no living raider stands in the wing bounds.
local WING_N = 4;
local wing_armed = false;
local wipe_ticks = 0;

function event_spawn(e)
	-- create a proximity to set the spawn timer
	event_counter = 0;
	local xloc = e.self:GetX();
	local yloc = e.self:GetY();
	eq.set_proximity(xloc - 80, xloc + 80, yloc - 60, yloc + 60);
end

function event_enter(e)
	if tonumber(eq.get_zone():GetVariable("Anar of Water")) or 0 > 0 then
		eq.zone_emote(14,"You have already completed the Trial of Water!");
	else
		-- a wing that wiped may not re-arm for one hour
		local reset_at = tonumber(eq.get_data(eq.get_zone_instance_id() .. "-wing-" .. WING_N .. "-reset_at")) or 0
		local since_wipe = os.time() - reset_at
		if reset_at > 0 and since_wipe < 3600 then
			e.other:Message(MT.LightGray, string.format("The Trial of Water refuses to begin again so soon. It will accept challengers again in %i minutes.", math.ceil((3600 - since_wipe) / 60)));
			return;
		end
		wing_armed = true;
		wipe_ticks = 0;
		-- depop all mobs to prevent duplicates
		for index, mob in ipairs(event_mobs) do
			eq.depop_all(mob);
		end
		-- tell zone_status phase 1 was started
		eq.signal(223097,1,5*1000);
		-- wait 45 seconds before spawning the mobs.
		eq.clear_proximity();
		eq.set_timer("Phase1Water",10000);
		eq.set_timer("player_count",5 * 1000);	--check to ensure only 18 players in trial area
	end
end

function event_timer(e)
	if ring.handle_timer(e) then return end

	if(e.timer == "Phase1Water") then
		-- spawn first wave of 2 a_triloun_gatherer 
		eq.spawn2(eq.ChooseRandom(223092,223093),0,0,48,892,495,371);
		eq.spawn2(eq.ChooseRandom(223092,223093),0,0,48,842,495,371);

		-- Check on which version to spawn
		local expedition = eq.get_expedition()
		if expedition.valid then
			local anar_bucket = tonumber(eq.get_zone():GetVariable("Anar of Water")) or 0
			if anar_bucket == 0 then
				eq.spawn2(223104,0,0,68,867,495,371);	--Anar_of_Water (223104)
			else
				eq.spawn2(223091,0,0,68,867,495,371);	--#Shadow_of_Anar (223091)
			end
		end
		eq.stop_timer("Phase1Water");
	elseif(e.timer == "player_count") then
		CheckPlayerCount(e);
		CheckWipe(e);
	end
end


function event_signal(e)
	-- signal 1 comes from the phase 1 mobs and is used to increment a
	-- counter so we know when to signal the win
	if (e.signal == 1) then
		event_counter = event_counter + 1;
		-- win on a 7 count
		if (event_counter == 7) then
			-- tell zone_status
			--eq.signal(223097,223172); -- Add Loot Lockout for Phase 1 Wing
			--eq.signal(223097,2); -- Increment Phase 1 Wing Counter
			wing_armed = false;
			eq.zone_emote(MT.LightGray,"Ethereal mists gather at the far wall, causing it to fade in and out of focus.");
			-- hand the wing back to the Ring of Time.
			ring.finish(e, 20000, min_x, max_x, min_y, max_y);
		end
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
			eq.zone_emote(MT.LightGray, "The Trial of Water falls silent; its hourglass turns over. If the trial must begin again, an hour must first pass.");
		end
	else
		wipe_ticks = 0;
	end
end
