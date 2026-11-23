local boss = require("rof2_dodh_xill_boss")
local timer = "dodh_chamber_guardian_web"
local spells = {6657, 7060, 3053}
local spell_index = 1

function event_damage_taken(e)
    return boss.damage(e)
end

function event_combat(e)
    if e.joined then
        spell_index = 1
        eq.set_timer(timer, 15000)
    else
        eq.stop_timer(timer)
    end
end

function event_timer(e)
    if e.timer ~= timer or not e.self:IsEngaged() or e.self:IsCasting()
        or e.self:GetHPRatio() > 10 then return end
    local target = e.self:GetTarget()
    if not target.valid then return end
    e.self:CastSpell(spells[spell_index], target:GetID())
    spell_index = spell_index % #spells + 1
end
