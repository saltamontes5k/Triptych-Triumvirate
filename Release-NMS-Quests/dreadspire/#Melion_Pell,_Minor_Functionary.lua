-- dreadspire/#Melion_Pell,_Minor_Functionary.lua
-- Depths of Darkhollow: task 505745 "Frustrated Functionary" -> Dreadspire Library key.
local dodh = require("dodh_helper");

function event_say(e)
	local t = e.message:lower();
	if t:find("hail") then
		e.self:Say("'Oh mighty master, please spare me from needless intrusions. Did [they] send you to ask me some foolish question about where your quarters are or whose boot you need to lick to get access to a chamber pot?'");
	elseif t:find("they") then
		e.self:Say("'Did they also send you to further their attempts to drive me completely mad? Me, Magnificent Melion, once master of Erudin in all but title, trapped here to tend to the needs of wet-behind-the-ears visitors.' Melion sighs. 'Fine. I will once again be forced to prove that my powers of deduction are still brilliant. It seems you have some sort of [hunger].'");
	elseif t:find("hunger") or t:find("task") then
		e.self:Say("'They have it. I had it. The Master has it. After decades of trying to attain my rightful place here I have grown weary, and they have assigned me the stupidest [tasks] they can find. You could do these chores for me and I could give you some information that you might need. You appear to be the [purchasable] type.'");
	elseif t:find("purchasable") then
		if e.other:IsTaskCompleted(dodh.tasks.frustrated_functionary) then
			e.self:Say("'You have already done my chores. Do not expect me to repeat myself.'");
		else
			if not e.other:IsTaskActive(dodh.tasks.frustrated_functionary) then
				e.other:AssignTask(dodh.tasks.frustrated_functionary, e.self:GetID());
			end
			e.self:Say("'Then make yourself useful. Slay eight of the grayfang bats down the spire, and pry a Coral-set Golden Necklace from one of the castle orcs. Bring me the necklace and I will see you get the key to the library.'");
		end
	elseif t:find("necklace") or t:find("library") then
		e.self:Say("'The orcs of the castle hoard trinkets they cannot appreciate. A Coral-set Golden Necklace would buy my silence with the Quartet. Bring it to me.'");
	end
end

function event_trade(e)
	local item_lib = require("items");
	local c = e.other;

	-- Coral-set Golden Necklace -> Dreadspire Library key
	if item_lib.check_turn_in(e.trade, { item1 = dodh.items.coral_golden_necklace }) then
		if c:IsTaskActive(dodh.tasks.frustrated_functionary)
			or c:IsTaskCompleted(dodh.tasks.frustrated_functionary) then
			c:UpdateTaskActivity(dodh.tasks.frustrated_functionary, 1, 1);
			if (tonumber(c:GetBucket(dodh.flags.library_key)) or 0) == 0 then
				c:SetBucket(dodh.flags.library_key, "1");
			end
			e.self:Say("'Ah, the necklace! Yes, this will do nicely. As promised, the library door is now yours to pass. Now leave me be.'");
			c:Message(15, "You have been granted the Dreadspire - Key to Library.");
		else
			e.self:Say("'What am I to do with this? I have no interest in trinkets.'");
			c:SummonFixedItem(dodh.items.coral_golden_necklace);
		end
		return;
	end

	item_lib.return_items(e.self, e.other, e.trade);
end
