-- Tinmizer (451601) -- Big Bynn's lair controller (dragonscaleb v52).
-- "begin" activates the dragon; event script on Big Bynn I (451600).
local prog = require("sof_progression")

local BYNN = 451600

function event_say(e)
	if e.message:findi("begin") then
		if eq.get_entity_list():IsMobSpawnedByNpcTypeID(BYNN) then
			e.self:Say("As you wish. Sweet dreams are over, dragon!")
			eq.signal(BYNN, 1)
		else
			e.self:Say("The dragon already stirs -- fight or flee!")
		end
	elseif e.message:findi("hail") then
		e.self:Say("I am Tinmizer, tinker of dragons. Tell me [begin] when "
			.. "your forces stand ready to wake Big Bynn I.")
	end
end

function event_trade(e)
	local item_lib = require("items")
	item_lib.return_items(e.self, e.other, e.trade)
end
