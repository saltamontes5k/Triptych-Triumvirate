# Triptych Triumvirate — LAN server release

A complete, working **multiclass EverQuest server** (EQEmu-based, RoF2 client), released as a
LAN-oriented community server. Everything in this repo is tuned for play on a local network.

> **LAN only.** This release is intended for private/local-network play, of course it can be tweaked for network at discretion.

---

### This update's changes (9/9)

- **Melee while casting/moving** — balance patch; toggleable via `Custom:AllowAttackWhileCasting` (default **false**)
- **Bow AA ↔ thrown AA** — bow AA now affects thrown AA and vice-versa
- **Brother Hayn** spawns in Karana (Kree)
- **Test of Think** fix
- **Epic 1.0 title** fix
- **Tome AA** reflects reality with multiclass consideration; untrain / untrain all / recycle / downgrade
- **Scaffold progression** up to SoF; blueprint for DoN / LDoN / GoD
- **Inventory overflow fix** (chadw)
- **Mail-key bug** (chadw)
- **Kick math calcs include base skill** (chadw)
- **Allow beneficial spells vs slow/snare immunity** (chadw)
- **Summon timer override per NPC** (chadw)
- **Loot message shows quantity** (chadw)
- **Hero forge on char select fixes** (chadw)
- **Movement delta fixes** (chadw)
- **dinput8 MQ2 crash fixes** (riker)
- **dinput8 crash patch + NMS_WaypointsWnd.xml fix** (Rockin-Vik)

### Earlier (8/30)

- **spell_effects** fixes (chadw)
- **Leap** movement fix (chadw)
- **#illusion** storage (new `character_illusions` table) (chadw)
- **Target restriction** 99 → 95 (chadw)
- **XTarget** fixes (partial, chadw's EQEmu repo)
- **Offline bazaar** (valorith/nekkola, chadw's EQEmu repo)
- **Mount glamour merchant** and **languages**
- **Tome trainers** moved to bazaar backrooms
- **Bestial alignment AA racial fix** (idunknown)
- **Godmode rune bug** fix, particularly on pets (Doraj & Kree)
- **2H damage / #attack** fix and the **permanent glowing hand** bug (hawk & animal)
- Item **discoverability on summon** (not entirely working yet)

## What is in here

| Folder | What it is |
| --- | --- |
| [`Release-NMS-Server/`](Release-NMS-Server/) | The server (EQEmu-based), pre-built binaries, and the database dump |
| [`Release-NMS-Client/`](Release-NMS-Client/) | `dinput8.dll` client add-on + the modified UI files |
| [`Release-NMS-Quests/`](Release-NMS-Quests/) | Quest scripts (Perl / Lua) |
| [`Release-NMS-Plugins/`](Release-NMS-Plugins/) | Perl plugins the quests depend on |

Each folder has its own README with detailed instructions. Start with the server.

## What makes it different

- **Multiclassing** — a character can take up to three classes at once
- **Multiple pets** — pet classes control several pets, with a custom pet window
- **Echo of Memory** — an alternate currency that drops from kills and buys unlocks
- **Item upgrade tiers** — drops can roll as Enchanted or Legendary versions
- **Offline bazaar** — offline trader/buyer/barter support
- **Glamour & languages** — mount glamour merchant, armour glamour, and a languages trainer
- **Tome trainers** — located in the bazaar backrooms
- Assorted client-side quality-of-life fixes, shipped as `dinput8.dll`

---

## Quick start (LAN)

**1. Get a client.** EverQuest client files are Daybreak's — not included and cannot be. You
will need the RoF2-era client this server was built against. See
[the client README](Release-NMS-Client/README.md) for what to do with it.

**2. Get the map files.** The `maps/` folder is **not** included in this repository (too large
for GitHub). Sourcing map packs is a one-time download:
- `.map` files live under `maps/base/` and `maps/legacy/base/`
- `.nav` files live under `maps/nav/` and `maps/legacy/nav/`
- `.zon` water mesh files live under `maps/water/`

Any current EQEmu map pack for the zones in this server works. Drop them into `maps/` in the
server folder.

**3. Set up the database.** Unzip `Release-NMS-Server/database/release-peq.zip` and import it
into an empty schema. It contains **no player data** — it is a fresh world.

**4. Run the server.** Pre-built Windows binaries are in `Release-NMS-Server/bin/Release/`
(`world.exe`, `zone.exe`, `ucs.exe`, `queryserv.exe`, `loginserver.exe`, `eqlaunch.exe` and
`shared_memory.exe`, plus their DLLs and opcode/patch configs). Copy
`eqemu_config.json.example` and `login.json.example` to their real names and set your DB
credentials, then start `world.exe` (or use the included `start-servers.bat`).

Prefer to build from source instead? See **Building** below.

**5. Install quests and plugins.** Copy `Release-NMS-Quests/` into your server's `quests/` folder
and `Release-NMS-Plugins/` into `quests/plugins/`.

**6. Client data files.** `spells_us.txt`, `dbstr_us.txt`, `SkillCaps.txt` and `BaseData.txt`
are generated from the server DB and are **not shipped** in this repo. With the database
imported and `eqemu_config.json` in place, run:

```
export-client-files.bat <your-EQ-client-folder>
```

It runs the exporter and copies all four files into your client folder and its `Resources\`
folder. Re-run any time you change spells, skills or item text in the database.

**7. Install the client add-on.** Copy `Release-NMS-Client/ClientFiles/` over your client.
See [the client README](Release-NMS-Client/README.md) — it also covers the known art gaps.

---

## Building

The build produces the usual EQEmu binaries: `world`, `zone`, `ucs`, `queryserv`,
`loginserver` and `eqlaunch`.

Verified to compile clean with **MSVC 2022**, **clang 14**, and **GCC 12**.

### Windows

You need **Visual Studio 2022** with the *Desktop development with C++* workload. That
workload includes CMake, so there is usually nothing else to install.

Run:

```
build_server.bat
```

It generates `Build\EQEmu.sln` for your machine — then open that solution, pick
**Release / x64**, and Build. Binaries land in `Build\bin\Release\`.

Prefer to do it by hand?

```
cmake -S . -B Build -G "Visual Studio 17 2022" -A x64 -DEQEMU_BUILD_LOGIN=ON
cmake --build Build --config Release
```

The **first** configure needs an internet connection: CMake downloads the prebuilt Windows
dependencies into `vcpkg\` on its own.

### Linux

Install the dependencies (Debian/Ubuntu):

```
sudo apt install build-essential cmake ninja-build git \
     libmysqlclient-dev libperl-dev libboost-dev liblua5.1-0-dev \
     zlib1g-dev uuid-dev libssl-dev
```

---

## Future Plans
- More modernization to match more current versions of EQEMU
- Various changes that catch eye
- Deity quest gated weapon and spell procs
---

## Credits

  Tunaria Team — OG NMS / Project Triune
  Straps — Ascendant tome system plugins and trainers
  Devs of Quarm server — Cazic-Thule revamp
  chadw — spell_effects fixes, Leap movement fix, #illusion storage, Target restriction 99→95, XTarget fixes, offline bazaar, inventory overflow, mail-key bug, kick math calcs, beneficial spells vs slow/snare immunity, summon timer override per NPC, loot message quantity, hero forge char select, movement delta fixes
  huggy / sploose — Hazel buff bot
  zerohex — Purveyor of Armour Glamour
  dritjoda — Lost Soul Diablo-style augmentation system
  Palpinator87 — gambling script for the halfling
  valorith / nekkola — offline bazaar
  idunknown — bestial alignment AA racial fix
  Doraj / Kree — godmode rune bug fix, Brother Hayn Karana spawn
  hawk & animal — 2H damage / #attack fix, permanent glowing hand bug
  riker — dinput8 MQ2 crash fixes
  Rockin-Vik — dinput8 crash patch + NMS_WaypointsWnd.xml fix

## Requirements

- **Server:** CMake 3.12+ (4.x works), a C++17 compiler, MariaDB 10.6+ or MySQL 8.0, Perl
- **Client add-on:** Visual Studio 2022 with the *Desktop development with C++* workload
  (build as **Win32/x86** — the client is 32-bit)

## Licensing

The server is derived from the [EQEmu project](https://github.com/EQEmu/Server) and carries its
GPL licensing. The client add-on and the quest scripts are MIT, with their original copyright
notices intact — see the `LICENSE` file in each folder.

EverQuest is a registered trademark of Daybreak Game Company. This project is not affiliated with
or endorsed by Daybreak, and contains no EverQuest client files.
