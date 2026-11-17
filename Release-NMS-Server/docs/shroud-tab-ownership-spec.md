# Shroud tab — ownership and double-duty spec

Status: **spec, nothing implemented.** Written 2026-11-14. Successor to
`spirit-shroud-client-dependency.md` (which owns the *protocol* retirement); this document owns the
*tab*.

Scope: decide who paints the RoF2 Inventory window's Shrouds page, and how the three claimants —
functional spirit shrouds, the NMS multiclass "Hero" panel, and the EQL-style "one tab, two duties"
pattern — coexist without a second painter, without losing shroud progress, and without letting a
class change mutate a shrouded character.

---

## 0. The question this answers

"There is a shroud tab, did nightstalker6669's repo never do work on it?"

**No. They never touched it.** CONFIRMED by search of the vendored tree
(`reference/nsqemu-spirit-shrouds/`, = nightstalker6669/EQEmu `rof2-spirit-shrouds` @
`e7cb5dc2`, upstream develop `c9c8747a`):

| Check | Result |
|---|---|
| Any `EQUI_Inventory.xml`, `IW_AltCharProgPage`, `ACP_Progression*`, `TabText` reference | none |
| UI XML shipped anywhere in the tree | none — only `extensions/rof2/housing/patches/rof2-housing-finance-width.patch` (`EQUI_RealEstateManageWnd.xml`) |
| Opcode named after a tab | none — all sixteen are Selection/Request/Details/Select/Cancel/Progress*/Ability*/Equipment*/Transform/Complete/Bank* |

Their shroud UI surface is the **selection window** (`OP_SpiritShroudSelection` `0x2ec3`, the
"Monster Select" window) plus progress messages (`0x3823` append, `0x541d` replace), entered from a
keeper NPC. The Inventory Shrouds page is invisible to their design — which is exactly why they
needed no client patches and why their branch composes with anything sitting on that page.

That is the load-bearing fact for reconciliation: **the tab is a viewer, not the feature.**

---

## 1. What exists in this tree today

### 1.1 The tab is stock and shipped

`Release-NMS-Client/ClientFiles/uifiles/default/EQUI_Inventory.xml` carries the untouched page:

| Line | Item | Role |
|---|---|---|
| 9997 | `<Page item="IW_AltCharProgPage">` | the tab host |
| 9998 | `<ScreenID>AltCharProgPage` | tab identity in client code |
| 10004 | `<TabText>Shrouds` | the visible label |
| 10016 | `<Pieces>…ACP_ProgressionLayout` | page wiring |
| 9978 | `<VerticalLayoutBox item="ACP_ProgressionLayout">` | layout |
| 9922 | `<Listbox item="ACP_ProgressionList">` | progression rows |
| 9958 | `<STMLbox item="ACP_ProgressionInfo">` | detail pane |

So: the tab exists, is stock, and this repo ships it unmodified. Whatever the client normally draws
inside `ACP_ProgressionList/Info` is available to us at zero cost.

### 1.2 The Hero panel is not in this tree

- No `hero_tab.cpp/.h` in `Release-NMS-Client` (glob empty).
- No `OP_HeroRequest` anywhere in `Release-NMS-Server` (grep empty).
- NMS shipped it: `hero_tab.h` paints four ScreenIDs on this exact page and sends
  `OP_HeroRequest` `0x140C`; `0x140A/0x140B` are `OP_NmsLootOffer/Decision`.
  Their spec (`2026-09-05-hero-catchup-multiclass-design.md` §11.2) says: *"Replace the unused
  **Shrouds** tab (`IW_AltCharProgPage`)… Do not add a sixth tab."*

### 1.3 The shroud feature, in this tree

Two implementations, dispatched on the same opcode values:

| | Legacy quest shrouds | Native spirit shrouds |
|---|---|---|
| Code | `zone/shroud.cpp` (~1,500 lines) | `zone/client_spirit_shroud.cpp` (~1,850 lines) |
| Transform | `OP_Shroud` `0x6562` → needs DLL patches 2–4 | `OP_SpiritShroudTransform` `0x6562` — **same value**, no patches |
| Entry | Shroudkeeper quest scripts | keeper NPC → `OP_SpiritShroudSelection` `0x2ec3` |
| Storage | `shrouds`, `character_shroud_snapshot`, `character_shroud_aa` | `spirit_shroud_*` tables |

Live gates, read from `rule_values` 2026-11-14 (not compiled defaults):

| Rule | Value |
|---|---|
| `Custom:ShroudsEnabled` | `true` |
| `Custom:ShroudLiveMode` | `12` (bits 4+8; two identical rows) |
| `Custom:EnableSpiritShrouds` | `false` |
| `Custom:ShroudMonsterPointScale` | `100` |
| `Custom:AllowTestSpiritShrouds` | `true` (inert while master rule off) |

Catalog state (from the companion doc, re-confirm before relying on it): `spirit_shroud_templates`
= **0 rows**. Flipping `EnableSpiritShrouds` today opens an empty window.

---

## 2. Collision analysis

Three surfaces, only two of them shared:

| Surface | Shroud path needs it? | Hero path needs it? | Verdict |
|---|---|---|---|
| Inventory Shrouds page | **no** (entry is NPC → `0x2ec3`; progress via `0x3823/0x541d`) | yes (NMS paints it) | single-writer problem, not a feature conflict |
| `Shrouded` flag at `BaseProfile+0x340C` | yes (gates AA monster mode, `$Shrouded`, hotbars) | no | Hero must respect it |
| Class/race/AA mutation | yes (transform swaps all three) | yes (`AddExtraClass`/`RemoveExtraClass`) | **real hazard** — see §2.1 |

### 2.1 The one genuine defect

`Client::AddExtraClass` ([client.cpp](Release-NMS-Server/zone/client.cpp#L14938)) and
`Client::RemoveExtraClass` ([client.cpp](Release-NMS-Server/zone/client.cpp#L14976)) have **no shroud
guard**. The remove path is the dangerous one — it unmemorizes spells, unscribes spellbook entries,
untrains disciplines (`SaveSpells()`/`SaveDisciplines()`), ejects worn items, and kills pets, all
against live character state. While shrouded, that state is a snapshot the shroud will restore from;
mutating it is a data-integrity bug independent of any UI.

Meanwhile the AA path is already shroud-aware — `IsShroudAA` filtering while shrouded
(`aa.cpp:2509`, `:2590`), shroud-only rank visibility (`:1785`), monster-mode unspent
(`:1455`) — so a class change firing `SendAlternateAdvancementTable()` mid-shroud rewrites the
exact table the shroud view is built from.

This is latent today (no client sends `0x140C`), and becomes live the moment a Hero panel ships.

---

## 3. Decisions proposed for sign-off

| # | Decision | Why |
|---|---|---|
| D1 | Nothing in the spirit-shroud feature may depend on the tab being usable. Entry stays NPC/`0x2ec3`; progress stays `0x3823/0x541d`. | Upstream proved the protocol needs no UI file. Keeps the "no client patches" property. |
| D2 | The overlay must **keep** the stock `ACP_Progression*` controls; never delete them (NMS deleted them). | Deleting is what made the page single-purpose. Hiding is reversible, deleting is not. |
| D3 | Ship the Hero panel in its **own window** (`NMS_HeroWnd`), not on the tab. Recommended. | Zero contention; precedent: `NMS_WaypointsWnd`, `NMS_MapFilterWnd`, `NMS_LootWnd`, `EQUI_PetInfoWindow`. |
| D4 | If the maintainer wants NMS/EQL parity instead, the tab becomes a **mode-routed host**: Hero paints only while `Shrouded == 0` and no shroud menu is open; otherwise the stock page renders. | One tab, two duties, one painter at a time. |
| D5 | Fail closed on class mutation while `IsShrouded()` — server-side in `AddExtraClass`/`RemoveExtraClass`, client-side by disabling the buttons. | §2.1. Ships regardless of D3/D4. |
| D6 | `OP_HeroRequest` = `0x140C` (NMS reservation; `0x140A/0x140B` taken). No server→client Hero opcode; the redraw is `SendBulkStatsUpdate()`. | Matches NMS wire contract; avoids a second custom opcode. |
| D7 | Keep AA scan patch #1 (bound `0xC34F` → 100000) as a permanent content contract, independent of shrouds. | 326 rows above 49,999; it is not shroud code even though it lives in `ApplyShroudFlowFix`. |
| D8 | The Hero panel and the shroud selection window may not both be open: opening one closes the other (client-side). | Both bind the character's class/race/AA surfaces; two live editors is a bug factory. |

---

## 4. Options

### A. Tab stays stock; Hero is its own window — **recommended**

Cost: one new XML window + a `CCustomWnd`/detour init in `dinput8.dll`; four skins to touch
(`default/`, `gearcore/`, `shinsparxx/`, `Blue/` — plus `Bigzz_NMS_UI`/`sneaky_defiance_ui` if
they are meant to carry it). Benefit: no page contention ever, shroud progress keeps its stock home,
and Hero survives any future shroud UI work. Risk: lowest.

### B. NMS parity — tab is Hero

Cost: overlay replaces the stock page (must keep the ACP controls hidden, per D2), a paint gate keyed
to `Shrouded` and window state, and the shroud feature loses its only passive progress surface.
Benefit: matches NMS users' muscle memory; one tab as NMS shipped it. Risk: medium — a dll must win a
repaint race every frame, and `Shrouded` is only true *after* a transform, not during keeper browsing.

### C. EQL parity — one tab, two duties, client-native

What Daybreak does: live's Shrouds tab was replaced by the Persona tab when personas shipped
(CONFIRMED for live via the EQ forums; **EQL internals not verifiable here** — CANNOT-DETERMINE-STATICALLY).
Reproducing it in a dll means suppressing or co-opting the client's own ACP painter, which is a
bigger reverse-engineering job than everything in §1. Do not start here; revisit only if E1 shows the
stock painter is trivially redirectable.

---

## 5. Contracts

### 5.1 ScreenID contract (whatever wins)

| Owner | Control set |
|---|---|
| stock shroud progression | `AltCharProgPage`, `ACP_ProgressionList`, `ACP_ProgressionInfo`, `ACP_ProgressionLayout` |
| Hero (NMS) | `Hero_ClassList`, `Hero_Info`, `Hero_AddButton`, `Hero_RemoveButton` (shipped NMS names) |

Under A they live in different windows and never meet. Under B both live on `IW_AltCharProgPage`
and visibility is a runtime decision — which is precisely why D2 forbids deletion.

### 5.2 Opcode ownership

| Opcode | Value | Owner |
|---|---|---|
| `OP_Shroud` / `OP_SpiritShroudTransform` | `0x6562` | shroud (one value, two implementations — keep) |
| `OP_SpiritShroudSelection` | `0x2ec3` | shroud window |
| `OP_SpiritShroudProgressAppend`/`Replace` | `0x3823`/`0x541d` | shroud progress |
| `OP_HeroRequest` | `0x140C` | Hero |

Evidence for the identity: `utils/patches/patch_RoF2.conf:777-855` — the legacy names and the
upstream names are the same values, and line 854 spells it out (`Transform=Shroud (0x6562)`). One
opcode, two handlers, selected by `Custom:EnableSpiritShrouds`.

### 5.3 State gates

- `IsShrouded()` true → Hero panel hidden (B) or window refused (A); `0x140C` rejected server-side.
- Shroud menu open (`Keeper()`, 120 s window) → same.
- In combat → existing multiclass gates already refuse (NMS `CanAddExtraClass`); unchanged.

---

## 6. Phases

| Tier | Work | Gate |
|---|---|---|
| T1 | Server guard: `AddExtraClass`/`RemoveExtraClass` return false when `IsShrouded()`; log at debug. Unit-checkable with the legacy path (apply a shroud `#`/quest, then `#hero add`). | Legacy shroud applied → add/remove refused; unshrouded → unchanged behaviour. |
| T2 | Hero UI placement per A or B + `OP_HeroRequest` + `EVENT_HERO_REQUEST` policy (or drop the event and keep C++ gates). | Add/remove from the panel; AA table, spells, disciplines intact. |
| T3 | Progress surface: run **E1** (§7), then either keep stock or add a Hero-owned progress line. | Decided by measurement, not by guess. |
| T4 | Catalog import (owned by `spirit-shroud-client-dependency.md` Tier 3) — without it no shroud UI is visible either way. | `spirit_shroud_templates` non-empty; one form offered end-to-end. |

T1 is independent and can land alone.

---

## 7. Open questions / experiments

- **E1 (decisive).** With `EnableSpiritShrouds` on, one offered template, and one shroud AA granted:
  does the stock tab populate (`ACP_ProgressionList` shows rows) when unshrouded, when shrouded, or
  never? This decides whether Option B's "yield to stock" paints anything at all, and whether the tab
  is a progress *viewer* or a dead page in RoF2 emu.
- **E2.** Does `OP_SpiritShroudProgressReplace` (`0x541d`) target the tab or the selection window?
  Upstream binds it to shroud progress generally; the client-side target is untraced
  (CONDITIONAL).
- **E3.** Can a `dinput8` detour suppress the client's ACP painter without breaking the page's child
  windows? Only matters for Option C.
- **E4.** Is "no sixth tab" (NMS §11.2) a real client constraint or a design preference? Matters only
  if someone proposes a new tab instead of a window.

## 8. Risks

| Risk | Mitigation |
|---|---|
| Two painters on one page (Option B) fighting per frame | D2 keep-don't-delete + a single visibility owner in the dll |
| Class mutation inside a shroud corrupting the snapshot | D5 guard, T1, ships first |
| Overlay drift across skins | §4A lists every skin; sync `EQUI_Inventory.xml` copies together |
| Turning the rule on for a demo, seeing an empty window, declaring the feature broken | T4 before any shroud UI demo |
| Deleting the stock page controls "because Hero replaced it" (the NMS mistake) | D2 |

## 9. Rollback

Option A: delete the window XML + its init call. Option B: restore the stock `EQUI_Inventory.xml`
(the copy in this repo is already stock) and drop the paint gate. T1's guard is two early returns and
can be reverted independently.
