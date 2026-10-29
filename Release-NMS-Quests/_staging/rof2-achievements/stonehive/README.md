# Stone Hive: scouts, botany, cooking and Warwing

This package installs **16 quests, 33 objectives and 16 achievement bindings** across four Hero’s Journey achievements. It includes the quest givers, ordered scout and Warwing chains, research-area triggers, original ground-pickup repairs, Juzzulli, Neezzee, Queen Pelzia’s encounter, confirmed quest rewards and the scripts required for them.

All 16 quests completed in native RoF2 gameplay. The four parent achievement reward sets are included. See [verification and fidelity status](provenance/native-status.json) for the evidence boundaries and historical uncertainties.

| Achievement family | Quests | Main behavior |
|---|---:|---|
| Scouts | 5 | Deliveries, automatic follow-ons, research areas, ground items and Juzzulli |
| Botanist Brezuu | 3 | Original petal, seed and sap collection routes |
| Cook Idriak | 4 | Original delivery objectives, prerequisite order and item rewards |
| Warwing Wendlez | 4 | Neezzee, war plans, disguise materials and Queen Pelzia |

The package retains the original NPC placements and weighted loot tables. Fungus patches already supply botany materials; no scripted guaranteed sap is added. The dependency modules included here retain earlier quest-delivery behavior at Cook Idriak.

## Install the whole package

Install the repository’s engine/schema foundation first, including patches `0001` through `0008`. Python 3 and a MariaDB-compatible command-line client are needed for the checks. Use a protected database options file; keep credentials out of commands and screenshots.

1. Back up your database and quest directory. **Stop all game services while leaving MariaDB running.** Keep players disconnected until every step succeeds.
2. From this folder, run the database and quest-file preflights:

   ```sh
   python3 preflight.py --mysql-command-json '["mariadb","--defaults-extra-file=/private/eq.cnf","peq"]'
   python3 apply_quests.py --quests /path/to/quests
   ```

   Substitute your actual database and paths. A conflict is a request to merge existing custom content, not permission to overwrite it.
3. Import these files into the same database, in this order: `sql/010-catalogue.sql`, `sql/020-quests.sql`, `sql/030-scenes.sql`, `sql/040-parent-rewards.sql`. Every file is required. Open and execute them in your SQL client, or use that client’s SQL-file import facility. Stop on the first error.
4. Install the complete script set with a **new backup folder outside the quest tree**:

   ```sh
   python3 apply_quests.py --quests /path/to/quests --apply --backup /path/to/backups/stonehive
   ```

5. Restart all game services, then reconnect. A quest/task reload in one occupied zone does **not** refresh an idle zone process’s old task catalogue; do not replace this restart with a hot reload.

The installer checks release hashes, preserves the earlier Cook script when its known version is present, chains existing global Lua callbacks and refuses competing custom scripts. SQL imports contain no character, inventory, guild or housing table data.

### Native Windows servers

The scripts and installer are designed for native Windows server executables; WSL is not required. Replace `python3` with `py -3` and use Windows paths:

```powershell
py -3 preflight.py --mysql-command-json '["C:/MariaDB/bin/mariadb.exe","--defaults-extra-file=C:/private/eq.cnf","peq"]'
py -3 apply_quests.py --quests C:\EQEmu\quests
py -3 apply_quests.py --quests C:\EQEmu\quests --apply --backup C:\EQEmu-backups\stonehive
```

Import all four SQL files between the file preflight and `--apply`, while game services remain stopped. Adjust the MariaDB executable location. Native Windows execution of this content installer has not yet been verified; its filesystem operations use Python’s standard library.

### Akk-stack

Use the host quest directory mounted into the game container. Stop the stack’s game services, keep its database service running, and execute the preflight with a command array appropriate to that stack. For example, when an options file is available inside a service named `mariadb`:

```sh
python3 /path/to/this/package/preflight.py --mysql-command-json '["docker","compose","exec","-T","mariadb","mariadb","--defaults-extra-file=/private/eq.cnf","peq"]'
```

Run that command from your stack directory. Import all four SQL files through the same database service, install scripts into the mounted host quest directory and restart the game services. Service names, credentials-file paths and database names vary between stacks.

## Rewards, defaults and known limits

Confirmed **quest item rewards** are included. Original XP amounts remain unknown, so the supplied **1000 XP PEQ-style defaults** are labelled in the [quest specification](provenance/quest-specification.json). The configurable XP fields are `tasks.exp_reward` for ordinary tasks and the two common XP entries in `rewards` for tasks with class-filtered choices. Choice tasks have task XP zero to prevent duplicate XP.

[Scout](provenance/research-scouts.json), [collection/cooking](provenance/research-collections.json) and [Warwing](provenance/research-warwing.json) research distinguish period reports from later corroboration. Some minimum levels, repeatability choices, potion stack quantities, encounter statistics, actor models, timers and the disguise spell identity remain labelled uncertainties or reconstructions. The [four parent reward sets](provenance/parent-rewards.json) include class-filtered bracers, paired earrings, paired rings and Warwing shield/weapon bundles. Modern source copies are distinguished from period comments; the full original Warwing option list and Berserker common-shield behavior remain unverified. Unconfirmed parent XP, AA, cash and faction awards are not invented. Earlier-zone parent gear rewards remain separate unfinished work. High-level verification does not establish minimum-level balance or shared-task parity. Queen combat demonstrated both add families and periodic spell attempts; the room tether and exact original actor models remain unverified in native gameplay.

## Opcodes and structures

The [opcode and packet structure reference](../../protocol/README.md) is included in this repository. Stone Hive uses existing task, item, ground-pickup, spell, achievement and reward messages; it adds **no new opcode or packet layout**. Public releases exclude tests, raw logs, private character fixtures and client assets.
