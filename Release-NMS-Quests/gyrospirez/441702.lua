-- #Engineer_XXXIX (441702) -- Intelligence Gathering (301107). Casts
-- Static Bolt (7630), a heavy frontal AE -- face him away from the group.

function event_combat(e)
	if e.joined then
		e.self:SetTimer("bolt", 25000)
	else
		e.self:StopTimer("bolt")
	end
end

function event_timer(e)
	if e.timer == "bolt" then
		local t = e.self:GetTarget()
		if t ~= nil then
			e.self:CastSpell(7630, t:GetID())
		end
	end
end
