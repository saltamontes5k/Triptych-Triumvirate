-- Vallon Zek OOB Script - Splits from RZTW
-- NPC ID: 214129

function event_combat(e)
    if e.joined then
        eq.set_timer("OOBcheck", 6000) -- 6 seconds
    else
        eq.stop_timer("OOBcheck")
    end
end

function event_timer(e)
    if e.timer == "OOBcheck" then
        if e.self:GetX() > 650 then
            e.self:CastSpell(2441, e.self:GetHateTop():GetID(), 0, 1) -- Shadowblade spell on top hate target
            e.self:GMMove(412, 11, 169, 129) -- Move back to designated safe coords
            e.self:Emote("'s image fades into the shadows of Drunder.")
        else
            eq.set_timer("OOBcheck", 6000)
        end
    end
end
