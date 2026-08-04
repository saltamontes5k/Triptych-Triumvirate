-- Krasnok Event

function event_spawn(e)
    eq.spawn2(228120,0,0,-1061,-47.1,-285.8,120); -- #door exit
    eq.spawn2(228119,0,0,-1363,-290.5,-73.5,120); -- #door enter
end

function event_say(e)
    if(e.message:findi("Hail")) then
        e.self:Say("Thieves! Thieves aboard the ship! Return what you have [" .. eq.say_link("what have I stolen?",false, "stolen") .. "] and I promise, your death will be swift.");
    elseif(e.message:findi("stolen")) then
        e.self:Say("Do not try my patience dryfoot, the Captain and his hands will soon return. If he finds his things missing there will be death, he has been in foul spirits since losing the Stone. Your death if you are found with them. You did [" .. eq.say_link("I did not steal!",false, "steal") .. "] them? Admit it!");
    elseif(e.message:findi("steal")) then
        e.self:Emote("gets a suspicious look in his eyes.");
        e.self:Say("Ok, I will be honest. I lost the Captain's trinkets. If you [" .. eq.say_link("I will help you.",false, "help") .. "] me find them before his return, I am sure I can track something down that will not be missed. I have access to the treasure room, and there is much there in the way of spoils.");
    elseif(e.message:findi("help")) then
        e.self:Message(MT.Red,"You sense that when you return you should be ready for a battle, despite Mi`Ta's assurances.");
        e.self:Say("Excellent! It is not much, I was below deck with his compass, spyglass, ocean map, and a bottle of his favorite spirits. I would be in your debt should you find them for me.");
    end
end

function event_trade(e)
    local item_lib = require("items");
    if(item_lib.check_turn_in(e.trade, {item1 = 56004, item2 = 56005, item3 = 56006, item4 = 56007})) then -- Ancient Compass, Mystical Spyglass, Map of Norrath's Oceans, Krasnok's Private Reserve

        -- Depop Doors In and Out
        eq.signal(228119,1,0); -- #door_enter
        eq.signal(228120,1,0); -- #door_exit

        -- Start Spells Casting
        eq.signal(228118,1,0); -- #spell_target
        eq.signal(228114,1,0); -- #bleeding_spell
        eq.signal(228115,1,0); -- #drowning_spell
        eq.signal(228116,1,0); -- #hate_spell
        eq.signal(228117,1,0); -- #languish_spell

        -- Spawn Event Mobs
        eq.spawn2(228121,0,0,-1281,-46,-285.58,120); -- #Captain_Krasnok
        eq.spawn2(228122,0,0,-1281,-120,-285.58,0); -- #Fist_of_Krasnok
        eq.spawn2(228122,0,0,-1281,118,-285.58,248); -- #Fist_of_Krasnok
        eq.spawn2(228122,0,0,-1090,-120,-285.58,0); -- #Fist_of_Krasnok
        eq.spawn2(228122,0,0,-1090,124,-285.58,248); -- #Fist_of_Krasnok

        eq.depop();
    end
    item_lib.return_items(e.self, e.other, e.trade)
end
