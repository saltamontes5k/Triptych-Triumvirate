-- Rollback of v155 (utils/sql/20261013_dodh_zone_links.sql).
-- Removes the 16 authored DoDH zone-line rows. The dead 0,0,0 dreadspire
-- imports (numbers 30-80) that the migration deleted are intentionally NOT
-- restored - they were inert duplicates targeting Stoneroot/Hive with null
-- coordinates and no inbound counterpart; re-adding them only recreates the
-- cleanup work.

DELETE FROM `zone_points`
WHERE `version` = 0 AND (
       (`zone` = 'drachnidhive'  AND `number` IN (50, 60))
    OR (`zone` = 'dreadspire'    AND `number` = 90)
    OR (`zone` = 'corathus'      AND `number` = 40)
    OR (`zone` = 'corathusa'     AND `number` = 10)
    OR (`zone` = 'eastkorlach'   AND `number` IN (60, 70))
    OR (`zone` = 'eastkorlacha'  AND `number` = 10)
    OR (`zone` = 'westkorlach'   AND `number` IN (50, 60))
    OR (`zone` = 'westkorlacha'  AND `number` = 10)
    OR (`zone` = 'westkorlachc'  AND `number` = 10)
    OR (`zone` = 'illsalin'      AND `number` = 10)
    OR (`zone` = 'illsalinc'     AND `number` = 10)
    OR (`zone` = 'illsalinb'     AND `number` = 10)
    OR (`zone` = 'drachnidhivec' AND `number` = 10));
