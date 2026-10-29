# Blightfire Bixie and Makesn quests

This package adds **12 quests, 58 native objectives and 12 achievement component bindings** for **Battling the Bixies** and **Makesn's Plight**. It includes the complete Bowen and Ethaniel chains, the Fletcher stinger/Buzzazar quests, and Makesn's three quests.

Cocoons hatch larvae, Verrin walks back to camp, jumjum buckets refill, the Silo bud grows, and rescued thralls must reach camp alive. Original PEQ NPC locations and ordinary corpse drops remain in use. The native task and reward engines handle progression, deliveries, class-filtered choices and persistence.

## Install

Install the [achievement engine](../../ENGINE.md), including all six ordered patches, then install [Blightfire Moors](../blightfire-moors/README.md). This package extends its Fletcher and player callbacks. Back up your database and quest tree. Stop game services while upgrading; leave MariaDB available. Do not combine this import with another content upgrade.

Python 3 and the MariaDB command-line client are required. These scripts support Linux, native Windows and Akk-stack. On Windows use `py -3` instead of `python3`, Windows paths, and LF checkout line endings (`git -c core.autocrlf=false clone ...`). With Akk-stack, point the installer at the mounted host quest tree, not an unmounted container directory.

From this package directory, check identities and script composition first:

```sh
python3 preflight.py --mysql-command-json '["mariadb","--defaults-extra-file=/private/eq.cnf","peq"]'
python3 apply_quests.py --quests /path/to/server/quests
```

Use a private MariaDB option file with your own credentials; do not put passwords on the command line. Pass `--additional-quests /other/quest/root` for other configured quest roots so alternate callbacks can be checked. A conflicting identity or custom script needs a manual merge; do not force the upgrade.

Import both SQL files in order, then install all quest files and both composed hooks:

```sh
mariadb --defaults-extra-file=/private/eq.cnf peq < sql/010-catalogue.sql
mariadb --defaults-extra-file=/private/eq.cnf peq < sql/020-quests.sql
python3 apply_quests.py --quests /path/to/server/quests --apply --backup /path/to/backups/bixies-before
```

On native Windows run the SQL redirections from Command Prompt, or open the MariaDB client and use `SOURCE` with each absolute SQL path. Akk-stack users can feed the files to their MariaDB service through `docker compose exec -T`; use the database and service names from their stack. Restart game services after installation so task/NPC caches reload.

The installer recognizes the previous released Fletcher script and upgrades it, while preserving its Green Ooze Buds quest. It chains existing Lua player callbacks, rejects conflicting Perl shadowing, checks release checksums and backs up changed files. SQL guards reject conflicting authored IDs before changing quest content. Character, inventory, guild and housing tables are not import targets.

## Historical fidelity and settings

[Quest specifications](provenance/quest-specification.json) record sources, objective counts, minimum-level and repeatability decisions. The other [provenance files](provenance/) distinguish period reports from later corroboration. Task IDs 3039901–3039912 and new NPC IDs 395900–395907 are authored emulator IDs, not recovered Live IDs.

Known XP rewards with unknown original amounts use the approved **1000 XP PEQ-style default**. Ordinary task XP is in `tasks.exp_reward`; choice tasks carry XP in the common reward entry instead. Do not enable both and pay XP twice. Native task cash and confirmed item rewards are separate. The disputed Widow pollen reward is deliberately excluded.

Exact historical trigger volumes, scene timing/probabilities and some NPC combat values remain unverified. Their reconstructed settings are labelled in the provenance and `achievement_quest_bixie_scenes_data.lua`. Bucket refill is nine minutes from period reports; the empty-harvest probability is an explicit reconstruction. PEQ class spell lists provide level-appropriate casts where exact original spell lists are unavailable.

The Jumjum Reserves barrel uses the original model and position. Its PEQ LDoN treasure class prevented native item hand-ins; the package repairs that interaction class and adds noncombat protections. This is a verified server compatibility repair, not a claim to recover Live's original class field.

Guards spawn at the original thrall point rather than at an arbitrary lateral offset that can cross the farmhouse wall. This positioning is a reconstruction; exact Live guard coordinates remain unknown. Guard kills are not a task objective. Native checks verified five living arrivals and the final reward; guard melee remains unverified.

## Verification and protocol

See [native status](provenance/native-status.json) for the actual gameplay coverage. Builds, offline checks, gameplay and portable installation have distinct scopes. Geared high-level QA travel does not establish historical minimum-level combat balance.

The engine's [opcode and structure reference](../../protocol/README.md) remains available. This content adds no new opcode mapping or packet structure. Tests, raw captures, logs, private accounts, character fixtures and client assets are excluded from this package.

## Required parent gear upgrade

After installing the five Blightfire quest packages, install the complete [Blightfire parent reward upgrade](../blightfire-parent-rewards/README.md). It supplies the eight family reward sets that were unimplemented at this package’s original verification checkpoint. The separate Conqueror meta reward remains unresolved. See that upgrade for its native claim/persistence coverage and historical limits.
