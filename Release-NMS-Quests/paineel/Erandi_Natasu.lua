function event_say(e)
    if e.message:findi("Hail") then
        e.self:Emote("looks nervously about before leaning in close to your ear. 'Do you need [" .. eq.say_link("work") .. "]?");
    elseif e.message:findi("work") then
        e.self:Say("My name is Erandi Natasu. I am here representing a group of interested parties among the merchant coalitions across Norrath. You do not need to know who is involved with this. We are looking to hire a few people to take [care] of some things for us.");
    elseif e.message:findi("care") then
        e.self:Say("Our businesses are hurting, people cannot keep up their stock or afford to stay in business with the upsurge in [piracy] upon our waters. Trade lines are cut between the continents; supplies are not arriving at their proper destinations. It is quite dreadful.");
    elseif e.message:findi("piracy") then
        e.self:Say("As the pirates that reside in Broken Skull Rock become stronger and more bold, the attacks on our ships have increased dramatically. Would you be interested in [helping] the very merchants that supply your food and clothing by performing some mercenary services?");
    elseif e.message:findi("helping") then
        e.self:Say("Wonderful! There are a few ships in particular that have been causing us much grief, their names are Stormwave, Lady Dirulia, Dandolak's Run, Oceancrasher, and Windscorn. Between these five ships terror has been spread to the end of the seas. Each crew seems to have some kind of common badge amongst themselves, if you can slay two members of every crew I believe the merchants would be satisfied. Bring us these seals and we will be most pleased.");
        if not e.other:HasItem(17181) then
            e.other:SummonItem(17181); -- Item: Merchant's Crate
        end
    end
end

function event_trade(e)
    local item_lib = require("items");
    if item_lib.check_turn_in(e.trade, {item1 = 54016}) then -- Item: Sealed Crate
        e.self:Say("How marvelous! The Coalition will be delighted by this win. We have all worked together to obtain this as a prize for whomever would be successful in this mission, please accept it and our gratitude.");
        e.other:SummonItem(54017);	-- Item: Symbol of Loyalty to the People
        e.other:QuestReward(e.self,{exp = 10000});
    end
    item_lib.return_items(e.self, e.other, e.trade)
end
