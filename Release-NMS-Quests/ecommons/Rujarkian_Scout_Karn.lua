local rujc = {
  expedition = { name="The Rujarkian Hills: Wind Bridges", min_players=1, max_players=54 },
  instance   = { zone="rujc", version=50, duration=eq.seconds("3h") },
  zonein     = { x=-1097, y=256.66, z=-9, h=0 },
  compass    = { zone="sro", x=1346.18, y=-2099.33, z=-88.0377 },
  safereturn = { zone="sro", x=1349, y=-2161, z=-87, h=0 }
}

local prog = require("nms_progression")

function event_say(e)
  -- NMS: enter your active expedition directly (like the Echo projections)
  if e.message:findi("ready") then
    local __dz = e.other:GetExpedition()
    if __dz.valid then
      e.other:MovePCDynamicZone(__dz:GetZoneID())
      return
    end
  end  if not prog.gate_stage(e.other, "DoN", "Rujarkian Scout Karn says, 'The Wayfarers will open these dungeons only to those who have toppled the elemental gods of the planes.'") then
    return
  end
  if e.message:findi("hail") then
    eq.get_entity_list():MessageClose(e.self, true, 100, MT.SayEcho, ("Rujarkian Scout Karn says, 'Hail, %s. The Wind Bridges span the Rujarkian chasms, and the orcs guard them well.  If you can rally the call of your friends, perhaps you can help us with a serious [" .. eq.say_link("problem") .. "].'"):format(e.other:GetCleanName()))
  elseif e.message:findi("problem") then
    eq.get_entity_list():MessageClose(e.self, true, 100, MT.SayEcho, "Rujarkian Scout Karn says, 'A taskmaster named Velrek commands the bridge garrison. Break his hold on the bridges and the Rujarkian supply lines will falter. Are you [" .. eq.say_link("interested") .. "]?'")
  elseif e.message:findi("interested") then
    eq.get_entity_list():MessageClose(e.self, true, 100, MT.SayEcho, ("Rujarkian Scout Karn says, 'Mind the drop, %s.  The bridges are no place to stumble.'"):format(e.other:GetCleanName()))
    e.other:CreateExpedition(rujc)
  end
end
