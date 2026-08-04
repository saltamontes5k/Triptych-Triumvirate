function event_say(e)
  if e.message:findi('hail') then
    e.other:Message(MT.NPCQuestSay, "Pandula Bubundu says 'What can I do for you? I'm waiting to hear word from the Wayfarer scouts. My niece has been captured by the Muramites and I only wish to discover if she is still alive. I can't take this, not knowing. I would much rather endure a thousand of those beast's whips than be kept in the dark. Please find her for me.'")
  end
end

function event_trade(e)
  item_lib = require("items")

  if item_lib.check_turn_in(e.trade, {item1 = 52179}) then --Scuffed Signet Ring
    e.other:Message(MT.NPCQuestSay, "Pandula Bubundu sobs uncontrollably, tears welling up in her eyes, 'So my little one is still out there. This is wonderful news. I can now die in peace. The Wayfarers have transcribed my final wishes onto this parchment. Please deliver this to Namosa.'")
    e.other:SummonItem(52178)
  elseif item_lib.check_turn_in(e.trade, {item1 = 52177}) then --Symbol of Faith
    e.other:Message(MT.NPCQuestSay, "Pandula Bubundu looks quizzically at the symbol and rubs it in her hands. She smiles as if realizing something, 'Ah, Tentric, you are always right. I can't give up on this world or my family. I'm not sure why I was behaving so selfishly. Take this flower to my niece, she will know what it means.'")
    e.other:SummonItem(52175)
  end

  item_lib.return_items(e.self, e.other, e.trade)
end
