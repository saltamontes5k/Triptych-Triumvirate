-- Vallon Zek (214083)
-- Wave/final-round logic lives in encounters/vallon_event.lua; this file keeps
-- only the EQS-custom death hooks (static-instance PP + account bucket flag).

function event_death_complete(e)
	--spawn planar projection
	local xloc = e.self:GetX();
	local yloc = e.self:GetY();
	local zloc = e.self:GetZ();
	if tostring(eq.get_zone_instance_version()) == eq.get_rule("Custom:StaticInstanceVersion") then -- Only flag in non-respawning dz
		eq.spawn2(202368,0,0,xloc,yloc,zloc,0); -- NPC: A_Planar_Projection
	end
end

function event_killed_merit(e)
	if tostring(eq.get_zone_instance_version()) == eq.get_rule("Custom:StaticInstanceVersion") then -- Only flag in non-respawning dz
		local vallon_bucket = tonumber(e.other:GetAccountBucket("pop.flags.vallon")) or 0
		if vallon_bucket == 0 then
			e.other:SetAccountBucket("pop.flags.vallon", "1")
			e.other:Message(MT.LightBlue, "You receive a character flag!")
		end
	end
end
