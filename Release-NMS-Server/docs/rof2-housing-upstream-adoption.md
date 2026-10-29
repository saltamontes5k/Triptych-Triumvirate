# RoF2 housing: what we took from the public reconstruction

Source: <https://github.com/nightstalker6669/eqemu-rof2-housing> — an EQEmu source overlay that
implements the same May 2013 RoF2 real-estate protocol on pinned upstream commit
`8175ae61874cbf20d7b05102821f6f8a4f4d1c39`. License: GPLv3 (`LICENSE`), with a `NOTICE`
that requires existing source notices to be preserved and states that no client assets are
included.

This tree is not that overlay. What follows is a field-layout adoption for the packet bodies
our own IDA work had only partly pinned, plus the checklist of what that project's install
instructions require, mapped to where we stand.

## 1. What we adopted (2026-10-29)

| Packet | Before | Now |
| --- | --- | --- |
| `0x2698` definitions | id + 7 zero u32s + kind + 1 zero u32 + string + 6 zero u32s | full eleven-u32 record (`id, area_id, purchase_scheme, upkeep_scheme, max_items, max_non_estate_items, max_children, zone_id, dynamic_zone_id, type, group_id`), address, icon, `max_npc_items`, four floats, count-driven children, then the cost-scheme list |
| `0x6fd0` / `0x63fd` snapshot | six u32s, two strings, permission, child count, dynamic name, escrow count, then a stray kind u32 and two zeros | the documented snapshot: six u32s, owner name, owner handle, permission level, child count, dynamic name, child ids, escrow count and `key/f64` balances, upkeep component, expiry, voting byte |
| `0x626e` S2C | four hand-swept variants with integer-or-float positions at guessed offsets | the documented `ActorRecord` (model, flags, `guid`, scale/heading/pitch/roll, y/x/z, bounds, light) plus the 34-byte suffix: source kind, three source slots, three flags, three dwords, a region `KEY/RESULT` map and the required final zone pair |
| `nms_plot` | no memory of the building item | `house_item_id` (custom migration 264), because the preview's world model is the item's `idfile` |

Encoder source: `zone/nms_housing.cpp` — `WriteEstateDefinition`, `WriteEstateSnapshot`,
`WritePlacementActor`, `SendPlacementPreview`, `SendRealEstateExteriors`.

Two details worth recording:

- **The stray kind u32 was wrong.** We sent the definition kind (5) as the last field of the
  0x6fd0 body. In the documented grammar that slot is `default_upkeep_component`, so the client
  has been reading "upkeep component 5" and an expiry of 0. The `+144` neighbourhood gate never
  used that field — it comes from the definition lookup, as §9 found — so removing it costs
  nothing and stops asserting a false upkeep component.
- **`0x49df` cross-checks clean.** Their region record is `ID, 16 float transform words, 3 float
  opaque words, 2 opaque DWORDs` = 88 bytes. Ours is `id + 4x4 floats + 5 u32` = 88 bytes, in
  the same order. Two independent decodes agreeing is the strongest evidence we have that the
  area manifest is right.

## 2. Catalogue values are policy, not history

Capacities now come from their revision-1 emulator defaults
(`docs/CONFIGURING-HOUSE-CAPACITIES.md`): 300 total items, a 300-item non-estate/vault subset,
5 NPC items, one child estate for a one-room personal plot. We label these as emulator policy in
the code, because that is what they are — the historical totals are explicitly unknown in their
own documentation.

No cost scheme is published. The grammar is known and the encoder can emit it, but the 2013
tariff is not recovered; a fabricated purchase price would be a claim about Live data we do not
have. The purchase window therefore has nothing to price until we review a tariff table.

## 3. Unverified in game

Batch 7 (this change) has not been through the client yet. What to check, in order:

1. Zone into `neighborhood`. Plot Search still renders owned plots (regression check on the
   rewritten 0x6fd0 body).
2. Manage / lot-edit on an owned lot: eqstr 727 should stay away if the §13 area manifest is
   right. This is still the open gate from batch 6.
3. `#housing place <door_id> [item_id]` on a vacant lot: the item is consumed **and** the
   building draws. If it does not draw, `#housing exterior <door_id> <item_id> [model]` re-sends
   the preview and the zone log prints the model actually used.
4. Re-zone and confirm the building is still drawn (that is the `house_item_id` path).
5. The estate windows should now show owner name and expiry rather than blanks.

The model name is the open assumption: we send the item's `idfile` (`IT20020` and friends). If
the client expects a house-catalogue model string instead, step 3 fails with the packet still
well-formed, and `#housing exterior <door_id> <item_id> <model>` is the probe.

## 4. What we did **not** take

| Thing | Why not |
| --- | --- |
| `overlay/zone/*` (`client_housing.cpp` 224 KB, `housing_inventory_bridge.cpp` 147 KB, `housing_house_surface_data.h` 3.4 MB) | written against a different tree with its own schema; would collide with `nms_housing.cpp` and the `nms_*` tables |
| `patches/eqemu-housing.patch` (214 KB) | same reason; also carries their `Housing` rule category and inventory-session work |
| `tools/install_housing.py` + `installer-migrations.json` (89 migrations) | refuses conflicting custom schemas by design; cannot run against this DB |
| `tools/install_original_geometry.py` | reads *their* overlay hash catalogs; not portable without the overlay |
| `Housing::EnablePlayerHousing` and the three sibling rules | those are rules **their patch adds**. Our build has no `Housing` rule category and our housing is unconditional; adding rules nothing reads would be decoration |
| Client geometry / meshes | not in that repository by design, and must come from our own client |

## 5. Their install requirements, mapped to us

| Their requirement | Our status |
| --- | --- |
| May 10 2013 RoF2 client matching their binary hashes | We target the same build (#630) but cannot validate against their catalogs; ours is identified by our own IDA work |
| Collision maps (`maps/base`) | **Absent here.** No `maps/base` anywhere under `C:\EQS`; our housing does no collision validation, so nothing depends on it. If we ever add placement validation, this becomes a prerequisite |
| Original moving-crate item 62586 metadata | Present (`items` 62586, itemtype 11) |
| Native housing rules enabled in the active ruleset | N/A — see above |
| `patch_RoF2.conf` gains their opcode symbols | We already map the opcodes we use. Remember the deploy gotcha (§13): the runtime copy in `Build/bin/Release/` is separate |
| `RealEstateDefs.txt` in the client directory | Present in `Release-NMS-Client/ClientFiles`; capacities aligned with the wire this round |
| Item/content database and housing database identical | True here (single `peq`) |
| They do not merge custom C++ | Applies to us the other way round: nothing of theirs is merged |

## 6. Still missing locally

- `0x45be` purchase (188-byte C2S envelope; price/upkeep component ids at +172/+176, cached
  roster count at +180) and its one-byte S2C — the path that would replace `#housing place`.
- `0x711a` placement commit (96 bytes: heading/pitch/roll/scale at 44..56, y/x/z at 60..68,
  extents 72..80, centre 84..92) — the path that would replace `#housing exterior`.
- Storage: `0x613d` pack, `0x6917` store-all, `0x5b41` layout load, escrow `0x2aa6`.
- Guild trophies: the six `0x7db5/0x7dd2/0x039d/0x7c1d/0x7a41/0x02bc` opcodes.
- `0x21ec` item menu records, without which the item-action menu is inert.

Each of those is a layout we can now take from `protocol/STRUCTS.md` when we want the feature;
none of them blocks the current gate work.


## 7. Opcode names (fixed 2026-10-29)

`common/emu_oplist.h`, both `patch_RoF2.conf` copies and the `Client::Handle_OP_*` table now use
the recovered names. No wire number changed; only labels did.

| Number | Was | Now |
| --- | --- | --- |
| 0x2036 | `OP_RealEstateRequest` | `OP_RealEstatePickup` |
| 0x218c | `OP_RealEstatePlotSelect` | `OP_RealEstateGo` |
| 0x21ba | `OP_RealEstateWindowAction` | `OP_RealEstateHouseSwap` |
| 0x2691 | `OP_RealEstateSearchRequest` | `OP_RealEstateNeighborhood` |
| 0x2aa6 | `OP_RealEstateDataRequest` | `OP_RealEstateEscrow` |
| 0x3424 | `OP_RealEstateNeighborhoodRequest` | `OP_RealEstateItemOperation` |
| 0x3c8b | `OP_RealEstateNameSearch` | `OP_RealEstateTextRequest` (unnamed upstream) |
| 0x45be | `OP_RealEstateItemsRequest` | `OP_RealEstatePurchase` |
| 0x58c7 | `OP_RealEstateItemAction` | `OP_RealEstateItemInspect` |
| 0x5b41 | `OP_RealEstateLayoutSave` | `OP_RealEstateLoadLayout` |
| 0x613d | `OP_RealEstateManageAction` | `OP_RealEstatePack` |
| 0x626e | `OP_RealEstatePlacement` | `OP_RealEstatePlacementBegin` |
| 0x6573 | `OP_RealEstateToggle` | `OP_RealEstateVotingOptOut` |
| 0x6917 | `OP_RealEstateItemsAction` | `OP_RealEstateStoreAll` |
| 0x792c | `OP_RealEstatePurchaseSelect` | `OP_RealEstateSale` |
| 0x796c | `OP_RealEstatePlotSearchRequest` | `OP_RealEstateInspect` |
| 0x7ad1 | `OP_RealEstateManageRequest` | `OP_RealEstateAction5Request` (unresolved upstream) |
| 0x6fd0 | `OP_RealEstateZone` | `OP_RealEstateZoneContext` |
| 0x63fd | `OP_RealEstateObject` | `OP_RealEstateSnapshot` |
| 0x49df | `OP_RealEstateAreas` | `OP_RealEstateRegions` |

0x2698 (`OP_RealEstateDefinitions`) was already correct.

### The rename exposed a real bug

`0x626e` is `PlacementBegin`, and the recovered body puts **screen** coordinates at 52/56 (their
note: the third flag "controls screen-ray initialization"). Our handler read those two floats as
world X/Y and called `TryClaimPlot` -- so every placement attempt claimed whatever lot happened
to be nearest to a screen coordinate. That is removed:
`Handle_OP_RealEstatePlacementBegin` now decodes the estate id (32) and item id (36) and, if the
estate is a lot this character may build on, answers with the placement preview. It never claims
and never consumes; `#housing claim` stays the explicit path.

`0x711a` (`OP_RealEstatePlacementCommit`) is still unmapped. A placement begun in the client can
be previewed but not committed, so the client-side build flow stops there.

