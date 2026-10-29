-- Blightfire parent achievement gear; install complete upgrade with game services stopped.
SET NAMES utf8mb4;
SET SESSION check_constraint_checks=1;
DROP TEMPORARY TABLE IF EXISTS _blight_parent_guard;
CREATE TEMPORARY TABLE _blight_parent_guard(label VARCHAR(80)PRIMARY KEY,ok TINYINT NOT NULL,CHECK(ok=1))ENGINE=InnoDB;
INSERT INTO _blight_parent_guard VALUES('items',((SELECT COUNT(*)FROM items WHERE (id=108064 AND Name='Rough Consigned Plate Helm' AND classes=151) OR (id=108071 AND Name='Rough Consigned Chain Coif' AND classes=33544) OR (id=108078 AND Name='Rough Consigned Leather Cap' AND classes=16480) OR (id=108085 AND Name='Rough Consigned Cloth Cap' AND classes=15360) OR (id=108551 AND Name='Rough Consigned Chitin Shield' AND classes=16861) OR (id=108552 AND Name='Rough Consigned Round Shield' AND classes=15906) OR (id=108541 AND Name='Rough Consigned Scepter' AND classes=15906) OR (id=108550 AND Name='Rough Consigned Bow' AND classes=285) OR (id=108540 AND Name='Rough Consigned Hammer' AND classes=16861) OR (id=108543 AND Name='Rough Consigned Longsword' AND classes=413) OR (id=108542 AND Name='Rough Consigned Shortsword' AND classes=413) OR (id=108544 AND Name='Rough Consigned Stone Dagger' AND classes=16793) OR (id=108549 AND Name='Rough Consigned Halberd' AND classes=32797) OR (id=108063 AND Name='Rough Consigned Plate Boots' AND classes=151) OR (id=108070 AND Name='Rough Consigned Chain Boots' AND classes=33544) OR (id=108077 AND Name='Rough Consigned Leather Boots' AND classes=16480) OR (id=108084 AND Name='Rough Consigned Cloth Sandals' AND classes=15360) OR (id=108342 AND Name='Rough Soldier''s Facemask' AND classes=49629) OR (id=108352 AND Name='Rough Scryer''s Facemask' AND classes=15906) OR (id=108343 AND Name='Rough Soldier''s Gorget' AND classes=49629) OR (id=108353 AND Name='Rough Scryer''s Necklace' AND classes=15906) OR (id=108345 AND Name='Rough Soldier''s Cloak' AND classes=49629) OR (id=108355 AND Name='Rough Scryer''s Cloak' AND classes=15906) OR (id=108344 AND Name='Rough Soldier''s Mantle' AND classes=49629) OR (id=108354 AND Name='Rough Scryer''s Scarf' AND classes=15906) OR (id=108346 AND Name='Rough Soldier''s Stake' AND classes=49629) OR (id=108356 AND Name='Rough Scryer''s Wand' AND classes=15906))=27));
INSERT INTO _blight_parent_guard VALUES('achievement_500020200',((SELECT COUNT(*)FROM achievements WHERE id=500020200 AND name='Welcome to the Moors (21-25)' AND enabled=1 AND has_reward=1)=1));
INSERT INTO _blight_parent_guard VALUES('source_500020200',(NOT EXISTS(SELECT 1 FROM reward_sources WHERE(source_type=1 AND source_id=500020200 AND reward_set_id<>3050202)OR(reward_set_id=3050202 AND NOT(source_type=1 AND source_id=500020200)))));
INSERT INTO _blight_parent_guard VALUES('set_3050202',(NOT EXISTS(SELECT 1 FROM reward_sets WHERE reward_set_id=3050202 AND title<>'Welcome to the Moors (21-25)')));
INSERT INTO _blight_parent_guard VALUES('reward_305020201',(NOT EXISTS(SELECT 1 FROM rewards WHERE reward_id=305020201 AND NOT(reward_type=0 AND reward_data_id=108064 AND amount=1 AND description='May2013 Blightfire parent 500020200 item 108064'))AND NOT EXISTS(SELECT 1 FROM reward_option_entries WHERE reward_id=305020201 AND NOT(reward_set_id=3050202 AND option_id=1))AND NOT EXISTS(SELECT 1 FROM reward_source_entries WHERE reward_id=305020201)));
INSERT INTO _blight_parent_guard VALUES('reward_305020202',(NOT EXISTS(SELECT 1 FROM rewards WHERE reward_id=305020202 AND NOT(reward_type=0 AND reward_data_id=108071 AND amount=1 AND description='May2013 Blightfire parent 500020200 item 108071'))AND NOT EXISTS(SELECT 1 FROM reward_option_entries WHERE reward_id=305020202 AND NOT(reward_set_id=3050202 AND option_id=2))AND NOT EXISTS(SELECT 1 FROM reward_source_entries WHERE reward_id=305020202)));
INSERT INTO _blight_parent_guard VALUES('reward_305020203',(NOT EXISTS(SELECT 1 FROM rewards WHERE reward_id=305020203 AND NOT(reward_type=0 AND reward_data_id=108078 AND amount=1 AND description='May2013 Blightfire parent 500020200 item 108078'))AND NOT EXISTS(SELECT 1 FROM reward_option_entries WHERE reward_id=305020203 AND NOT(reward_set_id=3050202 AND option_id=3))AND NOT EXISTS(SELECT 1 FROM reward_source_entries WHERE reward_id=305020203)));
INSERT INTO _blight_parent_guard VALUES('reward_305020204',(NOT EXISTS(SELECT 1 FROM rewards WHERE reward_id=305020204 AND NOT(reward_type=0 AND reward_data_id=108085 AND amount=1 AND description='May2013 Blightfire parent 500020200 item 108085'))AND NOT EXISTS(SELECT 1 FROM reward_option_entries WHERE reward_id=305020204 AND NOT(reward_set_id=3050202 AND option_id=4))AND NOT EXISTS(SELECT 1 FROM reward_source_entries WHERE reward_id=305020204)));
INSERT INTO _blight_parent_guard VALUES('achievement_500020300',((SELECT COUNT(*)FROM achievements WHERE id=500020300 AND name='Battling Blightfire (26-30)' AND enabled=1 AND has_reward=1)=1));
INSERT INTO _blight_parent_guard VALUES('source_500020300',(NOT EXISTS(SELECT 1 FROM reward_sources WHERE(source_type=1 AND source_id=500020300 AND reward_set_id<>3050203)OR(reward_set_id=3050203 AND NOT(source_type=1 AND source_id=500020300)))));
INSERT INTO _blight_parent_guard VALUES('set_3050203',(NOT EXISTS(SELECT 1 FROM reward_sets WHERE reward_set_id=3050203 AND title<>'Battling Blightfire (26-30)')));
INSERT INTO _blight_parent_guard VALUES('reward_305020301',(NOT EXISTS(SELECT 1 FROM rewards WHERE reward_id=305020301 AND NOT(reward_type=0 AND reward_data_id=108551 AND amount=1 AND description='May2013 Blightfire parent 500020300 item 108551'))AND NOT EXISTS(SELECT 1 FROM reward_option_entries WHERE reward_id=305020301 AND NOT(reward_set_id=3050203 AND option_id=1))AND NOT EXISTS(SELECT 1 FROM reward_source_entries WHERE reward_id=305020301)));
INSERT INTO _blight_parent_guard VALUES('reward_305020302',(NOT EXISTS(SELECT 1 FROM rewards WHERE reward_id=305020302 AND NOT(reward_type=0 AND reward_data_id=108552 AND amount=1 AND description='May2013 Blightfire parent 500020300 item 108552'))AND NOT EXISTS(SELECT 1 FROM reward_option_entries WHERE reward_id=305020302 AND NOT(reward_set_id=3050203 AND option_id=2))AND NOT EXISTS(SELECT 1 FROM reward_source_entries WHERE reward_id=305020302)));
INSERT INTO _blight_parent_guard VALUES('reward_305020303',(NOT EXISTS(SELECT 1 FROM rewards WHERE reward_id=305020303 AND NOT(reward_type=0 AND reward_data_id=108541 AND amount=1 AND description='May2013 Blightfire parent 500020300 item 108541'))AND NOT EXISTS(SELECT 1 FROM reward_option_entries WHERE reward_id=305020303 AND NOT(reward_set_id=3050203 AND option_id=2))AND NOT EXISTS(SELECT 1 FROM reward_source_entries WHERE reward_id=305020303)));
INSERT INTO _blight_parent_guard VALUES('reward_305020304',(NOT EXISTS(SELECT 1 FROM rewards WHERE reward_id=305020304 AND NOT(reward_type=0 AND reward_data_id=108550 AND amount=1 AND description='May2013 Blightfire parent 500020300 item 108550'))AND NOT EXISTS(SELECT 1 FROM reward_option_entries WHERE reward_id=305020304 AND NOT(reward_set_id=3050203 AND option_id=3))AND NOT EXISTS(SELECT 1 FROM reward_source_entries WHERE reward_id=305020304)));
INSERT INTO _blight_parent_guard VALUES('reward_305020305',(NOT EXISTS(SELECT 1 FROM rewards WHERE reward_id=305020305 AND NOT(reward_type=0 AND reward_data_id=108540 AND amount=1 AND description='May2013 Blightfire parent 500020300 item 108540'))AND NOT EXISTS(SELECT 1 FROM reward_option_entries WHERE reward_id=305020305 AND NOT(reward_set_id=3050203 AND option_id=4))AND NOT EXISTS(SELECT 1 FROM reward_source_entries WHERE reward_id=305020305)));
INSERT INTO _blight_parent_guard VALUES('reward_305020306',(NOT EXISTS(SELECT 1 FROM rewards WHERE reward_id=305020306 AND NOT(reward_type=0 AND reward_data_id=108543 AND amount=1 AND description='May2013 Blightfire parent 500020300 item 108543'))AND NOT EXISTS(SELECT 1 FROM reward_option_entries WHERE reward_id=305020306 AND NOT(reward_set_id=3050203 AND option_id=5))AND NOT EXISTS(SELECT 1 FROM reward_source_entries WHERE reward_id=305020306)));
INSERT INTO _blight_parent_guard VALUES('reward_305020307',(NOT EXISTS(SELECT 1 FROM rewards WHERE reward_id=305020307 AND NOT(reward_type=0 AND reward_data_id=108542 AND amount=1 AND description='May2013 Blightfire parent 500020300 item 108542'))AND NOT EXISTS(SELECT 1 FROM reward_option_entries WHERE reward_id=305020307 AND NOT(reward_set_id=3050203 AND option_id=6))AND NOT EXISTS(SELECT 1 FROM reward_source_entries WHERE reward_id=305020307)));
INSERT INTO _blight_parent_guard VALUES('reward_305020308',(NOT EXISTS(SELECT 1 FROM rewards WHERE reward_id=305020308 AND NOT(reward_type=0 AND reward_data_id=108544 AND amount=1 AND description='May2013 Blightfire parent 500020300 item 108544'))AND NOT EXISTS(SELECT 1 FROM reward_option_entries WHERE reward_id=305020308 AND NOT(reward_set_id=3050203 AND option_id=7))AND NOT EXISTS(SELECT 1 FROM reward_source_entries WHERE reward_id=305020308)));
INSERT INTO _blight_parent_guard VALUES('reward_305020309',(NOT EXISTS(SELECT 1 FROM rewards WHERE reward_id=305020309 AND NOT(reward_type=0 AND reward_data_id=108549 AND amount=1 AND description='May2013 Blightfire parent 500020300 item 108549'))AND NOT EXISTS(SELECT 1 FROM reward_option_entries WHERE reward_id=305020309 AND NOT(reward_set_id=3050203 AND option_id=8))AND NOT EXISTS(SELECT 1 FROM reward_source_entries WHERE reward_id=305020309)));
INSERT INTO _blight_parent_guard VALUES('achievement_500020400',((SELECT COUNT(*)FROM achievements WHERE id=500020400 AND name='Champion of the Moors (31-35)' AND enabled=1 AND has_reward=1)=1));
INSERT INTO _blight_parent_guard VALUES('source_500020400',(NOT EXISTS(SELECT 1 FROM reward_sources WHERE(source_type=1 AND source_id=500020400 AND reward_set_id<>3050204)OR(reward_set_id=3050204 AND NOT(source_type=1 AND source_id=500020400)))));
INSERT INTO _blight_parent_guard VALUES('set_3050204',(NOT EXISTS(SELECT 1 FROM reward_sets WHERE reward_set_id=3050204 AND title<>'Champion of the Moors (31-35)')));
INSERT INTO _blight_parent_guard VALUES('reward_305020401',(NOT EXISTS(SELECT 1 FROM rewards WHERE reward_id=305020401 AND NOT(reward_type=0 AND reward_data_id=108063 AND amount=1 AND description='May2013 Blightfire parent 500020400 item 108063'))AND NOT EXISTS(SELECT 1 FROM reward_option_entries WHERE reward_id=305020401 AND NOT(reward_set_id=3050204 AND option_id=1))AND NOT EXISTS(SELECT 1 FROM reward_source_entries WHERE reward_id=305020401)));
INSERT INTO _blight_parent_guard VALUES('reward_305020402',(NOT EXISTS(SELECT 1 FROM rewards WHERE reward_id=305020402 AND NOT(reward_type=0 AND reward_data_id=108070 AND amount=1 AND description='May2013 Blightfire parent 500020400 item 108070'))AND NOT EXISTS(SELECT 1 FROM reward_option_entries WHERE reward_id=305020402 AND NOT(reward_set_id=3050204 AND option_id=2))AND NOT EXISTS(SELECT 1 FROM reward_source_entries WHERE reward_id=305020402)));
INSERT INTO _blight_parent_guard VALUES('reward_305020403',(NOT EXISTS(SELECT 1 FROM rewards WHERE reward_id=305020403 AND NOT(reward_type=0 AND reward_data_id=108077 AND amount=1 AND description='May2013 Blightfire parent 500020400 item 108077'))AND NOT EXISTS(SELECT 1 FROM reward_option_entries WHERE reward_id=305020403 AND NOT(reward_set_id=3050204 AND option_id=3))AND NOT EXISTS(SELECT 1 FROM reward_source_entries WHERE reward_id=305020403)));
INSERT INTO _blight_parent_guard VALUES('reward_305020404',(NOT EXISTS(SELECT 1 FROM rewards WHERE reward_id=305020404 AND NOT(reward_type=0 AND reward_data_id=108084 AND amount=1 AND description='May2013 Blightfire parent 500020400 item 108084'))AND NOT EXISTS(SELECT 1 FROM reward_option_entries WHERE reward_id=305020404 AND NOT(reward_set_id=3050204 AND option_id=4))AND NOT EXISTS(SELECT 1 FROM reward_source_entries WHERE reward_id=305020404)));
INSERT INTO _blight_parent_guard VALUES('achievement_500020500',((SELECT COUNT(*)FROM achievements WHERE id=500020500 AND name='Job Offers (Blightfire 20+)' AND enabled=1 AND has_reward=1)=1));
INSERT INTO _blight_parent_guard VALUES('source_500020500',(NOT EXISTS(SELECT 1 FROM reward_sources WHERE(source_type=1 AND source_id=500020500 AND reward_set_id<>3050205)OR(reward_set_id=3050205 AND NOT(source_type=1 AND source_id=500020500)))));
INSERT INTO _blight_parent_guard VALUES('set_3050205',(NOT EXISTS(SELECT 1 FROM reward_sets WHERE reward_set_id=3050205 AND title<>'Job Offers (Blightfire 20+)')));
INSERT INTO _blight_parent_guard VALUES('reward_305020501',(NOT EXISTS(SELECT 1 FROM rewards WHERE reward_id=305020501 AND NOT(reward_type=0 AND reward_data_id=108342 AND amount=1 AND description='May2013 Blightfire parent 500020500 item 108342'))AND NOT EXISTS(SELECT 1 FROM reward_option_entries WHERE reward_id=305020501 AND NOT(reward_set_id=3050205 AND option_id=1))AND NOT EXISTS(SELECT 1 FROM reward_source_entries WHERE reward_id=305020501)));
INSERT INTO _blight_parent_guard VALUES('reward_305020502',(NOT EXISTS(SELECT 1 FROM rewards WHERE reward_id=305020502 AND NOT(reward_type=0 AND reward_data_id=108352 AND amount=1 AND description='May2013 Blightfire parent 500020500 item 108352'))AND NOT EXISTS(SELECT 1 FROM reward_option_entries WHERE reward_id=305020502 AND NOT(reward_set_id=3050205 AND option_id=2))AND NOT EXISTS(SELECT 1 FROM reward_source_entries WHERE reward_id=305020502)));
INSERT INTO _blight_parent_guard VALUES('achievement_500020600',((SELECT COUNT(*)FROM achievements WHERE id=500020600 AND name='Two Gnolls With One Stone (Blightfire 20+)' AND enabled=1 AND has_reward=1)=1));
INSERT INTO _blight_parent_guard VALUES('source_500020600',(NOT EXISTS(SELECT 1 FROM reward_sources WHERE(source_type=1 AND source_id=500020600 AND reward_set_id<>3050206)OR(reward_set_id=3050206 AND NOT(source_type=1 AND source_id=500020600)))));
INSERT INTO _blight_parent_guard VALUES('set_3050206',(NOT EXISTS(SELECT 1 FROM reward_sets WHERE reward_set_id=3050206 AND title<>'Two Gnolls With One Stone (Blightfire 20+)')));
INSERT INTO _blight_parent_guard VALUES('reward_305020601',(NOT EXISTS(SELECT 1 FROM rewards WHERE reward_id=305020601 AND NOT(reward_type=0 AND reward_data_id=108343 AND amount=1 AND description='May2013 Blightfire parent 500020600 item 108343'))AND NOT EXISTS(SELECT 1 FROM reward_option_entries WHERE reward_id=305020601 AND NOT(reward_set_id=3050206 AND option_id=1))AND NOT EXISTS(SELECT 1 FROM reward_source_entries WHERE reward_id=305020601)));
INSERT INTO _blight_parent_guard VALUES('reward_305020602',(NOT EXISTS(SELECT 1 FROM rewards WHERE reward_id=305020602 AND NOT(reward_type=0 AND reward_data_id=108353 AND amount=1 AND description='May2013 Blightfire parent 500020600 item 108353'))AND NOT EXISTS(SELECT 1 FROM reward_option_entries WHERE reward_id=305020602 AND NOT(reward_set_id=3050206 AND option_id=2))AND NOT EXISTS(SELECT 1 FROM reward_source_entries WHERE reward_id=305020602)));
INSERT INTO _blight_parent_guard VALUES('achievement_500020700',((SELECT COUNT(*)FROM achievements WHERE id=500020700 AND name='Stemming the Threat (Blightfire 20+)' AND enabled=1 AND has_reward=1)=1));
INSERT INTO _blight_parent_guard VALUES('source_500020700',(NOT EXISTS(SELECT 1 FROM reward_sources WHERE(source_type=1 AND source_id=500020700 AND reward_set_id<>3050207)OR(reward_set_id=3050207 AND NOT(source_type=1 AND source_id=500020700)))));
INSERT INTO _blight_parent_guard VALUES('set_3050207',(NOT EXISTS(SELECT 1 FROM reward_sets WHERE reward_set_id=3050207 AND title<>'Stemming the Threat (Blightfire 20+)')));
INSERT INTO _blight_parent_guard VALUES('reward_305020701',(NOT EXISTS(SELECT 1 FROM rewards WHERE reward_id=305020701 AND NOT(reward_type=0 AND reward_data_id=108345 AND amount=1 AND description='May2013 Blightfire parent 500020700 item 108345'))AND NOT EXISTS(SELECT 1 FROM reward_option_entries WHERE reward_id=305020701 AND NOT(reward_set_id=3050207 AND option_id=1))AND NOT EXISTS(SELECT 1 FROM reward_source_entries WHERE reward_id=305020701)));
INSERT INTO _blight_parent_guard VALUES('reward_305020702',(NOT EXISTS(SELECT 1 FROM rewards WHERE reward_id=305020702 AND NOT(reward_type=0 AND reward_data_id=108355 AND amount=1 AND description='May2013 Blightfire parent 500020700 item 108355'))AND NOT EXISTS(SELECT 1 FROM reward_option_entries WHERE reward_id=305020702 AND NOT(reward_set_id=3050207 AND option_id=2))AND NOT EXISTS(SELECT 1 FROM reward_source_entries WHERE reward_id=305020702)));
INSERT INTO _blight_parent_guard VALUES('achievement_500020800',((SELECT COUNT(*)FROM achievements WHERE id=500020800 AND name='Battling the Bixies (Blightfire 30+)' AND enabled=1 AND has_reward=1)=1));
INSERT INTO _blight_parent_guard VALUES('source_500020800',(NOT EXISTS(SELECT 1 FROM reward_sources WHERE(source_type=1 AND source_id=500020800 AND reward_set_id<>3050208)OR(reward_set_id=3050208 AND NOT(source_type=1 AND source_id=500020800)))));
INSERT INTO _blight_parent_guard VALUES('set_3050208',(NOT EXISTS(SELECT 1 FROM reward_sets WHERE reward_set_id=3050208 AND title<>'Battling the Bixies (Blightfire 30+)')));
INSERT INTO _blight_parent_guard VALUES('reward_305020801',(NOT EXISTS(SELECT 1 FROM rewards WHERE reward_id=305020801 AND NOT(reward_type=0 AND reward_data_id=108344 AND amount=1 AND description='May2013 Blightfire parent 500020800 item 108344'))AND NOT EXISTS(SELECT 1 FROM reward_option_entries WHERE reward_id=305020801 AND NOT(reward_set_id=3050208 AND option_id=1))AND NOT EXISTS(SELECT 1 FROM reward_source_entries WHERE reward_id=305020801)));
INSERT INTO _blight_parent_guard VALUES('reward_305020802',(NOT EXISTS(SELECT 1 FROM rewards WHERE reward_id=305020802 AND NOT(reward_type=0 AND reward_data_id=108354 AND amount=1 AND description='May2013 Blightfire parent 500020800 item 108354'))AND NOT EXISTS(SELECT 1 FROM reward_option_entries WHERE reward_id=305020802 AND NOT(reward_set_id=3050208 AND option_id=2))AND NOT EXISTS(SELECT 1 FROM reward_source_entries WHERE reward_id=305020802)));
INSERT INTO _blight_parent_guard VALUES('achievement_500020900',((SELECT COUNT(*)FROM achievements WHERE id=500020900 AND name='Makesn''s Plight (Blightfire 30+)' AND enabled=1 AND has_reward=1)=1));
INSERT INTO _blight_parent_guard VALUES('source_500020900',(NOT EXISTS(SELECT 1 FROM reward_sources WHERE(source_type=1 AND source_id=500020900 AND reward_set_id<>3050209)OR(reward_set_id=3050209 AND NOT(source_type=1 AND source_id=500020900)))));
INSERT INTO _blight_parent_guard VALUES('set_3050209',(NOT EXISTS(SELECT 1 FROM reward_sets WHERE reward_set_id=3050209 AND title<>'Makesn''s Plight (Blightfire 30+)')));
INSERT INTO _blight_parent_guard VALUES('reward_305020901',(NOT EXISTS(SELECT 1 FROM rewards WHERE reward_id=305020901 AND NOT(reward_type=0 AND reward_data_id=108346 AND amount=1 AND description='May2013 Blightfire parent 500020900 item 108346'))AND NOT EXISTS(SELECT 1 FROM reward_option_entries WHERE reward_id=305020901 AND NOT(reward_set_id=3050209 AND option_id=1))AND NOT EXISTS(SELECT 1 FROM reward_source_entries WHERE reward_id=305020901)));
INSERT INTO _blight_parent_guard VALUES('reward_305020902',(NOT EXISTS(SELECT 1 FROM rewards WHERE reward_id=305020902 AND NOT(reward_type=0 AND reward_data_id=108356 AND amount=1 AND description='May2013 Blightfire parent 500020900 item 108356'))AND NOT EXISTS(SELECT 1 FROM reward_option_entries WHERE reward_id=305020902 AND NOT(reward_set_id=3050209 AND option_id=2))AND NOT EXISTS(SELECT 1 FROM reward_source_entries WHERE reward_id=305020902)));
INSERT INTO _blight_parent_guard VALUES('options_3050202',(NOT EXISTS(SELECT 1 FROM reward_options WHERE reward_set_id=3050202 AND NOT((`reward_set_id` <=> 3050202 AND `option_id` <=> 1 AND `sequence` <=> 1 AND `label` <=> 'Rough Consigned Plate Helm' AND `common_to_all` <=> 0 AND `flags` <=> 0 AND `enabled` <=> 1 AND `class_mask` <=> 151) OR (`reward_set_id` <=> 3050202 AND `option_id` <=> 2 AND `sequence` <=> 2 AND `label` <=> 'Rough Consigned Chain Coif' AND `common_to_all` <=> 0 AND `flags` <=> 0 AND `enabled` <=> 1 AND `class_mask` <=> 33544) OR (`reward_set_id` <=> 3050202 AND `option_id` <=> 3 AND `sequence` <=> 3 AND `label` <=> 'Rough Consigned Leather Cap' AND `common_to_all` <=> 0 AND `flags` <=> 0 AND `enabled` <=> 1 AND `class_mask` <=> 16480) OR (`reward_set_id` <=> 3050202 AND `option_id` <=> 4 AND `sequence` <=> 4 AND `label` <=> 'Rough Consigned Cloth Cap' AND `common_to_all` <=> 0 AND `flags` <=> 0 AND `enabled` <=> 1 AND `class_mask` <=> 15360)))));
INSERT INTO _blight_parent_guard VALUES('entries_3050202',(NOT EXISTS(SELECT 1 FROM reward_option_entries WHERE reward_set_id=3050202 AND NOT((`reward_set_id` <=> 3050202 AND `option_id` <=> 1 AND `sequence` <=> 0 AND `reward_id` <=> 305020201) OR (`reward_set_id` <=> 3050202 AND `option_id` <=> 2 AND `sequence` <=> 0 AND `reward_id` <=> 305020202) OR (`reward_set_id` <=> 3050202 AND `option_id` <=> 3 AND `sequence` <=> 0 AND `reward_id` <=> 305020203) OR (`reward_set_id` <=> 3050202 AND `option_id` <=> 4 AND `sequence` <=> 0 AND `reward_id` <=> 305020204)))));
INSERT INTO _blight_parent_guard VALUES('options_3050203',(NOT EXISTS(SELECT 1 FROM reward_options WHERE reward_set_id=3050203 AND NOT((`reward_set_id` <=> 3050203 AND `option_id` <=> 1 AND `sequence` <=> 1 AND `label` <=> 'Melee shield' AND `common_to_all` <=> 1 AND `flags` <=> 0 AND `enabled` <=> 1 AND `class_mask` <=> 16861) OR (`reward_set_id` <=> 3050203 AND `option_id` <=> 2 AND `sequence` <=> 2 AND `label` <=> 'Caster shield and scepter' AND `common_to_all` <=> 1 AND `flags` <=> 0 AND `enabled` <=> 1 AND `class_mask` <=> 15906) OR (`reward_set_id` <=> 3050203 AND `option_id` <=> 3 AND `sequence` <=> 3 AND `label` <=> 'Rough Consigned Bow' AND `common_to_all` <=> 0 AND `flags` <=> 0 AND `enabled` <=> 1 AND `class_mask` <=> 285) OR (`reward_set_id` <=> 3050203 AND `option_id` <=> 4 AND `sequence` <=> 4 AND `label` <=> 'Rough Consigned Hammer' AND `common_to_all` <=> 0 AND `flags` <=> 0 AND `enabled` <=> 1 AND `class_mask` <=> 16861) OR (`reward_set_id` <=> 3050203 AND `option_id` <=> 5 AND `sequence` <=> 5 AND `label` <=> 'Rough Consigned Longsword' AND `common_to_all` <=> 0 AND `flags` <=> 0 AND `enabled` <=> 1 AND `class_mask` <=> 413) OR (`reward_set_id` <=> 3050203 AND `option_id` <=> 6 AND `sequence` <=> 6 AND `label` <=> 'Rough Consigned Shortsword' AND `common_to_all` <=> 0 AND `flags` <=> 0 AND `enabled` <=> 1 AND `class_mask` <=> 413) OR (`reward_set_id` <=> 3050203 AND `option_id` <=> 7 AND `sequence` <=> 7 AND `label` <=> 'Rough Consigned Stone Dagger' AND `common_to_all` <=> 0 AND `flags` <=> 0 AND `enabled` <=> 1 AND `class_mask` <=> 16793) OR (`reward_set_id` <=> 3050203 AND `option_id` <=> 8 AND `sequence` <=> 8 AND `label` <=> 'Rough Consigned Halberd' AND `common_to_all` <=> 0 AND `flags` <=> 0 AND `enabled` <=> 1 AND `class_mask` <=> 32797)))));
INSERT INTO _blight_parent_guard VALUES('entries_3050203',(NOT EXISTS(SELECT 1 FROM reward_option_entries WHERE reward_set_id=3050203 AND NOT((`reward_set_id` <=> 3050203 AND `option_id` <=> 1 AND `sequence` <=> 0 AND `reward_id` <=> 305020301) OR (`reward_set_id` <=> 3050203 AND `option_id` <=> 2 AND `sequence` <=> 0 AND `reward_id` <=> 305020302) OR (`reward_set_id` <=> 3050203 AND `option_id` <=> 2 AND `sequence` <=> 1 AND `reward_id` <=> 305020303) OR (`reward_set_id` <=> 3050203 AND `option_id` <=> 3 AND `sequence` <=> 0 AND `reward_id` <=> 305020304) OR (`reward_set_id` <=> 3050203 AND `option_id` <=> 4 AND `sequence` <=> 0 AND `reward_id` <=> 305020305) OR (`reward_set_id` <=> 3050203 AND `option_id` <=> 5 AND `sequence` <=> 0 AND `reward_id` <=> 305020306) OR (`reward_set_id` <=> 3050203 AND `option_id` <=> 6 AND `sequence` <=> 0 AND `reward_id` <=> 305020307) OR (`reward_set_id` <=> 3050203 AND `option_id` <=> 7 AND `sequence` <=> 0 AND `reward_id` <=> 305020308) OR (`reward_set_id` <=> 3050203 AND `option_id` <=> 8 AND `sequence` <=> 0 AND `reward_id` <=> 305020309)))));
INSERT INTO _blight_parent_guard VALUES('options_3050204',(NOT EXISTS(SELECT 1 FROM reward_options WHERE reward_set_id=3050204 AND NOT((`reward_set_id` <=> 3050204 AND `option_id` <=> 1 AND `sequence` <=> 1 AND `label` <=> 'Rough Consigned Plate Boots' AND `common_to_all` <=> 0 AND `flags` <=> 0 AND `enabled` <=> 1 AND `class_mask` <=> 151) OR (`reward_set_id` <=> 3050204 AND `option_id` <=> 2 AND `sequence` <=> 2 AND `label` <=> 'Rough Consigned Chain Boots' AND `common_to_all` <=> 0 AND `flags` <=> 0 AND `enabled` <=> 1 AND `class_mask` <=> 33544) OR (`reward_set_id` <=> 3050204 AND `option_id` <=> 3 AND `sequence` <=> 3 AND `label` <=> 'Rough Consigned Leather Boots' AND `common_to_all` <=> 0 AND `flags` <=> 0 AND `enabled` <=> 1 AND `class_mask` <=> 16480) OR (`reward_set_id` <=> 3050204 AND `option_id` <=> 4 AND `sequence` <=> 4 AND `label` <=> 'Rough Consigned Cloth Sandals' AND `common_to_all` <=> 0 AND `flags` <=> 0 AND `enabled` <=> 1 AND `class_mask` <=> 15360)))));
INSERT INTO _blight_parent_guard VALUES('entries_3050204',(NOT EXISTS(SELECT 1 FROM reward_option_entries WHERE reward_set_id=3050204 AND NOT((`reward_set_id` <=> 3050204 AND `option_id` <=> 1 AND `sequence` <=> 0 AND `reward_id` <=> 305020401) OR (`reward_set_id` <=> 3050204 AND `option_id` <=> 2 AND `sequence` <=> 0 AND `reward_id` <=> 305020402) OR (`reward_set_id` <=> 3050204 AND `option_id` <=> 3 AND `sequence` <=> 0 AND `reward_id` <=> 305020403) OR (`reward_set_id` <=> 3050204 AND `option_id` <=> 4 AND `sequence` <=> 0 AND `reward_id` <=> 305020404)))));
INSERT INTO _blight_parent_guard VALUES('options_3050205',(NOT EXISTS(SELECT 1 FROM reward_options WHERE reward_set_id=3050205 AND NOT((`reward_set_id` <=> 3050205 AND `option_id` <=> 1 AND `sequence` <=> 1 AND `label` <=> 'Rough Soldier''s Facemask' AND `common_to_all` <=> 1 AND `flags` <=> 0 AND `enabled` <=> 1 AND `class_mask` <=> 49629) OR (`reward_set_id` <=> 3050205 AND `option_id` <=> 2 AND `sequence` <=> 2 AND `label` <=> 'Rough Scryer''s Facemask' AND `common_to_all` <=> 1 AND `flags` <=> 0 AND `enabled` <=> 1 AND `class_mask` <=> 15906)))));
INSERT INTO _blight_parent_guard VALUES('entries_3050205',(NOT EXISTS(SELECT 1 FROM reward_option_entries WHERE reward_set_id=3050205 AND NOT((`reward_set_id` <=> 3050205 AND `option_id` <=> 1 AND `sequence` <=> 0 AND `reward_id` <=> 305020501) OR (`reward_set_id` <=> 3050205 AND `option_id` <=> 2 AND `sequence` <=> 0 AND `reward_id` <=> 305020502)))));
INSERT INTO _blight_parent_guard VALUES('options_3050206',(NOT EXISTS(SELECT 1 FROM reward_options WHERE reward_set_id=3050206 AND NOT((`reward_set_id` <=> 3050206 AND `option_id` <=> 1 AND `sequence` <=> 1 AND `label` <=> 'Rough Soldier''s Gorget' AND `common_to_all` <=> 1 AND `flags` <=> 0 AND `enabled` <=> 1 AND `class_mask` <=> 49629) OR (`reward_set_id` <=> 3050206 AND `option_id` <=> 2 AND `sequence` <=> 2 AND `label` <=> 'Rough Scryer''s Necklace' AND `common_to_all` <=> 1 AND `flags` <=> 0 AND `enabled` <=> 1 AND `class_mask` <=> 15906)))));
INSERT INTO _blight_parent_guard VALUES('entries_3050206',(NOT EXISTS(SELECT 1 FROM reward_option_entries WHERE reward_set_id=3050206 AND NOT((`reward_set_id` <=> 3050206 AND `option_id` <=> 1 AND `sequence` <=> 0 AND `reward_id` <=> 305020601) OR (`reward_set_id` <=> 3050206 AND `option_id` <=> 2 AND `sequence` <=> 0 AND `reward_id` <=> 305020602)))));
INSERT INTO _blight_parent_guard VALUES('options_3050207',(NOT EXISTS(SELECT 1 FROM reward_options WHERE reward_set_id=3050207 AND NOT((`reward_set_id` <=> 3050207 AND `option_id` <=> 1 AND `sequence` <=> 1 AND `label` <=> 'Rough Soldier''s Cloak' AND `common_to_all` <=> 1 AND `flags` <=> 0 AND `enabled` <=> 1 AND `class_mask` <=> 49629) OR (`reward_set_id` <=> 3050207 AND `option_id` <=> 2 AND `sequence` <=> 2 AND `label` <=> 'Rough Scryer''s Cloak' AND `common_to_all` <=> 1 AND `flags` <=> 0 AND `enabled` <=> 1 AND `class_mask` <=> 15906)))));
INSERT INTO _blight_parent_guard VALUES('entries_3050207',(NOT EXISTS(SELECT 1 FROM reward_option_entries WHERE reward_set_id=3050207 AND NOT((`reward_set_id` <=> 3050207 AND `option_id` <=> 1 AND `sequence` <=> 0 AND `reward_id` <=> 305020701) OR (`reward_set_id` <=> 3050207 AND `option_id` <=> 2 AND `sequence` <=> 0 AND `reward_id` <=> 305020702)))));
INSERT INTO _blight_parent_guard VALUES('options_3050208',(NOT EXISTS(SELECT 1 FROM reward_options WHERE reward_set_id=3050208 AND NOT((`reward_set_id` <=> 3050208 AND `option_id` <=> 1 AND `sequence` <=> 1 AND `label` <=> 'Rough Soldier''s Mantle' AND `common_to_all` <=> 1 AND `flags` <=> 0 AND `enabled` <=> 1 AND `class_mask` <=> 49629) OR (`reward_set_id` <=> 3050208 AND `option_id` <=> 2 AND `sequence` <=> 2 AND `label` <=> 'Rough Scryer''s Scarf' AND `common_to_all` <=> 1 AND `flags` <=> 0 AND `enabled` <=> 1 AND `class_mask` <=> 15906)))));
INSERT INTO _blight_parent_guard VALUES('entries_3050208',(NOT EXISTS(SELECT 1 FROM reward_option_entries WHERE reward_set_id=3050208 AND NOT((`reward_set_id` <=> 3050208 AND `option_id` <=> 1 AND `sequence` <=> 0 AND `reward_id` <=> 305020801) OR (`reward_set_id` <=> 3050208 AND `option_id` <=> 2 AND `sequence` <=> 0 AND `reward_id` <=> 305020802)))));
INSERT INTO _blight_parent_guard VALUES('options_3050209',(NOT EXISTS(SELECT 1 FROM reward_options WHERE reward_set_id=3050209 AND NOT((`reward_set_id` <=> 3050209 AND `option_id` <=> 1 AND `sequence` <=> 1 AND `label` <=> 'Rough Soldier''s Stake' AND `common_to_all` <=> 1 AND `flags` <=> 0 AND `enabled` <=> 1 AND `class_mask` <=> 49629) OR (`reward_set_id` <=> 3050209 AND `option_id` <=> 2 AND `sequence` <=> 2 AND `label` <=> 'Rough Scryer''s Wand' AND `common_to_all` <=> 1 AND `flags` <=> 0 AND `enabled` <=> 1 AND `class_mask` <=> 15906)))));
INSERT INTO _blight_parent_guard VALUES('entries_3050209',(NOT EXISTS(SELECT 1 FROM reward_option_entries WHERE reward_set_id=3050209 AND NOT((`reward_set_id` <=> 3050209 AND `option_id` <=> 1 AND `sequence` <=> 0 AND `reward_id` <=> 305020901) OR (`reward_set_id` <=> 3050209 AND `option_id` <=> 2 AND `sequence` <=> 0 AND `reward_id` <=> 305020902)))));
START TRANSACTION;
INSERT INTO reward_sets(`reward_set_id`,`title`,`enabled`)VALUES
(3050202,'Welcome to the Moors (21-25)',1),
(3050203,'Battling Blightfire (26-30)',1),
(3050204,'Champion of the Moors (31-35)',1),
(3050205,'Job Offers (Blightfire 20+)',1),
(3050206,'Two Gnolls With One Stone (Blightfire 20+)',1),
(3050207,'Stemming the Threat (Blightfire 20+)',1),
(3050208,'Battling the Bixies (Blightfire 30+)',1),
(3050209,'Makesn''s Plight (Blightfire 30+)',1)
ON DUPLICATE KEY UPDATE `title`=VALUES(`title`),`enabled`=VALUES(`enabled`);
INSERT INTO reward_sources(`source_type`,`source_id`,`reward_set_id`,`enabled`)VALUES
(1,500020200,3050202,1),
(1,500020300,3050203,1),
(1,500020400,3050204,1),
(1,500020500,3050205,1),
(1,500020600,3050206,1),
(1,500020700,3050207,1),
(1,500020800,3050208,1),
(1,500020900,3050209,1)
ON DUPLICATE KEY UPDATE `source_id`=VALUES(`source_id`),`reward_set_id`=VALUES(`reward_set_id`),`enabled`=VALUES(`enabled`);
INSERT INTO reward_options(`reward_set_id`,`option_id`,`sequence`,`label`,`common_to_all`,`flags`,`enabled`,`class_mask`)VALUES
(3050202,1,1,'Rough Consigned Plate Helm',0,0,1,151),
(3050202,2,2,'Rough Consigned Chain Coif',0,0,1,33544),
(3050202,3,3,'Rough Consigned Leather Cap',0,0,1,16480),
(3050202,4,4,'Rough Consigned Cloth Cap',0,0,1,15360),
(3050203,1,1,'Melee shield',1,0,1,16861),
(3050203,2,2,'Caster shield and scepter',1,0,1,15906),
(3050203,3,3,'Rough Consigned Bow',0,0,1,285),
(3050203,4,4,'Rough Consigned Hammer',0,0,1,16861),
(3050203,5,5,'Rough Consigned Longsword',0,0,1,413),
(3050203,6,6,'Rough Consigned Shortsword',0,0,1,413),
(3050203,7,7,'Rough Consigned Stone Dagger',0,0,1,16793),
(3050203,8,8,'Rough Consigned Halberd',0,0,1,32797),
(3050204,1,1,'Rough Consigned Plate Boots',0,0,1,151),
(3050204,2,2,'Rough Consigned Chain Boots',0,0,1,33544),
(3050204,3,3,'Rough Consigned Leather Boots',0,0,1,16480),
(3050204,4,4,'Rough Consigned Cloth Sandals',0,0,1,15360),
(3050205,1,1,'Rough Soldier''s Facemask',1,0,1,49629),
(3050205,2,2,'Rough Scryer''s Facemask',1,0,1,15906),
(3050206,1,1,'Rough Soldier''s Gorget',1,0,1,49629),
(3050206,2,2,'Rough Scryer''s Necklace',1,0,1,15906),
(3050207,1,1,'Rough Soldier''s Cloak',1,0,1,49629),
(3050207,2,2,'Rough Scryer''s Cloak',1,0,1,15906),
(3050208,1,1,'Rough Soldier''s Mantle',1,0,1,49629),
(3050208,2,2,'Rough Scryer''s Scarf',1,0,1,15906),
(3050209,1,1,'Rough Soldier''s Stake',1,0,1,49629),
(3050209,2,2,'Rough Scryer''s Wand',1,0,1,15906)
ON DUPLICATE KEY UPDATE `option_id`=VALUES(`option_id`),`sequence`=VALUES(`sequence`),`label`=VALUES(`label`),`common_to_all`=VALUES(`common_to_all`),`flags`=VALUES(`flags`),`enabled`=VALUES(`enabled`),`class_mask`=VALUES(`class_mask`);
INSERT INTO rewards(`reward_id`,`reward_type`,`reward_data_id`,`amount`,`description`,`enabled`)VALUES
(305020201,0,108064,1,'May2013 Blightfire parent 500020200 item 108064',1),
(305020202,0,108071,1,'May2013 Blightfire parent 500020200 item 108071',1),
(305020203,0,108078,1,'May2013 Blightfire parent 500020200 item 108078',1),
(305020204,0,108085,1,'May2013 Blightfire parent 500020200 item 108085',1),
(305020301,0,108551,1,'May2013 Blightfire parent 500020300 item 108551',1),
(305020302,0,108552,1,'May2013 Blightfire parent 500020300 item 108552',1),
(305020303,0,108541,1,'May2013 Blightfire parent 500020300 item 108541',1),
(305020304,0,108550,1,'May2013 Blightfire parent 500020300 item 108550',1),
(305020305,0,108540,1,'May2013 Blightfire parent 500020300 item 108540',1),
(305020306,0,108543,1,'May2013 Blightfire parent 500020300 item 108543',1),
(305020307,0,108542,1,'May2013 Blightfire parent 500020300 item 108542',1),
(305020308,0,108544,1,'May2013 Blightfire parent 500020300 item 108544',1),
(305020309,0,108549,1,'May2013 Blightfire parent 500020300 item 108549',1),
(305020401,0,108063,1,'May2013 Blightfire parent 500020400 item 108063',1),
(305020402,0,108070,1,'May2013 Blightfire parent 500020400 item 108070',1),
(305020403,0,108077,1,'May2013 Blightfire parent 500020400 item 108077',1),
(305020404,0,108084,1,'May2013 Blightfire parent 500020400 item 108084',1),
(305020501,0,108342,1,'May2013 Blightfire parent 500020500 item 108342',1),
(305020502,0,108352,1,'May2013 Blightfire parent 500020500 item 108352',1),
(305020601,0,108343,1,'May2013 Blightfire parent 500020600 item 108343',1),
(305020602,0,108353,1,'May2013 Blightfire parent 500020600 item 108353',1),
(305020701,0,108345,1,'May2013 Blightfire parent 500020700 item 108345',1),
(305020702,0,108355,1,'May2013 Blightfire parent 500020700 item 108355',1),
(305020801,0,108344,1,'May2013 Blightfire parent 500020800 item 108344',1),
(305020802,0,108354,1,'May2013 Blightfire parent 500020800 item 108354',1),
(305020901,0,108346,1,'May2013 Blightfire parent 500020900 item 108346',1),
(305020902,0,108356,1,'May2013 Blightfire parent 500020900 item 108356',1)
ON DUPLICATE KEY UPDATE `reward_type`=VALUES(`reward_type`),`reward_data_id`=VALUES(`reward_data_id`),`amount`=VALUES(`amount`),`description`=VALUES(`description`),`enabled`=VALUES(`enabled`);
INSERT INTO reward_option_entries(`reward_set_id`,`option_id`,`sequence`,`reward_id`)VALUES
(3050202,1,0,305020201),
(3050202,2,0,305020202),
(3050202,3,0,305020203),
(3050202,4,0,305020204),
(3050203,1,0,305020301),
(3050203,2,0,305020302),
(3050203,2,1,305020303),
(3050203,3,0,305020304),
(3050203,4,0,305020305),
(3050203,5,0,305020306),
(3050203,6,0,305020307),
(3050203,7,0,305020308),
(3050203,8,0,305020309),
(3050204,1,0,305020401),
(3050204,2,0,305020402),
(3050204,3,0,305020403),
(3050204,4,0,305020404),
(3050205,1,0,305020501),
(3050205,2,0,305020502),
(3050206,1,0,305020601),
(3050206,2,0,305020602),
(3050207,1,0,305020701),
(3050207,2,0,305020702),
(3050208,1,0,305020801),
(3050208,2,0,305020802),
(3050209,1,0,305020901),
(3050209,2,0,305020902)
ON DUPLICATE KEY UPDATE `option_id`=VALUES(`option_id`),`sequence`=VALUES(`sequence`),`reward_id`=VALUES(`reward_id`);
COMMIT;
