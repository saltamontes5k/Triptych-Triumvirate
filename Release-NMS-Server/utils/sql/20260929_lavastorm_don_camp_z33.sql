-- 20260929_lavastorm_don_camp_z33.sql
-- The Lavastorm DoN camps were spawning below the client terrain, deep inside
-- geometry. Clamp z to a minimum of 33 for the whole camp roster:
--   * custom DoN-access camp near the DoN Porter (spawngroups don_*/lavastorm_don_*,
--     plus the camp NPCs relocated to ~(795,417) by ldon_don_access.sql)
--   * upstream DoN-era camp from the PEQ spawn sync (v1 spawn2 and their v0 dupes)
--   * the camp's merchants and guards
-- Idempotent: only rows currently below 33 are touched, so it is safe to re-run.
-- Spawns already at/above 33 (e.g. don_merchant_Voltak_Shadethorn at 38) are left alone.
SET NAMES utf8mb4;

DROP TABLE IF EXISTS spawn2_bak_20260929_don_camp;
CREATE TABLE spawn2_bak_20260929_don_camp AS
SELECT * FROM spawn2
WHERE zone = 'lavastorm'
  AND id IN (
    -- custom DoN-access camp (officers/leaders + relocated Dark Reign/Keepers camp)
    38275, 38276, 38277, 38278, 38279, 38280, 38281, 38282, 38283,
    38286, 38287, 38289, 38290,
    45000330, 45000331, 45000332, 45000333, 45000334, 45000347,
    910032,
    -- merchants
    45000346,
    -- upstream DoN-era camp (v1 spawn2 and v0 dupes)
    250644, 250645, 250646, 264693, 264696, 264697,
    38273, 38274, 38333
  );

UPDATE spawn2
   SET z = 33
 WHERE zone = 'lavastorm'
   AND z < 33
   AND id IN (
    38275, 38276, 38277, 38278, 38279, 38280, 38281, 38282, 38283,
    38286, 38287, 38289, 38290,
    45000330, 45000331, 45000332, 45000333, 45000334, 45000347,
    910032,
    45000346,
    250644, 250645, 250646, 264693, 264696, 264697,
    38273, 38274, 38333
   );
