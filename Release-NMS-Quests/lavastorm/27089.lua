-- Celrak Blightblood (27089) - Dark Reign camp
-- Completes the 'Deliver 1 Stillmoon Drake Egg to Celrak Blightblood' activity
-- of the Dark Reign Tier 2 group mission 'Drake Eggs' (task 5555, deliver = activity 2).

local item_lib = require("items")

function event_say(e)
  if e.message:findi("hail") then
    eq.get_entity_list():MessageClose(e.self, true, 100, MT.SayEcho, "Celrak Blightblood says, 'What do you want? If you have business with the Dark Reign, speak quickly. I have little patience for idle chatter.'")
  end
end

function event_trade(e)
  if item_lib.check_turn_in(e.trade, { item1 = 49022 }) then -- Stillmoon Drake Egg
    if e.other:IsTaskActive(5555) then
      e.other:UpdateTaskActivity(5555, 2, 1)
      e.other:Message(MT.NPCQuestSay, "Celrak Blightblood says, 'A drake egg... you actually managed it. Fine. Your work for the Dark Reign is noted. Now begone.'")
    else
      e.other:Message(MT.NPCQuestSay, "Celrak Blightblood says, 'I have no use for this. Take it back.'")
      e.self:Say(("I have no need for this, %s. You can have it back."):format(e.other:GetCleanName()))
      e.other:SummonItem(49022)
    end
  end
  item_lib.return_items(e.self, e.other, e.trade)
end
