-- powar: Katka the Unworthy — the Narikor rebellion chain
-- (PoP-ized: the anvil/forge click-gimmicks are folded into the forge-room
-- NPCs, Bolgorn and Cooper Jolris.)
local P = require("powar_shared")
local item_lib = require("items")

local NOTES = { selynse = 97477, sorayn = 97475, mickorn = 97476 }
local PLEDGES = { mickorn = 97488, sorayn = 97481, selynse = 97494 }
local PROCLAMATION = 97495
local CAPTURED_SLAVER = 97496
local CALL_TO_ARMS = 97498
local PLAN = 97469

function event_say(e)
  local c = e.other
  if e.message:findi("hail") then
    if not P.flagged(c, "mines") then
      P.say(e, "A surface-dweller, down here? The tithe comes first — Ets`in`thini`konar`ifet guards the way in.")
    elseif P.flagged(c, "katka") then
      P.say(e, "The mines breathe freer for what you did, warbrand. Narikor remembers.")
    elseif P.get(c, "katka_started") then
      local have = {}
      for who, id in pairs(PLEDGES) do
        if c:HasItem(id) then table.insert(have, who) end
      end
      if #have == 3 then
        P.say(e, "All three pledges! Selynse, Sorayn and Mickorn stand with me. Hand them over and the Proclamation goes up tonight.")
      else
        P.say(e, "The notes are out: Selynse south of here, Sorayn down the west tunnel, Mickorn south then second right. Do what they ask of you and bring me their pledges of support. I still wait on: " .. (next(have) and table.concat(have, ", ") or "all of them") .. ".")
      end
    else
      P.say(e, "I am Katka — the Unworthy, the overseers call me, and I will make the name a joke they choke on. This mine runs on slaves and iron and Jergamund's whip. Say 'rebellion' if your hands are clean enough to dirty them properly.")
    end
  elseif e.message:findi("rebellion") and P.flagged(c, "mines") and not P.get(c, "katka_started") then
    P.set(c, "katka_started", "1")
    e.other:SummonItem(NOTES.selynse)
    e.other:SummonItem(NOTES.sorayn)
    e.other:SummonItem(NOTES.mickorn)
    P.say(e, "Then take these. One note each to Selynse, Sorayn and Mickorn — scattered through the tunnels. They will test you before they trust you. When all three pledges sit in your pack, come back to me.")
  end
end

function event_trade(e)
  local c = e.other
  if item_lib.check_turn_in(e.trade, { item1 = PLEDGES.mickorn, item2 = PLEDGES.sorayn, item3 = PLEDGES.selynse }) then
    e.other:SummonItem(PROCLAMATION)
    P.say(e, "The Proclamation of Rebellion. Nail it to the first slaver that gives you lip — that means all of them. Jergamund himself will come to see who dares. Kill him, take his slaver from the corpse, and bring both back to me.")
  elseif item_lib.check_turn_in(e.trade, { item1 = CAPTURED_SLAVER, item2 = PROCLAMATION }) then
    e.other:SummonItem(CALL_TO_ARMS)
    P.say(e, "The overseer hangs his example and we hang ours. Take my call to arms to Selynse — she knows what to do with a barrel and a grudge.")
  elseif item_lib.check_turn_in(e.trade, { item1 = PLAN }) then
    P.set(c, "war_alliance", "1")
    P.say(e, "Galben's hand and Tamrel's seal — the castles finally ask the mines to the war. Show them what Narikor iron is worth. This alliance will hold, warbrand. Narikor thanks you.")
    e.other:QuestReward(e.self, 0, 0, 0, 0, 127556, 100000) -- a Zekarian Diamond keepsake
  else
    item_lib.return_items(e.self, e.other, e.trade)
  end
end
