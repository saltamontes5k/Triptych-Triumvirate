# Spirit shrouds — client-dependency retirement plan

Status: **plan, nothing implemented.** Revised 2026-11-12 after the shroud/housing investigation and
the maintainer's decisions below.

Scope: get shroud code out of `dinput8.dll` (the DLL itself stays — multiclass needs it), and
collapse the two server-side shroud implementations into one. Decision: **be true to upstream**
(`reference/nsqemu-spirit-shrouds/` = nightstalker6669/EQEmu develop + the spirit-shroud extension,
same RoF2 client, **no client patches**).

Client: RoF2 `C:\Games\EQTriune\eqgame.exe` (May 10 2013, Release #630). Server: EQS.

---

## 0. Decisions (maintainer, 2026-11-12)

1. **Reload**, not native no-reload transitions — match upstream's default
   (`Character:NativeSpiritShroudTransitions = false`).
2. **AA ids: follow upstream** — their whole shroud catalog lives below the RoF2 AA-window
   enumeration bound (see §5); our 90xxx band is our own invention.
3. **One shroud engine.** Quest-granted shrouds are the *entry point*, not a second system: on live
   the shroud came from an NPC/quest and still went through the one client protocol. Upstream's own
   entry is exactly that (keeper NPCs 202326/202327/202329 in PoKnowledge, hail/"shroud" say-links,
   a chan-8 chat hook).
4. **Leave AAs alone for now** (2026-11-12). No renumbering, no new id policy: client patch #1 stays
   as a permanent content contract. Tier 2 is withdrawn (§5) and the upstream id facts are kept only
   as a reference for a future content import.

### Live state (read from `rule_values`, 2026-11-12 — not compiled defaults)

| Rule | Value | Consequence |
|---|---|---|
| `Custom:ShroudsEnabled` | `true` | the legacy quest path is what runs today |
| `Custom:ShroudLiveMode` | `12` (bits 4 + 8) | bit 4 = stripped profile; bit 8 = the +0x350C carrier that requires client patch #4 |
| `Custom:EnableSpiritShrouds` | `false` | the native spirit-shroud protocol is compiled but dormant |
| `Custom:ShroudMonsterPointScale` | `100` | baseline ladder |
| `Custom:AllowTestSpiritShrouds` | `true` | no effect while the master rule is off |

Two rows each exist for `ShroudLiveMode` and `ShroudMonsterPointScale` (identical values — last row
wins, so harmless today). Clean up while touching this area.

---

## 1. What "shroud code" is today

### 1.1 Client (dinput8.dll) — the whole surface

| Symbol | File:line | What it does |
|---|---|---|
| `ApplyShroudFlowFix` | `eqgame.cpp:1046` | Applies four runtime patches (§2) |
| `ShroudRestoreHotbars` | `eqgame.cpp:1139` | Re-shows HotButtonWnd + pages 2–10 after the class rebuild |
| `g_shroudHotbarFixesLeft/NextTick` | `eqgame.cpp:1154` | 12 follow-up passes over ~6 s |
| `g_serverShroudState` (+ Valid/StampLeft/StampNext) | `eqgame.cpp:1166` | Captured from block +0x350C of 0x6562 |
| `g_aaRefreshAt` | `eqgame.cpp:1170` | Coalesced AA-window repopulate |
| `ShroudRefreshAAWindow` | `eqgame.cpp:1215` | Calls eqgame+0x609F90 |
| `ShroudStampServerState` | `eqgame.cpp:1227` | Writes BaseProfile+0x340C, then refreshes AA |
| `HandleWorldMessage` shroud branch | `eqgame.cpp:1440–1484` | 0x66b5/0x7a27 AA-refresh scheduling; 0x6562 capture + stamp + pose + hotbars |
| pulse ticks | `MQ2Pulse.cpp:355–405` | /sit+/stand pose nudge, hotbar follow-ups, stamp loop, AA refresh |
| `$Shrouded` TLO | `MQ2DataTypes.cpp:3170` | Reads `GetCharInfo2()->Shrouded`; data-only |

Everything else in the DLL is multiclass, LoN, power source, loot, etc. — untouched.

### 1.2 Server

- **Native spirit shrouds**: `zone/client_spirit_shroud.cpp` (~1,850 lines), `common/shroud/*.h`,
  `spirit_shroud_*` tables (v390/v391), **17 Shroud opcodes** in `emu_oplist.h` — 11 legacy-named
  plus 6 `OP_SpiritShroud*`; the "16-message May 2013 client set" excludes `OP_Shroud` itself.
  Values already match upstream (AUDIT-EQS §1).
- **Legacy quest shrouds**: `zone/shroud.cpp` (~1,500 lines), `shrouds` table,
  `character_shroud_aa`, `character_shroud_snapshot`, `Custom::ShroudsEnabled` /
  `ShroudLiveMode` / `ShroudMonsterPointScale`, Shroudkeeper quest scripts, Cake Defense
  `ApplyShroud(500)`.
- **The transform packet** (the thing that forces every client patch):
  `SendShroudTransform` (`zone/shroud.cpp:81`) → `ShroudSelf_Struct`
  (`common/eq_packet_structs.h:5677`) → `ENCODE(OP_Shroud)` → `BuildShroudProfileBlock`
  (`common/patches/rof2.cpp:5248`, hand-written 0x4FF8 offsets, state carrier at +0x350C).
- **Ported, mostly unused**: `SerializeShroudSpawn / NormalProfile / Inventory / BankItem`
  (`rof2.cpp:5158–5214`) have **no callers**; `SerializeShroudPreviewItem` (`:5216`) **does** —
  `client_spirit_shroud.cpp:544`, the native equipment-preview handler. `common/shroud/native_transform.h`
  (`ProfileReader`, `CompactFromNormal`, `Envelope`) has no callers either. `FillShroudTransformExtras`
  feeds only the transform packet.

---

## 2. The four client patches

| # | Patch | Address / bytes | Exists because |
|---|---|---|---|
| 1 | AA pane scan bound `0xC34F → 100000` — **not shroud code, never deleted** | 0x608CE0, 4 B | rank ids ≥ 49,999 invisible to the AA window (326 non-shroud rows today, §5) |
| 2 | Fix A: NOP `mov [flt_DD2630],0` | 0x4C2F60, 10 B | OP_Shroud self path nulls the local-player pointer and can early-return with it NULL (feigned pose, dead UI) |
| 3 | Fix B: `jnz +0x0A → jmp +0x0A` | 0x4C2F85, 2 B | forces the completion path (standstate + UI reload) |
| 4 | Flag store retarget `0x3408 → 0x340C` | 0x579255, 1 B | our block carries the shroud state at +0x350C; the client's `Shrouded` field is +0x340C |

Patches 2–4 exist **only because we send OP_Shroud at runtime**. Under the reload decision there is
no runtime transform at all, so **2–4 go**. Patch 1 is a content policy (see §5) and **stays**; it
lives in the same function today, so Tier 1 must move it into its own always-applied patch
(`ApplyAACatalogScanFix`, called unconditionally at DLL init) before deleting the rest.

---

## 3. Tier 0R — reload without a transform packet · 2–4 days · server only

This is the whole enabler, and it is much smaller than porting upstream's shadow-swap engine,
because our snapshot model already holds the real profile in memory.

### The ordering bug that makes OP_Shroud look necessary

- The zone-in profile is serialized and sent from `Handle_Connect_OP_ZoneEntry`
  (`zone/client_packet.cpp:2065`, `OP_PlayerProfile`).
- `LoadSpiritShroudState()` + `LoadAndApplyShroudState()` run in `Client::CompleteConnect()`
  (`zone/client_packet.cpp:880–885`), which is called later, from
  `Handle_Connect_OP_ClientReady` (`:1409–1411`).

So the client is always sent the **real** profile first, and the only way to show the form is the
deferred OP_Shroud at zone settle (`ResendShroudState`, `m_shroud_zonein_pending`,
`client_process.cpp:158`). Move the state application above the profile send and the transform is
unnecessary: the client logs in already wearing the form, exactly as upstream's DB-rewritten
profile does.

### Steps

1. Move `LoadSpiritShroudState()` + `LoadAndApplyShroudState()` (and the multiclass
   `m_pp.classes` assignment at `:887`) from `CompleteConnect()` to the **end of the `m_pp`
   assembly** in `Handle_Connect_OP_ZoneEntry` — after the bandolier/bind work at `:1711+` and the
   skill-slot refresh that runs through `:2059`, immediately **before** the profile packet is built
   at `:2061–2065`. Not "top of the function": the loads span the whole handler and a form applied
   mid-assembly would be overwritten by later component loads. Guard for a failed auth path.

   Extra benefit: the "zone died mid-shroud → restore the real profile" branch
   (`client_packet.cpp:882–884`) now reaches the client **on the wire**, instead of only through the
   deferred OP_Shroud.
2. Form change (enter/exit) persists the snapshot as today, then **reloads the client in place** —
   same zone, same instance, current x/y/z and heading preserved (`MovePC` with the preserved
   position). Deliberately **not** `EvacToSafeCoords`: that teleports to the safe point, which is a
   behaviour change nobody approved. If a safe-point landing is ever wanted, make it a per-mission
   option and document it.
3. Convert or account for **all five** `SendShroudTransform` call sites before deleting anything:

   | Site | Path | Tier 0R action |
   |---|---|---|
   | `shroud.cpp:655` | legacy enter (`ApplyShroud`) | convert to reload |
   | `shroud.cpp:746` | legacy exit (`RemoveShroud`) | convert to reload |
   | `shroud.cpp:1373` | legacy zone-in re-apply (`ResendShroudState`) | delete with the function — the pre-profile load replaces it |
   | `client_spirit_shroud.cpp:872` | native enter (`EnterNativeShroud`) | unreachable while `EnableSpiritShrouds=false`; **left in place** for Tier 3 (or stubbed to reload if the rule is ever turned on early) |
   | `shroud.cpp:1339` | native zone-in re-apply (`ResendShroudState`) | delete with the function |

   Because the native enter survives, the **`ENCODE(OP_Shroud)` + `BuildShroudProfileBlock`
   deletion is deferred to Tier 3** (`rof2.cpp:5481–5518`), unless Tier 0R stubs that call site.
4. Delete now: `ResendShroudState` and both branches, `m_shroud_zonein_pending` /
   `m_shroud_zonein_at`, the `client_process.cpp:158–160` deferred block,
   `FillShroudTransformExtras`, and the four genuinely-dead serializers
   (`SerializeShroudSpawn / NormalProfile / Inventory / BankItem`). **Keep**
   `SerializeShroudPreviewItem` — `client_spirit_shroud.cpp:544` still calls it for the native
   equipment preview.
5. Keep `ShroudPersistGuard` semantics: while the form is on, saves write the real profile, never
   the form.

### Verification (must pass before any client patch is deleted)

- Enter a form, camp, relog: still the form, correct class/level/HP/mana/endurance/appearance/AA.
- Exit: real character back, AAs/points/XP unchanged, inventory unchanged (rows, not just client).
- Zone while shrouded; die while shrouded; merc suspended; corpse rules unchanged.
- AA window lists the form's AAs as ordinary owned ranks; purchases persist.
- No OP_Shroud on the wire in any of the above (zone log: grep `OP_Shroud`).
- Run the Cake Defense (rivervale) and King of the Monsters (moors) mission controllers once
  end-to-end: the seven fixed missions must survive the settle-window removal (see §6, "What Tier 0R
  changes").

### Risks

- Zone-in cost per form change (seconds) — accepted by the decision.
- Anything that reads the profile before `Handle_Connect_OP_ZoneEntry` must tolerate the form
  (e.g. multiclass `m_pp.classes`, class-gated skill load, tribute/buff slots).
- Same-zone reload must not re-trigger loot/corpse or task state twice; test with an active task.

---

## 4. Tier 1 — delete the client shroud code · 0.5 day, after Tier 0R

Inside `dinput8.dll`, delete everything shroud-related in §1.1 **except patch #1** (content
policy, §5 — it must be moved to its own always-applied `ApplyAACatalogScanFix` and out of
`ApplyShroudFlowFix` first) and the `$Shrouded` data read (one line, harmless):

- `ApplyShroudFlowFix` **minus the AA scan bound** — i.e. patches 2–4 only, then delete the
  function's remainder: `ShroudRestoreHotbars`, `g_shroudHotbarFixes*`, `g_serverShroudState*`,
  `ShroudStampServerState`, `ShroudRefreshAAWindow`, `g_aaRefreshAt`.
- The `0x6562` branch and the `0x66b5/0x7a27` scheduling in `HandleWorldMessage`; with them
  `g_shroudPoseFix` (defined at `eqgame.cpp:1042`) goes too.
- The pulse block (`MQ2Pulse.cpp:355–405`: pose nudge, hotbar follow-ups, stamp loop, AA refresh),
  which also drops its four `extern` references.
- **Keep** `ShroudPatchLog` — patch #1 still logs its byte guard through it.
- `Custom:ShroudLiveMode` loses its purpose: bits 1/2/4/8 all describe the transform packet.
  Update the rule description (`common/ruletypes.h:1236`) and delete the bit handling, or retire
  the rule in favour of `Custom:EnableSpiritShrouds`.
- While in `ruletypes.h`: `:1241` says `EnableSpiritShrouds` "Requires the v388 migrations", but
  they landed as **v390/v391** — fix the description.

Client release, not a server build. Verify with `nms_client_patch.log` absent of shroud lines and
the §3 checklist still green.

---

## 5. Tier 2 — AA ids · **WITHDRAWN 2026-11-12 (leave AAs alone)**

> Decision: no AA renumbering and no id policy change. Client patch #1 stays permanently and is
> documented as a server-wide content contract ("our AA rank ids may exceed 49,999; the client's AA
> pane scan is widened to 100,000"). The facts below are kept for a future content import only.

### Reference: what upstream does

Upstream's policy (their `utils/sql/shroud/007_rof2_enumerable_aa.sql`, quoted):
"RoF2 AA window enumerates numeric rank IDs 0 through 49998" — so they *relocate* 50000–50006 down
to **48000–48006** rather than patch the client. Their enabled content:

| Upstream band | Content |
|---|---|
| 48000–48006 | seven free adapters (Eyes Wide Open, Fire, Frost, Thunder, Flight, Ultravision, Spirit Sending) |
| 48400+ (step 5/10) | the 47 captured paid Monster groups / 329 ranks (012/013) |

No shroud rank id there exceeds 48,999. Ours are 90,001–91,564 (466 rows) — our invention.

### If we ever revisit

- If we import their catalog, the shroud ids arrive as 48xxx and need no patch. **Do not remap them
  into 90xxx.**
- Patch #1 would still be needed for *non-shroud* content above the bound: 124 multiclass ranks
  (61,626–62,571) and 202 custom ranks (93,000–93,201) = **326 rows**. Free ids at 45,002–49,998:
  4,997, so "zero patches" would mean renumbering those too — a multiclass-content decision.

---

## 6. Tier 3 — one engine, quests as entry points · project-sized

### Live precedent: Old Man McKenzie's "Monster Select"

Live's monster missions (Old Man McKenzie in PoK, "say groups" → pick a mission) open a
**"Monster Select" window with a list of classes**, each member picks a form, and the group zones in
as monsters with a classic gear/stat loadout
([pakcafaneq write-up](https://pakcafaneq.wordpress.com/old-man-mckenzie-missions/)).

That window *is* this protocol: `OP_ShroudSelectionWindow` 0x2ec3 = upstream's
`OP_SpiritShroudSelection`, its PROGRESSION/BRANCH/TEMPLATE tree = the "bunch of forms", the
starter-equipment rows = the gear you zone in with, and the mission itself is ordinary task/quest
code. So a McKenzie-style NPC is exactly the Tier 3 shape: a keeper that opens the window plus a
task script around it. Nothing new is needed on the wire — the forms are data.

### Catalog reality (measured in the live `peq`, 2026-11-12)

| Table | Rows |
|---|---|
| `spirit_shroud_templates` | **0** |
| `spirit_shroud_starter_equipment` | **0** |
| `spirit_shroud_spells` | **0** |
| `spirit_shroud_abilities` | **0** |
| `spirit_shroud_progression_definitions` | 8 |
| `spirit_shroud_branch_progression` | 34 |
| `spirit_shroud_entitlements` | 0 |
| legacy `shrouds` (what runs today) | **496 forms**, 12 progressions, 38 branches |
| legacy `shroud_abilities` | 7,906 id references |

v391 seeds **only the progression skeleton** — its only statements are two `INSERT IGNORE`s (8
definitions, 34 branches); there are no template inserts in it. Upstream's 009 (3,769 template rows,
of which they enable 112 = 8 families × levels 5–70), 006 (starter equipment, e.g. Rusty Staff
94114 / Backpack 94074) and 011 were the manual import step and are **not in this database**.

**Consequence: flipping `EnableSpiritShrouds` on today opens an empty window.** Catalog import is a
hard prerequisite for Tier 3, with two decisions: which catalog wins (our 496 legacy forms vs
upstream's 3,769 rows / 112 enabled), and the starter item ids must exist in shared memory before
any form is offered.

### Quest entry points: what exists today

| Capability | Status |
|---|---|
| Quest NPC opens the **native** window | **Yes, already** — `client:OpenShroudWindow(npc)` is bound in Perl and Lua (`perl_client.cpp:4299`, `lua_client.cpp:4539`) and `Client::OpenShroudWindow` dispatches to `OpenSpiritShrouds()` when `Custom:EnableSpiritShrouds` is on and the client is RoF2 (`zone/shroud.cpp:494`) |
| Quest flips the **system** on | **No, by design** — `Custom:EnableSpiritShrouds` is a `rule_values` row (live: `false`), cached server-wide. Per-player access is data, not a rule |
| Quest **unlocks a form for one player** | **Hook exists, writer missing** — a template with `entitlement_key` is offered only when `spirit_shroud_entitlements` holds that character+key (`client_spirit_shroud.cpp:300–306`), but nothing in the tree INSERTs into that table |
| Quest **applies a form directly** (Cake Defense style) | **No binding** — `ChangeSpiritShroud(template)` requires `Keeper(...)` (an open keeper session), and only the legacy `ApplyShroud(shroud_id)` is script-exposed |
| Quest removes a form | `RemoveShroud()` / `RemoveShroudSilent()` bound, legacy path only |

### Mission-scoped windows (Cake Defense, McKenzie)

A mission can dictate the list: McKenzie offers that mission's class list, and a tradeskill quest
like Cake Defense needs exactly **one** form (the cake enchanter).

### Three shapes, one enforcement point

| Shape | Caller today | Binding after one-engine |
|---|---|---|
| **Fixed** — one form, no menu | 7 missions call `client:ApplyShroud(id)`: Cake Defense (rivervale), King of the Monsters (moors), Pottery Trial (beholder), Dwarven Wedding (kaladima), Derelict Space Station (netherbian), Boat Lesson (oot), Midnight Snack (skyshrine) | `client:ApplySpiritShroud(id)` |
| **Shortlist** — choose from N | **missing** (would be the Halo parody's shape) | `client:OpenSpiritShroudWindow(npc, "id1,id2,...")` |
| **Open** — the catalogue | 3 Shroudkeepers in PoKnowledge (`OpenShroudWindow(e.self)`) | `client:OpenSpiritShroudWindow(npc)` |

The mission decides the shape, never the NPC: one McKenzie can run a fixed mission and a
choose-your-monster mission back to back, and the group members each get their own window for
their own choice. List size is 1..N; a one-element shortlist renders as a single row.

Today:

- The legacy path never opens a menu for such a quest — the script calls
  `client:ApplyShroud(500)` and the form is applied directly.
- The native window (`OpenSpiritShrouds`, `client_spirit_shroud.cpp:400`) always lists every
  form the character has globally unlocked (`Offered()`: progression XP + entitlement), so it
  cannot express "only this one".

What a filtered window needs:

1. **Allowed set on the window**: `OpenSpiritShrouds(allowed)` filters `Catalog()` to the given
   ids, bypasses the progression/entitlement gate for them (the quest is the authority) but keeps
   `SpiritShroud::Offered`'s enumerability check — a form whose ranks the client cannot enumerate
   must never be listed. The tree needs no change: PROGRESSION/BRANCH headers are emitted only for
   rows that pass the filter (`:428–446`), so one allowed template renders as one row.
2. **Server-side whitelist, not just UI**: store the allowed set with the menu
   (`m_spirit_shroud_allowed`), clear it on cancel/apply/timeout, and enforce it in
   `Handle_OP_SpiritShroudSelect` → `ChangeSpiritShroud` **and** in the preview handler. Hiding
   rows client-side is cosmetic; a crafted `0x1cd0` must not take a form the quest did not offer —
   today it only re-checks global availability, and with the gate bypass above that check weakens.
3. **Bindings**: `client:OpenSpiritShroudWindow(npc [, id_list])` (comma-separated ids for Perl/Lua)
   and `client:ApplySpiritShroud(template_id)` for the no-menu case. Both must take the keeper from
   the **NPC argument**, not `GetTarget()`, and keep the existing 40-unit proximity check and
   120-second menu window (`Keeper()`, `client_spirit_shroud.cpp:116`).

Cake Defense then stays a one-liner either way: `ApplySpiritShroud(cake_enchanter)` (no menu, as
today) or `OpenSpiritShroudWindow(npc, "cake_enchanter")` (one-row menu, live-like).

### What Tier 0R changes for those 7 missions

Their controllers poll for `client:GetRace() ~= <form race>` and then rely on a deliberately
delayed apply — `#Cake_Defense_Baker.lua:225–256` documents a "5s zone-settle window before
OP_Shroud flies" and carries a `prepared` marker plus a "persisted shroud" branch for relogged
members. With a reload and no transform:

- the settle window and the double-apply dance disappear (the form arrives with the profile);
- `GetRace() == <form race>` stays valid as the "already in the form" test;
- a relogged member is re-applied by the zone-in path before the profile is sent, so the
  "persisted shroud" special case collapses into the same branch.

That is a simplification of the seven controllers, not just of the DLL — worth a line in the
Tier 0R verification (run Cake Defense and King of the Monsters once each).

### Deliverables for the one-engine step

1. **Entitlement writer + binding**: `client:GrantSpiritShroudEntitlement(key)` /
   `RevokeSpiritShroudEntitlement(key)` (and a `#shroud entitlement` GM command for testing), writing
   `spirit_shroud_entitlements`. That is the live-like "this quest unlocks this form" handle.
2. **Scripted apply/remove**: `client:ApplySpiritShroud(template_id)` /
   `client:RemoveSpiritShroud()` that (a) validate the calling NPC as the keeper/trigger, (b) reuse
   the gate list (dead/engaged/casting/trade/cursor — see §7 for why the spoof interaction is
   documented, not enforced), (c) enter through
   `EnterNativeShroud` without requiring a client-side session. This replaces Cake Defense's
   `ApplyShroud(500)`.
3. **Repoint `OpenShroudWindow`** callers (Shroudkeeper scripts) — already correct; verify with the
   rule on.
4. **Mission-scoped windows + whitelist** (§ above): filter parameter, per-client allowed set
   enforced on select/preview, scripted apply binding.
5. **Import the catalog + starter loadout** (prerequisite for 1–4 to be visible): pick the winning
   catalog, import templates/equipment/spells/abilities, ensure starter item ids exist, and decide
   the per-character gates (progression XP vs entitlement keys).
6. **Then delete the legacy path**: `shrouds`, `character_shroud_aa`, `character_shroud_snapshot`,
   the legacy handlers, `Custom:ShroudLiveMode`.

### Why the duplication exists

Today the two implementations dispatch on the same opcodes:
`Handle_OP_ShroudSelect` → `Handle_OP_SpiritShroudSelect` when `Custom:EnableSpiritShrouds`
else the legacy handler. Two catalogs (`shrouds` vs `spirit_shroud_templates`), two storage models
(`character_shroud_snapshot`/`character_shroud_aa` vs `spirit_shroud_*`), two points systems
(`ShroudLiveMode` monster points vs allocations/entitlements).

That duplication is history, not design: the legacy path predates the port. On live there was one
protocol and the shroud came from quests — so quests become *callers* of the one engine (§6
deliverables above). The snapshot model stays as the storage backbone (Tier 0R depends on it) even
while the catalog and protocol become upstream's.

---

## 7. Sequence and gates

| Step | What | Gate |
|---|---|---|
| 1 | **Tier 0R** (server) | §3 checklist green with the current DLL |
| 2 | **Tier 1** (DLL) | a shipped client build with no shroud code left except the AA scan patch; §3 checklist still green |
| 3 | ~~Tier 2 (AA ids)~~ | **withdrawn** — AAs left alone; patch #1 stays |
| 4 | **Tier 3** (catalog import → one engine + quest entry points) | separate project; can start any time after 0R; catalog import first so the window is never empty |

**What stays regardless:** `dinput8.dll` and all multiclass machinery; the 17 Shroud opcodes
(16-message native set + `OP_Shroud`); the spirit-shroud catalog/protocol; the AA scan patch;
`$Shrouded` as a data read if anything uses it.

### Cross-system gate: spoof vs form change

Multiclass swaps `pPlayer->Class` / `pCI2->Class` around class-gated skill checks and sets
`g_blockOutgoingPackets` for that window (`eqgame.cpp:714/755/1702`). The spoof exists **only in
the client** — the server never sees it, so a "server-side flag" is not implementable as written.

What is true instead: `g_blockOutgoingPackets` already suppresses client→server packets while the
spoof is up, so a form-change request (`0x1cd0`) cannot be sent mid-spoof — the practical risk is
near zero. Keep the existing server gate list (dead/engaged/casting/trade/cursor) and **document
the spoof interaction** rather than inventing a barrier. If belt-and-braces is ever wanted, the
check belongs in the DLL (that is *our* DLL, not an `eqgame.exe` patch, so it does not violate the
"no client patch" rule) or the DLL announces spoof state to the zone; either is a deliberate
addition, not a prerequisite.

### Verification kit

- In game: Imp 5 and Bear 70 enter/exit; AA window; purchase; camp; relog; zone while shrouded;
  die while shrouded; merc suspend; task active during reload.
- Logs: no `OP_Shroud` on the wire; `nms_client_patch.log` has no shroud lines after Tier 1.
- DB: `character_shroud_snapshot`, `spirit_shroud_state`, `character_shroud_aa` unchanged across a
  round trip; inventory rows byte-identical (the 2026-11-12 item-tail bug was invisible in the DB).

---

## 8. Review log

Independent review, 2026-11-12: every file:line anchor, DB count and upstream quote re-checked
against the tree and the live `peq`; all confirmed except two noted as author-measured (upstream's
009 = 3,769 rows / 112 enabled; the full 16-value wire parity). Five findings were fixed in this
text:

1. **Patch #1 is not shroud code** — Tier 1 no longer deletes `ApplyShroudFlowFix` wholesale; the AA
   scan bound moves to its own always-applied patch (§2, §4), keeping the 326 non-shroud rows in the
   61k/93k bands visible.
2. **"Zero callers" was 4-of-5** — `SerializeShroudPreviewItem` is used by the native equipment
   preview (`client_spirit_shroud.cpp:544`); it stays, the other four go (§1.2, §3 step 4).
3. **The native engine also rides OP_Shroud** — all five `SendShroudTransform` sites are now named
   with their disposition, and the encoder/block deletion is deferred to Tier 3 (§3 step 3).
4. **The spoof barrier had nothing to read** — spoof state is client-side only; the section now says
   `g_blockOutgoingPackets` already covers the window and records the DLL/announce options instead of
   a server-side flag (§7).
5. **"EvacToSafeCoords" was ambiguous** — the reload is specified as in-place (same zone, instance,
   x/y/z, heading preserved), explicitly not the safe point (§3 step 2).

Minor: opcode count clarified (17 declarations = 16-message native set + `OP_Shroud`), the
`EnableSpiritShrouds` rule text's "v388" corrected to v390/v391, and the Tier 0R insertion point
pinned to the end of the `m_pp` assembly rather than "top of the handler".
