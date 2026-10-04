-- Laiyken (442036) -- Crystallos gatekeeper, Dragonscale Hills.
-- Stage 2: Master Crystal Base -> Prismatic Crystal Charm (static access).
-- Stage 4: Exploring Crystallos task + Oil Stained Crystal -> Crystallos
-- raid expedition request ("crystallos" instance version 220).
local prog = require("sof_progression")

local CRYSTALLOS_RAID_LOCKOUT = eq.seconds("72h")

local crystallos_raid = {
	expedition = { name = "Crystallos, Lair of the Awakened", min_players = 1, max_players = 54 },
	instance   = { zone = "crystallos", version = 220, duration = eq.seconds("8h") },
	compass    = { zone = "dragonscale", x = -1092, y = 1983, z = 362.25 },
	safereturn = { zone = "dragonscale", x = -1092, y = 1983, z = 362.25, h = 0 },
	zonein     = { x = 1560, y = 400, z = 319.6, h = 0 }, -- near Kerafyrm's approach (TUNABLE)
}

local function has_crystallos_access(e)
	return e.other:CountItem(prog.ITEM.charm) > 0
		or prog.has_flag(e.other, prog.FLG.crystallos)
end

function event_say(e)
	if e.message:findi("hail") then
		if prog.task_done(e.other, prog.TASK_BARRIER) then
			if e.other:CountItem(prog.ITEM.charm) > 0
				or prog.has_flag(e.other, prog.FLG.crystallos) then
				if not prog.task_done(e.other, prog.TASK_EXPLORE_CRYSTALLOS)
					and not e.other:IsTaskActive(prog.TASK_EXPLORE_CRYSTALLOS) then
					e.self:Say("You walk with the awakened light upon you. "
						.. "One more service: [explore] the four elemental "
						.. "wings of Crystallos so my maps may be finished.")
				elseif prog.task_done(e.other, prog.TASK_EXPLORE_CRYSTALLOS)
					and not prog.has_flag(e.other, prog.FLG.crystallos_raid) then
					if e.other:CountItem(prog.ITEM.oil_crystal) > 0 then
						e.self:Say("An oil stained crystal, straight from "
							.. "Meldrath's own engine. Trade it to me and "
							.. "the [raid] on Crystallos is yours to call.")
					else
						e.self:Say("The maps are done. Now bring me one "
							.. "[oil stained crystal] from Meldrath himself, "
							.. "and the lair's raid will open to you.")
					end
				else
					e.self:Say("The [raid] on Crystallos awaits your word, "
						.. e.other:GetCleanName() .. ".")
				end
			elseif e.other:CountItem(prog.ITEM.master_base) > 0 then
				e.self:Say("A master crystal base, unworked. Place the four "
					.. "restored crystals within it -- clear, cloudy, "
					.. "glowing and light blue -- and the [charm] it yields "
					.. "will part the barrier.")
			else
				e.self:Say("The brothers sent you? Then take this [master "
					.. "crystal base]. Restore the four crystals with the "
					.. "golem essences and combine them within it.")
			end
		else
			e.self:Say("Hail, " .. e.other:GetCleanName() .. ". The barrier "
				.. "to Crystallos is not kind to the uninvited. Speak with "
				.. "the four brothers first.")
		end
	elseif e.message:findi("master crystal base")
		or e.message:findi("charm") then
		if prog.task_done(e.other, prog.TASK_BARRIER)
			and e.other:CountItem(prog.ITEM.master_base) == 0
			and e.other:CountItem(prog.ITEM.charm) == 0
			and not prog.has_flag(e.other, prog.FLG.crystallos) then
			e.other:SummonItem(prog.ITEM.master_base)
			e.self:Say("Guard it well. Decay and life make the clear; water, "
				.. "thunder and arcana the cloudy; fire and icicles the "
				.. "glowing; rage, sadness and mana the light blue.")
		else
			e.self:Say("One base per pair of hands, friend.")
		end
	elseif e.message:findi("explore") then
		if has_crystallos_access(e)
			and not prog.task_done(e.other, prog.TASK_EXPLORE_CRYSTALLOS)
			and not e.other:IsTaskActive(prog.TASK_EXPLORE_CRYSTALLOS) then
			e.self:Say("Fire, water, air and earth -- find the squires' "
				.. "rooms in each wing and my work is done.")
			eq.task_selector({ prog.TASK_EXPLORE_CRYSTALLOS })
		end
	elseif e.message:findi("raid") then
		if not prog.has_flag(e.other, prog.FLG.crystallos_raid) then
			e.self:Say("The lair opens only to those who have walked it and "
				.. "brought me the [oil stained crystal].")
			return
		end
		if e.other:GetLevel() < 70 then
			e.self:Say("Return at level 70, " .. e.other:GetCleanName() .. ".")
			return
		end
		local current = e.other:GetExpedition()
		if current.valid then
			e.self:Say("You already hold a claim to an expedition. Use it or let it lapse.")
			return
		end
		local dz = e.other:CreateExpedition(crystallos_raid)
		if dz.valid then
			dz:AddReplayLockout(CRYSTALLOS_RAID_LOCKOUT)
			e.self:Say("Awakened one. The barrier will carry your raid "
				.. "through. Strike true.")
		else
			e.self:Say("The barrier is restless -- ask me again shortly.")
		end
	elseif e.message:findi("ready") then
		local dz = e.other:GetExpedition()
		if dz.valid then
			e.self:Say("Pass through, " .. e.other:GetCleanName() .. ".")
			e.other:MovePCDynamicZone(dz:GetZoneID())
		else
			e.self:Say("You belong to no expedition.")
		end
	end
end

function event_trade(e)
	local item_lib = require("items")
	-- Oil Stained Crystal -> crystallos raid flag (consumed)
	if item_lib.check_turn_in(e.trade,
			{ item1 = prog.ITEM.oil_crystal }) then
		if prog.task_done(e.other, prog.TASK_EXPLORE_CRYSTALLOS) then
			prog.set(e.other, prog.FLG.crystallos_raid, 1)
			e.self:Say("Meldrath's grease, shed for the last time. The [raid] "
				.. "is yours to request, " .. e.other:GetCleanName() .. ".")
		else
			e.other:SummonItem(prog.ITEM.oil_crystal)
			e.self:Say("Walk the wings for me first, then we will speak of raids.")
		end
		return
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
