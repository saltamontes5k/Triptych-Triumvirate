# Blightfire Moors achievement quests

This package adds **14 quests and 44 native task objectives** for:

- **Job Offers (Blightfire 20+)** — Lost Memento, Experienced Hunters Needed, Intrepid Explorer and Supply Runner.
- **Two Gnolls With One Stone (Blightfire 20+)** — Ore for Smelting, Gnollish Tools, The Mucktail Quarry and The Mucktail Mines.
- **Stemming the Threat (Blightfire 20+)** — the three Rotwood quests, Hardy Seeds, Kindling for the Fires and Green Ooze Buds.

The actual quest givers, animals, gnolls, plants, mushrooms and named opponents use existing PEQ entities and locations. Left-click either original Blightfire job board to open the native task selector. The native task engine handles kills, exploration, corpse loot, deliveries, rewards, completion and persistence. The Rotwood sequence retains its prerequisite order and repeat-cycle state. These tasks update the corresponding achievement components.

## Before installing

1. Install the [achievement engine](../../ENGINE.md), including all **six** ordered patches and its database migrations. Patch 0006 supplies the NPC-bound selector required by job boards. Rebuild and deploy the server binaries.
2. Back up your database and quest tree. Stop the game services during the upgrade; keep MariaDB available for importing SQL. Keep other content upgrades out of the same operation.
3. Run the two checks below. A missing or different identity means your content needs a manual merge. Do not force an import into a conflicting custom database.

This is an overlay for the documented PEQ baseline, not a complete database replacement. It preserves housing, characters and existing acquisition tables. Its scoped SQL changes authored tasks/criteria, two faction reward lists and the researched three-copy Scar shield drop. No client assets or UI modifications are required.

## Install on Linux, native Windows or Akk-stack

Python 3 and the MariaDB command-line client are needed. The scripts use the same server files on all platforms. For Windows checkouts, retain LF line endings (`git -c core.autocrlf=false clone ...`) so release checksums remain intact.

From this package directory, check database identities with a private MariaDB option file:

```sh
python3 preflight.py --mysql-command-json '["mariadb","--defaults-extra-file=/private/eq.cnf","peq"]'
python3 apply_quests.py --quests /path/to/server/quests
```

On native Windows, run Python as `py -3`; use your own Windows paths and the corresponding shell quoting. For example, in PowerShell:

```powershell
py -3 preflight.py --mysql-command-json '["mariadb.exe","--defaults-extra-file=C:/private/eq.cnf","peq"]'
py -3 apply_quests.py --quests 'C:/EQEmu/quests'
```

For Akk-stack, use the **host path of the mounted quest directory** for `--quests`. Run the database check through an executable wrapper that forwards stdin to the stack's MariaDB client; supply that wrapper's argument array through `--mysql-command-json`. Existing stack authentication can remain in the wrapper/container configuration. The check sends SELECT statements only. Do not put database passwords in public files or this repository.

If your server has additional quest roots, add `--additional-quests /other/root` for each one. The quest checker detects competing NPC scripts, versioned player callbacks and Lua/Perl shadowing. It preserves existing Lua player callbacks by composing the two narrow event hooks. Custom conflicts require a deliberate manual merge. The exact stock `crescent/#Anarynn.pl` is backed up and retired because its numeric Lua replacement preserves the greeting and handles native delivered-item consumption.

After both checks pass, import these files **in order** through your normal MariaDB connection:

1. `sql/010-catalogue.sql`
2. `sql/020-quests.sql`

Then install every quest wrapper/module and both player hooks, keeping the backup outside the quest tree:

```sh
python3 apply_quests.py --quests /path/to/server/quests --apply --backup /path/to/backups/blightfire-before
```

The same command works with `py -3` and Windows paths. Akk-stack users should retain the mounted quest directory rather than copying into an unmounted container layer. Restart the game services afterward so existing active task caches load the new definitions. The quest installer can be rerun; it recognizes matching installed files/hooks. Do not repeatedly import SQL over a customized installation without rerunning the checks and reviewing local settings.

## Historical accuracy and configurable settings

[Quest specifications](provenance/quest-specification.json) contain objective counts, rewards, minimum levels, repeatability choices and their provenance. [Historical sources](provenance/historical-sources.json) distinguish page revision dates from archive captures made after May 2013. The archive timestamps themselves are not pre-cutoff evidence.

Known XP rewards with unrecovered amounts use a **labelled 1000 XP PEQ-style default**, configurable through the task's `exp_reward` field. Ore for Smelting uses 0 because its XP reward has not been confirmed. Minimum levels and repeatability use the best-supported historical values with explicit uncertainty labels. Faction directions are period-supported; exact numerical amounts are corroborated by later sources. Explorer waypoint centres are researched, but their area widths are reconstructed. Introductory dialogue is authored routing text rather than a claim to preserve every original Live line.

The Spore Farms objective uses the period-revised **15 farmers**, and spores come from the actual Rotwood Spore entities. Existing corpse loot routes remain in use; later group-wide item gifts were not added. Task IDs 3039801–3039814 are **authored emulator IDs**, not recovered original Live task IDs. The original catalogue's `has_reward` flag does not establish a separate achievement reward; no unverified achievement reward is invented. The listed quest item rewards are verified separately. See [reconstruction policy](configuration/reconstruction-policy.json).

## Verification and protocol

**All 14 quests completed through native gameplay**, with saved task history, 14 component completions and all 3 parent achievements observed complete again after logout/login. The Rotwood repeat cycle also returned to its first task. See [native-status.json](provenance/native-status.json) for completed gameplay routes and remaining limits. Static checks, builds, native gameplay and clean-port installation are separate evidence. QA travel and a geared high-level test character do not establish historical minimum-level balance.

The engine's [opcode and structure reference](../../protocol/README.md) remains available. This content package requires no additional achievement opcode values or packet-layout changes. Tests, raw captures, logs, private accounts/characters and client files are excluded from this release.

## Required parent gear upgrade

After installing the five Blightfire quest packages, install the complete [Blightfire parent reward upgrade](../blightfire-parent-rewards/README.md). It supplies the eight family reward sets that were unimplemented at this package’s original verification checkpoint. The separate Conqueror meta reward remains unresolved. See that upgrade for its native claim/persistence coverage and historical limits.
