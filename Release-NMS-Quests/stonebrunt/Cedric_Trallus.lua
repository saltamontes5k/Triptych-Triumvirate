-- Luggald Studies (Dark Caster Seplls)

function event_say(e)
    local qglobals = eq.get_qglobals(e.self,e.other);
    if(e.message:findi("Hail")) then
        e.self:Say("Hello ".. e.other:GetName() .. ", chancing a journey to Brokenskull are you? Many have ventured there, but few have returned. I was favored by the will of Thule to return here in one piece, although I would not call my [" .. eq.say_link("journey") .. "] exactly successful.");
    elseif(e.message:findi("journey")) then
        e.self:Say("Our spies in Erudin were able to learn that a voyage of Deepwater knights was setting sail in search of Brokenskull Island. Our priests in Paineel had received several visions from the lord Cazic telling of great powers that might be found on this island. Our group was instructed to follow their ship across the waters and explore the island should we find it. Find it they did, and more then they ever bargained for on that [" .. eq.say_link("cursed isle") .. "].");
    elseif(e.message:findi("cursed isle")) then
        e.self:Say("Just as the Deepwater knights were about to drop anchor near a small cove on the island, we attacked them. The magic cloaks we had placed over our ship did their job all too well. We took them by surprise and our forces easily overpowered them, but our battle was joined by a [" .. eq.say_link("third force") .. "].");
    elseif(e.message:findi("third force")) then
        e.self:Say("A group of strange creatures crawled up the side of the boats and began to attack everyone on both sides. They cut through many of us before we were able to retreat our forces back to our ship and turn our sails away from the island. Several of the creatures pursued us through the water with amazing speed. We fought them off and we forced them back into the sea. We were able to slay one of them, or so we thought. We brought the [" .. eq.say_link("body") .. "] back to Paineel for the priests to study.");
    elseif(e.message:findi("body")) then
        e.self:Say("When we docked here in Paineel we were carrying the body off of the ship when suddenly the creature came to life. It threw several of our knights into the water and then jumped in himself and swam off into the ocean. We suspect that it used some form of magic to fool us into believing it was actually dead. The necromancers of Paineel are not easily fooled in matters of life and death. We greatly desire to study the [" .. eq.say_link("organs") .. "] of these creatures to learn the secret of this new magic.");
    elseif(e.message:findi("organs")) then
        e.self:Say("Bring me two samples of these creatures internal organs for our priests to study and we may share the secret of their magic with you. Something tells me you won't come back alive, though.");
    elseif(e.message:findi("robes") and qglobals["luggald"] == "1") then
        e.self:Emote("glances at the burns in his robes inquisitively.");
        e.self:Say("It seems an aspect of the luggald's system is acidic in nature. Perhaps we have yet to find the secret of their comatose state. I'll need more samples to continue my research. This time bring me purified samples of their bile, blood, and saliva and I will study them.");
    end
end

function event_trade(e)
    local qglobals = eq.get_qglobals(e.self,e.other);
    local item_lib = require("items");
    if(item_lib.check_turn_in(e.trade, {item1 = 59035, item2 = 59035})) then -- Luggald Organs x2
        if(e.other:HasClass(Class.SHADOWKNIGHT) or e.other:HasClass(Class.NECROMANCER)) then -- Shadow Knight or Necro
            eq.set_global("luggald","1",0,"F"); -- Set Global for 2nd step
            e.self:Emote("takes the organs from you and lays them down on the ground before him. He begins to slice and separate the organs from one another with a wicked looking dagger. Dark blue blood stains his robe as he probes the strange flesh. Finally after several minutes he smiles and pulls a parchment from a bag at his side and begins to draw several runes using the dark blue blood.");
            e.self:Say("Take this, I have discovered the secret of their magic, or so I believe. Of course it might not work and you'll end up actually dead, but we'll never know till you try, will we?");
            if(e.other:HasClass(Class.NECROMANCER)) then -- Necro
                e.other:QuestReward(e.self,0,0,0,0,59019,10000); -- Spell: Auspice
            elseif(e.other:HasClass(Class.SHADOWKNIGHT)) then -- Shadow Knight
                e.other:QuestReward(e.self,0,0,0,0,59006,10000); -- Spell: Blood of Pain
            end
            e.other:Message(MT.Yellow, "As you take the scroll from him you notice a sickly burning odor in the air. You glance down at Cedric's robes and notice several holes beginning to form where the blood touches his [" .. eq.say_link("robes") .. "].");
        else -- Not a Shadow Knight or Necro
            e.self:Say("You do not posess the correct class afinity to progress with my research, take these back.") -- Made up rather than random spell provided, since spells are no drop.
            e.other:SummonItem(59035); -- Luggald Organs
            e.other:SummonItem(59035); -- Luggald Organs
        end
    elseif(qglobals["luggald"] == "1" and item_lib.check_turn_in(e.trade, {item1 = 59050, item2 = 59036, item3 = 59051})) then -- Luggald bile, Luggald Blood, Luggald saliva
        e.self:Emote("takes the vials and holds them out in front of him. He begins to recite an incantation and the vials rise and float in the air in front of him. He continues to chant as each of the vials begins to glow and then grow dim in turn. Cedric picks up a large potion bottle and places a rolled piece of parchment inside. He then holds it before him causing it to float in the air as well. Each of the first three vials floats over the potion bottle and a distinct amount of each liquid is poured in, causing it to bubble and shake. Cedric reaches out before him and takes the bottle from the air and hands it to you.");
        e.self:Say("Fear is a weapon to be used against your enemies, ".. e.other:GetName() .. ", but we can not afford to let it cloud our judgment as well. Drink the potion and new power will energize your being.");
        e.other:QuestReward(e.self,0,0,0,0,59037,10000); -- Glowing dark blue potion
        eq.delete_global("luggald"); -- Delete Global
    end
    item_lib.return_items(e.self, e.other, e.trade)
end
