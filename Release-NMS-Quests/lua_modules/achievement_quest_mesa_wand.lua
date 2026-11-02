-- Bixie Dust9146 is a native instant dummy effect; server scripts implement calm.
-- Duration is a labelled reconstruction in mesa_data, not recovered Live timing.
local D=require('achievement_quest_mesa_data').wand
local M={}
local targets={};for _,id in ipairs(D.targets)do targets[id]=true end
local timer='achievement_mesa_bixie_dust'
function M.effect(e)
 if e.spell_id~=D.spell then return 0 end
 if eq.get_zone_id()~=397 or not e.target or not e.target.valid then return 1 end
 local c=eq.get_entity_list():GetClientByID(e.caster_id);local n=e.target:CastToNPC()
 if not c.valid or not n.valid or not targets[n:GetNPCTypeID()]or n:GetOwnerID()~=0 then return 1 end
 -- Native item casting owns charge consumption, equipment and cast range.
 -- Retain an explicit item guard so direct spell invocations cannot calm giants.
 if c:GetItemIDAt(Slot.Primary)~=D.item then return 1 end
 local original=n:GetEntityVariable('mesa_dust_faction')
 if not original or original==''then n:SetEntityVariable('mesa_dust_faction',tostring(n:GetNPCFactionID()))end
 n:WipeHateList();n:SetNPCFactionID(0);n:PauseWandering(D.calm_seconds)
 n:SetEntityVariable('mesa_dust_until',tostring(os.time()+D.calm_seconds));n:SetTimer(timer,D.calm_seconds)
 c:Message(15,'The Bixie dust briefly calms the giant.');return 1
end
function M.timer(e)
 if e.timer~=timer then return false end
 local n=e.self;local untiltime=tonumber(n:GetEntityVariable('mesa_dust_until'))or 0
 if os.time()<untiltime then n:SetTimer(timer,math.max(1,untiltime-os.time()));return true end
 local original=tonumber(n:GetEntityVariable('mesa_dust_faction'))
 if original then n:SetNPCFactionID(original)end
 n:SetEntityVariable('mesa_dust_faction','');n:SetEntityVariable('mesa_dust_until','');n:StopTimer(timer);return true
end
return M
