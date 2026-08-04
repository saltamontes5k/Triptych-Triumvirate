task_ids = require('task_ids')
function event_say(e)
  -- If you don't have Kevren's task done, he has nothing to say to you about BiC
  if not e.other:IsTaskCompleted(task_ids.kevren_task) then
    if e.message:findi("have done all you asked") then
      e.other:Message(MT.NPCQuestSay, "Kevren Nalavat shakes his head, 'I believe we still have more work to do before I can trust you with the information I have for L`diava.'")
    end
  end

  -- Flag 19: You're done with Kevren
  if e.other:IsTaskCompleted(task_ids.kevren_task) then
    if e.message:findi("hail") then
       e.other:Message(MT.NPCQuestSay, "Kevren Nalavat says 'Welcome back, " .. e.other:GetCleanName() ..".  You have done all I have asked, but you should see if Tublik needs you for anything else.  Otherwise, if you'd like, we have a chance now to talk [" .. eq.say_link("more") .. "]. You're also more than welcome to attempt the trials again. If so, just let me know you're [" .. eq.say_link("ready to test") .. "] again and we'll proceed down that path. What'll it be, " .. e.other:GetCleanName() .. "?'")
      if not e.other:IsTaskActive(task_ids.tublik_task) and not e.other:IsTaskCompleted(task_ids.tublik_task) then
        e.other:AssignTask(task_ids.tublik_task)
      end
    end
    if e.message:findi("have done all you asked") and e.other:IsTaskActivityActive(task_ids.bic_kodtaz, 2) then
      e.other:Message(MT.NPCQuestSay, "Kevren Nalavat says 'Indeed you have and your help is greatly appreciated. Take this back to L`diava I believe it has the answers she seeks.'")
      e.other:SummonItem(67562)
      e.other:UpdateTaskActivity(task_ids.bic_kodtaz, 2, 1)
    end
  end

  -- Flag 18: You should turn in the Grand Summonter's Glyphs
  if e.other:IsTaskCompleted(task_ids.trials_task) then
    if e.other:IsTaskActivityActive(task_ids.kevren_task, 10) then
      if e.message:findi("hail") then
         e.other:Message(MT.NPCQuestSay, "Kevren Nalavat says 'Welcome back, " .. e.other:GetCleanName() ..". Were you able to stop the muramite summoners?  If so, please hand the glyph you found to me.  Otherwise, if you'd like, we have a chance now to talk [" .. eq.say_link("more") .. "]. You're also more than welcome to attempt the trials again. If so, just let me know you're [" .. eq.say_link("ready to test") .. "] again and we'll proceed down that path. What'll it be, " .. e.other:GetCleanName() .. "?'")
      end
    end

    -- Flag 17: Summoner's Ring
    if e.other:IsTaskActivityActive(task_ids.kevren_task, 7) or e.other:IsTaskActivityActive(task_ids.kevren_task, 8) or e.other:IsTaskActivityActive(task_ids.kevren_task, 9) then
      if e.message:findi("hail") then
        e.other:Message(MT.NPCQuestSay, "Kevren Nalavat says 'Welcome back, " .. e.other:GetCleanName() .. ". I've studied the glyph as much as I can for now. In addition to what we uncovered with the translated glyph, we've received word that the [" .. eq.say_link("rumors") .. "] of a dark summoning are indeed true. The truth of these rumors is no surprise to me at all with all that we've uncovered thus far. The Legion of Mata Muram is evil indeed I have a moment if you want to talk a bit [" .. eq.say_link("more") .. "] about me. You're also more than welcome to attempt the trials again. If so, just let me know you're [" .. eq.say_link("ready to test") .. "] again and we'll proceed down that path. What'll it be, " .. e.other:GetCleanName() .. "?")
      end
      if e.message:findi("rumors") then
        e.other:Message(MT.NPCQuestSay, "Kevren Nalavat says 'It looks as though the invaders are planning on bringing beasts into this world by means of a collective summoning. We're unsure if they're even able to do this, but we do know that they cannot be allowed the chance to succeed. You are charged with finding the Muramites attempting this summoning and putting a stop to them at once! Is this something you [" .. eq.say_link("think you can do") .. "]?'")
      end
      if e.message:findi("can do") then
        e.other:Message(MT.NPCQuestSay, "Kevren Nalavat says 'I hoped as much. What I ask of you now won't be easy. You must gather a raiding force several times the size of your normal party. We fear that only sufficient force will be enough to stop this threat. Once you have your party in tow, make your way to the summoning circle, and vanquish the threat of the evil legion priests before they bring their minions into this realm. I have one [" .. eq.say_link("final warning") .. "] for you before you go.'")
      end
      if e.message:findi("final warning") then
        e.other:Message(MT.NPCQuestSay, "Kevren Nalavat says 'I am unsure of the Muramites' timing. It is possible that I have heard incorrectly and that the summoning force may not be there at this time. Do not take this to mean that I was wrong! The force will be there, but it may take them a few more hours to assemble. Be patient. They will arrive. Lastly, the rumors have stated that these legion priests will be using some special artifacts they have collected. We do not know what these artifacts are, but you must return one of these artifacts to me when you have finished so that we can examine it. Good luck, " .. e.other:GetCleanName() .. ", I fear you may need it.'")
      end
    end

    --Flag 16: You should turn in the Translated Glyph of the Damned
    if e.other:IsTaskActivityActive(task_ids.kevren_task, 6) then
      if e.message:findi("hail") then
         e.other:Message(MT.NPCQuestSay, "Kevren Nalavat says 'Welcome back, " .. e.other:GetCleanName() ..". Were you able to translate the glyphs?  If so, please hand the result to me.  Otherwise, if you'd like, we have a chance now to talk [" .. eq.say_link("more") .. "]. You're also more than welcome to attempt the trials again. If so, just let me know you're [" .. eq.say_link("ready to test") .. "] again and we'll proceed down that path. What'll it be, " .. e.other:GetCleanName() .. "?'")
      end
    end

    --Flag 15: Stone Tablet
    if e.other:IsTaskActivityActive(task_ids.kevren_task, 3) or e.other:IsTaskActivityActive(task_ids.kevren_task, 4) or e.other:IsTaskActivityActive(task_ids.kevren_task, 5) then
      if e.message:findi("hail") then
        e.other:Message(MT.NPCQuestSay, "Kevren Nalavat says 'Welcome back, " .. e.other:GetCleanName() ..". You should find Tublik Narwether and ask him for a stone tablet.  Otherwise, if you'd like, we have a chance now to talk [" .. eq.say_link("more") .. "]. You're also more than welcome to attempt the trials again. If so, just let me know you're [" .. eq.say_link("ready to test") .. "] again and we'll proceed down that path. What'll it be, " .. e.other:GetCleanName() .. "?'")
      end
    end

    --Flag 13: Temple of the Damned
    if e.other:IsTaskActivityActive(task_ids.kevren_task, 2) then
      if e.message:findi("hail") then
         e.other:Message(MT.NPCQuestSay, "Kevren Nalavat says 'Hello again, " .. e.other:GetCleanName() .. ". I've been studying the information you retrieved from the Martyrs Passage and I do believe we have a [" .. eq.say_link("problem") .. "] on our hands. I have a moment if you want to talk a bit [" .. eq.say_link("more") .. "] about me. You're also more than welcome to attempt the trials again. If so, just let me know you're [" .. eq.say_link("ready to test") .. "] again and we'll proceed down that path. What'll it be, " .. e.other:GetCleanName() .. "?")
      end
      if e.message:findi("problem") then
        e.other:Message(MT.NPCQuestSay, "Kevren Nalavat says 'The problem is that this information reveals a most disturbing plot by the Muramites to summon a creature into this realm. They appear to be experts in teleportation. The parchment you returned to me described the use of the Temple of the Damned to gather instruments of power that will allow the beast to coalesce in our world. It doesn't go into what those instruments are or when the summoning will take place, so you must [" .. eq.say_link("discover their plans") .. "].'")
      end
      if e.message:findi("discover their plans") then
        e.other:Message(MT.NPCQuestSay, "Kevren Nalavat says 'You must go into the Temple of the Damned. It is the temple directly behind me with the fog looming around it. Explore the temple and search for the instruments of power that the Legion of Mata Muram priests are collecting. Once you have the relics in hand, return them to me so I can study them further. Good luck to you, " .. e.other:GetCleanName() .. ".'")
      end
    end

    --Flag 12: You should turn in the skin
    if e.other:IsTaskActivityActive(task_ids.kevren_task, 1) then
      if e.message:findi("hail") then
         e.other:Message(MT.NPCQuestSay, "Kevren Nalavat says 'Welcome back, " .. e.other:GetCleanName() ..". Did you find something else from the muramites in Martyr's Passage?  If so, please hand it to me.  Otherwise, if you'd like, we have a chance now to talk [" .. eq.say_link("more") .. "]. You're also more than welcome to attempt the trials again. If so, just let me know you're [" .. eq.say_link("ready to test") .. "] again and we'll proceed down that path. What'll it be, " .. e.other:GetCleanName() .. "?'")
      end
    end

    --Flag 11: You should turn in the relics
    if e.other:IsTaskActivityActive(task_ids.kevren_task, 0) then
      if e.message:findi("hail") then
         e.other:Message(MT.NPCQuestSay, "Kevren Nalavat says 'Welcome back, " .. e.other:GetCleanName() ..". Were you able to find the relics in Martyr's Passage?  If so, please hand them to me.  Otherwise, if you'd like, we have a chance now to talk [" .. eq.say_link("more") .. "]. You're also more than welcome to attempt the trials again. If so, just let me know you're [" .. eq.say_link("ready to test") .. "] again and we'll proceed down that path. What'll it be, " .. e.other:GetCleanName() .. "?'")
      end
    end
  end

  --Flag 10: Trials complete, moving on
  if e.other:IsTaskCompleted(task_ids.trials_task) and not e.other:IsTaskCompleted(task_ids.kevren_task) and not e.other:IsTaskActive(task_ids.kevren_task) then
    if e.message:findi("hail") then
      e.other:Message(MT.NPCQuestSay, "Kevren Nalavat says 'Welcome back, " .. e.other:GetCleanName() ..". I must congratulate you on your recent completion of all three trials. I must admit that I was unsure of your ability to do as well as you did. Now that you have finished, you have the choice of taking on some [" .. eq.say_link("other tasks") .. "]. If you'd like, we have a chance now to talk [" .. eq.say_link("more") .. "]. You're also more than welcome to attempt the trials again. If so, just let me know you're [" .. eq.say_link("ready to test") .. "] again and we'll proceed down that path. What'll it be, " .. e.other:GetCleanName() .. "?'")
    end
    if e.message:findi("other tasks") then
      e.other:Message(MT.NPCQuestSay, "Kevren Nalavat says 'As I suspected, you're ready for some challenging work! I must warn you though, what lies ahead is not for the faint of heart.  The task I need now is someone to investigate the [" .. eq.say_link("Martyrs Passage") .. "].")
    end
    if e.message:findi("martyrs passage") then
      e.other:Message(MT.NPCQuestSay, "Kevren Nalavat says 'Good, we're in need of a sturdy adventurer to help us with a dire situation along the Martyrs Passage. First, this area was named so because it houses the spirits of martyred heroes lost long ago. The trusik lined the passageway with [" .. eq.say_link("ancient relics") .. "] to sooth the spirits while in the afterlife. Unfortunately, the Muramites are disturbing the remains and are looking to collect the spiritual remnants for some sinister use.'")
    end
    if e.message:findi("ancient relics") then
      e.other:Message(MT.NPCQuestSay, "Kevren Nalavat says 'We're unsure what the invaders are gathering these particular relics for. From what I can surmise, none of them have any kind of magical properties. In any case, it's up to you and a group of adventurers to venture to the Martyrs Passage and [" .. eq.say_link("investigate") .. "] the situation. I've heard reports of ghosts in that area, so the invaders may have stirred up something unexpected.'")
    end
    if e.message:findi("investigate") then
      e.other:Message(MT.NPCQuestSay, "Kevren Nalavat says 'You'll need to head to the Martyrs Passage and recover four different relics. I advise taking a sturdy group with you because there may be invaders there in the process of burgling the passage. If you uncover any information on what the Mata Muram are planning to use these relics for, return that to me as well. Do you [" .. eq.say_link("understand") .. "] your objective?'")
    end
    if e.message:findi("understand") then
      e.other:Message(MT.NPCQuestSay, "Kevren Nalavat says 'Good, be on your way then. Return to me when you have completed your objective. I wish you luck and await your return.'")
      e.other:AssignTask(task_ids.kevren_task)
    end
  end

  --Flag 8 and 9: You should be doing the trial
  if not e.other:IsTaskCompleted(task_ids.trials_task) and e.other:IsTaskActive(task_ids.trials_task) then
    if e.other:IsTaskActivityActive(task_ids.trials_task, 13) or e.other:IsTaskActivityActive(task_ids.trials_task, 14) or e.other:IsTaskActivityActive(task_ids.trials_task, 15) or e.other:IsTaskActivityActive(task_ids.trials_task, 16) then
      if e.message:findi("hail") then
        e.other:Message(MT.NPCQuestSay, "Kevren Nalavat says, 'Good luck with the third trial, " .. e.other:GetCleanName() .. "!  Be sure to return the artifact you obtain from the trial to Kenra Kalekkio.")
      end
    end

  --Flag 7: Trial of Tri-Fates
    if e.other:IsTaskActivityActive(task_ids.trials_task, 11) or e.other:IsTaskActivityActive(task_ids.trials_task, 12) then
      if e.message:findi("hail") then
        e.other:Message(MT.NPCQuestSay, "Kevren Nalavat says 'Welcome back, " .. e.other:GetCleanName() .. ". Reports of your actions in the Temple of Twin Struggles suggest that you may be well on your way to becoming an outstanding addition to the coalition that investigates these temples. I continue standing my post and, boring as it is, it is of no interest to you I'm sure. If you want, we can talk [" .. eq.say_link("more") .. "] when we have some idle time. For now, if you're [" .. eq.say_link("ready to continue testing") .. "], we can proceed! What'll it be, " .. e.other:GetCleanName() .. "?'")
      end
      if e.message:findi("ready to continue testing") then
        e.other:Message(MT.NPCQuestSay, "Kevren nods his approval, 'Good to hear! If you're interested or have forgotten I can give you some [" .. eq.say_link("background information") .. "] about the mountaintop. If you're ready to proceed, I can explain the [" .. eq.say_link("trials") .. "] to you once more.'")
      end
      if e.message:findi("singular might") or e.message:findi("twin struggles") then
        e.other:Message(MT.NPCQuestSay, "Kevren Nalavat shakes his head, 'You have already completed that trial, the brotherhood needs you to move on to the next challenges before you can return to a trial.")
      end
      if e.message:findi("tri(.*)fates") then
        e.other:Message(MT.NPCQuestSay, "Kevren Nalavat says 'Beyond the dark fog to the south lies the Temple of the Tri-Fates. It is the northern-most temple of the three. In front of the temple you will encounter three smaller temples and it is there you will find another of the brotherhood waiting for you. Seek out and speak with Kenra Kalekkio about the troubles within the temple.'")
      end
    end 

    --Flag 5 and 6: You should be doing the trial
    if e.other:IsTaskActivityActive(task_ids.trials_task, 7) or e.other:IsTaskActivityActive(task_ids.trials_task, 8) or e.other:IsTaskActivityActive(task_ids.trials_task, 9) or e.other:IsTaskActivityActive(task_ids.trials_task, 10) then
      if e.message:findi("hail") then
        e.other:Message(MT.NPCQuestSay, "Kevren Nalavat says, 'Good luck with the second trial, " .. e.other:GetCleanName() .. "!  Be sure to return the artifact you obtain from the trial to Maroley Nazuey.")
      end
    end

    --Flag 4: Trial of Twin Struggles
    if e.other:IsTaskActivityActive(task_ids.trials_task, 5) or e.other:IsTaskActivityActive(task_ids.trials_task, 6) then
      if e.message:findi("hail") then
        e.other:Message(MT.NPCQuestSay, "Kevren Nalavat says 'Welcome back, " .. e.other:GetCleanName() .. ". Reports of your actions in the Temple of Singular Might suggest that you may be well on your way to becoming an outstanding addition to the coalition that investigates these temples. I continue standing my post and, boring as it is, it is of no interest to you I'm sure. If you want, we can talk [" .. eq.say_link("more") .. "] when we have some idle time. For now, if you're [" .. eq.say_link("ready to continue testing") .. "], we can proceed! What'll it be, " .. e.other:GetCleanName() .. "?'")
      end
      if e.message:findi("ready to continue testing") then
        e.other:Message(MT.NPCQuestSay, "Kevren nods his approval, 'Good to hear! If you're interested or have forgotten I can give you some [" .. eq.say_link("background information") .. "] about the mountaintop. If you're ready to proceed, I can explain the [" .. eq.say_link("trials") .. "] to you once more.'")
      end
      if e.message:findi("twin struggles") then
        e.other:Message(MT.NPCQuestSay, "Kevren Nalavat says 'Beyond the dark fog to the south lies the Temple of Twin Struggles. It is the southern-most temple of the three. In front of the temple you will encounter two smaller temples and it is there you will find another of the brotherhood waiting for you. Seek out and speak with Maroley Nazuey about the troubles within the temple.'")
      end
      if e.message:findi("singular might") then
        e.other:Message(MT.NPCQuestSay, "Kevren Nalavat shakes his head, 'You have already completed that trial, the brotherhood needs you to move on to the next challenges before you can return to a trial.")
      end
      if e.message:findi("tri(.*)fates") then
        e.other:Message(MT.NPCQuestSay, "Kevren Nalavat says 'I'm sorry " .. e.other:GetCleanName() .. ", but you're not ready to face the third trial. You must first find Maroley Nazuey near the Temple of [" .. eq.say_link("Twin Struggles") .. "] and finish the second trial before you may proceed. Return to me when you have accomplished that feat.'")
      end
    end

    --Flag 2 and 3: You should be doing the trial
    if e.other:IsTaskActivityActive(task_ids.trials_task, 0) or e.other:IsTaskActivityActive(task_ids.trials_task, 1) or e.other:IsTaskActivityActive(task_ids.trials_task, 2) or e.other:IsTaskActivityActive(task_ids.trials_task, 3) or e.other:IsTaskActivityActive(task_ids.trials_task, 4) then
      if e.message:findi("hail") then
        e.other:Message(MT.NPCQuestSay, "Kevren Nalavat says, 'Good luck with the first trial, " .. e.other:GetCleanName() .. "!  Be sure to return the artifact you obtain from the trial to Gazak Klelkek.")
      end
    end
  end

  --Flag 1: Trial of Singular Might
  if not e.other:IsTaskActive(task_ids.trials_task) and not e.other:IsTaskCompleted(task_ids.trials_task) then
    if e.message:findi("hail") then
      e.other:Message(MT.NPCQuestSay, "Kevren looks relieved to see you. 'Finally the Wayfarers Brotherhood has sent adventurers this far out. I was beginning to wonder what was happening. I'm Kevren Nalavat, one of the brotherhood's traveling scholars. We can talk [" .. eq.say_link("more") .. "] later. The important thing is that you're here and now that you are you'll need to prove that you're up to the challenges facing us on this rugged terrain. I've been all through this area and it's no place to be caught unaware! So what do you say?  Are you [" .. eq.say_link("ready to be tested") .. "]?'")
    end
    if e.message:findi("singular might") then
      e.other:Message(MT.NPCQuestSay, "Kevren Nalavat says 'Beyond the dark fog to the south lies the Temple of Singular Might. You can find it between the two other temples. In front of the temple you will find a single, smaller temple where another of the brotherhood is waiting for you. Seek out Gazak Klelkek and speak to him about the troubles within the temple.'")
      if not e.other:IsTaskActive(task_ids.trials_task) then
        e.other:AssignTask(task_ids.trials_task)
      end
    end
    if e.message:findi("twin struggles") then
      e.other:Message(MT.NPCQuestSay, "Kevren Nalavat says 'I'm sorry " .. e.other:GetCleanName() .. ", but you're not ready to face the second trial. You must first find Gazak Klelkek near the Temple of [" .. eq.say_link("Singular Might") .. "] and finish the first trial before you may proceed. Return to me when you have accomplished that feat.'")
    end
    if e.message:findi("tri(.*)fates") then
        e.other:Message(MT.NPCQuestSay, "Kevren Nalavat says 'I'm sorry " .. e.other:GetCleanName() .. ", but you're not ready to face the third trial. You must first find Gazak Klelkek near the Temple of [" .. eq.say_link("Singular Might") .. "] and finish the first trial before you may proceed. Return to me when you have accomplished that feat.'")
    end
  end

  --Flags 10 and up: Redo trials
  if e.other:IsTaskCompleted(task_ids.trials_task) then
    if e.message:findi("ready to test") then
      e.other:Message(MT.NPCQuestSay, "Kevren nods his approval, 'Good to hear! If you're interested or have forgotten I can give you some [" .. eq.say_link("background information") .. "] about the mountaintop. If you're ready to proceed, I can explain the [" .. eq.say_link("trials") .. "] to you once more.'")
    end
  end

  --Flags 1+: Lore
  if e.message:findi("ready to be tested") then
    e.other:Message(MT.NPCQuestSay, "Kevren nods his approval, 'Good to hear! If you're interested I can give you a little [" .. eq.say_link("background information") .. "] about the mountaintop here before we get started, otherwise I'll explain the [" .. eq.say_link("trials") .. "] to you.'")
  end
  if e.message:findi("more") then
    e.other:Message(MT.NPCQuestSay, "Kevren Nalavat says 'Well I haven't always been the bold adventurer you see before you. I know I may not look too daring, but that's because I'm trying to keep a low profile. Before I joined the Wayfarers Brotherhood I was a learned scholar and knowledge-seeker. I sought to uncover the mysteries of ancient ruins and civilizations lost long ago. I was so focused on my studies that most of my colleagues thought I bordered on [" .. eq.say_link("crazy") .. "].'")
  end
  if e.message:findi("crazy") then
    e.other:Message(MT.NPCQuestSay, "Kevren Nalavat says 'Yes, crazy. I didn't mind though. I knew most of them would never uncover a full understanding of the past like I was. I continued my studies until I was approached by Morden Rasp -- I'm sure you've heard of him. He contacted me and said he was going to begin gathering artifacts from civilizations lost to the ages and that my skills were going to be needed in the times to come. I couldn't help but [" .. eq.say_link("join him") .. "].'")
  end
  if e.message:findi("join him") then
    e.other:Message(MT.NPCQuestSay, "Kevren Nalavat says 'His offer was irresistible! Since I joined the brotherhood I have provided my continuing expertise about lost civilizations. Of course, Morden told me that just being a scholar wasn't going to be enough. He said I had to learn some other skill to stay with the brotherhood as an explorer. I had already learned so much so quickly and didn't dare leave with all the new and exciting items we were getting from adventurers, so I decided to learn how to become a rogue so I could [" .. eq.say_link("sneak around") .. "] to collect what I needed.'")
  end
  if e.message:findi("sneak around") then
    e.other:Message(MT.NPCQuestSay, "Kevren looks towards the ground, shamefully. 'It wasn't the most glamorous thing to do, I know. But you have to understand that I have never been the adventurous type! I certainly didn't want glamour of any kind. I figured sneaking around to gather [" .. eq.say_link("what was needed") .. "] would be easier than trying to fight my way through. Plus, sneaking around allowed me to go alone into ruins so I didn't need to rely on anyone.")
  end
  if e.message:findi("what was needed") then
    e.other:Message(MT.NPCQuestSay, "Kevren suddenly looks up at you with renewed earnest. 'Oh you wouldn't believe the things I've already found out about the people who built the temples around here! Well firstly, it's been a bit more difficult than usual to find anything out about them because they have no written history -- they tell stories complemented with glyphs to recount their history. I've learned how to interpret most of the glyphs I've encountered so far and believe me when I say that it's been some of the most interesting work I've done thus far. That reminds me, do you want to hear some more about the [" .. eq.say_link("background information") .. "] of this area or are you ready to learn about the [" .. eq.say_link("trials") .. "]?'")
  end
  if e.message:findi("background information") then
    e.other:Message(MT.NPCQuestSay, "Kevren Nalavat says 'Good. There's no use going into an area without knowing the lay of the land. The first thing you should know is that you're walking into a huge expanse at the top of the mountain. It must have taken several years to dig out all the rock from the mountain. With the space they dug out they were able to build grand temples into the side of the mountain. Until you've seen them for yourself you can't imagine their [" .. eq.say_link("grandeur") .. "].'")
  end
  if e.message:findi("grandeur") then
    e.other:Message(MT.NPCQuestSay, "Kevren Nalavat says 'Oh indeed! The trusik -- that's what they call themselves -- had powerful geomancers that must have expended huge amounts of energy to shape and mold the mountain. They used mighty golems to clear away the rubble so they could continue their work. The temples they built are all in recognition to [" .. eq.say_link("some being") .. "] they worshiped long ago and some of them seem to reach the sky!'")
  end
  if e.message:findi("some being") then
    e.other:Message(MT.NPCQuestSay, "Kevren Nalavat says 'From what I've been able to gather these people prayed to a god they call Trushar. They believed Trushar was the one who controlled the seas. It was to this deity that they prayed for the destruction of all non-believers and those who exiled them. I tend to wonder if they [" .. eq.say_link("prayed for the destruction") .. "] of non-believers or the nihil in the city.'")
  end
  if e.message:findi("prayed for the destruction") then
    e.other:Message(MT.NPCQuestSay, "Kevren scrunches his brow thoughtfully. 'From the information I've sorted through so far, the nihil in the city kicked the trusik out because they were tired of the fanatic belief in their beloved sea god. I even think that's where the name trusik comes from, a title for exiled believers of a non-existent being. I'm hoping that we can uncover some more of those [" .. eq.say_link("mysteries") .. "] in the temples beyond.'")
  end
  if e.message:findi("mysteries") then
    e.other:Message(MT.NPCQuestSay, "Kevren Nalavat says 'There are still some things that are left unexplained. Most importantly is the fact that we don't know how deep the invader presence goes. We need to discover some of the reasons for the temples, what purpose they serve now, and what the invaders have to do with them. We need to investigate the temples and the remains further for this information. That's where [" .. eq.say_link("you come in") .. "].'")
  end
  if e.message:findi("come in") then
    e.other:Message(MT.NPCQuestSay, "Kevren sighs, 'I haven't had a lot of time to look around the temples, because I was commissioned to scout ahead and remain here for the adventuring parties that would be sent shortly after. Now that those parties are being sent, I have to maintain my post and make sure that those we're sending in to look for the information for us are up to the task. That's the very reason we have designed the [" .. eq.say_link("trials") .. "].'")
  end
  if e.message:findi("trials") then
    e.other:Message(MT.NPCQuestSay, "Kevren's look turns serious. 'There are any number of new threats with these invaders and we're unsure just how powerful or how many of them there are. We need to make sure that those of you being sent up here to find that information out for us won't be scared off by the destructive force these invaders bring along with them. The trials must be done in a [" .. eq.say_link("specific order") .. "] and must all be completed before we can allow you to attempt any further work for the brotherhood.'")
  end
  if e.message:findi("specific order") then
    e.other:Message(MT.NPCQuestSay, "Kevren Nalavat says 'There exist three temples nearby that you must enter. I have defined these three as the Temple of [" .. eq.say_link("Singular Might") .. "], Temple of [" .. eq.say_link("Twin Struggles") .. "], and Temple of the [" .. eq.say_link("Tri-Fates") .. "]. In each lay the forces of the Legion of Mata Muram who must be destroyed. You must not be fooled, we do not control these temples. The areas are controlled by the [" .. eq.say_link("Muramites") .. "], but we believe that these places hold the most predictable of the invaders and can be used easily as our testing grounds.'")
  end
  if e.message:findi("muramites") then
    e.other:Message(MT.NPCQuestSay, "Kevren Nalavat says 'The Muramites aren't from Norrath. We're not sure where they're from yet, but that's one of the things we're trying to uncover. They are part of the Legion of Mata Muram, and though we don't know who Mata Muram is just yet, we believe he is their leader. Back to the issue at hand, the Muramites keep a steady flow of reinforcements into these three temples to ensure that they maintain control of them. We use the temples to ensure that we have capable expeditioners to eradicate more of the creatures that serve in the legion.'")
  end
end

function event_trade(e)
  local item_lib = require("items")

  if item_lib.check_turn_in(e.trade, {item1 = 60141, item2 = 60142, item3 = 60143, item4 = 60144}) then
    e.other:Message(MT.NPCQuestSay, "Kevren examines the relics for a moment. 'The only thing I can find on these relics are glyphs. They're very old and hard to make out, but it appears that they depict four powers. I would say they refer to the temples around the Altar of Destruction, but I can't be sure. It will take some time to go over these some more. In the meantime, do you have anything else for me that might explain the Muramites' interest in the passage? If not, please do go look again. I'm sure there will be something there we can use!'")
  end

  if item_lib.check_turn_in(e.trade, {item1 = 60145}) then
    e.other:Message(MT.NPCQuestSay, "Kevren Nalavat says 'Aha! I suspected there would be some kind of indication of what they were doing in that passage. I applaud your efforts. I only briefly skimmed the information and from what I can gather, it appears that there are nefarious deeds afoot. I'll need more time to examine this, but I should know what it says in a few moments. Well done, once again, " .. e.other:GetCleanName() .. "!'")
  end

  if item_lib.check_turn_in(e.trade, {item1 = 60146, item2 = 60147, item3 = 60148, item4 = 60149}) then 
    e.other:Message(MT.NPCQuestSay, "Kevren examines the strange glyphs. 'These glyphs are faded. I won't be able to decipher them until they've been cleaned up. You'll need to go back to the Martyrs Passage and recover some dust from the grounds nearby. Once you've gotten a pile of dust, you'll need to speak with Tublik Narwethar who is south of the Martyrs Passage. He has a stone tablet that can add some clarity to the glyphs with the help of that dust. Hurry along, " .. e.other:GetCleanName() .. ", this information is important!'")
    e.other:SummonItem(60146)
    e.other:SummonItem(60147)
    e.other:SummonItem(60148)
    e.other:SummonItem(60149)
  end

  if item_lib.check_turn_in(e.trade, {item1 = 60150}) then
    e.other:Message(MT.NPCQuestSay, "Kevren copies down the intricate patterns from the glyph. 'Very interesting, but very dangerous. I've gone over the glyphs and they suggest there is great danger in the summoning of some kind of ferocious beast. I need to study the markings further, but since I've transcribed them already, you can keep the glyph for your own use. Nicely done, " .. e.other:GetCleanName() .. ".'")
    e.other:SummonItem(60150)
  end

  if item_lib.check_turn_in(e.trade, {item1 = 60151}) then
    e.other:Message(MT.NPCQuestSay, "Kevren Nalavat says 'You've done well to stop the summoning, " .. e.other:GetCleanName() .. ". I know it wasn't easy, but you are quickly becoming known as someone who can do what needs to get done. I fear I have run out of things for you to do for now, so you must find Tublik Narwethar and speak with him for further tasks to complete. You can find him to the south of the Martyrs Passage. Farewell for now, " .. e.other:GetCleanName() .. ".'")
  end

  if item_lib.check_turn_in(e.trade, {item1 = 67702}) then
    e.other:Message(MT.NPCQuestSay, "Kevren Nalavat says 'Seems you have made quite an impression if you are trusted by L`diava. But don't think that this means you do not have to gain my trust. While you survived the three trials I am still in need of assistance, I some [" .. eq.say_link('other tasks') .. "] completed, when you have finished them please return to me and tell me you have done all I asked and I will give you what you came here for. If you do not wish to start these tasks right now we do have some time to talk a little [" .. eq.say_link('more') .. "].'")
  end

  item_lib.return_items(e.self, e.other, e.trade)
end
