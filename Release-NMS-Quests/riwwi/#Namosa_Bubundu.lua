task_ids = require('task_ids')
function event_say(e)
  local rep = e.other:GetFaction(e.self)

  if rep > 2 then
    e.other:Message(MT.NPCQuestSay, "Namosa Bubundu glances at you, then pointedly looks away.  Perhaps she would speak with you if you were to gain the trust of her people somehow?")
  else
    if e.message:findi('hail') then
      e.other:Message(MT.NPCQuestSay, "Namosa Bubundu coughs pitifully and looks through you with weak eyes, 'This gazebo was once a place of contemplation, meditation, and reflection, but now it is a place of torture. These slavers shackle us here within feet of the pool of water and refuse us food or drink for days at a time, accompanied by horrible beatings. And now, I have had enough. I am through with this world and can only hope for peace in my passing. Before I pass on I wonder if you could do a [" .. eq.say_link("favor") .. "] for me?'")
    end
    if e.message:findi('favor') then
      e.other:Message(MT.NPCQuestSay, "Namosa Bubundu slips you a scuffed signet ring, 'Yes, yes. Here is a family heirloom that I have been keeping secret from our captors. If you deliver this ring to my kin, I can die in peace knowing it never fell into their hands. There are rumors that some of my family members have escaped the clutches of these monsters and made their way into a city that floats on water. I hope you understand, friend. Go quickly.'")
      e.other:SummonItem(52179)
      e.other:UpdateTaskActivity(task_ids.bic_riwwi, 1, 1)
    end
  end
end

function event_trade(e)
  local rep = e.other:GetFaction(e.self)
  local item_lib = require("items")

  if rep > 2 then
    e.other:Message(MT.NPCQuestSay, "Namosa Bubundu shies away from the items you are trying to hand her.  Perhaps she would be more receptive if you were to gain the trust of her people somehow?")
  else
    if item_lib.check_turn_in(e.trade, {item1 = 52178}) then
      e.other:Message(MT.NPCQuestSay, "Namosa Bubundu gasps, 'What?! Oh no, this isn't good at all. She isn't supposed to die. I am! Quick, go and see Councilman Tentric in Qinimi and let him know what's happening. He has always helped our family when we were in need. If you bring this token he will know I sent you!'")
      e.other:SummonItem(52176)
      e.other:Faction(1770, 1)
      e.other:Faction(1771, -1)
    end
    if item_lib.check_turn_in(e.trade, {item1 = 52175}) then
      e.other:Message(MT.NPCQuestSay, "Namosa Bubundu says 'A drakelily? My aunt grew these in her garden. In fact, I helped her plant some of them myself. She always told me they were a sign of hope. Thank you, " .. e.other:GetCleanName() .. ". I'll inform our people of your kindness.'")
      e.other:SummonItem(52174)
      e.other:Faction(1770, 50)
      e.other:Faction(1771, -25)
      e.other:Message(MT.Yellow, "Namosa touches your shoulder and gazes at you with pleading eyes. 'I hope this isn't presumptuous of me. You've already done so much. Before you go, I need to ask you for another favor. Turlini is under heavy guard in one of the nearby towers. The Muramites think he's up to something and I'm concerned they may torture or kill him. Please have a talk with Turlini when you can.'")
    end
  end
  item_lib.return_items(e.self, e.other, e.trade)
end
