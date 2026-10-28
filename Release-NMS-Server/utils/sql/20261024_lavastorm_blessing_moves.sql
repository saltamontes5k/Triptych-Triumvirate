-- 2026-10-24 Lavastorm: move Togg Purk + the three blessing Dopplegangers out of geometry
-- Blessing task 700190 encounter (Rallos Zek tree): Togg_Purk 344226 and
-- a_Doppleganger 344292 / a_Fierce_Doppleganger 344293 / a_Raging_Doppleganger 344294
-- all spawned in unreachable terrain around (680-740, 30-90, -88).
-- Moved to the open spot at (473, 75, 6): Togg on the anchor, doppelgangers fanned
-- ~10 units out, each facing Togg. No pathgrids, no condition gating.
-- Rollback: restore x/y/z/heading from the per-row comments below.

UPDATE `spawn2` SET `x` = 473, `y` = 75, `z` = 6, `heading` = 0   WHERE `id` = 3390223 AND `zone` = 'lavastorm'; -- Togg_Purk was 680, 30, -88, h 0
UPDATE `spawn2` SET `x` = 483, `y` = 69, `z` = 6, `heading` = 214 WHERE `id` = 3390310 AND `zone` = 'lavastorm'; -- a_Doppleganger was 700, 50, -88, h 0
UPDATE `spawn2` SET `x` = 485, `y` = 83, `z` = 6, `heading` = 168 WHERE `id` = 3390311 AND `zone` = 'lavastorm'; -- a_Fierce_Doppleganger was 720, 70, -88, h 0
UPDATE `spawn2` SET `x` = 463, `y` = 71, `z` = 6, `heading` = 48  WHERE `id` = 3390312 AND `zone` = 'lavastorm'; -- a_Raging_Doppleganger was 740, 90, -88, h 0
