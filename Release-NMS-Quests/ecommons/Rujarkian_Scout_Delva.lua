local rujb = {
  expedition = { name="The Rujarkian Hills: Bloodied Quarries", min_players=1, max_players=54 },
  instance   = { zone="rujb", version=50, duration=eq.seconds("3h") },
  zonein     = { x=-544.45, y=-328, z=-25, h=0 },
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
  end  if not prog.gate_stage(e.other, "DoN", "Rujarkian Scout Delva says, 'The Wayfarers will open these dungeons only to those who have toppled the elemental gods of the planes.'") then
    return
  end
  if e.message:findi("hail") then
    eq.get_entity_list():MessageClose(e.self, true, 100, MT.SayEcho, ("Rujarkian Scout Delva says, 'Hail, %s. The Bloodied Quarries are worked day and night by orcish slavers. We mean to break their hold.  If you can rally the call of your friends, perhaps you can help us with a serious [" .. eq.say_link("problem") .. "].'"):format(e.other:GetCleanName()))
  elseif e.message:findi("problem") then
    eq.get_entity_list():MessageClose(e.self, true, 100, MT.SayEcho, "Rujarkian Scout Delva says, 'The orcs drive their slaves hard in the quarries, and a taskmaster named Devrak keeps them in line through fear. Cut down the taskmaster and thin the Rujarkian ranks. Are you [" .. eq.say_link("interested") .. "]?'")
  elseif e.message:findi("interested") then
    eq.get_entity_list():MessageClose(e.self, true, 100, MT.SayEcho, ("Rujarkian Scout Delva says, 'Strike hard and fast, %s.  We will be right behind you.'"):format(e.other:GetCleanName()))
    e.other:CreateExpedition(rujb)
  end
end
