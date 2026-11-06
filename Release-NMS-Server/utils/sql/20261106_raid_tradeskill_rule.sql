-- v354 (2026-11-06) -- Master switch for the raid-kill tradeskill skill-ups
-- (quests/plugins/NMS_tradeskill_utils.pl, hooked by global_npc.pl
-- EVENT_KILLED_MERIT). Ships ON so gating changes no behavior; ops turn it
-- off with #rules setdb Custom:RaidTradeskillRewards false + #reload rules.
-- Twin of the v354 entry in common/database/database_update_manifest_custom.cpp
-- (keep in sync).

INSERT INTO `rule_values` (`ruleset_id`, `rule_name`, `rule_value`, `notes`)
VALUES (1, 'Custom:RaidTradeskillRewards', 'true',
        'Master switch for raid-kill tradeskill skill-ups (NMS_tradeskill_utils.pl)')
ON DUPLICATE KEY UPDATE `rule_value` = VALUES(`rule_value`);
