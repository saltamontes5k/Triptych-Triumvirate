-- ============================================================================
-- Mount saddle fix - missing horses rows
-- ----------------------------------------------------------------------------
-- Mount spell resolution: Horse::BuildHorseType looks up horses.filename =
-- spells_new.teleport_zone (SE_SummonHorse). These 26 mount spells reference
-- filenames that had no horses row, so every one of them errored with
-- 'No Database entry for mount' (Komodo, wolf/worg family, Ethernere Wurm,
-- Umbral/Verdant Selyrah, Ornate Flying Carpet, Rhyan's Horse, Jungle Raptor,
-- Raptor, Reindeer, Swift/Lava Braxi, Topiary Lion Fast, Steed of War).
-- The real Komodo/wolf mount models do not exist in the RoF2 client, so the
-- Komodo borrows the wurm rig (679) and the wolf saddles the worg2 rig (594),
-- with distinct textures per wolf color (0=black,1=gray,2=white).
-- Idempotent (INSERT IGNORE, unique 'filename' key). Content-only;
-- no db_version.custom_version bump.
-- ============================================================================

INSERT IGNORE INTO `horses` (filename,race,gender,texture,helmtexture,mountspeed,notes) VALUES
('SumMKDRun2',679,2,0,-1,1.50,'Komodo Dragon Run'),
('SumMKDFast',679,2,0,-1,1.75,'Komodo Dragon Fast'),
('SumWUM00Gen',594,2,0,-1,1.50,'Black Wolf Saddle'),
('SumWUM01Gen',594,2,1,-1,1.50,'Gray Wolf Saddle'),
('SumWUM02Gen',594,2,2,-1,1.50,'White Wolf Saddle'),
('SumWGM00Gen',594,2,0,-1,1.50,'Worg Saddle'),
('SumWGM01Gen',594,2,1,-1,1.50,'Regal Worg Saddle'),
('SumWGM02Gen',594,2,2,-1,1.50,'Battle Armor Worg Saddle'),
('SumMWMm6Run2',679,2,5,-1,1.50,'Ethernere Wurm Run'),
('SumMWMm6Fast',679,2,5,-1,1.75,'Ethernere Wurm Fast'),
('SumMSLm2Run2',674,2,2,-1,1.50,'Umbral Selyrah Run'),
('SumMSLm2Fast',674,2,2,-1,1.75,'Umbral Selyrah Fast'),
('SumMSLm4Run2',674,2,4,-1,1.50,'Verdant Selyrah'),
('SumMCPm0Run2',720,2,0,-1,1.50,'Ornate Flying Carpet Run'),
('SumMCPm0Fast',720,2,0,-1,1.75,'Ornate Flying Carpet Fast'),
('SumUNMm12Run2',517,2,12,-1,1.50,'Rhyan''s Horse Run'),
('SumUNMm12Fast',517,2,12,-1,1.75,'Rhyan''s Horse Fast'),
('SumMRPm3Run2',680,2,3,-1,1.50,'Jungle Raptor Run'),
('SumMRPm3Fast',680,2,3,-1,1.75,'Jungle Raptor Fast'),
('SumMRMRun2',680,2,0,-1,1.50,'Raptor'),
('SumMRERun2',583,2,0,-1,1.50,'Reindeer Saddle'),
('SumMBXm0Fast',676,2,0,-1,1.75,'Swift Braxi Fast'),
('SumMBXm2Run2',676,2,2,-1,1.50,'Lava Braxi Run'),
('SumMTLm0Fast',671,2,0,-1,1.75,'Verdant Topiary Lion Fast'),
('SumHRSm9Run2',517,2,9,-1,1.50,'Steed of War Run'),
('SumHRSm9Fast',517,2,9,-1,1.75,'Steed of War Fast');