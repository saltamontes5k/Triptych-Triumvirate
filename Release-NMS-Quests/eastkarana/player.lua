-- BeginFile: eastkarana\player.pl
-- Quest file for East Karana: Paladin message during Necromancer Epic 1.5 (Soulwhisper)

local epic_disabled = true; -- Disabling for omens (epics) cannot reference perl expansion vars from lua.

function event_loot(e)
	if not epic_disabled then
		if e.item:GetID() == 11430 and e.self:HasItem(26896) and e.self:HasItem(14344) and e.self:HasItem(22892) then -- All 4 Paladin Heads
			e.self:Message(15, "With his last breath, the paladin says, 'You are too late. The last paladin has fled to Natimbi with the staff and is on his way to destroy it!'");
		end
	end
end
