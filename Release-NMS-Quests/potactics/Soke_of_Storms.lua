-- potactics: Soke of Storms — the DPS challenge in the blacksmith depths
-- (Bonzz pow.htm, PoP-ized: bleed him to 10% and live; then ask for the word.)
local P = require("powar_shared")
local item_lib = require("items")

local EDMUUNDS_MESSAGE = 86294
local SOKES_MISSIVE = 86295

local challengers = {}
local yielded = false

local function reset(e)
  yielded = false
  e.self:SetInvul(false)
  e.self:SetSpecialAbility(SpecialAbility.immune_aggro, 0)
  e.self:SetSpecialAbility(SpecialAbility.immune_aggro_on, 0)
end

function event_spawn(e)
  challengers = {}
  reset(e)
end

function event_say(e)
  local c = e.other
  if e.message:findi("hail") then
    if P.flagged(c, "soke_done") then
      P.say(e, "The goblin polishes a hammer that has never struck anything slowly. 'The missive flew. Tell Edmuund the storm keeps its word.'")
    elseif P.flagged(c, "soke_challenge") and yielded and challengers[c:CharacterID()] then
      P.say(e, "The goblin grins through broken teeth. 'Still standing? Then you have earned the word. Say message, and carry it.'")
    elseif P.flagged(c, "soke_challenge") then
      P.say(e, "The goblin measures you with a smith's eye. 'The message is mine until you bleed me to a tenth and live. Swing harder.'")
    else
      P.say(e, "The goblin measures you with a smith's eye. 'Edmuund sends another, does he? Hand over the message - I keep it - and if you can bleed me to a tenth and live, the word is yours.'")
    end
  elseif e.message:findi("message") and P.flagged(c, "soke_challenge") and yielded and challengers[c:CharacterID()] then
    P.set(c, "soke_done", "1")
    e.other:SummonItem(SOKES_MISSIVE)
    P.say(e, "'The storm keeps its word,' tell him. And tell him the goblin of the depths is still the better smith.")
  end
end

function event_trade(e)
  local c = e.other
  if item_lib.check_turn_in(e.trade, { item1 = EDMUUNDS_MESSAGE }) then
    if P.flagged(c, "soke_done") then
      e.other:SummonItem(SOKES_MISSIVE)
      P.say(e, "Already earned. Take the word.")
    elseif not P.flagged(c, "soke_challenge") then
      P.set(c, "soke_challenge", "1")
      challengers[c:CharacterID()] = true
      e.self:Emote("tucks the message into a storm-proof pouch and rolls his shoulders.")
      e.self:Shout("THEN BLEED ME, LITTLE STORM! TENTH PART ONLY - AND STAND IN THE AFTER!")
    else
      item_lib.return_items(e.self, e.other, e.trade)
      P.say(e, "The message stays with me until the tenth part. Swing harder.")
    end
  else
    item_lib.return_items(e.self, e.other, e.trade)
  end
end

function event_hp(e)
  if yielded then return end
  if not e.other or not e.other:IsClient() then return end
  if e.hp <= 10 then
    local c = e.other:CastToClient()
    if challengers[c:CharacterID()] then
      yielded = true
      e.self:SetInvul(true)
      e.self:WipeHate()
      e.self:SetSpecialAbility(SpecialAbility.immune_aggro, 1)
      e.self:SetSpecialAbility(SpecialAbility.immune_aggro_on, 1)
      e.self:Emote("raises both hands, grinning, blood and sparks everywhere. 'ENOUGH! The tenth part is reached - and you stand in the after.'")
    end
  end
end
