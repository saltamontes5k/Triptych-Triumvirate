-- Static Version

function event_signal(e)
	e.self:AddItem(57085,1); -- Item: Ring of the Undead Spiritcharmer
	eq.set_data("shaman_epic15_nadox", "1",tostring(eq.seconds("2h"))); -- 2H Cooldown on event
end
