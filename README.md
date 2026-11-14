# Triptych Triumvirate — LAN server release

A complete, working **multiclass EverQuest server** (EQEmu-based, RoF2 client, the steam one), released as a
LAN-oriented community server. Everything in this repo is tuned for play on a local network.

> **LAN only.** This release is intended for private/local-network play, of course it can be tweaked for network at discretion.

---
### This update's changes (11/13)

- Housing and furniture placement works at a basic level still has some kinks, follow the menu guide, lot rent isn't in so hold on to Georgist High Fantasy Monopoly dreams
- Mercs charge what they are worth
- Various fixes to potimeA, if you killed quarm should be able to click on one of the dials on the gem monster side of potimeA for a special battle
- Starvation/thirst code, off by default, customizable
- LoN cards save progress and free starter kits in the bazaar, also an npc that sells them
- Personal loot is in with 0 (off) and 4 other options, only 1 where you and your group mate(s) each get a copy has been tested extensively, also loot theft halted with 1-4 on
- No more grief kills of the vault merchant
- Various quest fixes, powater/poearth issues
- MacroQuest coexistence hardened: the old gCXStrAccess "drain" retired for read-only observation, plus a breadcrumb on the client's out-of-memory trap so crash dumps finally explain themselves.
- LoN soundtrack stops with the card game
- A little bird rebrand due to player bias against elementals
- Rule-gated bazaar exile — unauthed-client handling is now a rule; disabled means one polite note per zone-in instead of the countdown
- Keying is back for pre Pop zones to slow the rush
- Added a rule to gate gaining tradeskills from raidboss kills

### This update's changes (11/10)
- compiled binaries removed from the repo - server exes, runtime dlls, map tools, all of it. Build from source (see Building); the client add-on builds from Release-NMS-Client too
- lon card data (client-derived) removed from history too - one command puts it back from your own client: recreate-lon-data.bat <client-folder> (see Release-NMS-Server/docs/lon-card-data.md)
- history scrubbed so the old binary blobs are gone for real, fresh clones are much lighter
- the database zip and the maps are still included, nothing else moved

### This update's changes (11/1)
- various server side stability fixes/fixes in general cherrypicked from downstream (Russianranger, GreyMouser69)
- Achievements has pretty buttons up to UF and offers some rewards now, a bit op and a bit underwhelming, needs to be populated more
- Populated some of TSS, ROF Achievements by https://github.com/nightstalker6669/eqemu-rof2-achievements
- Added high inquistor xeru after death of LIS as custom battle
- fixed eternal spawning vz in tactics, rallos zek pit event
- populated powar some more, still scaffold
- Glamour dupe clean up
- Fellowships in and working, xp-aa needs more testing (https://github.com/nightstalker6669/eqemu-rof2-achievements), camps work in instances, need 2 to create a fellowship 1 to make a camp
- did a pass of opcodes, various other housing/shroud code from https://github.com/nightstalker6669/EQEmu/tree/rof2-integration, will need a lot more passes etc to get up to par #housing if you want to play with it
- fixed a bunch of blessings quests, Halloween quests, npc locations (Kree)
- made the contested rumor about druids and stop rain true
- added tradeskill knowledge on death on many raid mobs up to about GoD to make them worth farming/killing
- added scaffold to OMM for silly shroud quests, have not been tested, have not been locked to 85 yet
- added librarian npc in pok next to seer to work as a specific guide to help with progression pop and beyond, so you don't need 12 tabs open while you play, needs work
- added legendary and master mercs, gave them bot brains to make them worthy of the title
- more quest scaffolding esp TBS-SOF-SOD-UF
- fixed philanthropy duping bug


### This update's changes (10/16)
- various server side stability fixes
- fixed shrouds + aggressive dedupe leading to hidden universal AAs (Kree)
- thezerodivide's Spellbook 720 → 1440 spells, this makes the client req https://ntcore.com/4gb-patch/ to be applied first, been using it about a decade np on other programs
- Lon card game, requires rof2 steam client version to access, cards/boosters rare drop off mobs and every account gets 5 packs a month as a reward for survival
- Mercs and they charge
- Achievements and rewards window, its in, needs work (like more of them for example)
- fix Sayrn flagging issue, GoD progression confirmed accessible by testers
- Ornament v glamour divide started, glamors are cosmetic, while ornaments have stats/procs/clickies, eventually will add them in
- Finally fixed origin and a few AAs
- Opened up and lowered the level of a ton of AAs, bunch of weird AAs still visible
- various corpse-mobs actually look dead now

### This update's changes (10/9)
- Focus locker is in under procs in your nautilus vault, pick 4 items you want skill/foci/instrumentation bonus of and it'll fire from it, UI is still sketch but its in, also UI now displays corruption resist
- Deduped and consolidated some AAs, yes there's a bunch of weird AAs now visible
- Shrouds 80% done, put in a baking skill training quest in bazaar, you must become one with the dough
- added rank 2 of the god quests, not tested, agnostics have it loccked at pop now and must choose a cause
- put in halloween quests, again not tested
- Rog/RNG innate crit and 2hs AA melee boosting
- Behemoth activates now, keep the spiders away

### This update's changes (10/4)
- Nautilus Vault is in, UI is sketch but its in, proc locker has rule choice to proc locked weapons procs and their augs in addition to procs in held weaps
- fixed doors to guild lobby for real this time
- readded tomes to global drops (oops)
- Tome AA cap raised to 300 again and guards in place, waiting on AA consolidation-dedupe patch
- boosted augs to match lost soul system
- extended pet and swarm pet focus and abilities to 85 (some swarm spells still don't work right)
- more scaffolding up to UF
- fixed Pojustice mark flagging
- fixed various glitchy maps (hopefully for real this time)
- added ascendant shard upgrade and small chance on named raid npcs
- powersources in and functional, UI is sketch as is method of gaining them. obviously can't level a powersource by having it in your powersource slot

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
| [`Release-NMS-Server/`](Release-NMS-Server/) | The server (EQEmu-based) source and the database dump |
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
- **Glamour & languages** — mount glamour merchant, armour glamour, and a languages trainer Also #illusion to store/use illusions from
- **Personal Power** — Personal procs via blessing of the gods questline, not from AAs, clickies, and not from augs. It follows the PC around
- **Tome trainers** — located in the bazaar backrooms
- **Legends of Norrath Card Game** - Trading Card game, for nostalgia, has rewards, free 5 packs a month for existing, packs rare world drop**
- **Achievements ** - Achievements to keep track of what you've done in Norrath
- **Fellowship** - Fellowships to call friends to adventure and keep adventuring together easy 
- **Mercenaries** - Mercs you can hire to help in your higher level adventures
- **Shrouds** - Shrouds, transform into a different monster-singular class, currently includes one monster quest
- **Tradeskill by Quest and Raiding** - Tradeskill via Monster quest (well inanimate object quest) and soon raise tradeskills directly via killing of select raid bosses
- Assorted client-side quality-of-life fixes, shipped as `dinput8.dll`
- **Housing and Lots** - Houses you can live in and furnish
- **85 Level Cap and Goal of UF Reachable Progression** - Lvl 85 player cap and a goal of making up to UF reachable progression wise
---

## Quick start (LAN)

**1. Get a client.** EverQuest client files are Daybreak's — not included and cannot be. You
will need the RoF2-era client this server was built against. See
[the client README](Release-NMS-Client/README.md) for what to do with it.

**2. Map files.** The server maps **are** included at `Release-NMS-Server/maps/`:
- `.map` files live under `maps/base/` and `maps/legacy/base/`
- `.nav` files live under `maps/nav/` and `maps/legacy/nav/`
- `.zon` water mesh files live under `maps/water/`

They are already in place for a fresh checkout — no separate download needed.

**3. Set up the database.** Unzip `Release-NMS-Server/database/release-peq.zip` and import it
into an empty schema. It contains **no player data** — it is a fresh world.

**4. Build and run the server.** Binaries are **not shipped** — build from source (see
**Building** below); they land in `Build\bin\Release\`. Copy
`eqemu_config.json.example` and `login.json.example` to their real names and set your DB
credentials, then start `world.exe` (or use the included `start-servers.bat`).

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

**7. Install the client add-on.** Build `dinput8.dll` from `Release-NMS-Client/eqgame_dll`
(VS 2022, **Win32/x86** — it is not shipped) and copy `Release-NMS-Client/ClientFiles/`
over your client. See [the client README](Release-NMS-Client/README.md) — it also covers
the known art gaps.

**8. Optional — Legends of Norrath card game.** The card data is Daybreak-copyright, so it is
not shipped either — recreate it from your own client:

```
recreate-lon-data.bat <your-EQ-client-folder>
```

Until you run it the card game simply stays off (one log line per world boot) and everything
else is unaffected. Details: [the LoN card data doc](Release-NMS-Server/docs/lon-card-data.md).

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

- **Expansion content depth varies a lot.** The OoW-UF ranges are scaffold-level — playable in spots, thin almost everywhere else.
- **Factions are incomplete and sometimes flat-out wrong.** Missing or erroneous faction
  hooks are one of the biggest gaps in the content along with bad hps.
- **DoN alternate currency** (radiant/ebon crystals) is not implemented yet.
- **Shrouds and houses** are still being tuned, especially houses
- Deity quests rank 3+ need to be put in
- Many OoW+ AAs don't do anything, there are broken swarm pet spells and broken spells in general
- merchants LDoN-UF ranges have no or missing stock
- you have to do everything again for travel achievements
- housing and shroud code needs more passes
- legendary/master mercs in and have bot brains in merc bodies, future availability for multiclassing possible though currently EQbot AI chokes on it
- few silly OMM quests in, not properly level locked not properly tested
- avatar of wing ring in poair is glitchy but completable
- new librarian npc to act as offline guide for flagging, he's not 100pct correct on things yet
- custom xeb (evil zeb) event in but needs finetuning/is buggy
- tzvz can be cheesed for tradeskill grinding,
- blessings of gods questline needs more tuning and some deities/agnostic line may not be completable yet
- various npcs facing the wrong way, wrong appearance etc
- Arcade added in hastily still needs buttons and doesn't work
- curio traps in veeshan/poair (don't click the loot) has not been heavily tested

---

## Deity Quest

Blessing of Gods is in, only rank 1 attainable for now. See Blessing of God NPC in bazaar for rank 1. for veeshaan/agnostic think of the one common gem unused for imbueds. Cleric merchant sells new imbued spell for Veeshan** You get these abilities without anything special, just upon question completion trigger automatically in combat. Will need tuning

## Deity Blessings — Proc Effect Chart

Source of truth: `deity_blessings.pl` (`%BLESS_PROC`). The "Blessing of the God" system grants each deity a set of proc effects keyed by trigger type:

- `melee` — landed melee OR ranged hit (`BlessingOnDamageGiven`, spell_id 0, no DS/DoT ticks)
- `cast` — completed hostile **damage** spell cast (`BlessingOnCast`)
- `cast_heal` — beneficial buff/heal cast (no combat requirement)
- `taken` — incoming melee damage (reflect) (`BlessingOnDamageTaken`)
- `passive` — applied on zone-in

## Per-deity procs

Proc chart by trigger
Triggers: melee = landed melee/ranged hit · hostile cast = completed damage spell · reflect = incoming melee hit · beneficial = any heal/buff/utility cast · passive = applied on zone-in. All procs share one roll (Rank I = 1%, Rank II = 3%) with a 2-second internal cooldown; hostile triggers require combat; CC casts never proc; "heal if hurt" only fires below 50% HP.

| God | Melee hit | Hostile cast | Reflect | Beneficial cast | Passive |
| --- | --- | --- | --- | --- | --- |
| Bertoxxulous | Disease/Poison nuke (random) | same | Disease | generic self-heal | — |
| Brell Serilis | Dyn's Dizzying Draught | Dyn's | — | group heal + 10% if hurt | — |
| Cazic-Thule | Fear/Root/Poison (random) | same | Fear + Root + Poison | generic self-heal | — |
| Erollisi Marr | lifetap | mana tap | — | 10% if hurt | — |
| Bristlebane | mischief¹ | mischief¹ | — | mischief¹ | — |
| Innoruuk | lifetap | lifetap + mana tap + 200 hate | — | generic self-heal | — |
| Karana | weapon twinproc | twincast | — | twincast | — |
| Mithaniel Marr | Dyn's | Dyn's | — | group heal + 10% if hurt | — |
| Prexus | cold nuke | twincast-cold + cold nuke | — | group heal + 10% if hurt | — |
| Quellious | −200 hate + mana tap + rare Dyn's (10% sub-roll) | −200 hate + mana tap + twincast | — | 10% self-heal | — |
| Rallos Zek | lifetap + 150 hate + flurry | lifetap + twinproc + 150 hate | — | 10% if hurt | — |
| Rodcet Nife | group heal | group heal | — | group heal | — |
| Solusek Ro | fire nuke | twincast-fire + fire nuke | — | twincast | — |
| the Tribunal | lifetap-if-hurt-else-nuke | same | — | 10% if hurt | — |
| Tunare | snare + 4% heal | — (heals only) | — | 8% heal | damage shield on zone-in (only passive) |
| Veeshan | Fire/Cold/Magic (random) | same | — | 10% if hurt | — |
| Agnostic (unbound) | mischief¹ | mischief¹ | — | mischief¹ | — |
¹ Mischief = 40% pickpocket + steal victim's appearance, 60% mimicry (copy a random other god's bundle for that trigger; never copies itself or another mimic tree).

### Agnostic causes (bind at the PoT Keeper, before Rank I)
Choosing a cause routes all procs through that god's row above from Rank I onward; the god is never named in game, only the label. Changing cause later severs everything.

| Cause label | Hidden god | Cause label | Hidden god |
| --- | --- | --- | --- |
| Legacy | Bertoxxulous | Adventure | Karana |
| Wealth | Brell Serilis | Valor | Mithaniel Marr |
| Myself | Cazic-Thule | Glory | Prexus |
| Love | Erollisi Marr | Peace | Quellious |
| Fun and Games | Bristlebane | Battle | Rallos Zek |
| Revenge | Innoruuk | People | Rodcet Nife |
| Power | Solusek Ro | Justice | the Tribunal |
| Nature | Tunare | Knowledge and Reason | Veeshan |
### Rank 2 — the Deity Favors
Rank I = idol hand-in as before (god-followers at the Bazaar keeper; agnostics: cause + blank idol at the PoT keeper only). Rank II = that god's favor quest (agnostics must do all 16 — no royal road; progress shows in the devotion window). Reward per favor: that god's Fireworks Focus; Rank II also grants a Potion of Adventure II.

| God | Favor quest | Giver — zone |
| --- | --- | --- |
| Bertoxxulous | Culling Fever | Avatar — East Karana gnoll reaver camp |
| Brell Serilis | Crafting a Party | Roderik — Butcherblock |
| Cazic-Thule | A Taste of Fear | Avatar — Feerrott |
| Erollisi Marr | Love, Norrathian Style | Aspect — South Ro coast |
| Bristlebane | Party Favor | the Image — Plane of Knowledge |
| Innoruuk | The Power of Hatred | evil little imp — Innothule |
| Karana | Tears of a God | Avatar — South Karana (Tober in North Karana) |
| Mithaniel Marr | Deliver Us from Evil | Avatar — Plane of Tranquility |
| Prexus | Fishing for Blessings | Primate — Erud's Crossing |
| Quellious | Peace and Understanding | Avatar — Plane of Tranquility |
| Rallos Zek | Warrior's Rest | Avatar — Plane of Tranquility (Togg in Lavastorm) |
| Rodcet Nife | Healing Touch | Helera Garet — North Qeynos |
| Solusek Ro | Bonfires of Vanity | Avatar — North Ro |
| the Tribunal | Justice of the Tribunal | Herald — Plane of Tranquility |
| Tunare | The Gift of Life | Avatar — Greater Faydark |
| Veeshan | Memory in Crystal | crystalline avatar — Plane of Knowledge (5-question trivia) |


## Future Plans
- More modernization to match more current versions of EQEMU
- Various changes that catch eye
- more scaffolding, hope to have progression up to uf at least semi-retail, then after that start filling with custom
- force lvl 60+ to v1 shards for better compatibility with ldon+ zones
- future plans for future xpansions/newbie quests at pok level - revamp these to pop-tier or better, especially zones that get looked over due to server's progression-style (crescent reach, eastern wastes, etc)
- explorer path scaffold for ldon+ scaffold, only hero available right now
- more quests for the Blessing of the gods line
- more 'monster' quests to grind tradeskills, also kill select raidbosses to raise skills ala the old non-graphical MUDs that inspired EQ
- more functional housing system, explore housing in non-neighborhood zone if possible
- marriage system with live eq style con ally to spouse
- nimbus and more illusion prizes
- unique utility spells/aas
- consolidate evolving items and our basic-enhanced-legendary scaffold to free up the powersource slot
- fix the shroud tab and remove shroud dependency on external dll

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
  thezerodivide - 1440 spell expansion
  Russianranger - various server fixes
  GreyMouser69 - various server fixes
  nightstalker6669 - expanded housing, shroud, fellowship, TSS non raid zone achievement code and complete quests
  
  

## Requirements

- **Server:** CMake 3.12+ (4.x works), a C++17 compiler, MariaDB 10.6+ or MySQL 8.0, Perl
- **Client add-on:** Visual Studio 2022 with the *Desktop development with C++* workload
  (build as **Win32/x86** — the client is 32-bit), 4gb patch

## Licensing

The server is derived from the [EQEmu project](https://github.com/EQEmu/Server) and carries its
GPL licensing. The client add-on and the quest scripts are MIT, with their original copyright
notices intact — see the `LICENSE` file in each folder.

EverQuest is a registered trademark of Daybreak Game Company. This project is not affiliated with
or endorsed by Daybreak, and contains no EverQuest client files.
