-- powar: Jorgar the Pacifist — requester for the Zek brothers raid
-- (Bonzz pow.htm: 6+ players live; PoP-ized to 3+. 72h lockout on a win,
-- applied by the Zeks themselves.)
local P = require("powar_shared")

local EXPEDITION_NAME = "Plane of War: The Zek Brothers"

local dz_spec = {
  expedition = { name = EXPEDITION_NAME, min_players = 3, max_players = 54 },
  instance = { zone = "powar", version = 0, duration = eq.seconds("6h") },
  zonein = { x = -465.0, y = 2592.0, z = 195.0, h = 0.0 }
}

function event_say(e)
  local c = e.other
  if e.message:findi("hail") then
    P.say(e, "Jorgar the Pacifist sits apart from the war with his back to all of it. 'I do not fight. I count those who do, and I open doors for the serious ones. Say 'serious' if your people mean to answer the Zek brothers - Tallon and Vallon both, at the south end of the field. Say 'ready' if the door is already open for you.'")
  elseif e.message:findi("serious") then
    if c:GetExpedition().valid then
      P.say(e, "You already hold a war-room. Say 'ready' and walk through it.")
      return
    end
    local dz = c:CreateExpedition(dz_spec)
    if dz.valid then
      dz:AddReplayLockout(eq.seconds("6h"))
      P.say(e, "The door is open, and Jorgar writes your names where the war can read them. Bring your people, say 'ready' to me inside, and then say 'challenge' to either brother when you are all standing in the Zek room. The doors close when the war starts.")
    else
      P.say(e, "The war-room refuses. Tidy your raid - everyone here, no one mid-instance - and ask again.")
    end
  elseif e.message:findi("ready") then
    local exp = c:GetExpedition()
    if exp.valid then
      c:MovePCDynamicZone(exp:GetZoneID())
    else
      P.say(e, "You hold no war-room. Say 'serious' first.")
    end
  end
end

function event_trade(e)
  local item_lib = require("items")
  item_lib.return_items(e.self, e.other, e.trade)
end
