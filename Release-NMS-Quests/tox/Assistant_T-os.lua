-- Quest: Luggald Flesh / Luggald Rumors

function event_say(e)
	local qglobals = eq.get_qglobals(e.self, e.other);
    local grisk_2 = e.other:GetBucket("grisk_2");
    local tsoma_2 = e.other:GetBucket("tsoma_2");

	if e.message:findi("Hail") then
        if qglobals["tsoma"] ~= nil and qglobals["tsoma"] == "2" and tsoma_2 == "" then
            e.self:Say("You're late! Never mind. Prepare yourself. I do not trust these magics T`soma has constructed.");
            e.other:SetBucket("tsoma_2", "1", "H1");
            eq.unique_spawn(38005,0,0,1630,2137,-54,270);  -- #Fleshless_Servant (Luggald Flesh Version)
        elseif qglobals["grisk"] ~= nil and qglobals["grisk"] == "2" and grisk_2 == "" then
            e.self:Say("You're late! Never mind. Prepare yourself. I do not trust these magics T`soma has constructed.");
            e.other:SetBucket("grisk_2", "1","H1");
            eq.unique_spawn(38173,0,0,1630,2137,-54,270);  -- #Fleshless_Servant (Luggald Rumors Version)
        else
            e.self:Emote("Can't you see I'm busy right now!?");
        end
	end
end

function event_trade(e)
	local item_lib = require("items");
	item_lib.return_items(e.self, e.other, e.trade)
end
