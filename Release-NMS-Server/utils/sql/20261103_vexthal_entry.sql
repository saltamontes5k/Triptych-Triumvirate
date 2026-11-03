-- Vex Thal entry gating (2026-11-03). The VT portal in Umbral Plains is a keyed teleport
-- door (doors 8917/142339, keyitem 22198 = The Scepter of Shadows; full PEQ key chain is
-- live: Lucid Shards -> Shadowed Scepter Frame -> Unadorned -> Scepter, recipes 10040/10014).
-- A co-located unkeyed zone_point (umbral point 45, versions 0/100) let any player walk onto
-- the pad and zone straight into vexthal: zone_points has no key column and zone-in
-- validation is proximity-only, so the keyed door was bypassed entirely. Delete the walk-in
-- triggers; the door (plus the SoL progression atlas gate in global_player.pl) is the only
-- entry left. Verified live 2026-11-03: no other zone_points target vexthal, no quest
-- scripts reference these rows, keyring holders keep access. Twin of manifest entry 312.
SET NAMES utf8mb4;
DELETE FROM `zone_points`
WHERE `zone` = 'umbral'
  AND `number` = 45
  AND `target_zone_id` = 158
  AND `target_instance` = 0;
