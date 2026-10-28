-- powar: Edmuund — the giant who tests the worthy
-- (PoP-ized: the Frostcrypt leg is replaced — Gorod's Medallion and
-- Aelfgir's Signet Ring drop from Icecore in the Plane of Nightmare.)
local P = require("powar_shared")
local item_lib = require("items")

local HEART = 86290          -- Heart of the Colossus
local CHAMPION_BLADE = 86291 -- Champion Blade
local DISPLAY_CASE = 86296
local SEALED_CASE = 86297
local MEDALLION = 86292      -- Gorod's Medallion
local SIGNET_RING = 86293    -- Aelfgir's Signet Ring
local EDMUUNDS_MESSAGE = 86294
local SOKES_MISSIVE = 86295

local function edmuund_stage(c) return tonumber(P.get(c, "edmuund_stage")) or 0 end

function event_say(e)
  local c = e.other
  local standing, _ = P.standing(c, "tamrel")
  local stage = edmuund_stage(c)
  if e.message:findi("hail") then
    if P.flagged(c, "edmuund") then
      P.say(e, "The giant inclines his head, one soldier to another.")
    elseif not P.flagged(c, "mines") then
      P.say(e, "Edmuund looks through you.")
    elseif e.message:findi("worthy") or standing >= 50 then
      if stage == 0 then
        P.say(e, "You wish to be tested? Then say 'test'. My terms: my old display case refilled, a debt repaid, and a message delivered — in that order, and all of it in Rulnavis' own house.")
      elseif stage == 1 then
        P.say(e, "Four Hearts of the Colossus, from the colossi at the back wall of the Field of Blood. The case is empty; my honor is not.")
      elseif stage == 2 then
        P.say(e, "The case is sealed and given. Now the debt: my medallion, Gorod's Medallion, lies frozen in the Plane of Nightmare — an Icecore wears it like a trophy. Bring the medallion and the Aelfgir's Signet Ring from the same beast.")
      elseif stage == 3 then
        P.say(e, "My thanks. Now the message: take Edmuund's Message to Soke of Storms — a goblin in the blacksmith depths of the Plane of Tactics. He owes me a word, and the word must be earned.")
      elseif stage == 4 then
        P.say(e, "The missive! Give it here — and stand back. If Soke spoke truly, my test walks through that door in moments.")
      end
    else
      P.say(e, "Edmuund looks through you. Come back when Tamrel calls you warm.")
    end
  elseif e.message:findi("test") and stage == 0 and standing >= 50 then
    P.set(c, "edmuund_stage", "1")
    P.say(e, "Then the test begins. Four Hearts of the Colossus — the colossi at the back wall of the Field of Blood. Bring them.")
  end
end

function event_trade(e)
  local c = e.other
  local stage = edmuund_stage(c)
  if item_lib.check_turn_in(e.trade, { item1 = HEART, item2 = HEART, item3 = HEART, item4 = HEART }) and stage == 1 then
    P.set(c, "edmuund_stage", "2")
    e.other:SummonItem(DISPLAY_CASE)
    P.say(e, "Four hearts, heavy as the war. Here is my old display case - fill it with four Champion Blades from a Gindan Champion's rack and bring the filled case back to me. A giant collects, it is true. Even ones who lose their wars.")
  elseif stage == 2 and c:HasItem(DISPLAY_CASE)
      and item_lib.check_turn_in(e.trade, { item1 = CHAMPION_BLADE, item2 = CHAMPION_BLADE, item3 = CHAMPION_BLADE, item4 = CHAMPION_BLADE }) then
    c:RemoveItem(DISPLAY_CASE, 1)
    e.other:SummonItem(SEALED_CASE)
    P.set(c, "edmuund_stage", "3")
    P.say(e, "The blades fit like they never left. Sealed, and mine again - keep it safe. Now the debt, as I said: Gorod's Medallion and Aelfgir's Signet Ring - an Icecore in the Plane of Nightmare wears them both.")
  elseif item_lib.check_turn_in(e.trade, { item1 = MEDALLION, item2 = SIGNET_RING, item3 = SEALED_CASE }) and stage == 3 then
    P.set(c, "edmuund_stage", "4")
    e.other:SummonItem(EDMUUNDS_MESSAGE)
    P.say(e, "Gorod's medallion, home at last, and my case with it. One more errand, and it is the strangest: carry my message to Soke of Storms in the blacksmith depths of the Plane of Tactics. He will make you earn the reply.")
  elseif item_lib.check_turn_in(e.trade, { item1 = EDMUUNDS_MESSAGE, item2 = SOKES_MISSIVE }) and stage == 4 then
    P.set(c, "edmuund_stage", "0")
    eq.unique_spawn(P.NPC.edmuund_bold, 0, 0, e.self:GetX() - 30, e.self:GetY() - 30, e.self:GetZ(), 0)
    e.self:Emote("reads the missive, bellows with laughter, and strides out of the room.")
    P.say(e, "Soke's word, earned and delivered! Then the test is simple at last: I have told the room to send in the strongest version of you. Defeat it, and you are worthy in every book that matters.")
  else
    item_lib.return_items(e.self, e.other, e.trade)
  end
end
