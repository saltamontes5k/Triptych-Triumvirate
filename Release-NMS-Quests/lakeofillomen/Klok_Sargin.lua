--Shaman Cudgel Quest 6

function event_say(e)
	local Shaman_Cudgel_Progress	= e.other:GetBucket("Shaman_Cudgel")

	if e.other:GetFaction(e.self) <= 4 and Shaman_Cudgel_Progress == "6.1" then
		if e.message:findi("Sisters of Scale") then
			e.self:Say("Looking for the skull I had for sale? I am afraid I sold it to a staunch lizard champion. I would gladly give you his name if you would do me a [slight favor].");
		elseif e.message:findi("slight favor") then
			e.self:Say("The lake garrison has requested that I work on a helm similar to the ones worn by sarnak dragoons. The problem is.. I need one to examine. You go get me one and I will tell you who purchased the skull.");
		end
	end
end

function event_trade(e)
	local item_lib					= require("items");
	local Shaman_Cudgel_Progress	= e.other:GetBucket("Shaman_Cudgel")

	if e.other:GetFaction(e.self) <= 5 and Shaman_Cudgel_Progress == "6.1" and e.other:GetFaction(e.self) <= 5 and item_lib.check_turn_in(e.trade, {item1 = 12761}) then -- Item: Sarnak Dragoon Helm
		e.self:Say("Uhh. Thanks. I sort of told the lizard who bought the skull that you were asking for him, and, well, he was kinda mad, and... " .. e.other:GetCleanName() .. ", meet Bruiser.");
		eq.unique_spawn(85226,0,0,e.self:GetX() + 5,e.self:GetY(),e.self:GetZ(),e.self:GetHeading()); -- NPC: Bruiser Noz

	end
	item_lib.return_items(e.self, e.other, e.trade);
end

function event_signal(e)
	e.self:Emote("shakes with fear. A dark stain begins to spread across the front of his trousers. 'Ye.. Ye.. Yes.. Yes, Bruiser.");
	eq.signal(85226,51); -- NPC: Bruiser_Noz
end
