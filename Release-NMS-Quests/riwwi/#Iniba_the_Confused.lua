-- zam comment needs confirmation: "You need Begging 151 and WARMLY faction with Yunjo Resistance to get key."

function event_say(e)
    if(e.message:findi("please")) then
        if (e.other:GetFaction(e.self) <= 3) then
            if (e.other:GetSkill(67) > 150) then --Begging skill
                e.other:Message(MT.NPCQuestSay, "Iniba the Confused says 'Here, take this. You have proven yourself most persuasive, and the Yunjo are grateful for allies such as you.'");
                e.other:SummonItem(52156); -- Item: Scored Silvery Key
            else
                e.other:Message(MT.NPCQuestSay, "Iniba the Confused says 'You will have to be far more persuasive than that. Work on your begging and return when you have honed the skill.'");
            end
        end
    end
end
