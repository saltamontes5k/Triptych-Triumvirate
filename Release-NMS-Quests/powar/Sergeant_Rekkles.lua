-- powar: Sergeant Rekkles — Castle Tamrel recruiter
-- Tallon Soldier Insignia turn-ins build Tamrel standing; at Max Ally he
-- vouches for you to Lieutenant Ess Pekky (who holds the retreat dust).
local P = require("powar_shared")
local item_lib = require("items")

local TALLON_SOLDIER = 88465

function event_say(e)
  local c = e.other
  local standing, label = P.standing(c, "tamrel")
  if e.message:findi("hail") then
    if P.flagged(c, "rekkles_done") then
      P.say(e, "The sergeant salutes. 'Give my regards to the lieutenant — and mind the walls, they bite.'")
    elseif not P.flagged(c, "mines") then
      P.say(e, "Rekkles eyes you from the gate. 'This is Tamrel ground, stranger. The Field decides who belongs — pay the tithe at the wall first.'")
    else
      P.say(e, "Sergeant Rekkles, recruiter for Castle Tamrel. We fight Rulnavis across the field, and the Wall eats soldiers faster than the field does. Bring me Tallon Soldier Insignias — one per fallen soldier, pulled from the field trash — and Tamrel will learn your name. Your standing: " .. label .. ". Say 'help' for details.")
    end
  elseif e.message:findi("help") then
    P.say(e, "Tamrel opens her gates to the worthy. Insignias earn standing; standing earns the castle. At Max Ally I will write the vouching that gets you Lieutenant Ess Pekky's ear — and her dust.")
  end
end

function event_trade(e)
  local c = e.other
  if not P.flagged(c, "mines") then
    item_lib.return_items(e.self, e.other, e.trade)
    P.say(e, "The Field decides who belongs. Pay the tithe at the wall first.")
    return
  end
  if P.flagged(c, "rekkles_done") then
    item_lib.return_items(e.self, e.other, e.trade)
    P.say(e, "You stand at Max Ally — the castle owes you nothing more in insignias. Take your vouching to Ess Pekky.")
    return
  end
  if item_lib.check_turn_in(e.trade, { item1 = TALLON_SOLDIER }) then
    local v = P.fac_up(c, "tamrel", 4)
    if v >= 100 then
      P.set(c, "rekkles_done", "1")
      P.say(e, "That settles it — Max Ally, and no soldier of ours could say otherwise. I will send word to Lieutenant Ess Pekky inside. She holds Tamrel's Tactical Retreat Dust, and now she will hold it slightly less selfishly.")
    else
      local _, label = P.standing(c, "tamrel")
      P.say(e, "Tamrel hears of the fallen, and of you. Standing: " .. label .. ".")
    end
  else
    item_lib.return_items(e.self, e.other, e.trade)
  end
end
