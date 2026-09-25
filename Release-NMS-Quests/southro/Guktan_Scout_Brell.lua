local gukb = {
  expedition = { name="Deepest Guk: The Drowning Crypt", min_players=1, max_players=54 },
  instance   = { zone="gukb", version=50, duration=eq.seconds("3h") },
  zonein     = { x=-745, y=-915.87, z=0, h=0 },
  compass    = { zone="sro", x=1001, y=-1468, z=-23.88 },
  safereturn = { zone="sro", x=1001, y=-1468, z=-23.88, h=0 }
}

local prog = require("nms_progression")

function event_say(e)
  if e.message:findi("ready") then
    local __dz = e.other:GetExpedition()
    if __dz.valid then
      e.other:MovePCDynamicZone(__dz:GetZoneID())
      return
    end
  end  if not prog.gate_stage(e.other, "DoN", "Guktan Scout Brell says, 'The Wayfarers will open these dungeons only to those who have toppled the elemental gods of the planes.'") then
    return
  end
  if e.message:findi("hail") then
    eq.get_entity_list():MessageClose(e.self, true, 100, MT.SayEcho, ("Guktan Scout Brell says, 'Hail, %s. The Drowning Crypt is flooded with the restless dead, and our kin among them. Will you help us lay them to rest?  Are you [" .. eq.say_link("interested") .. "]?'"):format(e.other:GetCleanName()))
  elseif e.message:findi("interested") then
    eq.get_entity_list():MessageClose(e.self, true, 100, MT.SayEcho, ("Guktan Scout Brell says, 'Bless you, %s.  Descend into the crypt and put an end to the Lich that rules it.'"):format(e.other:GetCleanName()))
    e.other:CreateExpedition(gukb)
  end
end
