-- Doppelganger-style swarm pets for every player-reachable SE_Doppelganger spell.
--
-- Client::Doppelganger() resolves spells_new.teleport_zone through `pets`, then
-- clones the caster's appearance, level, stats, gear and buffs onto that NPC
-- template. Only SwarmPetDG1..SwarmPetDG3 ever existed in `pets`, so every
-- spell below bailed at GetPetEntry() and summoned nothing, e.g.:
--   [Doppelganger] Unknown doppelganger spell id: [12580], check pets table
--
-- Because the template is fully overwritten from the caster, the existing
-- SwarmPetDG3 template (npc_types 684) is correct for every one of these.
-- This covers:
--   Doppelganger AA ranks 4-13   SwarmPetDG4..DG13   (spells 12580..31606)
--   Doppelganger leftover IDs    SwarmPetDG14..DG18  (spells 31607..33932)
--   Projection of Fury (AA 3213/23213)  SwarmPetDGWarProj/2 (21785/23538)
--   Illusory Ally (AA 2203)      SwarmPetIA01..03    (38414..38416)
--   First Spire of Enchantment   SpireDoppelganger1..3 (16279..16281)
--     template only: the spire rank spells (16270..16278) still carry no
--     SE_Doppelganger effect, so 16279..16281 are not cast by anything yet.
--   Rune of Tallon (item 86163/86174)   15AVTallonSwarm (39616)
--
-- NPC-only SE_Doppelganger spells are deliberately not covered: the effect
-- handler ignores non-client casters.
-- Keep in sync with common/database/database_update_manifest_custom.cpp entry 165.

INSERT INTO `pets`
  (`type`,`petpower`,`npcID`,`temp`,`petcontrol`,`petnaming`,`monsterflag`,`equipmentset`)
VALUES
  ('SwarmPetDG4',        -1, 684, 0, 0, 0, 0, -1),
  ('SwarmPetDG5',        -1, 684, 0, 0, 0, 0, -1),
  ('SwarmPetDG6',        -1, 684, 0, 0, 0, 0, -1),
  ('SwarmPetDG7',        -1, 684, 0, 0, 0, 0, -1),
  ('SwarmPetDG8',        -1, 684, 0, 0, 0, 0, -1),
  ('SwarmPetDG9',        -1, 684, 0, 0, 0, 0, -1),
  ('SwarmPetDG10',       -1, 684, 0, 0, 0, 0, -1),
  ('SwarmPetDG11',       -1, 684, 0, 0, 0, 0, -1),
  ('SwarmPetDG12',       -1, 684, 0, 0, 0, 0, -1),
  ('SwarmPetDG13',       -1, 684, 0, 0, 0, 0, -1),
  ('SwarmPetDG14',       -1, 684, 0, 0, 0, 0, -1),
  ('SwarmPetDG15',       -1, 684, 0, 0, 0, 0, -1),
  ('SwarmPetDG16',       -1, 684, 0, 0, 0, 0, -1),
  ('SwarmPetDG17',       -1, 684, 0, 0, 0, 0, -1),
  ('SwarmPetDG18',       -1, 684, 0, 0, 0, 0, -1),
  ('SwarmPetDGWarProj',  -1, 684, 0, 0, 0, 0, -1),
  ('SwarmPetDGWarProj2', -1, 684, 0, 0, 0, 0, -1),
  ('SwarmPetIA01',       -1, 684, 0, 0, 0, 0, -1),
  ('SwarmPetIA02',       -1, 684, 0, 0, 0, 0, -1),
  ('SwarmPetIA03',       -1, 684, 0, 0, 0, 0, -1),
  ('SpireDoppelganger1', -1, 684, 0, 0, 0, 0, -1),
  ('SpireDoppelganger2', -1, 684, 0, 0, 0, 0, -1),
  ('SpireDoppelganger3', -1, 684, 0, 0, 0, 0, -1),
  ('15AVTallonSwarm',    -1, 684, 0, 0, 0, 0, -1)
ON DUPLICATE KEY UPDATE `npcID` = `npcID`;
