local ruje = {
  expedition = { name="The Rujarkian Hills: Drudge Hollows", min_players=1, max_players=54 },
  instance   = { zone="ruje", version=50, duration=eq.seconds("3h") },
  zonein     = { x=-1619, y=1254.3, z=-180, h=0 },
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
  end  if not prog.gate_stage(e.other, "DoN", "Rujarkian Scout Orlo says, 'The Wayfarers will open these dungeons only to those who have toppled the elemental gods of the planes.'") then
    return
  end
  if e.message:findi("hail") then
    eq.get_entity_list():MessageClose(e.self, true, 100, MT.SayEcho, ("Rujarkian Scout Orlo says, 'Hail, %s. The Drudge Hollows are where the orcs send those they have broken. Few who go down come back up.  If you can rally the call of your friends, perhaps you can help us with a serious [" .. eq.say_link("problem") .. "].'"):format(e.other:GetCleanName()))
  elseif e.message:findi("problem") then
    eq.get_entity_list():MessageClose(e.self, true, 100, MT.SayEcho, "Rujarkian Scout Orlo says, 'A taskmaster named Dokorel rules the hollows with an iron fist. End him and the drudges may yet see the sun again. Are you [" .. eq.say_link("interested") .. "]?'")
  elseif e.message:findi("interested") then
    eq.get_entity_list():MessageClose(e.self, true, 100, MT.SayEcho, ("Rujarkian Scout Orlo says, 'Watch your step down there, %s.  The dark hides more than orcs.'"):format(e.other:GetCleanName()))
    e.other:CreateExpedition(ruje)
  end
end
