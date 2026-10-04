-- ============================================================================
-- Origin AA -- replaces the Lucky Coin "Manifest Experience" AA
--
-- End state
--   aa_ability 31082  "Manifest Experience" -> "Origin", all classes / races /
--                     deities, activated, not grant-only.
--   aa_ranks   41000  points at the new spell 121861, 1080s (18 minute) reuse,
--                     cost 0, level 5, single rank.
--   spells_new 121861 new "Origin" spell whose first effect is
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
--   The AA window button always sends the *rank* id, which is 41000, and the
--   server resolves activation through aa_ranks (Client::Handle_OP_AAAction ->
--   ActivateAlternateAdvancementAbility -> Zone::GetAlternateAdvancementRank), so
--   "/alt activate 41000" is what actually works. The retail db_str strings
--   advertise the ability id instead (e.g. AA 35 "Mass Group Buff" says
--   /alt activate 35 while its rank is 128, and aa_ranks has an unrelated id 35),
--   so that wording is stale flavor text and does not resolve server side.
--   The AA title below therefore says 41000, not 31082.
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
--   latter is what teaches the client about the new spell 121861.
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
    121861, 'Origin', 'PLAYER_1', 322, 100, 6, 5000,
    0, 0, '', 1, 0,
    0, 0, 0
) ON DUPLICATE KEY UPDATE
    name                = 'Origin',
    player_1            = 'PLAYER_1',
    effectid1           = 322,
    effect_base_value1  = 100,
    targettype          = 6,
    cast_time           = 5000,
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
WHERE id = 121861;

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
SET spell       = 121861,
    spell_type  = 121861,
    cost        = 0,
    level_req   = 5,
    recast_time = 1080,   -- 18 minutes, in seconds (cf. Lay on Hands 4320 = 72 min)
    expansion   = 0,
    prev_id     = -1,
    next_id     = -1,
    title_sid   = 41000,
    desc_sid    = 41000
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
--    db_str types: 1 = AA title, 2 = first line of the 2-line spell name,
--    3 = second line of that name, 4 = AA description.
--    Type 3 is deleted rather than blanked because "Origin" is a one-line name.
-- ---------------------------------------------------------------------------
DELETE FROM db_str WHERE id = 41000 AND type IN (1, 2, 3, 4);
INSERT INTO db_str (id, type, value) VALUES
    (41000, 1, 'Origin'),
    (41000, 2, 'Origin'),
    (41000, 4, '(ALL) [/alt activate 31082]<br>This ability, when activated, transports you back to your starting city.  You can check your origin location using the command /charinfo.');
