task_ids = require('task_ids')
local ikk1_zoner = eq.get_entity_list():GetMobByNpcTypeID(293229)
local righteous_coord = { zone="kodtaz", x=ikk1_zoner:GetX(), y=ikk1_zoner:GetY(), z=ikk1_zoner:GetZ(), h=ikk1_zoner:GetHeading() }
local righteous_info = {
  expedition = { name="Ikkinz, Chambers of Righteousness", min_players=1, max_players=6 },
  instance = { zone="ikkinz", version=3, duration=eq.seconds("13h") },
  compass = righteous_coord,
  safereturn = { zone="kodtaz", x=1279, y=-2004, z=-349.375, h=336 },
  zonein = righteous_coord, 
}
local ikk2_zoner = eq.get_entity_list():GetMobByNpcTypeID(293230)
local glorious_coord = { zone="kodtaz", x=ikk2_zoner:GetX(), y=ikk2_zoner:GetY(), z=ikk2_zoner:GetZ(), h=ikk2_zoner:GetHeading() }
local glorious_info = {
  expedition = { name="Ikkinz, Chambers of Glorification", min_players=1, max_players=6 },
  instance = { zone="ikkinz", version=4, duration=eq.seconds("13h") },
  compass = glorious_coord,
  safereturn = { zone="kodtaz", x=1279, y=-2004, z=-349.375, h=336 },
  zonein = glorious_coord,
}
local ikk3_zoner = eq.get_entity_list():GetMobByNpcTypeID(293231)
local transcend_coord = { zone="kodtaz", x=ikk3_zoner:GetX(), y=ikk3_zoner:GetY(), z=ikk3_zoner:GetZ(), h=ikk3_zoner:GetHeading() }
local transcend_info = {
  expedition = { name="Ikkinz, Chambers of Transcendence", min_players=1, max_players=6 },
  instance = { zone="ikkinz", version=5, duration=eq.seconds("13h") },
  compass = transcend_coord,
  safereturn = { zone="kodtaz", x=1279, y=-2004, z=-349.375, h=336 },
  zonein = transcend_coord
}

function event_say(e)
  if e.other:IsTaskCompleted(task_ids.trusik_task) or e.other:GetGM() then
    if e.message:findi("hail") then
      e.other:Message(MT.NPCQuestSay, "Tublik Narwether says 'Hello again, " .. e.other:GetCleanName() .. "!  You've done great things here in Kod'taz to combat both the Trusik and the Muramites, but I suspect your journey is not yet complete.  If you wish to enter the [" .. eq.say_link("Sanctuary of the Righteous") .. "], the [" .. eq.say_link("Sanctuary of the Glorified") .. "], or the [" .. eq.say_link("Sanctuary of the Transcendent") .. "] again, just say so!'")
    end
    if e.message:findi('sanctuary of the righteous') then
      local dz = e.other:CreateExpedition(righteous_info)
      if dz.valid then
        dz:AddReplayLockout(eq.seconds("14h"))
      end
    end
    if e.message:findi('sanctuary of the glorified') then
      local dz = e.other:CreateExpedition(glorious_info)
      if dz.valid then
        dz:AddReplayLockout(eq.seconds("14h"))
      end
    end
    if e.message:findi('sanctuary of the transcendent') then
      local dz = e.other:CreateExpedition(transcend_info)
      if dz.valid then
        dz:AddReplayLockout(eq.seconds("14h"))
      end
    end
  elseif e.other:IsTaskActivityActive(task_ids.trusik_task, 14) or e.other:IsTaskActivityActive(task_ids.trusik_task, 15) then
    if e.message:findi("hail") then
      e.other:Message(MT.NPCQuestSay, "Tublik Narwethar says 'There you are! I've been waiting for you. I've examined the final glyph on the Icon of the Altar and it seems to suggest that there must have been a final battle between the trusik priests and a keeper of some sort. I can't quite determine what the keeper is, but I imagine it won't be friendly. Before you enter the keeper's inner chambers, you'll need to present your Icon of the Altar to a stone [" .. eq.say_link("sentinel") .. "] standing guard outside. By all accounts, this seems to be the same path that the priests had to take as well.'")
    end
    if e.message:findi("sentinel") then
      e.other:Message(MT.NPCQuestSay, "Tublik Narwethar says 'Like the keeper, I don't know what you should expect with the sentinel, so be prepared for anything. I must send you on your way now and wish you whatever luck a poor dwarf can muster. Fortune has treated you well so far... let's hope it continues.'")
    end
  elseif e.other:IsTaskActivityActive(task_ids.trusik_task, 13) then
    if e.message:findi("hail") then
      e.other:Message(MT.NPCQuestSay, "Tublik Narwethar says 'Welcome back, " .. e.other:GetCleanName() .. ". Any luck with creating the Icon of the Altar?'")
    end
  elseif e.other:IsTaskActivityActive(task_ids.trusik_task, 12) then
    if e.message:findi("hail") then
      e.other:Message(MT.NPCQuestSay, "Tublik Narwethar says 'Welcome back, " .. e.other:GetCleanName() .. ". It doesn't look like you've been able to finish your Icon of the Altar. Do you remember the [" .. eq.say_link("plan") .. "] I devised to create it? If not, I can explain it to you once more.'")
    end
    if e.message:findi("altar of destruction") then
      e.other:Message(MT.NPCQuestSay, "Tublik Narwethar says 'The Altar of Destruction is far more remarkable than any other temple built in this region. I have been catching up on the history of those three artifacts and now you must harness the power that the geomantic priests once held. That power will combine the three pieces you collected into one final [" .. eq.say_link("Icon of the Altar") .. "].'")
    end
    if e.message:findi("icon of the altar") then
      e.other:Message(MT.NPCQuestSay, "Tublik Narwethar says 'From what we've seen of the glyphs in the area, we believe the trusik would use their geomantic powers to meld the three pieces together and form the icon. Since we don't have that luxury, we're going to have to do it another way. I've devised a [" .. eq.say_link("plan") .. "] that should replicate what they were trying to do, but it will require more effort on your part.'")
    end
    if e.message:findi("plan") then
      e.other:Message(MT.NPCQuestSay, "Tublik Narwethar says 'The first thing you're going to need is something to meld the three pieces together. I believe that using some inanimate ore from the stone guardians that protect the temples will be perfect for this job. The next thing you'll need is to make an inferno scepter to heat up the ore. You'll have to make the scepter yourself, which can be done by combining a flarestone, flaring coals, an inferno scepter mold and a blazing torch in a forge. Hmm. I believe you'll have to head back to the ship to find some of those things. If you don't have the Smithing ability, you should seek out Kaleng on the ship, he may not look like it but he's an expert smith, just ask him for some assistance. In any case, there's one [" .. eq.say_link('final step') .. "] that you need to take before you're done.'")
    end
    if e.message:findi("final step") then
      e.other:Message(MT.NPCQuestSay, "Tublik Narwethar says 'Each inferno scepter you make can be used to smelt one block of inanimate ore. Do this three times and you'll get three vials of smelted molten ore. Combine the three vials and the three artifacts in a forge to fuse the three pieces together and hopefully create the Icon of the Altar. When you've finally accomplished all this, show me the icon so I can identify whether this method is one that works or not. Good luck, " .. e.other:GetCleanName() .. ".'")
    end
  elseif e.other:IsTaskActivityActive(task_ids.trusik_task, 9) or e.other:IsTaskActivityActive(task_ids.trusik_task, 10) or e.other:IsTaskActivityActive(task_ids.trusik_task, 11) then
    if e.message:findi("hail") then
      e.other:Message(MT.NPCQuestSay, "Tublik Narwether say 'Hello again, " .. e.other:GetCleanName() .. "!  Are you ready to head into the [" .. eq.say_link("sanctuary of the transcendent") .. "]?'")
    end
  elseif e.other:IsTaskActivityActive(task_ids.trusik_task, 7) or e.other:IsTaskActivityActive(task_ids.trusik_task, 8) then
    if e.message:findi("sanctuary of the transcendent") then
      e.other:Message(MT.NPCQuestSay, "Tublik Narwether says 'The glyphs you recovered show an Artifact of Transcendence that is guarded by a sentinel that is ages old. You will find the Sanctuary of the Transcendent to the south of the Altar of Destruction. You must gather a raiding party several times larger than your normal party's size and be prepared for anything. Find an entrance to the inner chambers of the Sanctuary of the Transcendent and recover the artifact. May you be gifted with the luck of the brotherhood. I fear you may need it.'")
      local dz = e.other:CreateExpedition(transcend_info)
      if dz.valid then
        dz:AddReplayLockout(eq.seconds("14h"))
      end
    end
  elseif e.other:IsTaskActivityActive(task_ids.trusik_task, 5) or e.other:IsTaskActivityActive(task_ids.trusik_task, 6) then
    if e.message:findi("hail") then
      e.other:Message(MT.NPCQuestSay, "Tublik Narwether say 'Hello again, " .. e.other:GetCleanName() .. "!  Are you ready to head into the [" .. eq.say_link("sanctuary of the glorified") .. "]?'")
    end
  elseif e.other:IsTaskActivityActive(task_ids.trusik_task, 4) then
    if e.message:findi("sanctuary of the glorified") then
      e.other:Message(MT.NPCQuestSay, "Tublik Narwether says 'The glyphs you recovered show an Artifact of Glorification that is guarded by a sentinel that is ages old. You will find the Sanctuary of the Glorification to the west of the Altar of Destruction. You must gather a raiding party several times larger than your normal party's size and be prepared for anything. Find an entrance to the inner chambers of the Sanctuary of the Glorified and recover the artifact. May you be gifted with the luck of the brotherhood. I fear you may need it.'")
      local dz = e.other:CreateExpedition(glorious_info)
      if dz.valid then
        dz:AddReplayLockout(eq.seconds("14h"))
      end
    end
  elseif e.other:IsTaskCompleted(task_ids.tublik_task) and not e.other:IsTaskActive(task_ids.trusik_task) then
    if e.message:findi("hail") then
      e.other:Message(MT.NPCQuestSay, "Tublik Narwethar says 'I wasn't expecting you back so soon, " .. e.other:GetCleanName() .. ", but I'm glad you're here. I've been analyzing the glyphs on the last three artifacts you recovered and, the way I read them, it seems the trusik priests used the [" .. eq.say_link("four temples") .. "] around the Altar of Destruction to gain access to a temple to face some kind of final rite of passage.'")
    end
    if e.message:findi("four temples") then
      e.other:Message(MT.NPCQuestSay, "Tublik Narwethar says 'As you've already uncovered, the Sanctuary of Divine Destruction was used to uncover the purpose for the other three. I believe the Muramites destroyed that temple because it holds the key to the remaining three temples and the artifacts that they hold. Now that we know what's ahead, we can continue forth and unravel this [" .. eq.say_link("mystery") .. "].'")
    end
    if e.message:findi("mystery") then
      e.other:Message(MT.NPCQuestSay, "Tublik Narwethar says 'It's clear to me that you must proceed into each of the three remaining temples and recover the three artifacts that are in them. You should start with the [" .. eq.say_link("sanctuary of the righteous") .. "]'")
    end
    if e.message:findi("sanctuary of the righteous") then
      e.other:Message(MT.NPCQuestSay, "Tublik Narwether says 'The glyphs you recovered show an Artifact of Righteousness that is guarded by a sentinel that is ages old. You will find the Sanctuary of the Righteous to the south of the Altar of Destruction. You must gather a raiding party several times larger than your normal party's size and be prepared for anything. Find an entrance to the inner chambers of the Sanctuary of the Righteous and recover the artifact. May you be gifted with the luck of the brotherhood. I fear you may need it.'")
      local dz = e.other:CreateExpedition(righteous_info)
      if dz.valid then
        dz:AddReplayLockout(eq.seconds("14h"))
      end
      if not e.other:IsTaskActive(task_ids.trusik_task) and not e.other:IsTaskCompleted(task_ids.trusik_task) then
        e.other:AssignTask(task_ids.trusik_task)
      end
    end
  elseif e.other:IsTaskActivityActive(task_ids.tublik_task, 11) or e.other:IsTaskActivityActive(task_ids.tublik_task, 12) then
    if e.message:findi("hail") then
      e.other:Message(MT.NPCQuestSay, "Tublik Narwethar says 'Welcome back, " .. e.other:GetCleanName() .. ".  Have you been able to find [" .. eq.say_link("more clues") .. "]?'")
    end
    if e.message:findi("ritual") then
      e.other:Message(MT.NPCQuestSay, "Tublik Narwethar says 'I've been assuming that only the Muramites were so cruel that they would rip flesh from another living being in this manner, but it appears that the trusik priests were the ones that did it. They etched glyphs into the skin and then removed it to be used later. The glyphs represent the four temples and their direct connection to the Altar of Destruction. It looks as though there may be [" .. eq.say_link("more clues") .. "] about the Altar of Destruction and its surrounding temples in the trial temples.'")
    end
    if e.message:findi("more clues") then
      e.other:Message(MT.NPCQuestSay, "Tublik Narwethar says 'I need you to return to the three temples where you participated in the three trials. Based on this clue, I believe you will find three additional clues about the Altar of Destruction in the Temple of Singular Might, the Temple of Twin Struggles, and the Temple of the Tri-Fates. I doubt they'll be hard to find, but you must go to each and search for the clues! Return to me when you have found them!'")
    end
  elseif e.other:IsTaskActivityActive(task_ids.tublik_task, 9) or e.other:IsTaskActivityActive(task_ids.tublik_task, 10) then
    if e.message:findi("hail") then
      e.other:Message(MT.NPCQuestSay, "Tublik Narwethar says 'Welcome back, " .. e.other:GetCleanName() .. ".  Have you made any progress with the runes [" .. eq.say_link("made of flesh") .. "]?'")
    end
    if e.message:findi("made of flesh") then
      e.other:Message(MT.NPCQuestSay, "Tublik shakes his head. 'I know it's not very pleasant, but you've got to remember that these Muramites are a new type of scum like nothing else we've ever come across. I think we can salvage some information from this, but it will require you to venture back into areas infested with Muramites. You'll need to [" .. eq.say_link("gather some materials") .. "] for me so we can sew the flesh back together.'")
    end
    if e.message:findi("gather some materials") then
      e.other:Message(MT.NPCQuestSay, "Tublik Narwethar says 'The first thing you'll need is a needle. We can't take any chances with the use of Muramite-altered flesh so you'll need to make your own. To do so, you'll need to find four bone chips and combine them with some of the weird black residue that the Muramites leave behind when they die. You should be able to fashion them together with a sewing kit. The next thing you'll need to do is get some [" .. eq.say_link("strands of hair") .. "] to keep the flesh together.'")
    end
    if e.message:findi("strands of hair") then
      e.other:Message(MT.NPCQuestSay, "Tublik Narwethar says 'You'll need to gather four strands of hair from the local hynids. They're not friendly, so be careful when you encounter one. Once you've gotten the strands and made your needle, you're going to need to sew the strands together using the needle. It seems strange I know, but remember that the best solutions are usually the simplest ones. Take the hynid thread and the needle and your four pieces of flesh and sew them together. That should get you what you need. Once you've sewn the clue back together, give it to me, and I may finally be able to understand it.'  He pauses for a moment.  'By the way, if you happen to not know your way around a needle, these materials will be very difficult to use.  I'd suggest heading back to the ship and asking Adsame Leing for some tailoring assistance.")
    end
  elseif e.other:IsTaskActivityActive(task_ids.tublik_task, 8) then
    if e.message:findi("hail") then
      e.other:Message(MT.NPCQuestSay, "Tublik Narwethar says 'Welcome back, " .. e.other:GetCleanName() .. ". Have you recovered anything from the Crumbled Sanctuary?'")
    end
  elseif e.other:IsTaskActivityActive(task_ids.tublik_task, 6) or e.other:IsTaskActivityActive(task_ids.tublik_task, 7) then
    if e.message:findi("hail") then
      e.other:Message(MT.NPCQuestSay, "Tublik Narwethar says 'Nice to see you again, " .. e.other:GetCleanName() .. ". This whole time we've been looking at the artifacts that the Muramites have been collecting, but we've been [" .. eq.say_link('ignoring something') .. "] and I think it's time we looked into it.'")
    end
    if e.message:findi("ignoring something") then
      e.other:Message(MT.NPCQuestSay, "Tublik Narwethar says 'Perhaps you've heard of the Altar of Destruction? It is the largest, most visible temple just to the north of here. You can't miss it. If you were to venture just east of it, you would come across a temple that appears destroyed. This temple is called the [" .. eq.say_link("Crumbled Sanctuary") .. "] of Divine Destruction according to the historical information we've received. I have yet to uncover what its purpose is.'")
    end
    if e.message:findi("crumbled sanctuary") then
      e.other:Message(MT.NPCQuestSay, "Tublik Narwethar says 'Oh yeah, I know all about that thing. It was a temple that was decimated by the Muramites during their initial invasion. We're unsure what caused them to destroy that temple, but not the other three. I need you to go to the temple and [" .. eq.say_link("look for clues") .. "] as to what the reason may have been for destroying the temple.'")
    end
    if e.message:findi("look for clues") then
      e.other:Message(MT.NPCQuestSay, "Tublik Narwethar says 'I have no idea what the clues may look like, but I'm hoping they'll bring about some insight as to the reason behind the Muramites destroying the temple. Once you've recovered all the clues you can find, please come back to me so I can go over them. If we're lucky, I'll be able to decipher what the real cause was and we can relay that important news to the brotherhood. Off you go, " .. e.other:GetCleanName() .. ", and good luck!'")
      e.other:UpdateTaskActivity(task_ids.tublik_task, 6, 1)
    end
  elseif e.other:IsTaskActivityActive(task_ids.tublik_task, 3) or e.other:IsTaskActivityActive(task_ids.tublik_task, 4) or e.other:IsTaskActivityActive(task_ids.tublik_task, 5) then
    if e.message:findi("hail") then
      e.other:Message(MT.NPCQuestSay, "Tublik Narwethar says 'Welcome back, " .. e.other:GetCleanName() .. ". I've been looking over those artifacts you returned to me in the sealed bag and I'm afraid I have some disturbing news. It seems the artifacts weren't artifacts at all, but objects of ghastly power held by the dark spirits you collected them from. What's worse is that since you've collected these objects, the energy emanating from the pit has [" .. eq.say_link("gotten stronger") .. "]!'")
    end
    if e.message:findi("gotten stronger") then
      e.other:Message(MT.NPCQuestSay, "Tublik Narwethar says 'The power wasn't as noticeable before. Now, though, it seems there's a fiend in the pit that's become agitated by the removal of these objects we've been collecting. I believe that whatever is behind the energy disruption kept a watchful eye over those objects. Now that they're gone, I believe it will try to find them again and destroy anything and everything in its path in the process. You must [" .. eq.say_link("stop it") .. "] before it has a chance!'")
    end
    if e.message:findi("stop it") then
      e.other:Message(MT.NPCQuestSay, "Tublik Narwethar says 'You must return to the Pit of the Lost and find whatever this fiend is and destroy it. I believe that it will have some kind of artifact that is linked to the ones you returned to me in the sealed bag. Return whatever it may have to me. Good luck, " .. e.other:GetCleanName() .. ", I have no doubt that the artifact it holds will be as interesting of a find as anything else we've uncovered so far!'")
      local npcs = eq.get_entity_list()
      local arp = npcs:GetNPCByNPCTypeID(293221)
      if not arp.valid then --Don't spawn the Ageless Relic Protector if one is already available.
        eq.spawn2(293221, 0, 0, 2176, 2184, -476, 274)
      end
    end
  elseif e.other:IsTaskActivityActive(task_ids.tublik_task, 2) then
    if e.message:findi("hail") then
      e.other:Message(MT.NPCQuestSay, "Tublik Narwethar says 'Welcome back, " .. e.other:GetCleanName() .. ". Have you recovered anything from the Pit of the Lost?'")
    end
  elseif e.other:IsTaskActive(task_ids.tublik_task) then
    if e.message:findi("hail") then
      e.other:Message(MT.NPCQuestSay, "Tublik Narwethar glances at you suspiciously. 'Can I help you with something? Did Kevren send you about the [" .. eq.say_link("Pit of the Lost") .. "]? Speak up!'")
    end
    if e.message:findi("pit of the lost") then
      e.other:Message(MT.NPCQuestSay, "Tublik Narwethar says 'I see Kevren finally sent someone to me to look into the pit. It's about time! I've been telling him over and over that there are some really strange things going on in the Pit of the Lost to the north of here, but he just doesn't seem to want to pay enough attention to the claims. In any case, you're here now and that means that you must be [" .. eq.say_link("willing to look") .. "] into the odd occurrences, right?'")
    end
    if e.message:findi("willing to look") then
      e.other:Message(MT.NPCQuestSay, "Tublik Narwethar says 'I'm glad I can count on you. You need to know a couple things before you go. As I said, there are strange things going on in the pit, but we're not sure what they are yet. We have sensed an energy force emanating from that area and believe there are some kind of artifacts there that must be collected. We need you to [" .. eq.say_link("collect the artifacts") .. "] and return them so we can study them.'")
    end
    if e.message:findi("collect the artifacts") then
      e.other:Message(MT.NPCQuestSay, "Tublik hands you a bag and says, 'Place four artifacts you find from the pit in this bag and seal it off. Return the sealed bag to me when you're done so I can further examine what you find. Make haste to the Pit of the Lost and be careful -- there's no telling what kind of evils are waiting for you there. If you have someone else with you that [" .. eq.say_link("needs a bag") .. "], have them tell me so.'")
      e.other:SummonItem(60155)
    end
    if e.message:findi("needs a bag") then
      e.other:Message(MT.NPCQuestSay, "Tublik nods gruffly and hands you one of his bags.")
      e.other:SummonItem(60155)
    end
  elseif e.other:IsTaskActivityActive(task_ids.kevren_task, 3) or e.other:IsTaskActivityActive(task_ids.kevren_task, 4) then
    if e.message:findi("hail") then
      e.other:Message(MT.NPCQuestSay, "Tublik Narwether says 'Can I help you with something? Has someone sent you? Speak up!'")
    end
    if e.message:findi("stone tablet") then
      e.other:Message(MT.NPCQuestSay, "Tublik Narwethar says 'You need a stone tablet? What for? What have you got that's so special it requires the use of a stone tablet?'")
    end
    if e.message:findi("glyph of the damned") then
      e.other:Message(MT.NPCQuestSay, "Tublik Narwethar says 'Ahh, you're looking to translate some glyphs, eh? You're in luck then, " .. e.other:GetCleanName() .. ". I just happen to have a stone tablet available for you to use. I need to make sure you actually need it before I hand one out to you. Wouldn't want these getting into the wrong hands, you know. Show me one of the glyphs you need to translate and if I am satisfied with what I see, I'll let you have one.'")
      e.other:UpdateTaskActivity(task_ids.kevren_task, 3, 1)
    end
  else
    if e.message:findi("hail") then
      e.other:Message(MT.NPCQuestSay, "Tublik Narwether says 'Can I help you with something? Has someone sent you? Speak up!'")
    end
  end
end


function event_trade(e)
  local item_lib = require("items")

  if item_lib.check_turn_in(e.trade, {item1 = 60146}) then
    e.other:SummonItem(60146)
    give_tablet(e, kt_flag)
  end
  if item_lib.check_turn_in(e.trade, {item1 = 60147}) then
    e.other:SummonItem(60147)
    give_tablet(e, kt_flag)
  end
  if item_lib.check_turn_in(e.trade, {item1 = 60148}) then
    e.other:SummonItem(60148)
    give_tablet(e, kt_flag)
  end
  if item_lib.check_turn_in(e.trade, {item1 = 60149}) then
    e.other:SummonItem(60149)
    give_tablet(e, kt_flag)
  end

  if item_lib.check_turn_in(e.trade, {item1 = 60160}) then
    e.other:Message(MT.NPCQuestSay, "Tublik Narwethar says 'You're done already? I wasn't expecting such a prompt response, but nicely done " .. e.other:GetCleanName() .. "! Give me a while to examine these artifacts. I should have some additional information for you once you return.'")
  end

  if item_lib.check_turn_in(e.trade, {item1 = 60161}) then
    e.other:Message(MT.NPCQuestSay, "Tublik Narwethar says 'Excellent! We don't have to worry about that abomination any longer. This artifact you found on the creature is also quite unique. It will be a while before I have a chance to look it over, but it's nice to have it in our possession nonetheless. Well done once again, " .. e.other:GetCleanName() .. ". I look forward to working with you again soon!'")
  end

  if item_lib.check_turn_in(e.trade, {item1 = 60162, item2 = 60163, item3 = 60164, item4 = 60165}) then
    e.other:Message(MT.NPCQuestSay, "Tublik grunts unhappily at the four pieces. 'I had hoped more work wouldn't be needed to uncover the clues, but it looks like there's a bit more you're going to need to do for me. Take a look at these edges. Do you see how they look really sinewy? That's because they're [" .. eq.say_link("made of flesh") .. "], probably that of the trusik. No doubt the Muramites have been quite cruel to them now that they are mostly used for slavery.'")
    e.other:SummonItem(60162)
    e.other:SummonItem(60163)
    e.other:SummonItem(60164)
    e.other:SummonItem(60165)
  end

  if item_lib.check_turn_in(e.trade, {item1 = 60166}) then
    e.other:Message(MT.NPCQuestSay, "Tublik Narwethar says 'Nicely sewn, " .. e.other:GetCleanName() .. ". I would have tried doing it myself, but I have the most unsteady fingers when it comes to things like that. In any case, let me have a look at what this says.' Tublik looks over the clue for a time before continuing. 'Unbelievable. Simply astounding. These notes weren't made by the Muramites at all. In fact, they were created by trusik priests from their own flesh in some kind of [" .. eq.say_link("ritual") .. "].'")
  end

  if item_lib.check_turn_in(e.trade, {item1 = 60167, item2 = 60168, item3 = 60169}) then
    e.other:Message(MT.NPCQuestSay, "Tublik stares at the three clues for a moment before speaking. 'I can't be sure, but I believe we are getting close to something big, " .. e.other:GetCleanName() .. ". I need more time to examine these clues, but I should have something for you when you return. You've done well and I know that we wouldn't have been able to get this far without your help. Good job!'")
  end

  if item_lib.check_turn_in(e.trade, {item1 = 60170}) then
    e.other:Message(MT.NPCQuestSay, "Tublik Narwethar says 'You've done it! You've recovered the first of the three artifacts! You must keep this with you, as you'll need it once you've recovered all three artifacts. The next temple is the[" .. eq.say_link("Sanctuary of the Glorified") .. "], are you ready ".. e.other:GetCleanName() .. "?")
    e.other:SummonItem(60170)
  end

  if item_lib.check_turn_in(e.trade, {item1 = 60171}) then
    e.other:Message(MT.NPCQuestSay, "Tublik Narwethar says 'You've done it! You've recovered the second of the three artifacts! You must keep this with you, because you'll need it once you've recovered all three artifacts. You only need one more from the [" .. eq.say_link("Sanctuary of the Transcendent") .. "]. Are you ready to progress forward with the final artifact?'")
    e.other:SummonItem(60171)
  end

  if item_lib.check_turn_in(e.trade, {item1 = 60172}) then
    e.other:Message(MT.NPCQuestSay, "Tublik Narwethar says 'You've done it! You've recovered all three of the artifacts! You must keep this with you, because you'll need it now. Somewhere deep down I knew you would be able to get them all. I've been studying the markings from the artifacts and I've come to the conclusion that they must be combined to form a key to enter the [" .. eq.say_link("Altar of Destruction") .. "].'")
    e.other:SummonItem(60172)
  end

  if item_lib.check_turn_in(e.trade, {item1 = 60173}) then
    e.other:Message(MT.NPCQuestSay, "Tublik scans the icon before returning it to you. 'You've done well, " .. e.other:GetCleanName() .. ". Up until now I hadn't noticed the final glyph that is created when the three pieces are combined. I must inspect this further, but return to me shortly and I should have an answer as to the glyph's meaning.'")
    e.other:SummonItem(60173)
  end

  if item_lib.check_turn_in(e.trade, {item1 = 60174}) then
    e.other:Message(MT.NPCQuestSay, "Tublik Narwethar says 'You've exceed all my expectations. This key is only the first of what looks to be three needed... needed for what I wonder? I imagine you'll find out more as you continue your adventures. Seek out Brevik in the Abysmal Sea should you discover anything else. He is one of the Wayfarers Brotherhood's resident geomancer adepts. He's not yet fully skilled, but he has much in the way of knowledge of the craft already and learning more each day. He will no doubt have more information for you. For now, I bid you good luck and farewell, " .. e.other:GetCleanName() .. "!'")
  end
  item_lib.return_items(e.self, e.other, e.trade)
end

function give_tablet(e, kt_flag)
  e.other:Message(MT.NPCQuestSay, "Tublik Narwethar says 'So, you really are helping Kevren with this. My apologies for being so blunt with the requirements, but you never can be too careful with things like this. Here's a stone tablet for your troubles. You're going to need to use as many piles of dust as you have glyphs, then combine the dust and the four glyphs together with the stone tablet to translate them. These glyphs can be tricky, so good luck.'")
  e.other:SummonItem(60175)
end
