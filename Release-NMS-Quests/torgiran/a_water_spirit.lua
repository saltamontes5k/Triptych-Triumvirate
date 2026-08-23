function event_spawn(e)
    eq.set_timer("depop", 600 * 1000);
end
    
function event_timer(e)
    if e.timer == "depop" then
        eq.depop();
    end
end

function event_say(e)
    if e.message:findi("hail") then
        e.self:Say("I sense a young spirit of flesh and blood nearby.  Those that wish to corrupt it have trapped the spirits of four fearsome beasts within this magical pool. They are known as the frenzy, berserk, fury, and rage spirits.  Tell me which of these do you choose to cleanse from the pool?  Be forewarned these are powerful creatures that can rarely be matched in battle.");
    elseif e.message:findi("frenzy") then
        e.self:Emote("poofs away to nothing as a frenzied creature is summoned forth from the glowing magical pool.");
        eq.unique_spawn(226099, 0, 0, e.self:GetX(), e.self:GetY(),  e.self:GetZ(),  e.self:GetHeading()); -- NPC: a_frenzied_luggald_abomination (226099)
        eq.depop();
    elseif e.message:findi("berserk") then
        e.self:Emote("poofs away to nothing as a berserk creature is summoned forth from the glowing magical pool.");
        eq.unique_spawn(226108, 0, 0, e.self:GetX(), e.self:GetY(),  e.self:GetZ(),  e.self:GetHeading()); -- NPC: a_berserk_luggald_abomination (226108)
        eq.depop();
    elseif e.message:findi("fury") then
        e.self:Emote("poofs away to nothing as a furious creature is summoned forth from the glowing magical pool.");
        eq.unique_spawn(226107, 0, 0, e.self:GetX(), e.self:GetY(),  e.self:GetZ(),  e.self:GetHeading()); -- NPC: a_furious_luggald_abomination (226107)
        eq.depop();
    elseif e.message:findi("rage") then
        e.self:Emote("poofs away to nothing as an enraged creature is summoned forth from the glowing magical pool.");
        eq.unique_spawn(226110, 0, 0, e.self:GetX(), e.self:GetY(),  e.self:GetZ(),  e.self:GetHeading()); -- NPC: an_enraged_luggald_abomination (226110)
        eq.depop();
    end
end
