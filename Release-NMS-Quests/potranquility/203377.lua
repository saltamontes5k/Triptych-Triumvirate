function event_say(e)
	local rallos_bucket = tonumber(e.other:GetAccountBucket("pop.flags.rallos")) or 0
	if e.message:findi("hail") then
		if rallos_bucket == 1 then
			e.self:Say("Ahh I see you have been quite busy! Many are speaking of the deeds of you and your compatriots. You have earned the trust of the Elders. You may now pass into the Plane of Earth.")
		else
			e.self:Say("Well met, I am the keeper of the Portal to the Plane of Earth.")
		end
	elseif e.message:findi("elemental essences") then
		local qglobals = eq.get_qglobals(e.other)
		local mage_epic_global = tonumber(qglobals["mage_epic"]) or 0
		if mage_epic_global == 6 then
			e.self:Say("The Essence of Earth? Indeed, I know much of it. It was captured long ago by a great geomancer. He used it to assist him in harnessing and manipulating the power of earth and stone. At last word the geomancer did something to incur the wrath of a god, and he has lost much of his power. I would find where his strength was last at its greatest, and begin my search there.")
			eq.set_global("mage_epic_earth1", "1", 5, "F")
		end
	end
end
