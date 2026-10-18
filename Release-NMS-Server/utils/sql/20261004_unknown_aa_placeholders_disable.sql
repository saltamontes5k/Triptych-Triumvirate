-- Disable "Unknown AA" placeholder lines (2026-10-04)
--
-- These 186 placeholder lines (plus the id-0 "Unknown AA -1" row) were
-- previously hidden only by accident: their ranks carried expansion 99999999
-- and CanUseAlternateAdvancementRank's `1 << (expansion - 1)` overflows to
-- bit 30, which the World:ExpansionSettings mask (524287) does not include.
-- The 20261004 UF cap (expansion -> 16) intentionally removed that accident's
-- coverage for real custom content, which also surfaced this junk in the AA
-- window (reported on a BRD/BER/ROG character).
--
-- Proper gate: enabled = 0. The loader loads enabled = 1 only, so these never
-- reach the window, the purchase path, or auto-grant regardless of any future
-- expansion-code changes. Verified before applying: zero characters own ranks
-- of any of these lines and zero aa_custom_mapping rows reference them.
-- The id-0 row also carried auto_grant_enabled = 1 (audit landmine; the
-- auto-grant rule is off, but the flag is cleared too).
--
-- Applied live 2026-10-04: 186 placeholders + id 0 disabled.
-- Companion code guard (zone/aa.cpp): rank->expansion > 32 is now an
-- intentional "always hidden" sentinel, so 99999999 keeps meaning exactly
-- that even if the shift overflow is ever fixed.

UPDATE aa_ability
SET enabled = 0, auto_grant_enabled = 0
WHERE enabled = 1 AND name LIKE 'Unknown%';

UPDATE aa_ability
SET enabled = 0, auto_grant_enabled = 0
WHERE id = 0;

-- Rollback: re-enable by id from git history of this file's pre-state
-- (SELECT id FROM aa_ability WHERE name LIKE 'Unknown%'), or restore from
-- any pre-20261004 dump of aa_ability.
