function event_spawn(e)
	local entity_list = eq.get_entity_list()

	if entity_list:IsMobSpawnedByNpcTypeID(206067) then
		eq.depop(206067) -- Real Xanamech
	end

	if not entity_list:IsMobSpawnedByNpcTypeID(206068) then
		eq.spawn2(206068, 0, 0, -735, 1500, -50, 251.6) -- Fake Xanamech
	end
end

function event_death_complete(e)
        local walking_variable = tonumber(e.self:GetEntityVariable("Walking")) or 0
        local won_variable = tonumber(e.self:GetEntityVariable("Won")) or 0
        if walking_variable == 1 and won_variable == 0 then
                eq.spawn2(206033, 0, 0, 974, 1532, -35, 0) -- Repop him if he dies during escort before its over
        end
end


function event_say(e)
	local walking_variable = tonumber(e.self:GetEntityVariable("Walking")) or 0
	local won_variable = tonumber(e.self:GetEntityVariable("Won")) or 0

	if won_variable == 1 then
		if e.message:findi("Hail") then
			local xanamech_bucket = tonumber(e.other:GetAccountBucket("pop.flags.xanamech")) or 0
			if xanamech_bucket == 0 then
				e.other:SetAccountBucket("pop.flags.xanamech", "1")
				e.other:Message(MT.LightBlue, "You receive a character flag!")
			else
				e.self:Say("It looks like we've already spoken.")
			end
		end
	elseif walking_variable == 1 then
		if e.message:findi("Hail") then
			local advanced_tinkering_link = eq.silent_say_link("advanced tinkering")
			e.self:Say(
				string.format(
					"Oh my hello! It has been such a long time since I have had visitors. Have you come to learn of [%s] as well?",
					advanced_tinkering_link
				)
			)
		elseif e.message:findi("advanced tinkering") then
			local construction_link = eq.silent_say_link("construction")
			e.self:Say(
				string.format(
					"Aye, I advanced to this plane due to my work on tinkering back in Ak`Anon. A grand city it is, but my abilities were compromised with the materials I had to work with there. My body and soul has come to rest here, forever coming up with new ideas. You should be aware though that this plane is not how it was when I arrived. Much [%s] has taken place.",
					construction_link
				)
			)
		elseif e.message:findi("construction") then
			local instinct_for_survival_link = eq.silent_say_link("instinct for survival")
			e.self:Say("When I first arrived I started creating smaller things. As time went on my inventions became more and more focused and impressive. I started building steam powered clockwork to help me gather materials. I had gone too far giving them the ability to learn and with a built in desire of self perpetuation. They began to integrate themselves with the clockwork that already existed within the factory that you can see if you step outside.")
			e.self:Say(
				string.format(
					"I once worked within the factory with a kind and fair gnome, Meldrath. Now that he has gone missing the clockworks seem to be working towards a more devious goal. The clockwork out here in the junkyard have been discarded due to their malfunction or replacement by a more efficient series. Needless to say their [%s] has not been lost.",
					instinct_for_survival_link
				)
			)
		elseif e.message:findi("instinct for survival") then
			local combination_of_batteries_link = eq.silent_say_link("combination of batteries")
			e.self:Say(
				string.format(
					"The clockwork have become increasingly aggressive because of their desperation for spare parts. I have to defend myself anytime I head out to find parts for my tinkering. I fear for my safety with what is being built in the factory. I have started to build myself my own means of defense. It is nearly completed but I need an odd [%s] to start it up. I should have planned more carefully for it to use simple mana batteries.",
					combination_of_batteries_link
				)
			)
		elseif e.message:findi("combination of batteries") then
			local collecting_materials_link = eq.silent_say_link("collecting materials")
			e.self:Say(
				string.format(
					"Well you see when I was back home it was common for me to use a mycological spore extricate-kinetoconvertor to power my devices. I started planning my defense to use this as a power source out of sheer habit. Here in this desolation the mushrooms that were grown back home do not exist. I am going to have to rig something from spare parts. It is taking a long time with my having to search the junkyard small portions at a time due to the clockworks. Would you help me in [%s]?",
					collecting_materials_link
				)
			)
		elseif e.message:findi("collecting materials") then
			e.self:Say("Let us see here. I have some of the base parts for the power source. If you could collect a copper node, a bundle of super conductive wires, and an intact power cell I could power up the machine. Good luck to you $name, I hope that we can work together on this.")
		end
	elseif walking_variable == 0 and won_variable == 0 then
		local bundle_link = eq.item_link(9295)
		local node_link = eq.item_link(9426)
		local cell_link = eq.item_link(9434)
		e.self:Say(
			string.format(
				"I need a %s, %s, and an %s before I can begin.",
				bundle_link,
				node_link,
				cell_link
			)
		)
	end
end

function event_trade(e)
	local item_lib = require("items")

	if item_lib.check_turn_in(e.trade, {item1 = 9426, item2 = 9295, item3 = 9434}) then
		e.self:SetEntityVariable("Walking", "1")
		eq.start(23)
		eq.set_timer("Position", 1 * 1000) -- 1 Second
	end
end

function event_timer(e)
	local entity_list = eq.get_entity_list()

	if e.timer == "Position" and e.self:GetX() == -720 and e.self:GetY() == 1500 and not entity_list:IsMobSpawnedByNpcTypeID(206067) then
		eq.spawn2(206067, 0, 0, -735, 1580, -50, 251.6) -- Real Xanamech
		eq.depop(206068) -- Fake Xanamech
		eq.stop_timer("Position")
		eq.set_timer("Win", 1 * 1000) -- 1 Second
		eq.set_timer("Fail", 7200 * 1000) -- 2 Hours
	elseif e.timer == "Win" and not entity_list:IsMobSpawnedByNpcTypeID(206067) then -- Real Xanamech
		e.self:SetEntityVariable("Won", "1")
		e.self:SetEntityVariable("Walking", "0")
		eq.stop_timer("Win")
		eq.set_timer("Reset", 600 * 1000) -- 10 Minutes
	elseif e.timer == "Win" and entity_list:IsMobSpawnedByNpcTypeID(206067) then
		eq.stop_timer("Win")
		eq.set_timer("Win", 1 * 1000) -- 1 Second
	elseif e.timer == "Reset" then
		eq.depop_with_timer()
	elseif e.timer == "Fail" then
		eq.depop_all(206067) -- Real Xanamech
		eq.depop_with_timer()
	end
end
