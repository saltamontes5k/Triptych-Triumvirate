-- powar: the possessed colossus — follows its deployer and picks the fight
-- with High Tactician Drelg when the shrine breaks.
local P = require("powar_shared")

function event_spawn(e)
  local owner_id = eq.get_data("pow-colossus-owner")
  if owner_id and owner_id ~= "" then
    local clients = eq.get_entity_list():GetClientList()
    if clients ~= nil then
      for client in clients.entries do
        if client.valid and tostring(client:CharacterID()) == tostring(owner_id) then
          e.self:SetFollowID(client:GetID())
          break
        end
      end
    end
  end
  eq.set_timer("find_fight", 10000)
  eq.set_timer("expire", eq.seconds("1h") * 1000)
end

function event_timer(e)
  if e.timer == "find_fight" then
    local drelg = eq.get_entity_list():GetNPCByNPCTypeID(P.NPC.drelg)
    if drelg and drelg.valid then
      e.self:AddToHateList(drelg, 1000, 1000)
    end
  elseif e.timer == "expire" then
    e.self:Depop()
  end
end

function event_death(e)
  eq.zone_emote(15, "The Strategic Colossus falls apart, orcs and all. Someone owes the troopmaster an apology.")
end
