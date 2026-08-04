task_ids = require('task_ids')
function event_say(e)
  local rep = e.other:GetFaction(e.self)

  if rep > 2 then
    e.other:Message(MT.NPCQuestSay, "Turlini shakes his head at you as you try to talk with him.  Perhaps he would speak with you if you were to gain the trust of his people somehow?")
  else
    if e.message:findi('hail') then
      e.other:Message(MT.NPCQuestSay, "Turlini beams with excitement, 'I recognize you! One of the adventurers we've heard tales about! There are rumors of you destroying the Legion of Mata Muram. Have you come to set us free?'")
    end
    if e.message:findi('free') then
      e.other:Message(MT.NPCQuestSay, "Turlini says 'Bless you, we're saved! Listen up, friend. I've already formulated a plan to stage a quick and decisive escape, but first we need to get our hands on a complete set of shackle keys. Just a few won't suffice; it must be entire set. If we were to rescue only some of my brethren, those that remain behind would be brutally tortured beyond imagination. Now, I've watched the guards carefully and counted the silvery keys they carry. There are ten in total. Combine the set in this sack and return it to me. I knew you would help!'")
      e.other:SummonItem(52150)
      e.other:UpdateTaskActivity(task_ids.bic_riwwi, 7, 1)
    end
  end
end

function event_trade(e)
  local rep = e.other:GetFaction(e.self)
  local item_lib = require("items")

  if rep > 2 then
    e.other:Message(MT.NPCQuestSay, "Turlini refuses to take the items you are offering.  Perhaps he would speak with you if you were to gain the trust of his people somehow?")
  else
    if item_lib.check_turn_in(e.trade, {item1 = 52161}) then
      e.other:Message(MT.NPCQuestSay, "Turlini fishes a jagged key from the sack and tries it on his manacles. They unlock with a loud snap and slide off his wrists. His expression melts into simultaneous shock and elation. 'YES! We will be freed. Very soon now, these chains will bind my people no longer! And as for you, " .. e.other:GetCleanName() .. ", you will become a legend among my people.'")
      e.other:Message(MT.Yellow, "You have received a character flag!")
      e.other:Faction(1770, 50)
      e.other:Faction(1771, -25)
      e.other:Message(MT.NPCQuestSay, "Turlini can barely contain his excitement. 'This is wonderful news, friend. Freedom is within our grasp! The only problem remaining is the ever-present guards. They are always watching over us. We would need a monumental distraction to buy enough time for me to release everyone. Which is where you come in. One of your kind who goes by the name of Reyna has been taken to the arena and has been tortured daily in front of the Muramite masses. If you were to create enough of a ruckus in the arena trying to free her I think we could make our escape.'")
    end
    if item_lib.check_turn_in(e.trade, {item1 = 52233}) then --Blood-Soaked Satchel 1
      e.other:Message(MT.NPCQuestSay, "Turlini gives you an appraising nod, 'Your valiant demonstration in the arena has given us all hope that someone can stand against the Muramites. Please accept this trinket as a token of appreciation from our people.'")
      e.other:SummonItem(52085) --Yunjo's Braided Cord
    end
    if item_lib.check_turn_in(e.trade, {item1 = 52234}) then --Bload-Soaked Satchel 2
      e.other:Message(MT.NPCQuestSay, "Turlini gives you an appraising nod, 'Your valiant demonstration in the arena has given us all hope that someone can stand against the Muramites. Please accept this trinket as a token of appreciation from our people.'")
      e.other:SummonItem(52086) -- Yunjo's Woven Cord
    end
    if item_lib.check_turn_in(e.trade, {item1 = 52235}) then --Bload-Soaked Satchel 3
      e.other:Message(MT.NPCQuestSay, "Turlini gives you an appraising nod, 'Your valiant demonstration in the arena has given us all hope that someone can stand against the Muramites. Please accept this trinket as a token of appreciation from our people.'")
      e.other:SummonItem(52087) -- Yunjo's Woven Twine Cord
    end
    if item_lib.check_turn_in(e.trade, {item1 = 52236}) then --Bload-Soaked Satchel 4
      e.other:Message(MT.NPCQuestSay, "Turlini gives you an appraising nod, 'Your valiant demonstration in the arena has given us all hope that someone can stand against the Muramites. Please accept this trinket as a token of appreciation from our people.'")
      e.other:SummonItem(52088) -- Yunjo's Plaited Hynid-Fur Cord
    end
    if item_lib.check_turn_in(e.trade, {item1 = 52237}) then --Bload-Soaked Satchel 5
      e.other:Message(MT.NPCQuestSay, "Turlini gives you an appraising nod, 'Your valiant demonstration in the arena has given us all hope that someone can stand against the Muramites. Please accept this trinket as a token of appreciation from our people.'")
      e.other:SummonItem(52089) -- Yunjo's Hynid Fang Cord
    end
    if item_lib.check_turn_in(e.trade, {item1 = 52238}) then --Bload-Soaked Satchel 6
      e.other:Message(MT.NPCQuestSay, "Turlini gives you an appraising nod, 'Your valiant demonstration in the arena has given us all hope that someone can stand against the Muramites. Please accept this trinket as a token of appreciation from our people.'")
      e.other:SummonItem(52090) -- Pressed Leather Yunjo Sash
    end
    if item_lib.check_turn_in(e.trade, {item1 = 52239}) then --Bload-Soaked Satchel 7
      e.other:Message(MT.NPCQuestSay, "Turlini gives you an appraising nod, 'Your valiant demonstration in the arena has given us all hope that someone can stand against the Muramites. Please accept this trinket as a token of appreciation from our people.'")
      e.other:SummonItem(52091) -- Spiked Leather Yunjo Sash
    end
    if item_lib.check_turn_in(e.trade, {item1 = 52240}) then --Bload-Soaked Satchel 8
      e.other:Message(MT.NPCQuestSay, "Turlini gives you an appraising nod, 'Your valiant demonstration in the arena has given us all hope that someone can stand against the Muramites. Please accept this trinket as a token of appreciation from our people.'")
      e.other:SummonItem(52092) -- Woven Bone Yunjo Sash
    end
    if item_lib.check_turn_in(e.trade, {item1 = 52241}) then --Bload-Soaked Satchel 9
      e.other:Message(MT.NPCQuestSay, "Turlini gives you an appraising nod, 'Your valiant demonstration in the arena has given us all hope that someone can stand against the Muramites. Please accept this trinket as a token of appreciation from our people.'")
      e.other:SummonItem(52093) -- Silvery Mesh Yunjo Sash
    end
    if item_lib.check_turn_in(e.trade, {item1 = 52242}) then --Bload-Soaked Satchel 10
      e.other:Message(MT.NPCQuestSay, "Turlini shouts with joy. 'Aha, you've done it! Thanks to your distractions in the coliseum, the Muramite legion is engulfed in utter chaos. We will take this opportunity to escape. You have saved us all. Oh, I almost forgot! Before I go, take this as a final gift from the Yunjo. It holds much strength, just as you do. Unfortunately I have bad news. Something I could not tell you until now. Reyna passed on a few days ago. Her last request was that I give this to someone who had proven his or her worth. You have more than done that. I wish there were more I could do, but we are masters of shaping stone not life.'")
      e.other:SummonItem(52094) -- Sash of the Yunjo's Champion
      e.other:SummonItem(67417) -- Reyna's Scout Report
      e.other:Message(MT.Yellow, "You have received a character flag!")
      e.other:Message(MT.NPCQuestSay, "Turlini says 'I can't wait to be reunited with my family! Let's get out of this place.'")
      e.other:Message(MT.NPCQuestSay, "Turlini kicks the shackles from their legs. 'Quick, to the exits!'")
      eq.depop(282098)
      eq.depop_with_timer(282049)
      eq.depop_with_timer(282056)
      eq.depop_with_timer(282048)
      eq.depop_with_timer()
      eq.get_zone():SetVariable("arena_started", "0")
      e.other:UpdateTaskActivity(task_ids.bic_riwwi, 11, 1)
    end
  end
  item_lib.return_items(e.self, e.other, e.trade)
end
