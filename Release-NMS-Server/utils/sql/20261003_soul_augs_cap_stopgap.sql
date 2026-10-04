-- ============================================================================
-- Soul Augs stopgap -- extend top drop band to the level cap (85)
-- Date: 2026-10-03
--
-- The Lost/Restless/Found Soul aug system (items 160000-160749, generated
-- by utils/Release-NMS-Server/utils/scripts/generators/aug_generator) was
-- built against a level-65 cap: its highest tier is reclevel 65 and its
-- top global-loot band only matched NPC levels 61-65. The live server cap
-- is now 85 (rule_values Character:MaxLevel), so mobs 66+ could never drop
-- soul augs and capped characters had no aug source.
--
-- Stopgap (no new items): extend the top band, global_loot id 178706
-- (GLB-Soul-Augs -> loottable Soul_Augs_61-65, all 118 tier-65 augs,
-- ~1% per kill), from max_level 65 to 85. Mobs 61-85 all roll the tier-65
-- aug pool; bands 178700-178705 (1-60) are untouched.
--
-- Real fix, not shipped here: generator tiers 70/75/80/85 with new items
-- and per-band drop pools.
--
-- Idempotent: single-row UPDATE.
-- Twin of ManifestEntry .version = 98 in
-- common/database/database_update_manifest_custom.cpp
-- ============================================================================

UPDATE `global_loot`
SET `max_level` = 85
WHERE `id` = 178706;
