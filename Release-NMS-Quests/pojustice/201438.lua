-- 201438 Trial of Flame
-- Trial of Flame

local trial_x = 883
local trial_y = -728
local trial_z = 56

function event_say(e)
	local mavuin_bucket = tonumber(e.other:GetAccountBucket("pop.flags.mavuin")) or 0
	if mavuin_bucket == 1 then
		if e.message:findi("Hail") then
			local prepared_link = eq.silent_say_link("prepared")
			e.self:Emote(
				string.format(
					" fixes you with a dark, piercing gaze. 'What do you want, mortal? Are you [%s]?",
					prepared_link
				)
			)
		elseif e.message:findi("prepared") then
			local begin_the_trial_of_flame_link = eq.silent_say_link("begin the trial of flame")
			e.self:Say(
				string.format(
					"Very well. When you are ready, you may [%s]. You must endure the heat of the fire and be sure not to let its creatures reach the center. We shall judge the mark of your success.",
					begin_the_trial_of_flame_link
				)
			)
		elseif e.message:findi("begin the trial of flame") then
			local active_variable = tonumber(e.self:GetEntityVariable("Active")) or 0
			if active_variable == 0 then
				e.self:Say("Then begin.")

				if e.other:IsGrouped() then
					local group = e.other:GetGroup()
					local member_count = group:GroupCount()
					for i = 0, member_count - 1 do
						local member = group:GetMember(i)
						if member ~= nil and member.valid and member:IsClient() and member:CalculateDistance(e.self:GetX(), e.self:GetY(), e.self:GetZ()) <= 150 then
							local client = member:CastToClient();
							client:MovePCInstance(201, eq.get_zone_instance_id(), 937, -703, 53, 300)
						end
					end
				else
					e.other:MovePCInstance(201, eq.get_zone_instance_id(), 937, -703, 53, 300)
				end

				eq.set_timer("Start", 30 * 1000) -- 30 Seconds
				eq.signal(201417, 1, 30) -- #Event_Burning_Control
				e.self:SetEntityVariable("Active", "1")
				eq.spawn2(201417, 0, 0, 880, -729, 55, 0)
			else
				e.self:Say("I'm sorry, the Trial of Flame is currently unavailable to you.")
			end
		elseif e.message:findi("mavuin") then
			local flame_bucket = tonumber(e.other:GetAccountBucket("pop.flags.flame")) or 0
			if e.other:HasItem(31796) then
				if flame_bucket == 0 then
					e.other:SetAccountBucket("pop.flags.tribunal", "1")
					e.other:SetAccountBucket("pop.flags.flame", "1")
					e.other:Message(MT.LightBlue, "You receive a character flag!");
				else
					e.self:Say("It looks like we've already spoken.")
				end
			else
				local mark_link = eq.item_link(31796)
				e.self:Say(
					string.format(
						"You seem to be missing a %s, return to me when you acquire it.",
						mark_link
					)
				)
			end
		elseif e.message:findi("knowledge") then
			if (
				e.other:HasItem(31796) and
				e.other:HasItem(31842) and
				e.other:HasItem(31845) and
				e.other:HasItem(31846) and
				e.other:HasItem(31960)
			) then
				if not e.other:HasItem(31599) then
					e.other:SummonItem(31599) -- Item: The Mark of Justice
				end
			elseif (
				e.other:HasItem(31796) or
				e.other:HasItem(31842) or
				e.other:HasItem(31845) or
				e.other:HasItem(31846) or
				e.other:HasItem(31960)
			) then
				e.self:Say("You have done well, mortal, but there are more trials yet for you to complete.")
			end
		end
	else
		if e.message:findi("Hail") then
			e.self:Say("I'm sorry, the Trial of Flame is currently unavailable to you.")
		end
	end
end

function event_timer(e)
	if e.timer == "Start" then
		eq.stop_timer("Start")
		e.self:SetEntityVariable("Active", "1")
		eq.set_timer("Fail", 1200 * 1000) -- 20 Minutes
	elseif e.timer == "Fail" then
		eq.stop_timer("Fail")
		e.self:DeleteEntityVariable("Active")
		eq.signal(201434, 0, 5) -- #The_Tribunal Flame Trial
	end
end

function event_signal(e)
	if e.signal == 0 then
		e.self:Shout("The Trial of Flame is now available.")
		e.self:DeleteEntityVariable("Active")
		eq.stop_timer("Fail")
		eq.signal(201417, 2, 5) -- #Event_Burning_Control
	end
end

function event_trade(e)
	local item_lib = require("items")
	local mavuin_bucket = tonumber(e.other:GetAccountBucket("pop.flags.mavuin")) or 0
	if mavuin_bucket == 1 then
		local trials = {
			[31842] = "execution",
			[31796] = "flame",
			[31960] = "lashing",
			[31845] = "stoning",
			[31844] = "torture",
			[31846] = "hanging"
		}

		for item_id, flag in pairs(trials) do
			if item_lib.check_turn_in(e.trade, {item1 = item_id}) then
				e.other:Message(MT.LightBlue, "You have completed a trial - impressive for mortals. You can tell Mavuin that we will hear his plea. We will seek him out as time befits us.")
				e.other:SetAccountBucket("pop.flags.tribunal", "1")
				e.other:SetAccountBucket(string.format("pop.flags.%s", flag), "1")
				e.other:Message(MT.LightBlue, "You receive a character flag!")
			end
		end
	end

	item_lib.return_items(e.self, e.other, e.trade)
end
