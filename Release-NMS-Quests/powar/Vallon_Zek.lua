-- powar raid: Vallon Zek — adds every 5%, skirmisher/priest every 95s,
-- and the war's lockout. (PoP-ized Rathe-council-style 2-group raid;
-- mechanics simplified from Bonzz's write-up: no clones, no swap.)
local P = require("powar_shared")

local LOCKOUT_NAME = "Plane of War: The Zek Brothers"
local LOCKOUT = eq.seconds("72h")
local last_threshold = 100

-- six spawn points around the south war-room
local points = {
  { 0, -4250 }, { -80, -4300 }, { 80, -4300 },
  { -120, -4400 }, { 120, -4400 }, { 0, -4520 },
}
local point_i = 0

local function next_point()
  point_i = point_i + 1
  if point_i > #points then point_i = 1 end
  return points[point_i][1], points[point_i][2]
end

local function add_type()
  local roll = math.random(1, 8)
  if roll == 1 then return P.NPC.r_archer
  elseif roll == 2 then return P.NPC.r_marauder
  elseif roll == 3 then return P.NPC.r_slavebringer
  elseif roll == 4 then return P.NPC.r_warmaster
  elseif roll == 5 then return P.NPC.r_lifetaker
  elseif roll == 6 then return P.NPC.r_flamespeaker
  elseif roll == 7 then return P.NPC.r_warbrute
  else return P.NPC.r_provost end
end

function event_spawn(e)
  last_threshold = 100
  e.self:Emote("sits rooted in the war-room, smiling the smile of someone who has already read every ending.")
end

function event_combat(e)
  if e.joined then
    eq.set_timer("skirmish", 95000)
    eq.zone_emote(15, "Vallon Zek's smile widens. 'Begin.'")
  else
    eq.stop_timer("skirmish")
  end
end

function event_hp(e)
  local hp = e.self:GetHP() / e.self:GetMaxHP() * 100
  while hp <= last_threshold - 5 and last_threshold > 5 do
    last_threshold = last_threshold - 5
    local x, y = next_point()
    eq.unique_spawn(add_type(), 0, 0, x + math.random(-15, 15), y + math.random(-15, 15), 0, 0)
    if last_threshold % 10 == 0 then
      e.self:Emote("raises a hand, and the war-room answers with soldiers!")
    end
  end
end

function event_timer(e)
  if e.timer == "skirmish" then
    local x, y = next_point()
    eq.unique_spawn(P.NPC.r_skirmisher, 0, 0, x, y, 0, 0)
    local px, py = next_point()
    eq.unique_spawn(P.NPC.r_priest, 0, 0, px, py, 0, 0)
    e.self:Emote("whistles, and a skirmisher with a priest at his heel slip into the room!")
  end
end

function event_death(e)
  eq.stop_timer("skirmish")
  local tallon = eq.get_entity_list():GetNPCByNPCTypeID(1520001313)
  if tallon == nil or not tallon.valid or tallon:IsDead() then
    local exp = eq.get_expedition()
    if exp.valid and not exp:HasLockout(LOCKOUT_NAME) then
      exp:AddLockout(LOCKOUT_NAME, LOCKOUT)
    end
    eq.zone_emote(15, "Both Zek brothers have fallen. The Plane of War falls silent - for about three days.")
  else
    eq.zone_emote(15, "Vallon Zek falls! Tallon Zek takes aim with everything he has left!")
  end
end
