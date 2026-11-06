-- Agilica (442182) -- SoF faction task "The Rescue" (300205).
-- Hand-written: summons two brownie guards when a player on the guard
-- step of the task hails her (live behavior; do not hail while invisible).

local TASK_RESCUE = 300205
local GUARD = 57044

function guards_present()
	local count = 0
	local list = eq.get_entity_list():GetNPCList()
	for npc in list.entries do
		if npc:GetNPCTypeID() == GUARD then
			count = count + 1
		end
	end
	return count
end

function event_say(e)
	if e.other:IsTaskActive(TASK_RESCUE) and e.other:IsTaskActivityActive(TASK_RESCUE, 1) then
		if guards_present() >= 2 then
			e.self:Say("My guards are already dealing with you!")
		else
			e.self:Say("You would harm me? Guards! Guards! To me!")
			for _ = 1, 2 do
				local guard = eq.spawn2(GUARD, 0, 0,
					e.self:GetX() + math.random(-10, 10),
					e.self:GetY() + math.random(-10, 10),
					e.self:GetZ(), e.self:GetHeading())
				if guard.valid then
					guard:Attack(e.other)
				end
			end
		end
	else
		e.self:Say("Hail, " .. e.other:GetCleanName() .. ". The encampment presses in around us. Kaerra coordinates our efforts if you come seeking work.")
	end
end

function event_trade(e)
	local item_lib = require("items")
	item_lib.return_items(e.self, e.other, e.trade)
end


-- rof2b composition (2026-11-05): this giver's SoF faction-task dialogue above
-- is preserved; the reconstruction's Dragonscale Hills routes dispatch below.
-- Their handler is keyword-gated and opens its own task selector; the SoF
-- offer keywords 'work'/'offer'/'jobs' still reach the dialogue above, and a
-- plain hail keeps both the SoF greeting and their selector.
local dragonscale_mod = require('achievement_quest_dragonscale')
local rof2b_sof_say = event_say
local rof2b_sof_trade = event_trade
local rof2b_sof_accepted = event_task_accepted
local rof2b_their_kw = { 'hail', 'task', 'help', 'profit', 'clockworks',
	'replace', 'resources', 'deal', 'risk', 'assist', 'issues', 'grateful',
	'find her', 'aid' }
local function rof2b_theirs(e)
	local msg = e.message:lower()
	for _, w in ipairs(rof2b_their_kw) do
		if msg:find(w, 1, true) then return true end
	end
	return false
end

function event_say(e)
	if rof2b_theirs(e) then
		dragonscale_mod.say(e)
		if e.message:lower():find('hail', 1, true) and rof2b_sof_say then
			rof2b_sof_say(e)
		end
	elseif rof2b_sof_say then
		rof2b_sof_say(e)
	end
end

function event_trade(e)
	local handled = false
	if dragonscale_mod.trade then handled = dragonscale_mod.trade(e) end
	if not handled and rof2b_sof_trade then rof2b_sof_trade(e) end
end

function event_task_accepted(e)
	if rof2b_sof_accepted then rof2b_sof_accepted(e) end
	if dragonscale_mod.accepted then dragonscale_mod.accepted(e) end
end
