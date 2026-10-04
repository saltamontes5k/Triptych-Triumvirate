-- [[
-- Breakneck, Master at Arms (460510) -- MMM event 1 (mechanotus v1).
-- Rasper: raidMMM.html stage 1.
--   * stance change emotes (stationary / mobile)
--   * mallet lob (targeted emote -> 50k if not ducked)
--   * charge (targeted emote -> 50k AE to everyone near the victim if caught)
--   * four add waves (elite grinder + trooper), then an extra elite every 2 min
-- On death: Treasure_of_Breakneck (460580) + signal the zone controller.
-- Simplifications: the live "click each door for a spawn chance" opening is
-- folded into a single static v1 spawn; ducking is approximated.
-- ]]

local mmm = require("sof_mmm_raid")

local SIG = 2001
local TROOPER, ELITE = mmm.NPC.grinder_trooper, mmm.NPC.grinder_elite

local MY_X, MY_Y, MY_Z = 70, 1525, 678.05

local WAVES = {
    { elite = 2, trooper = 2 },
    { elite = 2, trooper = 3 },
    { elite = 3, trooper = 3 },
    { elite = 3, trooper = 4 },
}

local engaged, phase = false, 0
local adds = {}
local lob_target, charge_target

local function alive(r)
    return mmm.alive_clients(MY_X, MY_Y, r or 300)
end

local function spawn_wave(i)
    local w = WAVES[i]
    for _ = 1, w.elite do
        local m = mmm.spawn_add(ELITE, MY_X + math.random(-30, 30), MY_Y + math.random(-30, 30), MY_Z)
        if m then adds[#adds + 1] = m:GetID() end
    end
    for _ = 1, w.trooper do
        local m = mmm.spawn_add(TROOPER, MY_X + math.random(-30, 30), MY_Y + math.random(-30, 30), MY_Z)
        if m then adds[#adds + 1] = m:GetID() end
    end
    local t = alive(300)
    for _, id in ipairs(adds) do
        local m = eq.get_entity_list():GetNPCByID(id)
        if m and m.valid and #t > 0 then
            m:AddToHateList(t[math.random(#t)], 1000, 10000)
        end
    end
end

local function engage(e)
    if engaged then return end
    engaged = true
    phase = 0
    eq.set_timer("wave", 60000)
    eq.set_timer("mallet", 35000)
    eq.set_timer("charge", 55000)
    eq.zone_emote(15, "Breakneck, Master at Arms adopts a stationary stance again. 'You will not pass, whelps!'")
end

function event_combat(e)
    if e.joined then
        engage(e)
        eq.stop_timer("resetcheck")
    else
        eq.set_timer("resetcheck", 60000)
    end
end

function event_timer(e)
    if e.timer == "resetcheck" then
        if not e.self:IsEngaged() then
            engaged = false
            mmm.clear_list(adds)
            adds = {}
            eq.stop_timer("wave"); eq.stop_timer("mallet"); eq.stop_timer("charge")
            e.self:Heal()
            eq.zone_emote(15, "Breakneck straightens, the fight forgotten. The event resets.")
        end
        return
    end
    if not engaged then return end

    if e.timer == "wave" then
        if phase < #WAVES then
            phase = phase + 1
            eq.zone_emote(15, "Breakneck, Master at Arms changes his stance. He is no longer stationary. Grinder reinforcements pour in!")
            spawn_wave(phase)
            eq.set_timer("wave", 60000)
        else
            spawn_wave(4)
            eq.zone_emote(15, "More grinders answer Breakneck's call.")
            eq.set_timer("wave", 120000)
        end
    elseif e.timer == "mallet" then
        local t = alive(300)
        if #t > 0 then
            local v = t[math.random(#t)]
            lob_target = v:GetID()
            eq.zone_emote(15, "Breakneck hoists an arm back, preparing to lob a weighted mallet in your direction.")
            eq.set_timer("malletboom", 4000)
        end
        eq.set_timer("mallet", 35000)
    elseif e.timer == "malletboom" then
        if lob_target then
            local v = eq.get_entity_list():GetClientByID(lob_target)
            if v and v.valid and v:GetHPRatio() > 0 then
                eq.zone_emote(13, "Breakneck's mallet slams down on " .. v:GetCleanName() .. "!")
                mmm.raw_damage(e.self, { v }, 50000, 28)
            end
            lob_target = nil
        end
    elseif e.timer == "charge" then
        local t = alive(300)
        if #t > 0 then
            local v = t[math.random(#t)]
            charge_target = v:GetID()
            eq.zone_emote(15, "Breakneck locks eyes with " .. v:GetCleanName() .. " and stomps at the metallic tiles with his hooves. He's about to charge!")
            v:Message(13, "Breakneck is charging directly at YOU -- run!")
            eq.set_timer("chargehit", 5000)
        end
        eq.set_timer("charge", 55000)
    elseif e.timer == "chargehit" then
        if charge_target then
            local v = eq.get_entity_list():GetClientByID(charge_target)
            if v and v.valid and v:GetHPRatio() > 0 then
                eq.zone_emote(13, "Breakneck catches " .. v:GetCleanName() .. "! The crash of impact tears through everyone nearby.")
                mmm.raw_damage(e.self, mmm.alive_clients(v:GetX(), v:GetY(), 40), 50000, 28)
            end
            charge_target = nil
        end
        eq.zone_emote(15, "Breakneck, Master at Arms pauses to catch his breath.")
    end
end

function event_death_complete(e)
    engaged = false
    mmm.clear_list(adds)
    adds = {}
    for _, t in ipairs({ "wave", "mallet", "malletboom", "charge", "chargehit" }) do eq.stop_timer(t) end
    mmm.spawn_chest(e.self, SIG)
    mmm.signal(SIG)
    eq.zone_emote(15, "Breakneck, Master at Arms crashes to the floor. His chest clatters open.")
end
