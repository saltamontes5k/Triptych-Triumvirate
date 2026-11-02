-- powar: Strategist Gromluk — the library, the defense, and the tar
-- (PoP-ized: library books are lent for captain insignias instead of being
-- clicked off shelves; the defense event and the tar bait start from here.)
local P = require("powar_shared")
local item_lib = require("items")

local LETTER = 97434
local INDEX = 97435          -- Rulnavian Library Index
local BOOK1 = 97436          -- Rilnak's Strategic Compendium
local BOOK2 = 97437          -- Binget's Battle Guide
local BOOK3 = 97438          -- The Art of Zek
local CAPTAIN = 88466        -- Tallon Captain Insignia (lending fee)
local WRIT = 97439           -- Writ of Rulnavian Command
local DLEDGER = 97440        -- Defensive Report Ledger
local DPAGE = 97441          -- Successful Defensive Report Page
local DFILLED = 97443        -- Filled Defensive Report Ledger
local TAR = 97444            -- Burning Tar
local TARBAG = 97445         -- Tar-Proof Bag
local BONES_S = 97446        -- Charred Soldier's Bones
local BONES_C = 97447        -- Charred Captain's Bones
local BAG_BONES = 97449      -- Bag of Burned Bones

local last_defense = 0
local last_tar = 0

function event_say(e)
  local c = e.other
  local standing, label = P.standing(c, "rulnavis")
  if e.message:findi("hail") then
    if P.flagged(c, "defending") then
      P.say(e, "Gromluk closes a very large ledger. 'The walls stand. The strategist approves.'")
    elseif standing >= 20 and P.get(c, "gromluk_stage") == nil then
      P.say(e, "Strategist Gromluk, keeper of the Rulnavis library. Dulkot's letter reaches me before you do, as letters do. The library is the castle's brain - and you, standing " .. label .. ", may borrow from it. Say 'borrow'.")
    elseif tonumber(P.get(c, "gromluk_stage")) == 1 then
      P.say(e, "Three books: Rilnak's Strategic Compendium, Binget's Battle Guide, and The Art of Zek. Each lends for one Tallon Captain Insignia - the fine is a rank, the late fee is a war.")
    elseif tonumber(P.get(c, "gromluk_stage")) == 2 then
      P.say(e, "All three read? Then the Writ of Rulnavian Command is yours, with the Defensive Report Ledger. Say 'defend' at the gate and I will send chargers at our defenders - six pages from six chargers, then the ledger back to me filled.")
    elseif tonumber(P.get(c, "gromluk_stage")) == 3 then
      P.say(e, "The walls held. Last parish: the tar. Say 'bait' and I will march three Tamrels into the southwest field - burn them properly, with the tar I give you, and bring me their charred bones: seven soldiers, three captains. Then the ledger closes.")
    end
  elseif e.message:findi("defend") and tonumber(P.get(c, "gromluk_stage")) == 2 then
    if os.time() - last_defense < 300 then
      P.say(e, "The gate is still sweeping the last chargers off the bridge. Wait a moment.")
      return
    end
    last_defense = os.time()
    local x, y, z = e.self:GetX(), e.self:GetY(), e.self:GetZ()
    for i = 1, 6 do
      eq.unique_spawn(P.NPC.charger, 0, 0, x + math.random(-30, 30), y + math.random(-30, 30), z, 0)
    end
    eq.zone_emote(15, "Tamrelian chargers crash against the Rulnavis gate!")
    P.say(e, "Six chargers, six pages, one ledger. Defend well.")
  elseif e.message:findi("bait") and tonumber(P.get(c, "gromluk_stage")) == 3 and c:HasItem(TAR) then
    if os.time() - last_tar < 300 then
      P.say(e, "The field is still smoking from the last baiting. Wait a moment.")
      return
    end
    last_tar = os.time()
    local x, y, z = e.self:GetX(), e.self:GetY(), e.self:GetZ()
    eq.unique_spawn(P.NPC.assailant, 0, 0, x + 40, y + 20, z, 0)
    eq.unique_spawn(P.NPC.assaulter, 0, 0, x + 40, y - 20, z, 0)
    eq.unique_spawn(P.NPC.assaulter, 0, 0, x + 60, y, z, 0)
    eq.zone_emote(15, "Tamrelian soldiers advance on the castle, flags high - straight into the smoking field.")
    P.say(e, "Three Tamrels marching. Burn them - the tar does the talking, the bones do the reporting. Ten charred bones, any mix of soldiers and captains, fills the bag.")
  end
end

function event_trade(e)
  local c = e.other
  local stage = tonumber(P.get(c, "gromluk_stage")) or 0
  if item_lib.check_turn_in(e.trade, { item1 = LETTER }) and stage == 0 then
    P.set(c, "gromluk_stage", "1")
    P.say(e, "Dulkot's hand. Then the library: three books, one captain insignia each. Rilnak for strategy, Binget for battles, Zek for everything else.")
  elseif item_lib.check_turn_in(e.trade, { item1 = CAPTAIN }) and stage == 1 then
    local got = P.get(c, "gromluk_books") or ""
    if not got:find(BOOK1) then
      P.set(c, "gromluk_books", got .. BOOK1 .. ",")
      e.other:SummonItem(BOOK1)
      P.say(e, "Rilnak's Strategic Compendium. Two more.")
    elseif not got:find(BOOK2) then
      P.set(c, "gromluk_books", got .. BOOK2 .. ",")
      e.other:SummonItem(BOOK2)
      P.say(e, "Binget's Battle Guide. One more.")
    elseif not got:find(BOOK3) then
      P.set(c, "gromluk_books", got .. BOOK3 .. ",")
      e.other:SummonItem(BOOK3)
      P.say(e, "The Art of Zek itself. That is the shelf - bring all three back and the Index will close the account.")
    else
      item_lib.return_items(e.self, e.other, e.trade)
      P.say(e, "You have the shelf already.")
    end
  elseif item_lib.check_turn_in(e.trade, { item1 = BOOK1, item2 = BOOK2, item3 = BOOK3, item4 = INDEX }) and stage == 1 then
    P.set(c, "gromluk_stage", "2")
    e.other:SummonItem(WRIT)
    e.other:SummonItem(DLEDGER)
    P.say(e, "The account closes; the Writ of Rulnavian Command opens. With it, a Defensive Report Ledger. Say 'defend' and I will spring chargers on our own defenders - collect six Successful Defensive Report Pages, tuck them in, and bring it back.")
  elseif item_lib.check_turn_in(e.trade, { item1 = DPAGE, item2 = DPAGE, item3 = DPAGE }) and c:HasItem(DLEDGER) and stage == 2 then
    local n = (tonumber(P.get(c, "gromluk_dpages")) or 0) + 3
    if n >= 6 then
      c:RemoveItem(DLEDGER, 1)
      P.set(c, "gromluk_stage", "3")
      P.set(c, "gromluk_dpages", "0")
      e.other:SummonItem(TAR)
      e.other:SummonItem(TARBAG)
      P.say(e, "Six pages, six chargers, zero breaches. The walls stand. Last parish: the tar - Burning Tar and a Tar-Proof Bag. Say 'bait' when your arm is ready. Ten charred bones, any mix, in the bag.")
    else
      P.set(c, "gromluk_dpages", tostring(n))
      P.say(e, "Three pages tucked - " .. n .. " of 6. The chargers keep coming when you say 'defend'.")
    end
  elseif item_lib.check_turn_in(e.trade, { item1 = BONES_S, item2 = BONES_S, item3 = BONES_S, item4 = BONES_S }) and c:HasItem(TARBAG) and stage == 3 then
    local n = math.min((tonumber(P.get(c, "gromluk_bones")) or 0) + 4, 10)
    P.set(c, "gromluk_bones", tostring(n))
    if n >= 10 then
      c:RemoveItem(TARBAG, 1)
      P.set(c, "defending", "1")
      P.say(e, "Ten charred bones, all honest. The bag closes, and so does the ledger. Castle Rulnavis knows your name now - go back to Dulkot, and then to Galben. The strategist's work begins where the requisitions end.")
    else
      P.say(e, "The bag counts " .. n .. " of 10. Keep burning.")
    end
  else
    item_lib.return_items(e.self, e.other, e.trade)
  end
end
