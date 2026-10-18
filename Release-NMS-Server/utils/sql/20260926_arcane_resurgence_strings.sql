-- Arcane Resurgence (aa_ability 31083 / first rank 41001) accidentally reused
-- Dimensional Armory's client string id 50000 for title_sid/desc_sid/spell_type,
-- so the AA window rendered it as a second "Dimensional Armory" (and the dbstr
-- exporter generated a duplicate line). Give it its own strings and repoint the rank.
--
-- The dbstr exporter (client_files/export/main.cpp) auto-prepends the
-- "(classes) [/alt activate|toggle N]" tag to db_str type 4 from aa_ability/aa_ranks,
-- so the stored value below is just the description body.

DELETE FROM `db_str` WHERE `id` = 50101;

INSERT INTO `db_str` (`id`, `type`, `value`) VALUES
(50101, 1, 'Arcane Resurgence'),
(50101, 2, 'Arcane'),
(50101, 3, 'Resurgence'),
(50101, 4, 'This passive ability grants your beneficial spells a chance to heal your target.');

UPDATE `aa_ranks`
SET `title_sid`  = 50101,
    `desc_sid`   = 50101,
    `spell_type` = 0
WHERE `id` = 41001;
