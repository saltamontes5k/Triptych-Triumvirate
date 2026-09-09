-- nms_progression.lua - Lua-side mirror of NMS_progression_utils.pl account progression
--
-- The Perl progression plugin persists each stage as a serialized hash via
-- quest::set_data("<accountid>-progress-flag-<STAGE>", "objective=1;objective2=1;...").
-- This module reads that same data from Lua so event scripts (e.g. LDoN camp/raid
-- recruiters) can enforce the per-account expansion gates with one require().

local PREREQ = {
    -- Dragons of Norrath / LDoN unlock: all five PoP elemental gods
    DoN = {
        "xegony",
        "fennin ro the tyrant of fire",
        "coirnav the avatar of water",
        "rathe council",
        "agnarr the storm lord",
    },
    -- Prophecy of Ro: six MPG chamber Masters + Anguish clear
    PoR = {
        "master of hate",
        "master of weaponry",
        "master of foresight",
        "master of specialization",
        "master of adaptation",
        "master of destruction",
        "anguish",
    },
    -- The Serpent's Spine: Deathknell (Ayonae Ro) clear
    TSS = { "deathknell" },
    -- The Buried Sea: Tunat'Muram + Dyn'Leth
    TBS = { "tunat`muram cuu vauax", "dyn`leth" },
    -- Secrets of Faydwer: Dyn'Leth
    SoF = { "dyn`leth" },
}

local M = {}

function M.stage_key(stage)
    return M.stage_key_static(stage)
end

function M.stage_key_static(stage)
    return stage
end

function M.get_stage_progress(client, stage)
    local key = tostring(client:AccountID()) .. "-progress-flag-" .. tostring(stage)
    local raw = eq.get_data(key)
    local out = {}
    if raw and raw ~= "" then
        for pair in raw:gmatch("[^;]+") do
            local k, v = pair:match("^([^=]+)=(.*)$")
            if k then out[k] = v end
        end
    end
    return out
end

-- Returns true when the account has every objective for the named stage.
function M.stage_complete(client, stage)
    local reqs = PREREQ[stage]
    if not reqs then
        return false
    end
    local prog = M.get_stage_progress(client, stage)
    for _, r in ipairs(reqs) do
        if prog[r] ~= "1" then
            return false
        end
    end
    return true
end

-- Returns true if the client may access the stage (GM always passes). When denied,
-- speaks the optional deny message from the speaking NPC and returns false.
function M.gate_stage(client, stage, deny_message)
    if client:GetGM() then
        return true
    end
    if M.stage_complete(client, stage) then
        return true
    end
    if deny_message then
        eq.get_entity_list():MessageClose(client, true, 100, MT.SayEcho, deny_message)
    end
    return false
end

return M
