-- ============================================================================
-- Manifest Experience AA -> Lucky Coin (spell wiring)
-- Source: Ascendant-EQ-Emu/Ascendant-Server @ main
--   server/quests/global/spells/27086.pl  +  spell 27086 "Transmute Experience"
-- Adapted for Triptych/EQS:
--   Local spell 27086 is the live PEQ "Pet Illusion: Stoneworker", so the AA
--   rank 41000 (aa_ability 31082 "Manifest Experience") cannot use it. The
--   Ascendant spell is copied verbatim into the free id 121860 and the AA rank
--   is repointed to it. The coin granted by global/spells/121860.pl is the local
--   Lucky Coin 121857 (used by Harley Wynn).
-- Idempotent. Rollback: 20260928_ascendant_lucky_coin_aa_rollback.sql
-- ============================================================================
SET NAMES utf8mb4;

DELETE FROM spells_new WHERE id = 121860;
INSERT INTO spells_new VALUES (121860,'Transmute Experience','PLAYER_1','','','','','','',100,0,0,0,100,100,100,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,2510,2051,-1,-1,-1,-1,1,1,1,1,-1,-1,-1,-1,100,100,100,100,100,100,100,100,100,100,100,100,0,1,0,0,254,254,254,254,254,254,254,254,254,254,254,254,6,25,5,-1,0,0,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,51,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,100,0,191,209,0,0,0,1,0,0,0,0,0,12,0,0,0,0,0,0,0,100,0,0,0,0,0,0,0,0,0,0,0,0,0,5,101,17,20,0,0,0,0,0,0,5,100,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,0,0,0,1,0,0,1,1,1,0,-1,0,0,0,5,19,-1,0,1,0,0,1,0,1,0,0,0,0,0,0);

UPDATE aa_ranks SET spell = 121860, spell_type = 121860 WHERE id = 41000;

UPDATE db_str SET value = 'Manifest your Alternative Advancement Experience Points into a Lucky Coin to try your luck with Harley Wynn.  Each click transmutes 3 AA points into a Lucky Coin.' WHERE id = 41000 AND type = 4;
