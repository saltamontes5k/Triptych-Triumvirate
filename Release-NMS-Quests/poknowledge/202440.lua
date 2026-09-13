-- Frostfell (2008): #Cordys_Leaflighter - Gifts Ungiven mission giver
function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("Happy Frostfell! Would you help me [recover] the missing gifts?")
	elseif e.message:findi("recover") or e.message:findi("help") then
		e.self:Say("Search Thundercest Isles for the stolen presents and defeat the Frostclaw Thief.")
	end
end
