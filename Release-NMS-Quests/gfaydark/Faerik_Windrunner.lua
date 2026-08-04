-- Gandak's Ill-Fated Trip

function event_say(e)
    if e.message:findi("Hail") then
        e.self:Say("Hello. I am afraid I do not have time for small talk I have a very important job to do here and unless you are [interested] in helping me please leave me alone.");
    elseif e.message:findi("interested") then
        e.self:Say("I didn't think I could get anyone to assist me with this, and you don't look like much but any help is good help. Allow me to introduce myself, I am Faerik Windrunner of the Emerald Warriors. I have been tasked with finding a party that is willing to [assist] us in investigating the disappearance of one of our own at sea.");
    elseif e.message:findi("assist") then
        e.self:Say("I am very happy to hear this ".. e.other:GetName() .. ". I shall tell you what I know about this delicate situation. Gandak Whisperwind is one of the finest Emerald Warriors this town has ever seen. His weapon mastery skills are unmatched by anyone. Recently, his wife fell ill and there was a need for an antidote component that is grown by a well respected [farmer] in the karanas. Only if we receive these herbs from our friend in the karanas will Gandaks wife live.");
    elseif e.message:findi("farmer") then
        e.self:Say("The farmer that I speak of is Tarnic McWillows, he runs a farm in the karanas that grows the herbs that we need for Lady Jernca`s medicine. So with that known we sent out 3 of our finest rangers and druids to obtain this herb and bring back the medicine but for the sake of if anything happened Gandak insisted to go along for the ill-fated [trip] because he loves his wife so very much");
    elseif e.message:findi("trip") then
        e.self:Say("Well it would seem that something went terribly wrong not long after they set out on their journey to the karanas. We know this for sure because sadly we found their boat that washed up on shore with all of the bodies of the original party on board, except for Gandak's. So with this knowledge it is that we hope and believe somehow Gandak is still alive and is either making his way to the Karanas or is just somewhere that we cannot find him yet. We have heard of a group of Pirates originating from a [fortress] in the sea that might be responsible.");
    elseif e.message:findi("fortress") then
        e.self:Say("There are many talks of a fierce and deadly troll pirate clan that calls themselves Broken Skull. They are claiming responsibility for many of these sea hijackings and I believe that if Gandak is alive he might be there. If you wish to travel to attempt to gain knowledge about his disappearance seek out the mystical boat that docks in the Stonebrunt Mountains. If you should find Gandak please give him this medallion that he will know has come from us.");
        e.other:SummonItem(21986); -- Item: Medallion of the Emerald warrior
    end
end

function event_trade(e)
    local item_lib = require("items");
    if item_lib.check_turn_in(e.trade, {item1 = 21988}) then -- Item: Antidote of the wind
        e.self:Say("Gandak is alive? That is excellent news, I will get this antidote to his wife right away.  The Emerald Warriors will not forget what you have done ".. e.other:GetName() .. ".  Here is a small token of our appreciation.");
        e.other:QuestReward(e.self,{exp = eq.ExpHelper(20)});
        e.other:SummonItem(61004);	-- Item: Charm of the Emerald Warrior
    end
    item_lib.return_items(e.self, e.other, e.trade)
end
