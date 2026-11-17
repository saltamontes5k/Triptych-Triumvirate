-- bazaar/Wendel_Sweetcrumb.lua
-- NMS tradeskill mission desk.
--
-- Three monster missions start here: the Fool's Gold Cake Defense (rivervale
-- v202, shroud 500 cake), the Dwarven Keg Wedding (kaladima v25, shroud 501
-- keg) and Mudshoes' Pottery Trial (beholder v80, shroud 506 clay golem).
--
-- They used to be three NPCs standing side by side (Wendel_Sweetcrumb
-- 1520001800, Dorgan_Thunderbrew 1520001930, Pimm_Mudshoes 1520001990). The
-- other two stood inside the stall and could not be reached, so their missions
-- moved onto Wendel and their spawns were retired.
--
-- The controllers still apply the forms themselves (shrouds.id 500/501/506);
-- nothing here touches the shroud directly.

local MIN_LEVEL = 25 -- shrouds only go down, never up

local compass    = { zone = "bazaar", x = 155, y = -493, z = 3 }
local safereturn = { zone = "bazaar", x = 185, y = -835, z = 4, h = 390 }

local MISSIONS = {
	cake = {
		name       = "The Fool's Gold Cake Defense",
		link       = "Cake Defense",
		zone       = "rivervale",
		version    = 202,
		zonein     = { x = -134, y = -61, z = 3, h = 0 },
		pitch      = "The Fool's Gold ordered a birthday cake so grand the adventurers of the Vale can smell it three zones away. Somebody has to guard it -- and in my professional opinion, nothing guards a cake better than another cake. Say [ready] and in you go. Just don't let them eat you.",
		enter_text = "Into the oven you go! Group members, say [ready] to follow. Once everyone's in and buttered up, say 'I am delicious' -- that's the dinner bell. Guard that cake!",
	},
	keg = {
		name       = "The Dwarven Keg Wedding",
		link       = "Keg Wedding",
		zone       = "kaladima",
		version    = 25,
		zonein     = { x = 396, y = 44, z = 9, h = 0 },
		pitch      = "My cousin Hilda is marrying into the Ironforge clan in the Warrior's Guild Hall in South Kaladim. The guests are gathered, the priest is ready, and the ceremonial keg is missing. I need someone to *be* the keg. The form gives you a bleary gaze, liquid courage and a blast of beery wind -- buy them with the monster points it grants. Say [ready]. And mind what I say: do not kill anyone. Alcohol kills, you know.",
		enter_text = "Into the barrel with you! Group members, say [ready] to follow. Once you are in and settled, say 'pour the first round' to begin. Buy your keg abilities first -- you will need Stale Brew, Beer Bubbles, Pass Out, Brewmaster's Bidding, and Keg Blast.",
	},
	pottery = {
		name       = "Mudshoes' Pottery Trial",
		link       = "Pottery Trial",
		zone       = "beholder",
		version    = 80,
		zonein     = { x = -1840, y = 720, z = 9, h = 0 },
		pitch      = "A magician camped at the mouth of the Gorge has stolen my best apprentice -- an honest potter, now bound to his ritual. My plan is foolproof: I shrink a volunteer into a tiny clay golem, you wander in and find her, and when she works you over on the shaping wheel you come out bigger, harder, and considerably more vengeful. Say [ready] when you're ready to be clay. Don't touch the water elementals. They don't know their own strength.",
		enter_text = "Into the kiln with you! Group members, say [ready] to follow. Once you are in, say 'I am adaptable' -- the potter's pitch, and the golem's whole worldview.",
	},
}

local function build_definition(m)
	return {
		expedition = { name = m.name, min_players = 1, max_players = 6 },
		instance   = { zone = m.zone, version = m.version, duration = eq.seconds("2h") },
		compass    = compass,
		safereturn = safereturn,
		zonein     = m.zonein,
	}
end

local function current_mission(client)
	local dz = client:GetExpedition()
	if not dz.valid then
		return nil
	end
	for _, m in pairs(MISSIONS) do
		if dz:GetName() == m.name then
			return m
		end
	end
	return nil
end

local function offer(e, key)
	local m = MISSIONS[key]
	if e.other:GetLevel() < MIN_LEVEL then
		e.self:Say("Come back when you've seen at least 25 winters. These forms only shrink seasoned adventurers.")
		return
	end

	local active = current_mission(e.other)
	if active then
		if active.name == m.name then
			e.self:Say(string.format("Your %s is already under way. Say [ready] and I'll show you back in.", m.link))
		else
			e.self:Say("You are already expected at another of my little disasters. Finish that one first.")
		end
		return
	end

	e.self:Say(m.pitch)
end

local function enter(e, key)
	local m = MISSIONS[key]
	if e.other:GetLevel() < MIN_LEVEL then
		e.self:Say("The forms stay folded for you until you've seen 25 winters.")
		return
	end

	local active = current_mission(e.other)
	if active then
		if active.name == m.name then
			e.other:MovePCDynamicZone(e.other:GetExpedition():GetZoneID())
			return
		end
		e.self:Say("Finish the one you're already in first.")
		return
	end

	local dz = e.other:CreateExpedition(build_definition(m))
	if dz.valid then
		e.self:Say(m.enter_text)
	else
		e.self:Say("The instance is already assembling, or the hall is full. Try again in a moment.")
	end
end

function event_say(e)
	local msg = e.message:lower()

	if msg:find("hail") then
		e.self:Say(string.format(
			"Fresh bread! Honey buns! -- hello, %s. If you have a taste for trouble, I run three of them: the %s, the %s, and the %s.",
			e.other:GetCleanName(),
			eq.say_link(MISSIONS.cake.link),
			eq.say_link(MISSIONS.keg.link),
			eq.say_link(MISSIONS.pottery.link)))
	elseif msg:find("cake") then
		offer(e, "cake")
	elseif msg:find("keg") or msg:find("wedding") then
		offer(e, "keg")
	elseif msg:find("pottery") or msg:find("clay") then
		offer(e, "pottery")
	elseif msg:find("ready") then
		local active = current_mission(e.other)
		if active then
			for key, m in pairs(MISSIONS) do
				if m.name == active.name then
					enter(e, key)
					return
				end
			end
		end
		-- No expedition yet: "ready" is the cake's original shortcut.
		enter(e, "cake")
	end
end
