--Quest: Deepspores
--Quest: Bridge Escort
local invis_bridge  = false;
local beacon_npc    = 164124;

function event_say(e)
    local is_gm = (e.other:Admin() > 80 and e.other:GetGM());

    if  e.message:findi("go") and is_gm then -- Debug
		e.self:SetRunning(true);
        e.self:SetGrid(11);
        eq.start(11);
    elseif e.message:findi("hail") and invis_bridge then
        e.self:Emote("puts his hand over your mouth. 'Shuuuush! You may not be afraid of any of these beasties, but there's no reason to make all this noise and make them come running!'");
    elseif e.message:findi("hail") then
        e.self:Emote("eyes you suspiciously. His beard is tangled in completely impossible knots, and you wonder very much if he has ever seen fresh water in his life. He seems to be completely oblivious of the small insects that crawl freely across his tattered clothing. He speaks to you in a low growl. 'Go away! I don't like being bothered! Your making too much noise! The horrors will hear you and then I'll have to [" .. eq.say_link("move again") .. "]!'");
    elseif e.message:findi("move again") then
        e.self:Emote("glares at you. 'You're really out to get me killed aren't you? How am I supposed to find [" .. eq.say_link("deep spores") .. "] with you thrashing about waking up the beasties and scaring all the shriekers!'");
    elseif e.message:findi("deep spores") then
        e.self:Say("Never heard of deep spores have you? Well if you're going to be spending some time down here you'd best learn quickly. Deepspores are the only thing edible in this cavern. Most of the mushrooms down here will sooner eat you then allow them selves to be eaten! The Deepspores are different though, if you cook them a bit they're the most delicious food in the universe!");
    elseif e.message:findi("chasm") then
        e.self:Emote("rolls his eyes at you. 'Hmm....I'm not sure, maybe that big gaping hole in the ground down through the second corridor! You haven't even explored yet have you. I wouldn't wander around too much unless you're feeling lucky. There's nothing the thought horrors like more than a loud obnoxious band of would be heroes that comes crashing into their home. They especially like playing with corpses of those that fall through that fake bridge out there.'");
    elseif e.message:findi("fake bridge") then
        e.self:Say("Yes that bridge out there is fake, I'm sure more than a few of your kind will end up falling straight through it like lemmings. I'll be taking the safe route thank you very much. Just have to be careful about sneaking past all the beasties. Somehow I doubt you'd make it past any of them as careless as you prance around. Few can face the thought horrors and get away with their sanity. I'm one of the lucky ones, yup!");
    elseif e.message:findi("thought horrors") then
        e.self:Emote("laughs uncontrollably. When he finally regains his composure he looks at you and says, 'All right chief, if you can prove to me that you can stand up to horrors then I'll show you the way across the chasm. Bring me 2 thought horror tentacles and that hunk of rock I gave you and we'll see about getting you across that bridge. Oh and by the way, since you're so full of energy, go run to shadowhaven and bring me back some Deep Cavern Bourbon along with those tentacles.'");
    end
end

function event_waypoint_arrive(e)
    local x,y,z,h = e.self:GetX(), e.self:GetY(), e.self:GetZ(), e.self:GetHeading();
    local grid = e.self:GetGrid()

    if e.wp == 1 and grid == 11 then --#2 on Grid 11
        e.self:Say("Well here's the chasm I told you about. Seeing as how you're not very quick, I'd expect you to go barreling across that bridge over there at full speed! That'd get you killed in a hurry. I'm sure the mushrooms would enjoy feeding off of your remains though. Hurry up there now! We haven't got all day!");
    elseif e.wp == 2 and grid == 11 then -- #3 on Grid 11
        eq.spawn2(beacon_npc,0,0,x, y, z, h); -- a_beacon, #3 on Grid 11
        --Kludging this to spawn the beacons on the bridge instead of him spawning as he goes since pathing across invis bridge is AWFUL
        eq.spawn2(beacon_npc,0,0, 631, 160, -68, 0); -- a_beacon, #4 on Grid 11
        eq.spawn2(beacon_npc,0,0, 774, 213, -68, 0); -- a_beacon, #5 on Grid 11
        eq.spawn2(beacon_npc,0,0, 914, 263, -68, 0); -- a_beacon, #6 on Grid 11
        eq.spawn2(beacon_npc,0,0, 1023, 301, -68, 0); -- a_beacon, #7 on Grid 11
        eq.spawn2(beacon_npc,0,0, 1120, 340, -63, 0); -- a_beacon, #8 on Grid 11
        e.self:Say("Here's where you'll have to trust me friend. Just stay close to me and you'll be fine. And be QUIET! The beasties on the other side aren't nearly as pleasant as the ones over here.");
    elseif e.wp == 3 and grid == 11 then
        eq.spawn2(beacon_npc,0,0,x, y, z, h);
    elseif e.wp == 4 and grid == 11 then
        eq.spawn2(beacon_npc,0,0,x, y, z, h);
    elseif e.wp == 5 and grid == 11 then
        eq.spawn2(beacon_npc,0,0,x, y, z, h);
    elseif e.wp == 6 and grid == 11 then
        eq.spawn2(beacon_npc,0,0,x, y, z, h);
    elseif e.wp == 7 and grid == 11 then
        eq.spawn2(beacon_npc,0,0,x, y, z, h);
        e.self:Say("Well here you are, the other side of the chasm. This is where I leave you, I need to take care of some things over here. I'm sure you'll be just fine as long as you stay quiet. Good luck to you friend.");
        invis_bridge = true;
        eq.set_timer('depop', 120 * 1000);
    end
end

function event_combat(e)
    if e.joined then
        eq.stop_timer('depop');
    else
        eq.set_timer('depop', 60 * 1000);
    end
end

function event_timer(e)
    if e.timer == 'depop' then
        eq.depop_with_timer();
    end
end

function event_trade(e)
	local item_lib = require("items");
    if item_lib.check_turn_in(e.trade, {item1 = 32400, item2 = 32400, item3 = 32400, item4 = 32400}) then -- Items: x4 Deepspore
        e.self:Emote("eyes the spores hungrily. He shoves them all in his pockets and looks at you. 'I appreciate that friend, you've proven yourself worth a bit of trust. I hate to take the mushrooms and run, but I have to get across the [" .. eq.say_link("chasm") .. "] soon. Here take this, thanks for the mushrooms!'");
        e.other:QuestReward(e.self,0,0,0,0,32402,100); -- Item: Fungus-covered hunk of rock
        e.other:Faction(1569,2,0); -- Faction: Deklean Korgad
    elseif item_lib.check_turn_in(e.trade, {item1 = 32402, item2 = 32401, item3 = 32401, item4 = 22170}) then -- Items: Fungus-covered hunk of rock, 2x Thought Horror Tentacle, Deep Cavern Bourbon
        e.self:Say("Well I'm impressed " .. e.other:GetName() .. ", you actually went up against some terrors and won. I'll keep my part of the bargain and show you across the chasm. I'm warning you though, this side of the cave is a candy shop compared to the far side. Anyhow, follow me and we'll make our way there.I'm sure you'll be able to dispatch anything we run into on the way, seeing as how you're an accomplished horror slayer!");
        e.other:QuestReward(e.self,0,0,0,0,0,100);
        e.other:Faction(1569,1,0); -- Faction: Deklean Korgad
        e.self:SetGrid(11);
        eq.start(11);
    end
	item_lib.return_items(e.self, e.other, e.trade)
end
