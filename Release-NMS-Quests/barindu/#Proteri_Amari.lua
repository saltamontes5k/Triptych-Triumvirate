task_ids = require('task_ids')

function event_say(e)
  local rep = e.other:GetFaction(e.self)

  if rep > 2 then
    e.other:Message(MT.NPCQuestSay, "Proteri Amari looks at you with fear visible in his eyes, and he shakes his head.  Perhaps he will speak to you further if you were to gain the trust of the Nihil somehow...")
  else
    if e.message:findi('hail') then
      e.other:Message(MT.NPCQuestSay, "Proteri Amari glances around nervously. 'Leave me be. I can't be seen talking to outsiders.'")
    end
    if e.message:findi('talwin') then
      e.other:Message(MT.NPCQuestSay, "Proteri Amari says 'Yes ... Talwin. He and I were becoming fast friends until Ixvet took him. I am not sure what has happend to him, but if you would be [" .. eq.say_link("interested") .. "] in helping me I may be able to assist you in return.'")
    end
    if e.message:findi('interested') then
      e.other:Message(MT.NPCQuestSay, "Proteri Amari says 'Good, good. As you may have noticed, the majority of these creatures are brutish types best suited for destruction. They are kept under control solely by strong [" .. eq.say_link("leadership") .. "].'")
    end
    if e.message:findi('leadership') then
      e.other:Message(MT.NPCQuestSay, "Proteri Amari says 'The one who controls this area of the city goes by the name Ixvet Pox. She's as cruel as the rest, but considerably more intelligent which makes her even more dangerous. Fortunately, she's grown complacent and that gives us an [" .. eq.say_link("opportunity") .. "]. If we can destroy Ixvet, it will throw this area into chaos and we should be able to escape before order is restored.'")
    end
    if e.message:findi('opportunity') then
      e.other:Message(MT.NPCQuestSay, "Proteri Amari says 'I've managed to get someone loyal to our cause placed within Ixvet Pox's entourage of personal servants and a skilled herbalist tends to her favorite fruits in the gardens. We will use this connection to poison the tyrant. Go talk with Kunimi Falade. You can find her working on the Hanging Gardens. Give her this ring as proof that you are there with my blessing and she will tell you what she needs.'")
      e.other:SummonItem(64001)
    end
  end
end

function event_trade(e)
  local rep = e.other:GetFaction(e.self)
  local item_lib = require("items")

  if rep > 2 then
    e.other:Message(MT.NPCQuestSay, "Proteri Amari shrinks away from the items you offer.  Perhaps he would be more receptive if you were to gain the trust of the Nihil?")
    item_lib.return_items(e.self, e.other, e.trade)
  else
    if item_lib.check_turn_in(e.trade, {item1 = 64006}) then
      e.other:Message(MT.NPCQuestSay, "Proteri Amari says 'I knew Kunimi would come through! Our day of escape is almost here. Take this to Abena Taifa. She is the servant who brings Ixvet his meals and is loyal to our cause.'")
      e.other:SummonItem(64007)
    end
  end
  item_lib.return_items(e.self, e.other, e.trade)
end
