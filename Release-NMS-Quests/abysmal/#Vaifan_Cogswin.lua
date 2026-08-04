task_ids = require('task_ids')

function event_say(e)
  if e.other:IsTaskCompleted(task_ids.bic_abysmal) or (e.other:IsTaskCompleted(task_ids.bic_sewers) and e.other:IsTaskCompleted(task_ids.bic_vxed) and e.other:IsTaskCompleted(task_ids.bic_tipt) and e.other:IsTaskCompleted(task_ids.bic_outer)) then
    e.other:Message(MT.NPCQuestSay, "Thank you for all of your assistance, " .. e.other:GetCleanName() .. "!  I have reported your assistance to Fezbin, you should speak with him if you need more work.")
  elseif not e.other:IsTaskActive(task_ids.bic_abysmal) then
    e.other:Message(MT.NPCQuestSay, "Please do not disturb a genius at work. I have a very serious problem and little time to spend gabbing to just anyone.")
  else
    if e.message:findi('hail') then
      e.other:Message(MT.NPCQuestSay, "Vaifan Cogswin says 'Well, hello traveler. You here to help with the scout problem we've been having?'")
    end
    if e.message:findi('yes') then
      e.other:Message(MT.NPCQuestSay, "Vaifan Cogswin says 'Good to hear. I have been going out of my skull trying to tinker another one to find the first. Now that you are here, I can stop that and focus on compiling the information I already have. Let me tell you, being in charge of something like this is very taxing on the nerves. I remember being a young gnome and whenever I tinkered something it worked the first time. Ah, how good it felt to put the Cogswin family emblem on my wonderful creations. Nowadays it seems like everything I make has some intermittent flaw or defect. I might have to accept that I am getting old and a little slow, but I still have the wits to invent. I should stop rambling and get to the point. I am in charge of scouting the mountain areas known as [" .. eq.say_link("Tipt") .. "], [" .. eq.say_link("Vxed") .. "], and the [" .. eq.say_link("sewers") .. "] under the city. Which would you like to know about?'")
    end
    if e.message:findi('sewers') then
      e.other:Message(MT.NPCQuestSay, "Vaifan Cogswin says 'According to my records here, the sewers are a pretty vile area. Filled with some strange creatures, I hear. So, being the genius that I am, I came up with a plan to use a prototype clockwork scout I built when we were having problems exploring the catacombs in Mistmoore. He appeared to be working fine. I received constant detailed reports on the sewers and mountain areas until one day it stopped. For some time I tried to make contact with the clockwork, but nothing. I started working on a second one to retrieve the first when Falcin stumbled onto the boat. In his struggle to get back to us he had to make his escape through the sewers. While going through there, he found this. This is the reporting module used by the clockwork scout. It does not look like much now, but you should have seen it when Falcin gave it to me. I have repaired most of the damage in an attempt to access the information stored within, but there are four vital components missing. I need you to go to the four sewer areas and find a timing gear, a rusty spring, an oiled cog, and a processing gizmo. When you have them all, place them inside the gearbox and combine them. Once this has been done, the gearbox should give you a report. Return the report to me.'")
      e.other:SummonItem(67528)
      e.other:AssignTask(task_ids.bic_sewers)
    end
    if e.message:findi('vxed') then
      e.other:Message(MT.NPCQuestSay, "Vaifan Cogswin says 'We have discovered that this continent holds many dangerous creatures, including the strange beings of the invading army. Many of these beasts can be found in the mountain area called Vxed. After being severely damaged in Tipt, the clockwork scout made its way back to Vxed to perform self maintenance, but I believe this is where it met its final demise. While the chance is slim, I believe you may be able to salvage enough of the parts from the creatures within Vxed to reassemble the frame. What you will need to find is a flickering finkenheimer, a tarnished sprocket, some uncoiled springs, a greased bolt, and some connection rods. When you have them all place, the sprocket, springs, bolt, and rods in the finkenheimer and bring me the result. I must warn you to be careful though. If these things could stop my clockwork, they must be pretty powerful creatures.'")
      e.other:AssignTask(task_ids.bic_vxed)
    end
    if e.message:findi('tipt') then
      e.other:Message(MT.NPCQuestSay, "Vaifan Cogswin says 'The mountainous areas of this continent hold many dangers within them. Tipt in particular is thick with members of the invading army, dangerous creatures, and the angry spirits of nihil refugees. Looking at the information I have, the clockwork scout tried to take a direct path to the other side of Tipt and had some serious problems. Apparently, it had a run in with some cragbeasts, a pack of ghosts, numerous Muramites, and a native riddlemaster. While he made it pretty far, he took significant damage each step of the way. My last report received for this area stated that it was returning to the Vxed area to recover, but had lost multiple power cells in the process. I need you to retrieve these power cells. They are vital to rebuilding the scout and getting that report. There are five different types of cells, each one is called Vaifan's Power Cell -- named after the most ingenious gnome there is, of course. The cells are named from A to E. When you have collected all of them, place them in this power pack, activate it, and return it to me.'")
      e.other:SummonItem(67547)
      e.other:AssignTask(task_ids.bic_tipt)
    end
  end
end

function event_trade(e)
  local sewer_stone = tonumber(e.other:GetBucket("god.bic.sewer_stone")) or 0
  local vxed_stone = tonumber(e.other:GetBucket("god.bic.vxed_stone")) or 0
  local tipt_stone = tonumber(e.other:GetBucket("god.bic.tipt_stone")) or 0
  local item_lib = require("items")

  --Mountains
  if item_lib.check_turn_in(e.trade, {item1 = 67536}) then --Outer Regions Scouting Report
    e.other:Message(MT.NPCQuestSay, "Vaifan Cogswin says 'Excellent. It is always wonderful when something you invent works out. This was all I needed to finish up my report to Fezbin. Thank you once again. You have been very helpful. Once again I must reward you with this. When you brought the clockwork frame to me this fell out of it. I think it will go with your stone quite well. Try combining the two together and see what happens. I must say goodbye now.'")
    e.other:UpdateTaskActivity(task_ids.bic_outer, 3, 1)
    e.other:UpdateTaskActivity(task_ids.bic_abysmal, 7, 1)
      if sewer_stone == 0 then
        e.other:SummonItem(67535)
      elseif vxed_stone == 0 then
        e.other:SummonItem(67568)
      elseif tipt_stone == 0 then
        e.other:SummonItem(67553)
      else
        e.other:Message(MT.Yellow, "You feel as if the gods have made a mistake somewhere...[Contact GMs for assistance]")
      end
  --Tipt
  elseif item_lib.check_turn_in(e.trade, {item1 = 67537}) then --Fully Charged Power Pack
    e.other:Message(MT.NPCQuestSay, "Vaifan Cogswin says 'Wonderful. While the power cells were slightly damaged I was still able to increase the strength of the power pack for a short amount of time. This should give the scout just enough power to produce a legible copy the report. Thank you for the assistance, take this I scraped it off the side of the power cells. Looks like it might be able to add some power to the stone you recieived from Fezbin. There are still some areas left to explore, so when you are ready ask me about the next area you want to look into.'")
    e.other:SummonItem(67576)
    e.other:UpdateTaskActivity(task_ids.bic_abysmal, 6, 1)
    if e.other:IsTaskCompleted(task_ids.bic_sewers) and e.other:IsTaskCompleted(task_ids.bic_vxed) and e.other:IsTaskCompleted(task_ids.bic_tipt) then
      e.other:Message(MT.NPCQuestSay, "Vaifan Cogswin says 'Now that we have all the functioning pieces, we can reassemble the scout. Take these instructions and this power pack adapter and return to either mountain area to assemble the scout. I would have you do it here, but I fear he may be unstable and . . . well, let's just say I don't want to put the ship in danger. Please return to me with the report once you have it. I am going to prepare my final report so when you return I can take it straight to Fezbin. Good luck to you.'")
      e.other:SummonItem(67538)
      e.other:SummonItem(67577)
      e.other:AssignTask(task_ids.bic_outer)
    else
      e.other:SummonItem(67553)
      e.other:SetBucket("god.bic.tipt_stone", "1")
    end
  --Vxed
  elseif item_lib.check_turn_in(e.trade, {item1 = 67554}) then --Clockwork Scout Shell
    e.other:Message(MT.NPCQuestSay, "Vaifan Cogswin says 'I can't believe you did it. Not a bad job if I do say so myself. You may have a future in tinkering my young friend. Now, if you will give me one second to change a few things and rip this part out, adjust this here, add a couple of these, and there you go, a nice new clockwork frame. Now we just need to collect the rest of the pieces to rebuild him. Oh, and before I forget, here is a reward for helping me out. Let me know if you wish to explore any of the other areas by asking me about them.'")
    e.other:UpdateTaskActivity(task_ids.bic_abysmal, 5, 1)
    e.other:SummonItem(67539)
    if e.other:IsTaskCompleted(task_ids.bic_sewers) and e.other:IsTaskCompleted(task_ids.bic_vxed) and e.other:IsTaskCompleted(task_ids.bic_tipt) then
      e.other:Message(MT.NPCQuestSay, "Vaifan Cogswin says 'Now that we have all the functioning pieces, we can reassemble the scout. Take these instructions and this power pack adapter and return to either mountain area to assemble the scout. I would have you do it here, but I fear he may be unstable and . . . well, let's just say I don't want to put the ship in danger. Please return to me with the report once you have it. I am going to prepare my final report so when you return I can take it straight to Fezbin. Good luck to you.'")
      e.other:SummonItem(67538)
      e.other:SummonItem(67577)
      e.other:AssignTask(task_ids.bic_outer)
    else
      e.other:SummonItem(67568)
      e.other:SetBucket("god.bic.vxed_stone", "1")
    end
  --Sewers
  elseif item_lib.check_turn_in(e.trade, {item1 = 67534}) then --Mangled Report
    e.other:Message(MT.NPCQuestSay, "Vaifan Cogswin says 'Grrr, I was afraid of this. Seems without the extra modules working together this one won't function completely. Nonetheless at least it is fixed now and with your assistance we should be able to reassemble the scout and place this module back inside. Take this. I found it in the gearbox when I first received it. Seems like it may have some affinity with the stone Fezbin gave to you. Let me know when you are ready to help out some more.'")
    e.other:UpdateTaskActivity(task_ids.bic_abysmal, 4, 1)
    if e.other:IsTaskCompleted(task_ids.bic_sewers) and e.other:IsTaskCompleted(task_ids.bic_vxed) and e.other:IsTaskCompleted(task_ids.bic_tipt) then
      e.other:Message(MT.NPCQuestSay, "Vaifan Cogswin says 'Now that we have all the functioning pieces, we can reassemble the scout. Take these instructions and this power pack adapter and return to either mountain area to assemble the scout. I would have you do it here, but I fear he may be unstable and . . . well, let's just say I don't want to put the ship in danger. Please return to me with the report once you have it. I am going to prepare my final report so when you return I can take it straight to Fezbin. Good luck to you.'")
      e.other:SummonItem(67538)
      e.other:SummonItem(67577)
      e.other:AssignTask(task_ids.bic_outer)
    else
      e.other:SummonItem(67535)
      e.other:SetBucket("god.bic.sewer_stone", "1")
    end
  end
  item_lib.return_items(e.self, e.other, e.trade)
end
