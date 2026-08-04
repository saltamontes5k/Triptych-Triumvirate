function event_say(e)
	if e.message:findi("Hail") then
		local situation_link = eq.silent_say_link("situation")
		e.self:Say(
			string.format(
				"Mortals, this far into the planes? Something that I never thought that I would see. Regardless that does not help my [%s] any does it?",
				situation_link
			)
		)
	elseif e.message:findi("situation") then
		local temple_link = eq.silent_say_link("Mithaniel's Temple")
		e.self:Say(
			string.format(
				"Not that it is your business, but this is where I call home. I have lost track of the years that I have spent here. This valley is my home, for I was exiled from [%s]. It is not a story that I am proud of and do not wish to share with you. So be one with you.",
				temple_link
			)
		)
	elseif e.message:findi("Mithaniel's Temple") then
		local information_link = eq.silent_say_link("information")
		e.self:Say(
			string.format(
				"Only a mortal would be as thick headed to know not when to take their leave. He and his legions call his temple The Halls of Honor. Paladins that have served him well on Norrath have the opportunity to ascend into his ranks. They are in training to make sure that they are always prepared to defend what they believe is the right and honorable thing to do. Mithaniel is an extremely proud being, and will accept any challenge that you may have to offer him. If you are willing to challenge him, I may have some [%s] you will find useful.",
				information_link
			)
		)
	elseif e.message:findi("information") then
		local paid_link = eq.silent_say_link("paid")
		e.self:Say(
			string.format(
				"There are other methods to enter the Halls of Honor than those that are readily apparent, and as a former soldier of Marr I can offer you access into the Halls; however as with all such arrangements there must be something [%s] for something earned.",
				paid_link
			)
		)
	elseif e.message:findi("paid") then
		e.self:Say("I was not the only member of my squad that was sent into exile, my brothers in arms, were the impetus for our exile. I was but a mere pawn. They now reside in the Plane of Justice as bodiless shades. Their punishment was too lax for their actions; I want their eternal souls to be mine. Find a smith who will teach you to create a box of souls, weaken the shades, then capture their souls and return all three to me.")
	end
end

function event_trade(e)
	local item_lib = require("items")
	if item_lib.check_turn_in(e.trade, {item1 = 29281, item2 = 29292, item3 = 29293, item4 = 29294}) then
		e.self:Say("Hmm, this is minor vindication, but vindication nonetheless. I will never again fight with my old compatriots, but now I know the punishment of those responsible for my exile is fitting for their crime. We did have an agreement, and while stripped of my rank I still have my honor. This ring is what all Soldiers of Marr wear, it serves no use for me any longer, it is yours now.")

		if e.other:IsGrouped() then
			local group = e.other:GetGroup()
			if group ~= nil then
				local member_count = group:GroupCount()
				for i = 0, member_count - 1 do
					local member = group:GetMember(i)
					if member ~= nil and member:IsClient() then
						member:SummonItem(29214) -- Item: Ring of Marr
					end
				end
			end
		end
	end

	item_lib.return_items(e.self, e.other, e.trade)
end