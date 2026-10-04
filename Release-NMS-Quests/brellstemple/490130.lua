-- the_Unfinished_Creation (490130) -- Brell's Temple v2, Trial of Creation.
-- Tracked source: Release-NMS-Quests/brellstemple/490130.lua.
-- Rasper: miscRaidProg.html.
--
-- Simplified live trial:
--   * every 30s an unstable flux (6k AE, 200 range);
--   * every 60s two creation motes -- a mote that lives 30s heals the
--     creation 3% (finish it, or it finishes itself);
-- On death: Treasure_of_Creation chest (9 Amulets), 72h lockout, and the
-- trial_creation flag for surviving raiders.

local prog = require("uf_progression")

local MOTE = 490131
local CHEST = prog.CHEST.creation
local LOCKOUT = eq.seconds("72h")

local engaged = false
local adds = {}

local function engage(e)
	if engaged then return end
	engaged = true
	eq.set_timer("flux", 30000)
	eq.set_timer("motes", 60000)
	eq.zone_emote(15, "The Unfinished Creation opens too many eyes. 'ALMOST. ALMOST.'")
end

function event_combat(e)
	if e.joined then
		engage(e)
		eq.stop_timer("resetcheck")
	else
		eq.set_timer("resetcheck", 60000)
	end
end

function event_timer(e)
	if e.timer == "resetcheck" then
		if not e.self:IsEngaged() then
			engaged = false
			prog.clear_adds(adds)
			adds = {}
			for _, t in ipairs({ "flux", "motes", "mote_heal" }) do eq.stop_timer(t) end
			e.self:Heal()
			eq.zone_emote(15, "The Unfinished Creation stills. The event has reset.")
		end
		return
	end
	if not engaged then return end
	local x, y = e.self:GetX(), e.self:GetY()

	if e.timer == "flux" then
		eq.zone_emote(13, "Unstable creation flux washes the chamber!")
		for _, c in ipairs(prog.alive_clients(x, y, 200)) do
			c:Damage(e.self, 6000, 0, 28)
		end
	elseif e.timer == "motes" then
		for i = 1, 2 do
			local m = eq.spawn2(MOTE, 0, 0, x + math.random(-50, 50),
				y + math.random(-50, 50), e.self:GetZ(), 0)
			if m then adds[#adds + 1] = m:GetID() end
		end
		eq.set_timer("mote_heal", 30000)
		eq.zone_emote(15, "Creation motes gather -- deny them to the Creation!")
	elseif e.timer == "mote_heal" then
		local el = eq.get_entity_list()
		local alive = false
		for _, id in ipairs(adds) do
			local m = el:GetNPCByID(id)
			if m and m.valid then
				alive = true
				break
			end
		end
		if alive then
			eq.zone_emote(13, "The Creation absorbs its motes -- it is restoring itself!")
			e.self:SetHP(e.self:GetHP() + math.floor(e.self:GetMaxHP() * 0.03))
		end
		prog.clear_adds(adds)
		adds = {}
	end
end

function event_death_complete(e)
	prog.clear_adds(adds)
	adds = {}
	for _, t in ipairs({ "flux", "motes", "mote_heal" }) do eq.stop_timer(t) end
	eq.zone_emote(15, "The Unfinished Creation is finished -- ended. The second trial is passed.")
	prog.spawn_chest(e, CHEST, "Trial of Creation")
	local exp = eq.get_expedition()
	if exp.valid and not exp:HasLockout("Trial of Creation") then
		exp:AddLockout("Trial of Creation", LOCKOUT)
	end
	for _, c in ipairs(prog.alive_clients(e.self:GetX(), e.self:GetY(), 300)) do
		prog.set(c, prog.FLG.trial_creation, 1)
		c:Message(15, "You have passed the Trial of Creation.")
	end
end
