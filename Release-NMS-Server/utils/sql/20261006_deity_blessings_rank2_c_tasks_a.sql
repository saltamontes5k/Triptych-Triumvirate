-- ============================================================================
-- Deity Blessings -- Rank 2 "Deity Favors": tasks, trees 1-8
-- Date: 2026-10-06
--
-- 700100 Bertoxxulous (Culling Fever)          -- infect-hail tour
-- 700109 Brell Serilis (Crafting a Party)      -- 6 tradeskills + delivery
-- 700118 Cazic-Thule (A Taste of Fear)         -- sow fear tour
-- 700127 Erollisi Marr (Love, Norrathian Style)-- 3 book deliveries
-- 700136 Bristlebane (Party Favor)             -- find 8 party machines
-- 700145 Innoruuk (The Power of Hatred)        -- needle tour + kill
-- 700154 Karana (Tears of a God)               -- 6 rains + Tober
-- 700163 Mithaniel Marr (Deliver Us from Evil) -- 10 spectres
--
-- Rank-2 task id = 700100 + treeIndex*9. Repeatable for post-severance
-- re-earning; the plugin's sequential rank gate prevents double grants.
-- Idempotent: deletes owned ids first.
-- ============================================================================

DELETE FROM `task_activities` WHERE `taskid` IN (700100,700109,700118,700127,700136,700145,700154,700163);
DELETE FROM `tasks`           WHERE `id`      IN (700100,700109,700118,700127,700136,700145,700154,700163);

INSERT INTO `tasks`
    (`id`,`type`,`duration`,`duration_code`,`title`,`description`,`reward_text`,
     `cash_reward`,`exp_reward`,`reward_method`,`reward_points`,`reward_point_type`,
     `min_level`,`max_level`,`level_spread`,`min_players`,`max_players`,`repeatable`,
     `faction_reward`,`completion_emote`,`replay_timer_group`,`replay_timer_seconds`,
     `request_timer_group`,`request_timer_seconds`,`dz_template_id`,`lock_activity_id`,
     `faction_amount`,`enabled`)
VALUES
    (700100,2,0,0,'Favor of Bertoxxulous','Spread the plagues of the Plague Lord for his Avatar in the East Karana gnoll camp.','The Avatar of Bertoxxulous nods: you have earned Rank II of his blessing.',0,0,0,0,0,1,125,0,1,1,1,0,'',0,0,0,0,0,-1,0,1),
    (700109,2,0,0,'Favor of Brell Serilis','Craft a feast for the Underfoot God and serve it to Roderik in Butcherblock.','Roderik raises a toast: you have earned Rank II of Brell''s blessing.',0,0,0,0,0,1,125,0,1,1,1,0,'',0,0,0,0,0,-1,0,1),
    (700118,2,0,0,'Favor of Cazic-Thule','Carry Pirex''s wands and sow fear in the hearts of the complacent.','Fear has been served: you have earned Rank II of Cazic-Thule''s blessing.',0,0,0,0,0,1,125,0,1,1,1,0,'',0,0,0,0,0,-1,0,1),
    (700127,2,0,0,'Favor of Erollisi Marr','Deliver the Books of Love to three lonely hearts of Norrath.','Love has found its mark: you have earned Rank II of Erollisi''s blessing.',0,0,0,0,0,1,125,0,1,1,1,0,'',0,0,0,0,0,-1,0,1),
    (700136,2,0,0,'Favor of Bristlebane','Find every one of Bristlebane''s hidden Party Machines.','A fit of giggles: you have earned Rank II of Bristlebane''s blessing.',0,0,0,0,0,1,125,0,1,1,1,0,'',0,0,0,0,0,-1,0,1),
    (700145,2,0,0,'Favor of Innoruuk','Stoke hatred in the hearts of the content, for the Prince of Hate.','Hatred burns brighter: you have earned Rank II of Innoruuk''s blessing.',0,0,0,0,0,1,125,0,1,1,1,0,'',0,0,0,0,0,-1,0,1),
    (700154,2,0,0,'Favor of Karana','Carry the True Karanite Rod and bring rain to the dry corners of the world.','Thunder rolls: you have earned Rank II of Karana''s blessing.',0,0,0,0,0,1,125,0,1,1,1,0,'',0,0,0,0,0,-1,0,1),
    (700163,2,0,0,'Favor of Mithaniel Marr','Vanquish ten spectres of evil that fester across Norrath.','Valor rewarded: you have earned Rank II of Mithaniel Marr''s blessing.',0,0,0,0,0,1,125,0,1,1,1,0,'',0,0,0,0,0,-1,0,1);

INSERT INTO `task_activities`
    (`taskid`,`activityid`,`req_activity_id`,`step`,`activitytype`,`target_name`,`goalmethod`,
     `goalcount`,`description_override`,`npc_match_list`,`item_id_list`,`item_list`,`dz_switch_id`,
     `min_x`,`min_y`,`min_z`,`max_x`,`max_y`,`max_z`,`skill_list`,`spell_list`,`zones`,
     `zone_version`,`optional`,`list_group`)
VALUES
-- 700100 Culling Fever
    (700100,0,-1,1,4,'Scheredin',0,1,'Speak to Scheredin, Priest of Bertoxxulous in East Freeport.','344224','','',0,0,0,0,0,0,0,-1,0,'10',-1,0,0),
    (700100,1,-1,2,4,'a sandskimmer bat',0,1,'Infect a sandskimmer bat in North Ro with Virulent Olisteir Mold.','344230','','',0,0,0,0,0,0,0,-1,0,'392',-1,0,0),
    (700100,2,-1,3,4,'a mother rat',0,1,'Infect a mother rat in North Ro.','344231','','',0,0,0,0,0,0,0,-1,0,'392',-1,0,0),
    (700100,3,-1,4,4,'a wiry coyote',0,1,'Infect a wiry coyote in North Ro.','344232','','',0,0,0,0,0,0,0,-1,0,'392',-1,0,0),
    (700100,4,-1,5,4,'a raging fire beetle',0,1,'Infect a raging fire beetle in North Ro.','344233','','',0,0,0,0,0,0,0,-1,0,'392',-1,0,0),
    (700100,5,-1,6,4,'a clever stonesnake',0,1,'Infect a clever stonesnake in North Ro.','344234','','',0,0,0,0,0,0,0,-1,0,'392',-1,0,0),
    (700100,6,-1,7,4,'Scheredin',0,1,'Report to Scheredin in East Freeport.','344224','','',0,0,0,0,0,0,0,-1,0,'10',-1,0,0),
    (700100,7,-1,8,4,'a frisky black bear',0,1,'Infect a frisky black bear in the Rathe Mountains with Bone-Eating Goo.','344235','','',0,0,0,0,0,0,0,-1,0,'50',-1,0,0),
    (700100,8,-1,9,4,'a content brown bear',0,1,'Infect a content brown bear in the Rathe Mountains.','344236','','',0,0,0,0,0,0,0,-1,0,'50',-1,0,0),
    (700100,9,-1,10,4,'a clumsy black bear',0,1,'Infect a clumsy black bear in the Rathe Mountains.','344237','','',0,0,0,0,0,0,0,-1,0,'50',-1,0,0),
    (700100,10,-1,11,4,'Scheredin',0,1,'Report to Scheredin in East Freeport.','344224','','',0,0,0,0,0,0,0,-1,0,'10',-1,0,0),
    (700100,11,-1,12,4,'a keen driftwolf',0,1,'Infect a keen driftwolf in the Eastern Wastes with Augrin''s Cholerae.','344238','','',0,0,0,0,0,0,0,-1,0,'116',-1,0,0),
    (700100,12,-1,13,4,'a floppy snow hare',0,1,'Infect a floppy snow hare in the Eastern Wastes.','344239','','',0,0,0,0,0,0,0,-1,0,'116',-1,0,0),
    (700100,13,-1,14,4,'Scheredin',0,1,'Report to Scheredin in East Freeport.','344224','','',0,0,0,0,0,0,0,-1,0,'10',-1,0,0),
    (700100,14,-1,15,4,'a sinewy tiger',0,1,'Infect a sinewy tiger in Toxxulia with Fraech''s Hidebloom.','344240','','',0,0,0,0,0,0,0,-1,0,'414',-1,0,0),
    (700100,15,-1,16,4,'an endearing skunk',0,1,'Infect an endearing skunk in Toxxulia.','344241','','',0,0,0,0,0,0,0,-1,0,'414',-1,0,0),
    (700100,16,-1,17,4,'Scheredin',0,1,'Report to Scheredin in East Freeport.','344224','','',0,0,0,0,0,0,0,-1,0,'10',-1,0,0),
    (700100,17,-1,18,4,'Damaex the Unicorn',0,1,'Infect Damaex the Unicorn in Lesser Faydark with Redrech''s Scallops Plague.','344242','','',0,0,0,0,0,0,0,-1,0,'57',-1,0,0),
    (700100,18,-1,19,4,'Avatar of Bertoxxulous',0,1,'Report your work to the Avatar of Bertoxxulous in the East Karana gnoll camp.','344210','','',0,0,0,0,0,0,0,-1,0,'15',-1,0,0),
-- 700109 Crafting a Party
    (700109,0,-1,1,4,'Roderik',0,1,'Speak to Roderik, High Priest of Brell in Butcherblock.','344211','','',0,0,0,0,0,0,0,-1,0,'68',-1,0,0),
    (700109,1,-1,2,6,'Silver Fork',0,1,'Craft a Silver Fork (jewelry kit).','','42888','',0,0,0,0,0,0,0,-1,0,'',-1,0,0),
    (700109,2,-1,3,6,'Silk Napkin',0,1,'Craft a Silk Napkin (tailoring kit).','','976240','',0,0,0,0,0,0,0,-1,0,'',-1,0,0),
    (700109,3,-1,4,6,'Plain Dining Plate',0,1,'Craft a Plain Dining Plate (pottery wheel, then kiln).','','976242','',0,0,0,0,0,0,0,-1,0,'',-1,0,0),
    (700109,4,-1,5,6,'Kiola Nut Brew',0,1,'Brew a Kiola Nut Brew (brew barrel).','','976243','',0,0,0,0,0,0,0,-1,0,'',-1,0,0),
    (700109,5,-1,6,6,'Celebratory Seafood Medley',0,1,'Bake a Celebratory Seafood Medley (oven).','','976244','',0,0,0,0,0,0,0,-1,0,'',-1,0,0),
    (700109,6,-1,7,6,'Metal Camp Chair',0,1,'Forge a Metal Camp Chair (forge).','','42894','',0,0,0,0,0,0,0,-1,0,'',-1,0,0),
    (700109,7,-1,8,1,'Silver Fork',0,1,'Serve the Silver Fork to Roderik in Butcherblock.','344211','42888','',0,0,0,0,0,0,0,-1,0,'68',-1,0,0),
    (700109,8,-1,9,1,'Silk Napkin',0,1,'Serve the Silk Napkin to Roderik.','344211','976240','',0,0,0,0,0,0,0,-1,0,'68',-1,0,0),
    (700109,9,-1,10,1,'Plain Dining Plate',0,1,'Serve the Plain Dining Plate to Roderik.','344211','976242','',0,0,0,0,0,0,0,-1,0,'68',-1,0,0),
    (700109,10,-1,11,1,'Kiola Nut Brew',0,1,'Pour the Kiola Nut Brew for Roderik.','344211','976243','',0,0,0,0,0,0,0,-1,0,'68',-1,0,0),
    (700109,11,-1,12,1,'Celebratory Seafood Medley',0,1,'Serve the Celebratory Seafood Medley to Roderik.','344211','976244','',0,0,0,0,0,0,0,-1,0,'68',-1,0,0),
    (700109,12,-1,13,1,'Metal Camp Chair',0,1,'Deliver the Metal Camp Chair to Roderik.','344211','42894','',0,0,0,0,0,0,0,-1,0,'68',-1,0,0),
-- 700118 A Taste of Fear
    (700118,0,-1,1,4,'Pirex Saulen',0,1,'Speak to Pirex Saulen in the Field of Bone and take his wands.','344227','','',0,0,0,0,0,0,0,-1,0,'78',-1,0,0),
    (700118,1,-1,2,4,'Galayna Idirin',0,1,'Use the Wand of Dire Doubtfall on Galayna Idirin in Greater Faydark.','344260','','',0,0,0,0,0,0,0,-1,0,'54',-1,0,0),
    (700118,2,-1,3,4,'Arthin Guinden',0,1,'Use the Wand of Dire Doubtfall on Arthin Guinden in Greater Faydark.','344261','','',0,0,0,0,0,0,0,-1,0,'54',-1,0,0),
    (700118,3,-1,4,4,'Ierene Seldon',0,1,'Use the Wand of Hopecutting on Ierene Seldon in Erudin.','344262','','',0,0,0,0,0,0,0,-1,0,'24',-1,0,0),
    (700118,4,-1,5,4,'Agar Treebs',0,1,'Use the Wand of Fearful Unminding on Agar Treebs in the Commonlands.','344263','','',0,0,0,0,0,0,0,-1,0,'408',-1,0,0),
    (700118,5,-1,6,4,'Lord Antonius Bayle',0,1,'Sow doubt in the court of Lord Antonius Bayle in North Qeynos.','466029','','',0,0,0,0,0,0,0,-1,0,'2',-1,0,0),
    (700118,6,-1,7,4,'Captain Callesh',0,1,'Sow doubt in Captain Callesh in North Qeynos.','344264','','',0,0,0,0,0,0,0,-1,0,'2',-1,0,0),
    (700118,7,-1,8,4,'Sephlin of Qeynos',0,1,'Sow doubt in Sephlin in North Qeynos.','344265','','',0,0,0,0,0,0,0,-1,0,'2',-1,0,0),
    (700118,8,-1,9,4,'Pirex Saulen',0,1,'Report back to Pirex Saulen in the Field of Bone.','344227','','',0,0,0,0,0,0,0,-1,0,'78',-1,0,0),
    (700118,9,-1,10,4,'Avatar of Cazic-Thule',0,1,'Report to the Avatar of Cazic-Thule in the Feerrott.','344212','','',0,0,0,0,0,0,0,-1,0,'47',-1,0,0),
-- 700127 Love, Norrathian Style
    (700127,0,-1,1,4,'an Aspect of Erollisi Marr',0,1,'Speak to the Aspect of Erollisi Marr on the South Ro coast.','344213','','',0,0,0,0,0,0,0,-1,0,'393',-1,0,0),
    (700127,1,-1,2,1,'Oograh Breaknose',0,1,'Deliver Book of Love Vol. 1 to Oograh Breaknose in Steamfont.','344305','976218','',0,0,0,0,0,0,0,-1,0,'56',-1,0,0),
    (700127,2,-1,3,1,'a forlorn spirit',0,1,'Deliver Book of Love Vol. 2 to the forlorn spirit in the Field of Bone.','344306','976219','',0,0,0,0,0,0,0,-1,0,'78',-1,0,0),
    (700127,3,-1,4,1,'Jheri Dorsay',0,1,'Deliver Book of Love Vol. 3 to Jheri Dorsay beneath Kelethin.','344307','976220','',0,0,0,0,0,0,0,-1,0,'54',-1,0,0),
    (700127,4,-1,5,4,'an Aspect of Erollisi Marr',0,1,'Return to the Aspect of Erollisi Marr in South Ro.','344213','','',0,0,0,0,0,0,0,-1,0,'393',-1,0,0),
-- 700136 Party Favor
    (700136,0,-1,1,4,'Bristlebane''s Image',0,1,'Take the party challenge from Bristlebane''s Image in the Plane of Knowledge.','344214','','',0,0,0,0,0,0,0,-1,0,'202',-1,0,0),
    (700136,1,-1,2,4,'a party machine',0,1,'Find Bristlebane''s Party Machine in the Steamfont Mountains.','344308','','',0,0,0,0,0,0,0,-1,0,'56',-1,0,0),
    (700136,2,-1,3,4,'a party machine',0,1,'Find Bristlebane''s Party Machine in the Butcherblock Mountains.','344309','','',0,0,0,0,0,0,0,-1,0,'68',-1,0,0),
    (700136,3,-1,4,4,'a party machine',0,1,'Find Bristlebane''s Party Machine in the Qeynos Hills.','344310','','',0,0,0,0,0,0,0,-1,0,'4',-1,0,0),
    (700136,4,-1,5,4,'a party machine',0,1,'Find Bristlebane''s Party Machine on the South Ro coast.','344311','','',0,0,0,0,0,0,0,-1,0,'393',-1,0,0),
    (700136,5,-1,6,4,'a party machine',0,1,'Find Bristlebane''s Party Machine in Everfrost.','344312','','',0,0,0,0,0,0,0,-1,0,'30',-1,0,0),
    (700136,6,-1,7,4,'a party machine',0,1,'Find Bristlebane''s Party Machine in the Feerrott.','344313','','',0,0,0,0,0,0,0,-1,0,'47',-1,0,0),
    (700136,7,-1,8,4,'a party machine',0,1,'Find Bristlebane''s Party Machine beneath Kelethin.','344314','','',0,0,0,0,0,0,0,-1,0,'54',-1,0,0),
    (700136,8,-1,9,4,'a party machine',0,1,'Find Bristlebane''s Party Machine in Nektulos Forest.','344315','','',0,0,0,0,0,0,0,-1,0,'25',-1,0,0),
-- 700145 The Power of Hatred
    (700145,0,-1,1,4,'an evil little imp',0,1,'Serve the evil little imp in Innothule Swamp and take the Needle of Hatred.','76059','','',0,0,0,0,0,0,0,-1,0,'46',-1,0,0),
    (700145,1,-1,2,4,'Lauren',0,1,'Bring hatred to Lauren near the North Karana bridge.','344277','','',0,0,0,0,0,0,0,-1,0,'13',-1,0,0),
    (700145,2,-1,3,4,'Tyler',0,1,'Bring hatred to Tyler near the North Karana bridge.','344278','','',0,0,0,0,0,0,0,-1,0,'13',-1,0,0),
    (700145,3,-1,4,4,'Rondor Sandskipper',0,1,'Torment Rondor Sandskipper on the Ocean of Tears shores.','344279','','',0,0,0,0,0,0,0,-1,0,'409',-1,0,0),
    (700145,4,-1,5,4,'Innoruuk''s Flame',0,1,'Light the Flame of Innoruuk in Lake Rathetear.','344280','','',0,0,0,0,0,0,0,-1,0,'51',-1,0,0),
    (700145,5,-1,6,2,'an enraged aviak guard',0,1,'Slay the enraged aviak guard.','344281','','',0,0,0,0,0,0,0,-1,0,'51',-1,0,0),
    (700145,6,-1,7,4,'an evil little imp',0,1,'Bring the news of your success to the imp in Innothule Swamp.','76059','','',0,0,0,0,0,0,0,-1,0,'46',-1,0,0),
-- 700154 Tears of a God
    (700154,0,-1,1,4,'Avatar of Karana',0,1,'Accept the storm task from the Avatar of Karana in South Karana.','344219','','',0,0,0,0,0,0,0,-1,0,'14',-1,0,0),
    (700154,1,-1,2,4,'Tober Grandim',0,1,'Take the True Karanite Rod from Tober Grandim in North Karana.','344225','','',0,0,0,0,0,0,0,-1,0,'13',-1,0,0),
    (700154,2,-1,3,5,'rain on Everfrost',0,1,'Bring the rain to Everfrost.',' ','','',0,517,1910,-100,617,2010,-20,-1,0,'30',-1,0,0),
    (700154,3,-1,4,5,'rain on the Abysmal Sea',0,1,'Bring the rain to the decks of the Abysmal Sea.',' ','','',0,-193,-11,90,-93,89,170,-1,0,'279',-1,0,0),
    (700154,4,-1,5,5,'rain on Gunthak',0,1,'Bring the rain to the Gulf of Gunthak.',' ','','',0,2325,-813,31,2425,-713,111,-1,0,'224',-1,0,0),
    (700154,5,-1,6,5,'rain on Butcherblock',0,1,'Bring the rain to the Butcherblock Mountains.',' ','','',0,3066,829,-52,3166,929,28,-1,0,'68',-1,0,0),
    (700154,6,-1,7,5,'rain on the Scarlet Desert',0,1,'Bring the rain to the Scarlet Desert.',' ','','',0,1029,818,-137,1129,918,-57,-1,0,'175',-1,0,0),
    (700154,7,-1,8,5,'rain on the Plane of Knowledge',0,1,'Bring the rain to the Plane of Knowledge.',' ','','',0,-238,166,-150,-138,266,-70,-1,0,'202',-1,0,0),
    (700154,8,-1,9,4,'Tober Grandim',0,1,'Return the rod to Tober Grandim in North Karana.','344225','','',0,0,0,0,0,0,0,-1,0,'13',-1,0,0),
    (700154,9,-1,10,4,'Avatar of Karana',0,1,'Report to the Avatar of Karana in South Karana.','344219','','',0,0,0,0,0,0,0,-1,0,'14',-1,0,0),
-- 700163 Deliver Us from Evil
    (700163,0,-1,1,4,'Avatar of Mithaniel Marr',0,1,'Take the Eye of Valor from the Avatar of Mithaniel Marr in the Plane of Tranquility.','344217','','',0,0,0,0,0,0,0,-1,0,'203',-1,0,0),
    (700163,1,-1,2,2,'a spectre of evil',0,1,'Vanquish the spectre of evil in Everfrost.','344282','','',0,0,0,0,0,0,0,-1,0,'30',-1,0,0),
    (700163,2,-1,3,2,'a spectre of evil',0,1,'Vanquish the spectre of evil in South Karana.','344283','','',0,0,0,0,0,0,0,-1,0,'14',-1,0,0),
    (700163,3,-1,4,2,'a spectre of evil',0,1,'Vanquish the spectre of evil in Highpass Hold.','344284','','',0,0,0,0,0,0,0,-1,0,'5',-1,0,0),
    (700163,4,-1,5,2,'a spectre of evil',0,1,'Vanquish the spectre of evil in Butcherblock.','344285','','',0,0,0,0,0,0,0,-1,0,'68',-1,0,0),
    (700163,5,-1,6,2,'a spectre of evil',0,1,'Vanquish the spectre of evil in Lesser Faydark.','344286','','',0,0,0,0,0,0,0,-1,0,'57',-1,0,0),
    (700163,6,-1,7,2,'a spectre of evil',0,1,'Vanquish the spectre of evil at the Firiona Vie docks.','344287','','',0,0,0,0,0,0,0,-1,0,'84',-1,0,0),
    (700163,7,-1,8,2,'a spectre of evil',0,1,'Vanquish the spectre of evil in the Iceclad Ocean.','344288','','',0,0,0,0,0,0,0,-1,0,'110',-1,0,0),
    (700163,8,-1,9,2,'a spectre of evil',0,1,'Vanquish the spectre of evil aboard the Abysmal Sea.','344289','','',0,0,0,0,0,0,0,-1,0,'279',-1,0,0),
    (700163,9,-1,10,2,'a spectre of evil',0,1,'Vanquish the spectre of evil in Shadeweaver''s Thicket.','344290','','',0,0,0,0,0,0,0,-1,0,'165',-1,0,0),
    (700163,10,-1,11,2,'a spectre of evil',0,1,'Vanquish the spectre of evil in Hollowshade Moor.','344291','','',0,0,0,0,0,0,0,-1,0,'166',-1,0,0),
    (700163,11,-1,12,4,'Avatar of Mithaniel Marr',0,1,'Return the Eye of Valor to the Avatar in the Plane of Tranquility.','344217','','',0,0,0,0,0,0,0,-1,0,'203',-1,0,0);
