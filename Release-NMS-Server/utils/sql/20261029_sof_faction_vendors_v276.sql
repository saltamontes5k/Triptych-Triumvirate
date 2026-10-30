-- v276: Secrets of Faydwer faction vendor stocks (Rasper factAkanon/Bertox/Valor/CoVeeshan/Fang/LoLight/Brownie).
-- faction_required convention per existing stocks: 500 = Kindly, 1100 = Ally (see Karri 438007).

-- Sydria the Elder (442032), elite Crusaders of Veeshan supplier in Dragonscale Hills:
-- repoint merchant_id (was 999999, a mismatched SoD scroll list) and stock the CoV Rk. III set + 10 shield ornaments.
UPDATE npc_types SET merchant_id = 442032 WHERE id = 442032;
DELETE FROM merchantlist WHERE merchantid = 442032;
INSERT INTO merchantlist (merchantid, slot, item, faction_required) VALUES
(442032, 1, 116084, 1100),
(442032, 2, 116510, 1100),
(442032, 3, 116325, 1100),
(442032, 4, 115733, 1100),
(442032, 5, 115935, 1100),
(442032, 6, 116010, 1100),
(442032, 7, 115089, 1100),
(442032, 8, 115780, 1100),
(442032, 9, 115601, 1100),
(442032, 10, 115251, 1100),
(442032, 11, 116436, 1100),
(442032, 12, 116216, 1100),
(442032, 13, 115402, 1100),
(442032, 14, 116135, 1100),
(442032, 15, 100112, 1100),
(442032, 16, 100113, 1100),
(442032, 17, 100114, 1100),
(442032, 18, 100115, 1100),
(442032, 19, 100116, 1100),
(442032, 20, 100117, 1100),
(442032, 21, 100118, 1100),
(442032, 22, 100119, 1100),
(442032, 23, 100120, 1100),
(442032, 24, 100121, 1100);

-- Lanika Shadestepper (444002), standard Bertoxxulous' Chosen supplier in Hills of Shade:
-- add the four Ally-tier rewards the Rasper listing names that were missing from her stock.
INSERT INTO merchantlist (merchantid, slot, item, faction_required) VALUES
(444002, 8, 115931, 1100),
(444002, 9, 116492, 1100),
(444002, 10, 100100, 1100),
(444002, 11, 102765, 1100);

-- Seridyn (442104), standard Ladies of the Light supplier in Dragonscale Hills:
-- her stock was the generic level 76-80 SoF scroll set; replace with the faction reward list.
DELETE FROM merchantlist WHERE merchantid = 442104;
INSERT INTO merchantlist (merchantid, slot, item, faction_required) VALUES
(442104, 1, 115338, 500),
(442104, 2, 116501, 500),
(442104, 3, 115737, 500),
(442104, 4, 115911, 500),
(442104, 5, 115452, 500),
(442104, 6, 116478, 500),
(442104, 7, 115082, 1100),
(442104, 8, 115621, 1100),
(442104, 9, 116048, 1100),
(442104, 10, 115753, 1100),
(442104, 11, 115955, 1100),
(442104, 12, 116337, 1100),
(442104, 13, 115797, 1100),
(442104, 14, 100102, 1100);

-- Alissa Saint Claire (442103), elite Ladies of the Light supplier:
-- stock the Rk. III versions of the faction reward line.
DELETE FROM merchantlist WHERE merchantid = 442103;
INSERT INTO merchantlist (merchantid, slot, item, faction_required) VALUES
(442103, 1, 115339, 1100),
(442103, 2, 116502, 1100),
(442103, 3, 115912, 1100),
(442103, 4, 115453, 1100),
(442103, 5, 116479, 1100),
(442103, 6, 115083, 1100),
(442103, 7, 115622, 1100),
(442103, 8, 116049, 1100),
(442103, 9, 115956, 1100),
(442103, 10, 116338, 1100),
(442103, 11, 115798, 1100);
