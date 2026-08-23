# CHANGELOG

Changes in this release relative to the upstream baseline
[`saltamontes5k/NMS-Release`](https://github.com/saltamontes5k/NMS-Release)
(which is itself a fork of `tunaria/NMS-Release`, single commit `2a93ac88`).

This backup is a fully sanitized snapshot of the live NMS server taken on
**2026-08-23**: all player data is wiped and all credentials are placeholders.

---

## Headline features

### 1. Cross-class AA Tome system (integrated from Ascendant-EQ-Emu/Ascendant-Server)

The biggest change. Players hunt **illegible tomes** dropped by NPCs and bring
them to **guild master trainers** in the Bazaar to learn **Alternate Advancement
abilities from other classes**.

- **Database**
  - New table `aa_custom_mapping` (464 rows) — maps original AA IDs to universal
    grant-only AA IDs (20036+) across three tiers (Greater / Exalted / Ascendant).
  - 337 universal AA entries (IDs 20000–21000) added to `aa_ability`.
  - 48 illegible tome items (IDs 121571–121618) added to `items`.
  - Standalone import file included at repo root: `ascendant_tome_system.sql`
    (additive, `INSERT IGNORE`, safe on top of the base dump).
- **Plugins** (`Release-NMS-Plugins/`)
  - `ascendant_tome_translator.pl` — maps class bitmask → tome item IDs per tier;
    multi-class tomes keyed by combined bitmask (e.g. Paladin + Shadowknight).
  - `ascendant_insight_trainer.pl` — full training system: tome turn-in, tiered
    credits, AA browsing, prerequisite checks, and AA rank purchasing.
- **Quests** (`Release-NMS-Quests/bazaar/`)
  - 16 guild master trainer NPCs, one per class that accept tomes:
    Alendar_Dawnsworn (PAL), Caldrin_Azure (WIZ), Elyndra_Farwatch (RNG),
    Fenrick_Lyresong (BRD), Grohm_Spiritbinder (SHM), Karesh_Wildsoul (BST),
    Krag_Bloodfury (BER), Lyrielle_Mindlace (ENC), Merion_Valcrest (CLR),
    Mortivar_Scholar (NEC), Shen_Kai (MNK), Silas_Quickveil (ROG),
    Thalwyn_Rootseer (DRU), Tharok_Ironbound (WAR), Velorin_Ashweave (MAG),
    Vorath_Duskblade (SHD).
  - `Haliax_Greycloak.pl` — AA credit display & redemption NPC: per-class/per-tier
    credit balances, credit → AA point redemption, and buyback of old translated
    tomes from the previous system.
  - `global_npc.pl` — level-banded rare **illegible tome drops** on all mobs
    (3 tiers, boosted on rare/named spawns).
  - `global_player.pl` — `#myaacredits` command to view all tome credit balances.
  - `bazaar_greengrocer.sql` / `bazaar_hazel_buffbot.sql` — NPC spawn data for
    the new Bazaar NPCs.

### 2. Drakkin breath weapons activated

Drakkin characters now receive their racial **breath weapon** as an AA line
instead of missing out entirely.

- `Release-NMS-Plugins/NMS_progression_utils.pl` — new `GrantDrakkinBreathWeapon`
  subroutine. Maps Drakkin heritage (color) → breath AA:
  - Atathus (Red) → AA 590 `Breath of Atathus`
  - Draton'ra (Black) → AA 591 `Breath of Draton'ra`
  - Osh'vir (Blue) → AA 592 `Breath of Osh'vir`
  - Venesh (Green) → AA 593 `Breath of Venesh`
  - Mysaphar (White) → AA 594 `Breath of Mysaphar`
  - Keikolin (Gold) → AA 595 `Breath of Keikolin`
  - Unknown heritage defaults to Venesh so every Drakkin gets a breath weapon.
- **13-rank progression**: rank n granted at level 5 + 5·(n−1), i.e. lvl 5 → 1
  rank, lvl 10 → 2 ranks, …, lvl 65 → 13 ranks (capped).
- `Release-NMS-Quests/global/global_player.pl` — grants on `EVENT_ENTERZONE`
  (catch-up for existing characters, re-verified every zone) and on `EVENT_LEVEL_UP`.
- Breath AAs 590–595 are included in the database dump.

### 3. rabbi's root / crowd-control break CTD patch

Fixes a server crash that could occur while processing buff ticks when a
root / charm / mez / fear / silence break check faded the buff mid-iteration.

- `Release-NMS-Server/zone/spell_effects.cpp`
  - Consolidated the per-effect break checks (charm, silence, root, fear, mez)
    into a single player-only check that runs before the effect switch.
  - Charm pets get an MR bonus on the break check, matching the old per-case math.
  - After a resisted break, validity of the buff is re-checked before continuing
    to process effects — prevents use-after-fade crashes.
  - `SE_CastOnFadeEffectNPC` / `SE_CastOnFadeEffectAlways` now validate the fade
    spell ID with `IsValidSpell` before calling `SpellFinished`; invalid IDs log
    an error instead of crashing.

---

## Other changes

### Server code
- **Directional cone casting fixes**
  - `common/spdat.cpp` — `ST_Directional` no longer requires a target.
  - `zone/spells.cpp` — `GetSpellImpliedTargetID` and `DoCastSpell` treat
    directional cones like beams/rings (fire from caster facing, ignore target).
  - `zone/aa.cpp` — AA activation resolves missing directional-cone targets to
    the caster so shared casting checks don't reject them.
- **GM `#logs` command hardening** (`zone/gm_commands/logs.cpp`) — validates
  start Category ID and per-category ID are within bounds before use; prints a
  clear error message instead of misbehaving on out-of-range input.

### Quests / plugins
- **Newbie starting spell scrolls** (`Release-NMS-Quests/bazaar/A_Fading_Memory.pl`)
  — the newbie reward NPC now grants each class its starting spell scrolls /
  books on top of the existing gear reward (Cleric, Druid, Shaman,
  Necromancer, Wizard, Magician, Enchanter, Berserker; skipped when already owned).
- **New Bazaar NPCs**
  - `Hazel.pl` — Wood Elf buff bot; hails for a level-appropriate full buff bar
    (<10, 10–24, 25–45, 46+).
  - `Greengrocer.pl` — Halfling campfire provisioner; stack of Heroes' Blessing
    and Legends' Blessing on hail. No running to Nro for the lazy
  - 16 guild master tome trainers (see headline feature 1).
  - `bazaar_hazel_buffbot.sql` / `bazaar_greengrocer.sql` spawn data.

---

## Sanitization notes

This backup is safe to share:
- **Player data wiped** — accounts, login accounts, characters (and all related
  tables: inventory, skills, spells, buffs, corpses, parcels, pets, tasks,
  tribute, alt currency, etc.), guilds, mail, traders, buyers, data buckets, and
  `nms_waypoints_character` are empty (structure only).
- **World content intact** — items, NPCs, spawns, loot, spells, zones, quests,
  merchants, tradeskill recipes, Drakkin breath AAs, and the full Ascendant tome
  system.
- **Credentials replaced** — DB password, login password, and Spire encryption
  key are placeholders (`changeme` / `REPLACE_ME_WITH_YOUR_OWN_KEY`) in
  `eqemu_config.json` and `login.json`.
- Compiled outputs (`Build/`, `vcpkg/`, `perl/` runtime), `spire.exe`, logs, and
  backup/config-artifact files (`.bak`) are not included.
