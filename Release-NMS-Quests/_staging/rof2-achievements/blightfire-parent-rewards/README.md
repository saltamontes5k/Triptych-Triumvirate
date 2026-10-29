# Blightfire achievement gear rewards

This required reward upgrade complements the five Blightfire quest packages. It adds **eight parent achievement reward sets**, with native item IDs and class eligibility. It does not replace quest content or grant quest completion.

| Achievement | Reward |
|---|---|
| Welcome to the Moors | Class-appropriate Rough Consigned helm |
| Battling Blightfire | Melee shield plus eligible weapon choice; casters receive shield and scepter |
| Champion of the Moors | Class-appropriate Rough Consigned boots |
| Job Offers | Soldier or Scryer facemask |
| Two Gnolls With One Stone | Soldier gorget or Scryer necklace |
| Stemming the Threat | Soldier or Scryer cloak |
| Battling the Bixies | Soldier mantle or Scryer scarf |
| Makesn’s Plight | Soldier stake or Scryer wand |

Previously completed achievements receive pending reward offers through the engine’s normal login recovery. Existing delivered rewards are not reset. Common-only class rewards use the same native reward window as choice rewards.

## Install the complete upgrade

1. Install the repository’s engine/schema foundation and all five Blightfire quest packages. Back up the database. Stop game services, leaving MariaDB running; keep players disconnected until the import succeeds.
2. Run the guarded preflight with Python 3 and your actual MariaDB client/database. Use a protected options file for credentials:

   ```sh
   python3 preflight.py --mysql-command-json '["mariadb","--defaults-extra-file=/private/eq.cnf","peq"]'
   ```

3. Import **sql/010-parent-rewards.sql** into that same database through your SQL client. Stop on an error; do not remove identity/conflict guards to force an import. This file contains the entire eight-set upgrade. No quest-script copy or server rebuild is required beyond the engine foundation.
4. Restart game services and reconnect. A character with completed achievements can claim the corresponding gear through the native reward window.

The import modifies only reward configuration tables. It contains no character, inventory, guild or housing table data, and it does not delete existing reward ledgers.

### Native Windows

Use native Windows executables with Python 3; WSL is not required:

```powershell
py -3 preflight.py --mysql-command-json '["C:/MariaDB/bin/mariadb.exe","--defaults-extra-file=C:/private/eq.cnf","peq"]'
```

Import the same SQL file while game services are stopped. Adjust paths/database names. Native Windows execution of this upgrade has not been performed.

### Akk-stack

Run the preflight from your stack directory using the database service command, for example:

```sh
python3 /path/to/package/preflight.py --mysql-command-json '["docker","compose","exec","-T","mariadb","mariadb","--defaults-extra-file=/private/eq.cnf","peq"]'
```

Import the same SQL into the stack database and restart game services. Service names and options-file paths vary by installation.

## Evidence and historical limits

[Reward specification](provenance/parent-rewards.json) records the source for every set; the [class matrix](provenance/class-matrix.json) records all sixteen classes. Current Allakhazam pages were entered in March 2012 but edited in September 2026; they are not archived May 2013 snapshots. Modern minimum/maximum levels are not imported as historical claim gates.

The Battling Blightfire description lists five weapons, while its explicit reward links add Halberd. The six explicitly listed options are included. Other similarly named native weapons are not inferred into the set. The canonical melee shield class mask excludes Berserker; original Berserker common-shield behavior remains unverified.

**Conqueror of Blightfire’s separate meta-achievement gear bundle remains unconfigured** until its complete selection/bundle semantics are established. Unconfirmed parent XP, AA, cash and faction awards are not invented. See [native verification status](provenance/native-status.json) for tested coverage.

## Opcodes and structures

The repository includes [all twelve achievement/reward mappings and packet layouts](../../protocol/README.md). This upgrade uses that existing protocol and adds no opcode or structure. Public files exclude tests, raw logs, private fixtures and client assets.
