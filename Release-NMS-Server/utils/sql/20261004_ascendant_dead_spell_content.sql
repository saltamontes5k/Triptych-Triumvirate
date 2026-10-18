-- Build the missing content for two broken custom AA line families (2026-10-04)
--
-- A) Crystalize Essence (aa_ability 31076-31081, ranks 40001-40006) pointed at
--    spells 26717-26722 that never existed. Each class line summons a
--    consumable essence item; using the item casts the existing class spell:
--      31076 DRU Chloroplast(145)      -> item 121870 via spell 26717
--      31077 SHM Inner Fire(267)       -> item 121871 via spell 26718
--      31078 ENC Clarity(174)          -> item 121872 via spell 26719
--      31079 MAG Shield of Blades(1560)-> item 121873 via spell 26720
--      31080 NEC Dead Man Floating(457)-> item 121874 via spell 26721
--      31081 RNG Strength of Nature(1397) -> item 121875 via spell 26722
--    The AA ranks already carry a 21600s (6h) reuse; the spells themselves are
--    plain summons (SE_SummonItem = SPA 32, self-targeted, 4s cast).
--
-- B) Companion's Veil (aa_ability 31100, ranks 41510-41512) pointed at spells
--    25550-25552 that never existed. Modeled on Veil of Mindshadow (spell 11083:
--    SE_MitigateMeleeDamage 80, formula 3 / 360): a pet-targeted (targettype 14,
--    same as the Burnout pet buffs) melee-mitigation veil, escalating 30/50/80
--    across the three ranks, same 360-tick duration. Rank reuse 6s is already
--    set on the ranks.
--
-- C) db_str fixes: the type-4 descriptions for 40001-40006 and 41510 were stored
--    truncated mid-word ("...that can be us", "...lowering th"); rewritten whole.
--
-- Requires a zone restart (or #hotfix spells) to load spells_new.
-- Idempotent (INSERT ... ON DUPLICATE KEY / DELETE+INSERT for db_str).
-- Rollback: delete items 121870-121875, spells 26717-26722 / 25550-25552;
--           restore db_str rows quoted here if previously non-truncated.
SET NAMES utf8mb4;

-- ---------------------------------------------------------------------------
-- A1. Essence items (consumable clickies, 1 charge, lore, no-trade)
-- ---------------------------------------------------------------------------
INSERT INTO items (id, Name, itemtype, classes, races, deity, price, clicktype,
                   clicklevel, clickeffect, casttime_, recastdelay, maxcharges,
                   lore, nodrop, norent, book, icon)
VALUES
 (121870,'Crystallized Essence of Chloroplast',17,65535,65535,0,1000,4,0,145,4000,30,1,
  'A sliver of crystallized druidic power. Faint wisps of living green curl within.',1,0,0,0),
 (121871,'Crystallized Essence of Focus',17,65535,65535,0,1000,4,0,267,4000,30,1,
  'A sliver of crystallized spiritual fury. It thrums with inner heat.',1,0,0,0),
 (121872,'Crystallized Essence of Clarity',17,65535,65535,0,1000,4,0,174,4000,30,1,
  'A sliver of crystallized thought. Gazing into it stills the mind.',1,0,0,0),
 (121873,'Crystallized Essence of Damage Shield',17,65535,65535,0,1000,4,0,1560,4000,30,1,
  'A sliver of crystallized elemental wrath. Its edges bite like blades.',1,0,0,0),
 (121874,'Crystallized Essence of Dead Man Floating',17,65535,65535,0,1000,4,0,457,4000,30,1,
  'A sliver of crystallized necromancy. It refuses to sink.',1,0,0,0),
 (121875,'Crystallized Essence of Strength of Nature',17,65535,65535,0,1000,4,0,1397,4000,30,1,
  'A sliver of crystallized wildgrowth. It is warm, like a living thing.',1,0,0,0)
ON DUPLICATE KEY UPDATE Name=VALUES(Name), clickeffect=VALUES(clickeffect),
  clicktype=VALUES(clicktype), casttime_=VALUES(casttime_), recastdelay=VALUES(recastdelay),
  maxcharges=VALUES(maxcharges), lore=VALUES(lore), nodrop=VALUES(nodrop);

-- ---------------------------------------------------------------------------
-- A2. Summon spells (SE_SummonItem -> the essence above)
-- ---------------------------------------------------------------------------
INSERT INTO spells_new (id, name, player_1, effectid1, effect_base_value1,
                        targettype, cast_time, buffdurationformula, buffduration,
                        teleport_zone, goodEffect, ResistDiff, mana, can_mgb, reflectable)
VALUES
 (26717,'Crystalize Essence: Chloroplast','PLAYER_1',32,121870,6,4000,0,0,'',1,0,0,0,0),
 (26718,'Crystalize Essence: Focus','PLAYER_1',32,121871,6,4000,0,0,'',1,0,0,0,0),
 (26719,'Crystalize Essence: Clarity','PLAYER_1',32,121872,6,4000,0,0,'',1,0,0,0,0),
 (26720,'Crystalize Essence: Damage Shield','PLAYER_1',32,121873,6,4000,0,0,'',1,0,0,0,0),
 (26721,'Crystalize Essence: Dead Man Floating','PLAYER_1',32,121874,6,4000,0,0,'',1,0,0,0,0),
 (26722,'Crystalize Essence: Strength of Nature','PLAYER_1',32,121875,6,4000,0,0,'',1,0,0,0,0)
ON DUPLICATE KEY UPDATE name=VALUES(name), effectid1=32,
  effect_base_value1=VALUES(effect_base_value1), targettype=6, cast_time=4000;

UPDATE spells_new
SET effectid2=254, effectid3=254, effectid4=254, effectid5=254, effectid6=254,
    effectid7=254, effectid8=254, effectid9=254, effectid10=254, effectid11=254, effectid12=254
WHERE id BETWEEN 26717 AND 26722;

-- ---------------------------------------------------------------------------
-- B. Companion's Veil spells (pet-targeted melee-mitigation veil)
-- ---------------------------------------------------------------------------
INSERT INTO spells_new (id, name, player_1, effectid1, effect_base_value1,
                        targettype, cast_time, buffdurationformula, buffduration,
                        teleport_zone, goodEffect, ResistDiff, mana, can_mgb, reflectable)
VALUES
 (25550,'Companion''s Veil','PLAYER_1',162,30,14,2000,3,360,'',1,0,0,0,0),
 (25551,'Companion''s Veil','PLAYER_1',162,50,14,2000,3,360,'',1,0,0,0,0),
 (25552,'Companion''s Veil','PLAYER_1',162,80,14,2000,3,360,'',1,0,0,0,0)
ON DUPLICATE KEY UPDATE name=VALUES(name), effectid1=162,
  effect_base_value1=VALUES(effect_base_value1), targettype=14,
  buffdurationformula=3, buffduration=360;

UPDATE spells_new
SET effectid2=254, effectid3=254, effectid4=254, effectid5=254, effectid6=254,
    effectid7=254, effectid8=254, effectid9=254, effectid10=254, effectid11=254, effectid12=254
WHERE id BETWEEN 25550 AND 25552;

-- ---------------------------------------------------------------------------
-- C. Repair truncated db_str descriptions
-- ---------------------------------------------------------------------------
DELETE FROM db_str WHERE id IN (40001,40002,40003,40004,40005,40006,41510) AND type = 4;
INSERT INTO db_str (id, type, value) VALUES
 (40001,4,'Crystallize your power into a tangible object: a Crystallized Essence of Chloroplast that can be used once to evoke Chloroplast.'),
 (40002,4,'Crystallize your power into a tangible object: a Crystallized Essence of Focus that can be used once to evoke Inner Fire.'),
 (40003,4,'Crystallize your power into a tangible object: a Crystallized Essence of Clarity that can be used once to evoke Clarity.'),
 (40004,4,'Crystallize your power into a tangible object: a Crystallized Essence of Damage Shield that can be used once to evoke Shield of Blades.'),
 (40005,4,'Crystallize your power into a tangible object: a Crystallized Essence of Dead Man Floating that can be used once to evoke Dead Man Floating.'),
 (40006,4,'Crystallize your power into a tangible object: a Crystallized Essence of Strength of Nature that can be used once to evoke Strength of Nature.'),
 (41510,4,'Creates a veil between your pet and its enemies, lowering the melee damage they deal to it. The veil grows stronger with each rank.');
