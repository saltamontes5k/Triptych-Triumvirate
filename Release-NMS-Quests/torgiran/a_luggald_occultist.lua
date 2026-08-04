-- Taskmaster Luga Event

local spirit_sp2    = {
    29975,29976,29977,29978
}

local tzobodinroom_sp2  = {
    46865,29967,46868,29968,46869
}

function event_death_complete(e)
    if has_value(spirit_sp2, e.self:CastToNPC():GetSp2()) then --spawn groups inside the water spirit room
        eq.signal(226213,1); -- signal An_ancient_spirit (226213) to add to wave counter
    elseif has_value(tzobodinroom_sp2, e.self:CastToNPC():GetSp2()) then --spawn groups inside Ritualist Tzobodin room
        eq.signal(226218,1); -- signal A_hate (226218) to add to wave counter
    end
end

function has_value (tab, val)
	for index, value in ipairs(tab) do
		if value == val then
			return true
		end
	end
	return false
end