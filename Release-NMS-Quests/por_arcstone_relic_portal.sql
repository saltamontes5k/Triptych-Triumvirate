-- Prophecy of Ro - Arcstone <-> Relic portal activation
--
-- Stock PEQ ships the two Arcstone "OBJ_ARCPORTAL" doors (doorids 6 and 7, the
-- platforms next to Or`Sarro the Youngest / Spirit of Ao the Fourth Born) with
-- dest_zone 'NONE', and no zone_points row in arcstone that targets relic (370).
-- The only server-side way into Relic was therefore the zoneline out of the
-- Skylance expedition. This restores the walk-in zoneline and the clickable
-- portals, so the Relic content (Borso, Arena Overseer, the twelve scrykin orbs
-- for task 3024 "Black Orb of the Scrykin") is reachable directly.
--
-- Landing spot is Relic's own safe/zone-in point at the Arcstone portal:
--   client map relic_1.txt : to_Arcstone,_Isle_of_Spirits (game 843, 618, -275)
--   zone safe point        : 861, 618, -265 (used here)
-- The Arcstone side source coords mirror the two portal doors.
-- Idempotent.

-- --- walk-in zonelines: arcstone -> relic --------------------------------------
DELETE FROM `zone_points` WHERE `zone` = 'arcstone' AND `target_zone_id` = 370;
INSERT INTO `zone_points`
 (`zone`,`version`,`number`,`y`,`x`,`z`,`heading`,`target_y`,`target_x`,`target_z`,`target_heading`,
  `zoneinst`,`target_zone_id`,`target_instance`,`buffer`,`client_version_mask`,`min_expansion`,`max_expansion`)
VALUES
 ('arcstone',0,10, 240.75, -957.25, 405.75, 45,  618.0, 861.0, -265.0, 0, 0, 370, 0, 0, 4294967295, -1, -1),
 ('arcstone',0,20, 171.75, -1019.0, 407.00, 295, 618.0, 861.0, -265.0, 0, 0, 370, 0, 0, 4294967295, -1, -1),
 ('arcstone',100,10, 240.75, -957.25, 405.75, 45,  618.0, 861.0, -265.0, 0, 0, 370, 0, 0, 4294967295, -1, -1),
 ('arcstone',100,20, 171.75, -1019.0, 407.00, 295, 618.0, 861.0, -265.0, 0, 0, 370, 0, 0, 4294967295, -1, -1);

-- --- clickable OBJ_ARCPORTAL doors (6 and 7) -----------------------------------
UPDATE `doors`
 SET `dest_zone` = 'relic', `dest_x` = 861, `dest_y` = 618, `dest_z` = -265, `dest_heading` = 0
 WHERE `zone` = 'arcstone' AND `doorid` IN (6, 7);
