# Triptych Triumvirate — LAN server release

A complete, working **multiclass EverQuest server** (EQEmu-based, RoF2 client), released as a
LAN-oriented community server. Everything in this repo is tuned for play on a local network.

> **LAN only.** This release is intended for private/local-network play, of course it can be tweaked for network at discretion.

---

### This update's changes (9/25)
- Fabled in (Rockin-Vik)
- more scaffolding, put in expansion tracker npcs, again completion dubious
- Deity procs in (details far below), inspired by Imperium's aug line descriptions
- housing and shrouds working a touch better, still sketchy
- fixed doors to guild lobby
- boosted everyone's charm spells
- damage aa for spells stack better
- drakkin breaths stack with malo/tash
- aa gem ability to spend down aas
- have powar in place, more scaffolding up to tbs, npcs have glitchy faction, bad hps, missing abilities, etc needs profound testing and tuning
- moved some silly death looping char choices to shar vahl, cats don't care
- #petition system wired in
- pet negative damage bug
- bard spmg clicky spellgem UI lockup bug
- 

### This update's changes (9/14)

- **Prophecy of Ro** — Theater of Blood / Deathknell / Razorthorn access chains, ToB armor
  drops + raid lockouts, phase 2/3/5 side quests, raids (Burning Prince, Sullon Zek, Suchun,
  Daosheen, Freeport Arena, Corruption of Ro), Spirit Mark Armor, Arcstone, Tunare's Shrine,
  Black Orb of the Scrykin (rough, not quite completable, more scaffolding)
- **GoD** — Qinimi events solo-requestable; Nalasrine stocks Muramite armor solvents
- **Water theme** — First Ripple / Mal'zeth V'Tide questlines; **Echo of Memory renamed to
  Triune of Fate** (matches modern upstream; client add-on + NPC updates)
- **Heroic stats** — reworked to better represent actual classes, dinput8 also reflects this
- **New rule** — `Custom:AllowAllClassesClickItems` (default **false**): let all classes click
  items regardless of class restrictions on click effects
- **Cartographer title fix** — the TSS Charm of Lore title no longer shows up on every
  character; only the quest grants it now
- Began very sketchy frail and buggy framework for shrouds and housing (very WIP based on zeklabs/Imperium)
- Added a truckload of recipes, items for recipes up through HoT, lazily wired in and expansion gated
- Spell research actually exists now
- Fixed wizard crit damage now its 1.5x instead of 0, fitting of wizards
- Added more waypoints to GoD, OoW
- Added some holiday quest scaffolding
- Added TBS/TSS quest placeholders, scaffolds
- **Server binaries** rebuilt; **database re-sanitized** (housing, shroud state and guild
  bank/ranks/tributes are now cleared as well)

### Earlier (9/9)

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
- **Triune of Fate** — an alternate currency that drops from kills and buys unlocks
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

## Known gaps / work in progress

Honest state of the world, so you know what you are getting into:

- **Expansion content depth varies a lot.** The DoN, LDoN, PoR, TBS and TSS ranges are
  scaffold-level — playable in spots, thin almost everywhere else.
- **Factions are incomplete and sometimes flat-out wrong.** Missing or erroneous faction
  hooks are one of the biggest gaps in the content.
- **DoN alternate currency** (radiant/ebon crystals) is not implemented yet.
- **Dynamic zone templates** — only 5 ship with the database; most setups will want 20+
  for instanced/expedition content.
- **Shrouds** are still being tuned.
- known issues;
- Shrouds right now are more of a cheaty delevel/plvl method, but you don't fd and lose ui anymore. still be cautious using
- No way to escape your house except by key or port, so be cautious using.
- LDON + augs need boosting
- Deity quests rank 2+ need to be put in

---

## Deity Quest

Blessing of Gods is in, only rank 1 attainable for now. See Blessing of God NPC in bazaar for rank 1. for veeshaan/agnostic think of the one common gem unused for imbueds. Cleric merchant sells new imbued spell for Veeshan** You get these abilities without anything special, just upon question completion trigger automatically in combat. Will need tuning

# Deity Blessings — Proc Effect Chart

Source of truth: `deity_blessings.pl` (`%BLESS_PROC`). The "Blessing of the God" system grants each deity a set of proc effects keyed by trigger type:

- `melee` — landed melee OR ranged hit (`BlessingOnDamageGiven`, spell_id 0, no DS/DoT ticks)
- `cast` — completed hostile **damage** spell cast (`BlessingOnCast`)
- `cast_heal` — beneficial buff/heal cast (no combat requirement)
- `taken` — incoming melee damage (reflect) (`BlessingOnDamageTaken`)
- `passive` — applied on zone-in

## Per-deity procs

| Deity | Melee hit | Hostile cast | Heal (beneficial cast) | Taken (reflect) | Passive |
|---|---|---|---|---|---|
| **Bertoxxulous** (201) | rand Disease/Poison | rand Disease/Poison | — | Disease | — |
| **Brell Serilis** (202) | Stun | Stun | Group Heal + heal 10% if <50% HP | — | — |
| **Cazic-Thule** (203) | rand Fear/Root/Poison | rand Fear/Root/Poison | — | Fear + Root + Poison | — |
| **Erollisi Marr** (204) | Lifetap | Manatap | heal 10% if <50% HP | — | — |
| **Bristlebane** (205) | pickpocket + illusion (60%) | mimic another god's proc line (40%) — |
| **Innoruuk** (206) | Lifetap | Lifetap + Manatap + hate +200 | — | — | — |
| **Karana** (207) | Cast Force (PB AE) | Cast Force (PB AE) | heal 10% if <50% HP | — | — |
| **Mithaniel Marr** (208) | Stun | Stun | Group Heal + heal 10% if <50% HP | — | — |
| **Prexus** (209) | Cold | Cold | heal 10% if <50% HP | — | — |
| **Quellious** (210) | hate −200 + Manatap | hate −200 + Manatap | — | — | — |
| **Rallos Zek** (211) | Lifetap + hate +150 + flurry | Lifetap + Cast Force + hate +150 | — | — | — |
| **Rodcet Nife** (212) | heal 5% max HP | *(none)* | Group Heal | — | — |
| **Solusek Ro** (213) | Fire | **twincast fire** + Fire | — | — | — |
| **The Tribunal** (214) | tribunal proc | tribunal proc | — | — | — |
| **Tunare** (215) | Snare + heal 4% | — | heal 8% | — | DS buff |
| **Veeshan** (216) | rand Fire/Cold/Magic | rand Fire/Cold/Magic | heal 10% if <50% HP | — | — |
| **Agnostic** (140/396) | *same as Bristlebane*: mimic another god (40%) or pickpocket + illusion (60%) — | — |

## Special actions

- **mimic** / **mimicry** — Bristlebane & Unaligned: copies a random other deity's tree per proc (excludes self, 205, 140, 396).
- **twincast fire** — Solusek Ro: re-fires the cast spell only if it is an actual fire DD (resisttype 2, negative SPA 0 in `spells_new`).
- **tribunal** — The Tribunal: lifetap if caster is hurt, otherwise magic shock.
- **flurry** — Rallos Zek (melee): extra magic nuke.
- **pickpocket** — on NPC opponent (no owner). **illusion** — random form (ids 581–592).

## Shared mechanics

- Anti-feedback: proc spells fire via `SpellFinished`, never re-enter `EVENT_CAST` (no cast bar, no recursion).
- Shared internal cooldown: at most one blessing proc per 2s (`bless-proc-ts`), single roll per trigger.
- Proc chance by rank: 1% / 3% / 5% / 8% / 11% / 15% / 17% / 20% / 22% / 25% (ranks 1–10). 
- Combat gating: hostile rolls require `IsEngaged` or `GetAggroCount > 0`; heal procs allowed out of combat.
- Beneficial casts roll HEAL effects only (never hostile). Hostile damage casts roll the offensive + heal bundle in one union (except mimic).
- CC/utility casts never proc: root(10), calm(30), charm(22), fear(23), mez(31), memblur(63), FD(74).
- Ranks/tiers: tier 1 = ranks 1–3, tier 2 = 4–6, tier 3 = 7–10; rank 1 via fired-idol task.


## Future Plans
- More modernization to match more current versions of EQEMU
- Various changes that catch eye
- more scaffolding, hope to have progression up to uf at least semi-retail, then after that start filling with custom
- future plans for future xpansions/newbie quests at pok level - revamp these to pop-tier or better, especially zones that get looked over due to server's progression-style (crescent reach, eastern wastes, etc)
- explorer path scaffold for ldon+ scaffold, only hero available right now
- more quests for the Blessing of the gods line
- heroic (violent) way to raise tradeskills
- old man mckenzie but different
- houses visible in sunrise hills that you get  as freebies vs 1M houses you set in open zone of your choice (it'll work like a bind, no house visible) ala old roguelikes
- marriage system with live eq style con ally to spouse
- nimbus and more illusion prizes
- unique utility spells/aas
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
