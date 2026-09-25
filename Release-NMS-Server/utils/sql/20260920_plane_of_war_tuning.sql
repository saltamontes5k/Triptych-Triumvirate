-- Plane of War - Phase 2b: loot assignment, Rolfron Zek fix, missing rares (idempotent).
UPDATE zone SET safe_x=738, safe_y=2484, safe_z=20, safe_heading=280 WHERE zoneidnumber=213;
UPDATE npc_types SET loottable_id=6130 WHERE id=1520001001;
UPDATE npc_types SET loottable_id=6129 WHERE id=1520001002;
UPDATE npc_types SET loottable_id=6127 WHERE id=1520001003;
UPDATE npc_types SET loottable_id=6130 WHERE id=1520001004;
UPDATE npc_types SET loottable_id=6135 WHERE id=1520001005;
UPDATE npc_types SET loottable_id=6135 WHERE id=1520001006;
UPDATE npc_types SET loottable_id=4092 WHERE id=1520001007;
UPDATE npc_types SET loottable_id=7490 WHERE id=1520001008;
UPDATE npc_types SET loottable_id=7490 WHERE id=1520001009;
UPDATE npc_types SET loottable_id=101937 WHERE id=1520001010;
UPDATE npc_types SET loottable_id=101937 WHERE id=1520001011;
UPDATE npc_types SET loottable_id=101944 WHERE id=1520001012;
UPDATE npc_types SET loottable_id=6131 WHERE id=1520001013;
UPDATE npc_types SET loottable_id=6131 WHERE id=1520001014;
UPDATE npc_types SET loottable_id=7518 WHERE id=1520001015;
UPDATE npc_types SET loottable_id=6137 WHERE id=1520001016;
UPDATE npc_types SET loottable_id=6140 WHERE id=1520001017;
UPDATE npc_types SET loottable_id=3007 WHERE id=1520001201;
UPDATE npc_types SET loottable_id=3007 WHERE id=1520001202;
UPDATE npc_types SET loottable_id=3239 WHERE id=1520001203;
UPDATE npc_types SET loottable_id=101965 WHERE id=1520001204;
UPDATE npc_types SET loottable_id=3239 WHERE id=1520001205;
UPDATE npc_types SET loottable_id=101972 WHERE id=1520001206;
UPDATE npc_types SET loottable_id=6192 WHERE id=1520001207;
UPDATE npc_types SET loottable_id=6192 WHERE id=1520001208;
UPDATE npc_types SET loottable_id=2083 WHERE id=1520001209;
UPDATE npc_types SET loottable_id=101965 WHERE id=1520001210;
UPDATE npc_types SET race=48, bodytype=1, level=68, hp=68040, mindmg=261, maxdmg=850, AC=188, loottable_id=3239 WHERE id=1520001205;
INSERT IGNORE INTO npc_types (id,name,lastname,level,hp,mana,race,class,bodytype,gender,size,npc_faction_id,mindmg,maxdmg,attack_delay,runspeed,AC,see_invis,findable,trackable,show_name,texture,loottable_id,npc_spells_id,merchant_id) VALUES
(1520001301,'The_Judicator','',70,250000,0,10,1,1,2,30,79,250,900,30,1.25,356,1,0,1,1,0,3007,0,0),
(1520001302,'a_Zekarian_colossus','',68,60000,0,10,1,1,0,40,79,184,735,30,1.25,188,1,0,1,1,0,6140,0,0),
(1520001303,'Jergamund_the_Slaver','',66,40000,0,10,1,1,0,20,79,160,640,30,1.25,186,1,0,1,1,0,101937,0,0),
(1520001304,'a_guardian_of_Narikor','',66,40000,0,10,1,1,0,20,79,160,640,30,1.25,186,1,0,1,1,0,101972,0,0),
(1520001305,'a_Decorin_taskmaster','',66,38000,0,325,1,19,2,20,79,160,640,30,1.25,186,1,0,1,1,0,101972,0,0),
(1520001306,'a_greedy_miner','',64,30000,0,10,1,1,0,20,79,140,560,30,1.25,184,0,0,1,1,0,6127,0,0),
(1520001307,'a_mindless_miner','',63,26000,0,10,1,1,0,20,79,133,532,30,1.25,183,0,0,1,1,0,6127,0,0),
(1520001308,'Araneae_the_Clever','',68,60000,0,10,1,1,2,24,79,184,735,30,1.25,188,1,0,1,1,0,3007,0,0),
(1520001309,'a_Rulnavian_machinist','',66,36000,0,10,1,1,0,20,79,160,640,30,1.25,186,1,0,1,1,0,6135,0,0),
(1520001310,'a_golem_smith','',67,40000,0,10,1,1,0,20,79,170,660,30,1.25,187,1,0,1,1,0,6140,0,0),
(1520001311,'a_Tamrelian_spy','',66,36000,0,1,9,1,2,20,79,160,640,30,1.25,186,1,0,1,1,0,6135,0,0),
(1520001312,'a_Tamrelian_wall_defender','',67,40000,0,1,1,1,0,20,79,170,660,30,1.25,187,1,0,1,1,0,6135,0,0),
(1520001313,'Tallon_Zek','',73,550000,0,290,1,19,2,25,79,233,907,30,1.25,365,1,0,1,1,0,2083,0,0),
(1520001314,'Vallon_Zek','',73,85000,0,289,1,19,2,25,79,228,893,30,1.25,365,1,0,1,1,0,104951,0,0);
INSERT IGNORE INTO spawngroup (id,name) VALUES
(1520004001,'powar_The_Judicator'),
(1520004002,'powar_a_Zekarian_colossus'),
(1520004003,'powar_Jergamund_the_Slaver'),
(1520004004,'powar_a_guardian_of_Narikor'),
(1520004005,'powar_a_Decorin_taskmaster'),
(1520004006,'powar_a_greedy_miner'),
(1520004007,'powar_a_mindless_miner'),
(1520004008,'powar_Araneae_the_Clever'),
(1520004009,'powar_a_Rulnavian_machinist'),
(1520004010,'powar_a_golem_smith'),
(1520004011,'powar_a_Tamrelian_spy'),
(1520004012,'powar_a_Tamrelian_wall_defender'),
(1520004013,'powar_Tallon_Zek'),
(1520004014,'powar_Vallon_Zek');
INSERT IGNORE INTO spawnentry (spawngroupID,npcID,chance,condition_value_filter,min_time,max_time) VALUES
(1520004001,1520001301,100,1,0,0),
(1520004002,1520001302,100,1,0,0),
(1520004003,1520001303,100,1,0,0),
(1520004004,1520001304,100,1,0,0),
(1520004005,1520001305,100,1,0,0),
(1520004006,1520001306,100,1,0,0),
(1520004007,1520001307,100,1,0,0),
(1520004008,1520001308,100,1,0,0),
(1520004009,1520001309,100,1,0,0),
(1520004010,1520001310,100,1,0,0),
(1520004011,1520001311,100,1,0,0),
(1520004012,1520001312,100,1,0,0),
(1520004013,1520001313,100,1,0,0),
(1520004014,1520001314,100,1,0,0);
INSERT IGNORE INTO spawn2 (id,spawngroupID,zone,version,x,y,z,heading,respawntime,variance,pathgrid) VALUES
(1520005001,1520004001,'powar',0,-34,-972,-2,0,640,0,0),
(1520005002,1520004002,'powar',0,-71,1487,-2,0,640,0,0),
(1520005003,1520004003,'powar',0,-247,-3054,-102,0,640,0,0),
(1520005004,1520004004,'powar',0,-247,-3004,-102,0,640,0,0),
(1520005005,1520004005,'powar',0,-247,-3104,-102,0,640,0,0),
(1520005006,1520004006,'powar',0,-297,-3054,-102,0,640,0,0),
(1520005007,1520004007,'powar',0,-197,-3054,-102,0,640,0,0),
(1520005008,1520004008,'powar',0,1125,-786,-8,0,640,0,0),
(1520005009,1520004009,'powar',0,1085,-786,-8,0,640,0,0),
(1520005010,1520004010,'powar',0,1165,-786,-8,0,640,0,0),
(1520005011,1520004011,'powar',0,-1252,-1545,20,0,640,0,0),
(1520005012,1520004012,'powar',0,-1212,-1545,20,0,640,0,0),
(1520005013,1520004013,'powar',0,-20,-4400,0,0,640,0,0),
(1520005014,1520004014,'powar',0,20,-4400,0,0,640,0,0);
