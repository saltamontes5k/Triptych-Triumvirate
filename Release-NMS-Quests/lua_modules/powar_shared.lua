-- Shared state/helpers for the PoP-ized Plane of War (Bonzz pow.htm port).
-- Quest state lives in per-character data buckets ("pow-<charid>-<key>").
-- Faction gates from the guide are bucket tiers; the faction_list rows
-- (5060 Castle Tamrel / 5061 Castle Rulnavis) exist for /con flavor only.
local M = {}

-- npc_types ids added by 20261024_powar_pop_quests.sql (band 1120002500+)
M.NPC = {
  bolgorn = 1120002500, jolris = 1120002501, diviner = 1120002502,
  unslaver = 1120002503, ess_pekky = 1120002506, ugor = 1120002507,
  resonance = 1120002508, soke = 1120002509, icecore = 1120002510,
  zayenaekk = 201281, -- pre-existing PEQ npc in pojustice
  zayenaek = 1120002512,
  herald = 1120002513, legionnaire = 1120002514, shade = 1120002515,
  slaver_capt = 1120002516, motivator = 1120002517, drelg = 1120002518,
  honor = 1120002519, blood = 1120002520, colossus = 1120002521,
  battle = 1120002522, charging = 1120002523, goblinimg = 1120002524,
  giantimg = 1120002525, hendin = 1120002526, orcally = 1120002527,
  bloodtusk = 1120002528, infiltrator = 1120002529, knight = 1120002530,
  rook = 1120002531, charger = 1120002532, assailant = 1120002533,
  assaulter = 1120002534, yendan = 1120002535, edmuund_bold = 1120002536,
  r_archer = 1120002537, r_marauder = 1120002538, r_slavebringer = 1120002539,
  r_warmaster = 1120002540, r_lifetaker = 1120002541, r_flamespeaker = 1120002542,
  r_warbrute = 1120002543, r_provost = 1120002544, r_skirmisher = 1120002545,
  r_priest = 1120002546
}

M.FAC_TAMREL = 5060
M.FAC_RULNAVIS = 5061

function M.key(client, k) return "pow-" .. client:CharacterID() .. "-" .. k end
function M.get(client, k) return eq.get_data(M.key(client, k)) end
function M.set(client, k, v) eq.set_data(M.key(client, k), tostring(v)) end
function M.flagged(client, k) return (M.get(client, k) or "") == "1" end

function M.say(e, text)
  e.other:Message(MT.NPCQuestSay, e.self:GetCleanName() .. " tells you, '" .. text .. "'")
end

-- Guide standing labels mapped onto bucket tiers (0-100)
function M.standing(client, which)
  local v = tonumber(M.get(client, which .. "_fac")) or 0
  local label
  if v >= 90 then label = "Max Ally"
  elseif v >= 70 then label = "Ally"
  elseif v >= 50 then label = "Warmly"
  elseif v >= 40 then label = "Kindly"
  elseif v >= 10 then label = "Apprehensive"
  elseif v >= 4 then label = "Dubious"
  else label = "Neutral" end
  return v, label
end

function M.fac_up(client, which, amt)
  local v = math.min((tonumber(M.get(client, which .. "_fac")) or 0) + amt, 100)
  M.set(client, which .. "_fac", v)
  return v
end

-- kill-credit: top hate holder on a dying event mob, if it is a client
function M.top_client(e)
  local top = e.self:GetHateDamageTop(e.self)
  if top and top.valid and top:IsClient() then return top:CastToClient() end
  return nil
end

return M
