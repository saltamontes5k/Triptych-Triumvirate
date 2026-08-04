function event_say(e)
	if e.message:findi("hail") then
		local rallos_bucket = tonumber(e.other:GetAccountBucket("pop.flags.rallos")) or 0
		if rallos_bucket == 1 then
			e.self:Say("The Elders say that you are now allowed to enter the Plane of Water. I shall allow you to enter, but I will not be responsible for whatever fate may befall you upon entry to this greater elemental plane.")
		else
			e.self:Say("Well met I am keeper of the Portal to the Plane of Water.")
		end
	elseif e.message:findi("elemental essences") then
		local qglobals = eq.get_globals(e.other)
		local mage_epic_global = tonumber(qglobals["mage_epic"]) or 0
		if mage_epic_global == 6 then
			e.self:Say("Oh? The Elemental Essence of water? That is what you mean, yes? Consider yourself fortunate, I know the location of the Essence. It has spent quite some time living as a minor god to the othmir.")
			eq.set_global("mage_epic_water1", "1", 5, "F")
		end
	end
end
