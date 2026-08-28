# NMS Server

A complete, working **multiclass EverQuest server** — a community remake built on
EQEmu. This repository is a sanitized snapshot of the live NMS server, safe to
share or build on with some customized tweaks.

**This code and all derivative works are the fruit of an educational project by
many students and will always be free!**

See **[CHANGELOG.md](CHANGELOG.md)** for everything that changed relative to the
upstream [`tunaria/NMS-Release`](https://github.com/tunaria/NMS-Release)
baseline.

I plan to branch this and hopefully modernize the EQEmu/PEQ database snapshot it uses sometime in the future and do other various changes that catch my eye. Next major ones are hopefully a offline bazaar trader/seller system and an Ultimate EQ/Imperium Emu inspired style weapon proc and spell proc lines that are deity quest gated.

---

## What is in here

| Folder / file | What it is |
| --- | --- |
| `Release-NMS-Server/` | The server (EQEmu-based) and the sanitized database dump |
| `Release-NMS-Client/` | `dinput8.dll` client add-on + the modified UI files |
| `Release-NMS-Quests/` | Quest scripts (Perl / Lua) |
| `Release-NMS-Plugins/` | Perl plugins the quests depend on |
| `maps/` | The map pack the server uses |
| `ascendant_tome_system.sql` | Cross-class AA training (tome) system — standalone import |
| `CHANGELOG.md` | All changes vs the upstream baseline |
| `*.bat` | Helper scripts: `build_server`, `rebuild_server`, `start-servers`, `stop-servers`, `spire` |

## What makes it different 

- **Cross-class AA Tome system** — hunt illegible tomes, train AAs from other
  classes at Bazaar guild master trainers; recycle a tome to reshape it into a
  different class's same-tier tome
- **Drakkin breath weapons** — racial breath AA line, 13 ranks (lvl 5 → 65) autogrants every 5 lvls
- **Lost Soul augs** — Diablo-style randomized Lost/Restless/Found Soul
  augmentations from the `aug_generator` (NEW)
- **Multiclassing** — a character can take up to three classes at once
- **Multiple pets** — pet classes control several pets, with a custom pet window
- **Echo of Memory** — an alternate currency that drops from kills and buys unlocks
- **Item upgrade tiers** — drops can roll as Enchanted or Legendary versions
- Assorted client-side quality-of-life fixes, shipped as `dinput8.dll`

---

## Credits

- **huggy / sploose** — Hazel buff bot
- **zerohex** — Purveyor of Armour Glamour
- **dritjoda** — Lost Soul Diablo-style augmentation system
- **Straps** — Ascendant tome system plugins and trainers
- Tunaria Team for OG NMS/Project Triune

See **[CHANGELOG.md](CHANGELOG.md)** for the full change list and per-commit
breakdown vs the upstream [`tunaria/NMS-Release`](https://github.com/tunaria/NMS-Release)
baseline.

## Quick start

**1. Get a client.** Not included and cannot be — EverQuest client files are
Daybreak's. You need the RoF2-era client this server was built against. See
[the client README](Release-NMS-Client/README.md).

**2. Set up the database.** Unzip
`Release-NMS-Server/database/release-peq-sanitized.zip` and import the contained
`release-peq-sanitized.sql` into an empty schema:

```
mysql -u root -p -e "CREATE DATABASE peq;"
mysql -u root -p peq < "Release-NMS-Server\database\release-peq-sanitized.sql"
```

It contains **no player data** — accounts and characters are wiped. The Drakkin
breath AAs and the Ascendant tome system are already included. If you want to add
the tome system to an existing database instead, import `ascendant_tome_system.sql`.

**3. Build the server.** Windows: run `build_server.bat`, then open
`Build\EQEmu.sln`. Linux: `make`. Verified against MSVC 2022, clang 14 and GCC 12.
Details in [the server README](Release-NMS-Server/README.md).

**4. Install quests and plugins.** Copy `Release-NMS-Quests/` into your server's
`quests/` folder and `Release-NMS-Plugins/` into `quests/plugins/`.

**5. Install maps.** Copy `maps/` into your server's `maps/` folder.

**6. Generate the client data files.** With the database imported, run
`export_client_files` from the server folder. It writes `spells_us.txt`,
`dbstr_us.txt`, `SkillCaps.txt` and `BaseData.txt` — copy them into your client
(and its `Resources\` folder).

**7. Install the client add-on.** Copy `Release-NMS-Client/ClientFiles/` over
your client. See [the client README](Release-NMS-Client/README.md).

**8. Start the server.** Run `start-servers.bat` (or launch the executables /
Spire). Everyone starts fresh — no existing player accounts.

> **Note:** you must replace the placeholder credentials in
> `Release-NMS-Server/eqemu_config.json` and `Release-NMS-Server/login.json`
> (database password and the Spire `encryption_key`) with your own values.

---

## Requirements

- **Server:** CMake 3.12+ (4.x works), a C++17 compiler, MariaDB 10.6+ or
  MySQL 8.0, Perl
- **Client add-on:** Visual Studio 2022 with the *Desktop development with C++*
  workload (build as **Win32/x86** — the client is 32-bit)

## Licensing

The server is derived from the [EQEmu project](https://github.com/EQEmu/Server) and NMS server
and carries its GPL licensing. The client add-on and the quest scripts are MIT,
with their original copyright notices intact — see the `LICENSE` file in each
folder. The Ascendant tome system is from the
[Ascendant-EQ-Emu/Ascendant-Server](https://github.com/Ascendant-EQ-Emu/Ascendant-Server)
project (GPL-3.0).

EverQuest is a registered trademark of Daybreak Game Company. This project is not
affiliated with or endorsed by Daybreak, and contains no EverQuest client files.
