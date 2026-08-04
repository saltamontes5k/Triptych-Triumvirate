task_ids = require('task_ids')
-- Task ID definitions
function event_say(e)
  if e.other:IsTaskCompleted(task_ids.bic_abysmal) then
    e.other:Message(MT.NPCQuestSay, "Fezbin Fizzles says 'Hello, " .. e.other:GetCleanName() .. "!  I heard from Beanalle that you were able to complete your stone!  The Wayfarers Brotherhood is forever in your debt for your assistance in scouting this new land.'")
  elseif e.other:IsTaskActive(task_ids.bic_abysmal) then
    if e.message:findi('hail') then
      e.other:Message(MT.NPCQuestSay, "Fezbin Fizzles says 'Hello, " .. e.other:GetCleanName() .. "!  Do you require another [" .. eq.say_link('stone') .. "] or [" .. eq.say_link('sealer') .. "]?'")
    end
    if e.message:findi('stone') then
      e.other:Message(MT.NPCQuestSay, "Fezbin Fizzles scrounges around the room until he comes up with another familiar white crystal.  'Here you are, " .. e.other:GetCleanName() .. ", try not to lose this one.'")
      e.other:SummonItem(67512)
    end
    if e.message:findi('sealer') then
      e.other:Message(MT.NPCQuestSay, "Fezbin Fizzles selects a new sealer from a nearby stack.  'Here you are, " .. e.other:GetCleanName() .. ".  Despite our store of them, try to keep ahold of this one.'")
      e.other:SummonItem(67659)
    end
    if e.message:findi('powerful') then
      e.other:Message(MT.NPCQuestSay, "Fezbin Fizzles says 'The stone I have given you is very special indeed. It is a rare stone with a power that has not yet been revealed. After studying it we have come to the conclusion that its power is based off of resonance. You will see that there are fourteen sockets in the stone. Each socket requires a gem fragment of a certain resonance. As the fragments are set in the stone it will gradually increase in power. These fragments must be placed in the stone in a certain order using a set of clockwork gemcutter's tools, the stone, and the correct shard in the device I handed to you along with the stone. As you help find our scouts, you may come across the gem fragments that will fit into the stone. If you do, please try combining them in the special sealer. If at any time you lose the sealer or misplace the stone return to me and I will what I can do about a replacement.'")
    end
    if e.message:findi('completed') then
      if e.other:IsTaskCompleted(task_ids.bic_qinimi) and e.other:IsTaskCompleted(task_ids.bic_barindu) and e.other:IsTaskCompleted(task_ids.bic_riwwi) and e.other:IsTaskCompleted(task_ids.bic_ferubi) and e.other:IsTaskCompleted(task_ids.bic_sewers) and e.other:IsTaskCompleted(task_ids.bic_vxed) and e.other:IsTaskCompleted(task_ids.bic_tipt) and e.other:IsTaskCompleted(task_ids.bic_outer) and e.other:IsTaskCompleted(task_ids.bic_yxtta) and e.other:IsTaskCompleted(task_ids.bic_kodtaz) then
        e.other:Message(MT.NPCQuestSay, "Fezbin Fizzles says 'So I have been told, " .. e.other:GetCleanName() .. ". Your help will long be remembered by the brotherhood. Since you first came to me, the stone should have grown in power and now I will give you the item that will unlock the stone's full potential. Please combine this with your stone after you have combined all of the other items given to you by the lead scouts and you will possess an item of immense power and a symbol of your fighting spirit. Once again, the brotherhood thanks you. I must bid you good day as I recently received some [" .. eq.say_link('interesting information') .. "].'")
        e.other:UpdateTaskActivity(task_ids.bic_abysmal, 10, 1)
        e.other:SummonItem(67571)
      else
        e.other:Message(MT.NPCQuestSay, "Fezbin Fizzles frowns and shakes his head.  'I haven't been informed of this.  You should check in with L`diava, Vaifan, and Taminoa to make sure they don't have anything else for you to do.'")
      end
    end
    if e.message:findi('interesting information') then
      e.other:Message(MT.NPCQuestSay, "Fezbin Fizzles says 'Where are my manners? I should have known someone as adventurous as you would be interested in this. One of our researching experts by the name of Beanalle has recently discovered some very intriguing information about the temples beyond Yxtta and Kod'Taz.'")
    end
  else
    if e.message:findi('hail') then
      e.other:Message(MT.NPCQuestSay, "Fezbin Fizzles says 'Greetings adventurer, have you come to explore this new [" .. eq.say_link('continent') .. "] we recently discovered?'")
    end
    if e.message:findi('continent') then
      e.other:Message(MT.NPCQuestSay, "Fezbin Fizzles focuses his attention on " .. e.other:GetCleanName())
      e.other:Message(MT.NPCQuestSay, "Fezbin Fizzles says 'Due to some rather odd events with Calliav, we, the Wayfarers Brotherhood, were guided here to the continent we have come to call Taelosia. It is a continent which has suffered through a great magical explosion and now the native inhabitants are in dire straits. Our goal was to investigate this continent and find out more about the strange pieces of matter that we recently found in various places. All signs led us here and so we decided to build this magnificent floating city you are standing in. Unfortunately, we have found out some rather disturbing [" .. eq.say_link('news') .. "] recently that has all of us rather concerned.'")
    end
    if e.message:findi('news') then
      e.other:Message(MT.NPCQuestSay, "Fezbin Fizzles says 'Well, when we finished the city, we began to send out scouts to various locales all over the new continent. Right away information started to flow in. They gave us details on the layout of the land and its current inhabitants. We began to piece together this picture of the current state of things on land. Many of the reports gave details on various things like wildlife and climate as well as the local inhabitants and level of advancement. All of this seemed promising to us as we thought we might be able to talk to the natives and find out more about the strange matter that seemed to originate from this place, but then we begin to receive some very [" .. eq.say_link('upsetting reports') .. "].'")
    end
    if e.message:findi('upsetting reports') then
      e.other:Message(MT.NPCQuestSay, "Fezbin Fizzles says 'Apparently, the event that spread these strange pieces of matter all over Norrath brought with it a group of beings more horrifying than a shaved dwarf. These creatures seemed to be an organized army of some sort. They have apparently taken over the continent and enslaved the natives. Curious about this, we ordered our scouts to find out more about these beings. Specifically, if they could be reasoned with and if they knew anymore about the odd chunks of rock we found recently. Shortly after we made this demand, everything [" .. eq.say_link('stopped') .. "].'")
    end
    if e.message:findi('stopped') then
      e.other:Message(MT.NPCQuestSay, "Fezbin Fizzles says 'The scout reports stopped coming in. We figured that maybe they had just not found anything yet, but as time went by we began to worry. That's when Morden suggested that we send someone to find one of them and learn what was going on. Young Falcin did not know what he was getting into when he volunteered to check things out for us. Falcin left here under the light of a full moon and returned soon after barely able to breathe. He had been caught spying on the beings that currently control the continent. They had tortured him for hours trying to get information. Being the resourceful human he is, he managed to escape only to be mauled by what the natives call ukun, a humanoid creature that is twisted and lethal. Left for dead, Falcin dragged himself back to us and explained what he had [" .. eq.say_link('discovered') .. "] during his ordeal.'")
    end
    if e.message:findi('discovered') then
      e.other:Message(MT.NPCQuestSay, "Fezbin Fizzles says 'Falcin told us that all of the scouts had been captured and were either dead or were enduring extreme torture sessions. These invading beings are a vicious lot who show absolutely no mercy. Falcin's wounds were proof enough of that. Falcin explained that the scouts who were still alive are being held near where they had been discovered. Those who he could not find he assumed were dead but he still tried to get some proof before he wrote them off. Unfortunately Falcin would not live to see his desire through, he passed on shortly after revealing this information to us and now we are at a loss as to how we can help our scouts who are still living return to us and provide a proper burial for those who were lost. We cannot afford to send anyone else out there as it seems it will require a significant force in order to have any chance of accomplishing the [" .. eq.say_link('task') .. "] we need completed.'")
    end
    if e.message:findi('task') then
      e.other:Message(MT.NPCQuestSay, "Fezbin Fizzles says 'With half of our numbers back home dealing with the investigation of the recently unearthed dungeons and the rest here on the ship handling what information we have and trying to decide the best plan of action, Morden figured it might be a good idea to ask some courageous individuals to assist us. Morden has authorized some form of valuable reward for those who can bring us any information regarding our missing scouts or the scouts themselves. Seeing as how you have been so interested in all I have said so far, do you think you would be interested in helping the Wayfarers Brotherhood?'")
    end
    if e.message:findi('yes') then
      e.other:Message(MT.NPCQuestSay, "Fezbin Fizzles says 'Most excellent. Please take these as a token of our gratitude. It is not much to look at now, but by helping us you will find ways to make this stone more [" .. eq.say_link('powerful') .. "] when combining it with certain items in that sealer. Please take the time to find Taminoa Bialu, Vaifan Cogswin, and L`diava Rexxen. They are all located on this ship. Each of them is responsible for information from certain areas of the continent. Taminoa has all the information on the city area, Vaifan keeps the information on the mountain passes, and L`diava collects information on the temple areas. If you truly wish to help us, talk to some or all of them and they will help guide you to the right path. When you have finished helping them all, return to me and I shall give you the reward that has been approved by Morden.'")
      e.other:AssignTask(task_ids.bic_abysmal)
      e.other:SummonItem(67512)
      e.other:SummonItem(67659)
    end
  end
end
