-- powar: Captain Flavis Stella — the three Tamrel trials
-- (PoP-ized: two waves per trial instead of three difficulty choices; each
-- trial is timed at ten minutes and fought in this room.)
local P = require("powar_shared")

local TRIAL_TIME = 600 -- seconds
local x, y, z = -1957, -877, 85 -- Flavis' room (2nd floor NE, Castle Tamrel)

local TRIALS = {
  { { P.NPC.battle, 2 }, { P.NPC.giantimg, 1 } },
  { { P.NPC.goblinimg, 2 }, { P.NPC.charging, 2 } },
  { { P.NPC.hendin, 3 }, { P.NPC.orcally, 2 } },
}

local wave_npcs = { P.NPC.battle, P.NPC.giantimg, P.NPC.goblinimg, P.NPC.charging, P.NPC.hendin }

local function trial_state(c)
  local t = tonumber(P.get(c, "trial_wave")) or 0
  local active = P.get(c, "trial_active") == "1"
  return t, active
end

function event_say(e)
  local c = e.other
  local t, active = trial_state(c)
  if e.message:findi("hail") then
    if P.flagged(c, "trials") then
      P.say(e, "Three trials, three seals, one colonel. General Ugor Gronno waits above — he sent for you by name.")
    elseif not P.flagged(c, "mines") then
      P.say(e, "The Field of Strife decides who sees this room. Pay the tithe first.")
    elseif active then
      P.say(e, "The trial runs! Finish the wave — the seal demands it before the sand runs out.")
    elseif t == 0 then
      P.say(e, "I am Captain Flavis Stella. Castle Tamrel arms itself for war and needs officers it can trust. Submit to my trials — three of them, ten minutes each, fought in this room — and I will send you to General Ugor Gronno myself. Say 'first' when you are ready.")
    elseif t >= 3 then
      P.set(c, "trials", "1")
      P.say(e, "All three seals broken in time. You are worth more than the walls you came through. General Ugor Gronno holds the south room above — go. Tell him Flavis vouches for you.")
    else
      P.say(e, "Trial " .. t .. " passed. Say 'first' when you want the next seal tested.")
    end
  elseif e.message:findi("first") and not active and t < 3 and P.flagged(c, "mines") then
    P.set(c, "trial_active", "1")
    P.set(c, "trial_owner", c:CharacterID())
    local wave = TRIALS[t + 1]
    for _, pair in ipairs(wave) do
      for i = 1, pair[2] do
        eq.unique_spawn(pair[1], 0, 0, x + math.random(-20, 20), y + math.random(-20, 20), z, 0)
      end
    end
    eq.zone_emote(15, "Captain Flavis Stella rings a bell of black iron. The trial of seal " .. (t + 1) .. " begins!")
    eq.set_timer("trial", TRIAL_TIME * 1000)
    eq.set_timer("check", 5000)
  end
end

function event_timer(e)
  if e.timer == "check" then
    local remaining = 0
    local list = eq.get_entity_list():GetNPCList()
    if list ~= nil then
      for npc in list.entries do
        if npc.valid then
          local id = npc:GetNPCTypeID()
          for _, wid in ipairs(wave_npcs) do
            if id == wid then remaining = remaining + 1 end
          end
        end
      end
    end
    if remaining == 0 then
      eq.stop_timer("check")
      eq.stop_timer("trial")
      -- credit the trial's owner
      local owner_id = P.get(e.self, "trial_owner")
      local clients = eq.get_entity_list():GetClientList()
      if clients ~= nil then
        for client in clients.entries do
          if client.valid and tostring(client:CharacterID()) == tostring(owner_id) then
            P.set(client, "trial_wave", (tonumber(P.get(client, "trial_wave")) or 0) + 1)
            P.set(client, "trial_active", "0")
            client:Message(MT.NPCQuestSay, "Captain Flavis Stella tells you, 'The seal yields. Speak to me.'")
          end
        end
      end
    end
  elseif e.timer == "trial" then
    eq.stop_timer("check")
    eq.stop_timer("trial")
    local list = eq.get_entity_list():GetNPCList()
    if list ~= nil then
      for npc in list.entries do
        if npc.valid then
          local id = npc:GetNPCTypeID()
          if id == P.NPC.battle or id == P.NPC.giantimg or id == P.NPC.goblinimg or id == P.NPC.charging or id == P.NPC.hendin then
            npc:Depop()
          end
        end
      end
    end
    local owner_id = P.get(e.self, "trial_owner")
    local clients = eq.get_entity_list():GetClientList()
    if clients ~= nil then
      for client in clients.entries do
        if client.valid and tostring(client:CharacterID()) == tostring(owner_id) then
          P.set(client, "trial_active", "0")
          client:Message(MT.NPCQuestSay, "Captain Flavis Stella tells you, 'The sand ran out. The seal resets - say 'first' when you are ready to try again.'")
        end
      end
    end
    eq.zone_emote(15, "The trial bell tolls. A trial seal has failed.")
  end
end
