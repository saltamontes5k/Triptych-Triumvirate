# Hero tab — Rockin-Vik port plan

Status: **plan, nothing implemented** (the UI page is the exception, already in
`Release-NMS-Client/ClientFiles/uifiles/default/EQUI_Inventory.xml`). Written 2026-11-22.

Source: `Rockin-Vik/NMS-Release` @ **0321afb** (2026-09-10), sparse clone
(`Release-NMS-Client`, `Release-NMS-Deploy`, `Release-NMS-Quests`, `Release-NMS-Plugins`,
`Release-NMS-Server/zone`, `.../utils/patches`).

Scope: bring the Hero (multiclass add/remove) tab from NMS into EQS, on the **Class** page that
already exists here (hero top, rule, shroud forms bottom). Does not include shroud catalog import.

---

## 0. What the port actually is

Four layers, and only the first is new to EQS:

| Layer | NMS shape | EQS today |
|---|---|---|
| 1. Stat keys `ClassLevel1..16` in `OP_ServerAuthStats` | per-class levels ride the bulk stats packet (§11.1 D11) | stat subsystem **exists**, keys do **not** |
| 2. `OP_HeroRequest` + `Handle_OP_HeroRequest` | client→server add/remove; reply is a bulk stats push | absent |
| 3. `hero_tab.cpp/.h` + stat accessors + click detour | 323-line painter, ScreenID lookups per use | absent |
| 4. Quest policy `EVENT_HERO_REQUEST` → `plugin::HeroRequest` | doors share one Perl policy | plugin exists, no HeroRequest |

The reason the port is small on the server side is that EQS already inherited
`Custom:ServerAuthStats`, `SendBulkStatsUpdate`, and the multiclass core
(`AddExtraClass`/`RemoveExtraClass`, `GestaltClasses` bucket).

## 1. Current EQS state (verified)

| Thing | Where | State |
|---|---|---|
| `AddExtraClass` | `zone/client.cpp:14938` | yes — bool, no reason code, **no shroud guard** |
| `RemoveExtraClass` | `zone/client.cpp:14976` | yes — unscribes/unmems/untrains/ejects; **no shroud guard** |
| class cap rule | `Client::GetMaxPlayerClasses` (`Custom:MaxPlayerClasses`) | yes — NMS's name is `Custom:MaxMulticlasses` |
| `StatEntry` enum | `common/eq_packet_structs.h:1429–1559` (`statMax` at 1559) | yes |
| `SendBulkStatsUpdate` | `zone/inventory.cpp:3994` | yes — sends `statMax-1` entries |
| dll stat decode | `MQ2Labels.cpp:1113–1132`, `eStatEntry` at 189 | yes — **tolerant**: skips keys `>= eStatMax` |
| multiclass helpers in dll | `ClassAbbr[17]`, `BuildClassAbbrFromMask`, `GetClassAbbreviationString` | yes |
| `OP_HeroRequest` | — | **absent** |
| `hero_tab.cpp/.h` | — | **absent** |
| `EVENT_HERO_REQUEST` | `zone/event_codes.h` | **absent** |
| `plugin::HeroRequest` | `Release-NMS-Plugins/NMS_multiclass_utils.pl` | **absent** (has `AddClass`, `RemoveClass`, `IsValidToAddClass`) |
| `#hero` command | `zone/gm_commands/` | **absent** (NMS: `gm_commands/hero.cpp`) |

## 2. Opcode: 0x140C is taken here

NMS reserves `0x140C`. **This server already uses it.** `patch_RoF2.conf`:

| Value | Owner |
|---|---|
| 0x1400 | `OP_CustomDiscTimer` |
| 0x1402–0x1409 | waypoints, character sets, `OP_SuppressBuffNameInfo` |
| 0x140A | `OP_NMSWindowData` |
| 0x140B | `OP_NMSWindowEvent` |
| **0x140C** | **`OP_NmsLootOffer`** |
| 0x140D | `OP_NmsLootDecision` |
| 0x140E | skipped (free) |
| 0x140F | `OP_ClientReport` |
| 0x1410 / 0x1411 | `OP_PersonalLootList` / `OP_PersonalLootAction` |

Free candidates: **0x1401** (unlisted) and **0x140E** (explicitly skipped). Recommendation: 0x1401,
because 0x140E carries a "skipped" comment that implies a reservation. Confirm against the client
dll's own opcode table before committing.

## 3. Decisions

| # | Decision | Why |
|---|---|---|
| D1 | Hero opcode = **0x1401**, not NMS's 0x140C. | 0x140C is `OP_NmsLootOffer` here. |
| D2 | Phase 1 handler calls the existing bool `AddExtraClass`/`RemoveExtraClass` and composes refusal text inline. Do **not** port NMS's `AddClassResult`/`RemoveClassResult` reason-code API up front. | The reason-code API (`client.cpp:15000–15116`, plus Perl/Lua bindings) is a refactor of every door. Port it only if message parity with the guildmasters is required. |
| D3 | Keep `Custom:MaxPlayerClasses`. Do not import `Custom:MaxMulticlasses`. | Same semantic, our names are already deployed in quests. |
| D4 | **Ship the server keys first, dll second.** | `MQ2Labels.cpp:1128` already skips unknown keys, so an old dll receiving 16 extra entries is safe; the reverse (new dll, old server) just shows an empty list. No lockstep release needed. |
| D5 | Add the shroud guard NMS never needed: `AddExtraClass`/`RemoveExtraClass` return false while `IsShrouded()`, and the handler refuses before dispatch. | `RemoveExtraClass` unscribes spells, untrains discs and ejects worn items — fatal against a shroud snapshot. See `shroud-tab-ownership-spec.md` D5. |
| D6 | New event constant in `zone/event_codes.h` + `perl_event_export_settings` row; confirm the next free id, do not reuse NMS's 146. | Event ids are global; ours has drifted. |
| D7 | The tab stays as built: one **Class** page, hero top, rule, shroud forms bottom. No sixth tab, no takeover of the stock ACP controls. | Already shipped in the XML; keeps the shroud row home intact. |

## 4. Phases

| Phase | Work | Exit criteria |
|---|---|---|
| **P1** | Server stat keys: 16 entries appended to `StatEntry` before `statMax`; `GetStatEntryValue` cases; dll `eStatEntry` mirror in the same order; `NMS_GetClassesBitmask`/`NMS_GetClassLevel(/_Raw)`/`NMS_GetClassAbbr` accessors. | Old dll + new server: no UI change, stats still correct. New dll + new server: accessors return real per-class levels (probe with `/echo` or a temporary debug print). |
| **P2** | Opcode: `emu_oplist.h`, `patch_RoF2.conf` (0x1401), `client_packet.h` decl, `Handle_OP_HeroRequest`, REGHANDLER entry; handler = D5 guard → D2 bool call → `SendBulkStatsUpdate()`. | A hand-built 8-byte packet (or `#hero`) adds and removes a class; shrouded character is refused. |
| **P3** | Client tab: port `hero_tab.cpp/.h`; `vcxproj` entries; `HeroTab_OnStatsUpdated()` call after the stat-map refresh; `HeroTab_HandleClick()` from the existing `CSidlScreenWnd::WndNotification` detour; `_options.h` flag. | Tab lists 16 classes with levels/status; Add/Remove work; list survives `/loadskin`. |
| **P4** | Quest policy: `EVENT_HERO_REQUEST` dispatch (global player script only), `global_player.pl` case, `plugin::HeroRequest` in `NMS_multiclass_utils.pl` (reusing `AddClass`/`RemoveClass`). | One policy for the tab, guildmasters and Lady Lachesis; refusal text comes from one place. |
| **P5** | `#hero` GM command (port `gm_commands/hero.cpp`, adapted to our rule name). | `#hero add 5` / `#hero remove 5` work for a GM. |

P1 and P2 can land without the dll; P3 is the first phase that needs a client build.

## 5. Risks

| Risk | Mitigation |
|---|---|
| Stat enum drift between server and dll (order matters, `statMax` is the count) | Append both sides in one commit; keep `ClassLevel1..16` contiguous and last. |
| `RemoveExtraClass` destructiveness inside a shroud | D5 guard, tested with the legacy shroud path before the shroud engine is unified. |
| `OP_HeroRequest` colliding with an unlisted 0x1401 use | Grep the dll's opcode table and `patch_*.conf` for 0x1401 before committing. |
| Tab repaint storms (`OP_ServerAuthStats` fires on every HP/mana tick) | Port NMS's dirty-check memo (mask/level/selection/list pointer) rather than redrawing per packet. |
| Quest door drift: tab adds, guildmasters remove, plugin rules disagree | P4 makes `plugin::HeroRequest` the single entry; the tab only sends and displays. |

## 6. Open questions

1. Reason-code API (D2) — ship inline messages now, or port `CanAddExtraClass`/`CanRemoveExtraClass` first so all three doors share wording?
2. Does EQS keep NMS's catch-up rule at all (join-at-watermark)? Our `AddExtraClass` has no watermark parameter, so the port either drops catch-up or grows the signature.
3. `#hero` — needed for testing, or is a hand-rolled packet enough?
4. The Shrouds→Class tab rename is done in one skin only (`default/`); no other skin ships `EQUI_Inventory.xml` today.
