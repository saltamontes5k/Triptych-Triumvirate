-- 2026_10_10_monster_mercs_facesmasher_brog.sql
-- Restores the old-server monster mercenary vendor: Facesmasher_Brog (npc 202448, race 574
-- minotaur, PoK 1070/-461 by the bank) becomes the monster-only mercenary liaison, selling:
--   Minotaur Warriors  (race 574, WAR class 1)
--   Siren Soothers     (race 564 TBS siren, CLR class 2)
--   Scrykin Casters    (race 495, WIZ class 12)
-- Tier ladder: Apprentice I-V + Journeyman I-II per race (21 entries). Journeyman Tiers III-V
-- are intentionally omitted: the stock seed ships NO merc_stats for those tiers at all (sources
-- 8-10/18-20/38-40 are empty), so those entries would fail on hire for standard races too.
-- stats/armor/weapon per tier are copied from the standard chain; stances, spell lists and
-- inventory are keyed by class/proficiency/subtype and are shared automatically.
-- dbstring format: [race_id][class 2-digit][proficiency 2-digit][tier 2-digit]
-- (merc_types use class 00 / tier 00; the client renders the grade+race label from it).

-- 1) Brog -> mercenary liaison
UPDATE npc_types SET class = 71, lastname = 'Monster Mercenary Liaison', findable = 1
WHERE id = 202448;

-- 2) merc_types: 3 monster races x 2 proficiencies (ids 49-54)
INSERT INTO merc_types (merc_type_id, race_id, proficiency_id, dbstring, clientversion) VALUES
	(49, 574, 1, '574000100', 4),
	(50, 574, 2, '574000200', 4),
	(51, 564, 1, '564000100', 4),
	(52, 564, 2, '564000200', 4),
	(53, 495, 1, '495000100', 4),
	(54, 495, 2, '495000200', 4);

-- 3) merc_npc_types: 3 classes x (5 Apprentice + 2 Journeyman tiers) (ids 41-70, gaps reserved)
INSERT INTO merc_npc_types (merc_npc_type_id, class_id, proficiency_id, tier_id, name) VALUES
	(41, 1, 1, 1, 'Minotaur Warrior - Apprentice Tank Tier I'),
	(42, 1, 1, 2, 'Minotaur Warrior - Apprentice Tank Tier II'),
	(43, 1, 1, 3, 'Minotaur Warrior - Apprentice Tank Tier III'),
	(44, 1, 1, 4, 'Minotaur Warrior - Apprentice Tank Tier IV'),
	(45, 1, 1, 5, 'Minotaur Warrior - Apprentice Tank Tier V'),
	(46, 1, 2, 1, 'Minotaur Warrior - Journeyman Tank Tier I'),
	(47, 1, 2, 2, 'Minotaur Warrior - Journeyman Tank Tier II'),
	(51, 2, 1, 1, 'Siren Soother - Apprentice Healer Tier I'),
	(52, 2, 1, 2, 'Siren Soother - Apprentice Healer Tier II'),
	(53, 2, 1, 3, 'Siren Soother - Apprentice Healer Tier III'),
	(54, 2, 1, 4, 'Siren Soother - Apprentice Healer Tier IV'),
	(55, 2, 1, 5, 'Siren Soother - Apprentice Healer Tier V'),
	(56, 2, 2, 1, 'Siren Soother - Journeyman Healer Tier I'),
	(57, 2, 2, 2, 'Siren Soother - Journeyman Healer Tier II'),
	(61, 12, 1, 1, 'Scrykin Caster - Apprentice Caster DPS Tier I'),
	(62, 12, 1, 2, 'Scrykin Caster - Apprentice Caster DPS Tier II'),
	(63, 12, 1, 3, 'Scrykin Caster - Apprentice Caster DPS Tier III'),
	(64, 12, 1, 4, 'Scrykin Caster - Apprentice Caster DPS Tier IV'),
	(65, 12, 1, 5, 'Scrykin Caster - Apprentice Caster DPS Tier V'),
	(66, 12, 2, 1, 'Scrykin Caster - Journeyman Caster DPS Tier I'),
	(67, 12, 2, 2, 'Scrykin Caster - Journeyman Caster DPS Tier II');

-- 4) stats / armor / weapon: clone from the standard chain
--    (source -> new id: 1-20 -> +40, 31-40 -> +30)
INSERT INTO merc_stats (merc_npc_type_id, clientlevel, level, hp, mana, AC, ATK, STR, STA, DEX, AGI, _INT, WIS, CHA, MR, CR, DR, FR, PR, Corrup, mindmg, maxdmg, attack_count, attack_speed, attack_delay, special_abilities, Accuracy, hp_regen_rate, mana_regen_rate, runspeed, statscale, spellscale, healscale)
SELECT s.merc_npc_type_id + CASE WHEN s.merc_npc_type_id BETWEEN 31 AND 40 THEN 30 ELSE 40 END,
	s.clientlevel, s.level, s.hp, s.mana, s.AC, s.ATK, s.STR, s.STA, s.DEX, s.AGI, s._INT, s.WIS, s.CHA,
	s.MR, s.CR, s.DR, s.FR, s.PR, s.Corrup, s.mindmg, s.maxdmg, s.attack_count, s.attack_speed,
	s.attack_delay, s.special_abilities, s.Accuracy, s.hp_regen_rate, s.mana_regen_rate, s.runspeed,
	s.statscale, s.spellscale, s.healscale
FROM merc_stats s
WHERE s.merc_npc_type_id IN (1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,31,32,33,34,35,36,37,38,39,40);

INSERT INTO merc_armorinfo (merc_npc_type_id, minlevel, maxlevel, texture, helmtexture, armortint_id, armortint_red, armortint_green, armortint_blue)
SELECT a.merc_npc_type_id + CASE WHEN a.merc_npc_type_id BETWEEN 31 AND 40 THEN 30 ELSE 40 END,
	a.minlevel, a.maxlevel, a.texture, a.helmtexture, a.armortint_id, a.armortint_red, a.armortint_green, a.armortint_blue
FROM merc_armorinfo a
WHERE a.merc_npc_type_id IN (1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,31,32,33,34,35,36,37,38,39,40);

INSERT INTO merc_weaponinfo (merc_npc_type_id, minlevel, maxlevel, d_melee_texture1, d_melee_texture2, prim_melee_type, sec_melee_type)
SELECT w.merc_npc_type_id + CASE WHEN w.merc_npc_type_id BETWEEN 31 AND 40 THEN 30 ELSE 40 END,
	w.minlevel, w.maxlevel, w.d_melee_texture1, w.d_melee_texture2, w.prim_melee_type, w.sec_melee_type
FROM merc_weaponinfo w
WHERE w.merc_npc_type_id IN (1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,31,32,33,34,35,36,37,38,39,40);

-- 5) templates 554-583 (clientversion 4 = visible to every client; subtype from standard chain)
INSERT INTO merc_templates (merc_type_id, merc_subtype_id, merc_npc_type_id, dbstring, name_type_id, clientversion) VALUES
	(49, 1, 41, '574010101', 0, 4), (49, 2, 42, '574010102', 0, 4), (49, 3, 43, '574010103', 0, 4),
	(49, 4, 44, '574010104', 0, 4), (49, 5, 45, '574010105', 0, 4),
	(50, 1, 46, '574010201', 0, 4), (50, 2, 47, '574010202', 0, 4),
	(51, 6, 51, '564020101', 0, 4), (51, 7, 52, '564020102', 0, 4), (51, 8, 53, '564020103', 0, 4),
	(51, 9, 54, '564020104', 0, 4), (51, 10, 55, '564020105', 0, 4),
	(52, 6, 56, '564020201', 0, 4), (52, 7, 57, '564020202', 0, 4),
	(53, 16, 61, '495120101', 0, 4), (53, 17, 62, '495120102', 0, 4), (53, 18, 63, '495120103', 0, 4),
	(53, 19, 64, '495120104', 0, 4), (53, 20, 65, '495120105', 0, 4),
	(54, 16, 66, '495120201', 0, 4), (54, 17, 67, '495120202', 0, 4);

-- 6) Brog's merchant catalog (group 25)
INSERT INTO merc_merchant_templates (merc_merchant_template_id, name, qglobal) VALUES
	(25, 'Monster Mercenaries - Facesmasher Brog', '');
INSERT INTO merc_merchant_entries (merc_merchant_template_id, merchant_id) VALUES
	(25, 202448);
INSERT INTO merc_merchant_template_entries (merc_merchant_template_id, merc_template_id) VALUES
	(25, 554), (25, 555), (25, 556), (25, 557), (25, 558), (25, 559), (25, 560),
	(25, 564), (25, 565), (25, 566), (25, 567), (25, 568), (25, 569), (25, 570),
	(25, 574), (25, 575), (25, 576), (25, 577), (25, 578), (25, 579), (25, 580);
