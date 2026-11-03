-- Vex Thal keyring reset (2026-11-03). Live test showed a character with no quest key
-- clicking into vexthal: they held keyring 22198 from the old PoP-completion auto-grant
-- hooks (removed the same day, v313's companion change), and the door's key check honors
-- the keyring. Grandfather decision reversed: strip ALL keyring 22198 rows so the scepter
-- quest chain (verified fully live) is the only path to the key. Holders stripped:
-- Drazhek, Zexxus, Trogdor, Betty (any legitimate holder can be restored with
-- #keyringadd or by redoing the chain). Twin of manifest entry 314.
SET NAMES utf8mb4;
DELETE FROM `keyring` WHERE `item_id` = 22198;
