task_ids = require('task_ids')

function event_say(e)
  if e.other:IsTaskCompleted(task_ids.bic_abysmal) or (e.other:IsTaskCompleted(task_ids.bic_yxtta) and e.other:IsTaskCompleted(task_ids.bic_kodtaz)) then
    e.other:Message(MT.NPCQuestSay, "L`diava Rexxen says 'Welcome back, " .. e.other:GetCleanName() .. ".  I have informed Fezbin of your assistance with scouting the temples of Taelosia.  Thank you once again for your assistance, friend.'")
  elseif not e.other:IsTaskActive(task_ids.bic_abysmal) then
    e.other:Message(MT.NPCQuestSay, "L`diava Rexxen says 'Time is short and my patience is thin. Please do not disturb those you do not have dealings with, it can be very bad for your health.'")
  else
    if e.message:findi('hail') then
      e.other:Message(MT.NPCQuestSay, "L`diava Rexxen says 'Yes, yes. What is it I can do for you? I am a very busy woman and do not have a moment to waste on just anyone. Are you one of the adventurers sent here by Fezbin?'")
    end
    if e.message:findi('yes') then
      e.other:Message(MT.NPCQuestSay, "L`diava Rexxen says 'Very good. You are just in time. I am in need of immediate assistance in the temple areas known as [" .. eq.say_link("Yxtta") .. "] and the [" .. eq.say_link("frightful temple") .. "], Kod'Taz. While our scouts have been missing for quite some time, I recently received some information that leads me to believe they may still be alive. Which one we help first is up to you. Which area do you wish to investigate?'")
    end
    if e.message:findi('yxtta') then
      e.other:Message(MT.NPCQuestSay, "L`diava Rexxen says 'Yxtta is one of three smaller temple areas where a group of natives known as the trusik used to worship a god called Trushar. We do not know who this god is, but we believe he is a false god centered around a belief in natural destruction. Xounii Resnen was the scout assigned to this area. She was given this task because of her expertise in shapeshifting. I told her to take the shape of a trusik native and interact with them to find out more information. She managed to fit in quite well. Perhaps too well. Gradually, reports came less frequently until they eventually stopped. While everyone feared she had suffered the same fate as the other scouts, I think she started to believe she was really a trusik and has abandoned her assignment. What I need you to do is go there and find her. Now, be careful, the trusik are not a friendly race of beings and they are even more irritated by the invasion of the Muramite army. When you find Xounii I fear she may attack you. If this happens, I will not fault you for defending yourself, but if it comes to this I want some form of proof as to what happened.'")
      e.other:AssignTask(task_ids.bic_yxtta)
    end
    if e.message:findi('frightful temple') then
      e.other:Message(MT.NPCQuestSay, "L`diava Rexxen says 'Kod'Taz is made up of multiple temples that were once used for worship by the trusik natives. Many of them have since been destroyed or made into strongholds for the Muramite army. Due to the sheer size of this area, we sent a scouting force there to investigate. All of them are still alive, save one, named Kitren Lanom. None of the scouts left in the area know what happened to her or her belongings. Last time they remember seeing her was when she entered the Temple of Tri-Fates in an attempt to pass the temple trial. Please go to Kod'Taz and speak to Kevren Nalavat. He should be able to help you access the three trials. You will have to enter each trial and bring me back anything you find of Kitren's from each temple. Even though the scouts there have searched many times for something, I think a fresh set of eyes may help some. Kevren is the only one who knows you are helping me. Please do not let the others know you were sent by me. I have not yet ruled out the possibility of foul play and if they are aware of your affiliation, it may place you in more danger.'")
      e.other:AssignTask(task_ids.bic_kodtaz)
    end
  end
end

function event_trade(e)
  local item_lib = require("items")

  if item_lib.check_turn_in(e.trade, {item1 = 67562}) then --Sealed Confession
    e.other:Message(MT.NPCQuestSay, "L`diava Rexxen says 'Once again, a job well done. I hear you accomplished the tasks with flying colors. Now let's see what this says. Hm . . . this changes everything. I never suspected something like this, but now that I know, it all makes sense to me. Oh poor Kitren, why didn't you warn me first? Please leave me be. I must take sometime to think. Take this as proof of your accomplishments in Kod'Taz. It possesses a power that you can unlock when you combine it with the stone from Fezbin. Return to me later if you wish to investigate Yxtta.'")
    e.other:UpdateTaskActivity(task_ids.bic_abysmal, 9, 1)
  end

  if item_lib.check_turn_in(e.trade, {item1 = 67561}) then --Kitren's Tattered Cloak
    e.other:Message(MT.NPCQuestSay, "L`diava Rexxen says 'Oh, thank you brave adventurer. We are now one step closer to finding out what happened to Kitren. Now, give me one second to look through the cloak here and . . . here it is, Kitren's notebook. There must be some information here that can help us more. While I read through this, I need you to return to Kevren Nalavat. He believes he may have found more clues to Kitren's whereabouts and since you did such a good job with the trials he believes you may be able to help him. Even though you have proven yourself by defeating the trials, he will not give you what I need unless you help him. When you return to him, show him this letter and it will confirm my trust in you. Hurry now. There no time to waste!'")
    e.other:SummonItem(67702)
  end

  if item_lib.check_turn_in(e.trade, {item1 = 67555}) then --Xounii's Journal Page 1
    e.other:Message(MT.NPCQuestSay, "L`diava Rexxen says 'Thank you for returning this to me. I wish the circumstances could have been different, but in honor of her memory, we will use this information to prevent the needless death of any other scouts. Now let me see what is written here. Hm. Seems she stumbled onto a secret ritual of some sort in an underground temple, called Uqua. Looks like the Muramites may be trying to reproduce another tear in space. This does not bode well for anyone. We must find out more about this. I must ask that you return to Yxtta and see if you can find any more of Xounii's entries. I cannot tell you where to start looking, but it seems that the best place to look would be in the caves where you found her. Xounii was very diligent about her reports so she would have written much about this. Try to find four more pieces of her journal entries and return them to me.'")
  end

  if item_lib.check_turn_in(e.trade, {item1 = 67556, item2 = 67703, item3 = 67557, item4 = 67558}) then -- Xounii's Journal Page 2 left
    e.other:UpdateTaskActivity(task_ids.bic_abysmal, 8, 1)
  end
  item_lib.return_items(e.self, e.other, e.trade)
end
