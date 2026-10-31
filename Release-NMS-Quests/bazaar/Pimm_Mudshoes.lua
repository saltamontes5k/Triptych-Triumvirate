-- bazaar/Pimm_Mudshoes.lua
-- Mudshoes' Pottery Trial: tradeskill shroud mission #2, spun off the Fool's
-- Gold Cake Defense (bazaar/Wendel_Sweetcrumb.lua). The halfling potter sends
-- L25+ players (group or solo) into a beholder version 80 expedition where
-- they are shrouded into tiny clay golems, dodge a water-elemental camp at
-- the entrance, take one deliberate hit from a runaway halfling potter, and
-- are grown and baked through four stages. Trigger phrase is "I am
-- adaptable" -- the potter's pitch, and the golem's whole worldview.
-- IDs live in migration v287 (20261030_mudshoes_pottery_v287.sql): shrouds.id
-- 506, beholder v80, controller 1520001991.

local EXPEDITION_NAME = "Mudshoes' Pottery Trial"
local MIN_LEVEL       = 25 -- shrouds only go down, never up
local PHRASE          = "i am adaptable"

local compass    = { zone = "bazaar", x = 162, y = -489, z = 3 }
local safereturn = { zone = "bazaar", x = 185, y = -835, z = 4, h = 390 }
-- The East Karana entrance of the Gorge: the "original spot" the finale
-- returns to. The controller spawns the stage-1 actors around it.
local zonein     = { x = -1840, y = 720, z = 9, h = 0 }

local pottery_trial = {
	expedition = { name = EXPEDITION_NAME, min_players = 1, max_players = 6 },
	instance   = { zone = "beholder", version = 80, duration = eq.seconds("2h") },
	compass    = compass,
	safereturn = safereturn,
	zonein     = zonein
}

local function on_pottery_expedition(client)
	local dz = client:GetExpedition()
	return dz.valid and dz:GetName() == EXPEDITION_NAME
end

function event_say(e)
	if e.message:findi("hail") then
		e.self:Say(string.format(
			"Mind the mud on the floor, %s -- half my stock is currently a puddle. If you have clay in your future, ask me about my %s.",
			e.other:GetCleanName(), eq.say_link("Pottery Trial")))
	elseif e.message:findi("pottery") then
		if e.other:GetLevel() < MIN_LEVEL then
			e.self:Say("Come back when you've seen at least 25 winters. Green clay cracks, and so do green adventurers.")
			return
		end
		if on_pottery_expedition(e.other) then
			e.self:Say("Your trial is already assembling! Say '" .. eq.say_link("I am adaptable") .. "' and I'll show you in.")
			return
		end
		e.self:Say("A magician camped at the mouth of the Gorge has stolen my best apprentice -- an honest potter, nowbound to his ritual. My plan is foolproof: I shrink a volunteer into a tiny clay golem, you wander in and find her, and when she works you over on the shaping wheel you come out bigger, harder, and considerably more vengeful. Say [" .. eq.say_link("I am adaptable") .. "] when you're ready to be clay. Don't touch the water elementals. They don't know their own strength.")
	elseif e.message:findi(PHRASE) then
		if on_pottery_expedition(e.other) then
			e.other:MovePCDynamicZone(e.other:GetExpedition():GetZoneID())
			return
		end
		if e.other:GetLevel() < MIN_LEVEL then
			e.self:Say("The kiln stays cold for you until you've seen 25 winters.")
			return
		end
		local dz = e.other:CreateExpedition(pottery_trial)
		if dz.valid then
			e.self:Say("Wedge, center, throw! Into the Gorge you go. Group members, say [" .. eq.say_link("I am adaptable") .. "] to follow. Find my potter and let her shape you -- and whatever happens, stay ADAPTABLE.")
		end
	end
end
