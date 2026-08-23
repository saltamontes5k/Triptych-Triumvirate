----------------------------------------------------------------
-- Relv the Mysterious – Forest Cleansing (Instance‑safe, open access)
-- Updated: Jun 5 2025 – removed single‑party lockout. Now *any* player or
-- group can speak "we are ready" and be ported through while sharing the
-- same encounter state within the instance.
----------------------------------------------------------------

-- === Constants ===
local MEPHIT_FIRE   = 210098
local MEPHIT_SMOKE  = 210097 
local BOSS_ID       = 210245
local VFX_ID        = 98207

local REQUIRED_KILLS = 8
local WAVE_INTERVAL  = 30  -- seconds
local WAVE_SIZE      = 4
local MAX_WAVES      = 3

-- === Per‑instance scratch‑pad ===
local instance_state = {}
local function state()
  local id = eq.get_zone():GetInstanceID() or 0  -- 0 for static zones
  if not instance_state[id] then
    instance_state[id] = {
      kills        = 0,
      boss_spawned = false,
      wave_count   = 0,
      waves_running = false,
    }
  end
  return instance_state[id]
end

-- === Helper ===
local function MovePlayerGroupOrRaid(player, zone_id, instance_id, x, y, z, h)
  do return end
  if not player or not player:IsClient() then return end
  local client = player:CastToClient()
  local group  = client:GetGroup()

  if group and group:IsGroupMember(client) then
    for i = 0, group:GroupCount() - 1 do
      local m = group:GetMember(i)
      if m and m:IsClient() then
        m:CastToClient():MovePCInstance(zone_id, instance_id, x, y, z, h)
      end
    end
  else
    client:MovePCInstance(zone_id, instance_id, x, y, z, h)
  end
end

-- === Core Events ===
function event_spawn(e)
  e.self:SetBodyType(BT.Humanoid, true)
  e.self:SetTargetable(true)
  state() -- ensure table exists
end

function event_say(e)
  do return end
  local s = state()

  if e.message:findi("hail") then
    e.self:Say("'Greetings to you, small one. I see you have made great progress through our fair planar dwelling. Were it not for the dubious undertakings by someone. . . or something, I would be more than glad to welcome you here. Unfortunately, there have been dangerous tidings afoot. Just look at the trees around you. This destruction is the work of something altogether unseen, at least by me.[" .. eq.say_link("destruction") .. "]")

  elseif e.message:findi("destruction") then
    e.self:Say("There was a time when all the trees were green and alive, though as you can see, that time is no more. I am unsure what it is that has caused the damage, but I do know that whatever it is has caused a great deal of damage and will continue to do so unless someone like yourself has the courage to rid us of i [" .. eq.say_link("continue") .. "]")

  elseif e.message:findi("continue") then
    e.self:Emote("Relv looks about him at the charred trees and sighs. 'If this destruction is not stopped, we may soon not have any forest left, which would cause a great disturbance in the balance of this land. If it were in my power, I would go forth through the brush here and try and stop whatever is causing this. Unfortunately, I cannot leave, as I must protect the rest of the trees here from any beasts that might try to defile these lands any further. This is why I must ask for an outsider to help, so that I may send them forth through the brush into the clearing beyond to find the menace and destroy it at the source[" .. eq.say_link("tell me more") .. "]")

  elseif e.message:findi("tell me more") then
    e.self:Say("I have waited patiently for someone to come along to defeat the scourge on the land, and you may just be the one. If you feel you are courageous enough to go forth, please let me know and I will make preparations to assist you through the brush to end whatever suffering the forest is feeling beyond [" .. eq.say_link("courageous") .. "]")

  elseif e.message:findi("courageous") then
    e.self:Say("As I had hoped. I regret that I have only enough strength to send four parties through the brush to the other side, and only one party at a time. When each party is ready to move forth, tell me that you are ready and I will make a clearing for you to go through. Be wary, my magic will only last for three hours before you are pulled back to me, so do whatever you can before that time is up! [" .. eq.say_link('we are ready', false, 'you are ready') .. "]")

  elseif e.message:findi("we are ready") then
    e.self:Say("Then I wish you luck...")
    e.self:Emote("A powerfully green aura surrounds Relv...")

    local client      = e.other:CastToClient()
    local zone        = eq.get_zone()
    local zone_id     = zone:GetZoneID()
    local instance_id = zone:GetInstanceID()
    MovePlayerGroupOrRaid(client, zone_id, instance_id, -156.593, 5090.91, -555.29, 431)

    -- Start encounter if it isn’t already in motion
    if not s.waves_running and not s.boss_spawned then
      s.wave_count   = 0
      s.kills        = 0
      s.waves_running = true
      eq.set_timer("spawn_wave", WAVE_INTERVAL * 1000)
    end
  end
end

function event_timer(e)
  do return end
  local s = state()

  if e.timer == "spawn_wave" then
    s.wave_count = s.wave_count + 1

    if s.wave_count > MAX_WAVES then
      eq.stop_timer("spawn_wave")
      s.waves_running = false
      if not s.boss_spawned then
        s.boss_spawned = true
        eq.zone_emote(15, "The last wave of enemies has been vanquished. A powerful presence approaches!")
        eq.unique_spawn(BOSS_ID, 0, 0, -740, 5150, -492, 0)
      end
    else
      for _ = 1, WAVE_SIZE do
        eq.spawn2(MEPHIT_FIRE,  0, 0, -610 + math.random(-10, 10), 5252 + math.random(-10, 10), -492,                     10)
        eq.spawn2(MEPHIT_SMOKE, 0, 0, -867 + math.random(-10, 10), 5038 + math.random(-10, 10), -492 + math.random(-10,10),  0)
      end
      eq.zone_emote(15, "A new wave of mephits has arrived! (" .. s.wave_count .. "/" .. MAX_WAVES .. ")")
    end

  elseif e.timer == "reset_party" then
    eq.stop_timer("reset_party")
    instance_state[eq.get_zone():GetInstanceID() or 0] = nil  -- clean slate
  end
end

function event_death(e)
  local npc_id = e.self:GetNPCTypeID()
  local s      = state()

  if npc_id == MEPHIT_FIRE or npc_id == MEPHIT_SMOKE then
    if not s.boss_spawned then
      s.kills = s.kills + 1
      eq.zone_emote(15, "The forest trembles as another mephit falls! (" .. s.kills .. "/" .. REQUIRED_KILLS .. ")")

      if s.kills >= REQUIRED_KILLS then
        s.boss_spawned = true
        eq.unique_spawn(BOSS_ID, 0, 0, e.self:GetX(), e.self:GetY(), e.self:GetZ(), e.self:GetHeading())
      end
    end

  elseif npc_id == BOSS_ID then
    eq.zone_emote(15, "The forest calms as the source of the destruction is silenced.")
    eq.spawn2(VFX_ID, 0, 0, e.self:GetX(), e.self:GetY(), e.self:GetZ(), e.self:GetHeading())
    eq.set_timer("reset_party", 60 * 1000)
  end
end