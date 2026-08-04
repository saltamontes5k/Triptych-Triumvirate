-- Dimaal the Spiritmaster (224115)

-- Variables

local event_started = false;
local wave = 0;
local difficulty = 0;

local mob_xloc = { 1107,  1076,  1004,   963,   941,   959,  1034,  1112,  1116};
local mob_yloc = {-2526, -2470, -2458, -2526, -2582, -2640, -2640, -2599, -2545};
local mob_zloc = {  -42,   -44,   -40,   -42,   -47,   -44,   -44,   -45,   -43};
local mob_hloc = {  355,   297,   237,   161,   104,    55,   508,   427,   384};

-- 1 = Easy Event, 2 = Medium Event, 3 = Hard Event
local event_mobs  = {
    [1] = {     224445, -- a_doomed_partisan (30) Warrior
                224445, -- a_doomed_partisan (30) Warrior
                224445, -- a_doomed_partisan (30) Warrior
                224445, -- a_doomed_partisan (30) Warrior
                224445, -- a_doomed_partisan (30) Warrior
                224445, -- a_doomed_partisan (30) Warrior
                224446,	-- a_doomed_sorcerer (30) Wizard
                224447,	-- a_doomed_curate (30) Wizard
                224444	-- Simati_the_Cursed (38) Shaman ##Named
    },
    [2] = {     224437, -- a_cursed_conscript (36) Warrior
                224437, -- a_cursed_conscript (36) Warrior
                224437, -- a_cursed_conscript (36) Warrior
                224437, -- a_cursed_conscript (36) Warrior
                     0, -- dummy mob
                     0, -- dummy mob
                224440, -- a_cursed_vicar (36) Cleric
                224441, -- a_cursed_magus (36) Wizard
                224448 	-- Tagai_Darkheart (48) Shaman ##Named
    },
    [3] = {     224438, -- a_fallen_knight (40) Warrior
                224438, -- a_fallen_knight (40) Warrior
                224438, -- a_fallen_knight (40) Warrior
                224438, -- a_fallen_knight (40) Warrior
                224438, -- a_fallen_knight (40) Warrior
                224438, -- a_fallen_knight (40) Warrior
                224442,	-- a_fallen_priest (40) Cleric
                224443,	-- a_fallen_thaumaturge (40) Wizard
                224439 	-- Phizan_Crindo (46) Shaman ##Named
    }
}

function event_spawn(e)
    wave = 0;
    event_started = false;
end

-- Say Block
function event_say(e)
    if e.message:findi("Hail") then
        e.self:Say("Ahh a visitor, I see? Welcome to the Cave of the Damned. I am the keeper of these caves, and I have been charged with holding the spiritual [" .. eq.say_link("What manifestations?", false, "manifestations") .. "] at bay. Many bloody battles have been fought on the shores of Gunthak, many more battles will be fought here.");
    elseif e.message:findi("manifestations") then
        e.self:Say("Most of the spirits that perish on the beach move on to the next world, though a few remain bound to their ships or comrades and remain on the shore. Every once in a great while, however, a spirit breaks its bond to the beach and is drawn to this cave. There is magic in this cave, dark magic. The spirits that find their way here draw power from the magic in the caves. I assure that the spirits that find their way here remain contained in the cave, along with their [" .. eq.say_link("What treasures?", false, "treasures") .. "].");
    elseif e.message:findi("treasures") then
        e.self:Say("I figured that would pique your interest. A few of the spirits here managed to retain a portion of their material possessions. If you wish, I can channel the spirits into a form where you may request their treasures. Of course, there is a [" .. eq.say_link("What is the price?", false, "price") .. "].");
    elseif e.message:findi("price") then
        e.self:Say("Finger bones. There is strong magic in the bones of our fingers, and I use such bones to summon the spirits, as well as keep them bound to this cave. Bring me four identical finger bones, the better condition the bones are in, the stronger the spirits I call will be.");
    end
end

-- Trade Block
function event_trade(e)
    local item_lib = require("items");

    if not event_started then
        if item_lib.check_turn_in(e.trade, {item1 = 56001,item2 = 56001,item3 = 56001,item4 = 56001}) then -- Cracked Finger Bone x4 (Easy)
            e.self:Say("'The spirits shall come. Ready yourselves.'");
            event_started = true;
            wave = 1;
            difficulty = 1;
            eq.set_timer('Event', 6 * 1000); -- 6s
        elseif item_lib.check_turn_in(e.trade, {item1 = 56002,item2 = 56002,item3 = 56002,item4 = 56002}) then -- Broken Finger Bone x4 (Medium)
            e.self:Say("'The spirits shall come. Ready yourselves.'");
            event_started = true;
            wave = 1;
            difficulty = 2;
            eq.set_timer('Event', 6 * 1000); -- 6s
        elseif item_lib.check_turn_in(e.trade, {item1 = 56003,item2 = 56003,item3 = 56003,item4 = 56003}) then -- Pristine Finger Bone x4 (Hard)
            e.self:Say("'The spirits shall come. Ready yourselves.'");
            event_started = true;
            wave = 1;
            difficulty = 3;
            eq.set_timer('Event', 6 * 1000); --6s
        end
    else
        e.self:Say("'The spirits are busy. Your time will come.'");
    end
    item_lib.return_items(e.self, e.other, e.trade)
end

-- Timers (in ms)
function event_timer(e)
    if e.timer == "Event" then
        for difficulty_level, mobs in pairs(event_mobs) do
            if difficulty == difficulty_level then
                for n = 1, 9 do
                    if wave == 4 then -- Wave = 4 Spawn 8 trash and one named
                        spawn_mob(mobs[n],n);
                    elseif wave <= 3 and n <= 8  then -- Wave <=3 only spawn first 8 mobs (No Name)
                        spawn_mob(mobs[n],n);
                    end
                end

                if wave <= 3 then
                    eq.set_timer('Event', 10 * 60 * 1000) -- 10 minutes between waves
                    wave = wave + 1;
                else
                    eq.stop_timer(e.timer)
                end
            end
        end
    end
end

-- Spawn mob by NPCID and LOC from table
function spawn_mob(NPCID, loc)
    eq.spawn2(NPCID, 0, 0, mob_xloc[loc], mob_yloc[loc], mob_zloc[loc], mob_hloc[loc]);
end

-- Receive signal from another NPC
function event_signal(e)
    if e.signal == 1 then
        e.self:Say("You seem to have this situation under control. I will depart now. Best of luck.");
        eq.depop_with_timer();
    elseif e.signal == 2 then
        e.self:Say("It seems one of the spirits has fled, I am afraid I must leave to meditate so the spirit does not make its way through my defenses.");
        eq.depop_with_timer();
    end
end