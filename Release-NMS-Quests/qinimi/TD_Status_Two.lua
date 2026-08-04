-- Thunderdome Two Player Count Checker
-- Specify dome boundaries for player check routine
local min_x = -1835;	-- East
local max_x = -1637;	-- West
local min_y = 1540;		-- South
local max_y = 1739;		-- North
local player_limit = 18;
local zone_id = eq.get_zone_id();

function event_spawn(e)
	eq.clear_proximity();
	eq.set_timer("player_count", 5 * 1000);	-- 5s player_count
end

function event_timer(e)
	if(e.timer == "player_count") then
		CheckPlayerCount(e);
	end
end

function CheckPlayerCount(e)
	local instance_id = eq.get_zone_instance_id();
	local player_list = eq.get_entity_list():GetClientList();
	local count = 0;
	if(player_list ~= nil) then
		for pc in player_list.entries do
			if pc:GetX() >= min_x and pc:GetX() <= max_x and pc:GetY() >= min_y and pc:GetY() <= max_y and not pc:GetGM() then
				count = count + 1;
				if count > player_limit then 
					pc:MovePCInstance(zone_id, instance_id, -300.73, -1480.06, -15.33, 42);	-- boot to zone in
				end
			end
		end
	end
end

function event_signal(e)
	if(e.signal == 1) then
		eq.stop_timer("player_count");
		local xloc = e.self:GetX();
		local yloc = e.self:GetY();
		eq.set_proximity(xloc - 50, xloc + 50, yloc - 50, yloc + 50);
	end
end

function event_enter(e)
	local instance_id = eq.get_zone_instance_id();
	e.other:MovePCInstance(zone_id, instance_id, -300.73, -1480.06, -15.33, 42);	-- boot to zone in
end
