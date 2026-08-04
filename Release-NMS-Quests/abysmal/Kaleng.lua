task_ids = require("task_ids")
function event_say(e)
	if e.message:findi("Hail") then
		e.self:Say("You looking for protection?  I gots da best.  Hard shell for soft ".. e.other:GetRaceName() .." body.  Or mebbe you need some [" .. eq.say_link('blacksmithin') .. "]?'");
	end
  if e.message:findi('blacksmithin') then
    e.other:Message(MT.NPCQuestSay, "Kaleng says 'I can make da [" .. eq.say_link('inferno scepter') .. "] for yeh if yeh wants.'")
  end
  if e.message:findi('inferno scepter') then
    e.other:Message(MT.NPCQuestSay, "Kaleng says 'Okay, bring me stuffs and monies, and I make.'")
    e.other:AssignTask(task_ids.inferno_scepter)
  end
end

function event_signal(e)
	if e.signal == 1 then
        e.self:Emote("laughs loudly.");
    end
end

function event_trade(e)
	local item_lib = require("items");
  if item_lib.check_turn_in(e.trade, {item1 = 60184, item2 = 60182, item3 = 60183, item4 = 60186, platinum = 5000}) then
    e.other:Message(MT.NPCQuestSay, "Kaleng gently nudges you out of the way of the forge and almost carelessly tosses the items in.  He works quickly to produce a blazing scepter, which he hands to you with a friendly grin.")
    e.other:UpdateTaskActivity(task_ids.inferno_scepter, 4, 1)
  end
	item_lib.return_items(e.self, e.other, e.trade);
end
