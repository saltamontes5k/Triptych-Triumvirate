-- kaladima/a_wedding_guest.lua
-- NMS monster mission: the Dwarven Keg Wedding (kaladima v25).
-- Every wedding party member AND every objector shares the name
-- a_wedding_guest, so this one script serves all of them; GetNPCTypeID()
-- identifies the role.
--
-- It reports three things to the invisible controller (1520001920):
--   * the checkpoint spell landing on the right NPC (signals 1-5),
--   * the optional group-size extra tasks (signals 30-37),
--   * each objector hit by Keg Blast / Gale Force (signals 20-26),
--   * any guest death at all (signal 99 -- "alcohol kills").
-- The controller also polls the checkpoint buffs, so a missed signal is not
-- fatal; the death signal is the primary pacifism check.

local CONTROLLER_ID = 1520001920

local MATRON        = 1520001900
local UNCLE1        = 1520001901
local UNCLE2        = 1520001902
local BEST_MAN      = 1520001903
local BREWMASTER    = 1520001904

-- Optional extra-quest guests (spawned by the controller for 2-6 kegs).
local AUNT1         = 1520001917
local AUNT2         = 1520001918
local FATHER        = 1520001919
local GROOM         = 1520001921
local BRIDE1        = 1520001922
local BRIDE2        = 1520001923
local GRAND1        = 1520001924
local GRAND2        = 1520001925

local OBJECTOR_BASE = 1520001910
local OBJECTOR_LAST = 1520001916

local MALAISE    = 8300  -- Stale Brew (the malo)
local LEVITATE   = 261   -- Beer Bubbles (single-target Levitate)
local SLEEP      = 7532  -- Pass Out
local SLEEP_ALT  = 7531
local CHARM      = 182   -- Brewmaster's Bidding
local CHARM_ALT  = 300
local GALE_FORCE = 8328  -- Keg Blast

local function signal(n)
	eq.signal(CONTROLLER_ID, n)
end

function event_spell_effect(e)
	local t     = e.self:GetNPCTypeID()
	local spell = e.spell_id
	local out   = 0

	if t == MATRON and spell == MALAISE then
		out = 1
	elseif t == UNCLE1 and spell == LEVITATE then
		out = 2
	elseif t == UNCLE2 and spell == LEVITATE then
		out = 3
	elseif t == BEST_MAN and (spell == SLEEP or spell == SLEEP_ALT) then
		out = 4
	elseif t == BREWMASTER and (spell == CHARM or spell == CHARM_ALT) then
		out = 5
	-- Optional group-size extra tasks.
	elseif t == AUNT1 and spell == LEVITATE then
		out = 30
	elseif t == AUNT2 and spell == LEVITATE then
		out = 31
	elseif t == FATHER and spell == MALAISE then
		out = 32
	elseif t == GROOM and (spell == CHARM or spell == CHARM_ALT) then
		out = 33
	elseif t == BRIDE1 and (spell == SLEEP or spell == SLEEP_ALT) then
		out = 34
	elseif t == BRIDE2 and (spell == SLEEP or spell == SLEEP_ALT) then
		out = 35
	elseif t == GRAND1 and spell == LEVITATE then
		out = 36
	elseif t == GRAND2 and spell == LEVITATE then
		out = 37
	elseif spell == GALE_FORCE and t >= OBJECTOR_BASE and t <= OBJECTOR_LAST then
		out = 20 + (t - OBJECTOR_BASE)
	end

	if out > 0 then
		signal(out)
	end
end

function event_death(e)
	signal(99)
end
