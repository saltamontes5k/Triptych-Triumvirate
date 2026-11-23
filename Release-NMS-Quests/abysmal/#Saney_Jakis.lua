-- Breakdown in Communication #3: Riwwi
local god_guide = require("god_guide")

function event_say(e)
	if e.message:findi("Hail") then
		e.other:Message(MT.NPCQuestSay, "Saney Jakis says 'Pleasure to meet you, ".. e.other:GetName() .. "! How are you making out? My friend and I traveled from afar in search of adventure and we've certainly found it. This strange land has delivered excitement in spades. Hasn't it, Rorrst?");
    elseif e.message:findi("key") then
		e.other:Message(MT.NPCQuestSay, "Saney Jakis says 'Are you trying to reason with Rorrst?'  Saney unsuccessfully attempts to stifle her tinny, high-pitch chortle.  'Now THAT'S a waste of time, and I would know.  Personal experience.  If you want something from him you'll have to try a different angle:  Appeal to his coinpurse.  Money talks.  Tell him I said so.");
    elseif e.message:findi("guide") or e.message:findi("progression") then
		e.other:Message(MT.NPCQuestSay, "Saney Jakis says 'The Brotherhood has put together a walking guide to the temples of Taelosia. Here, take this - right-click it whenever you need a reminder.'");
		god_guide.show(e.other);
		if e.other:CountItem(god_guide.CLICKY_ID) == 0 then
			e.other:SummonItem(god_guide.CLICKY_ID);
		end
	end
end

function event_trade(e)
	local item_lib = require("items");
	item_lib.return_items(e.self, e.other, e.trade);
end
