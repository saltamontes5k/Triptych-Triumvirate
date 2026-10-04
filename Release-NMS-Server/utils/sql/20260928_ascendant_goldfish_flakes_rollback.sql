-- Rollback for 20260928_ascendant_goldfish_flakes.sql
DELETE FROM loottable_entries WHERE lootdrop_id = 1520008200;
DELETE FROM lootdrop_entries WHERE lootdrop_id = 1520008200;
DELETE FROM lootdrop WHERE id = 1520008200;
DELETE FROM fishing WHERE Itemid = 121858;
DELETE FROM items WHERE id = 121858;
