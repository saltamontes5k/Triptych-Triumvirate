task_ids = require('task_ids')

function event_say(e)
  if e.other:IsTaskActivityActive(task_ids.bic_abysmal, 11) or e.other:IsTaskActivityActive(task_ids.bic_abysmal, 12) or e.other:IsTaskActivityActive(task_ids.bic_abysmal, 13) or e.other:IsTaskActivityActive(task_ids.bic_abysmal, 14) or e.other:IsTaskActivityActive(task_ids.bic_abysmal, 15) then
    if e.message:findi('hail') then
      e.other:Message(MT.NPCQuestSay, "Beanalle Banoam says 'Hello, " .. e.other:GetCleanName() .. ". It is truly an honor to meet you. I have heard some great things about you and hope that what I have [" .. eq.say_link('discovered') .. "] will interest you.'")
    end
    if e.message:findi('discovered') then
      e.other:Message(MT.NPCQuestSay, "Beanalle Banoam says 'After going through some of the reports submitted by the scout leaders, I was able to figure something out about the temples that lie beyond Yxtta and Kod'Taz. Apparently, the temple called Qvic is where the Muramite army first broke through. The temple was ravaged by the force of the explosion when the portal to the Muramites' realm closed. Of course, as you know, they are not the only thing that came through the portal. The strange magic stones we discovered were also a result of that explosion and up until now we thought we had found the most powerful ones. After going through the reports, I found out that concentrated pieces of the magic-imbued [" .. eq.say_link('matter') .. "] lie in the Qvic temple area and beyond.'")
    end
    if e.message:findi('matter') then
      e.other:Message(MT.NPCQuestSay, "Beanalle Banoam says 'These pieces of matter possess vast power like none we have ever seen, but there is a drawback. You see these special augmentations? I have come to call them shards of power because of the odd shapes they take. They must have their power removed and condensed before they can be applied to an item. I have figured out a way to do this, but another [" .. eq.say_link('drawback') .. "] has prevented me from testing my theory further.'")
    end
    if e.message:findi('drawback') then
      e.other:Message(MT.NPCQuestSay, "Beanalle Banoam says 'Well, these special shards can only be combined with an item they are attuned to. In other words, the materials that make up an item determine if these shards are compatible with it. Now, I have found many formulas that will allow for a particular shard to merge with a particular item. Recently I discovered one [" .. eq.say_link('item') .. "] that was perfectly in tune with them all.'")
    end
    if e.message:findi('item') then
      e.other:Message(MT.NPCQuestSay, "Beanalle Banoam says 'Why, your stone of course. The different items you have added to it have altered its makeup so much that it is hardly what it was when you first received it. It is a powerful item that can be made even more powerful with my help and yours, but this will require the help of many and I am afraid we do not have the force to take on such a task. Do you think you would be willing to collect the four shards of power from the temples and bring them to me as you get them?'")
    end
    if e.message:findi('yes') then
      e.other:Message(MT.NPCQuestSay, "Beanalle Banoam says 'Excellent! I knew Fezbin was right about you. Okay, here is what I can tell you. Qvic, Inktu'ta, Txevu, and Tacvi are the names of the temples beyond Yxtta and Kod'Taz. Within each of these you should find a shard of power. The hard part will be finding one as the Muramites are aware of the power within them and are hoarding every piece they find. If my theory is correct, you will have to combine the shards in a particular order before the stone will become attuned with another. You should retrieve the shards from the temples in the order I said before -- Qvic, Inktu'ta, Txevu, and Tacvi. Give each shard to me one at a time so that I can remove and condense the magic for you and then you can combine them in the special sealer. Now, hurry! I am worried that the leader of the Muramites may realize he needs to get rid of these shards, before we can get our hands on them.'")
    end
  else
    e.other:Message(MT.NPCQuestSay, "Beanalle Banoam seems to ignore you.")
  end
end

function event_trade(e)
  local item_lib = require("items")
  if e.other:IsTaskActivityActive(task_ids.bic_abysmal, 11) or e.other:IsTaskActivityActive(task_ids.bic_abysmal, 12) or e.other:IsTaskActivityActive(task_ids.bic_abysmal, 13) or e.other:IsTaskActivityActive(task_ids.bic_abysmal, 14) or e.other:IsTaskActivityActive(task_ids.bic_abysmal, 15) then
    if item_lib.check_turn_in(e.trade, {item1 = 67564}) then
      e.other:Message(MT.NPCQuestSay, "Beanalle Banoam says 'Ah, perfect. I am glad you were successful in finding it. Now, if you will give me one second I will condense the shard into concentrated energy which you can add to your stone. There we are. Please take the time to attach this, but make sure you do it in the order I mentioned when we first spoke.'")
      e.other:SummonItem(67572)
      e.other:UpdateTaskActivity(task_ids.bic_abysmal, 12, 1)
    end
    if item_lib.check_turn_in(e.trade, {item1 = 67565}) then
      e.other:Message(MT.NPCQuestSay, "Beanalle Banoam says 'Ah, perfect. I am glad you were successful in finding it. Now, if you will give me one second I will condense the shard into concentrated energy which you can add to your stone. There we are. Please take the time to attach this, but make sure you do it in the order I mentioned when we first spoke.'")
      e.other:SummonItem(67573)
      e.other:UpdateTaskActivity(task_ids.bic_abysmal, 13, 1)
    end
    if item_lib.check_turn_in(e.trade, {item1 = 67566}) then
      e.other:Message(MT.NPCQuestSay, "Beanalle Banoam says 'Ah, perfect. I am glad you were successful in finding it. Now, if you will give me one second I will condense the shard into concentrated energy which you can add to your stone. There we are. Please take the time to attach this, but make sure you do it in the order I mentioned when we first spoke.'")
      e.other:SummonItem(67575)
      e.other:UpdateTaskActivity(task_ids.bic_abysmal, 14, 1)
    end
    if item_lib.check_turn_in(e.trade, {item1 = 67567}) then
      e.other:Message(MT.NPCQuestSay, "Beanalle Banoam says 'Ah, perfect. I am glad you were successful in finding it. Now, if you will give me one second I will condense the shard into concentrated energy which you can add to your stone. There we are. Please take the time to attach this, but make sure you do it in the order I mentioned when we first spoke.'")
      e.other:SummonItem(67574)
      e.other:UpdateTaskActivity(task_ids.bic_abysmal, 15, 1)
    end
  end
  item_lib.return_items(e.self, e.other, e.trade)
end
