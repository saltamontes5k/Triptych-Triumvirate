-- global/items/36577.lua -- Mechano-Tool Kit (Switching Gears, 300028).
-- Click beside a wounded clockwork gnome (<40% HP, within 10 units) to
-- salvage parts: consumes one Micro-Cog or Class "A" Cog and advances the
-- task's scripted activity. The tenth salvage consumes the kit.
local fort = require("sof_fortress")

function event_item_click(e)
	if e.owner == nil then return end
	local owner = e.owner
	if not owner:IsTaskActive(fort.TASK_GEARS) then
		owner:Message(15, "The kit rattles inertly. The Warmarshal's errand is not yours to run.")
		return
	end
	if fort.activity_done(owner, fort.TASK_GEARS, 2) then
		owner:Message(15, "The kit is spent. Return it to the Clockwork Warmarshal.")
		return
	end
	-- find a wounded clockwork gnome nearby
	local target = nil
	local list = eq.get_entity_list():GetNPCList()
	for npc in list do
		if npc.valid and npc:IsNPC()
			and npc:CalculateDistance(owner:GetX(), owner:GetY(), owner:GetZ()) <= 10
			and npc:GetHPRatio() < 40
			and npc:GetCleanName():findi("clockwork gnome") then
			target = npc
			break
		end
	end
	if target == nil then
		owner:Message(15, "The kit's arm probes the air. Stand beside a wounded clockwork gnome (under 40% health) to use it.")
		return
	end
	-- consume one cog of either type
	if owner:CountItem(fort.ITEM.micro_cog) > 0 then
		owner:DeleteItemInInventory(fort.ITEM.micro_cog, 1)
	elseif owner:CountItem(fort.ITEM.class_a_cog) > 0 then
		owner:DeleteItemInInventory(fort.ITEM.class_a_cog, 1)
	else
		owner:Message(15, "The kit feeds on cogs. You have none left -- hunt more from the fortress clockworks.")
		return
	end
	target:Emote("shudders as the kit strips its gears. Salvage accepted.")
	fort.bump(owner, fort.TASK_GEARS, 2, 1)
	if fort.activity_done(owner, fort.TASK_GEARS, 2) then
		owner:DeleteItemInInventory(fort.ITEM.tool_kit, 1)
		owner:Message(15, "The Mechano-Tool Kit is spent. Take it back to the Clockwork Warmarshal.")
	end
end
