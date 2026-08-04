task_ids = require('task_ids')
function event_say(e)
	if e.message:findi("Hail") then
		e.self:Say("Hello.  I have a fair selection of leather armor, if you have need of such things.  I've also picked up a trinket or two from other travelers, though they didn't find them so valuable that they couldn't sell them to me,' Adsame smiles.  'If you need my [" .. eq.say_link('tailoring') .. "] skills, just let me know.'");
	end
  if e.message:findi("tailoring") then
    e.other:Message(MT.NPCQuestSay, "Adsame Leing says 'What can I make for you, " .. e.other:GetCleanName() .. "?  A [" .. eq.say_link('muramite needle') .. "] perhaps?  What about some [" .. eq.say_link('hynid-hair thread') .. "]?'")
  end
  if e.message:findi("muramite needle") then
    e.other:Message(MT.NPCQuestSay, "Adsame Leing says 'No problem, " .. e.other:GetCleanName() .. "!  Just bring me the materials and my fee, and it'll be no trouble!'")
    e.other:AssignTask(task_ids.muramite_needle)
  end
  if e.message:findi("hair thread") then
    e.other:Message(MT.NPCQuestSay, "Adsame Leing says 'No problem, " .. e.other:GetCleanName() .. "!  Just bring me the materials and my fee, and it'll be no trouble!'")
    e.other:AssignTask(task_ids.hynid_hair_thread)
  end
end

function event_trade(e)
	local item_lib = require("items");
  if item_lib.check_turn_in(e.trade, {item1 = 60179, item2 = 60179, item3 = 60179, item4 = 60179}) then
    e.other:Message(MT.NPCQuestSay, "Adsame Leing says 'Perfect, these will do nicely.'")
  end
  if item_lib.check_turn_in(e.trade, {item1 = 60187}) then
    e.other:Message(MT.NPCQuestSay, "Adsame Leing says 'Perfect, these will do nicely.'")
  end
  if item_lib.check_turn_in(e.trade, {item1 = 13073, item2 = 13073, item3 = 13073, item4 = 13073}) then
    e.other:Message(MT.NPCQuestSay, "Adsame Leing says 'Perfect, these will do nicely.'")
  end
	if item_lib.check_turn_in(e.trade, {item1 = 60178}) then
    e.other:Message(MT.NPCQuestSay, "Adsame Leing says 'Perfect, these will do nicely.'")
  end
  if item_lib.check_turn_in(e.trade, {platinum = 5000}) then
    eq.debug("I'm here")
    e.other:Message(MT.NPCQuestSay, "Adsame Leing says 'Thank you for your payment, " .. e.other:GetCleanName() .. "!'")
    e.other:UpdateTaskActivity(task_ids.muramite_needle, 2, 1)
  end
  if item_lib.check_turn_in(e.trade, {platinum = 2500}) then
    e.other:Message(MT.NPCQuestSay, "Adsame Leing says 'Thank you for your payment, " .. e.other:GetCleanName() .. "!'")
    e.other:UpdateTaskActivity(task_ids.hynid_hair_thread, 2, 1)
  end
  item_lib.return_items(e.self, e.other, e.trade);
end
