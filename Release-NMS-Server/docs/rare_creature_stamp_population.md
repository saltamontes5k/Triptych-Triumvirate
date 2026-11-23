# rare_creature stamp population (v414)

Review sheet for `npc_types.rare_creature`, the player-facing "This is a Rare
Creature" flag added by v413 and populated by v414. Strike a band here and it
comes out of the v414 `WHERE` before the migration is final.

## Why a new column

`rare_spawn` is not available for this. v101
(`20261007_ascendant_shard_named_only`, manifest `:8478`) sets it on every
raid target and named that can drop an Ascendant shard:

```
raid_target = 1 AND untargetable = 0 AND hp >= 1000
AND name NOT LIKE '%Trap%' ... 'Treasure_of_%'
```

Live that is 2,974 rows. Reading `IsRareSpawn()` for the consider line would
announce "This is a Rare Creature" on nearly every raid boss and named in the
game -- the opposite of the intent. So the consider line reads
`IsRareCreature()`, v101 keeps `rare_spawn`, and the two meanings stop sharing
a column.

## Bands stamped by v414

| Band | npc ids | rows | provenance |
|---|---|---|---|
| Stock rare spawns | see list below | 15 | `rare_spawn = 1` rows outside the v101 predicate (stock PEQ data) |
| SoD theme rares | 1120002010-1120002171 | 162 | v146 `20261012_sod_themerares` (63), v147 `sod_kunark_theme` (37), v150 `sod_rathe_theme` (33), v152 `sod_discord_theme` (29) |
| PoR theme completion | 1120002200-1120002299 | 100 | v181 `por_theme_completion_7_npc_1120002200` (50), v182 `..._8_npc_1120002250` (50) |
| TSS open-world named | 1120002300-1120002384 | 85 | v188-v219 `20261024_tss_open_content_*` (3 named per entry) |

Total: 362 rows. All four bands are `rare_spawn = 0` and `raid_target = 0`
today, so nothing here is double-flagged.

### Stock 15 (exact ids)

```
18142   Tesch_Val_Deval`Nmak        26000   Herald_of_the_Deepwater
27148   a_warbone_monk              27149   a_warbone_spearman
27152   a_lesser_nightmare          27168   Tisella
128089  #Kerafyrm                   151255  #Innoruuk
163045  a_shadow_master             163046  a_shadow_master
163172  a_shadow_master             340033  Sugita_the_Vicarious
340034  Toshiharu                   340400  Yoshihiro
397904  Fantoma
```

Note 27148/27149/27152 are ordinary-looking low-level mobs that stock PEQ marks
as rare spawns at their spawn point; they will con as rare creatures. That is
consistent with `rare_spawn`, but say so if you would rather drop them.

## Band that needs a decision: TSS

The SoD and PoR blocks are explicitly named-rare passes. The TSS block is
described in its own header as "rares, loot, event NPCs, tasks", and the id
range mixes both kinds:

- rare-spawn named: `#Crusher`, `#Fleshless`, `#Haze`, `#Fallow`,
  `#Chief_Urgak`, `#Avalanche`, `#Pummelcrush`, `#Vetiki`, `#Vegeroth`,
  `#Earthrender`, `#Earthcrusher`, `#Demeton_Destroyer_of_Life`,
  `#Stormwind_Totem`, `#Blightwind_Totem`, `#Deathwind_Totem`,
  `#Hatewind_Totem`, `#Grenrik_the_Addled`, `Blackfoot`, `Bloodfoot`,
  `Chillbone`, `Frostpaw`, `Glacier`, `Grimjaw`, `Hunter`, `Lowfire`,
  `Snowblind`, `Stalker of the Plains`, `Tarnuk Farwalker`, `Taruskor`,
  `Oldbones`, `Skurl`, `Sneaktalker Gizdor`, `Splotchy`, `Tarbelly the
  Wanderer`, `Deathfang`, `Midnight`, `Blackfoot` ...
- quest / camp NPCs that would also con rare: `Lorekeeper Heimdul`,
  `Lorekeeper Gerrod`, `Lorekeeper Magnus`, `Quartermaster Balrik`,
  `Quartermaster Ilzjinn`, `Griffon Trainer Ahrendes`, `Chef Gudez`,
  `Firebelly the Cook`, `Mammoth Tender Granik`, `Spring Master Yergin`,
  `Advisor Neezin D`rahl`, `Attendant Jin`zhu`, `Captain of the Guard`,
  `Royal Guard Captain Helgar`, `Squad Leader Brontik`,
  `Watch Commander Cearul`, `Watch Commander Thellik`, `Guard Commander
  Bowulf`, `Belgar, Captain of the Wall`, `Fihulf, Hero of the People`,
  `Patriarch Yerban`, `High Shaman Firglum`, `High Seer Longecho`,
  `an_unleashed_icemass`, `a_Direwind_Gust`, `a_Blight_Pyre_Golem`,
  `spirit_of_Haridok`

If the TSS band should ship without the quest-facing half, replace the
`id BETWEEN 1120002300 AND 1120002384` clause in v414 with an explicit id list;
the doc is the place to make that call, the migration just reads it.

## Verification

```sql
-- v413 landed
SHOW COLUMNS FROM npc_types LIKE 'rare_creature';

-- v414 coverage, expect 362
SELECT COUNT(*) FROM npc_types WHERE rare_creature = 1;

-- band breakdown, expect 15 / 162 / 100 / 85
SELECT SUM(id IN (18142,26000,27148,27149,27152,27168,128089,151255,163045,163046,163172,340033,340034,340400,397904)) AS stock,
       SUM(id BETWEEN 1120002010 AND 1120002171) AS sod,
       SUM(id BETWEEN 1120002200 AND 1120002299) AS por,
       SUM(id BETWEEN 1120002300 AND 1120002384) AS tss
  FROM npc_types WHERE rare_creature = 1;

-- v101 untouched
SELECT COUNT(*) FROM npc_types WHERE rare_spawn = 1;   -- 2,987
```
