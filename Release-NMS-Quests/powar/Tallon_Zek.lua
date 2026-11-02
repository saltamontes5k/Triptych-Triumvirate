-- powar raid: Tallon Zek — the marksman brother.
-- PoP-ized mechanics: aimed volleys on a timer, warmasters at 50%, and the
-- shared lockout when both brothers die.
local P = require("powar_shared")

local LOCKOUT_NAME = "Plane of War: The Zek Brothers"
local LOCKOUT = eq.seconds("72h")
local half_done = false

function event_spawn(e)
  half_done = false
  e.self:Emote("stands rooted across the war-room, sighting down an arrow older than the castle.")
end

function event_combat(e)
  if e.joined then
    eq.set_timer("aim", 45000)
  else
    eq.stop_timer("aim")
  end
end

function event_timer(e)
  if e.timer == "aim" then
    e.self:ZoneEmote(15, "Tallon Zek takes aim on this area - MOVE!")
  end
end

function event_hp(e)
  local hp = e.self:GetHP() / e.self:GetMaxHP() * 100
  if hp <= 50 and not half_done then
    half_done = true
    local x, y, z = e.self:GetX(), e.self:GetY(), e.self:GetZ()
    eq.unique_spawn(P.NPC.r_warmaster, 0, 0, x + 25, y + 15, z, 0)
    eq.unique_spawn(P.NPC.r_lifetaker, 0, 0, x - 25, y + 15, z, 0)
    e.self:Emote("switches to barbed shafts, and his personal guard steps out of the smoke!")
  end
end

function event_death(e)
  eq.stop_timer("aim")
  local vallon = eq.get_entity_list():GetNPCByNPCTypeID(1520001314)
  if vallon == nil or not vallon.valid or vallon:IsDead() then
    local exp = eq.get_expedition()
    if exp.valid and not exp:HasLockout(LOCKOUT_NAME) then
      exp:AddLockout(LOCKOUT_NAME, LOCKOUT)
    end
    eq.zone_emote(15, "Both Zek brothers have fallen. The Plane of War falls silent - for about three days.")
  else
    eq.zone_emote(15, "Tallon Zek falls! Vallon Zek calls the war-host to himself!")
  end
end
