-- powar: High Strategist Galben — the strategist's chain: work orders, the
-- Blessed Rulnavian Sword, A Colossal Task, and Tactical Strike.
local P = require("powar_shared")
local item_lib = require("items")

local BSMITH_WO = 97450
local BOWYER_WO = 97451
local BSMITH_UPD = 97458
local BOWYER_UPD = 97463
local REQUISITION = 97464     -- Blacksmith's Requisiton
local ENTREATY = 97465        -- Blessed Entreaty
local NOTE = 97468            -- Note for High Strategist Galben
local PLAN = 97469            -- Plan for Narikor
local COLOSSUS_REQ = 97470
local BOW_REQ = 97471         -- Assault Bow Requisition

function event_say(e)
  local c = e.other
  local standing, label = P.standing(c, "rulnavis")
  if e.message:findi("hail") then
    if P.flagged(c, "tactical") then
      P.say(e, "Galben, High Strategist, does not rise from his maps. 'Tactical Strike is written in the margin now. It stays written.'")
    elseif P.flagged(c, "colossal") and not c:HasItem(PLAN) and not P.flagged(c, "plan_given") then
      P.set(c, "plan_given", "1")
      e.other:SummonItem(PLAN)
      P.say(e, "A Colossal Task, done twice over. Here - the Plan for Narikor. It was meant for Katka's rebels, and what was meant for rebels can pass through a strategist's hands twice. Bring it back and I will sign the Tactical Strike.")
    elseif P.flagged(c, "plan_given") and c:HasItem(PLAN) then
      P.say(e, "The plan came back? Then the war moves a page. Hand it over and take your requisitions.")
    elseif standing >= 40 then
      P.say(e, "Galben, High Strategist of Castle Rulnavis, second floor library. The requisitions end at Dulkot; the war begins at this desk. Standing " .. label .. " - enough for work orders. Say 'orders' and we will forge something worth blessing.")
    else
      P.say(e, "The strategist does not look up. 'Kindly, at least. The desk is not for strangers.'")
    end
  elseif e.message:findi("orders") and standing >= 40 and not P.flagged(c, "galben_orders") then
    P.set(c, "galben_orders", "1")
    e.other:SummonItem(BSMITH_WO)
    e.other:SummonItem(BOWYER_WO)
    P.say(e, "Two work orders: one for Olmac the smith, by the forge northwest of the entrance; one for Fletcher Forlen, far south wall of the first floor. Updated orders come back here - and then we talk about blessings and colossi.")
  end
end

function event_trade(e)
  local c = e.other
  local standing = (tonumber(P.get(c, "rulnavis_fac")) or 0)
  if item_lib.check_turn_in(e.trade, { item1 = BSMITH_UPD, item2 = BOWYER_UPD }) and P.flagged(c, "galben_orders") then
    e.other:SummonItem(REQUISITION)
    e.other:SummonItem(ENTREATY)
    P.say(e, "Steel and wood, requisitioned honestly - a first. Take the Blacksmith's Requisition to Olmac for the Hardened Rulnavian Sword, and the Blessed Entreaty with it to High Priest Squelniss. What comes out of that pairing can crack a colossus.")
  elseif item_lib.check_turn_in(e.trade, { item1 = NOTE }) and standing >= 40 then
    P.set(c, "colossal", "1")
    P.fac_up(c, "rulnavis", 10)
    P.say(e, "The Body of a Colossus, the Blessed blade that cracked it, and Gurkan's signature. A Colossal Task, completed. Rest - then ask me about the Plan for Narikor.")
  elseif item_lib.check_turn_in(e.trade, { item1 = PLAN }) and P.flagged(c, "plan_given") then
    P.set(c, "tactical_gate", "1")
    e.other:SummonItem(COLOSSUS_REQ)
    e.other:SummonItem(BOW_REQ)
    P.say(e, "Signed. Tactical Strike: one Strategic Colossus from Gurkan, one Assault Bow from Forlen, the walls of Tamrel swept, and High Tactician Drelg dragged out of his shrine. The final requisitions are in your hand.")
  elseif item_lib.check_turn_in(e.trade, { item1 = 97473, item2 = 97472, item3 = 97474 }) and P.flagged(c, "tactical_gate") then
    -- Assault Bow + Strategic Colossus + Drelg's Message
    P.set(c, "tactical", "1")
    P.fac_up(c, "rulnavis", 20)
    P.say(e, "The bow, the colossus, and Drelg's own message - Tamrel's high tactician, dragged from his shrine by a soldier Rulnavis barely trained. The war will end before the paperwork does, and this is the paperwork. It is done.")
    e.other:QuestReward(e.self, 0, 0, 0, 0, 0, 150000)
  else
    item_lib.return_items(e.self, e.other, e.trade)
  end
end
