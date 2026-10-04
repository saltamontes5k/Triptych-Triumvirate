-- [[
-- Tactical Prototype XXVII (460520) -- MMM event 2, the Battle Room.
-- Rasper: raidMMM.html stage 2.
--   * rooted; Steam Blast PBAE (~8k + dot) all event
--   * 90%: six colour steamdrones; colour pressure drives effects
--       white=regen  black=flaming oil  red=flurry  yellow=stance
--       green=adds   blue=Zot frequency
--   * 75%: four engineers try to move drones back
--   * 50%: Zot on five players, spreads to neighbours if not isolated
-- On death: Treasure_of_the_Battle_Room (460581) + controller signal.
-- Simplifications: valve objects and drone tile mathematics are approximated
-- by the colour pressure timer; blinding engineers is not enforced.
-- ]]

local mmm = require("sof_mmm_raid")

local SIG = 2002
local DRONE, ENGINEER, ADD = mmm.NPC.drone, mmm.NPC.engineer, mmm.NPC.grinder_trooper
local MY_X, MY_Y, MY_Z = -70, 1525, 678.05
local COLORS = { "white", "black", "red", "yellow", "green", "blue" }

local engaged, started, eng_started, zot_started = false, false, false, false
local adds = {}
local zot_marked = {}

local function alive(r)
    return mmm.alive_clients(MY_X, MY_Y, r or 375)
end

local function spawn_drones()
    for i, col in ipairs(COLORS) do
        local ang = (i - 1) * math.pi / 3
        local d = eq.spawn2(DRONE, 0, 0, MY_X + math.cos(ang) * 40, MY_Y + math.sin(ang) * 40, MY_Z, 0)
        if d then
            d:SetEntityVariable("color", col)
            adds[#adds + 1] = d:GetID()
        end
    end
end

local function spawn_engineers()
    for i = 1, 4 do
        local ang = (i - 1) * math.pi / 2
        local e = eq.spawn2(ENGINEER, 0, 0, MY_X + math.cos(ang) * 55, MY_Y + math.sin(ang) * 55, MY_Z, 0)
        if e then adds[#adds + 1] = e:GetID() end
    end
    eq.zone_emote(15, "Four engineers stride onto the dance floor, dragging the drones toward forbidden colours!")
end

local function colour_pressure(self)
    -- count living drones per colour
    local counts = {}
    local el = eq.get_entity_list()
    for _, id in ipairs(adds) do
        local d = el:GetNPCByID(id)
        if d and d.valid and d:GetNPCTypeID() == DRONE and d:GetHPRatio() > 0 then
            local col = d:GetEntityVariable("color")
            if col and col ~= "" then counts[col] = (counts[col] or 0) + 1 end
        end
    end
    -- the colour with the most drones dominates the next window
    local best, bestn = "blue", 1
    for _, col in ipairs(COLORS) do
        if (counts[col] or 0) > bestn then best, bestn = col, counts[col] end
    end

    if best == "white" then
        eq.zone_emote(15, "White steam pours over the prototype, knitting its plating.")
        pcall(function() self:SetHP(math.min(self:GetMaxHP(), self:GetHP() + math.floor(self:GetMaxHP() * 0.03))) end)
    elseif best == "black" then
        eq.zone_emote(15, "Black steam builds to a head -- Flaming Oil erupts!")
        mmm.raw_damage(self, alive(375), 8000, 2)
    elseif best == "red" then
        eq.zone_emote(15, "Red steam drives the prototype into a frenzy!")
    elseif best == "yellow" then
        eq.zone_emote(15, "The prototype shifts its stance.")
    elseif best == "green" then
        eq.zone_emote(15, "Green steam floods the vents -- reinforcements clank in!")
        for _ = 1, 2 do
            local m = eq.spawn2(ADD, 0, 0, MY_X + math.random(-40, 40), MY_Y + math.random(-40, 40), MY_Z, 0)
            if m then
                adds[#adds + 1] = m:GetID()
                local t = alive(375)
                if #t > 0 then m:AddToHateList(t[math.random(#t)], 1000, 10000) end
            end
        end
    else -- blue
        eq.zone_emote(15, "Blue steam whines -- the prototype readies Zot.")
        if not zot_started then
            zot_started = true
            eq.set_timer("zot", 20000)
        end
    end
end

local function steam_blast(e)
    eq.zone_emote(15, "Steam Blast erupts from the prototype!")
    mmm.raw_damage(e.self, alive(375), 8000, 28)
end

function event_combat(e)
    if e.joined then
        if not engaged then
            engaged = true
            eq.set_timer("blast", 25000)
            eq.set_timer("phasecheck", 5000)
        end
        eq.stop_timer("resetcheck")
    else
        eq.set_timer("resetcheck", 60000)
    end
end

function event_timer(e)
    if e.timer == "resetcheck" then
        if not e.self:IsEngaged() then
            engaged, started, eng_started, zot_started = false, false, false, false
            mmm.clear_list(adds); adds = {}
            for _, t in ipairs({ "blast", "phasecheck", "colour", "zot" }) do eq.stop_timer(t) end
            e.self:Heal()
            eq.zone_emote(15, "The Battle Room powers down. The prototype resets its tiles.")
        end
        return
    end
    if not engaged then return end

    if e.timer == "blast" then
        steam_blast(e)
        eq.set_timer("blast", 25000)
    elseif e.timer == "phasecheck" then
        local hp = e.self:GetHPRatio()
        if not started and hp <= 90 then
            started = true
            spawn_drones()
            eq.zone_emote(15, "Six colour steamdrones drift onto the dance floor. The tiles begin to glow.")
            eq.set_timer("colour", 30000)
        end
        if started and not eng_started and hp <= 75 then
            eng_started = true
            spawn_engineers()
        end
        if started and not zot_started and hp <= 50 then
            zot_started = true
            eq.set_timer("zot", 15000)
        end
        eq.set_timer("phasecheck", 5000)
    elseif e.timer == "colour" then
        colour_pressure(e.self)
    elseif e.timer == "zot" then
        -- Zot on five players; spreads if an afflicted player is near another
        local t = alive(375)
        local n = math.min(5, #t)
        zot_marked = {}
        for i = 1, n do
            local v = t[math.random(#t)]
            if v then
                zot_marked[v:GetID()] = true
                v:Message(13, "ZOT! Get away from the raid before it spreads!")
                pcall(function() v:Damage(e.self, 8000, 0, 28); v:Stun(5000) end)
            end
        end
        eq.zone_emote(15, "Zot arcs between five of your number!")
        eq.set_timer("zotspread", 6000)
    elseif e.timer == "zotspread" then
        local el = eq.get_entity_list()
        local spread = {}
        for id in pairs(zot_marked) do
            local v = el:GetClientByID(id)
            if v and v.valid and v:GetHPRatio() > 0 then
                for _, c in ipairs(mmm.alive_clients(v:GetX(), v:GetY(), 30)) do
                    if not zot_marked[c:GetID()] then spread[c:GetID()] = true end
                end
            end
        end
        local cnt = 0
        for id in pairs(spread) do
            local c = el:GetClientByID(id)
            if c and c.valid and c:GetHPRatio() > 0 then
                cnt = cnt + 1
                c:Message(13, "Zot spreads to you! Run!")
                pcall(function() c:Damage(e.self, 8000, 0, 28); c:Stun(5000) end)
            end
        end
        if cnt > 0 then
            eq.zone_emote(15, "Zot chains to " .. cnt .. " more!")
            zot_marked = spread
            eq.set_timer("zotspread", 6000)
        else
            zot_marked = {}
            eq.set_timer("zot", 30000)
        end
    end
end

function event_death_complete(e)
    engaged = false
    mmm.clear_list(adds); adds = {}
    for _, t in ipairs({ "blast", "phasecheck", "colour", "zot", "zotspread" }) do eq.stop_timer(t) end
    mmm.spawn_chest(e.self, SIG)
    mmm.signal(SIG)
    eq.zone_emote(15, "The prototype collapses in a shower of gears. The Battle Room falls still.")
end
