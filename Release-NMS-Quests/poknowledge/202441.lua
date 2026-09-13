-- Frostfell (2008): #Elba_Straw - Presents Lost mission giver
function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("Happy Frostfell! Would you help me [recover] the missing presents?")
	elseif e.message:findi("recover") or e.message:findi("help") then
		e.self:Say("Search Hate's Fury for the stolen presents and defeat Iceheart, Frostclaw Thief.")
	end
end
