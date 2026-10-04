-- [[
-- Jortrev the Crusader (446217) -- Kerafyrm benefactor Herald.
-- Benefit: hate reduction + heal crit chance increase.
-- "frustrate him" blocks Kerafyrm's next big AE.
--]]
local KERAFYRM = 446214

function event_say(e)
	if e.message:findi("frustrate him") then
		e.self:Say("I shall quell the hatred it holds for you all.")
		eq.signal(KERAFYRM, 9001)
	elseif e.message:findi("benefit") then
		e.self:Shout("My blessing steadies your hands to mend -- and grants you reprieve from Kerafyrm's ire!")
		e.self:CastSpell(2902, e.other:GetID())
	end
end
