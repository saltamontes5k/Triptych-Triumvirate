-- bazaar/Wendel_Sweetcrumb.lua
-- NMS test monster mission: the Fool's Gold Cake Defense. The halfling baker
-- sends L25+ players (group or solo) into a Rivervale version 202 expedition
-- where they are shrouded into immobile birthday cakes and defend themselves
-- against three waves of hungry adventurers.
-- IDs live in migration v121 (20261008_cake_defense.sql): shrouds.id 500,
-- rivervale v202, controller 1520001801.

local EXPEDITION_NAME = "The Fool's Gold Cake Defense"
local MIN_LEVEL       = 25 -- shrouds only go down, never up

local compass    = { zone = "bazaar", x = 150, y = -496, z = 3 }
local safereturn = { zone = "bazaar", x = 185, y = -835, z = 4, h = 390 }
local zonein     = { x = -134, y = -61, z = 3, h = 0 }

local cake_defense = {
	expedition = { name = EXPEDITION_NAME, min_players = 1, max_players = 6 },
	instance   = { zone = "rivervale", version = 202, duration = eq.seconds("2h") },
	compass    = compass,
	safereturn = safereturn,
	zonein     = zonein
}

local function on_cake_expedition(client)
	local dz = client:GetExpedition()
	return dz.valid and dz:GetName() == EXPEDITION_NAME
end

function event_say(e)
	if e.message:findi("hail") then
		e.self:Say(string.format(
			"Fresh bread! Honey buns! Oh -- hello, %s. If you have a taste for trouble, ask me about the %s.",
			e.other:GetCleanName(), eq.say_link("Cake Defense")))
	elseif e.message:findi("cake defense") then
		if e.other:GetLevel() < MIN_LEVEL then
			e.self:Say("Come back when you've seen at least 25 winters. The oven only bakes guardian cakes for seasoned adventurers.")
			return
		end
		if on_cake_expedition(e.other) then
			e.self:Say("Your defense is already assembling! Say 'ready' and I'll show you in.")
			return
		end
		e.self:Say("The Fool's Gold ordered a birthday cake so grand the adventurers of the Vale can smell it three zones away. Somebody has to guard it -- and in my professional opinion, nothing guards a cake better than another cake. When you're [" .. eq.say_link("ready") .. "], say the word and in you go. Just don't let them eat you.")
	elseif e.message:findi("ready") then
		if on_cake_expedition(e.other) then
			e.other:MovePCDynamicZone(e.other:GetExpedition():GetZoneID())
			return
		end
		if e.other:GetLevel() < MIN_LEVEL then
			e.self:Say("The oven stays cold for you until you've seen 25 winters.")
			return
		end
		local dz = e.other:CreateExpedition(cake_defense)
		if dz.valid then
			e.self:Say("Into the oven you go! Group members, say [" .. eq.say_link("ready") .. "] to follow. Once everyone's in and buttered up, say 'I am delicious' -- that's the dinner bell. Guard that cake!")
		end
	end
end
