# Champion of the Moors quests

Adds **eight quests, 23 objectives and eight achievement-component bindings**: Pieces of the Past, Historian Pewdri’s Task, Feather for Your Cap, the three Dark Tower quests, The Blightfire Witches, and Return of the Moorwalkers.

Use the original bone pile and corpse loot, collect existing NPC drops, hand in the witches’ staves, fight Defan through his floor-to-roof transition, and weaken each distinct Moorwalker before clicking the original Runestaff. Original NPC placements and spawn timers are retained. Three additional scene actor profiles supply encounter adds; no duplicate bone pile is installed.

All eight quests completed in native RoF2 gameplay, with saved tasks, all eight component bits, parent completion and selected quest rewards. Those records and selected rewards persisted across an actual logout and fresh login. See [native coverage](provenance/native-status.json) for evidence boundaries. One Strall crest was a recorded GM test input; its original weighted drop table was source-audited and retained. Other acquisition and scene actions used the actual client. The parent achievement’s original gear choices are not implemented.

## Install the complete package

Requires the [achievement engine](../../ENGINE.md), **all eight ordered patches**, [Crescent Reach](../crescent/README.md), and [Blightfire Moors](../blightfire-moors/README.md). Patch0008 allows the actual Runestaff click to target the four original Moorwalkers in its quest context. Python 3 and a MariaDB command-line client are required.

Back up your database and quest tree. Stop game services while leaving MariaDB available. Keep players disconnected until every import and script installation succeeds.

Run the read-only checks from this package directory, using a private MariaDB credentials file:

```sh
python3 preflight.py --mysql-command-json '["mariadb","--defaults-extra-file=/private/eq.cnf","peq"]'
python3 apply_quests.py --quests /path/to/server/quests
```

Supply `--additional-quests /other/quest/root` for every other configured quest root. Resolve custom-content conflicts before proceeding. Then import all three SQL files in order and install all scripts together:

```sh
mariadb --defaults-extra-file=/private/eq.cnf peq < sql/010-catalogue.sql
mariadb --defaults-extra-file=/private/eq.cnf peq < sql/020-quests.sql
mariadb --defaults-extra-file=/private/eq.cnf peq < sql/030-scenes.sql
python3 apply_quests.py --quests /path/to/server/quests --apply --backup /path/to/backups/champion-before
```

Restart game services afterward. The installer backs up changed scripts outside the quest tree, chains existing Lua player callbacks, and retains Moonreader Ewera’s existing Perl druid-guild behavior. Conflicting custom NPC, spell and player callbacks require composition. SQL does not import character, inventory, guild or housing tables.

**Native Windows:** substitute `py -3` and Windows paths; check out LF line endings. Use Command Prompt redirection or MariaDB `SOURCE` with absolute SQL paths. Native Windows execution has not been verified.

**Akk-stack:** use the host quest directory mounted into your game container. Feed each SQL file through `docker compose exec -T` using your actual database service and database name. Use your stack’s game-service stop/start procedure and keep MariaDB running for imports.

## Rewards and fidelity

Confirmed item rewards include Pewdri’s sphere, the Feathered Cap, the witches’ signet, the Runestaff belt and Defan’s class-filtered armor choices. Unknown original XP uses the approved **1000 XP PEQ-style default**. Defan uses a common reward entry with task XP zero, preventing duplicate XP.

[Research decisions](provenance/research-decisions.json) separate historical sources, later corroboration, conflicting accounts and reconstructed settings. Exact Crystalwing faction amounts and unspecified cash rewards remain unconfigured. Some minimum levels, encounter timings, spell choices and add profiles are labelled reconstructions. High-level testing does not establish original minimum-level balance.

## Opcodes and structures

The [opcode and packet structure reference](../../protocol/README.md) is available alongside the implementation. This package uses existing task, item-click, spell and reward protocols; it introduces no new opcode or packet layout. Tests, raw logs, private character fixtures and client assets are excluded from public releases.

## Required parent gear upgrade

After installing the five Blightfire quest packages, install the complete [Blightfire parent reward upgrade](../blightfire-parent-rewards/README.md). It supplies the eight family reward sets that were unimplemented at this package’s original verification checkpoint. The separate Conqueror meta reward remains unresolved. See that upgrade for its native claim/persistence coverage and historical limits.
