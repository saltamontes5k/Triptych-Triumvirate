-- Tallon Zek (214026)
-- Combat behavior (shadowstep, Avatar Power knockback, aggro bounce) lives in
-- encounters/tallon_event.lua; this file keeps only the EQS-custom death hooks
-- (static-instance PP + account bucket flag).

function event_death_complete(e)
	if tostring(eq.get_zone_instance_version()) == eq.get_rule("Custom:StaticInstanceVersion") then -- Only flag in non-respawning dz
		eq.spawn2(218068, 0, 0, e.self:GetX(), e.self:GetY(), e.self:GetZ(), e.self:GetHeading()) -- NPC: A_Planar_Projection
	end
end

function event_killed_merit(e)
	if tostring(eq.get_zone_instance_version()) == eq.get_rule("Custom:StaticInstanceVersion") then -- Only flag in non-respawning dz
		local tallon_bucket = tonumber(e.other:GetAccountBucket("pop.flags.tallon")) or 0
		if tallon_bucket == 0 then
			e.other:SetAccountBucket("pop.flags.tallon", "1")
			e.other:Message(MT.LightBlue, "You receive a character flag!")
		end
	end
end
