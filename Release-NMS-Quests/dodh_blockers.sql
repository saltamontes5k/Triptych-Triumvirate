-- Depths of Darkhollow - Demi-Plane of Blood curse blockers
--
-- Wires the four "Aura of Crimson Mists" blocker items onto the existing
-- Demi-Plane named (lootdrops 900401-900404), so the Dreadspire blocker
-- turn-ins (Ur-Koraag, Arturos, Ariahn Teller, Irrissa the Seer) are obtainable:
--
--   52523 Rune-Etched Stone             <- Zi-Thuuli of the Granite Claw (loottable 900401)
--   52522 Congealed Blood of Redfang    <- Sanguimanus the Redfang        (loottable 900403)
--   52524 Shrunken Head                 <- Hatchet the Torturer           (loottable 900402)
--   52525 Sister's Handkerchief         <- The Wailing Sisters            (loottable 900404)
--
-- Idempotent; collision-free ids (910203-910206).

-- helper to (re)create a 100% single-item lootdrop
DELETE FROM `loottable_entries` WHERE `lootdrop_id` BETWEEN 910203 AND 910206;
DELETE FROM `lootdrop_entries` WHERE `lootdrop_id` BETWEEN 910203 AND 910206;
DELETE FROM `lootdrop` WHERE `id` BETWEEN 910203 AND 910206;

INSERT INTO `lootdrop` (`id`,`name`,`min_expansion`,`max_expansion`) VALUES
 (910203,'dodh_blocker_rune_etched_stone',-1,-1),
 (910204,'dodh_blocker_congealed_blood',-1,-1),
 (910205,'dodh_blocker_shrunken_head',-1,-1),
 (910206,'dodh_blocker_sisters_handkerchief',-1,-1);

INSERT INTO `lootdrop_entries`
 (`lootdrop_id`,`item_id`,`item_charges`,`equip_item`,`chance`,`disabled_chance`,`trivial_min_level`,`trivial_max_level`,`multiplier`,`npc_min_level`,`npc_max_level`,`min_expansion`,`max_expansion`)
VALUES
 (910203,52523,1,0,100,0,0,0,1,0,0,-1,-1),
 (910204,52522,1,0,100,0,0,0,1,0,0,-1,-1),
 (910205,52524,1,0,100,0,0,0,1,0,0,-1,-1),
 (910206,52525,1,0,100,0,0,0,1,0,0,-1,-1);

INSERT INTO `loottable_entries` (`loottable_id`,`lootdrop_id`,`multiplier`,`droplimit`,`mindrop`,`probability`) VALUES
 (900401,910203,1,0,0,100), -- Zi-Thuuli  -> Rune-Etched Stone
 (900403,910204,1,0,0,100), -- Sanguimanus -> Congealed Blood of Redfang
 (900402,910205,1,0,0,100), -- Hatchet    -> Shrunken Head
 (900404,910206,1,0,0,100); -- Wailing Sisters -> Sister's Handkerchief
