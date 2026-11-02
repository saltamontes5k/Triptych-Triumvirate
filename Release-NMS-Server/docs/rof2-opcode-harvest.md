# RoF2 opcode harvest from the rof2-* review layers

Source: the `rof2-*` branches of `nightstalker6669/EQEmu` (GPLv3), replayed onto upstream
develop `c9c8747ac949deddb140d196d241fa4e777500c7` — which is still upstream `develop` head on
2026-10-30. Harvested 2026-10-30.

Method: parse `utils/patches/patch_RoF2.conf` from each branch head and diff the name sets
against this tree's copy. On the 715 names both trees carry there are **zero hex
disagreements**, so the numbers below come from one shared recovery effort, not two.

An opcode name alone adds no behaviour: a name with no `ConnectedOpcodes` entry is decoded and
dropped, and one with an entry runs whatever that handler does. The status section below says
which of these have a handler today.

## Status in this tree (2026-10-30)

All 62 feature names below are now in `common/emu_oplist.h` and
`utils/patches/patch_RoF2.conf`. Implemented handlers:

- `0x2b35` `OP_RealEstatePlotSearchOpen` -- sent before the plot list on a search request
  (`search_type` 4/5) and available as `#housing plotsearch [mode]`.
- `0x21ec` `OP_RealEstateItemMenu` -- the 768-byte frame is answered with Inspect (eqstr 720)
  and, for the lot's owner, Enter (eqstr 723).
- `0x58c7` `OP_RealEstateItemInspect` -- replies with the serialized item, gated on the item
  being the building the lot actually holds.
- `0x796c` `OP_RealEstateInspect` -- the 4-byte estate request is answered with the inspection
  record (type, five ids, four strings, show byte) using the same door/zone ids the snapshot
  registered.
- `0x2aa7` `OP_RealEstateOwnedList` -- sent after the identity and the placed scenes: a full
  replacement list (count + estate ids) of the plots the character or their guild owns.

Every other name is registered against `Client::Handle_OP_Unimplemented`, which logs the
opcode name and size and grants no behaviour. The five upstream renames (`0x659c`, `0x4f4b`,
`0x3377`, `0x5882`, `0x36e8`) are deliberately not added: this tree already maps those
numbers under its older names, so a second name for the same number would collide.

## Counts per branch head (measured before the mapping pass)

| Branch head | Names there | Names here | Missing here | Feature work | Upstream drift |
| --- | --- | --- | --- | --- | --- |
| `rof2-housing` | 701 | 662 | 39 | 33 | 6 |
| `rof2-fellowship` | 707 | 668 | 39 | 33 | 6 |
| `rof2-mercenaries` | 720 | 668 | 52 | 46 | 6 |
| `rof2-spirit-shrouds` | 736 | 668 | 68 | 62 | 6 |

The branches stack, so these are cumulative: housing adds 33, mercenaries adds 13, spirit
shrouds adds 16. Fellowship adds no opcode of its own.

The six "upstream drift" names are not part of this feature work — they are newer upstream
develop opcodes this tree has not taken: `OP_BuffDefinition` 0x659c, `OP_RefreshTargetBuffs`
0x4f4b, `OP_RefreshBuffs` 0x3377, `OP_RefreshPetBuffs` 0x5882, `OP_MercenarySwitch` 0x1b37,
`OP_AvailableTask` 0x36e8.

## Where this tree stands on housing

Mapped and handled in `zone/nms_housing.cpp` (6): `0x45be` purchase, `0x711a` placement
commit, `0x050c` item query, `0x2691` neighborhood, `0x218c` Go, `0x626e` placement begin.

Mapped, then dropped with a log line, by the `NMS_HOUSING_LOG_ONLY` block at
`zone/nms_housing.cpp:606` (13): `0x2036` pickup, `0x3424` item operation, `0x21ba` house swap,
`0x2aa6` escrow, `0x3c8b` text request, `0x58c7` item inspect, `0x5b41` load layout,
`0x613d` pack, `0x6573` voting opt-out, `0x6917` store-all, `0x792c` sale, `0x796c` inspect,
`0x7ad1` action-5 request.

Unmapped entirely (33): the 27 real-estate names and 6 guild-trophy names below.

## Housing: 27 real-estate + 6 guild-trophy names to map

| Opcode | Name (fork) | Shape recovered in the fork's `common/housing/*_wire.h` |
| --- | --- | --- |
| 0x2b35 | `OP_RealEstatePlotSearchOpen` | S2C, one byte; opens the plot-search window |
| 0x2aa7 | `OP_RealEstateOwnedList` | owned-estate list; `estate_wire.h` |
| 0x485d | `OP_RealEstateAccess` | ACL read; `access_policy.h` |
| 0x3146 | `OP_RealEstateAccessEdit` | ACL write; `access_policy.h` |
| 0x507f | `OP_RealEstateTransfer` | ownership transfer; `transfer_consent_wire.h` |
| 0x087f | `OP_RealEstateItemDelta` | single-item estate delta; `item_list_wire.h` (`Packets.deltas`) |
| 0x2a9e | `OP_RealEstateWorldRemove` | remove a world actor |
| 0x2523 | `OP_RealEstatePlacementSource` | placement source selection |
| 0x6213 | `OP_RealEstatePlacementEnd` | leave placement mode |
| 0x1228 | `OP_RealEstateOperationResult` | generic operation result |
| 0x21ec | `OP_RealEstateItemMenu` | 768-byte query (`MenuSize`): `{profile, source, mouse[2], opaque}`; source = 18-byte guid + 2 pad + 3 `u32` location |
| 0x51e3 | `OP_RealEstateCustomInteraction` | custom-interaction menu; `interaction_wire.h` |
| 0x1da9 | `OP_RealEstateExit` | 4-byte body; the client leaves stale buffer bytes, they select nothing |
| 0x51a9 / 0x756a / 0x4b65 | trophy open / toggle / record | `trophy_anchor_wire.h`, `guild_trophy_wire.h` |
| 0x7697 / 0x51ae / 0x08bf | trophy list / timer / clear | as above |
| 0x7bb1 | `OP_RealEstateAnchorConfirm` | placement anchor confirmation |
| 0x1967 | `OP_RealEstateOwnerItemPurge` | owner purge of estate items |
| 0x3e00 / 0x66df | owned item list / archived list | `item_list_wire.h` |
| 0x66bf / 0x68ba / 0x5a63 | sale result / transfer result / transfer consent | `u32` emulator response profile, per the fork's conf comment |
| 0x21ea | `OP_RealEstateBindSpawn` | spawn-to-item binding, "canonical 32 consumed-byte profile" |
| 0x7db5 / 0x7dd2 / 0x039d / 0x7c1d / 0x7a41 / 0x02bc | guild trophy available / active / toggle / save / modify / opt-in | see below |

Guild-trophy bodies, measured in `guild_trophy_wire.h`: Toggle = 12 bytes, Modify = 80,
Save = 68 (four `u32` ids from +20 plus four `i32` tiers), Member/OptIn = 80 (one enabled byte,
NUL-terminated name up to 64 bytes from +8), Available = `{guild, count, ids...}`,
Active = `{guild, favor, remaining_ms, enabled, 4 ids, 4 tiers}`. Every decoder rejects a wrong
size instead of parsing best-effort.

## Layouts worth keeping even without the feature

- `layout_wire.h` — load-layout `0x5b41`: `Load{yard_estate_id, house_estate_id, operations[]}`
  with `UINT32_MAX` sentinels on the wire, converted to 0 only for the server's attached-house
  context. `DecodeLoad` is the reader.
- `escrow_wire.h` — `0x2aa6`: `Message` carrying `Value{type, subtype, i64 amount}` plus
  `EncodeCursorAssignment(action, estate_id, denomination, quantity)`, where quantity is the
  **resulting** cursor state, not a delta.
- `placement_wire.h` — begin 60 bytes, commit 96 bytes with scale `transform[3] > 0` validated;
  the world actor record is scale-first and is not the commit tuple.
- `item_wire.h` — item metadata tail (`EmptyTailSize` = 72) carrying `placeable,
  ignore_collisions, placement_type, definition_id, scale_min/max, upkeep_id, max_per_estate,
  housepet_filename (<=31), interactive, trophy_benefit_id, disable_rotation,
  disable_free_placement, socket subclasses`. `IsNpcItem` = housepet filename present and not
  interactive.
- `item_list_wire.h` — full list plus per-item deltas; the comment warns against truncating to
  a prototype's 32 items.

## Mercenaries: 13 names to map

`OP_MercenaryAutoAssist` 0x0b72, `Assist` 0x7e6f, `TransferRequest` 0x5df8,
`TransferResponse` 0x4333, `Unshroud` 0x69ca, `UnshroudResponse` 0x6e9f, `Dead` 0x038f,
`Restricted` 0x0e52, `RestoreReady` 0x2749, `Upkeep` 0x5f88, `CostUpdate` 0x3cbc,
`CurrencyMessage` 0x29ec, `TimerUpdate` 0x2b4f.

Machine-readable layouts live in the fork at `common/mercenary/rof2_opcodes.json` (15,272 B),
`common/mercenary/wire-layouts.json` (16,429 B) and `PROTOCOL.md`. Its README states the layer
is not standalone: payment paths reuse the housing inventory-session lease.

## Spirit shrouds: 16 names, plus better labels for two of ours

Same numbers wherever both trees name the opcode, so this is labelling only:

| Hex | This tree | Fork |
| --- | --- | --- |
| 0x2ec3 | `OP_ShroudSelectionWindow` | `OP_SpiritShroudSelection` |
| 0x2b37 | `OP_ShroudRequestStats` | `OP_SpiritShroudRequest` |
| 0x6c04 | `OP_ShroudRespondStats` | `OP_SpiritShroudDetails` |
| 0x1cd0 | `OP_ShroudSelect` | `OP_SpiritShroudSelect` |
| 0x79da | `OP_ShroudSelectCancel` | `OP_SpiritShroudCancel` |
| 0x541d | `OP_ShroudProgress` | `OP_SpiritShroudProgressReplace` |
| 0x3823 | `OP_ShroudProgress2` | `OP_SpiritShroudProgressAppend` |
| 0x6562 | `OP_Shroud` | `OP_SpiritShroudTransform` |
| 0x2507 | `OP_ShroudPointsUpdate` (commented "unnamed manager opcode") | `OP_SpiritShroudEquipment` |
| 0x006e | `OP_ShroudStateUpdate` (commented "unnamed manager opcode") | `OP_SpiritShroudAbilityReady` |
| 0x67e8 | `OP_ShroudRemove` | not named there |

Names this tree lacks: `AbilityRequest` 0x3acc, `EquipmentRequest` 0x4b25, `Complete` 0x7786,
`Bank` 0x7b71, `BankItems` 0x1115, `BankEmpty` 0x0728.

### The shroud bank trio

From the fork's `zone/client_spirit_shroud_native.cpp`. The handler revalidates a keeper NPC on
every action and refuses the whole opcode while the player is shroudED, so this is a pre-shroud
storage window, not a container for temporary-form items:

- `0x7b71` `Bank`: `u32 action` + arguments. `action 0` with an 8-byte body
  (`action, keeper_id`) requests the window; the reply is `{u32 0, u32 keeper_id}` and arms a
  120-second menu. `action 5` with a 24-byte body withdraws, key `u64` at +8..+16 (`slot + 1`,
  rejected above 9000). Refusal is `{u32 2, u32 0, u64 max}`.
- `0x1115` `BankItems`: `{u32 0, u32 count}`, then per row `{name, icon u32, key u64,
  stack u32}` — stack size for stackables, 1 otherwise.
- `0x0728` `BankEmpty`: empty-bank notice.

## How the mapping is wired

1. The name goes in `common/emu_oplist.h` (appended, so existing enum values do not move) and
   the number in `utils/patches/patch_RoF2.conf`.
2. `zone/client_packet.cpp` holds the single `k_log_only_rof2` table of named-but-unimplemented
   opcodes; `MapOpcodes` registers each against `Client::Handle_OP_Unimplemented`, and only
   where no real handler claimed the opcode, so a log-only entry cannot shadow an
   implementation.
3. Renaming an existing opcode is still not free: check every `ConnectedOpcodes` entry, every
   `OP_` use and any quest API exposure before swapping a label.
