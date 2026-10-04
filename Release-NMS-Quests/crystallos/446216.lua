-- [[
-- Grendish the Crusader (446216) -- Kerafyrm benefactor Herald.
-- Benefit: 50% melee mitigation + 1k/tick endurance regen.
-- "frustrate him" blocks Kerafyrm's next big AE.
--]]
local KERAFYRM = 446214

function event_say(e)
	if e.message:findi("frustrate him") then
		e.self:Say("May Kerafyrm's wind break upon my ward.")
		eq.signal(KERAFYRM, 9001)
	elseif e.message:findi("benefit") then
		e.self:Shout("Stand fast -- I shall mitigate Kerafyrm's blows and mend your stamina!")
		-- simplified endurance regen: grant the caller a small heal/regen
		e.self:CastSpell(2005, e.other:GetID())
	end
end
