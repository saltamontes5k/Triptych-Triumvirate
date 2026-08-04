local delivery = 0
local bandit1id = 56178
local bandit2id = 56179
local bandit3id = 56180

function event_spawn(e)
    eq.set_timer("CargoTimer", 5000)
end

function event_signal(e)
    e.self:Emote("Chuga.. Chug..Chug..")
    e.self:Say("This unit requires maintenance.")
end

function event_timer(e)
    local x = e.self:GetX()
    local y = e.self:GetY()
    local zone_hour = eq.get_zone_time().hour
    local qglobals = eq.get_qglobals()

    if qglobals["CargoClockwork"] == nil and zone_hour == 8 then
        eq.set_global("CargoClockwork", "1", 1, "H2")
        e.self:Start(177) -- path to windmills
    end

    if x == 700 and y == -1783 and delivery == 1 then
        e.self:Stop()
        delivery = 0
    end

    if x == 550 and y == -830 then
        e.self:Say("kachunk .. kachunk..")
        eq.signal(56066, 1) -- Watchman Grep
    end

    if x == 90 and y == -700 and delivery == 0 then
        delivery = 1
        e.self:Emote("Chuga.. Chug..Chug..")
        e.self:Emote("The chugging of the Cargo Clockwork comes to a halt.")

        local bandit1 = eq.spawn2(bandit1id, 0, 0, 30, -700, -109, 124) -- Hector
        local bandit1npc = eq.get_entity_list():GetMob(bandit1):CastToNPC()
        bandit1npc:AddToHateList(e.self, 1)

        local bandit2 = eq.spawn2(bandit2id, 0, 0, 95, -732, -108, 480) -- Renaldo
        local bandit2npc = eq.get_entity_list():GetMob(bandit2):CastToNPC()
        bandit2npc:AddToHateList(e.self, 1)

        local bandit3 = eq.spawn2(bandit3id, 0, 0, 53, -615, -107, 226) -- Jerald
        local bandit3npc = eq.get_entity_list():GetMob(bandit3):CastToNPC()
        bandit3npc:AddToHateList(e.self, 1)

        e.self:Say("This is highway robbery.")
    end

    local target = e.self:GetTarget()
    if target and string.find(target:GetCleanName():lower(), "highway_bandit") then
        e.self:WipeHateList()
    end
end

function event_death_complete(e)
    eq.stop_timer("CargoTimer")
    delivery = 0
    eq.signal(bandit1id, 0)
    eq.signal(bandit2id, 0)
    eq.signal(bandit3id, 0)
end
