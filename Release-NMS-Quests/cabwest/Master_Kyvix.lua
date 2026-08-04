function event_say(e)
    -- Get raw faction level (1 = ally ... 5 = neutral/indifferent ... higher = worse)
    local fac = e.other:GetFaction(e.self)
    local bucket = tonumber(e.other:GetBucket("Skull_Cap")) or 0
    local msg = e.message:lower()

    -- Low-faction or neutral players get a dismissive greeting
    if fac > 4 then
        if msg:find("hail") then
            e.self:Say("Begone, scum! I have no time for traitors and heretics.")
        end
        return
    end

    -- Fac == 5 (if you really need a special case for exactly 5)
    if fac == 5 then
        if msg:find("hail") then
            e.self:Say("Quite busy!! Quite busy!! Things must be done. I have no time for you!!")
        end
        return
    end

    -- Now handle quest stages by bucket
    if bucket == 0 or bucket == 1  then
        if msg:find("hail") then
            e.self:Say("Quite busy!! Quite busy!! Things must be done. See Master Xydox if you wish to help!!")
        end

    elseif bucket == 2 then
        if msg:find("hail") then
            e.self:Say("Quite busy!! Quite busy!! Things must be done. See Master Rixiz if you wish to help!!")
        end
    elseif bucket == 3 then
        if msg:find("hail") then
            e.self:Say("Quite busy!! Quite busy!! Things must be done. [New components] to be collected!!")
        elseif msg:find("new components") then
            e.self:Say("Yes, yes!! I will need components from beyond the gates. I must find an [apprentice of the third rank].")
        elseif msg:find("apprentice of the third rank") then
            e.self:Say("If you truly be an apprentice of the third circle, then there is a Dark Binder skullcap to be earned. Take this sack and fill it with a creeper cabbage, a heartsting telson with venom, brutling choppers and a scalebone femur. When they are combined within the sack, you may return it to me with your third rank skullcap and we shall bid farewell to the title, apprentice.")
            if not e.other:HasItem(17024) then
                e.other:SummonItem(17024)  -- Brood Sack
            end
        end
    elseif bucket == 4 then
        -- Bucket 4: breadcrumb and true mission
        if msg:find("hail") then
            e.self:Say("Ah, you have returned. When you are ready, ask me about your [true mission].")
        elseif msg:find("true mission") then
            e.self:Say("I have been waiting for a Nihilist to return. His name was Ryx and I fear his love of ale and the high seas has kept him from his mission. All I want you to do is find him. He should be disguised as a worker and he will give you a tome to bring to me. Return it with your Dark Binder Cap. I am sure that is simple enough for one as simple as you. Be sure to give him this.")
            if not e.other:HasItem(12848) then
                e.other:SummonItem(12848)  -- A Spectacle
            end
        end
    elseif bucket == 5 then
        if msg:find("hail") then
            e.self:Say("I did not expect you to return. You have made me lose a bet with one of the other scholars. Seeing as you have completed the tasks, I shall not harm you but rather welcome you into the rank of occultist. Now go see Keeper Rott and tell him you are [the chosen occultist].")
        end
    elseif bucket == 6 then
        if msg:find("hail") then
	    e.self:Say("Welcome, Revenant " .. e.other:GetName() .. ". The Harbinger awaits you. He seeks a [new revenant].");
        end
    elseif bucket == 7 then
        if msg:find("hail") then
            e.self:Say("Welcome Sorcerer. There is nothing more we can do for you here. Perhaps you should seek an outcast who hides as a hermit.")
        end
    elseif bucket == 8 then
        if msg:find("hail") then
            e.self:Say("Welcome Necromancer. There is only one who can help you advance in the dark art... Ixpacan")
        end
    end

end

function event_trade(e)
	local item_lib	= require("items");
	local faction	= e.other:GetFaction(e.self) <= 4
	if faction and e.other:GetBucket("Skull_Cap") == "3" and item_lib.check_turn_in(e.trade, {item1 = 12420, item2 = 4262}) then -- Items: full component sack, apprentice skullcap
		e.self:Say("You have taken far too long!! Already another apprentice has performed this task. You will still be rewarded with the Dark Binder skullcap, but now you must aid in a [true mission].");
		e.other:QuestReward(e.self,{exp = 200, gold = 15});
		e.other:SummonItem(4263);				-- Item: Dark Binder Skullcap
		e.other:Faction(441,2);					-- Faction: Legion of Cabilis
		e.other:Faction(443,10);				-- Faction: Brood of Kotiz
		e.other:SetBucket("Skull_Cap", "4");	-- Skullcap 4 is completed.
	elseif faction and e.other:GetBucket("Skull_Cap") == "4" and item_lib.check_turn_in(e.trade, {item1 = 18065, item2 = 4263}) then -- Items: a journal and dark binder skullcap
		e.self:Say("I did not expect you to return. You have made me lose a bet with one of the other scholars. Seeing as you have delivered the tome, I shall not harm you, but rather welcome you into the rank of occultist. Now go see Keeper Rott and tell him you are [the chosen occultist]");
		e.other:QuestReward(e.self,{exp = 200, gold = 20});
		e.other:SummonItem(4264);				-- Item: Occultist Skullcap
		e.other:Faction(441,2);					-- Faction: Legion of Cabilis
		e.other:Faction(443,10);				-- Faction: Brood of Kotiz
		e.other:SetBucket("Skull_Cap", "5");	-- Skullcap 5 is completed.
	elseif faction and e.other:GetBucket("Skull_Cap") == "5" and item_lib.check_turn_in(e.trade, {item1 = 12853, item2 = 12852, item3 = 4264}) then -- Items: Stem of Candlestick, Foot of Candlestick, occultist skullcap
		e.self:Emote("grabs the candle parts and puts them in an odd pouch, then takes your cap which disintegrates in his palm. He hands you another cap.");
		e.self:Say("Welcome, Revenant " .. e.other:GetName() .. ". You have done well. The Harbinger awaits you. He seeks a [new revenant].");
		e.other:QuestReward(e.self,{exp = 200, gold = 6});
		e.other:SummonItem(4265);				-- Item: Revenant Skullcap
		e.other:Faction(441,2);					-- Faction: Legion of Cabilis
		e.other:Faction(443,10);				-- Faction: Brood of Kotiz
		e.other:SetBucket("Skull_Cap", "6");	-- Skullcap 6 is completed.
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
