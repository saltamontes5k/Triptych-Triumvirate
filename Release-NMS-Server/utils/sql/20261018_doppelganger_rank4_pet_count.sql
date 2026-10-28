-- Doppelganger ranks 4-13 summons dropped from 3 copies (rank 3, spell 4554)
-- back to 2 from rank 4 on (12580..31606), so the "Azia/Beza/Caza" ordinals
-- stopped at Beza. Restore the rank-3 count for every rank from 4 up, including
-- the unreferenced DG14-18 spells, so progression never drops a copy.
--
-- Twin of manifest entry 221. Client spells_us.txt is regenerated with:
--   export_client_files.exe spells

UPDATE `spells_new` SET `effect_base_value1`=3 WHERE `id` IN (12580,12581,12582,13726,13727,13728,16829,16830,16831,31606,31607,31608,33930,33931,33932);
