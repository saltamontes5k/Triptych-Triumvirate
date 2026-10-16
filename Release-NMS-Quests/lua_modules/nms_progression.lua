-- nms_progression.lua - Lua-side mirror of NMS_progression_utils.pl account progression
--
-- The Perl progression plugin persists each stage as a serialized hash via
-- quest::set_data("<accountid>-progress-flag-<STAGE>", "objective=1;objective2=1;...").
-- This module reads that same data from Lua so event scripts (e.g. LDoN camp/raid
-- recruiters) can enforce the per-account expansion gates with one require().

local PREREQ = {
    -- Classic -> Planes of Power (same objective lists as %STAGE_PREREQUISITES)
    RoK = { "lord nagafen", "lady vox" },
    SoV = { "trakanon", "gorenaire", "severilous", "talendor" },
    SoL = { "klandicar", "zlandicar", "wuoshi", "dozekar the cursed", "kelorek`dar" },
    PoP = { "thought horror overfiend", "the insanity crawler", "grieg veneficus", "xerkizh the creator", "emperor ssraeshza" },
    -- Gates of Discord: Saryrn is the single objective (same as %STAGE_PREREQUISITES{'GoD'})
    GoD = { "saryrn" },
    -- Omens of War: Tunat`Muram Cuu Vauax (Tacvi end boss; same single objective
    -- as %STAGE_PREREQUISITES{'OoW'} in plugins/NMS_progression_utils.pl)
    OoW = { "tunat`muram cuu vauax" },
    -- Dragons of Norrath / LDoN unlock: all five PoP elemental gods
    DoN = {
        "xegony",
        "fennin ro the tyrant of fire",
        "coirnav the avatar of water",
        "rathe council",
        "agnarr the storm lord",
    },
    -- Lost Dungeons of Norrath: opens alongside DoN on the same five elemental gods
    LDoN = {
        "xegony",
        "fennin ro the tyrant of fire",
        "coirnav the avatar of water",
        "rathe council",
        "agnarr the storm lord",
    },
    -- Depths of Darkhollow: GoD end boss (same kill that opens OoW) +
    -- the LDoN Rujarkian Hills raid warlord (mirrors %STAGE_PREREQUISITES{'DoD'})
    DoD = { "tunat`muram cuu vauax", "warlord imal ojun" },
    -- Prophecy of Ro: six MPG chamber Masters + Anguish + the DoN Nest raid
    -- dragon + Demi-Plane Mayong (Dreadspire; distinct from the Solteris
    -- Mayong used by SoF)
    PoR = {
        "master of hate",
        "master of weaponry",
        "master of foresight",
        "master of specialization",
        "master of adaptation",
        "master of destruction",
        "anguish",
        "vishimtar the fallen",
        "mayong mistmoore dreadspire",
    },
    -- The Serpent's Spine: Deathknell (Ayonae Ro) clear
    TSS = { "deathknell" },
    -- The Buried Sea: Ashengate Dyn'Leth raid
    TBS = { "dyn`leth" },
    -- Secrets of Faydwer: Solteris Mayong Mistmoore + Solusek Ro
    SoF = { "mayong mistmoore", "solusek ro" },
    -- Seeds of Destruction: Crystallos Kerafyrm + Sleeper's Tomb 2.0 Kerafyrm
    SoD = { "kerafyrm", "kerafyrm-crystallos" },
    -- Fabled Nagafen's Lair: Quarm (Plane of Time, phase 6)
    FNagafen = { "quarm" },
    -- Underfoot: the Convorteum finale (seven-ward raid line, Rasper miscRaidProg)
    UF = { "the first creation" },
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
