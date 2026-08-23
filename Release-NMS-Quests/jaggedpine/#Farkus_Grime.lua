---- Quest:Paying Oracle Jaarl Respect
function event_say(e)
    if(e.message:findi("liver")) then
        e.self:Emote("clenches his teeth and speaks in a quiet but deadly tone, 'Keep your voice down you fool, mention of such a thing around here is dangerous! I'm always willing to help someone who shares the same... philosophy... as myself though. Are you [" .. eq.say_link("truly serious") .. "] about this?");
    elseif(e.message:findi("truly serious")) then
        e.self:Say("Very well, follow me and we'll have a little chat then.");
        e.self:SetGrid(256);
        eq.start(256);
    end
end

function event_waypoint_arrive(e)
    local grid = e.self:GetGrid()

    if (e.wp == 1 and grid == 256) then
        e.self:Say("You nearly blew my cover back there you idiot. Still, I shall overlook your transgression.");
    elseif (e.wp == 2 and grid == 256) then
        e.self:Say("I had not pegged you as one allied with the Plaguebringer, may his blessing once again spread across the land.");
    elseif (e.wp == 3 and grid == 256) then
        e.self:Say("So you wish for me to defile one of these so-called 'sacred' bears for you? I'm not sure what vile ritual you would need this liver for but I'd be delighted to assist you.");
    elseif (e.wp == 4 and grid == 256) then
        e.self:Say("However, before I do this thing for you there's something I need for you to do for me to show your loyalty. And to help me to settle an outstanding score of course.");
    elseif (e.wp == 5 and grid == 256) then
        e.self:Say("I want you to assassinate a Qeynos guard by the name of Nash. He has been a thorn in our side for some time. Bring me his head and I shall defile one of these bears for you.");
    elseif (e.wp == 1 and grid == 257) then
        e.self:Emote("holds a bit of food out to the bear cub, 'Want it?'");
        e.self:Say("Follow me then little bear");
        e.self:Emote("gives the bear the tainted food.");
    elseif (e.wp == 2 and grid == 257) then
        e.self:Say("The disease within this food acts very quickly. The bear should be maddened by the illness shortly and his liver suitable for harvest.");
    end
end

function event_trade(e)
    local item_lib = require("items");
    if(item_lib.check_turn_in(e.trade, {item1 = 8276})) then -- Head of Guard Nash
        e.self:Say("You've done well, I see we are of a like mind. I'll lure the bear outside so you can do your work.");
        e.other:QuestReward(e.self,0,0,0,0,0,500); -- Faction and EXP
        e.self:SetGrid(257);
        eq.start(257);
        eq.spawn2(181001,0,0,1834.97,1307.58,-12.9,18.2); -- NPC: docile bear
    end
    item_lib.return_items(e.self, e.other, e.trade)
end