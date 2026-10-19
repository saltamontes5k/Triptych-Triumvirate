-- ============================================================================
-- Origin AA -- replaces the Lucky Coin "Manifest Experience" AA
--
-- End state
--   aa_ability 31082  "Manifest Experience" -> "Origin", all classes / races /
--                     deities, activated, not grant-only.
--   aa_ranks   41000  points at the new spell 44021, 1080s (18 minute) reuse,
--                     cost 0, level 5, single rank; lower_hotkey_sid -1 so the
--                     one-word name draws as "Origin" (no db_str type 3).
--   spells_new 44021 new "Origin" spell whose first effect is
--                     SE_GateToHomeCity (322). zone/spell_effects.cpp handles
--                     that SPA with Client::GoToBind(4), i.e. bind slot 4 --
--                     the character's home city, which is what /charinfo
--                     reports as "origin". This is the exact SPA retail uses
--                     for Origin ("1: Gate to Home City").
--   aa_ability 481    "Lesson of the Devoted" grant_only 1 -> 0, so every
--                     account can buy it for free at level 50.
--
--   Why the ability is 31082 and not 331
--   Retail Origin is /alt activate 331, but aa_ability 331 on this server is
--   "Bazaar and Back" (rank 1000, spell 5824, driven by
--   quests/global/spells/5824.pl). Rather than destroy that travel ability the
--   retired Lucky Coin ability 31082 is repurposed in place.
--
--   Which number to activate
--   Two different numbers are in play and they are not interchangeable:
--
--   * The AA window button / hotbutton sends OP_AAAction carrying the *rank*
--     id (41000); the server resolves that through aa_ranks
--     (Client::Handle_OP_AAAction -> ActivateAlternateAdvancementAbility ->
--     Zone::GetAlternateAdvancementRank).
--   * "/alt activate <n>" is resolved by the CLIENT against the ability id it
--     received on the wire (SendAA_Struct.seq == aa_ability.id == 31082): it
--     looks through the owned abilities for one whose ID field equals <n>
--     (eqgame sub_4A3D70) and then sends *that* ability's rank id. So the
--     number the description must advertise is 31082. "/alt activate 41000"
--     matches no ability and silently does nothing.
--
--   export_client_files derives the advertised number from aa_ability.id, which
--   is why the db_str text below carries no number of its own.
--
-- Why a new spell instead of reusing 121860
--   spell 121860 ("Transmute Experience") is owned by the Lucky Coin AA and was
--   serviced by quests/global/spells/121860.pl. EVENT_SPELL_EFFECT_CLIENT
--   fires for any spell that has a script and lands on a client
--   (zone/spell_effects.cpp), so leaving the AA pointed at 121860 would have
--   made Origin deduct 3 AA points and summon a Lucky Coin. Adding a fresh
--   spell id keeps this migration additive.
--
-- Lucky Coin script retirement (companion file change, not SQL)
--   quests/global/spells/121860.pl was rewritten to an inert no-op by this same
--   change, so a stray cast of spell 121860 can never charge AA points again.
--   Spell 121860 itself and the Lucky Coin item 121857 are left in place --
--   nothing else casts 121860, and the item is still sold by Harley Wynn in the
--   Guild Lobby. Because a file cannot be restored by SQL, bringing the Lucky
--   Coin AA back needs the rollback plus a git checkout of the script; see the
--   rollback header for the exact commands.
--
-- Why Lesson was unobtainable
--   There is no account-age gate server side (Client::GetAccountAge is only
--   exposed to quests and no script calls it). grant_only was the whole
--   problem: CanPurchaseAlternateAdvancementRank() refuses grant-only ranks
--   (zone/aa.cpp) and AutoGrantAAPoints() skips them, so nothing could ever
--   hand AA 481 out.
--
-- Client strings
--   AA titles and descriptions are resolved by the CLIENT out of
--   dbstr_us.txt, so this migration also rewrites db_str (the export source)
--   for rank 41000. Run `export-client-files.bat <EQ-client-folder>` from the
--   repo root afterwards to regenerate dbstr_us.txt AND spells_us.txt -- the
--   latter is what teaches the client about the new spell 44021.
--
-- Two-line name (hotkey sids)
--   The selected-ability header in the AA window and the hotbutton label are
--   built as GetString(upper_hotkey_sid, 2) + " " + GetString(lower_hotkey_sid, 3)
--   (eqgame sub_608AC0 / sub_60AA80), and the second half is skipped only while
--   lower_hotkey_sid <= 0. The base "Manifest Experience" row is a two-word
--   name, so it carries lower_hotkey_sid = 41000 and db_str type 3 'Experience'.
--   "Origin" is one word: this migration clears lower_hotkey_sid to -1 (exactly
--   like the other one-word activated AAs: Exodus, Escape, ...) and leaves type 3
--   absent. Leaving it at 41000 with no type-3 row makes the client draw
--   "Unknown DB String 41000-3" everywhere that two-part name appears.
--
-- Note on db_str id 41000
--   41000 is also a real spell id, so its db_str type 6 row is the description
--   of *spell* 41000, not of this AA. Only types 1-4 are touched here.
--
-- Requires a zone restart (or #hotfix spells) to load spells_new.
-- Idempotent. Rollback: 20261005_ascendant_origin_aa_rollback.sql
-- ============================================================================
SET NAMES utf8mb4;

-- ---------------------------------------------------------------------------
-- 1. Origin spell -- native SE_GateToHomeCity (322) -> Client::GoToBind(4)
--
--    Column names deliberately mirror the existing gate spells (36 "Gate",
--    6094 "Secondary Recall"): targettype 6 is ST_Self, goodEffect 1 is
--    beneficial and ResistDiff 0 matches that family. cast_time is 0 rather
--    than the 5000 the rest of the gate family uses, because retail Origin is
--    an instant activated AA and a 5 second cast is just an invitation to
--    fizzle when the player moves. The 18 minute reuse on aa_ranks is what
--    gates repeat use.
--    effect_base_value1 is ignored by the SE_GateToHomeCity handler -- unlike
--    SE_Gate it does not roll for success -- but it is kept non-zero so the
--    slot never looks like a spacer.
-- ---------------------------------------------------------------------------
INSERT INTO spells_new (
    id, name, player_1, effectid1, effect_base_value1, targettype, cast_time,
    buffdurationformula, buffduration, teleport_zone, goodEffect, ResistDiff,
    mana, can_mgb, reflectable
) VALUES (
    44021, 'Origin', 'PLAYER_1', 322, 100, 6, 0,
    0, 0, '', 1, 0,
    0, 0, 0
) ON DUPLICATE KEY UPDATE
    name                = 'Origin',
    player_1            = 'PLAYER_1',
    effectid1           = 322,
    effect_base_value1  = 100,
    targettype          = 6,
    cast_time           = 0,
    buffdurationformula = 0,
    buffduration        = 0,
    teleport_zone       = '',
    goodEffect          = 1,
    ResistDiff          = 0,
    mana                = 0,
    can_mgb             = 0,
    reflectable         = 0;

-- The remaining effect slots must be blank (254 = SE_Blank). A freshly
-- inserted row already defaults to that, but a re-run over a hand-edited row
-- would not, so normalise them explicitly.
UPDATE spells_new
SET effectid2  = 254, effectid3  = 254, effectid4  = 254,
    effectid5  = 254, effectid6  = 254, effectid7  = 254,
    effectid8  = 254, effectid9  = 254, effectid10 = 254,
    effectid11 = 254, effectid12 = 254
WHERE id = 44021;

-- ---------------------------------------------------------------------------
-- 2. aa_ability 31082: Manifest Experience -> Origin
-- ---------------------------------------------------------------------------
UPDATE aa_ability
SET name               = 'Origin',
    category           = 9,        -- EverQuest (this server's custom/activated tab)
    classes            = 65535,    -- all classes
    races              = 65535,    -- all races
    drakkin_heritage   = 127,
    deities            = 131071,   -- all deities
    status             = 0,
    type               = 4,
    charges            = 0,
    grant_only         = 0,
    first_rank_id      = 41000,
    enabled            = 1,
    reset_on_death     = 0,
    auto_grant_enabled = 0
WHERE id = 31082;

-- ---------------------------------------------------------------------------
-- 3. aa_ranks 41000: the single Origin rank
--    spell_type mirrors the spell id, which is the convention the other
--    Ascendant ranks on this server follow (ranks 40000-40006, 41000).
-- ---------------------------------------------------------------------------
UPDATE aa_ranks
SET spell            = 44021,
    spell_type       = 44021,
    cost             = 0,
    level_req        = 5,
    recast_time      = 1080,   -- 18 minutes, in seconds (cf. Lay on Hands 4320 = 72 min)
    expansion        = 0,
    prev_id          = -1,
    next_id          = -1,
    -- "Origin" is one word: keep the first half of the two-part short name
    -- (type 2 -> 'Origin') and clear the second half so the client never asks
    -- for the deleted db_str type 3. See the header note on hotkey sids.
    upper_hotkey_sid = 41000,
    lower_hotkey_sid = -1,
    title_sid        = 41000,
    desc_sid         = 41000
WHERE id = 41000;

-- ---------------------------------------------------------------------------
-- 4. Lesson of the Devoted: grant_only 1 -> 0
--    cost is already 0 and level_req stays 50, so this becomes a free purchase
--    from level 50 up for every account, regardless of account age.
-- ---------------------------------------------------------------------------
UPDATE aa_ability
SET grant_only = 0,
    enabled    = 1,
    status     = 0
WHERE id = 481;

UPDATE aa_ranks
SET cost = 0
WHERE id = 1371;

-- ---------------------------------------------------------------------------
-- 5. Client AA strings for the repurposed rank (title_sid = desc_sid = 41000)
--    db_str types: 1 = AA list/tooltip title, 2 = first half of the two-part
--    short name drawn in the AA header and on the hotbutton, 3 = second half of
--    that short name, 4 = AA description.
--    Type 3 is intentionally absent: "Origin" is one word and lower_hotkey_sid
--    is -1 above, so the client never asks for it.
--
--    Type 4 is the bare description. export_client_files prepends the class tag
--    and "[/alt activate <aa_ability.id>]" itself
--    (DbStrRepository::GetDBStrFileLinesMulticlass), so a prefix hardcoded here
--    only double-prints -- and the only number that works in that prefix is the
--    ability id 31082, not the rank id 41000 (see the header note).
-- ---------------------------------------------------------------------------
DELETE FROM db_str WHERE id = 41000 AND type IN (1, 2, 3, 4);
INSERT INTO db_str (id, type, value) VALUES
    (41000, 1, 'Origin'),
    (41000, 2, 'Origin'),
    (41000, 4, 'This ability, when activated, transports you back to your starting city.  You can check your origin location using the command /charinfo.');
