-- [[
-- Susarrak the Crusader (446218) -- Kerafyrm benefactor Herald.
-- Benefit: nuke crit chance increase + 1k/tick mana regen.
-- "frustrate him" blocks Kerafyrm's next big AE.
--]]
local KERAFYRM = 446214

function event_say(e)
	if e.message:findi("frustrate him") then
		e.self:Say("Your spells shall not be undone by the Sleeper.")
		eq.signal(KERAFYRM, 9001)
	elseif e.message:findi("benefit") then
		e.self:Shout("Channel the storm! Your magic will strike true and your mana restored!")
		e.other:SetMana(e.other:GetMana() + 1000)
	end
end
