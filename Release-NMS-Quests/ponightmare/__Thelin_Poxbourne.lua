function event_spawn(e)
	eq.set_timer("Depop", 600 * 1000) -- 10 Minutes
	eq.set_timer("Emote 1", 6 * 1000) -- 6 Seconds
	eq.set_timer("Emote 2", 12 * 1000) -- 12 Seconds
	eq.set_timer("Emote 3", 18 * 1000) -- 18 Seconds
end

function event_timer(e)
	if e.timer == "Depop" then
		eq.stop_timer("Depop")
		eq.depop()
	elseif e.timer == "Emote 1" then
		eq.stop_timer("Emote 1")
		e.self:Say("Terris, hear me now!  I have done as you asked.  My beloved dagger is whole once again!  Now keep up your part of the bargain.")
		eq.signal(204065, 1, 0) -- #Terris_Thule
	elseif e.timer == "Emote 2" then
		eq.stop_timer("Emote 2")
		e.self:Say("Vile wench, I knew in the end it would come to this.  You shall pay dearly for your injustice here.")
		eq.signal(204065, 2, 0) -- #Terris_Thule
	elseif e.timer == "Emote 3" then
		eq.stop_timer("Emote 3")
		e.self:Say("So then my hope is nearly lost.  Take my dagger with you and plunge it deep into her soulless heart.  If I cannot escape from this forsaken plane under her rules, I shall make my own!")
	end
end

function event_say(e)
	local construct_bucket = tonumber(e.other:GetAccountBucket("pop.flags.construct")) or 0
	if e.message:findi("Hail") then
		if construct_bucket == 0 and tostring(eq.get_zone_instance_version()) == eq.get_rule("Custom:StaticInstanceVersion") then -- Only flag in non-respawning dz
			e.other:Message(MT.White, "Thelin Poxbourne tells you, 'Please destroy her for subjecting me to her hideous visions.'  Thelin closes his eyes and is swept away from his nightmare.  The land of pure thought begins to vanish from around you.")
			e.other:SetAccountBucket("pop.flags.construct", "1")
			e.other:Message(MT.LightBlue, "You receive a character flag!")
		else
			local return_link = eq.silent_say_link("return")
			e.self:Say(
				string.format(
					"It looks like we've already spoken, would you like to [%s]?",
					return_link
				)
			)
		end
	elseif e.message:findi("return") then
		e.other:MovePCInstance(204, eq.get_zone_instance_id(), -1520, 1104, 125, 0)
	end
end

function event_trade(e)
	local item_lib = require("items");
	if(item_lib.check_turn_in(e.trade, {item1 = 9258})) then -- # Handin: Dagger Blade Shard 
		e.self:Emote("takes the shard from you and places all of the pieces on the ground. The pieces reassemble and fuse back together into a completed dagger. Thelin picks the dagger up and hands it to you.")
		e.other:SummonItem(9259) -- #Thelin's Dagger
		eq.spawn2(204065,0,0,-4554,5018,5,260); -- # NPC: #Terris_Thule

		if e.other:IsGrouped() then
			local group = e.other:GetGroup()
			local member_count = group:GroupCount()
			for i = 0, member_count - 1 do
				local member = group:GetMember(i)
				if member ~= nil and member.valid and member:IsClient() then
					if tostring(eq.get_zone_instance_version()) == eq.get_rule("Custom:StaticInstanceVersion") then -- Only flag in non-respawning dz
						local construct_bucket = tonumber(e.other:GetAccountBucket("pop.flags.construct")) or 0
						if construct_bucket == 0 then
							local member_client = member:CastToClient();
							member_client:SetAccountBucket("pop.flags.construct", "1")
							member_client:Message(MT.LightBlue, "You receive a character flag!")
						end
					end
				end
			end
		end
	end

	item_lib.return_items(e.self, e.other, e.trade);
end
