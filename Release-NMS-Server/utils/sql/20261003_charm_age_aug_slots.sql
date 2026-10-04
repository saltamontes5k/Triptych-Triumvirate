-- ============================================================================
-- Charm of the Ages -- normalize aug slots to the server standard
-- Date: 2026-10-03
--
-- The Champions of Classic/Kunark/Luclin/PoP reward charms (items 121850-
-- 121854, Charm of the First..Fifth Age) shipped with their stock SoF
-- charm-aug layout: augtype 64 (type-7 augs only), zero aug slots on
-- First/Second Age, one type-7 slot on Third/Fourth Age, type-7/8 on
-- Fifth Age. Nothing else on the server produces types 7/8, so standard
-- server augs never fit these charms.
--
-- Normalizes all five to the server-wide layout (augslot1type = 1,
-- augslot2type = 2, augslot6type = 21 with visible flags on, augtype and
-- augdistiller cleared) -- the same configuration ~75k existing items
-- carry (e.g. Cloth Cap, id 1001). Type 21 is the server's universal
-- aug slot; 5.7k type-1, 21k type-2 and 25k type-21 augs exist.
--
-- Idempotent: pure UPDATE on the five charm ids.
-- Twin of ManifestEntry .version = 97 in
-- common/database/database_update_manifest_custom.cpp
-- ============================================================================

UPDATE `items`
SET `augtype`      = 0,
    `augdistiller` = 0,
    `augslot1type` = 1, `augslot1visible` = 1,
    `augslot2type` = 2, `augslot2visible` = 1,
    `augslot3type` = 0, `augslot3visible` = 0,
    `augslot4type` = 0, `augslot4visible` = 0,
    `augslot5type` = 0, `augslot5visible` = 0,
    `augslot6type` = 21, `augslot6visible` = 1
WHERE `id` IN (121850, 121851, 121852, 121853, 121854);
