-- Gandak's Ill-Fated Trip

function event_say(e)
    e.self:Say("Please... I don't have time to talk here. Why don't you just let me die in peace?");

end

function event_trade(e)
    local qglobals = eq.get_qglobals(e.self, e.other);
    local item_lib = require("items");

    if item_lib.check_turn_in(e.trade, {item1 = 21986}) then -- Item: Medallion of the Emerald warrior
        e.self:Say("What is this? You are sent by the Emerald Warriors? I don't believe what I am hearing, I thought I would die out here. You must help me ".. e.other:GetName() .. ", my wife is very sick and she needs an antidote from a farmer in the Karanas that I was traveling to see. I may not be able to be saved, but I want my wife to live. If you will kill these ruthless creatures that are responsible for me being here I will allow you to take the medicine bag to Tarnic. Return to me with an insignia of hatred, slaying, suffering and the blackblood.");
        eq.set_global("Gandak", "1", 0, "F");
    elseif qglobals["Gandak"] ~= nil and qglobals["Gandak"] == "1" and item_lib.check_turn_in(e.trade, {item1 = 21989, item2 = 21990, item3 = 21991, item4 = 21992}) then -- Global from Pre-Quest -- Items: Insignia of Hatred, Insignia of Slaying, Insignia of the Blackblood, Insignia of Suffering
        e.self:Say("Excellent work, ".. e.other:GetName() .. "! Now that I have these I need one final favor from you. I need you to continue on to the farmer in the Karanas to obtain the remedy for my wife. Take him this bag and he will fill it with what you need.");
        e.other:SummonItem(21987); -- Elven Medicine Bag
        eq.delete_global("Gandak");
    end
    item_lib.return_items(e.self, e.other, e.trade)
end