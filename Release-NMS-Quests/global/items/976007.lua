function event_scale_calc(e)
    -- potimeA
    if eq.get_zone_id() == 32 then
		e.self:SetScale(1.0)
    else
         e.self:SetScale(0.0) -- we actually need to set this to -1 ... which we don't support yet!
    end
end
