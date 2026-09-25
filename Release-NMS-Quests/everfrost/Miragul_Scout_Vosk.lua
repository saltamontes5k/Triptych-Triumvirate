local mirf = {
  expedition = { name="Miragul's Menagerie: The Forgotten Wastes", min_players=1, max_players=54 },
  instance   = { zone="mirf", version=50, duration=eq.seconds("3h") },
  zonein     = { x=-810, y=1321.41, z=60, h=0 },
  compass    = { zone="everfrost", x=5046, y=-1866, z=-64 },
  safereturn = { zone="everfrost", x=5046, y=-1866, z=-64, h=0 }
}

local prog = require("nms_progression")

function event_say(e)
  if e.message:findi("ready") then
    local __dz = e.other:GetExpedition()
    if __dz.valid then
      e.other:MovePCDynamicZone(__dz:GetZoneID())
      return
    end
  end  if not prog.gate_stage(e.other, "DoN", "Miragul Scout Vosk says, 'The Wayfarers will open these dungeons only to those who have toppled the elemental gods of the planes.'") then
    return
  end
  if e.message:findi("hail") then
    eq.get_entity_list():MessageClose(e.self, true, 100, MT.SayEcho, ("Miragul Scout Vosk says, 'Hail, %s. The Forgotten Wastes crawl with Miragul's failed experiments. Put them down before they wander into the peaks.  Are you [" .. eq.say_link("interested") .. "]?'"):format(e.other:GetCleanName()))
  elseif e.message:findi("interested") then
    eq.get_entity_list():MessageClose(e.self, true, 100, MT.SayEcho, ("Miragul Scout Vosk says, 'Watch for the vortices, %s.  They do not obey the rules of this world.'"):format(e.other:GetCleanName()))
    e.other:CreateExpedition(mirf)
  end
end
