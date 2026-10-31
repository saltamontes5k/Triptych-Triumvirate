-- v296: bot-brain mercenary spell list rows (Custom:MercBotBrain ships in the same migration).
--
-- Only the Master/Legendary lists (proficiency 3/4) gain rows; Apprentice/Journeyman lists are
-- untouched, so lower tiers keep the stock merc brain even with the rule on. Lists 11/12 (CLR
-- healers) and 15/16 (WIZ casters) are the only lists that can use the new behaviors — this
-- server's merc ecosystem is the four role classes (1/2/9/12) — and every spell below is
-- native to the class kit, verified against spells_new effect ids:
--   SE_Stun = 21 (single-target stuns, targettype 5), SE_Root = 99, SE_InstantHate = 92
--   (negative = hate reduction). IsPureNukeSpell requires exactly one effect, so the
--   stun-rider nukes and Concussive can never surface as primary nukes; they serve only their
--   dedicated dispatch branches:
--     Escape (SpellType_Escape = 16)   -> Concussive hate drop when HasOrMayGetAggro
--     Root   (SpellType_Root = 4)      -> Fetter line on fleeing targets
--     Debuff (SpellType_Debuff = 16384)-> healer stun when nobody needs healing and the
--                                         target is casting; stun-rider nukes (Telekin line)
--                                         feed the existing 15% stun roll via SE_Stun scan
-- slot 1-2 keeps them behind the combat rows; stance 0 = valid in every stance.

DELETE FROM `merc_spell_list_entries`
WHERE `merc_spell_list_id` IN (11, 12, 15, 16)
  AND `spell_type` IN (4, 16, 16384);

-- WIZ (lists 15/16): Concussive Blast family — hate-drop nukes (SE_InstantHate -4800/-5200)
INSERT INTO `merc_spell_list_entries`
	(`merc_spell_list_id`,`spell_id`,`spell_type`,`stance_id`,`minlevel`,`maxlevel`,`slot`,`procChance`)
VALUES
	(15, 10782, 16, 0, 71, 255, 1, 0),  -- Concussive Blast (Master)
	(16, 10784, 16, 0, 71, 255, 1, 0);  -- Concussive Blast Rk. III (Legendary)

-- WIZ (lists 15/16): Fetter line — roots (SE_Root) for the fleeing-target policy
INSERT INTO `merc_spell_list_entries`
	(`merc_spell_list_id`,`spell_id`,`spell_type`,`stance_id`,`minlevel`,`maxlevel`,`slot`,`procChance`)
VALUES
	(15, 1633, 4, 0, 58, 62, 1, 0),     -- Fetter
	(15, 3194, 4, 0, 63, 255, 2, 0),    -- Greater Fetter (slot 2: preferred when both load)
	(16, 1633, 4, 0, 58, 62, 1, 0),
	(16, 3194, 4, 0, 63, 255, 2, 0);

-- WIZ (lists 15/16): Telekin line — nukes with SE_Stun riders for the existing stun roll
INSERT INTO `merc_spell_list_entries`
	(`merc_spell_list_id`,`spell_id`,`spell_type`,`stance_id`,`minlevel`,`maxlevel`,`slot`,`procChance`)
VALUES
	(15, 3333, 1, 0, 64, 69, 1, 0),     -- Telekin
	(15, 5456, 1, 0, 70, 255, 1, 0),    -- Telekara
	(16, 3333, 1, 0, 64, 69, 1, 0),
	(16, 5456, 1, 0, 70, 255, 1, 0);

-- CLR (lists 11/12): single-target stun ladder (SE_Stun, targettype 5) as SpellType_Debuff;
-- dispatched only when nobody needs healing and the target is casting
INSERT INTO `merc_spell_list_entries`
	(`merc_spell_list_id`,`spell_id`,`spell_type`,`stance_id`,`minlevel`,`maxlevel`,`slot`,`procChance`)
VALUES
	(11, 3481, 16384, 0, 61, 65, 1, 0),   -- Tarnation
	(11, 5254, 16384, 0, 66, 70, 1, 0),   -- Shock of Wonder
	(11, 9717, 16384, 0, 71, 75, 1, 0),   -- Awestruck Rk. III
	(11, 14221, 16384, 0, 76, 80, 1, 0),  -- Aweshock Rk. III
	(11, 18242, 16384, 0, 81, 255, 1, 0), -- Aweshake Rk. III
	(12, 3481, 16384, 0, 61, 65, 1, 0),
	(12, 5254, 16384, 0, 66, 70, 1, 0),
	(12, 9717, 16384, 0, 71, 75, 1, 0),
	(12, 14221, 16384, 0, 76, 80, 1, 0),
	(12, 18242, 16384, 0, 81, 255, 1, 0);

-- Upsert, not bare UPDATE: the row may not exist yet (see versions 30-32 lesson in the manifest)
INSERT INTO `rule_values` (`ruleset_id`,`rule_name`,`rule_value`,`notes`)
VALUES (1, 'Custom:MercBotBrain', 'true', 'Master/Legendary mercs use the bot-grade brain (priority dispatch, Concussive hate drop, root fleeing targets, stun-rider nukes, healer interrupts). Tier lists need the v296 spell rows.')
ON DUPLICATE KEY UPDATE `rule_value` = VALUES(`rule_value`);

SELECT 'merc_spell_list_entries v296' AS section, `merc_spell_list_id`, COUNT(*) AS rows_now
FROM `merc_spell_list_entries`
WHERE `merc_spell_list_id` IN (11, 12, 15, 16)
GROUP BY `merc_spell_list_id`;
