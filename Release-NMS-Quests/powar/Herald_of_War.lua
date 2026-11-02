-- powar: Herald of War — collects the Token of War and closes Dyrginal's chain
local P = require("powar_shared")
local item_lib = require("items")

local TOKEN = 86240 -- Token of War

function event_say(e)
  local c = e.other
  if e.message:findi("hail") then
    if P.flagged(c, "legion_up") then
      P.say(e, "The Mark was lit, and the Mark was answered. Give me the Token of War from the legionnaire's body, and the War Fields will know your name.")
    else
      P.say(e, "The herald regards you without interest. 'The Mark is not yet lit. Speak to Dyrginal.'")
    end
  end
end

function event_trade(e)
  local c = e.other
  if item_lib.check_turn_in(e.trade, { item1 = TOKEN }) then
    P.set(c, "dyrginal", "1")
    P.set(c, "legion_up", "0")
    P.say(e, "Token received, warbrand. The Forge of War knows your name now. Dyrginal's work is done — the castles beyond the Field of Strife will speak of you.")
    e.other:QuestReward(e.self, 0, 0, 0, 0, 0, 50000)
    e.self:Depop()
  else
    item_lib.return_items(e.self, e.other, e.trade)
  end
end
