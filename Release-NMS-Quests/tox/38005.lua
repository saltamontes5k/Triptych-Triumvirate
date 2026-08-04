-- Quest: Luggald Flesh

function event_killed_merit(e)
	if e.other:GetBucket("tsoma_2") ~= "" then
		e.other:SetGlobal("tsoma", "3", 5, "F");
	end
end