task_ids = require('task_ids')
function event_say(e)
  local rep = e.other:GetFaction(e.self)

  if rep > 2 then
    e.other:Message(MT.NPCQuestSay, "Kunimi Falade looks at you with fear visible in her eyes, and she quickly looks away.  Perhaps she will speak to you further if you were to gain the trust of the Nihil somehow...")
  else
    if e.message:findi('hail') then
      e.other:Message(MT.NPCQuestSay, "Kunimi Falade glances around to make sure no one is within earshot then whispers, 'Who are you and what do you want?'")
    end
    if e.message:findi('proteri') then
      e.other:Message(MT.NPCQuestSay, "Kunimi Falade looks nervous at the mention of that name and says, 'I'm sorry. I don't know anyone by that name.'")
    end

    if e.message:findi('ingredients') then
      e.other:Message(MT.NPCQuestSay, "Kunimi Falade says 'Creating poisons is distasteful business and I'm afraid the items that go into it are just as distasteful. I need the black bile of a hynid and the yellow bile of a tide feaster from the shores of Natimbi and both a vial of corrosive slime and a mass of insect larva from the sewers beneath us. Once I have these items, I should be able to create an effective poison. Now, you should leave before we're seen.'")
    end
  end
end

function event_trade(e)
  local rep = e.other:GetFaction(e.self)
  local item_lib = require("items")

  if rep > 2 then
    e.other:Message(MT.NPCQuestSay, "Kunimi Falade shrinks away from the items you offer.  Perhaps she would be more receptive if you were to gain the trust of the Nihil?")
    item_lib.return_items(e.self, e.other, e.trade)
  else
    if item_lib.check_turn_in(e.trade, {item1 = 64001}) then
      e.other:Message(MT.NPCQuestSay, "Kunimi Falade takes the ring and studies it for a moment. 'So the time has finally come. Unfortunately, I have had little success. Our traditional poisons have absolutely no effect on these invaders. They don't even seem to notice the poison. But, there is some hope. I believe I can distill a poison that will affect them if I had the right [" .. eq.say_link("ingredients") .. "].'")
    end
    if item_lib.check_turn_in(e.trade, {item1 = 64002, item2 = 64003, item3 = 64004, item4 = 64005}) then --Black Hynid Bile
      e.other:Message(MT.NPCQuestSay, "Kunimi Falade takes the ingredients and gets to work. Within a few minutes, she produces a viscous green liquid. Plucking a bunch of fruit from the nearby plant, she coats the fruit in the poison.")
      e.other:Message(MT.NPCQuestSay, "Kunimi Falade says 'That should do it. I can't be positive that this will do more than give Ixvet an upset stomach, but we can hope. Please take this to Proteri Amari.'")
      e.other:SummonItem(64006)
    end
  end
end
