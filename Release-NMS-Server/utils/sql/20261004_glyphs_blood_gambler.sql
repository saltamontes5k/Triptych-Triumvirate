-- Bring back the offensive glyphs, Invitation of Blood, and add Glyph of the Gambler
-- (2026-10-04)
--
-- 1) Glyph of Destruction (589) / Glyph of the Cataclysm (7019): their spells
--    carried THREE additive SE_CriticalDamageMob slots (3x40=+120%, 3x60=+180%)
--    and limit_value 0 instead of all-skills. Collapsed to one all-skill slot at
--    the intended values (+50% / +60% for 2 minutes). Ranks already carry 600s
--    recast; abilities changed charges 1 -> 0 so they are reusable purchases
--    instead of consumed expendables. Code side: removed 589/5003/7019 from the
--    multiclass hardcoded grant_only/cost-0 list (zone/aa.cpp) so they are
--    buyable in the AA window again.
-- 2) Glyph of Frantic Infusion (5003): pet min-damage staging via 3 trainable
--    ranks (+10/+15/+20%, SE_MinDamageModifier is max-wins so stacked slots
--    cannot stage). Rank 7003's spell re-tuned 110 -> 10; new ranks 41012/41013
--    with spells 121863/121864 (+15/+20%).
-- 3) Invitation of Blood (31089 / rank 41011 / spell 121865): recreated as a
--    real ability. Casting costs 20% of current HP (script-clamped, cannot
--    kill) and grants +25% damage modifier (SE_DamageModifier 185) for 30
--    seconds. The old rank 1382 stub was pure flavor (no spell, spacer effect);
--    it remains in aa_ranks_stale_backup_20261004.
-- 4) Glyph of the Gambler (31088 / rank 41010 / spell 121862): new AA that
--    summons a completely random item from gambler_item_pool (curated,
--    admin-extendable). 5 AA points, 12 hour reuse. Handler:
--    quests/global/spells/121862.pl.
--
-- Idempotent. Rollback notes inline. Requires zone restart (#hotfix spells ok)
-- and client file re-export (spells 121862-121865 are new).
SET NAMES utf8mb4;

-- ---------------------------------------------------------------------------
-- 1. Glyph of Destruction (spell 9479) + Cataclysm (spell 21661)
-- ---------------------------------------------------------------------------
UPDATE spells_new SET
  effectid1 = 330, effect_base_value1 = 50, effect_limit_value1 = -1,
  effectid2 = 254, effect_base_value2 = 0,
  effectid3 = 254, effect_base_value3 = 0,
  cast_time = 0, buffdurationformula = 3, buffduration = 20
WHERE id = 9479;

UPDATE spells_new SET
  effectid1 = 330, effect_base_value1 = 60, effect_limit_value1 = -1,
  effectid2 = 254, effect_base_value2 = 0,
  effectid3 = 254, effect_base_value3 = 0,
  cast_time = 0, buffdurationformula = 3, buffduration = 20
WHERE id = 21661;

UPDATE aa_ability SET charges = 0 WHERE id IN (589, 5003, 7019) AND charges = 1;
-- Rollback charges: UPDATE aa_ability SET charges = 1 WHERE id IN (589, 5003, 7019);
-- Rollback spell values: slot1 base 40 / 60 x3 slots, limit 0 (see git history).

-- ---------------------------------------------------------------------------
-- 2. Glyph of Frantic Infusion: rank 1 re-tune + ranks 2/3 (+15/+20%)
-- ---------------------------------------------------------------------------
UPDATE spells_new SET
  effectid1 = 186, effect_base_value1 = 10, effect_limit_value1 = -1,
  effectid2 = 254, effect_base_value2 = 0,
  effectid3 = 254, effect_base_value3 = 0,
  targettype = 14, cast_time = 500, buffdurationformula = 3, buffduration = 10
WHERE id = 12751;

INSERT INTO spells_new (id, name, player_1, effectid1, effect_base_value1,
                        effect_limit_value1, targettype, cast_time,
                        buffdurationformula, buffduration, goodEffect, mana)
VALUES
 (121863, 'Glyph of Frantic Infusion', 'PLAYER_1', 186, 15, -1, 14, 500, 3, 10, 1, 0),
 (121864, 'Glyph of Frantic Infusion', 'PLAYER_1', 186, 20, -1, 14, 500, 3, 10, 1, 0)
ON DUPLICATE KEY UPDATE effect_base_value1 = VALUES(effect_base_value1);

UPDATE spells_new
SET effectid2=254, effectid3=254, effectid4=254, effectid5=254, effectid6=254,
    effectid7=254, effectid8=254, effectid9=254, effectid10=254, effectid11=254, effectid12=254
WHERE id BETWEEN 121863 AND 121864;

UPDATE aa_ranks SET next_id = 41012 WHERE id = 7003;

INSERT INTO aa_ranks (id, title_sid, desc_sid, cost, level_req, spell, spell_type,
                      recast_time, expansion, prev_id, next_id)
VALUES
 (41012, 7003, 7003, 4, 1, 121863, 121863, 600, 3, 7003, 41013),
 (41013, 7003, 7003, 4, 1, 121864, 121864, 600, 3, 41012, -1);

-- ---------------------------------------------------------------------------
-- 3. Invitation of Blood (ability 31089, rank 41011, spell 121865)
-- ---------------------------------------------------------------------------
INSERT INTO spells_new (id, name, player_1, effectid1, effect_base_value1,
                        effect_limit_value1, effectid2, effect_base_value2,
                        effect_limit_value2, targettype, cast_time,
                        buffdurationformula, buffduration, goodEffect, mana)
VALUES
 (121865, 'Invitation of Blood', 'PLAYER_1', 254, 0, 0, 185, 25, -1, 6, 0, 3, 5, 1, 0)
ON DUPLICATE KEY UPDATE name = VALUES(name);

UPDATE spells_new
SET effectid3=254, effectid4=254, effectid5=254, effectid6=254, effectid7=254,
    effectid8=254, effectid9=254, effectid10=254, effectid11=254, effectid12=254
WHERE id = 121865;

INSERT INTO aa_ability (id, name, category, classes, races, deities, drakkin_heritage,
                        type, charges, grant_only, first_rank_id, enabled)
VALUES
 (31089, 'Invitation of Blood', 9, 65535, 65535, 131071, 127, 4, 0, 0, 41011, 1)
ON DUPLICATE KEY UPDATE name = VALUES(name), first_rank_id = 41011, enabled = 1;

INSERT INTO aa_ranks (id, title_sid, desc_sid, cost, level_req, spell, spell_type,
                      recast_time, expansion, prev_id, next_id)
VALUES
 (41011, 41011, 41011, 5, 50, 121865, 121865, 600, 0, -1, -1);

DELETE FROM db_str WHERE id = 41011 AND type IN (1, 4);
INSERT INTO db_str (id, type, value) VALUES
 (41011, 1, 'Invitation of Blood'),
 (41011, 4, 'You are now one with the curse.  It calls to you, offering you limitless power in exchange for obedience.  Activating the Invitation sacrifices a fifth of your current health and floods you with power, increasing all damage you deal by 25% for 30 seconds.  The curse will not take your last breath.');

-- ---------------------------------------------------------------------------
-- 4. Glyph of the Gambler (ability 31088, rank 41010, spell 121862)
-- ---------------------------------------------------------------------------
INSERT INTO spells_new (id, name, player_1, targettype, cast_time,
                        buffdurationformula, buffduration, goodEffect, mana)
VALUES
 (121862, 'Glyph of the Gambler', 'PLAYER_1', 6, 0, 0, 0, 1, 0)
ON DUPLICATE KEY UPDATE name = VALUES(name);

INSERT INTO aa_ability (id, name, category, classes, races, deities, drakkin_heritage,
                        type, charges, grant_only, first_rank_id, enabled)
VALUES
 (31088, 'Glyph of the Gambler', 9, 65535, 65535, 131071, 127, 4, 0, 0, 41010, 1)
ON DUPLICATE KEY UPDATE name = VALUES(name), first_rank_id = 41010, enabled = 1;

INSERT INTO aa_ranks (id, title_sid, desc_sid, cost, level_req, spell, spell_type,
                      recast_time, expansion, prev_id, next_id)
VALUES
 (41010, 41010, 41010, 5, 50, 121862, 121862, 43200, 0, -1, -1);

DELETE FROM db_str WHERE id = 41010 AND type IN (1, 4);
INSERT INTO db_str (id, type, value) VALUES
 (41010, 1, 'Glyph of the Gambler'),
 (41010, 4, 'Activating the glyph summons a completely random item from the Gambler''s hoard.  Fortune favors nobody in particular.');

-- Item pool (curated; admins extend with plain INSERTs)
CREATE TABLE IF NOT EXISTS `gambler_item_pool` (
  `id`      INT NOT NULL AUTO_INCREMENT,
  `item_id` INT NOT NULL,
  `note`    VARCHAR(128) NOT NULL DEFAULT '',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_gip_item` (`item_id`)
) ENGINE=InnoDB;

INSERT IGNORE INTO gambler_item_pool (item_id, note) VALUES
 (121858, 'Goldfish Flakes'),
 (81258,  'Potion of Growth'),
 (77918,  'Spell: Illusion: Orc'),
 (61215,  'Blue Crystallized Essence'),
 (57455,  'FR/CR VIII augment'),
 (57459,  'Magic Resist VIII augment'),
 (57460,  'PR/DR VIII augment'),
 (41800,  'Benefit: Summoning Efficiency 09'),
 (41803,  'Benefit: Summoning Haste 09'),
 (85292,  'Bracer of Manifested Ether'),
 (71252,  'Bracer of Gnoll Hides'),
 (70077,  'Bracer of the Beaconguard'),
 (70556,  'Bracer of Bleak Omens'),
 (85299,  'Bracer of Suppressed Ether'),
 (89835,  'Bracer of the Natureguard'),
 (70112,  'Bracer of the Destitute'),
 (70286,  'Bracer of Burning Links'),
 (85306,  'Bracer of Flowing Ether'),
 (89834,  'Bracer of the Takish Guard'),
 (89836,  'Bracer of the Elddar Preserver'),
 (83462,  'Bracer of Blinding Rage'),
 (71572,  'Bracer of the Warriors'),
 (89837,  'Bracer of the Scrollkeeper'),
 (87064,  'Bracer of Undying Memories');

-- Rollback: DELETE FROM aa_ranks WHERE id IN (41010,41011,41012,41013);
--           DELETE FROM aa_ability WHERE id IN (31088,31089);
--           UPDATE aa_ability SET charges = 1 WHERE id IN (589, 7019);
--           UPDATE aa_ranks SET next_id = -1 WHERE id = 7003;
--           (spells/items/pool rows are additive; drop by id if desired)
