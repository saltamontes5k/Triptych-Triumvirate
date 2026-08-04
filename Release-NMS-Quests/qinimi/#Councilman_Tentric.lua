function event_say(e)
  if e.message:findi('hail') then
    e.other:Message(MT.NPCQuestSay, "Councilman Tentric says 'You haven't come to demand something of me, have you? I've been subjected to enough atrocities already. Please leave this old man in peace.'")
  end
end

function event_trade(e)
  local item_lib = require("items")

  if item_lib.check_turn_in(e.trade, {item1 = 52176}) then --Token of Understanding
    e.other:Message(MT.NPCQuestSay, "Councilman Tentric nods solemnly, 'Hmm . . . I see. So Pandula is contemplating leaving this world. There is no doubt that these are hard times. Our people are strong however, and nothing will truly break our spirit. Please let Pandula know that the gods have not forgotten us. Bring her this holy symbol.'")
    e.other:SummonItem(52177)
  end

  item_lib.return_items(e.self, e.other, e.trade)
end
