-- powar: High Tactician Drelg — the shrine's final argument.
-- Add waves at 95/60/40/20 (Bonzz pow.htm), honor and blood guards that
-- summon when hurt. Death drops Drelg's Message to the top haters.
local P = require("powar_shared")

local waves_done = {}

function event_spawn(e)
  waves_done = {}
  e.self:Emote("steps over the broken shards, sharpening a blade the length of a door.")
  e.self:Shout("THE SHRINE IS BROKEN, SO THE TACTICIAN COMES! BRING YOUR ARMY, TAMREL SENDS ONLY ONE!")
  eq.set_timer("guards", 45000)
end

function event_hp(e)
  local thresholds = { { 95, 1 }, { 60, 1 }, { 40, 2 }, { 20, 3 } }
  local hp = e.self:GetHP() / e.self:GetMaxHP() * 100
  for _, t in ipairs(thresholds) do
    if hp <= t[1] and not waves_done[t[1]] then
      waves_done[t[1]] = true
      local x, y, z = e.self:GetX(), e.self:GetY(), e.self:GetZ()
      for i = 1, t[2] do
        if i % 2 == 0 then
          eq.unique_spawn(P.NPC.blood, 0, 0, x + 15 + i * 5, y + 15, z, 0)
        else
          eq.unique_spawn(P.NPC.honor, 0, 0, x - 15 - i * 5, y + 15, z, 0)
        end
      end
      e.self:Emote("signals, and the shrine's guards answer!")
    end
  end
end

function event_timer(e)
  if e.timer == "guards" then
    local x, y, z = e.self:GetX(), e.self:GetY(), e.self:GetZ()
    eq.unique_spawn(P.NPC.honor, 0, 0, x + 20, y, z, 0)
    eq.unique_spawn(P.NPC.blood, 0, 0, x - 20, y, z, 0)
  end
end

function event_death(e)
  eq.stop_timer("guards")
  eq.set_data("pow-drelg-up", "0")
  eq.set_data("pow-crystals-dead", "0")
  local top = P.top_client(e)
  if top then
    top:SummonItem(97474) -- Drelg's Message
    top:Message(MT.NPCQuestSay, "Drelg's message falls from his coat - sealed, strategic, and final.")
  end
  eq.zone_emote(15, "High Tactician Drelg has fallen!")
end
