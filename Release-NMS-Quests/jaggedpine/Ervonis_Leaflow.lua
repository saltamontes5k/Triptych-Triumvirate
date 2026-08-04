--Quest Germand's Problem

function event_say(e)
    if(e.message:findi("lost")) then
        e.self:Say("I was washing its fine blade down by the river when those darned potameids attacked me. I ran but left my axe behind out of pure fear. If you could [" .. eq.say_link("find") .. "] it, I would be grateful and won't even charge you for some wood.");
    elseif(e.message:findi("find")) then
        e.self:Say("Great. I would start by checking near the river. Be careful though, those potameids are dangerous!");
    end
end

function event_trade(e)
    local item_lib = require("items");
    if(item_lib.check_turn_in(e.trade, {item1 = 55558})) then -- Note to Ervonis
        e.self:Say("Germand needs some more lumber? Well I would be happy to chop some for you, but unfortunately I [" .. eq.say_link("lost") .. "] my axe. It was my favorite axe so I will not be chopping any more wood until I get it back.");
        e.other:QuestReward(e.self,0,0,0,0,0,eq.ExpHelper(15)); -- 2-4% of lvl 15 exp
    elseif(item_lib.check_turn_in(e.trade, {item1 = 55522})) then -- Ervonis's Axe
        e.self:Say("I cannot tell you how thankful I am. Just a moment and I will get you some wood.' Ervonis chops some wood for you and ties it into a neat bundle. 'It is a bit heavy, but I think you can handle it. Thanks again!");
		e.other:QuestReward(e.self,0,0,0,0,55536,eq.ExpHelper(15)); -- 2-4% of lvl 15 exp and Bundle of Wood
    end
    item_lib.return_items(e.self, e.other, e.trade)
end