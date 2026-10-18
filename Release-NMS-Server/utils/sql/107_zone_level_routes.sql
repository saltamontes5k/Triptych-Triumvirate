-- Custom migration 107: level-based zone version routing (Custom:LevelBasedZoneRouting)
-- Routes players by level to versioned/replacement zones: lavastorm + cazic-thule go to a
-- shared version 1 static global instance at 60+, nro/sro redirect to northro/southro at 60+.
-- Twin of database_update_manifest_custom.cpp entry 107; applied automatically at world boot.

CREATE TABLE zone_level_routes (
    id INT AUTO_INCREMENT PRIMARY KEY,
    zoneidnumber INT NOT NULL,
    min_level SMALLINT UNSIGNED NOT NULL DEFAULT 0,
    max_level SMALLINT UNSIGNED NOT NULL DEFAULT 255,
    target_zoneidnumber INT NOT NULL,
    target_version SMALLINT UNSIGNED NOT NULL DEFAULT 0,
    enabled TINYINT UNSIGNED NOT NULL DEFAULT 1,
    comment VARCHAR(120) NOT NULL DEFAULT '',
    INDEX idx_zone_level_routes_zone (zoneidnumber)
);

INSERT INTO zone_level_routes (zoneidnumber, min_level, max_level, target_zoneidnumber, target_version, enabled, comment) VALUES
(48, 60, 255, 48, 1, 1, 'Cazic-Thule: 60+ -> v1 static instance');

-- cazic-thule v1 row: clone of v0 (same terrain, own version 1 mob set)
INSERT INTO zone (
  zoneidnumber, version, short_name, long_name, min_status, map_file_name, note,
  min_expansion, max_expansion, content_flags, content_flags_disabled, expansion, file_name,
  safe_x, safe_y, safe_z, safe_heading, graveyard_id, min_level, max_level, timezone,
  maxclients, ruleset, underworld, minclip, maxclip, fog_minclip, fog_maxclip,
  fog_blue, fog_red, fog_green, sky, ztype, zone_exp_multiplier, walkspeed, time_type,
  fog_red1, fog_green1, fog_blue1, fog_minclip1, fog_maxclip1,
  fog_red2, fog_green2, fog_blue2, fog_minclip2, fog_maxclip2,
  fog_red3, fog_green3, fog_blue3, fog_minclip3, fog_maxclip3,
  fog_red4, fog_green4, fog_blue4, fog_minclip4, fog_maxclip4,
  fog_density, flag_needed, canbind, cancombat, canlevitate, castoutdoor, hotzone,
  insttype, shutdowndelay, peqzone, bypass_expansion_check, suspendbuffs,
  rain_chance1, rain_chance2, rain_chance3, rain_chance4,
  rain_duration1, rain_duration2, rain_duration3, rain_duration4,
  snow_chance1, snow_chance2, snow_chance3, snow_chance4,
  snow_duration1, snow_duration2, snow_duration3, snow_duration4,
  gravity, type, skylock, fast_regen_hp, fast_regen_mana, fast_regen_endurance,
  npc_max_aggro_dist, npc_update_range, client_update_range, max_movement_update_range,
  underworld_teleport_index, lava_damage, min_lava_damage, idle_when_empty,
  seconds_before_idle, shard_at_player_count
)
SELECT
  zoneidnumber, 1, short_name, long_name, min_status, map_file_name, note,
  min_expansion, max_expansion, content_flags, content_flags_disabled, expansion, file_name,
  safe_x, safe_y, safe_z, safe_heading, graveyard_id, min_level, max_level, timezone,
  maxclients, ruleset, underworld, minclip, maxclip, fog_minclip, fog_maxclip,
  fog_blue, fog_red, fog_green, sky, ztype, zone_exp_multiplier, walkspeed, time_type,
  fog_red1, fog_green1, fog_blue1, fog_minclip1, fog_maxclip1,
  fog_red2, fog_green2, fog_blue2, fog_minclip2, fog_maxclip2,
  fog_red3, fog_green3, fog_blue3, fog_minclip3, fog_maxclip3,
  fog_red4, fog_green4, fog_blue4, fog_minclip4, fog_maxclip4,
  fog_density, flag_needed, canbind, cancombat, canlevitate, castoutdoor, hotzone,
  insttype, shutdowndelay, peqzone, bypass_expansion_check, suspendbuffs,
  rain_chance1, rain_chance2, rain_chance3, rain_chance4,
  rain_duration1, rain_duration2, rain_duration3, rain_duration4,
  snow_chance1, snow_chance2, snow_chance3, snow_chance4,
  snow_duration1, snow_duration2, snow_duration3, snow_duration4,
  gravity, type, skylock, fast_regen_hp, fast_regen_mana, fast_regen_endurance,
  npc_max_aggro_dist, npc_update_range, client_update_range, max_movement_update_range,
  underworld_teleport_index, lava_damage, min_lava_damage, idle_when_empty,
  seconds_before_idle, shard_at_player_count
FROM zone
WHERE zoneidnumber = 48 AND version = 0
  AND NOT EXISTS (SELECT 1 FROM (SELECT 1 FROM zone WHERE zoneidnumber = 48 AND version = 1) AS existing_v1);

-- static global instances that make the version 1 zones reachable (never expire)
INSERT INTO instance_list (zone, version, is_global, start_time, duration, expire_at, never_expires, notes)
SELECT 27, 1, 1, UNIX_TIMESTAMP(), 3155760000, UNIX_TIMESTAMP() + 3155760000, 1, 'Lavastorm v1 (60+) static global'
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM (SELECT 1 FROM instance_list WHERE zone = 27 AND version = 1 AND is_global = 1 AND never_expires = 1) AS existing_ls);

INSERT INTO instance_list (zone, version, is_global, start_time, duration, expire_at, never_expires, notes)
SELECT 48, 1, 1, UNIX_TIMESTAMP(), 3155760000, UNIX_TIMESTAMP() + 3155760000, 1, 'Cazic-Thule v1 (60+) static global'
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM (SELECT 1 FROM instance_list WHERE zone = 48 AND version = 1 AND is_global = 1 AND never_expires = 1) AS existing_ct);
