Database files in this folder:

  release-peq-sanitized.sql   (raw SQL, ~545 MB)
  release-peq-sanitized.zip   (same dump, compressed, ~53 MB - use this for GitHub)

Both are SAFE-TO-SHARE dumps of the live 'peq' server database taken 2026-08-23.

WHAT IS WIPED (empty - table structure only)
  - Account / login accounts / account IPs & rewards
  - All characters (data, inventory, skills, spells, buffs, corpses, parcels,
    pets, bind points, tasks, tribute, alt currency, etc.)
  - Guilds, guild members, guild bank, guild ranks
  - Mail, traders, buyers
  - Data buckets, nms_waypoints character data

WHAT IS KEPT (intact)
  - Items, NPCs, spawns, loot, spells, zones, doors, merchant lists,
    tradeskill recipes, grids, quest activities, world content.
  - Drakkin breath weapon AAs (590-595) and the Ascendant cross-class AA
    tome system (aa_custom_mapping, universal AAs 20000+, tome items).

RESTORE:
  1. Install MariaDB/MySQL and start it.
  2. Create an empty database:   CREATE DATABASE peq;
  3. Import:  gunzip/unzip release-peq-sanitized.zip  then
              mysql -u <user> -p peq < release-peq-sanitized.sql
