-- Beastlord warder race rework: lore-accurate pet forms per race.
-- Twin content of manifest entry '20260930_beastlord_warder_races' (v90).
-- pets_beastlord_data drives both warder summon appearance (zone/pets.cpp,
-- petnaming == 2) and the Bestial Alignment / Group Bestial Alignment
-- illusion forms (zone/spell_effects.cpp intercept of spells 30738 / 16443).

UPDATE `pets_beastlord_data` SET `pet_race`=83,  `texture`=0, `helm_texture`=0, `gender`=2, `size_modifier`=0.6, `face`=0 WHERE `player_race`=8;    -- Dwarf -> Skunk
UPDATE `pets_beastlord_data` SET `pet_race`=468, `texture`=0, `helm_texture`=0, `gender`=2, `size_modifier`=1.0, `face`=0 WHERE `player_race`=3;   -- Erudite -> Snake (ex-Halfling)
UPDATE `pets_beastlord_data` SET `pet_race`=415, `texture`=0, `helm_texture`=0, `gender`=2, `size_modifier`=0.6, `face`=0 WHERE `player_race`=11;  -- Halfling -> Rat
UPDATE `pets_beastlord_data` SET `pet_race`=244, `texture`=0, `helm_texture`=0, `gender`=2, `size_modifier`=1.0, `face`=0 WHERE `player_race`=4;   -- Wood Elf -> Treant
UPDATE `pets_beastlord_data` SET `pet_race`=416, `texture`=0, `helm_texture`=0, `gender`=2, `size_modifier`=0.6, `face`=0 WHERE `player_race`=7;   -- Half Elf -> Bat
UPDATE `pets_beastlord_data` SET `pet_race`=69,  `texture`=0, `helm_texture`=0, `gender`=2, `size_modifier`=0.6, `face`=0 WHERE `player_race`=5;   -- High Elf -> Wisp
UPDATE `pets_beastlord_data` SET `pet_race`=104, `texture`=0, `helm_texture`=0, `gender`=2, `size_modifier`=0.6, `face`=0 WHERE `player_race`=330; -- Froglok -> Leech
