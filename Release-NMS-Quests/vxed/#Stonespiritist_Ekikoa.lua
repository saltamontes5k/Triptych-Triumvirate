local mountain_task = 31
local vxed_task = 32
local tipt_task = 33

function event_spawn(e)
  eq.zone_emote(MT.Yellow, "A series of low chants comes to you from the Northeast, as Stonespiritist Ekikoa emerges from the shadows.")
  local client_list = eq.get_entity_list():GetClientList()
  for client in client_list.entries do
    if client.valid then
      client:UpdateTaskActivity(vxed_task, 1, 1)
    end
  end
end

function event_say(e)
  if e.message:findi("hail") then
    e.other:UpdateTaskActivity(vxed_task, 2, 1)
    e.other:UpdateTaskActivity(mountain_task, 0, 1)
    e.other:Message(MT.NPCQuestSay, "Ekikoa tells you, 'Ah, help has come.  I was told to expect friendly creatures from a distant land and here you are.  You are as alien as the others, but I know you have done good deeds for Udranda to send you here.  Now, I will tell you what you came for.  Obviously, the way to the temples is blocked. However, I [" .. eq.say_link("tend") .. "] to something very special here to overcome that problem.'")
  end
  if e.message:findi('tend') then
    e.other:Message(MT.NPCQuestSay, "Ekikoa tells you, 'This stone behind me is a shard of an Attunement Obelisk.  With a unique and ancient magic, we can attune spirits to this farstone to allow travel.  When you touch it, the stone will be imprinted with your essence, because this is only a section of an obelisk, more must be done in order to have full use of these obelisks.  Now, when you touch this stone, you will be sent back to Udranda.  She will tell you what you must do next when you are ready.'")
    e.other:Message(MT.Yellow, "You feel at one with the Attunement Obelisk and feel the power of the earth moving through you.")
    e.other:UpdateTaskActivity(vxed_task, 2, 1)
    e.other:UpdateTaskActivity(mountain_task, 0, 1)
    if e.other:IsTaskCompleted(mountain_task) then
      e.other:SetAccountBucket("god.flags.kt", "1")
    end
  end
end
