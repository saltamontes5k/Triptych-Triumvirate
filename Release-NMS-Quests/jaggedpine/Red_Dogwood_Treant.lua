-- Ranger Epic 1.5

local treesize;
local currclient = Client();

function event_spawn(e)
	treesize = 1;
	eq.set_timer("grow", 2 * 1000); -- 2s
end

function event_timer(e)
	if e.timer == "grow" then
		treesize = treesize +2;
		e.self:ChangeSize(treesize);
		if treesize >= 8 then
			eq.stop_timer("grow");
		end
	elseif e.timer == "e1" then
		eq.stop_timer("e1");
		e.self:Emote("looks about for a moment. It peers at the sky and the earth for a while. It then looks down and says, We finally meet. Thank you for helping me to grow. I understand that I have been blessed by spirits of rain and earth and that is why I can speak to you and move. You have given me much, my friend. Now I would give something to you. The great treant gently pulls a small piece of wood from its bole. The wood is hard and dark. It then reaches down with one of its high branches and plucks a singular flower, smaller and of blue color that differs from the white of the others. The petals fall from the flower as he reaches out and hands you these two items. I have been with you and your people for a while. I know what you seek. That seed will grow the plant you need. The heartwood is for you. May it serve you well.");
	elseif e.timer == "e2" then
		eq.stop_timer("e2");
		if currclient.valid then
			currclient:Message(MT.NPCQuestSay,"Red Dogwood Treant speaks directly into your mind. My day of growth is a glorious one, but now that I can sense the world directly I feel a dangerous presence invading it. There is a force of chaos here, I can feel it in my limbs. I am not the only one that feels this, for I hear others thinking about it. Many of them do not know what it is, they can not understand its force, but they are reacting to it. I sense that our world is becoming more dangerous, that there is a change coming. I also feel something closer, something coming. Something knows I have become aware. It is a servant of the chaos. It... it reaches for me!");
		end
	elseif e.timer == "e3" then
		eq.stop_timer("e3");
		e.self:Emote("screams in pain. Something has grasped my very soul! It seeks to consume me! The treant begins to wither.");
	elseif e.timer == "e4" then
		eq.stop_timer("e4");
		if currclient.valid then
			currclient:Message(MT.NPCQuestSay,"In your mind you feel the treant suffering and asks your permission to serve you rather than suffer consumption. Of course you agree, and you feel the treant's relief. You sense the spirit of the amazing creature leave its own body and enter the heartwood that it so recently gave to you. It speaks to you once more before completely merging with the wood. 'I sensed another there, a great nature spirit enslaved. It was this spirit that was forced to find me and be a conduit for my destruction. You must find and free him! He suffers so! I can aid you as I did before with Senvial and Grinbik, though it may be difficult for me to speak to you again. Thank you for everything, friend.");
		end
	elseif e.timer == "depop" then
		eq.depop();
	end
end

function event_say(e)
	if e.other:HasClass(Class.RANGER) then -- Ranger Only
		local data_bucket = ("Epic-Ranger-"..e.other:CharacterID());
		local s					= nil;	-- Status Array

		if eq.get_data(data_bucket) ~= "" then -- Has Started
			local temp = eq.get_data(data_bucket);
			s = eq.split(temp, ',');
	
			epic_pre_onefive	= tonumber(s[1]);
			epic_onefive		= tonumber(s[2]);		
			epic_two			= tonumber(s[3]);
			epic_twofive		= tonumber(s[4]);

			if epic_onefive == 12 and treesize >= 8 and e.message:findi("hail") then
				e.self:Emote("looks about for a moment. It peers at the sky and the earth for a while. It then looks down and says, We finally meet. Thank you for helping me to grow. I understand that I have been blessed by spirits of rain and earth and that is why I can speak to you and move. You have given me much, my friend. Now I would give something to you. The great treant gently pulls a small piece of wood from its bole. The wood is hard and dark. It then reaches down with one of its high branches and plucks a singular flower, smaller and of blue color that differs from the white of the others. The petals fall from the flower as he reaches out and hands you these two items. I have been with you and your people for a while. I know what you seek. That seed will grow the plant you need. The heartwood is for you. May it serve you well.");
				e.other:SummonItem(62623); -- Item: Red Dogwood Heartwood
				e.other:SummonItem(62624); -- Item: Spring Dogwood Seed
				update_ranger_epic_databucket(e,epic_pre_onefive,13,epic_two,epic_twofive);
				currclient = e.other;
				eq.set_timer("e2", 4* 1000); -- 4s
				eq.set_timer("e3", 8 * 1000); -- 8s
				eq.set_timer("e4", 12 * 1000); -- 12s
				eq.set_timer("depop", 15 * 1000); -- 15s
			end
		end
	end
end

function update_ranger_epic_databucket(e,pre_one_five,one_five,two,two_five)
	eq.set_data("Epic-Ranger-"..e.other:CharacterID(), pre_one_five..","..one_five..","..two..","..two_five);
	e.other:Message(MT.Yellow, "Your quest has been advanced"); -- Made up to let people know the flags have been updated.
end
