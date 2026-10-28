-- 2026-10-28 Karanite/Quellious clicky activation fix (migration v258).
-- The two PoK blessing-rod clickies were authored with clicktype = 0, a value
-- no other clickable in the DB uses (25,659 clickables live at types 1/3/4/5).
-- The RoF2 client cannot resolve activation type 0 and renders the item as
-- "Unknown Activation" while swallowing the click server-side never sees.
-- clicktype 5 is the standard activated-item type (instant here; casttime 0).
-- Rollback: UPDATE items SET clicktype = 0 WHERE id IN (976211, 976213);
UPDATE `items` SET `clicktype` = 5 WHERE `id` IN (976211, 976213) AND `clicktype` = 0;

-- verification
SELECT id, name, clicktype FROM items WHERE id IN (976211, 976213);
