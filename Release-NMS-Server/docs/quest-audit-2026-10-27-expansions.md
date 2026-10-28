# Quest Script Audit - 2026-10-27 (OoW / DoN / PoR / DoDH / TSS / TBS / SoF / SoD / UF + Blessing of the Gods)

Static + DB-coupling audit of the nine expansion quest trees and the Blessing of the
Gods line. Report-only run: nothing was fixed or written to the DB. A follow-up fix
pass awaits approval of the list at the bottom.

## Scope and method

Zone sets were derived from `zone.expansion` in the live peq DB (this schema is
shifted +1 vs stock: 8=OoW, 9=DoN, 10=DoDH, 11=PoR, 12=TSS, 13=TBS, 14=SoF,
15=SoD, 16=UF). That maps to **136 zone folders / 1,583 quest files** (669 .pl,
914 .lua), plus the shared surfaces (`global/`, `plugins/`, `bazaar/`,
`potranquility/`) that the expansion lines depend on.

Layers executed:

1. **Manifest** - source vs live-runtime (`Build/bin/Release/quests`) hash diff;
   .pl/.lua shadow-pair map (lua wins, per `quest_parser_collection.cpp`);
   zero-byte and `#`-disabled inventory.
2. **Loadability** - bundled-perl `perl -c` (993 files), real `luaL_loadfile` via the
   shipped `lua51.dll` (1,134 files), engine event-handler diff against
   `QuestEventSubroutines[]` / `LuaEvents[]`, and every `plugin::X(` resolved
   against the current plugin subs.
3. **Data coupling** - every handin / summonitem / cast / task-assign / spawn /
   door reference extracted (comment-stripped) and validated against live peq
   (items, spells_new, tasks, task_activities, npc_types, spawn2/spawnentry, doors).
   Task-grant coverage used the grant mechanisms this server actually uses:
   literal + dynamic `AssignTask`/`assigntask`, `eq.task_selector` camp tables,
   `lua_modules/task_ids.lua`, popup-response assigns, and engine-side
   `dz_template_id` grants.
4. **Blessing deep dive** - full read of both core scripts plus the plugin
   (960 lines), all 16 avatar scripts, and DB verification of tasks, items,
   recipes, spells (server + client file), and spawns.
5. **Logs** - retained zone/world/eqlaunch logs contain no script errors; zone
   stdout is not persisted on this box, so runtime error sweep is a limitation,
   not a clean bill.

Raw lead data: `tmp/quest_audit_expansions/` (manifest.json, L1_results.json,
L2_leads.json, L2_dead_tasks.json, L2_residual_tasks.json, L2_residual_refs.json,
L2_task_classes.json). DB caches: `tmp/quest_audit_expansions/db/`.

## Findings - CONFIRMED, player-reachable

### F1. Blessing of the Gods: Solusek Ro favor is unearnable; Agnostic Rank II permanently blocked
The rank-2 favor avatar for Solusek Ro (npc 344220) **spawns in `nro`** (classic
North Ro), but its quest script exists only as `northro/Avatar_of_Solusek_Ro.pl`
(the PoR-revamp folder). `nro/` has no script for it, so the spawned avatar is
silent: "Favor of Solusek Ro" (task 700208) can never be assigned. Followers of
Solusek Ro cannot reach Rank II, and Agnostics need **all 16** favors for Rank II
(`_BlessingGrantRank2Agnostic`), so the Agnostic road also dead-ends.
Everything else in the blessing line verified clean (see below), which makes this
the single blocking defect. Fix shape: ship the script in `nro/` (or move the
spawn to a zone whose folder has it) - the other 15 avatars all spawn in the zone
their script lives in.

### F2. crescent/Tenish.pl: empowered-armor handins reference items that do not exist
Tenish (npc 394240, spawned in crescent) hands in piece+medal combos for the
"Inlaid Leather" armor set. The piece items **51874, 51934, 51979, 51983 are not
in `items`**, while their partner medals (51478/51481/51492/52154/52462) and the
rewards (53806-53875) do exist, and nothing grants the pieces. Six of the leather
handins (`crescent/Tenish.pl:253,260,267,274,281,288`) can never complete. Either
the pieces were renumbered at some point or were never authored; the fix is to
map to the correct ids or author the pieces.

### F3. guildlobby/Tavid_Dennant.pl: summons a nonexistent item
Tavid_Dennant (npc 344025, spawned in guildlobby) summons item **429420** on the
`luminescent` hail branch - the item does not exist. The file is an unfinished
ZAM copy ("initial copy/paste of ZAM info", literal `_____` placeholder in the
hail text). Player-visible as a vendor NPC whose special branch does nothing.

### F4. global/spells/44026.pl (Grave Dig): spawns nonexistent NPC ids
Spell 44026 (cast by Edmund's Shovel on a_disturbed_earth for task 620013 "Digging
Their Graves") calls `quest::spawn2(60020074)` / `(60020075)` - neither id exists
in `npc_types`, so both dig outcomes fail silently and the task objective is
unreachable. Note `spawn2` here takes an **npc_types id** (verified in
`embparser_api.cpp:186`), and every other spawn2/unique_spawn reference in the
audited surface (467 distinct ids) resolves - these two are the only misses.

### F5. Deployment gap: 14 committed files are not on the live runtime
Commit 51d805d3 (2026-10-18, "fix(blessings): classless percent heals; fold in
pending content work") touched 14 in-scope quest files whose live
`Build/bin/Release/quests` copies are older (Oct 16-17): the server is running
pre-fix versions of
`guildlobby/Ben_Affactor.pl`, `bertoxtemple/478730.lua`, `discord/478734.lua`,
`discord/478735.lua`, `discord/478736.lua`, `discordtower/478737.lua`,
`oldkaesoraa/478732.lua`, `oldkithicor/478731.lua`, `rathechamber/478733.lua`,
`arthicrex/485290.lua`, `brellstemple/490041.lua`, `brellstemple/490120.lua`,
`brellstemple/490130.lua`, `convorteum/491290.lua`.
The source tree is otherwise fully synced (0 src-only, 0 live-only). Fix: sync
quests to runtime and restart zones.

### F6. plugins/illusion_tools.pl cannot compile
`use Switch;` at line 36 - Switch.pm is not in the bundled perl. The engine evals
every plugin .pl at parser load (`embperl.cpp`), so this fails (noisily) at every
zone boot. Zero callers anywhere in quests/plugins, so the impact is boot noise
only. Fix: delete the file (preferred - it is dead stock tooling) or vendor
Switch.pm.

## Findings - CONFIRMED but latent / intent-dependent

### F7. ~~DoDH (corathus): the instance-mission giver layer is disabled and unspawned~~ RETRACTED
This finding was wrong and is retracted after the fix-pass investigation. The
leading-`#` in quest filenames is part of the NPC's hidden name (`#Captain_Rittas`
et al.), not a disable marker, and the "missing" NPCs spawn **dynamically**:
`#Duke_Rumith.pl` spawns the Spirit of the Past (365143) on death, and the
Velog/Sporilok/Octo death scripts spawn their Shadow NPCs (365173-175) the same
way. Grant paths exist throughout (`quest::taskselector`, `eq.task_selector({ ... })`
array offers, module constants), the underscore-variant NPCs (`#Captain_Rittas_`
365144, `#Izzik_Springwidget_` 365146) are the live givers, and `corathus/player.pl`
plus the encounter scripts already handle the tasks' completion stages. The whole
DoDH corathus mission layer (500142-500156, 500300s) is live. The only leftover is
task 500144 "Scrap for Izzik" - the non-daily original superseded by the
500154-156 daily set; accepted as dead data, not a gap.

### F8. Task rows with no grant path (revised after fix-pass pattern corrections)
The original count (110) shrank substantially once two grant forms missed by the
scanner were accounted for: `quest::taskselector(...)` (plain form, e.g. the
corathus givers) and `eq.task_selector({ CONST })` / `taskselector(@task_array)`
array offers, plus cross-file module-constant pairs (the id literal lives in
`lua_modules/*.lua`, the assign in a zone script that requires it - e.g.
`riftseekers/player.lua` assigns `task_ids.oow_rss` = 800001 on zone-in, and the
whole custom SoF chain 301000-301012 is assigned through `sof_progression`
constants). The moors 600500-512 "Strengthening the Blood" series is likewise
covered by `assigntask(600499 + $next)` arithmetic in the crescent breath NPCs.
After re-verification, **~80 task rows remain without any grant path**,
in family groups:

- **SoF stock-PEQ story arcs** (bloodmoon 300034/300100s/301200s "The Bloodmoon"
  chain, dragonscale 300512-300518 "Faycitum" dailies, mechanotus/crystallos/
  lopingplains/hillsofshade/guardian/mansion/gyrospireb/z/steamfactory/
  shipworkshop/brellsrest siblings): inherited stock rows; the generator-written
  giver NPCs in those zones do not reference them. NOTE: the custom SoF
  progression chain (301000+) IS fully wired, and the mansion-raid gate task
  301011 was unassigned and is now fixed (see fix log).
- **TSS:** crescent legacy tasks 5436/5494/6022/6817/10640; shared task 100211
  "Skal's Waking Nightmare" (12 zones); the Felena chain's missing 600413 assign
  is now fixed (see fix log).
- **PoR:** the "Exploring ..." family (arcstone 3028, elddar/elddara 3025-3027,
  takishruins 3014-3017, skylance 3010-3012, relic 3020, rage 3002, 3398,
  303187-303197 event tasks) - `por_helper.lua` carries the ids but no zone
  script assigns them.
- **TBS:** atiiki 620100-103, 625051; barren/buriedsea 6250xx; zhisza/
  kattacastrum 620104-109.
- **OoW:** chambersa-f/dranikhollows 800000/800003 "Muramite Proving Grounds",
  anguish 800002, riftseekers 800001 (800001's task_ids entry exists but no
  zone-in assign outside the ranger-epic zone script... re-verified: assigned by
  `riftseekers/player.lua` - false residual; 800000/800002/800003 remain).
- **Others:** highpasshold 5743, roost 600041, nektulos 505741, icefall/direwind
  5792, steamfontmts 500271, wallofslaughter 620009, corathus 500144 (F7 note).

These are individually real ("no script can start this quest") but collectively
they look like inherited stock data from unported arcs, not regressions. Wiring
them is a per-quest content project (giver dialogue + Allakhazam verification
each); the two chains with live downstream gates (600413, 301011) were fixed in
this pass.

### F9. guildhall/player.pl shadowed by player.lua - class-AA grant dead (CONFIRMED regression, fixed)
`guildhall/player.pl` (14 KB) contains the per-class connect-grant of signature
AAs for all 16 classes (Infused by Rage/Rampage, Twincast/Divine Arbitration,
Divine Stun, Endless Quiver, ...). A 2 KB `player.lua` (guild-hall routing +
portal table, added in ae3af6dd) shadowed it - lua wins - so the grant had not
run since, and no other script grants these AAs. The maintainer ruled this a
regression (the tome NPC in The Bazaar is a separate system, not a replacement).
FIXED in the fix pass: the lua's routing/portals were merged into a rewritten
`player.pl` (grant logic factored once, the unconditional "You are unable to
play this race/class" spam lines removed, and the Berserker block's empty
`IncrementAA()` calls - runtime errors - dropped until real Zerker AAs are
authored); `player.lua` was deleted.

### F10. Minor latent items (largely fixed)
- `global/#TPTriggerG.pl` called undefined `plugin::update_zone_entry` - the
  attunement store was never implemented and nothing requires the file; the
  broken call was neutralized with a debug note (FIXED).
- Zero-byte stubs `guildhall/#Porter.pl`, `guildhall/Zeflmin_Werlikanin.pl`,
  `southro/#Gargantula.pl` - deleted (FIXED); their real `.lua` twins live.
- Shadow pairs: the 15 highpasshold `.lua` files were PEQ-stock conversions
  shadowing RICHER `.pl` versions (e.g. Bryan_McGee's bottle-crate quest,
  Barn_Bloodstone's waypoint pathing, the captains' better reward tables) -
  the audit's initial "stale .pl" reading was backwards. Each pair was verified
  as a pl-superset (Orben's `[job]` branch was ported into its `.pl` first) and
  the shadowing `.lua` files were deleted, restoring the richer logic (FIXED).
- Task refs to nonexistent task ids: 620075 (in atiiki `#Noble_*` files) and the
  600499 series base (crescent breath NPCs) - dormant, left as-is.
- 9 orphan flag writes (`maze_corner_*`, `<exp>_awarded_` prefixes - the latter
  are dynamic-key prefixes, not bugs).

## Verified clean (the negative results matter)

- **Blessing line end-to-end except F1:** both keeper scripts coherent; rank-1
  tasks 700001-700017 deliver correctly by **npc-id match** (npc_match_list
  344200/344201 - the "Keeper of Devotion" display name is not the matcher);
  idols 9706-9720/976203/976205 exist with pottery recipes including the Agnostic
  "Fired Idol" (recipe 992010); Enchanted/Legendary (+1M/+2M) idol variants exist
  and are accepted both by the task item lists and the giver's modulo match;
  all 9 blessing spells (44014-44020, 44029, 44030) exist in spells_new **and**
  have client tokens in `spells_us.txt`; both Keepers spawn (bazaar 5004100,
  potranquility 5004101); all 16 favor avatars spawn and their scripts gate
  correctly through `BlessingAssignRank2`; exactly 16 rank-2 favor tasks are
  authored, matching `$BLESS_RANK_CAP = 2` (ranks 3-10 unauthored by design);
  the proc engine (cooldowns, combat gates, CC exclusion, shroud exclusion,
  mimic/mischief trees) reads sound, and `global_player.pl` forwards
  TASK_COMPLETE / DAMAGE_GIVEN / DAMAGE_TAKEN / CAST / ENTERZONE / RESPAWN with
  no lua shadow.
- **Loadability:** 993 perl + 1,134 lua files compile; 0 dead engine handlers
  (one flagged name, `global/DayNight.pl` `EVENT_CYCLE`, is an internal helper
  sub, not an event - triaged false positive); plugin refs all resolve except
  the debug calls commented out in `Blessing_of_the_Gods.pl` (triaged).
- **Data coupling:** 0 missing spells among all cast references; 0 missing
  doors (12 initial leads were a dump-parse artifact, discarded); 0 missing
  tasksets; 0 orphan flag **reads** (no stuck progression gates from the
  bucket/subflag patterns).
- **Task grant paths verified working:** DoN camp missions via `eq.task_selector`
  tables in lavastorm camp NPCs; OoW proving-ground/raid tasks via
  `lua_modules/task_ids.lua`; popup-response `AssignTask` flows (e.g. broodlands
  player.lua); blessing favor tasks via the plugin's formula assigns.
- **Source/live sync:** no src-only or live-only files anywhere in the audited
  surface (only the 14 changed files in F5).

## Suggested fix-pass priorities (awaiting approval)

| Pri | Item | Action |
|-----|------|--------|
| P0 | F1 Solusek Ro avatar | Ship the favor script in `nro/` (or move spawn) |
| P0 | F4 Grave Dig spawns | Author npcs 60020074/75 or re-point to real ids |
| P0 | F2 Tenish items | Map pieces to real ids or author them |
| P1 | F5 deployment gap | Sync quests to runtime, restart zones |
| P1 | F3 Tavid_Dennant | Author item 429420 or cut the branch |
| P1 | F6 illusion_tools.pl | Delete (dead) or vendor Switch.pm |
| P2 | F7 corathus intent | Maintainer ruling: retire rows or restore givers |
| P2 | F9 guildhall grant | Maintainer ruling: tome-superseded or regression |
| P3 | F8 unwired task rows | Decide per family: wire up or accept as dead data |
| P3 | F10 hygiene | Remove stale shadowed .pl copies, fix #TPTriggerG ref |

## Fix pass - 2026-10-27 (approved scope executed)

Order per maintainer instruction: F10+P0, then P1, then P2, then P3. F6
(illusion_tools.pl) was held. Applied to source, synced to the live runtime
(robocopy both trees + mirrored deletions; re-verified 0 drift, 0 shadow pairs,
0 zero-byte), zones restarted.

| Item | Fix |
|------|-----|
| F1 | `nro/Avatar_of_Solusek_Ro.pl` shipped (copy of the northro script; task 700208 verified: SpeakWith/explore activities, beacon item 976212 exists). Solusek Ro favor + Agnostic Rank II reachable again. |
| F2 | `crescent/Tenish.pl` leather AND silk Part-1 handins remapped from the copied OoW ids to the real piece/catalyst items (32812/32816 hides, 32817/32813 swatches, 32832-32838 leather patterns, 32839-32845 silk patterns) - mapping cross-checked slot-by-slot against the working plate/chain sections. 14 handin lines fixed. |
| F4 | `global/spells/44026.pl` re-pointed to the already-authored npcs: zombie 60020074->1500200074 (loots 3001009 at 100%), spirit 60020075->1500200073; id/message cross-pairing fixed. No new npc rows needed. |
| F5 | Source -> runtime sync completed after all fixes (see above). |
| F3 | `guildlobby/Tavid_Dennant.pl` rebuilt per Allakhazam "Consigned Items" flow: luminescent (42942) / incandescent (42943) vortices, polymorphic cell (42960), molting cell (42941), class-mapped cocoon (42944-42959), watch/Doctor flavor, one free item per type per character, handins returned. The nonexistent 429420 reference is gone. |
| F7 | Retracted - no fix needed (see finding). 500144 accepted as dead data. |
| F9 | `guildhall/player.pl` rewritten as the merged controller (AA grants restored + lua routing/portals); `guildhall/player.lua` deleted. |
| F10 | #TPTriggerG neutralized; 3 zero-byte stubs deleted; 15 highpasshold lua shadows removed after per-pair superset verification (Orben [job] branch ported first). |
| F8 (partial) | Two live downstream gates wired: `vergalid/Rozoth_Orbu.pl` now assigns 600413 (Finding Felena finale - the chain was dead at its last step), and `mechanotus/436010.lua` (Warmarshal) offers 301011 (Exploring the Mansion) so the mansion raid gate is obtainable. The remaining ~80 stock-PEQ rows (SoF story arcs, PoR Exploring family, TBS families, crescent legacy, 100211, 800000/800002/800003) are documented in F8 as a per-quest content project. |

Verification: every edited file passes the bundled perl `-c` / luaL_loadfile
checks; the Tenish mapping and Tavid item set were validated against the live
items table; no DB rows were modified by this pass.
