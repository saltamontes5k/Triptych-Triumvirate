-- powar: Ets`in`thini`konar`ifet — the tithe that opens the Mines of Narikor
-- and the Field of Strife (PoP-ized: the bow legs that ran through Vegarlson,
-- Korascian Warrens and Toskirakk now route through sphinxes in PoJustice and
-- PoValor; the Stonewood bow itself comes from Fletcher Forlen in Castle
-- Rulnavis, and Zayenaek infuses it with a Zekarian Diamond).
local P = require("powar_shared")
local item_lib = require("items")

local TITHE_BOW = 127560 -- Zekarian Stonewood Compound Bow

function event_say(e)
  local c = e.other
  if e.message:findi("tithe") and not P.flagged(c, "mines") then
    if not P.get(c, "tithe_started") then
      P.set(c, "tithe_started", "1")
      P.say(e, "You would cross into the Field of Blood, would you? Then pay the tithe of war. My keeper Zayenaekk sits caged in the Plane of Justice — speak his name to him. Do this, and we will speak of a bow.")
    else
      P.say(e, "The tithe stands unfinished. Zayenaekk of the Plane of Justice. Then his sister Zayenaek in the Plane of Valor. Bring her the bow and a diamond of war.")
    end
  elseif e.message:findi("hail") or e.message:findi("status") then
    if P.flagged(c, "mines") then
      P.say(e, "The warbrand returns. May your quiver never empty. The mines of Narikor and the Field of Strife are yours.")
    elseif P.get(c, "tithe_started") then
      local jus = P.flagged(c, "tithe_jus") and "paid" or "unpaid"
      local val = P.flagged(c, "tithe_val") and "paid" or "unpaid"
      P.say(e, "The tithe: Zayenaekk of Justice — " .. jus .. ". Zayenaek of Valor — " .. val .. ". When both are paid and the bow is made, bring it here.")
    else
      P.say(e, "I am Ets`in`thini`konar`ifet, warden of the wall. Those who would hunt the Field of Strife or delve the mines of Narikor must pay the tithe. Say 'tithe' if you would pay it.")
    end
  end
end

function event_trade(e)
  if item_lib.check_turn_in(e.trade, { item1 = TITHE_BOW }) then
    if P.flagged(e.other, "tithe_val") then
      P.set(e.other, "mines", "1")
      P.say(e, "Infused with the power of war and freely given. The tithe is paid in full, warbrand. The small door behind me opens to the mines — Katka the Unworthy waits below, and the Field of Strife is yours to bleed in.")
    else
      P.set(e.other, "tithe_bow", "1")
      item_lib.return_items(e.self, e.other, e.trade)
      P.say(e, "A fine weapon, but you have not paid the tithe that earns it a place here. Speak with the sphinxes first.")
    end
  else
    item_lib.return_items(e.self, e.other, e.trade)
  end
end
