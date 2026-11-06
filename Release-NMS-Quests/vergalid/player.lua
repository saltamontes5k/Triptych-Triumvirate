-- Vergalid Mines zone player script (rof2b 2026-11-05).
-- Composes: (1) the stock perl player.pl door linkage (doors 41/42 gate
-- doors 38/39/40) translated here so the lua script may own the zone's
-- player events, and (2) the reconstruction's task wiring plus the
-- Vergalid inner-access cast/click hooks.
local vergalid = require('achievement_quest_vergalid')
local inner = require('vergalid_inner_access')

local function door_linkage(e)
	local clicked = e.door:GetDoorID()
	if clicked ~= 41 and clicked ~= 42 then return end
	local el = eq.get_entity_list()
	local tds = el:GetDoorsByDoorID(41)
	local bds = el:GetDoorsByDoorID(42)
	local t_open = (tds and tds:IsDoorOpen()) or false
	local b_open = (bds and bds:IsDoorOpen()) or false
	if (clicked == 41 and not b_open) or (clicked == 42 and not t_open) then
		for _, id in ipairs({ 38, 39, 40 }) do
			local d = el:GetDoorsByDoorID(id)
			if d then d:SetOpenState(not d:IsDoorOpen()) end
		end
	end
end

function event_click_door(e)
	local result = inner.click(e)
	if result and result ~= 0 then return result end
	door_linkage(e)
	return nil
end

function event_enter_zone(e)
	vergalid.resume(e)
end

function event_task_accepted(e)
	vergalid.resume(e)
end

function event_task_update(e)
	vergalid.resume(e)
end

function event_task_stage_complete(e)
	vergalid.resume(e)
end

function event_task_complete(e)
	vergalid.resume(e)
end

function event_task_fail(e)
	vergalid.resume(e)
end

function event_timer(e)
	if vergalid.timer(e) then return end
end

function event_cast(e)
	inner.cast(e)
end
