-- ============================================================================
-- Deity Blessings -- description string fix + proc-engine event export rows
-- Date: 2026-09-22
-- ============================================================================

-- Fix the Imbue Jacinth description (was inheriting Imbue Emerald's
-- via descnum=1888). Custom strings live above 910000000 like the soul gems.
INSERT INTO `db_str` (`id`,`type`,`value`)
VALUES (910000004, 6, 'Focuses the power of Veeshan into a jacinth.  Consumes a jacinth when cast.')
ON DUPLICATE KEY UPDATE `value` = VALUES(`value`);

UPDATE `spells_new`
SET `descnum` = 910000004, `typedescnum` = 0, `effectdescnum` = 0
WHERE `id` = 50017;

-- Reduce exported variables for the damage events the blessing proc engine
-- uses (matches the style of the other combat events: no qglobals/item).
INSERT INTO `perl_event_export_settings`
    (`event_id`,`event_description`,`export_qglobals`,`export_mob`,`export_zone`,`export_item`,`export_event`)
VALUES
    (116,'EVENT_DAMAGE_GIVEN',0,1,1,0,1),
    (117,'EVENT_DAMAGE_TAKEN',0,1,1,0,1)
ON DUPLICATE KEY UPDATE
    `event_description` = VALUES(`event_description`),
    `export_qglobals`   = VALUES(`export_qglobals`),
    `export_mob`        = VALUES(`export_mob`),
    `export_zone`       = VALUES(`export_zone`),
    `export_item`       = VALUES(`export_item`),
    `export_event`      = VALUES(`export_event`);
