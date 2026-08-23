--Shaman Cudgel Quest 6
function event_say(e)
	local Shaman_Cudgel_Progress	= e.other:GetBucket("Shaman_Cudgel")

	if Shaman_Cudgel_Progress == "6.1" then
		if e.other:GetLevel() >= 45 then
			if e.message:findi("hail") then
				e.self:Say("Ahh!! A conversationalist. How good to meet you, " .. e.other:GetCleanName() .. ". Yes. I have heard of you. Go ahead and ask for that which has brought you to my tower and emboldened you to slay my weaker minions.");
			elseif e.message:findi("sisters of scale") then
				e.self:Say("What a coincidence! I, too, seek a skull. Perhaps you might help me [obtain the skull]. Perhaps then you shall have the skull you desire.");
			elseif e.message:findi("obtain the skull") then
				e.self:Say("I am sure you would not mind removing the head of a scaled mystic. I hope not. There is an old Iksar who once called me slave. Now he shall adorn my wall, mounted on a fine plaque. His name is Digalis. Find him. Do not return until your task is complete.");
			end
		else
			e.self:Say("Come back when you are more experienced and you can assist us.");
		end
	else
		e.self:Say("Go away, I am busy.");
	end
end

function event_trade(e)
	local item_lib					= require("items");
	local Shaman_Cudgel_Progress	= e.other:GetBucket("Shaman_Cudgel")

	if Shaman_Cudgel_Progress == "6.1" and item_lib.check_turn_in(e.trade, {item1 = 12764}) then -- Item: Iksar Skull
		e.self:Shout("Excellent. You show signs of a true Iksar slayer. Too, bad I have already given the skull of the Sister of Scale to another. Perhaps you would like to meet him before he departs. Say hello, Doval.");
		e.other:SummonItem(12750);						-- Item: Iksar Skull
		e.other:QuestReward(e.self,{exp = 50});
		eq.unique_spawn(87154,0,0,-4067,6351,-53, 0);	-- NPC: Clerk_Doval
		eq.set_timer("heal",20 * 1000);
	end
	item_lib.return_items(e.self, e.other, e.trade);
end

function event_timer(e)
	if e.timer == "heal" then
		local doval = eq.get_entity_list():GetNPCByNPCTypeID(87154);
		if doval.valid then
			e.self:CastSpell(12, doval:GetID()); -- Spell: Healing
		end
	end
end

function event_signal(e)
	if e.signal == 1 then
		eq.stop_timer("heal");
	end
end
