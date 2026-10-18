-- Dedicated shroud clone AAs.
-- The shroud_abilities catalog reuses real classic AA lines for a form's granted
-- passives; mirror them into a dedicated 92000+ ability band / 93000+ rank band
-- and repoint the catalog (and recorded per-form purchases) at the clones, so the
-- real lines stay normal AAs. One clone per referenced ability, first
-- MAX(max_rank) ranks each. Idempotent.
DROP TEMPORARY TABLE IF EXISTS nms_shroud_abil_map;
DROP TEMPORARY TABLE IF EXISTS nms_shroud_rank_map;

CREATE TEMPORARY TABLE nms_shroud_abil_map AS
SELECT a.id AS real_id,
       92000 + ROW_NUMBER() OVER (ORDER BY a.id) - 1 AS clone_id
FROM aa_ability a
WHERE a.id IN (SELECT DISTINCT aa_id FROM shroud_abilities WHERE aa_id < 90100);

CREATE TEMPORARY TABLE nms_shroud_rank_map AS
WITH RECURSIVE chain AS (
  SELECT m.real_id AS real_ability_id, m.clone_id AS clone_ability_id,
         a.first_rank_id AS real_rank_id, 1 AS depth
  FROM nms_shroud_abil_map m JOIN aa_ability a ON a.id = m.real_id
  UNION ALL
  SELECT c.real_ability_id, c.clone_ability_id, r.next_id, c.depth + 1
  FROM chain c JOIN aa_ranks r ON r.id = c.real_rank_id
  WHERE r.next_id > 0
)
SELECT real_ability_id, clone_ability_id, real_rank_id, depth,
       93000 + ROW_NUMBER() OVER (ORDER BY real_rank_id) - 1 AS clone_rank_id
FROM chain c
WHERE c.depth <= (SELECT MAX(max_rank) FROM shroud_abilities s WHERE s.aa_id = c.real_ability_id);

DELETE FROM aa_rank_effects WHERE rank_id IN (SELECT clone_rank_id FROM nms_shroud_rank_map);
DELETE FROM aa_rank_prereqs WHERE rank_id IN (SELECT clone_rank_id FROM nms_shroud_rank_map);
DELETE FROM aa_ranks       WHERE id        IN (SELECT clone_rank_id FROM nms_shroud_rank_map);
DELETE FROM aa_ability     WHERE id        IN (SELECT clone_id FROM nms_shroud_abil_map);

INSERT INTO aa_ability (id,name,category,classes,races,drakkin_heritage,deities,status,type,charges,grant_only,first_rank_id,enabled,reset_on_death,auto_grant_enabled)
SELECT m.clone_id, CONCAT('Shroud ', a.name), a.category, a.classes, a.races, a.drakkin_heritage, a.deities, a.status, a.type, a.charges, a.grant_only, h.clone_rank_id, a.enabled, a.reset_on_death, a.auto_grant_enabled
FROM aa_ability a
JOIN nms_shroud_abil_map m ON m.real_id = a.id
JOIN nms_shroud_rank_map h ON h.real_ability_id = a.id AND h.depth = 1;

INSERT INTO aa_ranks (id,upper_hotkey_sid,lower_hotkey_sid,title_sid,desc_sid,cost,level_req,spell,spell_type,recast_time,expansion,prev_id,next_id)
SELECT rm.clone_rank_id, r.upper_hotkey_sid, r.lower_hotkey_sid, r.title_sid, r.desc_sid, r.cost, r.level_req, r.spell, r.spell_type, r.recast_time, r.expansion,
       COALESCE(pv.clone_rank_id, -1), COALESCE(nx.clone_rank_id, -1)
FROM nms_shroud_rank_map rm
JOIN aa_ranks r ON r.id = rm.real_rank_id
LEFT JOIN nms_shroud_rank_map pv ON pv.real_rank_id = r.prev_id
LEFT JOIN nms_shroud_rank_map nx ON nx.real_rank_id = r.next_id;

INSERT INTO aa_rank_effects (rank_id,slot,effect_id,base1,base2)
SELECT rm.clone_rank_id, e.slot, e.effect_id, e.base1, e.base2
FROM aa_rank_effects e JOIN nms_shroud_rank_map rm ON rm.real_rank_id = e.rank_id;

INSERT INTO aa_rank_prereqs (rank_id,aa_id,points)
SELECT rm.clone_rank_id, COALESCE(am.clone_id, p.aa_id), p.points
FROM aa_rank_prereqs p
JOIN nms_shroud_rank_map rm ON rm.real_rank_id = p.rank_id
LEFT JOIN nms_shroud_abil_map am ON am.real_id = p.aa_id;

UPDATE shroud_abilities s JOIN nms_shroud_abil_map m ON s.aa_id = m.real_id SET s.aa_id = m.clone_id;
UPDATE character_shroud_aa c JOIN nms_shroud_abil_map m ON c.aa_id = m.real_id SET c.aa_id = m.clone_id;

DROP TEMPORARY TABLE nms_shroud_rank_map;
DROP TEMPORARY TABLE nms_shroud_abil_map;
