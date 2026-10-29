# Battling Blightfire quests

Adds seven quests, 24 objectives and seven component bindings for **Battling Blightfire (26–30)**: Akins' Dead Wood chain, Gubjak's two Nokk rituals, and The Fallen Dragon.

The quests use original NPC placements and corpse drops. The Spirit Wand attunes at the crater, casts Lore Siphon on an eligible giant, and enables the original conversation. Gubjak walks to the circle; shades appear during the fire ritual. Clicking skulls summons pairs of guardians. Native task and reward systems handle objectives, deliveries and confirmed quest rewards.

**All seven quests completed in native RoF2 gameplay, and all seven component bits plus parent completion persisted across logout/login.** Quest completion and the parent achievement's gear reward are separate. Its original gear choices are under investigation and are not supplied by this package yet. See [native coverage](provenance/native-status.json) for exact checks and limits. This is not a claim that every Hero's Journey achievement or reward is complete.

## Install the whole package

Requires the [achievement engine](../../ENGINE.md), including all six ordered patches, and [Crescent Reach content](../crescent/README.md). Python 3 and a MariaDB command-line client are required. Back up your database and quest tree. Stop game services during the upgrade, leaving MariaDB available; restart them afterward so all zones reload the task catalogue together. Do not import while players are connected.

Linux, native Windows and Akk-stack use the same Python installer. On Windows use `py -3`, Windows paths and LF checkout line endings (`git -c core.autocrlf=false clone ...`). For Akk-stack, use the host path mounted as the server's quest tree, and run database commands against your actual MariaDB service and database.

Run these checks from this package directory before importing anything:

```sh
python3 preflight.py --mysql-command-json '["mariadb","--defaults-extra-file=/private/eq.cnf","peq"]'
python3 apply_quests.py --quests /path/to/server/quests
```

Use a private MariaDB option file for credentials. Pass `--additional-quests /other/quest/root` for each other configured quest root. Resolve reported custom scripts or identity conflicts before proceeding; do not force an overwrite.

Import both SQL files in order, then install every script and compose both player hooks:

```sh
mariadb --defaults-extra-file=/private/eq.cnf peq < sql/010-catalogue.sql
mariadb --defaults-extra-file=/private/eq.cnf peq < sql/020-quests.sql
python3 apply_quests.py --quests /path/to/server/quests --apply --backup /path/to/backups/spirits-before
```

On Windows, use Command Prompt for SQL redirection, or run `SOURCE` with each absolute SQL path inside the MariaDB client. Akk-stack users can feed each SQL file through `docker compose exec -T` using their own stack's service names. Restart game services when the complete import and script installation have succeeded.

The installer upgrades the known released Akins script while retaining its earlier Catacombs and Ogre quests. Existing Lua player callbacks are chained. Conflicting NPC, module, spell and Perl player callbacks are rejected for manual composition. Modified files are backed up outside the quest tree. The SQL does not import character, inventory, guild or housing tables.

## Rewards and historical choices

Confirmed quest rewards include Akins' class-filtered augment selection, Mark of the Searing Dawn and Selay's Shed Tooth. Unknown original XP amounts use the approved **1000 XP PEQ-style default**. The augment-selection task puts XP in its common reward entry and leaves task XP at zero to avoid duplicate payment.

The [research decisions](provenance/research-decisions.json) distinguish dated evidence from later corroboration and reconstruction. Authored task IDs 3040001–3040007 and scene NPC IDs 395910–395913 are emulator identifiers. Original drops and spawn timers are retained. Modern group-wide drop changes are excluded.

Some level and repeatability rules have conflicting historical sources; the selected values retain explicit provenance labels. Five skull clicks and ten guardians are the best-supported journal arrangement, but its exact May 2013 cutoff remains uncertain. Original scene trigger volumes, wand success probability, some NPC combat values and model details remain labelled reconstructions in the specification and scene data. High-level test combat does not establish original minimum-level balance.

## Opcodes and structures

The engine's [opcode and packet structure reference](../../protocol/README.md) remains available. These quests use existing task, spell, item and reward protocols; this package introduces no new opcode mapping or packet layout. Tests, captures, logs, private fixtures and client assets are excluded from public content.

## Required parent gear upgrade

After installing the five Blightfire quest packages, install the complete [Blightfire parent reward upgrade](../blightfire-parent-rewards/README.md). It supplies the eight family reward sets that were unimplemented at this package’s original verification checkpoint. The separate Conqueror meta reward remains unresolved. See that upgrade for its native claim/persistence coverage and historical limits.
