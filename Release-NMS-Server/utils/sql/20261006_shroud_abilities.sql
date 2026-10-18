-- 120: Shroud ability catalog (Custom:ShroudLiveMode auto-assign).
-- Twin of the manifest v120 entry (common/database/database_update_manifest_custom.cpp).
-- Maps shroud progressions + form levels to shroud-category AA ids (90100+
-- band); ApplyShroud auto-grants matching rows as owned ranks and records
-- them in character_shroud_aa for zone-in re-apply.

CREATE TABLE IF NOT EXISTS `shroud_abilities` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `progression` varchar(64) NOT NULL,
  `min_level` smallint(5) unsigned NOT NULL DEFAULT 1,
  `kind` enum('active','passive') NOT NULL DEFAULT 'passive',
  `aa_id` int(10) unsigned NOT NULL,
  `display_order` int(11) NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_prog_lvl_aa` (`progression`,`min_level`,`aa_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

DELETE FROM `shroud_abilities`;

INSERT INTO `shroud_abilities` (`progression`,`min_level`,`kind`,`aa_id`,`display_order`) VALUES
('Aberrations',1,'passive',90100,1),('Aberrations',1,'active',90101,2),
('Animals',1,'passive',90100,1),('Animals',1,'active',90101,2),
('Elementals',1,'passive',90100,1),('Elementals',1,'active',90101,2),
('Goblinoid',1,'passive',90100,1),('Goblinoid',1,'active',90101,2),
('Humanoid',1,'passive',90100,1),('Humanoid',1,'active',90101,2),
('Nature Spirits',1,'passive',90100,1),('Nature Spirits',1,'active',90101,2),
('Reptiles',1,'passive',90100,1),('Reptiles',1,'active',90101,2),
('Undead',1,'passive',90100,1),('Undead',1,'active',90101,2);
