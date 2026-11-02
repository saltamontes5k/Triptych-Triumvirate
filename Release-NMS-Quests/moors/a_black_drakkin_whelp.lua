-- moors/a_black_drakkin_whelp.lua
-- King of the Monsters (moors v40): the black whelp -- the clever one.
-- The first bite that lands triggers its one Harmstring (stock Harmshield,
-- a breath of invulnerability) and a taunt; after that it is just another
-- meal. Signal 106 to the controller.

local CONTROLLER = 1520001970
local COLOR      = 6
local STONE      = { x = -1378.8, y = -612.8 }
local JITTER     = 40
local HARMSTRING = 203 -- stock Harmshield

local harmstring_used = false

function event_spawn(e)
	e.self:SetDisableMelee(true)
	eq.set_timer("waddle", 3000)
end

function event_timer(e)
	if e.timer == "waddle" then
		e.self:MoveTo(STONE.x + math.random(-JITTER, JITTER), STONE.y + math.random(-JITTER, JITTER), e.self:GetZ(), 0, false)
	end
end

function event_damage_taken(e)
	if not harmstring_used and e.damage > 0 then
		harmstring_used = true
		e.self:CastSpell(HARMSTRING, e.self:GetID())
		e.self:Say("Harmstring! HAHAHA! You cannot devour me, overgrown gecko!")
	end
end

function event_death_complete(e)
	local killer = eq.get_entity_list():GetClientByID(e.killer_id)
	if killer and killer:GetRace() == 436 then
		eq.signal(CONTROLLER, 100 + COLOR)
	end
end
