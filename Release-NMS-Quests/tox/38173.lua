-- Quest: Luggald Rumors

function event_killed_merit(e)
	if e.other:GetBucket("grisk_2") ~= "" then
		e.other:SetGlobal("grisk", "3", 5, "F");
	end
end