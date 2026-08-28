Database file: release-peq-sanitized.zip  (contains release-peq-sanitized.sql)
SAFE-TO-SHARE dump of the live 'peq' database taken 2026-08-28.

WIPED (structure only): accounts, login accounts, all characters (inventory,
skills, spells, buffs, corpses, parcels, pets, tasks, tribute, alt currency),
guilds, mail, traders, buyers, data buckets, nms_waypoints character data.

KEPT: items (incl. ~750 generated Lost/Restless/Found Soul augs, IDs 160000+),
NPCs (incl. armour glamour + new tome trainers), spawns, loot, spells, zones,
quests, merchants, tradeskill recipes, Drakkin breath AAs (590-595), Ascendant
tome system (aa_custom_mapping, universal AAs, tome items), name_filter and
profanity_list (badword filter).

RESTORE:
  1. Start MariaDB, create empty DB:  CREATE DATABASE peq;
  2. Unzip, then import:  mysql -u <user> -p peq < release-peq-sanitized.sql
