# CHANGELOG

Changes in this repository relative to the upstream baseline
[`tunaria/NMS-Release:main`](https://github.com/tunaria/NMS-Release)
(single commit `2a93ac88`).

All snapshots are fully sanitized: player data is wiped and credentials are
placeholders. See the "Sanitization notes" section at the bottom.

---

## Commit 2 (2026-08-28) — new since Commit 1

Changes on top of the previous snapshot (Commit 1, `1351410`).

### Headline additions

- **AA tome recycling** — Haliax Greycloak (`Release-NMS-Quests/bazaar/Haliax_Greycloak.pl`)
  now offers **tome recycling** (`_do_recycle`): hand in one illegible tome
  (IDs 121571–121618) plus the tier deciphering fee (Greater 100pp / Exalted
  300pp / Ascendant 500pp) and receive a random tome of the **same tier for a
  different class**. One tome at a time; blocked for players on "The Tomeless"
  path. Buyback of old translated tomes from the previous system is still there.
- **Badword filter re-added** — new `Release-NMS-Server/badword_filter_restore.sql`
  restores the profanity/name filters that had been dropped from the live DB:
  - `name_filter` — 280 bad words used by `Database::CheckNameFilter`
    (character, channel, mercenary, bot name validation).
  - `profanity_list` — 283-word chat redaction list seeded from `GetBadWords()`,
    used by `EQ::ProfanityManager`.
  - Idempotent (`INSERT IGNORE`, safe to re-run). Both tables are included in
    the database dump.
- **Lost Soul augmentation system** — new generator
  `Release-NMS-Server/utils/scripts/generators/aug_generator/` creates
  Diablo-style **Lost / Restless / Found Soul** augmentations with randomized
  stats, names, focus/worn effects, and lootdrop entries. ~750 generated aug
  items (IDs 160000+) are in the database dump, wired into loot. Python script
  (`aug_generator.py`) plus `base_aug.txt` template and README; generated
  output is gitignored.
- **Echo of Memory roll change** (`Release-NMS-Server/zone/attack.cpp`) — the
  Echo of Memory award is now **one shared roll per kill** for the killer's
  raid/group; on success every eligible member (con color + level-range rules
  per member) is awarded together. Previously each member rolled individually.
- **Bazaar NPCs**
  - ~14 new tome-trainer guild masters (one per class, renamed variants):
    Almar_The_Wise (ENC), Andor_Drakon (WIZ), Arick_Mersans (CLR), Billy_Bo
    (MNK), Doc_Hoppers (BRD), Dora_The_Embalmer (NEC), Fred_Wildcog (BST),
    Grohm_Stonebinder (SHM), Kenny_Rootseer (DRU), Krag_Lavafury (BER),
    Magi_of_Yendor (MAG), Nick_Danger (WAR), Priendar_Dawnsear (PAL),
    Titania_Duskblade (SHD).
  - **Purveyor of Armour Glamour** — new `Purveyor_of_Armour_Glamour.pl` +
    `bazaar_armour_glamour.sql` + database manifest v26
    (`database_update_manifest_custom.cpp`): armour ornament NPC (npc_types
    1120001110, spawngroup 5003550, spawn2 2141650 in bazaar). Hail for info;
    hand in 5000pp or 2 Echo of Memory for a random Hero Forge armour ornament;
    Token of Shifting Glamour exchange and 1-for-1 glamour recycling.
- **DB connection leak fixes** — added `$dbh->disconnect()` /
  `$connect->disconnect()` in `Doors_Manip.pl`, `MP3.pl`, `rathunt.pl`, and
  `Purveyor_of_Glamour.pl`.

### Other

- `utils/scripts/.gitignore` now ignores `aug_generator/output/` and
  `aug_generator/used_names.txt`.
- Refreshed sanitized database dump (`database/release-peq-sanitized.zip`) with
  all of the above content.

---

## Commit 1 (2026-08-23, `1351410`) — original sanitized snapshot

The first release of this fork.

### 1. Cross-class AA Tome system (integrated from Ascendant-EQ-Emu/Ascendant-Server)

Players hunt **illegible tomes** dropped by NPCs and bring them to **guild
master trainers** in the Bazaar to learn **Alternate Advancement abilities from
other classes**.

- **Database**
  - New table `aa_custom_mapping` (464 rows) — maps original AA IDs to universal
    grant-only AA IDs (20036+) across three tiers (Greater / Exalted / Ascendant).
  - 337 universal AA entries (IDs 20000–21000) added to `aa_ability`.
  - 48 illegible tome items (IDs 121571–121618) added to `items`.
  - Standalone import file at repo root: `ascendant_tome_system.sql`
    (additive, `INSERT IGNORE`, safe on top of the base dump).
- **Plugins** (`Release-NMS-Plugins/`)
  - `ascendant_tome_translator.pl` — maps class bitmask → tome item IDs per tier;
    multi-class tomes keyed by combined bitmask.
  - `ascendant_insight_trainer.pl` — full training system: tome turn-in, tiered
    credits, AA browsing, prerequisite checks, and AA rank purchasing.
- **Quests** (`Release-NMS-Quests/bazaar/`)
  - 16 guild master trainer NPCs (one per class): Alendar_Dawnsworn (PAL),
    Caldrin_Azure (WIZ), Elyndra_Farwatch (RNG), Fenrick_Lyresong (BRD),
    Grohm_Spiritbinder (SHM), Karesh_Wildsoul (BST), Krag_Bloodfury (BER),
    Lyrielle_Mindlace (ENC), Merion_Valcrest (CLR), Mortivar_Scholar (NEC),
    Shen_Kai (MNK), Silas_Quickveil (ROG), Thalwyn_Rootseer (DRU),
    Tharok_Ironbound (WAR), Velorin_Ashweave (MAG), Vorath_Duskblade (SHD).
  - `Haliax_Greycloak.pl` — AA credit display & redemption NPC (per-class /
    per-tier credit balances, credit → AA point redemption, old-tome buyback).
  - `global_npc.pl` — level-banded rare **illegible tome drops** on all mobs
    (3 tiers, boosted on rare/named spawns).
  - `global_player.pl` — `#myaacredits` command.
  - `bazaar_greengrocer.sql` / `bazaar_hazel_buffbot.sql` — new NPC spawn data.

### 2. Drakkin breath weapons activated

Drakkin characters now receive their racial **breath weapon** as an AA line.

- `Release-NMS-Plugins/NMS_progression_utils.pl` — `GrantDrakkinBreathWeapon`:
  heritage (color) → breath AA (Atathus/Red→590, Draton'ra/Black→591,
  Osh'vir/Blue→592, Venesh/Green→593, Mysaphar/White→594, Keikolin/Gold→595;
  unknown defaults to Venesh). **13-rank progression**: rank n at level
  5 + 5·(n−1), capped at rank 13 (lvl 65).
- `global_player.pl` grants on `EVENT_ENTERZONE` (catch-up, re-verified) and
  `EVENT_LEVEL_UP`. Breath AAs 590–595 included in the DB dump.

### 3. rabbi's root / crowd-control break CTD patch

- `Release-NMS-Server/zone/spell_effects.cpp` — consolidated the per-effect
  break checks (charm, silence, root, fear, mez) into a single player-only check
  that runs before the effect switch. Charm pets keep their MR bonus on the
  break check. After a resisted break the buff's validity is re-checked before
  continuing (prevents use-after-fade crashes). `SE_CastOnFadeEffect*` now
  validates the fade spell ID with `IsValidSpell` and logs instead of crashing.

### Other changes (Commit 1)

- **Directional cone casting fixes** — `common/spdat.cpp`, `zone/spells.cpp`,
  `zone/aa.cpp`: `ST_Directional` cones fire from caster facing, ignore target,
  and AA activation resolves missing cone targets to the caster.
- **GM `#logs` hardening** (`zone/gm_commands/logs.cpp`) — validates category ID
  bounds.
- **Newbie starting spell scrolls** (`A_Fading_Memory.pl`) — class starting
  scrolls granted alongside the gear+cash newbie reward.
- **Bazaar NPCs**: `Hazel.pl` (buff bot), `Greengrocer.pl` (campfire
  provisioner), the 16 tome trainers, and Haliax Greycloak.

---

## Credits

- **huggy / sploose** — Hazel buff bot (`Release-NMS-Quests/bazaar/Hazel.pl`)
- **zerohex** — Purveyor of Armour Glamour
  (`Release-NMS-Quests/bazaar/Purveyor_of_Armour_Glamour.pl`)
- **dritjoda** — Lost Soul Diablo-style augmentation system
  (`Release-NMS-Server/utils/scripts/generators/aug_generator/`)
- **Straps** — Ascendant tome system plugins and trainers

---

## Sanitization notes

- **Player data wiped** — 145 player-data tables are empty (structure only):
  accounts, login accounts, all characters and character sub-tables (inventory,
  skills, spells, buffs, corpses, parcels, pets, tasks, tribute, alt currency,
  timers, zone flags, recipes, titles), guilds, mail, traders, buyers, data
  buckets, **discovered items**, **chat channels**, friends,
  groups/raids/expeditions, mercenaries, petitions, player & query-server event
  logs, admin accounts, and banned/GM IP tables.
- **World content intact** — items (incl. generated augs), NPCs, spawns, loot,
  spells, zones, quests, merchants, tradeskill recipes, Drakkin breath AAs, the
  Ascendant tome system, and the badword filters.
- **Credentials replaced** — DB password, login password, and Spire encryption
  key are placeholders (`changeme` / `REPLACE_ME_WITH_YOUR_OWN_KEY`) in
  `eqemu_config.json` and `login.json`.
- Compiled outputs (`Build/`, `vcpkg/`, `perl/` runtime), `spire.exe`, logs, and
  `.bak` files are not included.
- The raw `release-peq-sanitized.sql` dump is gitignored (over GitHub's 100 MB
  per-file limit); the compressed `release-peq-sanitized.zip` is shipped instead.
