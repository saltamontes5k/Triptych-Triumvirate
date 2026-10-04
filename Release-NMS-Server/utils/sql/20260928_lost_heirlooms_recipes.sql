-- Lost Heirlooms / Silverwing Charm - Aiden Silverwing (Plane of Knowledge).
--
-- Adds the ten tradeskill combines performed inside the Silverwing Lockbox
-- (item 17335, bagtype 30 = BagTypeAlwaysWorks -> never-fail quest container).
--
-- The nine tier combines are quest recipes (quest=1) with a null success
-- placeholder (item_id 0), matching the existing quest-combine convention
-- (e.g. recipes 10334/10346/10903): the tradeskill engine grants nothing, and
-- global/global_player.pl's EVENT_COMBINE_SUCCESS hands the player the
-- class-appropriate trinket (melee/hybrid vs. priest/caster). The two final
-- combines are ordinary no-fail recipes that yield the Crest directly.
--
-- Paired by the live quest: each family trinket combines with the shard whose
-- property it takes on.
--
--   tier 1  Silverwing Loop         (79621) + Glinting Shard      (81110)
--   tier 2  Silverwing Circlet      (79623) + Radiant Shard       (81111)
--   tier 3  Silverwing Choker       (79627) + Fiery Shard         (81112)
--   tier 4  Silverwing Emblem       (79631) + Gleaming Shard      (81113)
--   tier 5  Silverwing Shoulderpads (79635) + Shimmering Shard    (81114)
--   tier 6  Silverwing Cloak        (79639) + Pearlescent Shard   (81115)
--   tier 7  Silverwing Faceguard    (79643) + Polished Shard      (81116)
--   tier 8  Silverwing Belt         (79647) + Scintillating Shard (81117)
--   tier 9  Silverwing Band         (79651) + Glowing Shard       (81118)
--   final   the nine results (melee or caster) + Hoop             -> Crest

INSERT INTO `tradeskill_recipe`
    (`id`,`name`,`tradeskill`,`skillneeded`,`trivial`,`nofail`,`replace_container`,`must_learn`,`learned_by_item_id`,`quest`,`enabled`,`min_expansion`,`max_expansion`)
VALUES
    (993001,'Silverwing Loop Refinement',69,0,0,1,0,0,0,1,1,-1,-1),
    (993002,'Silverwing Circlet Refinement',69,0,0,1,0,0,0,1,1,-1,-1),
    (993003,'Silverwing Choker Refinement',69,0,0,1,0,0,0,1,1,-1,-1),
    (993004,'Silverwing Emblem Refinement',69,0,0,1,0,0,0,1,1,-1,-1),
    (993005,'Silverwing Shoulderpads Refinement',69,0,0,1,0,0,0,1,1,-1,-1),
    (993006,'Silverwing Cloak Refinement',69,0,0,1,0,0,0,1,1,-1,-1),
    (993007,'Silverwing Faceguard Refinement',69,0,0,1,0,0,0,1,1,-1,-1),
    (993008,'Silverwing Belt Refinement',69,0,0,1,0,0,0,1,1,-1,-1),
    (993009,'Silverwing Band Refinement',69,0,0,1,0,0,0,1,1,-1,-1),
    (993010,'Auroral Crest of the Silverwing',69,0,0,1,0,0,0,0,1,-1,-1),
    (993011,'Luminescent Crest of the Silverwing',69,0,0,1,0,0,0,0,1,-1,-1);

INSERT INTO `tradeskill_recipe_entries`
    (`recipe_id`,`item_id`,`successcount`,`failcount`,`componentcount`,`salvagecount`,`iscontainer`)
VALUES
    -- tier 1: Silverwing Loop + Glinting Shard (result: 79624 melee / 79625 caster)
    (993001,17335,0,0,0,0,1),
    (993001,79621,0,0,1,0,0),
    (993001,81110,0,0,1,0,0),
    (993001,0,1,0,0,0,0),
    -- tier 2: Silverwing Circlet + Radiant Shard (79628 / 79629)
    (993002,17335,0,0,0,0,1),
    (993002,79623,0,0,1,0,0),
    (993002,81111,0,0,1,0,0),
    (993002,0,1,0,0,0,0),
    -- tier 3: Silverwing Choker + Fiery Shard (79632 / 79633)
    (993003,17335,0,0,0,0,1),
    (993003,79627,0,0,1,0,0),
    (993003,81112,0,0,1,0,0),
    (993003,0,1,0,0,0,0),
    -- tier 4: Silverwing Emblem + Gleaming Shard (79636 / 79637)
    (993004,17335,0,0,0,0,1),
    (993004,79631,0,0,1,0,0),
    (993004,81113,0,0,1,0,0),
    (993004,0,1,0,0,0,0),
    -- tier 5: Silverwing Shoulderpads + Shimmering Shard (79640 / 79641)
    (993005,17335,0,0,0,0,1),
    (993005,79635,0,0,1,0,0),
    (993005,81114,0,0,1,0,0),
    (993005,0,1,0,0,0,0),
    -- tier 6: Silverwing Cloak + Pearlescent Shard (79644 / 79645)
    (993006,17335,0,0,0,0,1),
    (993006,79639,0,0,1,0,0),
    (993006,81115,0,0,1,0,0),
    (993006,0,1,0,0,0,0),
    -- tier 7: Silverwing Faceguard + Polished Shard (79648 / 79649)
    (993007,17335,0,0,0,0,1),
    (993007,79643,0,0,1,0,0),
    (993007,81116,0,0,1,0,0),
    (993007,0,1,0,0,0,0),
    -- tier 8: Silverwing Belt + Scintillating Shard (79652 / 79653)
    (993008,17335,0,0,0,0,1),
    (993008,79647,0,0,1,0,0),
    (993008,81117,0,0,1,0,0),
    (993008,0,1,0,0,0,0),
    -- tier 9: Silverwing Band + Glowing Shard (79655 / 79656)
    (993009,17335,0,0,0,0,1),
    (993009,79651,0,0,1,0,0),
    (993009,81118,0,0,1,0,0),
    (993009,0,1,0,0,0,0),
    -- final (melee): the nine melee trinkets + Gleaming Hoop -> Auroral Crest (79660)
    (993010,17335,0,0,0,0,1),
    (993010,79624,0,0,1,0,0),
    (993010,79628,0,0,1,0,0),
    (993010,79632,0,0,1,0,0),
    (993010,79636,0,0,1,0,0),
    (993010,79640,0,0,1,0,0),
    (993010,79644,0,0,1,0,0),
    (993010,79648,0,0,1,0,0),
    (993010,79652,0,0,1,0,0),
    (993010,79655,0,0,1,0,0),
    (993010,79657,0,0,1,0,0),
    (993010,79660,1,0,0,0,0),
    -- final (caster): the nine caster trinkets + Glowing Hoop -> Luminescent Crest (79661)
    (993011,17335,0,0,0,0,1),
    (993011,79625,0,0,1,0,0),
    (993011,79629,0,0,1,0,0),
    (993011,79633,0,0,1,0,0),
    (993011,79637,0,0,1,0,0),
    (993011,79641,0,0,1,0,0),
    (993011,79645,0,0,1,0,0),
    (993011,79649,0,0,1,0,0),
    (993011,79653,0,0,1,0,0),
    (993011,79656,0,0,1,0,0),
    (993011,79658,0,0,1,0,0),
    (993011,79661,1,0,0,0,0);
