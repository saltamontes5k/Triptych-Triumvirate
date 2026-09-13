-- ============================================================================
-- Classic HP fixes -- templeveeshan / necropolis / droga / nurga
-- ----------------------------------------------------------------------------
-- Audit (2026-09-13) vs the Alkabor (TakP / EQMac) classic dump found these
-- five zones broadly match classic values, EXCEPT for a small set of NPCs
-- whose live HP runs >= 1.3x the Alkabor reference (the "modern HP" symptom).
-- This patch lowers only those inflated rows. HP-only: level, damage and AC
-- are left untouched, and NPCs that are below Alkabor are intentionally left
-- alone (server balancing), as are necropolis live-only revamp NPCs,
-- expansion-gated variants, and trigger/object NPCs.
--
-- No spawn2/spawngroup changes: unlike Veeshan's Peak there is no duplicate
-- population here.
--
-- Idempotent: absolute HP values. Re-apply verbatim after any reimport.
-- ============================================================================

BEGIN;

-- ---------------------------------------------------------------------------
-- Temple of Veeshan (Alkabor #Lord_Kreizenn L66 hp 350000)
-- ---------------------------------------------------------------------------
UPDATE npc_types SET hp = 350000 WHERE id = 124074;  -- #Lord_Kreizenn        465000

-- ---------------------------------------------------------------------------
-- Dragon Necropolis (Alkabor reference values per name)
-- ---------------------------------------------------------------------------
UPDATE npc_types SET hp = 9767  WHERE id = 123075;   -- a_Chetari_seeker      17000
UPDATE npc_types SET hp = 9767  WHERE id = 123012;   -- a_Chetari_Seeker      15500
UPDATE npc_types SET hp = 9767  WHERE id = 123041;   -- a_Chetari_master      15500
UPDATE npc_types SET hp = 9767  WHERE id = 123069;   -- a_Chetari_master      14500
UPDATE npc_types SET hp = 7500  WHERE id = 123087;   -- a_Chetari_Deathbinder 10500
UPDATE npc_types SET hp = 14078 WHERE id = 123131;   -- Warmaster_Utvara      19000
UPDATE npc_types SET hp = 14078 WHERE id = 123090;   -- #Dominator_Yisaki     19000
UPDATE npc_types SET hp = 14078 WHERE id = 123091;   -- Seeker_Bulava         19000

-- ---------------------------------------------------------------------------
-- Mines of Droga (Alkabor an_Iksar_slave L30 hp 1150)
-- ---------------------------------------------------------------------------
UPDATE npc_types SET hp = 1150  WHERE id = 781003;   -- an_Iksar_slave        2000
UPDATE npc_types SET hp = 1150  WHERE id = 781469;   -- an_Iksar_slave        2000

-- ---------------------------------------------------------------------------
-- Mines of Nurga (Alkabor an_Iksar_slave L30 hp 1150)
-- ---------------------------------------------------------------------------
UPDATE npc_types SET hp = 1150  WHERE id = 807136;   -- an_Iksar_slave        2500

COMMIT;
