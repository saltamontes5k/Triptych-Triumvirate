-- Rollback for 20260922_crystalwing_faction_fix.sql

-- C (restore the duplicate stock task captured before deletion)
INSERT INTO `tasks` VALUES (6020,2,0,0,'Myjinn\'s Enlightenment','[Councilmember Myjinn, the first-born of the learned golden dragon Keikolin, hopes to enlighten you about the ways of his maker\'s focus. To do this, you must broaden your mind and open it to new knowledge. To prove your ability to learn, you must acquire three collections of lore and answer questions regarding them correctly.<br><br>- One book is being kept by the Librarian\'s Assistant, Geejulin, who resides in a quiet section of the library.<br>- Another parchment is written in drakkin blood and hidden amongst a pile of stones in the Dragon\'s Grove near the water. (The parchment is tucked between the pages of an old tome. Look for a stack of purple, green and yellow books on the ground near Y`ssuria the Elder.)<br>- And, lastly, the final lore is found on a magic parchment with no words, found on the shelves of the library. What you must do is cast the spell that lives in that parchment in order to read the text upon it. (The parchment is tucked between the pages of three colorful tomes. Look for a stack of blue, red and orange books on the shelf.)<br><br>Return to Myjinn with book and parchment and answer each question in turn.]','','0',1000,1000,0,0,0,0,0,0,0,0,1,1129,'Myjinn is vaguely impressed by your ability to answer the questions and will send word to Keikolin that you have passed this meager test. Keikolin will acknowledge your presence, but will likely not be impressed.',0,0,0,0,0,-1,10,1);
INSERT INTO `task_activities` VALUES (6020,0,-1,1,4,'Assistant Geejulin',0,1,'','394123','','',0,0,0,0,0,0,0,'-1','0','394',-1,0,0);
INSERT INTO `task_activities` VALUES (6020,1,-1,1,9,'',0,1,'Use the magic in the enchanted parchment to read it','','','',0,0,0,0,0,0,0,'-1','8691','394',-1,0,0);
INSERT INTO `task_activities` VALUES (6020,2,-1,2,255,'',0,1,'Speak with Councilmember Myjinn again after gathering and reading the three pieces of knowledge','','','',0,0,0,0,0,0,0,'-1','0','394',-1,0,0);

-- B
UPDATE npc_types SET npc_faction_id = 0 WHERE id = 405105;

-- A
UPDATE npc_types SET npc_faction_id = 0 WHERE id IN (397006, 397007, 397275);
DELETE FROM npc_faction_entries WHERE npc_faction_id = 1520000101;
DELETE FROM npc_faction WHERE id = 1520000101;
