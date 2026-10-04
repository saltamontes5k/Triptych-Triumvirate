-- [[
-- Charayan the Crusader (446215) -- Kerafyrm benefactor Herald.
-- Rasper: raidCrystallos.html (Kerafyrm, the 4 Heralds).
-- Benefit: 35% melee increase + "hundred hands". Can be told "frustrate him"
-- to block Kerafyrm's next big AE (shared block timer on the boss).
--]]
local KERAFYRM = 446214

function event_say(e)
	if e.message:findi("frustrate him") then
		e.self:Say("I will blunt the Sleeper's fury.")
		eq.signal(KERAFYRM, 9001)
	elseif e.message:findi("benefit") then
		-- 35% melee increase for 18s
		e.self:CastSpell(2665, e.other:GetID())  -- melee haste
		e.self:Say("Fight as though your hands were ten, and Kerafyrm shall feel it.")
	end
end
