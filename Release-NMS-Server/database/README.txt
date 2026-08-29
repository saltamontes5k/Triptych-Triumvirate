Database file: release-peq-sanitized.zip  (contains release-peq-sanitized.sql)
SAFE-TO-SHARE dump of the live 'peq' database taken 2026-08-28.

WIPED (structure only, 145 tables): accounts, login accounts, all characters
(inventory, skills, spells, buffs, corpses, parcels, pets, tasks, tribute, alt
currency, timers, zone flags, recipes, titles), guilds, mail, traders, buyers,
data buckets, discoveries, chat channels, friends, groups/raids/expeditions,
mercenaries, petitions, player & query-server event logs, admin accounts,
banned/GM IPs.

KEPT: items (incl. ~750 generated Lost/Restless/Found Soul augs), NPCs, spawns,
loot, spells, zones, quests, merchants, tradeskill recipes, Drakkin breath AAs
(590-595), Ascendant tome system (aa_custom_mapping, universal AAs, tome items),
name_filter + profanity_list (badword filter), and world waypoint config.

RESTORE:
  1. Start MariaDB, create empty DB:  CREATE DATABASE peq;
  2. Unzip, then import:  mysql -u <user> -p peq < release-peq-sanitized.sql
