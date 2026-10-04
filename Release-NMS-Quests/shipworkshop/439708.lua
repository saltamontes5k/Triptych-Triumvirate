-- Tinny (439708) -- Tactical Teleportation (301113) escort.
-- Follow-lite: hail to sign him on; he GMMoves toward his leader every
-- few seconds (no Follow binding on this build). "wait" parks him.

function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("Tinny reporting! Gurtrude said you would come. Keep me "
			.. "in one piece and I will show you the [teleporter].")
		e.self:SetEntityVariable("leader", tostring(e.other:GetID()))
		e.self:SetTimer("follow", 6000)
	elseif e.message:findi("wait") then
		e.self:Say("Parked. Ping me when the coast is clear.")
		e.self:StopTimer("follow")
	elseif e.message:findi("teleporter") then
		e.self:Say("Up the spiral ramp, then the first right-side pad. The "
			.. "Sizentist powers up when bothered. Bother him anyway.")
	end
end

function event_timer(e)
	if e.timer ~= "follow" then return end
	local leader_id = tonumber(e.self:GetEntityVariable("leader") or "0") or 0
	if leader_id == 0 then return end
	local leader = eq.get_entity_list():GetClientByID(leader_id)
	if leader == nil or not leader.valid then return end
	local dist = e.self:CalculateDistance(leader:GetX(), leader:GetY(), leader:GetZ())
	if dist > 40 then
		local dx = leader:GetX() - e.self:GetX()
		local dy = leader:GetY() - e.self:GetY()
		e.self:GMMove(e.self:GetX() + dx * 0.35, e.self:GetY() + dy * 0.35,
			leader:GetZ())
	end
end
