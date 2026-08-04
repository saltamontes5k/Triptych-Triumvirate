local mountain_task = 31
local vxed_task = 32
local tipt_task = 33

-- same for vxed and tipt
local compass     = { zone="barindu", x=-1249.24, y=575.142, z=-148.257 }
local safereturn  = { zone="barindu", x=-1242.00, y=456.00, z=-121.76, h=0.0 }
local vxed_zonein = { x=-427.0, y=-3552.0, z=14.99, h=463.0 }
local tipt_zonein = { x=-448.0, y=-2374.0, z=13.16, h=395.0 }

local vxed = {
  expedition = { name="Vxed, The Crumbling Caverns", min_players=1, max_players=6 },
  instance   = { zone="vxed", version=0, duration=eq.seconds("6h") },
  compass    = compass,
  safereturn = safereturn,
  zonein     = vxed_zonein
}

local tipt = {
  expedition = { name="Tipt, Treacherous Crags", min_players=1, max_players=6 },
  instance   = { zone="tipt", version=0, duration=eq.seconds("6h") },
  compass    = compass,
  safereturn = safereturn,
  zonein     = tipt_zonein
}

local paladin_epic = {
  expedition = { name="Vxed, The Crumbling Caverns", min_players=1, max_players=24 },
  instance   = { zone="vxed", version=1, duration=eq.seconds("6h") },
  compass    = compass,
  safereturn = safereturn,
  zonein     = vxed_zonein
}

local function create_expedition(client, expedition_info)
  local dz = client:CreateExpedition(expedition_info)
  if dz.valid then
    dz:AddReplayLockout(eq.seconds("5m"))
  end
end

function event_say(e)
  local is_gm = (e.other:Admin() > 80 and e.other:GetGM())
  local sewers_flag = tonumber(e.other:GetAccountBucket("god.flags.sewers")) or 0
  local ferubi_flag = tonumber(e.other:GetAccountBucket("god.flags.ferubi")) or 0

  -- Smith Rondo skip flag was not tested on live, will just bypass sewers progression dialogue here
  if e.message:findi("hail") then
    if e.other:HasClass(Class.PALADIN) and e.other:HasItem(69933) then -- Item: Seal of Enic
      e.other:Message(MT.NPCQuestSay, string.format("I heard you released Reiya from his tourture, %s. I have seen muramites gathering in Vxed and I fear this may have to do with Reiya and the creatures responsible. Go there now and investigate, Noble Knight.", e.other:GetCleanName()))
      create_expedition(e.other, paladin_epic)
    elseif sewers_flag == 1 and not e.other:IsTaskCompleted(vxed_task) then -- sewers progression dialogue
      -- note: live dialogue is always here if finished sewers, checking tipt access flag here avoids this live "bug"
      e.other:Message(MT.NPCQuestSay, "Udranda looks around sheepishly.  'Greetings.  A messenger told me you would come.  I believe we owe you our thanks -- though I'm not sure allowing you to face the terror in the mountains is a reward.  I will have my stone worker allow you to pass through, but you must [" .. eq.say_link("take heed") .. "] first and be as quiet as you can.'")
    else
      e.other:Message(MT.NPCQuestSay, "Udranda tells you, 'Greetings.  I have a duty here to stand guard at the mountain pass and allow the Muramites to pass through by moving the rocks with my magic.'  Udranda looks around for anyone listening and whispers to you. 'If you want to go into [" .. eq.say_link("Tipt") .. "] or [" .. eq.say_link("Vxed") .. "] I will have my stone worker open the passage for you.  If you want to progress past the mountains, I would ask that you first prove your worth with High Priest Diru.'")
    end
  elseif e.message:findi("take heed") and not e.other:IsTaskCompleted(vxed_task) then -- no longer responds to this after receiving permanent vxed completed flag
    if sewers_flag == 1 then
      e.other:Message(MT.NPCQuestSay, "Udranda tells you, 'Good.  There are many secrets I can't tell you right now for fear the Muramites might hear them, but you must do as I say and trust in me.  In the mountain pass, Vxed, you must seek out Stonespiritist Ekikoa.  He is my mentor and will help you in your quest to find passage to the peaks.  We have created a very unique magic that we will share with you, but you must speak with him.  It will all be clear to you when you find him.  Please hurry, I cannot leave a way open for too long.'")
      if not e.other:IsTaskActive(vxed_task) then
        e.other:AssignTask(vxed_task)
      end
      if not e.other:IsTaskActive(mountain_task) then
        e.other:AssignTask(mountain_task)
      end
      create_expedition(e.other, vxed) -- no emote when creating here
    else -- same message as hailing without progression
      e.other:Message(MT.NPCQuestSay, "Udranda tells you, 'Greetings.  I have a duty here to stand guard at the mountain pass and allow the Muramites to pass through by moving the rocks with my magic.'  Udranda looks around for anyone listening and whispers to you. 'If you want to go into [" .. eq.say_link("Tipt") .. "] or [" .. eq.say_link("Vxed") .. "] I will have my stone worker open the passage for you.  If you want to progress past the mountains, I would ask that you first prove your worth with High Priest Diru.'")
    end
  elseif e.message:findi("ready to pass") and sewers_flag == 0 and ferubi_flag == 0 then
    -- only responds without permanent vxed flag, possibly old dialogue to request tipt that was removed
    e.other:Message(MT.NPCQuestSay, "Udranda tells you, 'I cannot allow you to pass with your companions.  You seem heroic enough, but you must prove your worth to High Priest Diru and our stonespiritist in the Vxed mountain pass before I can allow you through.'")
  elseif e.message:findi("tipt") and (is_gm or e.other:IsTaskCompleted(vxed_task)) then
    eq.get_entity_list():MessageClose(e.self, true, 100, MT.SayEcho, e.self:GetCleanName() .. " subtly commands her stone worker to open the passage for you before any invaders can take notice.")
    create_expedition(e.other, tipt)
    if not e.other:IsTaskActive(tipt_task) and not e.other:IsTaskCompleted(tipt_task) then
      e.other:AssignTask(tipt_task)
    end
    if not e.other:IsTaskActive(mountain_task) and not e.other:IsTaskCompleted(mountain_task) then
      e.other:AssignTask(mountain_task)
    end
  elseif e.message:findi("vxed") and (is_gm or sewers_flag == 1 or ferubi_flag == 1) then
    eq.get_entity_list():MessageClose(e.self, true, 100, MT.SayEcho, e.self:GetCleanName() .. " subtly commands her stone worker to open the passage for you before any invaders can take notice.")
    create_expedition(e.other, vxed)
    if not e.other:IsTaskActive(vxed_task) and not e.other:IsTaskCompleted(vxed_task) then
      e.other:AssignTask(vxed_task)
    end
    if not e.other:IsTaskActive(mountain_task) and not e.other:IsTaskCompleted(mountain_task) then
      e.other:AssignTask(mountain_task)
    end
  end
end

function event_trade(e)
  local item_lib = require("items")
  item_lib.return_items(e.self, e.other, e.trade)
end
