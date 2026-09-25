-- Dirtdigger "invasion" spawn leak cleanup (non-native zones)
-- Applied to live `peq` 2026-09-19. Idempotent.
--
-- `a_Dirtdigger_*` are Dragons of Norrath mobs native to The Broodlands and
-- Thundercrest Mountains. Every Dirtdigger spawngroup is shared between a
-- thundercrest spawn2 and a "mirror" spawn2 in another zone. The mirrors in
-- cazicthule/dreadlands/eastkarana/eastwastes/frontiermtns/sro/wakening/
-- westwastes were already suppressed via spawn2_disabled; these 29 in
-- oot/thedeep/lavastorm/nektulos were missed and leaked level 67-68 mobs,
-- including into The Deep.
--
-- NOTE: several Lavastorm/Nektulos points are "mixed" spawngroups that the PEQ
-- B7 additive sync polluted with Dirtdigger entries (spawngroup-id collision
-- with pre-existing local groups like lavastorm-drk000). Disabling the mirror
-- spawn2 is the minimal, convention-consistent fix; a deeper split of those
-- collided spawngroups is queued as a separate audit.
SET NAMES utf8mb4;
START TRANSACTION;

INSERT INTO spawn2_disabled (spawn2_id, instance_id, disabled)
SELECT id, 0, 1 FROM (
  SELECT 264382 AS id            -- oot (pure)
  UNION ALL SELECT 264391         -- thedeep (pure)
  UNION ALL SELECT 264419 UNION ALL SELECT 264426   -- lavastorm (pure)
  UNION ALL SELECT 2140573 UNION ALL SELECT 264427  -- nektulos
  UNION ALL SELECT 2140581 UNION ALL SELECT 2140584 UNION ALL SELECT 2140585
  UNION ALL SELECT 2140590 UNION ALL SELECT 2140592 UNION ALL SELECT 2140593
  UNION ALL SELECT 2140596 UNION ALL SELECT 2140598 UNION ALL SELECT 2140603
  UNION ALL SELECT 2140606 UNION ALL SELECT 2140607 UNION ALL SELECT 2140608
  UNION ALL SELECT 2140609 UNION ALL SELECT 2140610 UNION ALL SELECT 2140611
  UNION ALL SELECT 2140616 UNION ALL SELECT 2140618 UNION ALL SELECT 2140623
  UNION ALL SELECT 2140639 UNION ALL SELECT 2140642 UNION ALL SELECT 2140647
  UNION ALL SELECT 2140652 UNION ALL SELECT 2140671  -- lavastorm (mixed)
) t
WHERE NOT EXISTS (SELECT 1 FROM spawn2_disabled d WHERE d.spawn2_id = t.id AND d.instance_id = 0);

COMMIT;

-- Kept enabled (native / legit): thundercrest, broodlands, and
-- potranquility 40908 `Muzzrap_Dirtdigger` (DoN task NPC).
-- After applying: #repop thedeep, oot, lavastorm, nektulos.
