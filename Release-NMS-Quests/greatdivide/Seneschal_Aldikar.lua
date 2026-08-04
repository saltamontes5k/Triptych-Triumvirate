-- Aldikar in Ring War event in GD

local consolidateTurnIn=true;
function event_spawn(e)
	stage0 = false;
	stage5 = false;
end

function event_say(e)
	if(e.message:findi("hail")) then
		e.self:Say("And a good day to you, "..e.other:GetCleanName().."!");
	end
end

function event_trade(e)
	local item_lib = require("items");
	
	if stage0 and item_lib.check_turn_in(e.trade, {item1 = 30369}) then -- 9th ring
		e.other:SummonItem(30369); -- hands back ring
		e.other:SummonItem(18511); -- orders for Zrelik
		e.self:Say(string.format("Commit these orders to memory, %s, have them ready to speak at a moment's notice. Tell your soldiers to prepare themselves. When the orders are handed to Zrelik we will take up our positions.",e.other:GetCleanName()));
		eq.set_timer("handin1", 300000); -- timer action is in encounter
		stage0 = false;
	elseif stage5 and item_lib.check_turn_in(e.trade, {item1 = 30369, item2 = 1739}) then -- Narandi's Head and 9th ring
		e.self:Emote("unsheathes a knife and shaves the beard from Narandi's face and returns the head to you, 'The Dain will require the beard for his trophy room, please accept this ring on his behalf. May it's effect aid you as you have aided us. Be certain to present the ring to the Dain when you're in town. If you remain an ally he will be most gracious, but be warned, if you fall from his good graces he will keep the ring.'");
		e.self:Say("Show the head to the surviving heroes quickly, we must report to the Dain and tend to the wounded.");
		
		e.other:Faction(406, 50); --Coldain
		e.other:Faction(405, 20); --Dain
		e.other:Faction(419, -80); --Kromrif
		e.other:Faction(448, -40); --Kromzek
		e.other:SummonItem(30385); -- 10th ring
		if not(consolidateTurnIn) then
			e.other:SummonItem(1741); -- Shorn head
		else
			-- Give all the rewards for the surviving dwarves
			churnNPC = eq.get_entity_list():GetNPCByNPCTypeID(118169);
			karginNPC = eq.get_entity_list():GetNPCByNPCTypeID(118172);
			corbinNPC = eq.get_entity_list():GetNPCByNPCTypeID(118171);
			dobbinNPC = eq.get_entity_list():GetNPCByNPCTypeID(118170);
			garadainNPC = eq.get_entity_list():GetNPCByNPCTypeID(118168);
			if (churnNPC.valid) then
				-- Churn's reward
				e.other:SummonItem(1746); -- Crown of Narandi
			end

			if (karginNPC.valid) then
				-- Kurgin's reward
				e.other:SummonItem(1745); -- Eye of Narandi
			end

			if (corbinNPC.valid) then
				-- Corbin's reward
				e.other:SummonItem(1744); -- Earring of the Frozen Skull
			end

			if (dobbinNPC.valid) then
				-- Dobbin's reward
				e.other:SummonItem(1743); -- Faceguard of Bentos the Hero
			end

			if (garadainNPC.valid) then
				-- Garadain's reward
				e.other:SummonItem(1742); -- Choker of the Wretched
			end
		end

		
		eq.stop_timer("WarEnd");
		eq.set_timer("WarEnd", 300000); -- timer action in encounter
		stage5 = false;
	end

	item_lib.return_items(e.self, e.other, e.trade);
end

function event_signal(e)
	if e.signal == 100 then
		stage0 = true;
	elseif e.signal == 105 then
		stage5 = true;
	end
end
