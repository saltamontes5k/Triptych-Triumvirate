-- Rollback of 20261024_xebuxoruk_clone.sql (manifest entry 222).
-- Removes the spawn wiring and the clone row, and restores npc 223238 to the
-- exact row that existed immediately before this entry ran -- the first
-- authoring pass's 'Zebuxoruk_' hijack of the PEQ #Shadow_of_Terlok slot
-- (captured verbatim from the peq-2026-10-17 daily backup). Note: that
-- pre-entry state was itself the defect; re-applying the forward entry
-- restores the shadow.

DELETE FROM spawnentry WHERE spawngroupID = 1520009100;
DELETE FROM spawn2 WHERE id = 1520023800;
DELETE FROM spawngroup WHERE id = 1520009100;

DELETE FROM npc_types WHERE id = 1120001288;

DELETE FROM npc_types WHERE id = 223238;

INSERT INTO npc_types VALUES (223238,'Zebuxoruk_','The Forsaken',75,295,1,0,3750000,0,2,0,0,0,30,0,0,0,794330,0,0,0,0,0,79,0,0,1800,4000,-1,'','1,1^2,3,1,10^3,4,1,15^4,1,5^6,1^7,1^12,1^13,1^14,1^15,1^16,1^17,1^21,1',70,70,1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,'IT10',28,28,7,10,400,400,400,400,400,0,0,1,0,0,900,0,0,0,25,0,400,400,400,400,400,400,400,0,0,1,0,1,1900,360,0,0,0,0,100,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,18,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,-1,0,100,15,0,1,0,0,0,0);
