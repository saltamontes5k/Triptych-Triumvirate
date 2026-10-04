-- ============================================================================
-- 2026-10-04 Door destination-instance fixes
--
-- Some doors point their destination at instance 1 of a zone that has no
-- instances at all. When a player uses such a door, doors.cpp calls MovePC with
-- that instance id, zoning.cpp rejects it (VerifyInstanceAlive fails), and the
-- zone is cancelled -- the client reloads the zone it is already in and shows
-- the stock "There is no escape from purgatory!" message. Gate/Origin still
-- work because spells do not go through the door.
--
-- 1) guildhall -> guildlobby (Guild Hall exit doors)
--    dest_instance = 1, but guildlobby (344) is static with no instance_list
--    rows. v0/v1/v100 rows: id 36666 / 36667 / 152052.
--    The sibling Guild Hall doors (id 11962 v0, 144530 v100) already use 0.
--
-- 2) corathus -> nektulos (POKTELE500 teleporter, doorid 112)
--    dest_instance = 1, but nektulos (25) is static with no instance_list rows.
--    v0/v100 rows: id 17152 / 146247.
--    The sibling corathus POKTELE500 door (id 13017 v1) already uses 0.
--
-- Idempotent.
-- ============================================================================

UPDATE doors
SET dest_instance = 0
WHERE zone = 'guildhall'
  AND dest_zone = 'guildlobby'
  AND dest_instance <> 0;

UPDATE doors
SET dest_instance = 0
WHERE zone = 'corathus'
  AND dest_zone = 'nektulos'
  AND dest_instance <> 0;
