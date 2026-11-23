local fall = require("rof2_dodh_fall")

local function apply_form(client)
    if not client or not client.valid or not client:IsTaskActive(920243) then return end
    if client:IsSpiritShrouded() then return end
    local run = client:GetSharedTaskIdentity()
    if type(run) ~= "string" or run == "" then return end
    local id = client:GetFallShroudSelectedTemplate(run)
    if id and id > 0 then client:ApplyFallEscrow(run, id) end
end

function event_enter_zone(e)
    local client = e.self
    apply_form(client)
    fall.enter(e)
end

function event_timer(e)
    fall.tick(e)
end
