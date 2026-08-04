-- sewer trials all share the same compass
-- items: 68298
local sewers = {
  snplant = { -- should be version 0 of zone, named can spawn in progression version
    expedition = { name="Sewers of Nihilia, The Purifying Plant", min_players=1, max_players=6 },
    instance   = { zone="snplant", version=0, duration=eq.seconds("6h") },
    zonein     = { x=150.00, y=127.00, z=-6.87, h=126.00 }
  },
  sncrematory = {
    expedition = { name="Sewers of Nihilia, The Crematory", min_players=1, max_players=6 },
    instance   = { zone="sncrematory", version=0, duration=eq.seconds("6h") },
    zonein     = { x=31.00, y=175.00, z=-17.87, h=254.00 }
  },
  snlair = {
    expedition = { name="Sewers of Nihilia, Lair of the Trapped Ones", min_players=1, max_players=6 },
    instance   = { zone="snlair", version=0, duration=eq.seconds("6h") },
    zonein     = { x=234.00, y=-70.00, z=-14.87, h=508.00 }
  },
  snpool = {
    expedition = { name="Sewers of Nihilia, The Pool of Sludge", min_players=1, max_players=6 },
    instance   = { zone="snpool", version=0, duration=eq.seconds("6h") },
    zonein     = { x=137.00, y=-5.00, z=-19.87, h=378.00 }
  }
}

for _, sewer in pairs(sewers) do
  sewer.compass    = { zone="barindu", x=-645.859, y=-338.502, z=-118.309 }
  sewer.safereturn = { zone="barindu", x=-605.0, y=-337.0, z=-123.84, h=0.0 }
end

local function create_sewer_expedition(client, sewer)
  local dz = client:CreateExpedition(sewer)
  if dz.valid then
    dz:AddReplayLockout(eq.seconds("5m"))
  end
end

task_ids = require('task_ids')

function event_say(e)
  if e.message:findi("hail") then
    -- No sewers task: Assign sewers
    if not e.other:IsTaskActive(task_ids.sewers_task) and not e.other:IsTaskCompleted(task_ids.sewers_task) then
      e.other:Message(MT.NPCQuestSay, "High Priest Diru tells you, 'These are sad times. Not only have the invaders taken away all that we own, but our own problems still occur. If only there was someone willing to help our cause. I beg of you, please, help us with all the problems going on in the sewers underneath this city. They have become the breeding grounds for stonemites. These nasty bugs get into everything. They eat our stored food and our crops. We need to terminate the source of the stonemites so that we will have enough food to survive. The invaders do not provide enough for us, and we need these crops to live. Please prepare and talk to me again when you are ready to help.'")
      e.other:AssignTask(task_ids.sewers_task)
    else
      -- Is plant done?
      if not e.other:IsTaskCompleted(task_ids.plant_task) then
        -- Does the player have the Plant task?
        if not e.other:IsTaskActive(task_ids.plant_task) then
          e.other:Message(MT.NPCQuestSay, "High Priest Diru tells you, 'Go find Ansharu. He has been researching their behavior patterns, and will be able to tell you what needs to be done. I hope that you will be able to help us out in these dire times. Please head to the sewer plant and find the source of the stonemite infestation. If you do this for us, I will share with you how to pass through the mountains and up to the temples created by the trusik, our exiled kin.'")
          create_sewer_expedition(e.other, sewers.snplant)
          e.other:AssignTask(task_ids.plant_task)
        else
          create_sewer_expedition(e.other, sewers.snplant)
        end
      -- Is crematory done?
      elseif e.other:IsTaskCompleted(task_ids.plant_task) and not e.other:IsTaskCompleted(task_ids.crem_task) then
        -- Update the plant task if it wasn't for some reason
        e.other:UpdateTaskActivity(task_ids.sewers_task, 0, 1)
        -- Does the player have the Crematory task?
        if not e.other:IsTaskActive(task_ids.crem_task) then
          e.other:Message(MT.NPCQuestSay, "High Priest Diru tells you, 'I know that you can do this for us. I have seen your action in this city and have heard of them on the rest of the continent. Please set the spirits of the fallen at ease. Seek out a way to into the crematory, find the remains of Ngozi, Mabiki, Talokoi, and Yogundi. Take the remains into the furnace and their spirits will present themselves. All will become clear when the time has come.'")
          create_sewer_expedition(e.other, sewers.sncrematory)
          e.other:AssignTask(task_ids.crem_task)
        else
          create_sewer_expedtion(e.other, sewers.sncrematory)
        end
      -- Is lair done?
      elseif e.other:IsTaskCompleted(task_ids.plant_task) and e.other:IsTaskCompleted(task_ids.crem_task) and not e.other:IsTaskCompleted(task_ids.lair_task) then
        -- Update the plant task if it wasn't for some reason
        e.other:UpdateTaskActivity(task_ids.sewers_task, 1, 1)
        --does the player have the lair task?
        if not e.other:IsTaskActive(task_ids.lair_task) then
          e.other:Message(MT.NPCQuestSay, "High Priest Diru tells you, 'Our sewer system was an integral part of the city before the great explosion. After the sewer system was deserted by most Taelosians, many of the processes that occurred below the city ceased to work. In the sewers, many insects, animals, and other slimy diseased creatures thrive. Take this seal. I know that Alej is very timid and may think you are there to harm him unless he sees something familiar from you. Please be careful while you're down there and be on the look out for cave-ins.'")
          e.other:SummonItem(68298)
          create_sewer_expedition(e.other, sewers.snlair)
          e.other:AssignTask(task_ids.lair_task)
        else
          e.other:SummonItem(68298)
          create_sewer_expedition(e.other, sewers.snlair)
        end
      -- Is pool done?
      elseif e.other:IsTaskCompleted(task_ids.plant_task) and e.other:IsTaskCompleted(task_ids.crem_task) and e.other:IsTaskCompleted(task_ids.lair_task) and not e.other:IsTaskCompleted(task_ids.pool_task) then
        -- Update the plant task if it wasn't for some reason
        e.other:UpdateTaskActivity(task_ids.sewers_task, 2, 1)
        --Does the player have the pool task?
        if not e.other:IsTaskActive(task_ids.pool_task) then
          e.other:Message(MT.NPCQuestSay, "High Priest Diru tells you, 'Utandi, the map maker, should be in the sewers. I must apologize for him in advance. He is wonderful with his maps, but very timid. Good luck and I hope that we can stand together, defiant against the invaders.'")
          create_sewer_expedition(e.other, sewers.snpool)
          e.other:AssignTask(task_ids.pool_task)
        else
          create_sewer_expedition(e.other, sewers.snpool)
        end
      -- Should be everything
      else
        -- Update the plant task if it wasn't for some reason
        e.other:UpdateTaskActivity(task_ids.sewers_task, 3, 1)
        e.other:Message(MT.NPCQuestSay, "High Priest Diru tells you, 'You have done excellent work helping our tribe. You and your kind are powerful and have done more for us than we expected, so I will reward you with the information you've been wanting. In order to pass through the mountains, you must work with those who have the most sacred knowledge of our lands -- the master stonespiritists. You will find an apprentice in Barindu, named Udranda. She will grant you access to the mountain pass and then tell you what you must do. Also, if you ever need to go back into the sewers for any reason, you can ask Gamesh to show you the way through. Good luck to you, and to us all.'")
        if e.other:IsTaskCompleted(task_ids.sewers_task) then
          local sewers_flag = tonumber(e.other:GetAccountBucket("god.sewers.flag")) or 0
          if sewers_flag == 0 then
            e.other:SetAccountBucket('god.flags.sewers', '1')
          end
        end
      end
    end
  end
end

function event_trade(e)
  local item_lib = require("items")
  item_lib.return_items(e.self, e.other, e.trade)
end
