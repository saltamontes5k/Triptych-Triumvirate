-- Ambassador_of_the_Crystalwing (npc id 202533) - The Plane of Knowledge
-- Member of the Circle of the Crystalwing. Offers passage to Crescent Reach to
-- any traveler, and a one-time embassy option (25,000 platinum) to those who
-- have finished The Serpent's Spine: it binds them to Crescent Reach, swears
-- them to Veeshan, and sets their Circle of the Crystalwing standing to that of
-- a newly created Drakkin adventurer. GM bypass comes from prog.gate_stage().

local prog = require("nms_progression")

local EMBASSY_COST  = 25000000  -- 25,000 platinum, in copper
local EMBASSY_ONCE  = "crystalwing_embassy" -- bucket prefix, keyed by char id

local VEESHAN       = 216       -- deity id
local CRYSTALWING   = 1129      -- Circle of the Crystalwing faction id
local DRAKKIN_STAND = 100       -- new Drakkin effective standing (base 0 + r522)

local PORT     = { zone = 394, x = -2780.0, y = -950.0, z = -50.0, h = 0 }
local CRESCENT = { zone = 394, x = -8.0,   y = 11.0,   z = 2.0,   h = 0 }

local DENY = "The Circle does not open its embassy to the untested. Silence Deathknell first, and we will speak again."

local function embassy_done(c)
	return (eq.get_data(EMBASSY_ONCE .. c:CharacterID()) or "") ~= ""
end

-- Forces the player's effective faction standing to `target` regardless of
-- race/class/deity. SetFactionLevel2 adds a delta to the personal value, and
-- Heroic CHA scales that delta, so a few correction passes are used to settle
-- on the exact value (same approach as bazaar/Ambassador_Terratoe.pl).
local function set_effective_faction(c, faction_id, target)
	for _ = 1, 3 do
		local delta = target - c:GetModCharacterFactionLevel(faction_id)
		if delta == 0 then break end
		c:SetFactionLevel2(c:CharacterID(), faction_id, c:GetClass(), c:GetBaseRace(), c:GetDeity(), delta, 0)
	end
end

local function say(e, text)
	eq.get_entity_list():MessageClose(e.self, true, 100, MT.SayEcho, "Ambassador of the Crystalwing says, '" .. text .. "'")
end

function event_say(e)
	local c = e.other
	if not c or not c:IsClient() then return end

	local name         = c:GetCleanName()
	local embassy_ready = c:GetGM() or prog.stage_complete(c, "TSS")

	if e.message:findi("hail") then
		local text = "Well met, " .. name .. ". I am the Ambassador of the Crystalwing, and I keep the Circle's way to Crescent Reach. Say the word and I will send you through, if you are [" .. eq.say_link("ready") .. "]."
		if embassy_ready and not embassy_done(c) then
			text = text .. " I can also accept you into the Circle's [" .. eq.say_link("embassy") .. "] for 25,000 platinum, binding you to Crescent Reach and to the service of Veeshan."
		end
		say(e, text)
	elseif e.message:findi("ready") or e.message:findi("crescent") or e.message:findi("reach") then
		say(e, "Hold fast, " .. name .. ". The Circle's way is not gentle.")
		c:MovePC(PORT.zone, PORT.x, PORT.y, PORT.z, PORT.h)
	elseif e.message:findi("embassy") then
		if embassy_done(c) then
			say(e, "You are already sworn to the Circle, " .. name .. ". Crescent Reach and Veeshan both know your name.")
		elseif not embassy_ready then
			say(e, DENY)
		elseif not c:TakeMoneyFromPP(EMBASSY_COST, true) then
			say(e, "The embassy costs 25,000 platinum, " .. name .. ". Come back when your purse is heavier.")
		else
			c:SetBindPoint(CRESCENT.zone, 0, CRESCENT.x, CRESCENT.y, CRESCENT.z, CRESCENT.h)
			c:SetDeity(VEESHAN)
			set_effective_faction(c, CRYSTALWING, DRAKKIN_STAND)
			eq.set_data(EMBASSY_ONCE .. c:CharacterID(), "1")
			say(e, "It is done, " .. name .. ". Crescent Reach is your home now, Veeshan is your patron, and the Circle numbers you among its own. Walk with the Crystalwing.")
		end
	end
end
