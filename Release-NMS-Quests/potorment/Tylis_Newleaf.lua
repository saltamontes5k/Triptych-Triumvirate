function event_say(e)
	local shadyglade_bucket = tonumber(e.other:GetAccountBucket("pop.flags.shadyglade")) or 0
	if e.message:findi("Hail") then
		if shadyglade_bucket == 1 then
			local will_assist_you = eq.silent_say_link("will assist you", "will you assist")
			e.self:Say(
				string.format(
					"...help ...end this torment ...will you come? I can show you the pain... it moves in the shadows of my mind... [%s] me?",
					will_assist_you
				)
			)
		else
			e.self:Say(
				string.format(
					"...help ...end this torment ...will you come? I can show you the pain... it moves in the shadows of my mind... Fahlia... help me?"					
				)
			)
		end
	elseif e.message:findi("will assist you") then
		if (e.other:KeyRingCheck(22954) or e.other:HasItem(22954)) and shadyglade_bucket == 1 then
			e.self:Say("I do not know if I have enough energy to channel all of you, but I can try. I will channel you into my pain.")
			if e.other:IsGrouped() then
				local group = e.other:GetGroup()
				if group then
					local member_count = group:GroupCount()
					for i = 0, member_count - 1 do
						local member = group:GetMember(i)
						if member ~= nil and member:IsClient() then
							local client = member:CastToClient();
						    client:MovePCInstance(207, eq.get_zone_instance_id(), -175, 815, -955,0)
						end
					end
				end
			else
				e.other:MovePCInstance(207, eq.get_zone_instance_id(), -175, 815, -955,0)
			end
		end
	end
end

function event_signal(e)
	if e.signal == 0 then 
		eq.depop_all(207014)
	end
end
