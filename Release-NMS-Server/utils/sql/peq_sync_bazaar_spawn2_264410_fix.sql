-- ============================================================================
-- Bazaar spawn2 264410 fix (restore Alchemist_Redsa, remove stray dervish)
--
-- The bazaar v0 spawn point `spawn2` id 264410 referenced spawngroup 287885.
-- The intended bazaar group is 1287885 ('bazaar-Alchemist_Redsa000'); the
-- spawngroupID was a typo missing its leading '1'. Group 287885 did not exist
-- locally, so the spawn was dead. The PEQ additive sync then imported upstream
-- 287885 ('thundercrest_287885' -> a_swirling_dervish), which revived the
-- typo'd spawn and put a swirling dervish in the bazaar.
--
-- This repoints the spawn to the intended group: removes the dervish and
-- restores the Alchemist_Redsa bazaar spawn.
-- ============================================================================

UPDATE `spawn2`
   SET `spawngroupID` = 1287885
 WHERE `id` = 264410
   AND `zone` = 'bazaar'
   AND `spawngroupID` = 287885;
