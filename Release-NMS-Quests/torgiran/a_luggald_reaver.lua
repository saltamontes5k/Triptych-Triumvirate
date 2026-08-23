-- Taskmaster Luga Event

local spirit_sp2    = {
    29975,29976,29977,29978
}

function event_death_complete(e)
    if has_value(spirit_sp2, e.self:CastToNPC():GetSp2()) then --spawn groups inside the water spirit room
        eq.signal(226213,1); -- signal An_ancient_spirit (226213) to add to wave counter
	elseif e.self:CastToNPC():GetSp2() == 282505 then -- spawn group inside the overlord room
        eq.signal(226204,1); -- #overlord_trigger (226204) to add to wave counter
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
