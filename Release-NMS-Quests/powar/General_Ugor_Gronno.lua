-- powar: General Ugor Gronno — the New Colonel of Castle Tamrel
-- Broken weapons, Rulnavis sabotage, and the flag for the Grandmaster's Tower.
local P = require("powar_shared")
local item_lib = require("items")

local TACTICS_BOOK = 88467
local BROKEN_WEAPON = 17843
local SEALED_BOX = 86227      -- Ugor's Sealed Storage Box
local SIGNET = 86228          -- Ugor's Signet
local THINGS_I_SEEN = 86229   -- Things I Seen
local IGNITOR = 86230         -- Arcanist's Ignitor
local STRATEGIES = 86231      -- Araneae's Strategies

function event_say(e)
  local c = e.other
  local standing, label = P.standing(c, "tamrel")
  if e.message:findi("hail") then
    if P.flagged(c, "colonel") then
      P.say(e, "The colonel nods once. 'The tower remembers you passed. The Grandmaster's board sits behind the mid-north wall — walk in and the game plays you.'")
    elseif not P.flagged(c, "trials") then
      P.say(e, "The ogre general looks you over like livestock. 'Flavis sends no one to me who has not broken his seals. Break them.'")
    elseif not P.get(c, "ugor_stage") then
      P.say(e, "I am Ugor Gronno — late of Rulnavis, colonel now of Tamrel by the offer of a better war. Flavis vouches, so I listen. Hand me the Lieutenant's book if you carry it.")
    elseif tonumber(P.get(c, "ugor_stage")) == 1 then
      P.say(e, "Rulnavis' forge runs on our broken steel. Four Broken Weapons from the field trash — bring them and I will show you what an ogre does with garbage.")
    elseif tonumber(P.get(c, "ugor_stage")) == 2 then
      P.say(e, "The box went back with the excellent steel inside. You may keep the signet — Ugor's Signet, mine by thirty years of service. Now: something to make an arcanist's fire worth lighting. 'Things I Seen' falls from anything out there. Bring the scroll and the signet both.")
    elseif tonumber(P.get(c, "ugor_stage")) == 3 then
      P.say(e, "Take the Arcanist's Ignitor to Kijarl, the Rulnavis arcanist in their castle's second floor. He will light what the ogres wrote. Mind the library.")
    elseif tonumber(P.get(c, "ugor_stage")) == 4 then
      P.say(e, "Araneae the Clever sits the Rulnavis library, bloated on stolen strategy. Kill her, take Araneae's Strategies, and bring them here with the ignitor.")
    end
  end
end

function event_trade(e)
  local c = e.other
  local stage = tonumber(P.get(c, "ugor_stage")) or 0
  if item_lib.check_turn_in(e.trade, { item1 = TACTICS_BOOK }) and stage == 0 then
    P.set(c, "ugor_stage", "1")
    P.say(e, "My book. Rulnavis taught ogres to march in squares; Tamrel will teach them to run in them. First: the forge. Four Broken Weapons — the field trash drops them.")
  elseif item_lib.check_turn_in(e.trade, { item1 = BROKEN_WEAPON, item2 = BROKEN_WEAPON, item3 = BROKEN_WEAPON, item4 = BROKEN_WEAPON }) and stage == 1 then
    P.set(c, "ugor_stage", "2")
    e.other:SummonItem(SIGNET)
    P.say(e, "Four broken swords — Rulnavis re-forges them and sells them back to us with 'excellent' stamped on. I have filled the box with what their smiths consider generosity. It went back to them this morning. Keep the signet; bring it back with a scroll called Things I Seen.")
  elseif item_lib.check_turn_in(e.trade, { item1 = SIGNET, item2 = THINGS_I_SEEN }) and stage == 2 then
    P.set(c, "ugor_stage", "3")
    e.other:SummonItem(IGNITOR)
    P.say(e, "A scroll of Rulnavis atrocities and my signet to light under it. Here — the Arcanist's Ignitor. Kijarl knows what it lights.")
  elseif item_lib.check_turn_in(e.trade, { item1 = STRATEGIES, item2 = IGNITOR }) and stage == 4 then
    P.set(c, "colonel", "1")
    P.say(e, "The Clever one, out-clevered. Araneae's strategies are mine now, and Tamrel's war has a new chapter. You — you have earned the tower. The Grandmaster's board sits behind the mid-north wall of this zone. Walk in, and play well.")
    e.other:QuestReward(e.self, 0, 0, 0, 0, 0, 75000)
  else
    item_lib.return_items(e.self, e.other, e.trade)
  end
end
