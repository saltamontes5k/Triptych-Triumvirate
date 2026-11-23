# Shroud system — agent handoff

*Written 2026-11-17. This replaces all earlier shroud notes in this tree. It records
exactly what was done, what state each layer is in, what is NOT verified, where the
prior agent's own mistakes are, and what to do next. Nothing here is speculative
unless marked so.*

## State at a glance (time of writing)

| Layer | State |
|---|---|
| Server processes | **Up** (re-booted 2026-11-17 14:59 with the full current tree; ~37 zones) |
| `db_version.custom_version` | **449** (v446-v449 applied at that boot) |
| On-disk `zone.exe` | 00:51 build (gate 440, buy fix, AA reset, LogF crash logger) |
| Compiled but **NOT linked** | `SetNativeShroudAbilityCaps` (AA replacement), manifest **v441** entry, gate **441** (`common/version.h`) — last build compiled clean, link hit LNK1104 while zones ran |
| Live data | v432–v441 payloads all applied; catalog = **468 enabled forms**, 92 templates carry ability rows (1,027 `spirit_shroud_abilities` rows, zero illegal) |
| Rules | `Custom:EnableSpiritShrouds = true`; `Custom:ShroudsEnabled` still on (quest path alive) |

## Terminology (strict)

| Term | Means | Gate |
|---|---|---|
| **quest shrouds** | old keeper system: `shrouds` table (496 rows), `shroud_abilities` caps, `ApplyShroud`/`RemoveShroud`, `OP_Shroud` transform | `Custom:ShroudsEnabled` |
| **spirit shrouds** | native engine: `spirit_shroud_*` tables, `OP_SpiritShroud*`/shroud-opcode protocol, monster points | `Custom:EnableSpiritShrouds` |
| **mission forms** | seven prop shrouds owned by missions (cake 110125, keg 100125, golem 120125, boat 140140, moorwalker 140240, ghost 140340, armour 140440), applied by controllers | entitlement_key + script |

## What was done across this effort (all verified against DB or logs unless noted)

### Data migrations (all applied live; all registered in
`common/database/database_update_manifest_custom.cpp`; all have `utils/sql/` twins;
rollback twins exist for v436–v441 except v432/v433 which are idempotent by design)

- **v436** — backport templates (progressions 10–13) had `resource_maxima=0` + NULL
  natives + NULL `unlock_xp`; set `resource_maxima=1` and `unlock_xp=0`.
- **v437** — four McKenzie props onto the spirit engine: progression 14
  `Hallucinations`, boat **140140** / moorwalker **140240** / ghost **140340** /
  armour **140440**, entitlement keys `mission:*`, starter gear copied from
  same-class templates. Also added `texture`/`helmet_texture` columns to
  `spirit_shroud_templates` (ghost needs texture 3/helm 3; defaults 0/255).
- **v438** — evicted the legacy 90k rank band from `spirit_shroud_abilities`
  (v431's fill had written 8,921 rows with rank_id > 65535 — Validate throws
  "invalid shroud ability set"; RoF2 AA window caps at 49999, `wire.h`
  `EnumerableRank`). The curated ten's authored 48xxx rows survive.
- **v439** — ladder backport: filled 439 of the 467 v427 preview rows (race 0,
  unauthored) with the legacy `shrouds` values (race/size/resources/texture/name,
  `resource_maxima=1`, monster points by level) and enabled them. 28 previews with
  no legacy twin stay disabled.
- **v440** — zeroed the seven stat columns on every `shrouds.id`-evidenced enabled
  row: the previews carry live-captured monster stats (stat_int 305 on level-70
  casters) and `ResourceContributions`
  (`common/shroud/resource_baseline.h`) throws "shroud resource maximum below class
  stat contribution" when captured mana < the mind contribution (305→482×7.5=3615 >
  mana 2062). The legacy engine never applied stats to a form; zero is the faithful
  port.
- **v441** — ability coverage: 82 enabled templates that had no ability rows got the
  authored band's ranks matching class mask (`classes & (1 << class_id)`, the
  engine's own enter-check idiom) and `level_req <= level`; lowest rank of each line
  `free_grant=1`. Max 19 rows/template. 375 enabled templates still have NO matching
  authored line for their class/level — that is authored-content work, not a gate.

### Engine changes (C++)

- `EnterNativeShroud(id, script_granted)` — Lua `ApplySpiritShroud` passes
  `script_granted=true`: a quest apply **is** the entitlement (waives
  `entitlement_key`); the keeper window keeps the check. **Live-tested** (cake
  mission applied).
- `Client::RemoveShroud(send_updates)` delegates native forms to
  `RestoreNativeShroud(send_updates)` (silent-capable). Without it,
  `RemoveShroudSilent` never cleared `m_spirit_shroud_template`/the
  `spirit_shroud_state` row/starter items and the form **resurrected on next
  zone-in** through cleanup hooks. **Live-tested** (keeper remove works).
- Template `texture`/`helmet_texture` carried through wire/catalog/loader/
  Snapshot/RestoreSnapshot/enter/reapply (mirrors the `model_size` precedent).
  **Not yet visually verified in game.**
- `SendShroudInventoryView` SEH-guarded (body in a free function for the SEH frame;
  code captured in the filter, logged after — C2712 forbids unwinding objects in SEH
  functions). The fault it catches is REAL and UNFIXED — see bug ledger.
- Crash handler: the generic `Log` macro (`common/eqemu_logsys_log_aliases.h:950`)
  forwards format strings **without** `fmt::format` — only `LogF` formats. The
  handler's arg-bearing lines printed literal `[{}]`, losing the faulting IP. Fixed
  to `LogF` (three calls in `common/crash.cpp`). **Live-tested** (skip message now
  prints the code).
- `SendShroudZoneInState` native branch: sends `SendClearPlayerAA` +
  table/points/stats (the client kept its AA window across the same-zone reload)
  **plus** the `OP_ShroudStateUpdate` points packet (`0x006e`, 8B
  `[aapoints, aapoints_spent]`) — the old-engine branch always sent it, the native
  branch never did, and the shroud window's purchase button reads it. **In the
  running binary; purchase success NOT yet confirmed in game.**
- `RestoreNativeShroud(send_updates)` re-sends the real AA table after restore.
  **Live-tested** (user confirmed the real list returns on unshroud).
- GM bypass: `Offered()` waives progression thresholds and entitlement rows for GMs;
  the keeper window lists every level for a GM and marks templates unlocked;
  `EnterNativeShroud` waives the level cap. **Live-tested** (user GM, catalog
  browse).
- `SetNativeShroudAbilityCaps(t)` (**STAGED, NOT LINKED, NOT TESTED**): fills
  `m_shroud_ability_caps` from the template's ability list on enter/reapply. This is
  the AA-window replacement fix — see bug ledger.

### Scripts (runtime tree `Build/bin/Release/quests`, synced via `sync-quests.bat`)

- The three tradeskill controllers and the four McKenzie controllers call
  `ApplySpiritShroud(<spirit id>)`; their `RemoveShroud`/`RemoveShroudSilent` calls
  stayed and are native-aware via the delegation.
- `global/global_player.pl` zone-exit cleanup blocks (all seven mission forms) now
  skip GMs: `!$client->GetGM() && $client->GetShroudID() == <id> && !(mission zone
  check)`. Without the GM guard the cleanup silently stripped a form worn outside
  its mission zone and keeper "remove" then hit the already-unshrouded no-op —
  that was the "keeper doesn't respond until I reshroud" report. **Live-tested.**

## Bug ledger — open items in priority order

1. **AA-window replacement (staged, needs link + test).** Design per maintainer:
   while shrouded, the AA window lists the **form's monster abilities**; the real
   list returns on unshroud. Two gates: (a) `PreviewRange`
   (`common/shroud/aa_preview.h`) drops every rank not in the form's list — works;
   (b) the client lists a row only when the server flags its per-row shroud byte
   (`aai->shroud_row`, `zone/aa.cpp:1343`), which reads `m_shroud_ability_caps` —
   filled only by the **legacy** `LoadShroudAbilityCaps` (quest path). The staged
   `SetNativeShroudAbilityCaps` fills it for native forms. **This was
   misdiagnosed once as "by design / client cannot render custom ids" — wrong; the
   client renders whatever `OP_SendAATable` delivers.**
2. **Shroud-window buy.** The zero-packets symptom (log-proven: buy clicks produced
   no `OP_AAAction`) was attributed to the missing StateUpdate points packet, which
   is now in the running binary — but a successful purchase has NOT been confirmed.
   The purchase path itself (`PurchaseSpiritShroudRank`,
   `zone/client_spirit_shroud.cpp:1218`) is silent-return on many gates; if buy is
   still dead after the relink, instrument the gates (they are all bare `return`s —
   add a Log line per rejection) before touching the client theory. Fallback
   hypothesis: the profile holder-kind byte (`+0x340C`, see the shroud-UI decode
   notes in `shroudref/` and IDA db `shroudref/eqgame.i64`) not set for native
   forms.
3. **0xC0000005 in the shrouded zone-in inventory encode.** Recurs on every shrouded
   zone-in of a form WITH starter gear (`Handle_Connect_OP_ZoneEntry` →
   `BulkSendInventoryItems` → `SendShroudInventoryView` → `RoF2` encode of
   `OP_CharInventory`); contained by the SEH guard (zone survives, client misses the
   cosmetic packet — log line `Shroud inventory view faulted (code [0xC0000005])`).
   Ladder forms without gear never fault. Prime suspect: item 94074 (Backpack, the
   starter container) — its DB row is clean (short strings), the shared-memory item
   segment was force-rebuilt 11-17 and the fault has not been re-observed since
   (no shrouded zone-in of a geared form has happened after the rebuild either —
   **undetermined**). The exact faulting line was never captured: the crash logger
   was broken at the time (see LogF fix); do NOT trust the disassembly chased at the
   old logged IP — it was incoherent (incremental-link PDB skew). With the LogF fix
   now live, the next occurrence logs a real faulting IP: resolve THAT.
4. **Log noise triage (the "too many errors").** Seen in zone logs: `Net error:
   Unhandled opcode 0x1d` (×2 per shroud reload — client opcode we do not handle;
   benign? uninvestigated), `Connection attempt failed for content_database: Access
   denied for user 'ODBC'@'localhost'` from `quests/plugins/MySQL.pl:52` (a quest
   plugin attempting a credential-less content-db connection — pre-existing plugin
   issue, not shroud work), the SEH skip message per geared zone-in. None were
   introduced by the shroud changes except the skip message itself (which is the
   containment of #3).
5. **Authored content** (not bugs): 375 enabled templates have no authored ability
   line for their class/level; cake/keg/golem wear staff+backpack stand-in gear
   (custom item proposal was drafted, never approved — content decisions belong to
   the maintainer).
6. **Quest-path retirement (Phase D)** — parked by design until everything above
   settles. NOTE: `shroud_abilities` (legacy table) is still load-bearing for quest
   shrouds via `LoadShroudAbilityCaps`; it retires with the quest path, not before.
   Same for `ENCODE(OP_Shroud)`/`BuildShroudProfileBlock` (`common/patches/rof2.cpp`)
   and rule `Custom:ShroudsEnabled`. Full caller accounting required (AGENTS.md).

## The prior agent's own mistakes — check these first

- The wrong "by design" AA diagnosis above (one full day of wrong direction).
- During a v440 manifest insertion, the new entry was anchored on the previous
  entry's closing braces and the real last entry was orphaned after the array's
  `};` (C2059). Repaired, but the array order is now v438, v440, v439, v441 — the
  runner matches entries by version number so order is cosmetic, but do not assume
  the array is version-sorted.
- A tree-building block in `OpenSpiritShroudsFor` was mangled by a bad edit and
  restored in the same minute — diff `Handle_OP_SpiritShroudRequest`/
  `OpenSpiritShroudsFor` against intent if anything looks off in window content.
- An SQL derivation battery once "passed" while the live catalog threw — a flat
  approximation of the half-stat curve. The battery in the transcript is now exact
  (integer truncation included), but SQL validation is necessary-not-sufficient:
  the authoritative test is hailing a keeper and entering a form.
- The 12-row rollback file `20261115_shroud_ladder_stats_v440_rollback.sql`
  restores captured stats for only the 12 rows that threw (transcribed from a live
  probe); the other ladder rows' captured stats were not preserved (they were
  never load-bearing).

## Relink + boot (the immediate owed step)

The server is down at time of writing — the link window is open:

```
rebuild_server.bat        # from C:\EQS; links zone/world/ucs with everything staged
start-servers.bat         # via PowerShell Invoke-CimMethod (a plain spawn dies with the shell)
```

Then confirm: `db_version.custom_version` = **441** (world evaluates the manifest;
v441's data is already applied so its entry skips and stamps).

## In-game verification protocol (after boot)

1. Hail a Shroudkeeper (PoK): window opens, full ladder visible, everything marked
   unlocked (GM).
2. Shroud **Imp Wizard 5** (20105 — 7 free abilities): AA window should list
   Eyes Wide Open (cat 3) + Fire/Frost/Thunder/Flight/Ultravision/Spirit Sending
   (cat 4) in place of the real list; `say remove` restores the real list.
3. Shroud-window Abilities pane: click a line → preview; buy → "You spend N monster
   points" and a `spirit_shroud_allocations` row appears.
4. Zone-in while shrouded as a geared form (Bear Beast 70): watch for the
   `Shroud inventory view faulted` line — if absent, the fresh segments fixed #3.
5. One tradeskill mission + one McKenzie mission end-to-end.

Quick DB probes (`python -I dbq.py "<query>"` from `C:\EQS`; add `-f` to write):

```sql
SELECT custom_version FROM db_version;
SELECT COUNT(*) FROM spirit_shroud_templates WHERE enabled=1;             -- 468
SELECT COUNT(*) FROM spirit_shroud_abilities;                             -- 1027
SELECT COUNT(*) FROM spirit_shroud_templates WHERE enabled=1 AND resource_maxima=0; -- 0
```

## Traps learned on this box (all cost time; all confirmed)

- **Manifest**: checks are all evaluated **before** any migration applies, so a
  pre-state probe must use `condition = "not_empty"` ("empty" on a post-state probe
  wrongly skips on fresh installs). MSVC C2026 at ~16 KB per string literal — split
  big SQL. The gate is `common/version.h` `CUSTOM_BINARY_DATABASE_VERSION` — re-grep
  the manifest max before picking a number (drift happened twice this effort).
- **Logging**: `Log(...)` never formats; `LogF(...)` does. Any new arg-bearing log
  line must use `LogF`.
- **Shared memory**: `shared_memory.exe` exits 0 **without rewriting** the segment
  files (it attaches/validates; mtimes lie). A forced rebuild = delete
  `shared/items` + `shared/spells` while the server is down, run the loader in the
  foreground, confirm new mtimes. Zones read items/spells ONLY via these segments.
- **Paths**: the server reads `Build/bin/Release/eqemu_config.json` and
  `Build/bin/Release/quests` — never the `Release-NMS-Server/` source copies or the
  `Release-NMS-*` staging trees. Edit the runtime quest tree, then
  `sync-quests.bat` (repo root).
- **Bounces**: never stop/restart the server without an explicit go-ahead from the
  user in chat that turn (AGENTS.md). LNK1104 on zone/world/ucs = the processes are
  running; stage the build and report the bounce owed.
- **Launch**: `start-servers.bat` must be spawned detached (PowerShell
  `Invoke-CimMethod Win32_Process Create`) — the Bash tool reaps children.
- **MariaDB** runs as a Windows service named `mariadbd.exe` (grep "mysqld" and you
  will miss it).
- **Upstream** for the spirit system: `nightstalker6669/EQEmu` (develop branch) and
  its DB repo `nightstalker6669/EQEmu-Database` (AA packages AA007-020). Client RE:
  `shroudref/eqgame.i64` (IDA; eqgame 32-bit @0x400000, no ASLR); prior decode notes:
  holder kind `+0x340C` gates the shroud UI, Progress packet `0x541D`.

## Key files

| Area | File |
|---|---|
| Catalog model + Validate/Snapshot | `common/shroud/wire.h`, `common/shroud/catalog.h`, `common/shroud/aa_preview.h`, `common/shroud/resource_baseline.h` |
| Native engine | `zone/client_spirit_shroud.cpp` (loader `Catalog()` ~:126, `Offered()` ~:283, window ~:405, enter ~:752, restore ~:911, purchase ~:1218, reapply ~:1480) |
| Legacy engine + shared paths | `zone/shroud.cpp` (`SendShroudInventoryView` ~:1313 guarded, `SendShroudZoneInState` ~:1382, `LoadAndApplyShroudState` ~:1160, `RemoveShroud` ~:703, caps ~:883) |
| AA table sender | `zone/aa.cpp` (`SendClearPlayerAA` :631, `SendAlternateAdvancementTable` :1196, per-rank :1273 — shroud byte at :1343) |
| Quest bindings | `zone/lua_client.cpp` ~:1893–1952, `zone/perl_client.cpp` ~:1917–1932 |
| Crash handler | `common/crash.cpp` |
| Migrations | `common/database/database_update_manifest_custom.cpp` (v430–v441 entries; **not version-sorted**), twins in `utils/sql/` |
| Status doc | this file |


## 2026-11-17 — AA mapping onto the modern model (handoff correction)

The prior conclusion, "shrouds have no AAs / the client cannot render custom ids", was
wrong. Our monster AAs exist and are authored for the **legacy** system; the modern
spirit-shroud model expects a different shape. That mismatch — not a missing feature —
is why a shrouded AA window looked empty.

**What the two systems are**

| | Legacy (ours) | Modern (nightstalker6669) |
|---|---|---|
| Ability definitions | `aa_ability` ids **90100–93000** (plus classic lines) | `aa_ability` ids **< 49999**; `utils/sql/shroud/007_rof2_enumerable_aa.sql` states "RoF2 AA window enumerates 0 through 49998" and relocates 50000–50006 into 48000–48006 |
| Rank chains | multi-rank, category 3/4, classes 65535 | per-class masks, free `grant_only` starters, paid chains (`012`, `013`) |
| Form binding | `shroud_abilities(progression, branch, min_level, max_rank, aa_id)` — 7,906 rows, 11 progressions / 37 branch-sets | `spirit_shroud_abilities(template_id, rank_id, free_grant)` |

The v431–v441 work bound only **92 of 468** enabled templates, to a re-authored 48xxx
band. Birthday Cake 25 (template 110125) had **0** rows, so its ten Confections AAs
(Sprinkle Bomb, Birthday Blowout, Sugar Rush, Molasses Glaze, …) — and the whole
Brewing set — were unmapped. Every enabled form does have a legacy twin (468/468).

**Mapping produced** — `utils/sql/20261117_shroud_aa_mapping_v442.sql` (+ rollback twin),
generated by `tools/map_shroud_aas.py`:

- 124 legacy abilities copied into the enumerable band: ability ids **46000–46123**,
  rank ids **47000–47619** (620 ranks, 306 effects, 3 prereqs).
- Per-ability class mask = OR of the classes of the forms that bind it.
- 34,850 `spirit_shroud_abilities` rows binding **462 / 467** templates (20105 keeps its
  live-captured 48000–48006 starter set; it is excluded).
- Ranks are bound only while `level_req <= form level`; a form's rank total is capped
  by `Validate` at 300 (largest form: 240).

Validated inside a rolled-back transaction: no rank `>= 49999`, every bound ability is
category 3/4, every bound rank passes `level_req`, no negative cost, every class mask
contains the form's class, no form over 300 rows.

**Not applied yet.** Zones cache `aa_ability`/`aa_ranks` at boot
(`Zone::LoadAlternateAdvancement`), so applying before a restart would leave the
catalog pointing at rank ids the zone does not know and break entry. Order:
apply the SQL → restart zones → then register the manifest entry and bump
`common/version.h` (next gate 442) and rebuild.

**Authored gap, not a mapping gap:** the five mission props — Clay Golem 120125,
Rusty Steamboat 140140, Western Moorwalker 140240, Dwarven Ghost 140340, Wizard Armour
140440 — have no `shroud_abilities` rows at all, so nothing can be bound for them.

**Open display question:** the RoF2 AA window fills its monster list only when
`BaseProfile+0x340C` is 1 or 2 (eqgame `0x4A40F0`), and the only writer in the stock
client is the PcProfile loader — the DLL patch that retargeted the OP_Shroud store to
it was retired 2026-11-15 (`Release-NMS-Client/eqgame_dll/eqgame.cpp` ~:770). The
per-row byte is still `aai->shroud_row` (`zone/aa.cpp` :1343) and the encoder still ORs
in category 3/4 (`common/patches/rof2.cpp` ~:3622). If the mapped rows still do not
list after the restart, the next lever is that byte: the pre-2026-10-09 encoder wrote
`WriteUInt8(0)` unconditionally and listed the same content as ordinary rows.

### 2026-11-17 addendum — mission props and client files

The five mission props have no `shroud_abilities` rows of their own, so they borrow a
creature's set (template → progression/branch/level, capped at the prop's level):

| Template | Prop | Borrowed set | Rows |
|---|---|---|---|
| 120125 | Clay Golem 25 (warrior) | Aberrations / Gargoyle Fighter @25 | 19 |
| 140140 | Rusty Steamboat 40 (wizard) | Aberrations / Imp Wizard @40 | 92 |
| 140240 | Western Moorwalker 40 | Reptiles / Basilisk Beast @40 | 53 |
| 140340 | Dwarven Ghost 40 | Animals / Bear Beast @40 | 54 |
| 140440 | Master Officer Wizard Armour 40 (wizard) | Aberrations / Imp Wizard @40 | 92 |

All 468 enabled forms now bind; final state is **123 abilities, 617 ranks, 303 effects,
35,137 `spirit_shroud_abilities` rows**. One legacy ability (`Shroud Extended Shielding`)
carried `enabled=0` and was excluded rather than resurrected — it never reached the AA
loader in the old system either.

Client files regenerated from the live DB with `export_client_files.exe` (40,979 spells,
46,195 dbstr strings) and copied to `C:\Games\EQTriune` — `spells_us.txt`,
`dbstr_us.txt`, `BaseData.txt`, `SkillCaps.txt`, with `.bak-20261117` copies kept.
