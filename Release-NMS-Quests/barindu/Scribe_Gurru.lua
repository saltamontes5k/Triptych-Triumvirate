task_ids = require('task_ids')
-- Scribe_Gurru NPCID:283052

function event_say(e)
  if e.message:findi("hail") then
    eq.get_entity_list():MessageClose(e.self, true, 100, MT.SayEcho, "Scribe Gurru says, 'Please do not bother the High Priest with petty issues, he has enough on his mind.  If you have other [" .. eq.say_link("issues") .. "] to discuss let me know.'")
  elseif e.message:findi("issues") then
    if e.other:IsTaskCompleted(task_ids.plant_task) and e.other:IsTaskActivityActive(task_ids.sewers_task, 0) then
      e.other:UpdateTaskActivity(task_ids.sewers_task, 0, 1)
    end
    if e.other:IsTaskCompleted(task_ids.crem_task) and e.other:IsTaskActivityActive(task_ids.sewers_task, 1) then
      e.other:UpdateTaskActivity(task_ids.sewers_task, 1, 1)
    end
    if e.other:IsTaskCompleted(task_ids.lair_task) and e.other:IsTaskActivityActive(task_ids.sewers_task, 2) then
      e.other:UpdateTaskActivity(task_ids.sewers_task, 2, 1)
    end
    if e.other:IsTaskCompleted(task_ids.pool_task) and e.other:IsTaskActivityActive(task_ids.sewers_task, 3) then
      e.other:UpdateTaskActivity(task_ids.sewers_task, 3, 1)
    end
    if e.other:IsTaskCompleted(task_ids.sewers_task) then
      local sewers_flag = tonumber(e.other:GetAccountBucket("god.flags.sewers")) or 0
      if sewers_flag == 0 then
        e.other:SetAccountBucket("god.flags.sewers", "1")
      end
    else
      e.other:Message(MT.NPCQuestSay, "Gurru tells you, 'I see that you have completed some deeds for our people and we appreciate it.  Before I can tell the High Priest of your work though, you will need to talk to him and finish some other tasks.'")
    end
  end
end

function event_trade(e)
  local item_lib = require("items")
  item_lib.return_items(e.self, e.other, e.trade)
end
