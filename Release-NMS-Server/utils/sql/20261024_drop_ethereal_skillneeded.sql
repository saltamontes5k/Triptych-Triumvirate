-- 2026-10-24 Drop the hard 220 skill requirement from the five Ethereal sub-combines
-- Ethereal Sheet of Metal (4327), Ethereal Temper (7656), Ethereal Metal Rings (4326),
-- Ethereal Silk Swatch (2587) and Ethereal Curing Agent (7655) are all trivial 212 but
-- carried skillneeded = 220, which hard-blocks the combine below 220 skill with
-- "You are not skilled enough." Setting skillneeded = 0 allows any skill to attempt them.
-- Rollback: UPDATE tradeskill_recipe SET skillneeded = 220
--           WHERE id IN (2587, 4326, 4327, 7655, 7656);

UPDATE `tradeskill_recipe`
SET `skillneeded` = 0
WHERE `id` IN (2587, 4326, 4327, 7655, 7656);
