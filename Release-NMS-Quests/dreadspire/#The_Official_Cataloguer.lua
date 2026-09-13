-- dreadspire/#The_Official_Cataloguer.lua
-- Depths of Darkhollow: grants the Study of Mystical Vision to bearers of
-- Treddlehoop's task 505746 "Check Out a Library Book".
local dodh = require("dodh_helper");

function event_say(e)
	local t = e.message:lower();
	if t:find("hail") then
		e.self:Say("State your business. The catalogue does not organise itself, and I have little patience for curiosity-seekers.");
	elseif t:find("mystical vision") or t:find("study") or t:find("catalog") then
		if e.other:HasItem(dodh.items.study_mystical_vision) then
			e.self:Say("You already hold the Study of Mystical Vision. Return it to Treddlehoop, not to me.");
		elseif e.other:IsTaskActive(dodh.tasks.library_book) then
			e.other:SummonFixedItem(dodh.items.study_mystical_vision);
			e.self:Say("A study of mystical vision, is it? Take it - and do not dog-ear the pages. Treddlehoop will be expecting you.");
		else
			e.self:Say("I do not hand my studies to just anyone. Come back when someone of standing has sent you.");
		end
	end
end
