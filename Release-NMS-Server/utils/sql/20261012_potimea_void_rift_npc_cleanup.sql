-- Remove the redundant bolt-on a_void_rift NPC (478757) that the v110 vendor
-- batch dropped next to potimea's real void portal (OBJ_VOIDPORTAL, doorid 2,
-- zone 'potimea', ~75.9/-39.5/15.1). The zone controller now handles doorid 2
-- and ports to thevoida, so the visible rift art is the entry; the hail NPC
-- was a duplicate and renders as a human placeholder on RoF2 clients.
-- Also embedded as custom manifest entry 141; this file is the standalone
-- reference copy.
DELETE FROM `spawnentry` WHERE `npcID` = 478757;
DELETE FROM `spawn2` WHERE `spawngroupID` = 1520008657;
DELETE FROM `spawngroup` WHERE `id` = 1520008657;
DELETE FROM `npc_types` WHERE `id` = 478757;
