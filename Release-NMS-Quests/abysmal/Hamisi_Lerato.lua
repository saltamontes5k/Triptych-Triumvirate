task_ids = require('task_ids')
function event_say(e)
  if e.message:findi('hail') then
    e.other:Message(MT.NPCQuestSay, "Hamisi Lerato looks despondent. 'I recently managed to escape from the city with my mother, but my sister is still stuck in there. She was too frightened to escape with us and now I fear she may be dead.'")
  end
  if e.message:findi('chiaka is alive') and (e.other:IsTaskActivityActive(task_ids.bic_barindu, 11) or e.other:IsTaskActivityActive(task_ids.bic_barindu, 12)) then
    e.other:Message(MT.NPCQuestSay, "A look of astonishment flashes across Hamisi's face. 'You've seen my sister? Is she ok? Where is she? Wait, there will be time to talk later. For now, you must return to her immediately. Our mother has been worrying herself to death and has grown very sick. I fear she won't last much longer. Please, take this shawl to my sister. It's our mother's. My sister will recognize it and know what it means. May the ocean speed your journey!'")
    e.other:SummonItem(64008)
  end
end
