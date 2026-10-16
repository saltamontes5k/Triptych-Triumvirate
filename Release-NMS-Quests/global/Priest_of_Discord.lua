-- Priest_of_Discord (global) - Tome of Order and Discord / PvP opt-in
--
-- Every Priest of Discord in a zone without its own script (the old-world city
-- priests) binds here. This file wins the shadow pair over global/Priest_of_Discord.pl
-- in this engine (lua registers before perl), so the tome behavior lives HERE and
-- the .pl was deleted - never keep behavior in both halves of the pair.
--
-- Dialogue per the live-era "Become PvP" quest: hail -> tome lore -> summon the
-- Tome of Order and Discord -> hand it back to turn PvP on.

function event_say(e)
  if e.message:findi("hail") then
    e.self:Say("Hello, " .. e.other:GetCleanName() .. ".  If you have come to seek the way of Discord in your life, then ask me about your [" .. eq.say_link("Tome of Order and Discord") .. "].")
  elseif e.message:findi("tome of order and discord") then
    e.self:Say("The Tome of Order and Discord was penned by the seventh member of the Tribunal and has become the key to a life of Discord, in spite of the author's pitiful warnings. Do you not have one, child of Order? Would you [" .. eq.say_link("like to read") .. "] it?")
  elseif e.message:findi("read") then
    e.self:Say("Very well. Here you go. Simply return it to me to be released from the chains of Order.")
    e.other:SummonItem(18700) -- Item: Tome of Order and Discord
  end
end

function event_trade(e)
  local item_lib = require("items")
  if item_lib.check_turn_in(e.trade, { item1 = 18700 }) then -- Item: Tome of Order and Discord
    e.self:Say("I see you wish to join us in Discord! Welcome! By turning your back on the protection of Order you are now open to many more opportunities for glory and power. Remember that you can now be harmed by those who have also heard the call of Discord.")
    e.other:Ding()
    e.other:SetPVP(true)
  end
  item_lib.return_items(e.self, e.other, e.trade)
end
