-- ============================================================================
-- Delete two mis-wired named spawns revived by the PEQ additive sync.
--
-- spawn2 264369 (guildhall v1) referenced the thundercrest group 287844 for
-- Scion_of_the_Sky; spawn2 264371 (cabeast) referenced the thenest group 287846
-- for #Filimar_Starshaper. Both zones are wrong, and the correct spawns already
-- exist (264465 thundercrest v7, 264467 thenest v11). Guarded deletes.
-- ============================================================================

DELETE FROM `spawn2`
 WHERE `id` = 264369 AND `zone` = 'guildhall' AND `spawngroupID` = 287844;

DELETE FROM `spawn2`
 WHERE `id` = 264371 AND `zone` = 'cabeast' AND `spawngroupID` = 287846;
