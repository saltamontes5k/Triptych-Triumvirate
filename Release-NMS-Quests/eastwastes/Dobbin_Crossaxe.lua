local ring_seven_ready = false;

function event_signal(e)
	if e.signal == 1 then
		ring_seven_ready = true;
		e.self:Say("We thought it was too late, the Dain will be very pleased!");
		e.self:Say("Please friend, show me your Mithril ring and I will show you our gratitude.");
	elseif e.signal == 2 then
		ring_seven_ready = false;
	end

end

function event_trade(e)
	local item_lib = require('items');
	if item_lib.check_turn_in(e.trade, {item1 = 30162}) then -- Item: Mithril Coldain Insignia Ring
		if ring_seven_ready then
			e.self:Say("Thank you. " .. e.other:GetName().. ", your deeds will be mentioned to the Dain. Please take this note from Corbin to Garadain. it may help him to achieve victory over the enemy.");
			ring_seven_ready = false;
			e.other:QuestReward(e.self,0,0,0,0,1047,10000); -- Item: Note from Corbin
			e.other:Faction(406, 5);	-- Faction: Coldain
			e.other:Faction(405, 5);	-- Faction: Dain
			e.other:Faction(419, -10);	-- Faction: Kromrif
			e.other:Faction(448, -10);	-- Faction: Kromzek
			eq.depop_all(116119);		-- NPC: Corbin Blackwell
		else
			e.self:Say(string.format("I have no need for this item %s, you can have it back.", e.other:GetCleanName()));
			e.other:SummonItem(30162); -- Item: Mithril Coldain Insignia Ring
		end
	end
	item_lib.return_items(e.self, e.other, e.trade);
end
