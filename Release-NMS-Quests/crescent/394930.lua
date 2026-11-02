-- Original concise dialogue. Only native Kill completion grants credit/rewards.
local function yes(v)return v==true or v==1 end
function event_spawn(e)eq.set_timer("expire",900000)end
function event_timer(e)if e.timer=="expire"and not e.self:IsEngaged()then eq.depop()end end
function event_say(e)
 if not yes(eq.is_task_active(3039606))then return end
 local key="gekkdar_dialogue_"..e.other:CharacterID();local stage=tonumber(e.self:GetEntityVariable(key))or 0;local text=e.message:lower()
 if text:find("hail",1,true)then e.self:Say("I was the last [one] of my line.")
 elseif text=="one"then e.self:SetEntityVariable(key,"1");e.self:Say("No heir remains. Can you [free] me?")
 elseif text=="free"and stage>=1 then e.self:SetEntityVariable(key,"2");e.self:Say("Would you face my [wrath]?")
 elseif text=="wrath"and stage>=2 then e.self:SetEntityVariable(key,"3");e.self:Say("Then I must [die] before I can rest.")
 elseif text=="die"and stage>=3 then e.self:AddToHateList(e.other,1)end
end
