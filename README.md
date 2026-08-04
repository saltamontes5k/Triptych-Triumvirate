# NMS Server — community release

This has been engineered by hardworking community developers for public release. Play the Official Project Triune Server at https://discord.gg/PkAFVSHZCz

**This code and all derivative works are the fruit of an educational project by many students and will always be free!**


A complete, working **multiclass EverQuest server**, released as a base for anyone who wants to run
one or build their own on top of it.

This is a remake of a multiclass server, built to the best of our ability, and published as a
one-time snapshot. It is not maintained here. Take it and remake it into something of your own —
rename it, strip out what you do not want, add whatever you do.

---

## What is in here

| Folder | What it is |
| --- | --- |
| [`Release-NMS-Server/`](Release-NMS-Server/) | The server (EQEmu-based) and the database dump |
| [`Release-NMS-Client/`](Release-NMS-Client/) | `dinput8.dll` client add-on + the modified UI files |
| [`Release-NMS-Quests/`](Release-NMS-Quests/) | Quest scripts (Perl / Lua) |
| [`Release-NMS-Plugins/`](Release-NMS-Plugins/) | Perl plugins the quests depend on |

Each folder has its own README with detailed instructions. Start with the server.

## What makes it different

- **Multiclassing** — a character can take up to three classes at once
- **Multiple pets** — pet classes control several pets, with a custom pet window
- **Echo of Memory** — an alternate currency that drops from kills and buys unlocks
- **Item upgrade tiers** — drops can roll as Enchanted or Legendary versions
- Assorted client-side quality-of-life fixes, shipped as `dinput8.dll`

---

## Quick start

**1. Get a client.** Not included and cannot be — EverQuest client files are Daybreak's. You will
need the RoF2-era client this server was built against. See
[the client README](Release-NMS-Client/README.md) for what to do with it.

**2. Set up the database.** Unzip `Release-NMS-Server/database/release-peq.zip` and import it into
an empty schema. It contains **no player data** — it is a fresh world.

**3. Build the server.** Windows: run `build-windows.bat`, then open `Build\EQEmu.sln`.
Linux: `make`. Verified against MSVC 2022, clang 14 and GCC 12.
Details in [the server README](Release-NMS-Server/README.md).

**4. Install quests and plugins.** Copy `Release-NMS-Quests/` into your server's `quests/` folder
and `Release-NMS-Plugins/` into `quests/plugins/`.

**5. Generate the client data files.** With the database imported, run `export_client_files` from
the server folder. It writes `spells_us.txt`, `dbstr_us.txt`, `SkillCaps.txt` and `BaseData.txt`
— copy them into your client (and its `Resources\` folder).

**6. Install the client add-on.** Copy `Release-NMS-Client/ClientFiles/` over your client.
See [the client README](Release-NMS-Client/README.md) — it also covers the known art gaps.

---

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
