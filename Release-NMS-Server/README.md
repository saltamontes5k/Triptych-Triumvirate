# NMS Server

A custom EverQuest server built on [EQEmu](https://github.com/EQEmu/Server), for the
**RoF2** client.

## About this release

This is a remake of a multiclass server, built to the best of our ability, and released so
that anyone who wants to run one has a working foundation instead of starting from scratch.

It is a one-time snapshot and is not maintained here. Take it and remake it into something
of your own — rename it, strip out what you do not want, add whatever you do.

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
build-windows.bat
```

It generates `Build\EQEmu.sln` for your machine — then open that solution, pick
**Release / x64**, and Build. Binaries land in `Build\bin\Release\`.

Prefer to do it by hand?

```
cmake -S . -B Build -G "Visual Studio 17 2022" -A x64 -DEQEMU_BUILD_LOGIN=ON
cmake --build Build --config Release
```

The **first** configure needs an internet connection: CMake downloads the prebuilt Windows
dependencies (~132 MB) into `vcpkg\` on its own.

> The Visual Studio solution is **not** included in this repository on purpose. CMake bakes
> absolute paths into it, so a solution generated on someone else's PC will not work on
> yours — always generate your own.

### Linux

Install the dependencies (Debian/Ubuntu):

```
sudo apt install build-essential cmake ninja-build git \
     libmysqlclient-dev libperl-dev libboost-dev liblua5.1-0-dev \
     zlib1g-dev uuid-dev libssl-dev
```

Then, from the source root:

```
make                              # auto-detects your compiler
make CC=clang CXX=clang++         # force clang
make CC=gcc-12 CXX=g++-12         # force a specific gcc
```

Other targets: `make clean`, `make distclean`, `make rebuild`, `make help`.
Binaries land in `build/bin/`.

### Requirements

- CMake 3.12 or newer (CMake 4.x works)
- A C++17 compiler
- MariaDB 10.6+ or MySQL 8.0
- Perl (for quest scripting)

---

## Database

The dump is in [`database/release-peq.zip`](database/release-peq.zip) (~40 MB zipped, ~540 MB
unpacked). Unzip it and import into an empty schema:

**Linux / macOS**

```
unzip database/release-peq.zip
mysql -u <user> -p <dbname> < release-peq.sql
```

**Windows**

```
tar -xf database\release-peq.zip
mysql -u <user> -p <dbname> < release-peq.sql
```

It contains **no player data** — accounts, characters, inventories, guilds, mail and corpses
all start empty, so this is a fresh world. The first account you create becomes yours; grant
it GM status with:

```
UPDATE account SET status = 250 WHERE name = '<your login>';
```

The server keeps its own schema up to date on boot through a custom migration manifest, so
you should not need to run migrations by hand. To audit what actually landed in your
database:

```
mysql -u <user> -p <dbname> < utils/sql/nms_content_health_check.sql
```

Every line prints its own expected value, so anything that disagrees points at the exact
payload that is missing.

---

## Layout

| Path | What it is |
| --- | --- |
| `world/` | world server — login, character select, zone orchestration |
| `zone/` | zone server — gameplay, spells, combat, quests |
| `common/` | shared code, database repositories, packet structures |
| `loginserver/` | optional standalone login server |
| `libs/`, `submodules/` | bundled dependencies (required — do not delete) |
| `utils/` | SQL, scripts and maintenance tools |

## Credits

Built on the work of the [EQEmu project](https://github.com/EQEmu/Server) and its
contributors. EverQuest is a registered
trademark of Daybreak Game Company. This project is not affiliated with or endorsed by
Daybreak.
