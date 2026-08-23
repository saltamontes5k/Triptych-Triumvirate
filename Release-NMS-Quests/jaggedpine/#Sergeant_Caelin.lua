---- Quest: Gnoll Canines & Qeynos Badge of Nobility (Badge #5)
function event_say(e)
    local fac = e.other:GetFaction(e.self);
    if e.message:findi("hail") then
        e.self:Say("Hail, " .. e.other:GetName() .. ". You have nothing to fear from the gnolls. My men and I have been sent from Qeynos to help defend Fort Jaggedpine should those worthless curs make the mistake of assuming this will be a place of easy plunder. I've fought and slain scores of gnolls in my time. Were I not bound to my post here I would go forth and drive them from their dark cave to the north myself. However, I can offer you a [bounty], should you choose to take such a mission upon yourself.");
    elseif e.message:findi("bounty") then
        e.self:Say("If you choose to go and fight against the gnolls, I shall offer a bounty for every gnoll canine that you return to me. You look a bit more adventurous then many of those that live in this settlement. They seem a bit [docile].");
    elseif(e.message:findi("docile")) then
        e.self:Say("Perhaps it comes from living in harmony with nature for an extended period of time but they are more concerned with trading food recipes and doing arts and crafts. I have offered to give them some basic training in the arts of war but they seem to have no interest. This is a dangerous world in which we live and failure to acknowledge that has meant the downfall of many a society. I won't let this happen on my watch, provided my [men] are on their toes.");
    elseif(e.message:findi("men")) then
        e.self:Say("Guard Bossamir is a model soldier and a good man. I'm happy to have him watching my back. That Finewine character however, he is not worth the cost of the sword he wields! All he does is whine and complain. He was born with a silver spoon in his mouth and his family enrolled him in the guard to teach him some discipline but I've had no luck with him. He hasn't even turned in a [shift report] for weeks. Captain Tillin will bust me down to private if I don't deliver those soon.");
    elseif e.message:findi("shift report") then	-- Qeynos Badge Dialogue
        if fac <= 4 then
            e.self:Say("You have been helpful in our defense efforts. However, I can not be too careful about whom I trust with carrying this information. If you truly consider yourself an ally to Qeynos then no doubt you have assisted the city in its defense before. Show me your Qeynos Badge of Honor and I'll know I can trust you fully. I'll place my mark upon it should anyone question your authority to do this service for me.");
        else
            e.self:Say("I am sorry, " .. e.other:GetName() .. ". You have not yet proved yourself worthy to our cause.");
        end
    end
end

function event_trade(e)
    local item_lib = require("items");
	local fac = e.other:GetFaction(e.self);
	local qglobals = eq.get_qglobals(e.self,e.other);

    while item_lib.check_turn_in(e.trade, {item1 = 13068}) do
		e.self:Say("Good work, that is one less gnoll we need to worry about!");
        e.other:QuestReward(e.self,{exp = 250});
        e.other:Faction(1597,1);    -- Faction: Residents of Jaggedpine
        e.other:Faction(272,2);     -- Faction: Jaggedpine Treefolk
        e.other:Faction(302,2);     -- Faction: Protectors of Pine
        e.other:Faction(262,5);     -- Faction: Guards of Qeynos
	end

    if fac <= 4 and item_lib.check_turn_in(e.trade, {item1 = 2388}) then -- Item: Qeynos Badge of Honor
        e.self:Emote("takes your badge and places his mark upon it.");
        e.self:Say("I see that I can fully trust you. Here is your badge back.");
        e.self:Say("Take this note to Guard Finewine. He is officially on notice...");
        e.other:QuestReward(e.self,{exp = 1000});
        e.other:SummonItem(8285);                   -- Item: Marked Qeynos Badge of Honor
        e.other:SummonItem(8283);                   -- Item: Official Warning
		eq.set_global("qeynos_badge5","1",5,"F");   -- QGlobal: Badge Globals
	elseif fac <= 4 and tonumber(qglobals.qeynos_badge5) == 2 and item_lib.check_turn_in(e.trade, {item1 = 8279}) then -- Item: Stack of Shift Reports
        e.self:Say("Oh praise Karana, how did you manage to get these out of him? Never mind, I don't really care. Here, take this Compiled Report to Captain Tillin in Qeynos at once.");
        e.other:QuestReward(e.self,{exp = 1000});
        e.other:SummonItem(8280);                       -- Item: Compiled Report
		eq.set_global("qeynos_badge5","3",5,"F");       -- Badge Globals
	elseif(fac <= 4 and tonumber(qglobals.qeynos_badge5) == 3 and item_lib.check_turn_in(e.trade, {item1 = 8287})) then -- Orders for Sergeant Caelin
        e.self:Emote("'s face grows pale as he reads the orders. 'Bossamir was right. The gnolls are far stronger than we expected. We lack the resources for a frontal assault so we have no choice to but to resort to covert operations and strike the gnolls at their heart. Their leader must fall and you look like the one for the job. Take this Writ of Execution and carry out the sentence. Your target is the leader of the gnolls, Barducks Darkpaw. Affix the Writ of Execution to the Head of Barducks Darkpaw and seal it in this Black Satchel. Return to me with the Closed Black Satchel and your Marked Qeynos Badge of Honor for your just reward.'");
        e.other:QuestReward(e.self,{exp = 1000});
		e.other:SummonItem(8282);					-- Item: Writ of Execution
		e.other:SummonItem(17160);                  -- Item: Black Satchel
		eq.set_global("qeynos_badge5","4",5,"F");   -- QGlobal: Badge Globals
	elseif fac <= 4 and tonumber(qglobals.qeynos_badge5) == 4 and item_lib.check_turn_in(e.trade, {item1 = 8285, item2 = 8286}) then -- Items: Marked Qeynos Badge of Honor and Closed Black Satchel
        e.self:Say("A job well done! Perhaps now that will throw the gnolls into disarray and show them that we are not to be trifled with! The people of Qeynos and it's surrounding territories are in a great debt to you. You have proved time and again your willingness to take great risks to protect those who can't protect themselves. I am hereby empowered to grant to you an honorary rank of nobility. Take this and wear it proudly.");
        e.other:QuestReward(e.self,{exp = 10000});
		e.other:SummonItem(8968);					-- Item: Qeynos Badge of Nobility
		eq.set_global("qeynos_badge5","5",5,"F");   -- QGlobal: Badge Globals
    end
    item_lib.return_items(e.self, e.other, e.trade)
end