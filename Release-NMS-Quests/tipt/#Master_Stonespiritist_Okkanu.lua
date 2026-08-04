local mountain_task = 31
local vxed_task = 32
local tipt_task = 33

function event_say(e)
  if e.message:findi("hail") then
    e.other:Message(MT.NPCQuestSay, "Okkanu tells you, 'I'm sorry, I can do nothing for you my friend.  Your bravery is notable, but I'm sure you can understand that we just can't trust anyone with our ancient magic.  It would be far too dangerous for my people.'")
    e.other:UpdateTaskActivity(tipt_task, 1, 1)
    e.other:UpdateTaskActivity(mountain_task, 1, 1)
    if e.other:IsTaskCompleted(mountain_task) then
      e.other:SetAccountBucket("god.flags.kt", "1")
    end
  end
end
