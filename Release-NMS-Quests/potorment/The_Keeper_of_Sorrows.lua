function event_combat(e)
    if e.joined then
    	eq.set_timer("1",6000)
    else
        eq.stop_timer("1")
    end
end

function event_timer(e)
    if e.timer == "1" then
        if(e.self:GetZ() < -975) then
	    e.self:ForeachHateList(
	        function(ent, hate, damage, frenzy)
                    if(ent:IsClient()) then
		        ent:CastToClient():MovePCInstance(207, eq.get_zone_instance_id(),-175,354,-759,503);
                    end
	        end
	    )
	end
    end
end

function event_death_complete(e)
    if tostring(eq.get_zone_instance_version()) ~= eq.get_rule("Custom:StaticInstanceVersion") then
	eq.signal(207014,0); -- NPC: Tylis_Newleaf, depop only in open world
    end
    eq.spawn2(207066,0,0,e.self:GetX(),e.self:GetY(),e.self:GetZ(),e.self:GetHeading()); -- NPC: #Tylis_Newleaf
end

function event_killed_merit(e)
    if tostring(eq.get_zone_instance_version()) == eq.get_rule("Custom:StaticInstanceVersion") then -- award the flag automatically
        local newleaf_bucket = tonumber(e.other:GetAccountBucket("pop.flags.newleaf")) or 0
	if newleaf_bucket == 0 then
            e.other:SetAccountBucket("pop.flags.newleaf", "1")
	    e.other:Message(MT.LightBlue, "You receive a character flag!")
	end
    end
end
