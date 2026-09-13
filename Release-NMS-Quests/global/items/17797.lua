-- Erollisi's Idol of Friendship - Things Are Best With Friends (Erollisi Day)
local ED = require("erollisiday")

function event_item_click(e)
	local c = e.self
	if not c or not c:IsClient() then return end
	if not c:IsTaskActive(ED.TASK.FRIENDS) then return end
	local t = c:GetTarget()
	if t and t:IsClient() and t:GetID() ~= c:GetID() then
		c:UpdateTaskActivity(ED.TASK.FRIENDS, 1, 1)
		c:Message(15, "Erollisi's friendship touches your target.")
	end
end
