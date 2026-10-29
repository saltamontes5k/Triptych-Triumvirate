# Welcome to the Moors quests

Adds **eight quests, 39 objectives and eight achievement-component bindings** for Welcome to the Moors (21–25): Ordunn's three Golden Pick quests, Ozzana's Darkwater Pools, Slashclaw Cliffs and Ghostpack Fens, Hammerstock's Ticking Crocodile, and Ella's Witchlamps.

The quests use original NPC placements and corpse drops. Equip the Golden Pick to uncover ore in three mines, click the original trap on a living slashclaw cub, and rescue the ratwork through a real walk back to camp. Native task and reward systems handle the objectives, hand-ins and confirmed quest rewards.

All eight quests completed in native RoF2 gameplay, with saved task completions, all eight component bits and parent completion. See [native coverage](provenance/native-status.json) for persistence checks and limitations. The parent achievement's original gear choices remain under investigation and are not supplied here.

## Install the complete package

Requires the [achievement engine](../../ENGINE.md), including **all seven ordered patches**, [Crescent Reach](../crescent/README.md) and [Blightfire Moors](../blightfire-moors/README.md) content. Patch0007 is required for the original cub trap to target its intended NPCs. Python 3 and a MariaDB command-line client are required.

Back up your database and quest tree. Stop game services during the upgrade, leaving MariaDB available, and keep players disconnected until the complete import and script installation succeed.

From this package directory, check your content and quest tree:

```sh
python3 preflight.py --mysql-command-json '["mariadb","--defaults-extra-file=/private/eq.cnf","peq"]'
python3 apply_quests.py --quests /path/to/server/quests
```

Use a private MariaDB option file for credentials. Add `--additional-quests /other/quest/root` for every other configured quest root. Resolve any reported custom-content conflicts before continuing.

Import both SQL files in order, then install all scripts and the composed global-player hook:

```sh
mariadb --defaults-extra-file=/private/eq.cnf peq < sql/010-catalogue.sql
mariadb --defaults-extra-file=/private/eq.cnf peq < sql/020-quests.sql
python3 apply_quests.py --quests /path/to/server/quests --apply --backup /path/to/backups/welcome-before
```

Restart game services afterward so every zone reloads the task catalogue together. The installer backs up modified scripts outside the quest tree and chains existing Lua player callbacks. It upgrades known Ozzana and Bronson callbacks while retaining their original behavior. Conflicting NPC, spell, module and Perl player callbacks require manual composition. SQL does not import character, inventory, guild or housing tables.

**Native Windows:** use `py -3` instead of `python3`, Windows paths, and LF checkout line endings (`git -c core.autocrlf=false clone ...`). Use Command Prompt for SQL redirection, or `SOURCE` with absolute SQL paths inside MariaDB. The Python installer uses portable filesystem APIs; native Windows execution has not been verified.

**Akk-stack:** select the host quest directory mounted into your game container. Feed each SQL file through `docker compose exec -T` using your stack's actual MariaDB service and database. Use your stack's game-service stop/start procedure; keep the database running for imports.

## Rewards and historical fidelity

Confirmed quest rewards are the Golden Pick III class-filtered bracer selection, Slashclaw Pelt Cloak, and **ten Elixir of Clear Mind potions** (item53524). Unknown original XP amounts use the approved **1000 XP PEQ-style default**. Golden Pick III pays this through its common reward entry and leaves task XP at zero to avoid duplicate XP.

[Research decisions](provenance/research-decisions.json) distinguish dated historical evidence, later corroboration and reconstruction. Minimum-level and repeatability conflicts retain explicit provenance. Authored task IDs 3040101–3040108 and scene NPC IDs 395920–395921 are emulator identifiers. Original drops and spawn timers are retained.

Exact original scene trigger volumes, crocodile spawn probability, ratwork timings, some NPC combat/model values, and certain minimum levels remain labelled reconstructions or best-supported selections. High-level test combat does not establish original minimum-level balance. These limitations do not constitute exact Live parity.

## Opcodes and structures

The [opcode and packet structure reference](../../protocol/README.md) remains available. These quests use the existing task, item, spell and reward protocols; no new opcode mapping or packet layout is introduced. Public files exclude tests, captures, raw logs, private fixtures and client assets.

## Required parent gear upgrade

After installing the five Blightfire quest packages, install the complete [Blightfire parent reward upgrade](../blightfire-parent-rewards/README.md). It supplies the eight family reward sets that were unimplemented at this package’s original verification checkpoint. The separate Conqueror meta reward remains unresolved. See that upgrade for its native claim/persistence coverage and historical limits.
