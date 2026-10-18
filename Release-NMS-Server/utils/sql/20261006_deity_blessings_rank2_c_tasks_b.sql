-- ============================================================================
-- Deity Blessings -- Rank 2 "Deity Favors": tasks, trees 9-16
-- Date: 2026-10-06
--
-- 700172 Prexus (Fishing for Blessings)        -- 8 blessed fish + delivery
-- 700181 Quellious (Peace and Understanding)   -- pies + calm tour
-- 700190 Rallos Zek (Warrior's Rest)           -- Togg Purk trials
-- 700199 Rodcet Nife (Healing Touch)           -- 10 injured animals
-- 700208 Solusek Ro (Bonfires of Vanity)       -- 10 bonfires
-- 700217 the Tribunal (Justice of the Tribunal)-- 10 city targets
-- 700226 Tunare (The Gift of Life)             -- 10 plantings
-- 700235 Veeshan (Memory in Crystal)           -- 5-question trivia (script-driven)
--
-- Idempotent: deletes owned ids first.
-- ============================================================================

DELETE FROM `task_activities` WHERE `taskid` IN (700172,700181,700190,700199,700208,700217,700226,700235);
DELETE FROM `tasks`           WHERE `id`      IN (700172,700181,700190,700199,700208,700217,700226,700235);

INSERT INTO `tasks`
    (`id`,`type`,`duration`,`duration_code`,`title`,`description`,`reward_text`,
     `cash_reward`,`exp_reward`,`reward_method`,`reward_points`,`reward_point_type`,
     `min_level`,`max_level`,`level_spread`,`min_players`,`max_players`,`repeatable`,
     `faction_reward`,`completion_emote`,`replay_timer_group`,`replay_timer_seconds`,
     `request_timer_group`,`request_timer_seconds`,`dz_template_id`,`lock_activity_id`,
     `faction_amount`,`enabled`)
VALUES
    (700172,2,0,0,'Favor of Prexus','Bless the Ocean Lord with eight blessed fish from the waters of the world.','The offering is accepted: you have earned Rank II of Prexus'' blessing.',0,0,0,0,0,1,125,0,1,1,1,0,'',0,0,0,0,0,-1,0,1),
    (700181,2,0,0,'Favor of Quellious','Calm the hot tempers of Norrath with pie and patience.','Tranquility spreads: you have earned Rank II of Quellious'' blessing.',0,0,0,0,0,1,125,0,1,1,1,0,'',0,0,0,0,0,-1,0,1),
    (700190,2,0,0,'Favor of Rallos Zek','Prove your worth in the trials of Togg Purk.','War finds you worthy: you have earned Rank II of Rallos Zek''s blessing.',0,0,0,0,0,1,125,0,1,1,1,0,'',0,0,0,0,0,-1,0,1),
    (700199,2,0,0,'Favor of Rodcet Nife','Mend ten wounded creatures in the name of the Prime Healer.','The wounds close: you have earned Rank II of Rodcet Nife''s blessing.',0,0,0,0,0,1,125,0,1,1,1,0,'',0,0,0,0,0,-1,0,1),
    (700208,2,0,0,'Favor of Solusek Ro','Set ten beacons of flame across the old world.','The beacons burn: you have earned Rank II of Solusek Ro''s blessing.',0,0,0,0,0,1,125,0,1,1,1,0,'',0,0,0,0,0,-1,0,1),
    (700217,2,0,0,'Favor of the Tribunal','Execute the judgment of the Six upon ten wrongdoers.','Justice is served: you have earned Rank II of the Tribunal''s blessing.',0,0,0,0,0,1,125,0,1,1,1,0,'',0,0,0,0,0,-1,0,1),
    (700226,2,0,0,'Favor of Tunare','Plant the mysterious seeds and wake the treants of the wilds.','Life blooms anew: you have earned Rank II of Tunare''s blessing.',0,0,0,0,0,1,125,0,1,1,1,0,'',0,0,0,0,0,-1,0,1),
    (700235,2,0,0,'Favor of Veeshan','Answer the crystalline avatar''s questions and prove your memory.','The Wyrmqueen is pleased: you have earned Rank II of Veeshan''s blessing.',0,0,0,0,0,1,125,0,1,1,1,0,'',0,0,0,0,0,-1,0,1);

INSERT INTO `task_activities`
    (`taskid`,`activityid`,`req_activity_id`,`step`,`activitytype`,`target_name`,`goalmethod`,
     `goalcount`,`description_override`,`npc_match_list`,`item_id_list`,`item_list`,`dz_switch_id`,
     `min_x`,`min_y`,`min_z`,`max_x`,`max_y`,`max_z`,`skill_list`,`spell_list`,`zones`,
     `zone_version`,`optional`,`list_group`)
VALUES
-- 700172 Fishing for Blessings
    (700172,0,-1,1,4,'Primate of Prexus',0,1,'Make an offering to the Primate of Prexus on Erud''s Crossing.','344222','','',0,0,0,0,0,0,0,-1,0,'98',-1,0,0),
    (700172,1,-1,2,7,'Blessed Barren Flounder',0,1,'Fish up a Blessed Barren Flounder on Erud''s Crossing.','','976230','',0,0,0,0,0,0,0,-1,0,'98',-1,0,0),
    (700172,2,-1,3,7,'Blessed Gunthak Mackerel',0,1,'Fish up a Blessed Gunthak Mackerel in the Ocean of Tears.','','976231','',0,0,0,0,0,0,0,-1,0,'409',-1,0,0),
    (700172,3,-1,4,7,'Blessed Timorous Tuna',0,1,'Fish up a Blessed Timorous Tuna in the Timorous Deep.','','976232','',0,0,0,0,0,0,0,-1,0,'96',-1,0,0),
    (700172,4,-1,5,7,'Blessed Iceclad Cutlassfish',0,1,'Fish up a Blessed Iceclad Cutlassfish in the Iceclad Ocean.','','976233','',0,0,0,0,0,0,0,-1,0,'110',-1,0,0),
    (700172,5,-1,6,7,'Blessed Kunark Mullet',0,1,'Fish up a Blessed Kunark Mullet in the Field of Bone.','','976234','',0,0,0,0,0,0,0,-1,0,'78',-1,0,0),
    (700172,6,-1,7,7,'Blessed 15 lb. Saltwater Tuna',0,1,'Fish up a Blessed 15 lb. Saltwater Tuna on the Abysmal Sea.','','976235','',0,0,0,0,0,0,0,-1,0,'279',-1,0,0),
    (700172,7,-1,8,7,'Blessed Kedge Grunion',0,1,'Fish up a Blessed Kedge Grunion in Kedge Keep.','','976236','',0,0,0,0,0,0,0,-1,0,'64',-1,0,0),
    (700172,8,-1,9,7,'Blessed Ovate Jellyfish',0,1,'Fish up a Blessed Ovate Jellyfish in the Gulf of Gunthak.','','976237','',0,0,0,0,0,0,0,-1,0,'224',-1,0,0),
    (700172,9,-1,10,1,'the flounder',0,1,'Deliver the Blessed Barren Flounder to the Primate.','344222','976230','',0,0,0,0,0,0,0,-1,0,'98',-1,0,0),
    (700172,10,-1,11,1,'the mackerel',0,1,'Deliver the Blessed Gunthak Mackerel to the Primate.','344222','976231','',0,0,0,0,0,0,0,-1,0,'98',-1,0,0),
    (700172,11,-1,12,1,'the tuna',0,1,'Deliver the Blessed Timorous Tuna to the Primate.','344222','976232','',0,0,0,0,0,0,0,-1,0,'98',-1,0,0),
    (700172,12,-1,13,1,'the cutlassfish',0,1,'Deliver the Blessed Iceclad Cutlassfish to the Primate.','344222','976233','',0,0,0,0,0,0,0,-1,0,'98',-1,0,0),
    (700172,13,-1,14,1,'the mullet',0,1,'Deliver the Blessed Kunark Mullet to the Primate.','344222','976234','',0,0,0,0,0,0,0,-1,0,'98',-1,0,0),
    (700172,14,-1,15,1,'the saltwater tuna',0,1,'Deliver the Blessed 15 lb. Saltwater Tuna to the Primate.','344222','976235','',0,0,0,0,0,0,0,-1,0,'98',-1,0,0),
    (700172,15,-1,16,1,'the grunion',0,1,'Deliver the Blessed Kedge Grunion to the Primate.','344222','976236','',0,0,0,0,0,0,0,-1,0,'98',-1,0,0),
    (700172,16,-1,17,1,'the jellyfish',0,1,'Deliver the Blessed Ovate Jellyfish to the Primate.','344222','976237','',0,0,0,0,0,0,0,-1,0,'98',-1,0,0),
-- 700181 Peace and Understanding
    (700181,0,-1,1,4,'Avatar of Quellious',0,1,'Take the task from the Avatar of Quellious in the Plane of Tranquility.','600155','','',0,0,0,0,0,0,0,-1,0,'203',-1,0,0),
    (700181,1,-1,2,4,'Nettle Higglesbury',0,1,'Speak to Nettle Higglesbury in Misty Thicket.','600156','','',0,0,0,0,0,0,0,-1,0,'33',-1,0,0),
    (700181,2,-1,3,1,'an angry farmer',0,10,'Calm ten angry farmers with Strawberry-Jumjum Pie in Misty Thicket.','344267|344268|344269|344270|344271|344272|344273|344274|344275|344276','976221','',0,0,0,0,0,0,0,-1,0,'33',-1,0,0),
    (700181,3,-1,4,4,'Atler Flamejabber',0,1,'Bring peace to Atler Flamejabber in West Freeport.','394020','','',0,0,0,0,0,0,0,-1,0,'9',-1,0,0),
    (700181,4,-1,5,4,'a drunken Fordel miscreant',0,1,'Calm the drunken Fordel miscreant in Shadow Haven.','600157','','',0,0,0,0,0,0,0,-1,0,'150',-1,0,0),
    (700181,5,-1,6,4,'a drunken Midst miscreant',0,1,'Calm the drunken Midst miscreant in Shadow Haven.','600158','','',0,0,0,0,0,0,0,-1,0,'150',-1,0,0),
    (700181,6,-1,7,4,'Avatar of Quellious',0,1,'Return to the Avatar of Quellious.','600155','','',0,0,0,0,0,0,0,-1,0,'203',-1,0,0),
-- 700190 Warrior's Rest
    (700190,0,-1,1,4,'Avatar of Rallos Zek',0,1,'Offer yourself to the Avatar of Rallos Zek in the Plane of Tranquility.','344218','','',0,0,0,0,0,0,0,-1,0,'203',-1,0,0),
    (700190,1,-1,2,4,'Togg Purk',0,1,'Speak to Togg Purk in the Lavastorm Mountains and agree to be tested.','344226','','',0,0,0,0,0,0,0,-1,0,'27',-1,0,0),
    (700190,2,-1,3,2,'a Doppleganger',0,1,'Slay the first doppleganger.','344292','','',0,0,0,0,0,0,0,-1,0,'27',-1,0,0),
    (700190,3,-1,4,4,'Togg Purk',0,1,'Report the first kill to Togg Purk.','344226','','',0,0,0,0,0,0,0,-1,0,'27',-1,0,0),
    (700190,4,-1,5,2,'a Fierce Doppleganger',0,1,'Slay the fierce doppleganger.','344293','','',0,0,0,0,0,0,0,-1,0,'27',-1,0,0),
    (700190,5,-1,6,4,'Togg Purk',0,1,'Report the second kill to Togg Purk.','344226','','',0,0,0,0,0,0,0,-1,0,'27',-1,0,0),
    (700190,6,-1,7,2,'a Raging Doppleganger',0,1,'Slay the raging doppleganger.','344294','','',0,0,0,0,0,0,0,-1,0,'27',-1,0,0),
    (700190,7,-1,8,4,'Avatar of Rallos Zek',0,1,'Return to the Avatar of Rallos Zek.','344218','','',0,0,0,0,0,0,0,-1,0,'203',-1,0,0),
-- 700199 Healing Touch
    (700199,0,-1,1,4,'Helera Garet',0,1,'Take the task from Helera Garet in North Qeynos.','344223','','',0,0,0,0,0,0,0,-1,0,'2',-1,0,0),
    (700199,1,-1,2,4,'an Injured Rat',0,1,'Heal the Injured Rat in the Qeynos Hills.','344250','','',0,0,0,0,0,0,0,-1,0,'4',-1,0,0),
    (700199,2,-1,3,4,'an Injured Skunk',0,1,'Heal the Injured Skunk in Butcherblock.','344251','','',0,0,0,0,0,0,0,-1,0,'68',-1,0,0),
    (700199,3,-1,4,4,'an Injured Drixie',0,1,'Heal the Injured Drixie in Lesser Faydark.','344252','','',0,0,0,0,0,0,0,-1,0,'57',-1,0,0),
    (700199,4,-1,5,4,'an Injured Drake',0,1,'Heal the Injured Drake in Nektulos Forest.','344253','','',0,0,0,0,0,0,0,-1,0,'25',-1,0,0),
    (700199,5,-1,6,4,'an Injured Kodiak',0,1,'Heal the Injured Kodiak in the Commonlands.','344254','','',0,0,0,0,0,0,0,-1,0,'408',-1,0,0),
    (700199,6,-1,7,4,'an Injured Coyote',0,1,'Heal the Injured Coyote in North Ro.','344255','','',0,0,0,0,0,0,0,-1,0,'392',-1,0,0),
    (700199,7,-1,8,4,'an Injured Rockhopper',0,1,'Heal the Injured Rockhopper in Marus Seru.','344256','','',0,0,0,0,0,0,0,-1,0,'168',-1,0,0),
    (700199,8,-1,9,4,'an Injured Snake',0,1,'Heal the Injured Snake in Nedaria''s Landing.','344257','','',0,0,0,0,0,0,0,-1,0,'182',-1,0,0),
    (700199,9,-1,10,4,'an Injured Alligator',0,1,'Heal the Injured Alligator in Innothule Swamp.','344258','','',0,0,0,0,0,0,0,-1,0,'46',-1,0,0),
    (700199,10,-1,11,4,'an Injured Scorpion',0,1,'Heal the Injured Scorpion in the Field of Bone.','344259','','',0,0,0,0,0,0,0,-1,0,'78',-1,0,0),
    (700199,11,-1,12,4,'Helera Garet',0,1,'Return to Helera Garet in North Qeynos.','344223','','',0,0,0,0,0,0,0,-1,0,'2',-1,0,0),
-- 700208 Bonfires of Vanity
    (700208,0,-1,1,4,'Avatar of Solusek Ro',0,1,'Accept the flame task from the Avatar of Solusek Ro in North Ro.','344220','','',0,0,0,0,0,0,0,-1,0,'392',-1,0,0),
    (700208,1,-1,2,5,'bonfire of South Ro',0,1,'Set the flame near the Spectre Tower of South Ro.',' ','','',0,3789,-1701,-16,3889,-1601,64,-1,0,'393',-1,0,0),
    (700208,2,-1,3,5,'bonfire of Jaggedpine',0,1,'Set the flame in the Jaggedpine Forest.',' ','','',0,962,1682,-42,1062,1782,38,-1,0,'181',-1,0,0),
    (700208,3,-1,4,5,'bonfire of Everfrost',0,1,'Set the flame by the sand giant statue of Everfrost.',' ','','',0,580,-5462,-21,680,-5362,59,-1,0,'30',-1,0,0),
    (700208,4,-1,5,5,'bonfire of the Commonlands',0,1,'Set the flame in the Commonlands.',' ','','',0,2630,233,-77,2730,333,3,-1,0,'408',-1,0,0),
    (700208,5,-1,6,5,'bonfire of Nektulos',0,1,'Set the flame along the road of Nektulos Forest.',' ','','',0,-147,86,-3,-47,186,77,-1,0,'25',-1,0,0),
    (700208,6,-1,7,5,'bonfire of Toxxulia',0,1,'Set the flame by the druid ring of Toxxulia.',' ','','',0,807,-1107,-12,907,-1007,68,-1,0,'414',-1,0,0),
    (700208,7,-1,8,5,'bonfire of Greater Faydark',0,1,'Set the flame beneath Kelethin.',' ','','',0,638,371,77,738,471,157,-1,0,'54',-1,0,0),
    (700208,8,-1,9,5,'bonfire of Dagnor''s Cauldron',0,1,'Set the flame by the Unrest passage of Dagnor''s Cauldron.',' ','','',0,-1698,-743,-378,-1598,-643,-298,-1,0,'70',-1,0,0),
    (700208,9,-1,10,5,'bonfire of the Burning Woods',0,1,'Set the flame at the great meteor of the Burning Woods.',' ','','',0,-832,-1072,-279,-732,-972,-199,-1,0,'87',-1,0,0),
    (700208,10,-1,11,5,'bonfire of the Iceclad Ocean',0,1,'Set the flame outside the Tower of Frozen Shadow.',' ','','',0,1477,2917,-79,1577,3017,1,-1,0,'110',-1,0,0),
    (700208,11,-1,12,4,'Avatar of Solusek Ro',0,1,'Return the last flame to the Avatar of Solusek Ro.','344220','','',0,0,0,0,0,0,0,-1,0,'392',-1,0,0),
-- 700217 Justice of the Tribunal
    (700217,0,-1,1,4,'Herald of Justice Due',0,1,'Take the judgment from the Herald of Justice Due in the Plane of Tranquility.','344216','','',0,0,0,0,0,0,0,-1,0,'203',-1,0,0),
    (700217,1,-1,2,2,'Branack Welk',0,1,'Execute judgment on Branack Welk of the West Freeport academy.','344295','','',0,0,0,0,0,0,0,-1,0,'9',-1,0,0),
    (700217,2,-1,3,2,'Tomee Stenk',0,1,'Execute judgment on Tomee Stenk of South Qeynos.','344296','','',0,0,0,0,0,0,0,-1,0,'1',-1,0,0),
    (700217,3,-1,4,2,'Silva Tonk',0,1,'Execute judgment on Silva Tonk of Erudin.','344297','','',0,0,0,0,0,0,0,-1,0,'24',-1,0,0),
    (700217,4,-1,5,2,'Encan V`Dal',0,1,'Execute judgment on Encan V`Dal of Neriak.','344298','','',0,0,0,0,0,0,0,-1,0,'42',-1,0,0),
    (700217,5,-1,6,2,'Eoando Kelu',0,1,'Execute judgment on Eoando Kelu of Felwithe.','344299','','',0,0,0,0,0,0,0,-1,0,'62',-1,0,0),
    (700217,6,-1,7,2,'Gloribo Hammerbreaker',0,1,'Execute judgment on Gloribo Hammerbreaker of Kaladim.','344300','','',0,0,0,0,0,0,0,-1,0,'67',-1,0,0),
    (700217,7,-1,8,2,'Snogge',0,1,'Execute judgment on Snogge of Oggok.','344301','','',0,0,0,0,0,0,0,-1,0,'49',-1,0,0),
    (700217,8,-1,9,2,'Bronkks',0,1,'Execute judgment on Bronkks of Grobb.','344302','','',0,0,0,0,0,0,0,-1,0,'52',-1,0,0),
    (700217,9,-1,10,2,'Scooky Moog',0,1,'Execute judgment on Scooky Moog of Rivervale.','344303','','',0,0,0,0,0,0,0,-1,0,'19',-1,0,0),
    (700217,10,-1,11,2,'Doran Keez',0,1,'Execute judgment on Doran Keez of the Qeynos Hills.','344304','','',0,0,0,0,0,0,0,-1,0,'4',-1,0,0),
-- 700226 The Gift of Life
    (700226,0,-1,1,4,'Avatar of Tunare',0,1,'Accept the seeds from the Avatar of Tunare in Greater Faydark.','344221','','',0,0,0,0,0,0,0,-1,0,'54',-1,0,0),
    (700226,1,-1,2,5,'plant by the Sleeper''s Tomb',0,1,'Plant a treant in the Eastern Wastes behind the Sleeper''s Tomb.',' ','','',0,-7679,-120,-14,-7559,0,66,-1,0,'116',-1,0,0),
    (700226,2,-1,5,5,'plant among the Kolbok',0,1,'Plant a treant in the Stonebrunt Mountains.',' ','','',0,-3303,1199,90,-3183,1319,170,-1,0,'100',-1,0,0),
    (700226,3,-1,4,5,'plant at the brigand camp',0,1,'Plant a treant in Shadeweaver''s Thicket.',' ','','',0,-1120,-1160,-281,-1000,-1040,-201,-1,0,'165',-1,0,0),
    (700226,4,-1,5,5,'plant in a safe corner',0,1,'Plant a treant in the Overthere.',' ','','',0,-3374,3555,215,-3254,3675,295,-1,0,'93',-1,0,0),
    (700226,5,-1,6,5,'plant in the druid valley',0,1,'Plant a treant in the Steamfont Mountains.',' ','','',0,-1136,1431,-99,-1016,1551,-19,-1,0,'56',-1,0,0),
    (700226,6,-1,7,5,'plant near Najena',0,1,'Plant a treant in the Lavastorm Mountains.',' ','','',0,390,-1360,-131,490,-1240,-51,-1,0,'27',-1,0,0),
    (700226,7,-1,8,5,'plant by the explorer tower',0,1,'Plant a treant by the Lake of Ill Omen.',' ','','',0,1850,-180,67,1950,-80,147,-1,0,'85',-1,0,0),
    (700226,8,-1,9,5,'plant by the wizard spires',0,1,'Plant a treant in Nektulos Forest.',' ','','',0,405,-820,-3,505,-700,77,-1,0,'25',-1,0,0),
    (700226,9,-1,10,5,'plant by the lake',0,1,'Plant a treant in Kithicor Forest.',' ','','',0,-65,-450,-64,55,-330,16,-1,0,'20',-1,0,0),
    (700226,10,-1,11,5,'plant by the druid rings',0,1,'Plant a treant by the Rathe Mountains druid rings.',' ','','',0,5350,700,-17,5470,820,63,-1,0,'50',-1,0,0),
    (700226,11,-1,12,4,'Avatar of Tunare',0,1,'Return to the Avatar of Tunare.','344221','','',0,0,0,0,0,0,0,-1,0,'54',-1,0,0),
-- 700235 Memory in Crystal (trivia answers are quest-driven: the avatar
-- script calls UpdateTaskActivity on each correct answer)
    (700235,0,-1,1,4,'a crystalline avatar',0,1,'Take the challenge of the crystalline avatar in the Plane of Knowledge.','344215','','',0,0,0,0,0,0,0,-1,0,'202',-1,0,0),
    (700235,1,-1,2,4,'first answer',2,1,'Answer the first question.','344215','','',0,0,0,0,0,0,0,-1,0,'202',-1,0,0),
    (700235,2,-1,3,4,'second answer',2,1,'Answer the second question.','344215','','',0,0,0,0,0,0,0,-1,0,'202',-1,0,0),
    (700235,3,-1,4,4,'third answer',2,1,'Answer the third question.','344215','','',0,0,0,0,0,0,0,-1,0,'202',-1,0,0),
    (700235,4,-1,5,4,'fourth answer',2,1,'Answer the fourth question.','344215','','',0,0,0,0,0,0,0,-1,0,'202',-1,0,0),
    (700235,5,-1,6,4,'fifth answer',2,1,'Answer the fifth question.','344215','','',0,0,0,0,0,0,0,-1,0,'202',-1,0,0);
