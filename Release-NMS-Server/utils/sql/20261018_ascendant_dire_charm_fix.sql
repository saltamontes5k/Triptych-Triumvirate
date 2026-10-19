-- Ascendant Dire Charm (AA 31084/31085/31086) was casting pet illusions:
--   41500 -> 28620 Pet Illusion: Magma Dervish
--   41501 -> 27244 Pet Illusion: Telmira
--   41502 -> 26877 Pet Illusion: Pyrlien
-- Those spells are the Petamorph Wand click effects (items 907230/907295/907293),
-- so they stay untouched. The AA ranks now cast real charms:
--   41500 -> 43990 Dire Charm (level 66, enchanter)
--   41501 -> 2760  Dire Charm (Animal)
--   41502 -> 2759  Dire Charm (Undead)
-- and 54016/960/961 descriptions are rewritten to match.
--
-- Twin of manifest entry 169.

UPDATE `aa_ranks` SET `spell`=43990 WHERE `id`=41500;
UPDATE `aa_ranks` SET `spell`=2760  WHERE `id`=41501;
UPDATE `aa_ranks` SET `spell`=2759  WHERE `id`=41502;

INSERT INTO `db_str` (`id`,`type`,`value`) VALUES
  (54016, 4, 'Permanently charms a single NPC up to level 66. The charm is unresistable, lasts until it breaks, the target dies, or you zone, and cannot be used while an animation is active. 4 minute 20 second reuse. /alt activate 31084'),
  (960, 4, 'Permanently charms a single animal that is level 46 or below, or that cons light blue or lower to you. The charm is unresistable, lasts until it breaks, the target dies, or you zone, and cannot be used while another druid pet is active. /alt activate 31085'),
  (961, 4, 'Permanently charms a single undead that is level 46 or below, or that cons light blue or lower to you. The charm is unresistable, lasts until it breaks, the target dies, or you zone, and cannot be used while another necromancer pet is active. /alt activate 31086')
ON DUPLICATE KEY UPDATE `value`=VALUES(`value`);
