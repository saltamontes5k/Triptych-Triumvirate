task_ids = require('task_ids')
-- items: 55617, 55618, 55619, 55620
local event_started = false

function event_spawn(e)
  e.self:SetSpecialAbility(SpecialAbility.immune_melee, 1)
  e.self:SetSpecialAbility(SpecialAbility.immune_magic, 1)
  e.self:SetSpecialAbility(SpecialAbility.immune_aggro, 1)
  e.self:SetSpecialAbility(SpecialAbility.immune_aggro_on, 1)
  e.self:SetSpecialAbility(SpecialAbility.no_harm_from_client, 1)
end

function event_say(e)
  local on_progression = e.other:IsTaskActive(task_ids.pool_task)

  if on_progression and (e.message:findi("hail") or e.message:find("hello")) then
    e.other:Message(MT.NPCQuestSay, "Utandi tells you, 'Wh, who are you?'  Utandi's voice quivers with fear.  'I have nothing of value if you are planning to rob me.  What's that?  You will not harm me?  You seek treasures elsewhere?  You think like I do.  I myself am in search of treasures.  There is only one [" .. eq.say_link("problem") .. "] though.'")
  elseif on_progression and e.message:findi("problem") then
    e.other:Message(MT.NPCQuestSay, "Utandi tells you, 'Well I was attacked by some of the creatures here in the sewer and I lost my map.  If you could [" .. eq.say_link("find it") .. "], I have some valuable knowledge I could pass along to you.'")
  elseif on_progression and e.message:findi("find it") then
    e.other:Message(MT.NPCQuestSay, "Utandi tells you, 'You will help?  That is good news indeed!  Search here in the sewers for my map.  It was made of stone and unfortunately it was shattered into four pieces when I got attacked. If you find the four pieces, hand them to me.'")
    if not event_started then
      eq.spawn2(285085, 0, 0, 1354, 475, -135.90, 169):ChangeSize(9) -- NPC: #Slime_Cube
      event_started = true
    end
  elseif e.message:findi("hail") or e.message:findi("hello") or e.message:findi("problem") or e.message:findi("find it") then
    e.other:Message(MT.NPCQuestSay, "Utandi tells you, 'Who are you?  What do you need with me?  Please leave me be, I cannot endure anymore punishment!'")
  end
end

function event_trade(e)
  local item_lib = require("items")

  -- Items: First Fragment of Utandi`s Map, Second Fragment of Utandi`s Map, Third Fragment of Utandi`s Map, Fourth Fragment of Utandi`s Map
  if item_lib.check_turn_in(e.trade, {item1 = 55617, item2 = 55618, item3 = 55619, item4 = 55620}) then
    check_turnin(e)
  end
  item_lib.return_items(e.self, e.other, e.trade)
end

function check_turnin(e)
  local item_lib = require("items")
  if e.other:IsTaskCompleted(task_ids.pool_task) then
    local client_list = eq.get_entity_list():GetClientList()
    for client in client_list.entries do
      if client.valid then
        client:UpdateTaskActivity(task_ids.sewers_task, 3, 1)
        if client:IsTaskCompleted(task_ids.sewers_task) then
          client:SetAccountBucket("god.flags.sewers", "1")
        end
      end
    end
    eq.get_entity_list():MessageClose(e.self, true, 100, MT.SayEcho, "Utandi says, 'You are most kind.  I think I can salvage these pieces and assemble my map again.  As a reward to you, I will now explain how to gain access to the temples through our once sacred mountain passes.  First seek the High Priest and tell him of your duty here.  He will recommend you to the only one that can help.'  Utandi proceeds to explain to you and your party how to access the mountain zones.'")
  end
end

