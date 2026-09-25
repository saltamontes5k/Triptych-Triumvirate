local gukd = {
  expedition = { name="Deepest Guk: The Mushroom Grove", min_players=1, max_players=54 },
  instance   = { zone="gukd", version=50, duration=eq.seconds("3h") },
  zonein     = { x=-483, y=988.4, z=-27, h=0 },
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
  end  if not prog.gate_stage(e.other, "DoN", "Guktan Scout Moka says, 'The Wayfarers will open these dungeons only to those who have toppled the elemental gods of the planes.'") then
    return
  end
  if e.message:findi("hail") then
    eq.get_entity_list():MessageClose(e.self, true, 100, MT.SayEcho, ("Guktan Scout Moka says, 'Hail, %s. The Mushroom Grove has been overrun by the cursed Korta. We need someone to cull them before they spread further.  Are you [" .. eq.say_link("interested") .. "]?'"):format(e.other:GetCleanName()))
  elseif e.message:findi("interested") then
    eq.get_entity_list():MessageClose(e.self, true, 100, MT.SayEcho, ("Guktan Scout Moka says, 'Take care in the grove, %s.  The spores themselves can kill.'"):format(e.other:GetCleanName()))
    e.other:CreateExpedition(gukd)
  end
end
