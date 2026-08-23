local quintItemId=56018
local zoneId = 223

function event_say(e)
	if (e.message:findi("hail")) then
		e.self:Say("Welcome to the Prison of the Forsaken, mortal!  Would you like to [teleport] to a location or have you found the [mystical item] to control time?")
	elseif (e.message:findi("teleport")) then
		-- Build out a list of locations the player can teleport to
		e.self:Say("I can send you to any of the following locations: ")
		for _,v in ipairs(generate_locations()) do
			e.self:Say(v)
		end
	elseif (e.message:findi("air trial")) then
		-- teleport to air trial
		movePlayer(e, -36, 1352, 496, 124)
	elseif (e.message:findi("water trial")) then
		-- teleport to water trial
		movePlayer(e, -51, 857, 496, 124)
	elseif (e.message:findi("earth trial")) then
		-- teleport to earth trial
		movePlayer(e, -35, 1636, 496, 124)
	elseif (e.message:findi("fire trial")) then
		-- teleport to fire trial
		movePlayer(e, -55, 569, 496, 124)
	elseif (e.message:findi("undead trial")) then
		-- teleport to undead trial
		movePlayer(e, -26, 1103, 496, 124)
	elseif (e.message:findi("phase 3")) then
		-- teleport to top of phase 3 area
		movePlayer(e, 898, 1106, 495, 124)
	elseif (e.message:findi("phase 4")) then
		-- teleport to phase 4 entry room
		movePlayer(e, -355, 0, 350, 124)
	elseif (e.message:findi("phase 5")) then
		-- teleport to phase 5 entry room
		movePlayer(e, -355, 0, 5, 124)
	elseif (e.message:findi("quarm")) then
		-- teleport to quarm lair
		movePlayer(e, 195, -1115, 0, -124)
	elseif (e.message:findi("mystical item")) then
		e.self:Say("I can help you control time, but it comes at a cost.  Give me one [Time Phased Quintessence] and I will move time forward so you can immediately confront the lesser gods!")
	elseif (e.message:findi("time phased quintessence")) then
		e.self:Say("The Time Phased Quintessence is a key element for me to manipulate time within the prison.  While they are rare, the same beings trapped in this prison are rumored to have them") 
	end
end

function event_trade(e)
	local item_lib = require("items")
	if (item_lib.check_turn_in(e.trade, {item1 = quintItemId})) then
		-- Quintessence has been turned in.  Only progress if we're still in phase 1.  Otherwise, return it
		currentPhase = tonumber(eq.get_zone():GetVariable("Phase")) or 0
		if (currentPhase == 0)  then
			progressToP4()
			e.self:Say("The lesser gods await you!  Good luck, hero!")
		else
			e.other:SummonItem(quintItemId)
			e.self:Say("It seems you have gone off and already set the timeline forward.  You must continue to progress on your own.  Next time, come to me first!")
		end
	else
		item_lib.return_items(e.self, e.other, e.trade)
	end
end

function progressToP4()
	depopAllP1Mobs()
	eq.get_zone():SetVariable("Phase","3")
	eq.get_entity_list():GetSpawnByID(157394):Repop(2) -- NPC: zone_status
	eq.get_entity_list():GetSpawnByID(157395):Repop(2) -- NPC: zone_emoter
	eq.get_entity_list():GetSpawnByID(3388052):Repop(2) -- NPC: Herald of Druzzil Ro
end

function depopAllP1Mobs()
	-- disable all spawn conditions
	for i = 1, 10, 1 do
		eq.spawn_condition("potimeb",eq.get_zone_instance_id(),i,0)
	end
	-- depop all p1 mobs and controllers
	eq.depop_zone(false)
end

function movePlayer(e, x, y, z, h)
	e.other:MovePCInstance(zoneId, eq.get_zone_instance_id(), x, y, z, h);
end

function generate_locations()
	local locations = {}
	-- generate the static Phase 1 locations
	table.insert(locations, "--Phase 1/2--")
	table.insert(locations, "[Air Trial]")
	table.insert(locations, "[Fire Trial]")
	table.insert(locations, "[Earth Trial]")
	table.insert(locations, "[Water Trial]")
	table.insert(locations, "[Undead Trial]")
	
	lastCompletedPhase = tonumber(eq.get_zone():GetVariable("Phase")) or 0

	if (lastCompletedPhase > 1) then
		-- Phase 2 has been completed, add phase 3 portal
		table.insert(locations, "[Phase 3]")
	end
	if (lastCompletedPhase > 2) then
		-- Phase 3 has been completed, add phase 4 portal
		table.insert(locations, "[Phase 4]")
	end
	if (lastCompletedPhase > 3) then
		-- Phase 4 has been completed, add phase 5 portal
		table.insert(locations, "[Phase 5]")
	end
	if (lastCompletedPhase > 4) then
		-- Phase 5 has been completed, add Quarm portal
		table.insert(locations, "[Quarm]")
	end
	return locations
end
