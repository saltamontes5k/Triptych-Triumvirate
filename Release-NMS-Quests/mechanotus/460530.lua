-- [[
-- Doctor Brinda Sprocket (460530) -- MMM event 3 (mechanotus v1).
-- Rasper: raidMMM.html stage 3.
--   * Brinda is invulnerable (killing her is pointless on live -- she just
--     returns); she roots in place and rakes the raid with fire AEs.
--   * Ten M.E.G. enforcers spawn on engage; three carry the passwords.
--     Kill all three password enforcers to complete the event.
--   * oil slicks lay a fire-resist debuff aura.
-- On completion: Treasure_of_Doctor_Brinda (460582) + controller signal.
-- Simplification: the live three-phase /say password ritual is collapsed to
-- "kill the three password enforcers".
-- ]]

local mmm = require("sof_mmm_raid")

local SIG = 2003
local MEG_ENF, PW_ENF, SLICK = mmm.NPC.meg_enforcer, mmm.NPC.password_enforcer, mmm.NPC.oil_slick
local MY_X, MY_Y, MY_Z = 70, 1590, 678.05

local engaged, frags, done = false, 0, false
local adds = {}

local function alive(r)
    return mmm.alive_clients(MY_X, MY_Y, r or 300)
end

local function clear_event()
    mmm.clear_list(adds)
    adds = {}
end

local function finish(e)
    if done then return end
    done = true
    engaged = false
    for _, t in ipairs({ "fire", "resetcheck" }) do eq.stop_timer(t) end
    clear_event()
    pcall(function() e.self:SetInvul(false) end)
    eq.zone_emote(15, "The passwords align. M.E.G. howls, the enforcers seize, and Doctor Brinda vanishes in a gout of steam!")
    mmm.spawn_chest(e.self, SIG)
    mmm.signal(SIG)
    e.self:Depop()
end

local function engage(e)
    if engaged then return end
    engaged = true
    pcall(function() e.self:SetInvul(true) end)
    -- 7 filler enforcers + 3 password enforcers + 3 oil slicks
    for _ = 1, 7 do
        local m = eq.spawn2(MEG_ENF, 0, 0, MY_X + math.random(-45, 45), MY_Y + math.random(-45, 45), MY_Z, 0)
        if m then
            adds[#adds + 1] = m:GetID()
            local t = alive(300)
            if #t > 0 then m:AddToHateList(t[math.random(#t)], 1000, 10000) end
        end
    end
    for i = 1, 3 do
        local m = eq.spawn2(PW_ENF, 0, 0, MY_X + (i - 2) * 25, MY_Y - 35, MY_Z, 0)
        if m then adds[#adds + 1] = m:GetID() end
    end
    for i = 1, 3 do
        local m = eq.spawn2(SLICK, 0, 0, MY_X + (i - 2) * 30, MY_Y + 35, MY_Z, 0)
        if m then adds[#adds + 1] = m:GetID() end
    end
    eq.set_timer("fire", 30000)
    eq.zone_emote(15, "Doctor Brinda Sprocket cackles. 'Try to keep up! We'll force you!'")
end

function event_combat(e)
    if e.joined then
        engage(e)
        eq.stop_timer("resetcheck")
    else
        eq.set_timer("resetcheck", 60000)
    end
end

function event_signal(e)
    if e.signal ~= 3001 or done then return end
    frags = frags + 1
    if frags >= 3 then
        finish(e)
    else
        eq.zone_emote(15, "A password fragment is recovered. (" .. frags .. "/3)")
    end
end

function event_timer(e)
    if e.timer == "resetcheck" then
        if not e.self:IsEngaged() and not done then
            engaged = false
            frags = 0
            clear_event()
            eq.stop_timer("fire")
            pcall(function() e.self:SetInvul(false) end)
            e.self:Heal()
            eq.zone_emote(15, "The M.E.G. enforcers power down. The event resets.")
        end
        return
    end
    if not engaged or done then return end

    if e.timer == "fire" then
        local roll = math.random(3)
        local t = alive(300)
        if #t == 0 then eq.set_timer("fire", 30000); return end
        if roll == 1 then
            local v = t[math.random(#t)]
            eq.zone_emote(13, "Mathmatron Mallet slams into " .. v:GetCleanName() .. "! (stun + knockback)")
            pcall(function() v:Damage(e.self, 15000, 0, 2); v:Stun(3000) end)
        elseif roll == 2 then
            eq.zone_emote(15, "A Brinda Conical Burn sweeps the room!")
            mmm.raw_damage(e.self, t, 3500, 2)
        else
            eq.zone_emote(15, "Doctor Brinda fires up the Blowtorch!")
            for _ = 1, math.min(4, #t) do
                local v = t[math.random(#t)]
                if v then mmm.raw_damage(e.self, { v }, 8000, 2) end
            end
        end
        eq.set_timer("fire", 30000)
    end
end

function event_death_complete(e)
    -- Brinda cannot be killed during the event (invulnerable); safety net only.
    if not done then
        eq.zone_emote(15, "Doctor Brinda Sprocket reassembles herself from spare parts. 'You can't kill progress!'")
    end
end
