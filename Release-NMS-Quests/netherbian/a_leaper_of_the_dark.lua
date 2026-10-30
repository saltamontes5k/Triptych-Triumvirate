-- netherbian/a_leaper_of_the_dark.lua
-- Derelict Space Station (netherbian v66): the Leaper of the Dark. It wears
-- rogue-style hide (SetInvisible -- not pierced by see-invis, which a level
-- 40 Master Officer will not have anyway) and never auto-aggros: the SQL
-- sets aggroradius 1 (0 would be bumped to 70 by AI_Start) and the faction
-- scowls do the rest. A 1s stalk timer reveals it when anyone comes within
-- REVEAL_DIST; in combat it shadowsteps (GMMove) back to any target that
-- opens more than STEP_DIST, and re-hides a few seconds after combat ends
-- with nobody close. Kills report to the controller (signal 10) when a
-- shrouded Master Officer lands them.

local CONTROLLER  = 1520001985
local REVEAL_DIST = 45
local STEP_DIST   = 35
local FADE_DIST   = 60

local function nearest_client_dist_sq(self)
	local best = nil
	local clients = eq.get_entity_list():GetClientList()
	if not clients then
		return nil
	end
	for client in clients.entries do
		if client.valid then
			local dx = client:GetX() - self:GetX()
			local dy = client:GetY() - self:GetY()
			local dz = client:GetZ() - self:GetZ()
			local d2 = dx * dx + dy * dy + dz * dz
			if not best or d2 < best then
				best = d2
			end
		end
	end
	return best
end

function event_spawn(e)
	e.self:SetInvisible(1)
	eq.set_timer("stalk", 1000)
end

function event_timer(e)
	if e.timer == "stalk" then
		-- hidden: reveal and open combat the moment someone is close
		local d2 = nearest_client_dist_sq(e.self)
		if d2 and d2 <= REVEAL_DIST * REVEAL_DIST then
			e.self:SetInvisible(0)
			local clients = eq.get_entity_list():GetClientList()
			for client in clients.entries do
				if client.valid then
					local dx = client:GetX() - e.self:GetX()
					local dy = client:GetY() - e.self:GetY()
					local dz = client:GetZ() - e.self:GetZ()
					if dx * dx + dy * dy + dz * dz <= REVEAL_DIST * REVEAL_DIST then
						e.self:AddToHateList(client, 1)
					end
				end
			end
			eq.stop_timer("stalk")
			eq.set_timer("shadow", 5000)
		end
	elseif e.timer == "shadow" then
		-- in combat: leap back to a target that has opened up too far
		local target = e.self:GetTarget()
		if target and target.valid then
			local dx = target:GetX() - e.self:GetX()
			local dy = target:GetY() - e.self:GetY()
			if dx * dx + dy * dy > STEP_DIST * STEP_DIST then
				e.self:GMMove(target:GetX() + math.random(-5, 5),
					target:GetY() + math.random(-5, 5),
					target:GetZ(), 0, false)
			end
		end
	elseif e.timer == "refade" then
		-- out of combat: hide again once nobody lingers nearby
		local d2 = nearest_client_dist_sq(e.self)
		if not d2 or d2 > FADE_DIST * FADE_DIST then
			eq.stop_timer("refade")
			eq.stop_timer("shadow")
			e.self:SetInvisible(1)
			eq.set_timer("stalk", 1000)
		else
			eq.set_timer("refade", 3000)
		end
	end
end

function event_combat(e)
	if e.joined then
		eq.stop_timer("stalk")
		eq.set_timer("shadow", 5000)
	else
		eq.stop_timer("shadow")
		eq.set_timer("refade", 12000)
	end
end

function event_death_complete(e)
	local killer = eq.get_entity_list():GetClientByID(e.killer_id)
	if killer and killer:GetRace() == 323 then
		eq.signal(CONTROLLER, 10)
	end
end
