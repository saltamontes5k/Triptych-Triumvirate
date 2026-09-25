local takf = {
  expedition = { name="Takish-Hiz: Sandfall Corridors", min_players=1, max_players=54 },
  instance   = { zone="takf", version=50, duration=eq.seconds("3h") },
  zonein     = { x=402.18, y=1374.67, z=0, h=0 },
  compass    = { zone="nro", x=899, y=2680, z=-24.75 },
  safereturn = { zone="nro", x=899, y=2680, z=-24.75, h=0 }
}

local prog = require("nms_progression")

function event_say(e)
  if e.message:findi("ready") then
    local __dz = e.other:GetExpedition()
    if __dz.valid then
      e.other:MovePCDynamicZone(__dz:GetZoneID())
      return
    end
  end  if not prog.gate_stage(e.other, "DoN", "Takish Scout Nareen says, 'The Wayfarers will open these dungeons only to those who have toppled the elemental gods of the planes.'") then
    return
  end
  if e.message:findi("hail") then
    eq.get_entity_list():MessageClose(e.self, true, 100, MT.SayEcho, ("Takish Scout Nareen says, 'Hail, %s. The Sandfall Corridors are thick with the Geomantic Compact and their guards. We could use a strong arm.  Are you [" .. eq.say_link("interested") .. "]?'"):format(e.other:GetCleanName()))
  elseif e.message:findi("interested") then
    eq.get_entity_list():MessageClose(e.self, true, 100, MT.SayEcho, ("Takish Scout Nareen says, 'Mind the shifting sands, %s.  Nothing in Takish-Hiz stays still for long.'"):format(e.other:GetCleanName()))
    e.other:CreateExpedition(takf)
  end
end
