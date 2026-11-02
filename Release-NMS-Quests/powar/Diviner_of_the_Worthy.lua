-- powar: Diviner of the Worthy — closes Katka's rebellion chain
local P = require("powar_shared")
local item_lib = require("items")

local TOKEN = 97500 -- Token of Reclaimed Honor

function event_say(e)
  local c = e.other
  if e.message:findi("hail") then
    if P.flagged(c, "katka") then
      P.say(e, "The divination holds: the mines are worthy, and so are you.")
    elseif P.get(c, "katka_started") then
      P.say(e, "I read what the blast shakes loose. Three tokens of reclaimed honor — from the shades Bolgorn's powder drags up — and I will name this rebellion worthy before the War Fields themselves.")
    else
      P.say(e, "The worthy are few. Katka knows the road to me.")
    end
  end
end

function event_trade(e)
  local c = e.other
  if item_lib.check_turn_in(e.trade, { item1 = TOKEN, item2 = TOKEN, item3 = TOKEN }) then
    P.set(c, "katka", "1")
    P.fac_up(c, "tamrel", 10)
    P.say(e, "Three tokens, three judgments, one verdict: worthy. The mines of Narikor stand redeemed — and Castle Tamrel will hear that you are a name worth knowing.")
    e.other:QuestReward(e.self, 0, 0, 0, 0, 0, 25000)
  else
    item_lib.return_items(e.self, e.other, e.trade)
  end
end
