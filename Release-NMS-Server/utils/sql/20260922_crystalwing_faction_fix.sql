-- Circle of the Crystalwing corrections (faction_list 1129; Allakhazam faction 473).
--
-- A. The three Allakhazam faction members (Pioneer Vulu, Scout Madu, Shrynn) were
--    npc_faction_id=0, so killing them did nothing.  Wire them to a Crystalwing-member
--    faction whose single kill entry lowers 1129 by 10.
-- B. #Gatekeeper_Kor (405105) is a hostile Direwind Cliffs NPC that drops a raid-key
--    item; it was wrongly in gen_kos_faction.py's FRIENDLY allowlist, leaving it
--    neutral.  Move it onto the TSS KOS faction.
-- C. Remove the duplicate stock task "Myjinn's Enlightenment" (id 6020).  The TSS arc
--    uses 600245 (wired in quests/crescent/Councilmember_Myjinn.pl); 6020 was
--    unreachable and only duplicated the title.

-- A ---------------------------------------------------------------------------
DELETE FROM npc_faction_entries WHERE npc_faction_id = 1520000101;
DELETE FROM npc_faction WHERE id = 1520000101;

INSERT INTO npc_faction (id, name, primaryfaction, ignore_primary_assist)
  VALUES (1520000101, 'crystalwing_member', 1129, 0);

INSERT INTO npc_faction_entries (npc_faction_id, faction_id, value, npc_value, temp)
  VALUES (1520000101, 1129, -10, 0, 0);

UPDATE npc_types SET npc_faction_id = 1520000101 WHERE id IN (397006, 397007, 397275);

-- B ---------------------------------------------------------------------------
UPDATE npc_types SET npc_faction_id = 20004 WHERE id = 405105;

-- C ---------------------------------------------------------------------------
DELETE FROM task_activities WHERE taskid = 6020;
DELETE FROM tasks WHERE id = 6020;
