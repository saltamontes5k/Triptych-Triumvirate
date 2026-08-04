function event_say(e)
	local x,y,z,h = e.self:GetX(), e.self:GetY(), e.self:GetZ(), e.self:GetHeading();
	if e.message:findi("hail") then
		e.other:Message(MT.NPCQuestSay, "I am the spectral image of Besana. In life, I guarded the spirits of my people and now in death I make sure the dead have a proper burial. Those who have tried to stop the menacing invaders of this area have suffered many losses. I have placed many bodies here in the ground until their spirits return to inhabit them. The spirits looking for their bodies need only say they [wish to live again] and I will dig up the body for them.")
	elseif e.message:findi("wish to live again") then
		e.other:Message(MT.NPCQuestSay, "Besana the Gravedigger says, 'And so you shall my friend. And so you shall.'");
		local clist = eq.get_entity_list():GetCorpseList();
		if clist ~= nil then
			for corpse in clist.entries do
				if corpse:IsPlayerCorpse() then
					corpse:GMMove(x,y,z,h);
				end
			end
		end
	end
end
