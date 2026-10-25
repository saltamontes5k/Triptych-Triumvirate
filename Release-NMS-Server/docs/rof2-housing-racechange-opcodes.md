# RoF2 housing / real-estate and /racechange opcodes

Reverse-engineered from `eqgame.exe` build #630 (the RoF2 client in this tree) with IDA.
This document is the reference cited by `common/emu_oplist.h` and
`utils/patches/patch_RoF2.conf`; keep it in sync when those change.

Confidence tags: **CONFIRMED** = read directly from the client binary; **INFERRED** = deduced
from a single call site and not yet exercised against a live client; **OPEN** = unknown.

## 1. Dispatch model

* `sub_7D03C0(opcode, 0)` is a pass-through that returns its first argument, so the constant at a
  send site **is** the wire opcode. It is the only packet-send constructor; `sub_7D0660(id, 0)` is
  a *UI message* lookup and its constants share the same numeric namespace. Do not classify a
  constant by `push imm` alone — check the call target. (**CONFIRMED**)
* EQ opcodes are direction-agnostic: one number carries both the client→server request and the
  server→client response. (**CONFIRMED** — `0x2691` is both a send constant and a case in the
  client's server→client dispatcher `sub_4C3250`.)
* `OP_RealEstateNeighborhoodRequest` (0x3424) is **send-only**: no `cmp` against 0x3424 exists
  anywhere in the client, so its response cannot come back on 0x3424. It arrives on 0x2691/0x2698.
  (**CONFIRMED**)
* A client→server packet is `{u16 opcode; payload}` assembled into a global buffer and sent with
  `sub_8C51F0(4, &buf, payload_len + 2)`. (**CONFIRMED**)

### Wire primitives

* **Length-prefixed string** — `sub_80C9B0`: u32 byte length, then that many bytes; length <= 0 is
  the null string. (**CONFIRMED**)
* **16-byte identifier** — `sub_80C920`: copies exactly 16 characters, and only if
  `strlen(src) == 16` and a encode/decode round-trip of the value matches. Some real-estate
  payloads carry one of these instead of a general string. (**CONFIRMED**)

## 2. Opcode values

Recovered by walking every call to `sub_7D03C0` and reading the constant argument. All values are
already present in `utils/patches/patch_RoF2.conf` and `common/emu_oplist.h`.

| Emu name | Value | Client senders (VA) |
|---|---|---|
| OP_RealEstateRequest | 0x2036 | sub_73CC50 |
| OP_RealEstatePlotSelect | 0x218C | sub_5384D0, sub_73CC50, sub_74A3A0 |
| OP_RealEstateWindowAction | 0x21BA | sub_735480 |
| OP_RealEstateSearchRequest | 0x2691 | sub_74A3A0, sub_74B920, sub_74BE00 |
| OP_RealEstateDataRequest | 0x2AA6 | sub_741EE0, sub_745090, sub_74D500 |
| OP_RealEstateNeighborhoodRequest | 0x3424 | sub_73CC50 |
| OP_RealEstateNameSearch | 0x3C8B | sub_73CC50 |
| OP_RealEstateItemsRequest | 0x45BE | sub_74D500 |
| OP_RealEstateItemAction | 0x58C7 | sub_73CC50 |
| OP_RealEstateLayoutSave | 0x5B41 | sub_73BEC0 |
| OP_RealEstateManageAction | 0x613D | sub_735480 |
| OP_RealEstatePlacement | 0x626E | sub_5384D0, sub_73CC50 |
| OP_RealEstateToggle | 0x6573 | sub_74D500 |
| OP_RealEstateItemsAction | 0x6917 | sub_735480 |
| OP_RealEstatePurchaseSelect | 0x792C | sub_74C8D0 |
| OP_RealEstatePlotSearchRequest | 0x796C | sub_74C110 |
| OP_RealEstateManageRequest | 0x7AD1 | sub_73CC50 |
| OP_RaceChangeRequest | 0x754E | sub_7276F0 |

The whole real-estate code cluster lives at VA 0x730000..0x750000.

## 3. Client→server payloads

### OP_RealEstateSearchRequest = 0x2691 — 224-byte payload
From `sub_74B920` (type 4) and `sub_74BE00` (type 5). (**CONFIRMED**)

| Offset | Type | Meaning |
|---|---|---|
| 0 | u32 | search type (4 = address search in a neighborhood, 5 = variant) |
| 4 | u32 | neighborhood id (real-estate object +140) |
| 8 | u32 | zero |
| 12 | char[80] | neighborhood name criteria |
| 92 | char[64] | player name criteria |
| 156 | char[64] | guild name criteria |
| 220 | u8 | caller flag |
| 221 | u8 | always 1 |
| 222 | u16 | zero |

### OP_RealEstateNeighborhoodRequest = 0x3424 — 48-byte payload
Built by `sub_73F6C0`, which fills 18 bytes then seven dwords. (**CONFIRMED** layout, **INFERRED**
meaning)

| Offset | Type |
|---|---|
| 0 | char[16] real-estate identifier |
| 16 | u16 |
| 20,24,28 | u32 x3 (from a 3-dword source) |
| 32,36 | u32 x2 |
| 40,44 | u32 x2 |

### OP_RealEstatePlotSelect = 0x218C — 12-byte payload
From `sub_5384D0`: `[0] = world x`, `[4] = world y`, `[8] = 0`. Sent when a lot is clicked.
(**CONFIRMED**)

### OP_RealEstatePlacement = 0x626E — 60-byte payload
From `sub_5384D0`. Built by `sub_5424D0`, then a 16-byte identifier is written with
`sub_80C920`, then: (**CONFIRMED** on the listed fields, **OPEN** on offsets 0..19)

| Offset | Value |
|---|---|
| 20 | 0 |
| 24 | 0xFFFF00E1 |
| 28 | 0x0000FFFF |
| 44 | 1 |
| 48 (byte) | 1 |
| 52 | world x |
| 56 | world y |

### OP_RealEstatePurchaseSelect = 0x792C — 188-byte payload
From `sub_74C8D0`. Zeroed, then `[0] = *(this + 8)`; the remaining 184 bytes are zero.

## 4. Server→client handling map

Client dispatcher `sub_4C3250`; real-estate cases land in `RealEstate::HandlePacket`
(`sub_5B2500`), which switches again:

| Opcode | Handler | Purpose |
|---|---|---|
| 0x2691, 0x2698 | sub_5B0F80 | search / neighborhood result (main list path) |
| 0x2AA6 | sub_741670 | real-estate items data |
| 0x58C7 | sub_5559A0, sub_6AE610 | item action result |
| 0x626E | case 25198 @ 0x4D058A | placement result |

### 0x2691 response shape (from `sub_5B0F80`) — **INFERRED**

```
u32   unknown (consumed and discarded)
u8    kind
if sub_7F6030(kind):        # neighborhood detail
      ... neighborhood object fields, four length-prefixed strings, then sub_7FE1E0(...)
else:
      u32 search_type
      if search_type in (4, 5): sub_74C4C0(reader, search_type)   # plot list
      elif search_type != 3:    sub_74AB50(reader, search_type)   # neighborhood list
```

`sub_74AB50` (neighborhood list), search_type 0/1 branch:

```
u16   count
u8    flag
u32   <one value>
count * {
    u32    neighborhood_id
    string neighborhood_name        # u32 length + bytes
    u32    guild_id                  # 0xFFFFFFFF = not guild-owned
    u32    max_player_plots
    u32    owned_player_plots
    u32    max_guild_plots
    u32    owned_guild_plots
}
```

That entry is the guild-to-area assignment: the guild id is what the neighborhood window shows in
its Guild column, and a guild-owned neighborhood restricts plot purchase to that guild.

`sub_74AB50` search_type 2 (a specific neighborhood) additionally reads a second u16 count and a
list of u32 guild ids formatted through `sub_425670`.

`sub_74C4C0` (plot list), search_type 4/5:

```
u16   count
count * {
    u32    plot_id
    u32    owner_type       # 4 = Player, 8 = Guild
    u32    <one value>
    string <one string>
    string <one string>
}
```

## 5. Client UI surface

`uifiles/default/EQUI_RealEstate*.xml` define six windows: RealEstateNeighborhoodWnd,
RealEstatePurchaseWnd, RealEstateManageWnd, RealEstateItemsWnd, RealEstatePlotSearchWnd,
RealEstateLayoutDetailsWnd. `help/tips/ctxrealestate*.html` documents the gameplay: two plot types
(player, guild), buy by clicking the lot's stone marker, max two plots, guild-owned neighborhoods
are members-only, upkeep/escrow/transfer/move-out/90-day forfeiture. The client needs no new UI.

## 6. Server-side state in this tree

* `house` (id, char_id UNIQUE, instance_id, zone, purchased_at) and
  `house_objects` (id, house_id, item_id, x, y, z, heading) exist and are used only by the
  script-driven realtor in `quests/neighborhood/Christine.lua`.
* There is no neighborhood / plot / lot / real-estate table. The opcodes are declared but have no
  server handlers, no packet structs and no dispatch entries anywhere in `zone/`.
* `neighborhood` is zone 712 ("Sunrise Hills"). Lots are `doors` rows named `OBP_LOTSQUARE`
  with `opentype 160`: 76 lots, doorid 1..157, each stored twice (version 0 and version 100).
  The door row carries the lot's world x/y/z.
* Guild hall interiors are incomplete: only zone 345 `guildhall` exists; `guildhallsml`,
  `guildhalllrg` and `guildhall3` do not exist here.
* Placeable guild-hall items exist: Standard Guild Hall (66618), Grand (66619), Palatial (66620),
  Modest (66660), plus "Complete ... Package" bundles. `dbstr_us.txt` 52656 describes the
  neighborhood charter item that binds a neighborhood to a guild; no such item exists in this DB.
* There is no market or bazaar placeable; housing has player and guild plots only.

## 6. Server implementation (zone/nms_housing.cpp)

`zone/nms_housing.cpp` is the server half. It registers five housing opcodes in
`Client::ConnectedOpcodes` and answers:

| Incoming | Response |
|---|---|
| 0x3424 NeighborhoodRequest, 0x2036 RealEstateRequest | neighborhood list on 0x2691 |
| 0x2691 with search type 4/5 | plot list on 0x2691 |
| 0x2691 with any other search type | neighborhood list on 0x2691 |
| 0x218C PlotSelect | logged only |
| 0x626E Placement | claims the nearest vacant lot, then sends the plot list |

Backing tables: `nms_neighborhood` and `nms_plot` (see
`utils/sql/20261019_housing_schema.sql`, compiled migration 161). 76 plots are seeded from
the `OBP_LOTSQUARE` lot markers.

Two details in the client reader drive the response bytes:

* the neighborhood list carries a flag byte that the client only redraws the window when
  non-zero (`sub_74AB50`, `if ((_BYTE)v40) ... UpdateWindow`), so it is sent as 1;
* the plot list has no flag byte — `sub_74C4C0` steps straight from the u16 count into the
  entries, and it only creates a row when the owner type is 4 (Player) or 8 (Guild), so vacant
  lots cannot appear in that list.

Verified so far: the emitted neighborhood packet (57 bytes for one neighborhood) round-trips
through a port of `sub_5B0F80` + `sub_74AB50` consuming exactly the buffer and recovering the
`nms_neighborhood` values; the nearest-lot query resolves a lot's own coordinates to that lot;
and the claim UPDATE sets owner + timestamps and refuses an already-owned lot. **Not yet
verified:** that a live client accepts the response — that needs an in-game click, and the
placement semantics are provisional until the capture confirms them.

## 7. The neighborhood gate (why every real-estate action said "You must be in a neighborhood")

This was the blocker that kept the whole UI inert, and it is worth stating plainly.

* `sub_74BB00` gates the real-estate actions on `sub_7F5F70(RealEstate[+144])`. That predicate
  returns true **only for the value 5**; anything else prints eqstr **8078**, "You must be in a
  neighborhood to use that." (**CONFIRMED**)
* `+144` is written in exactly one place: the `RealEstate::HandlePacket` (0x5B2500) case for
  wire opcode **0x6FD0**, from `sub_7F4FA0(object +32)` after a lookup in the client's real-estate
  definition table; the same case writes `+140` (neighborhood id) from `object +20`.
  (**CONFIRMED**)
* The definition table is built in client code by `sub_7DC430(zone_type, zone_id, short_name,
  long_name, ...)`; zone **712 'neighborhood' / "Sunrise Hills"** is registered at 0x7E32F7.
  (**CONFIRMED**)
* The `0x6FD0` payload is parsed by the RealEstate vtable slot 3 (`sub_7FDF00`):
  `u32, u32, u32, u32, u32, u32, string, string, u32, u32 count, string, ...` mapping to object
  offsets +20..+40, +48, +44, +52, then a count and +56. (**CONFIRMED** order)
* Upstream EQEmu has no name or mapping for 0x6FD0. It is now `OP_RealEstateZone=0x6fd0` in
  `utils/patches/patch_RoF2.conf` and `common/emu_oplist.h`.

The full `0x6FD0` payload order, from the rest of `sub_7FDF00`:

```
u32  -> object +20   (becomes RealEstate[+140], the neighborhood id)
u32  -> +24
u32  -> +28
u32  -> +32          (real-estate object id)
u32  -> +36
u32  -> +40
str  -> +48
str  -> +44
u32  -> +52
u32     child id list count, then count * u32
str  -> +56
u8      key/value pair count, then count * (u32 key, f64 value)
u32  -> +60          <-- the kind; sub_7F5F70() accepts only 5
u32  -> +64
u8   -> +68
```

An earlier attempt omitted everything after the `+56` string, so `+60` stayed 0 and the gate kept
firing even though the packet was delivered (verified in the zone log: 69 bytes, four times).
`Client::SendRealEstateIdentity()` now sends the whole 79-byte payload with `+60 = 5`.

Verified by round-trip: the 79-byte payload parsed through a port of `sub_7FDF00` consumes exactly
79/79 bytes and yields object id 712, kind 5.

Why the identity packet and not the neighborhood-detail path: the detail path builds its object with
`sub_7FE1E0(v14, 0, v42, v41, v18, v20, &v36, &v35, 0, &v37, 0, 0, 0)`, and that constructor writes
`*(this+15) = a12`, which is **0** there. `sub_7F4FA0` returns that same `+15` slot, so the detail
path can only ever produce 0 for `+144` — the gate can only be satisfied by 0x6FD0 carrying 5 at
`+60`. (**CONFIRMED** statically)

`RealEstate[+144]` is `sub_7F4FA0(manager.map, object +32)`, where the map lives at manager+116
(see `sub_5B3430`, which calls it explicitly as `sub_7F4FA0(*(this+116), v7[8])`). **Still inferred:**
that parsing 0x6FD0 inserts the object into that map, so the lookup finds it and returns its +60.

## 8. The actual root cause: the client is missing RealEstateDefs.txt

The gate above is real, but it is not the first thing that fails. `sub_7F5F70` tests the value
returned by `sub_7F4FA0(manager.map@+116, object +32)`, and that map is **loaded from a local data
file**:

* `sub_7F5380` opens **`RealEstateDefs.txt`** (`sub_486FA0(..., "RealEstateDefs.txt")`), also reads
  **`RealEstateDefRel.txt`**, and parses lines split on `'^'` (0x5E).
* `sub_7FCFE0` / `sub_7F5CE0` build the map from that file in the manager constructor.
* `sub_7F4FA0` returns entry[15] or **10**; the manager constructor initialises `+144 = 10`,
  matching the miss value exactly. So with no definitions file, every lookup misses and every
  real-estate action prints eqstr 8078.

**This install does not have the file.** `RealEstateDefs.txt`, `RealEstateDefRel.txt`,
`RealEstate.txt` and `RealEstateCosts.txt` are all absent from the client directory, and a
recursive search of `C:\Games`, `C:\EQS` and the user profile found no copy. The names are
referenced by the client at 0xA100B8, 0xA100CC, 0xA1042C and 0xA10418; they ship with a Live
install and are not part of an EQEmu server.

CORRECTED 2026-10-25 (findings doc §9): the file and the wire feed the SAME map — `case 0x2698`
merges into `a1[29]`, the map this section describes. A packet CAN satisfy the gate: the wire
definition just has to carry the kind as the **raw integer 5** (`sub_7F4C90` stores every field
verbatim; the server was sending the IEEE bits of 5.0f, which is what actually broke every
test). Insert prepends to the bucket chain, so a wire entry shadows a same-id file entry.

### RealEstateDefs.txt format (from sub_7F5380)

One definition per record, **23 `^`-separated tokens** (the file is split on `'^'`, 0x5E):

| # | Type | Field |
|---|---|---|
| 1 | int | definition id — this is what the 0x6FD0 object `+32` must carry |
| 2 | str(600) | name |
| 3 | str(1500) | description |
| 4-6 | float | unknown |
| 7-9 | int | unknown |
| 10 | int | max items (validated >= 17 and >= 19) |
| 11-13 | int | unknown |
| **14** | **int** | **kind — 10 = unknown (the code default), 5 = neighborhood** |
| 15 | int | unknown |
| 16 | str(600) | unknown |
| 17 | int | max non-real-estate items |
| 18 | int | default 336 |
| 19 | int | max pet items |
| 20-23 | float | unknown |

Token 14 lands at struct index **15**, which is exactly the slot `sub_7F4FA0` returns and
`sub_7F5F70` tests — and its code default is 10, the same value `sub_7F4FA0` returns on a miss.
That correspondence is what identifies it as the kind.

`RealEstateDefRel.txt` records are `<definition id>^<related id>`; the parser looks the first up in
the definition map (node key at +27) and appends the second to that definition's list at +23.

The insert is confirmed: `sub_7F52F0(map, struct, &id)` allocates a 0x74-byte node, copies the
parsed struct into it with `sub_7F5230`, then stores the key at **node+108** (dword 27) and links
it. `sub_7F4FA0` compares that same +108 and returns **node+60** (dword 15). So struct index 15 —
token 14 of the record — is unambiguously the value the neighborhood gate tests.

### File and tokenizer mechanics (verified)

* `sub_808860` is a plain `fgets` line reader: it clears the record buffer, reads one line,
  resets the token cursor to the start of the buffer and returns the line length (-1 at EOF).
* `sub_808930` is only "is the file handle non-null".
* `sub_808940` (the token reader behind `sub_808C50`/`sub_808C90`/`sub_808C20`) stops at a
  newline, a CR, **or the delimiter**, and advances past the delimiter only when that is what
  stopped it. So records are **lines** and fields are `^`-separated within a line.
* `sub_808C50` = `atoi` of the token, `sub_808C90` = `atof`, `sub_808C20` = raw string.

The parser reads one line **before** entering its loop, so **line 1 is always discarded** — the
file must start with a header line. A data-only file parses as zero records, which is exactly how
the first version of the authored file was wrong.

Note the manager is a lazily-constructed singleton (`sub_5B3540`), so the data file is read once
per **client process**. Editing the file while the game is running has no effect; the client must be
restarted, not just re-zoned.

Authored stand-ins exist in the client directory (`RealEstateDefs.txt` with id 712 / kind 5;
refreshed 2026-10-25 with sane item caps — MaxItems 300 / MaxNonRE 60 / MaxPets 10 — and the
dangling `1^1` DefRel row removed; also copied to `Release-NMS-Client/ClientFiles`). **Gate
verify in game owed** — see findings doc §9. The client reports
parse problems to `RealEstateErrors.txt` in its own directory, and logs
`Could not open file: %s` when a data file is absent — that file is the feedback channel.

## 8b. The neighborhood gate looked unsatisfiable in this client build — FALSIFIED, see below

`+144` — the value `sub_7F5F70` tests and the single thing gating every real-estate action — is
written in only three places, found by scanning every `mov [reg+0x90], imm` and
`mov [reg+0x90], reg` in .text:

| Site | Writes |
|---|---|
| `sub_5B21E0` (manager ctor) plus two resets near 0x5AFF2A / 0x5B1D13 | the constant **10** |
| `0x5B30C3`, inside `case 0x6FD0` of `RealEstate::HandlePacket` | `sub_7F4FA0(map@+116, object+32)` |

Nothing stores **5**, so the only route to a passing gate is that lookup — and that branch looks
unreachable: `RealEstate::HandlePacket` has exactly two callers, the zone dispatcher (which reaches
it only for 0x2691/0x2698) and the world-authenticate handler `sub_5629C0` (which passes **0x2698**
for case 9880). Nothing passes 0x6FD0, and the function appears in no static table.

Caveat: a handler table built at runtime would be invisible to a static xref scan, so this is
"no static path found", not "proven impossible".

Observed behaviour matches exactly: `#housing send list` **does** open the window (that only needs
the packet), the client then sends 0x2691 searches that we answer, but every control is inert
because each action re-tests `+144`. Practical consequence: on this build the native UI can show
server data but cannot act on it, so placement runs server-side via `#housing place`.

FALSIFIED 2026-10-25: the 0x6FD0 case runs. `sub_5B2500` switches on the raw opcode and contains
`case 0x6FD0` (writes `+140` from `object+20`, `+144` from the `a1[29]` lookup); the
server→client dispatcher `sub_4C3250` calls `sub_5B2500` at 0x4cc1ea with the opcode passed
through, and runtime confirmed it — the client echoes the `+140` value we send back in its 0x2691
search requests. The static scan missed that the dispatcher forwards a whole opcode class into
the same switch. The gate was failing on the kind VALUE, not on reachability (findings doc §9).

## 8c. The 0x626E server->client packet (how a placed building becomes visible)

A placed house has no exterior until the server sends this. The client dispatcher's
`case 25198` at `0x4D058A` parses it with two helpers:

`sub_505400` (the big object, constructed by `sub_504460`):

```
string  (null-terminated, max 63)    -> +60
u8                                   -> +44
u32                                  -> +188
u32                                  -> +12
string16(null-terminated, max 16)    -> passed to sub_80C920 (the 16-byte id)
u32                                  -> +36
u32                                  -> +40
u32                                  -> +124
u32                                  -> +128
u32                                  -> +132
u32                                  -> +136
u32                                  -> +140
u32                                  -> +144
u32                                  -> +148
u8                                   -> +152
u8                                   -> +153
u8                                   -> +154
u32                                  -> +156
u32                                  -> +160
u32                                  -> +164
u32                                  -> +168
u32                                  -> +172
u32                                  -> +176
u32                                  -> +180
u32                                  -> +184
```

`sub_505A50` turned out to be small: it reads one null-terminated string of at most 16
characters and hands it to `sub_80C920`, the fixed 16-byte identifier copier. So the whole
parser above is now decoded — roughly 98 bytes before the second helper starts.

`sub_4D60E0` (the small object at `0x4D05AF`):

```
u8   -> +0
u16  -> +4
u16  -> +6
u16  -> +8
```

then, inline in the handler: `u8, u8, u8, u32, u32, u32, u32 count, count * (u32, u32), u32, u32`,
and finally `sub_558BB0(...)` is called with ten stack arguments. The call site at **0x4D07A3**
pushes them in this order, so the mapping is known even though the meanings are not:

| Arg | Value |
|---|---|
| a2 | manager + 0x84 |
| a3 | the big object (`sub_505400`) |
| a4 | the small object (`sub_4D60E0`) |
| a5, a6, a7 | the three bytes read inline after the small object |
| a8, a9, a10 | the three u32s read after those bytes |
| a11 | 0 |

So the small object's `u8 + 3 x u16` and those three bytes are what carry placement into the world;
they are the most likely home of the per-lot transform or model/type selector.

**Safety note:** unlike `sub_74C4C0` (the plot list), every read in `sub_505400` and `sub_505A50` is
bounds-checked against the packet length, so a short or partly-zero packet leaves fields at their
defaults instead of overrunning. That is what makes `#housing exterior` safe to experiment with —
the 20:51 crash came from `sub_80C9B0`, which reads a length and then copies that many bytes
without re-checking.

Implemented as `#housing exterior <door_id> [variant]` (variants 0-3 sweep the unknown fields).
Not yet observed to draw anything.

### Four defects found before it could ever have worked

Each of these was independently fatal, which is why early attempts produced no signal at all:

1. **Strings are null-terminated, not length-prefixed.** `sub_505400` measures them with
   `strlen`, so a `u32` length prefix is read as the first characters of the name and every
   field after it shifts.
2. **The 16-character identifier must be valid.** `sub_80C920` accepts it only when
   `strlen == 16` *and* decode/re-encode reproduces it; otherwise it is silently skipped.
   The codec is a custom base64 with the alphabet `0-9A-Za-z+-` (table at `0xB61D20`):
   `sub_80C6A0` packs 16 chars into 12 bytes, `sub_80C520` unpacks.
3. **World coordinates are integers.** `sub_5384D0` stores its `int` parameters straight into
   the client's placement request and bounds-checks them against integer world limits, so these
   dwords are integer world units, not float bit patterns.
4. **Eight tail dwords, not ten.** After the three flag bytes the parser reads `+156 … +184`
   inclusive = eight dwords. Two extra shifted the small object (the placement parameters) by
   8 bytes.

With all four corrected the packet is **161 bytes and a faithful port of the parser consumes
exactly 161/161**, with the name, the 16-char id and the integer position landing on the right
offsets. Structure is now verified as far as static reading can; only the *semantics* of the
placement fields (the small object's `u8 + 3 x u16` and the three bytes after it) remain unknown.

## 9. Guilds and areas (server side)

`TryClaimPlot` now enforces the guild model the client's strings describe (dbstr 52656, the
neighborhood charter; eqstr 5317/754/755 for the purchase refusals):

* `nms_neighborhood.guild_id != 0` binds the neighborhood to that guild, and the claim is refused
  for anyone whose `Client::GuildID()` differs. This is the "assignment of guilds to areas".
* `nms_plot.plot_type = 1` marks a guild plot. Those set `owner_guild_id` and require a guild;
  player plots (`plot_type = 0`) set `owner_char_id` and count against the two-plot limit.
* The claim UPDATE is guarded on `owner_char_id = 0 AND owner_guild_id = 0`, so a lost race just
  affects zero rows.

Verified: the handler's plot query returns columns in the expected order
(`id, door_id, owner_char_id, owner_guild_id, plot_type, guild_id, dist`) and resolves lot
coordinates to the right plot; binding and unbinding `nms_neighborhood.guild_id` round-trips.

All 76 seeded plots are `plot_type = 0`. Which physical lots are guild plots in Live is not
recoverable from this tree, so promoting some is a data decision, not a code one:
`UPDATE nms_plot SET plot_type = 1 WHERE door_id IN (...)` then recompute
`nms_neighborhood.max_guild_plots`.

## 10. Open questions

1. The trigger for `0x3424` vs `0x2691` at window-open time, and the meaning of the four unknown
   u32s in the neighborhood-list entry. A live packet capture settles this (log categories
   "Packet C->S" 84 and "Packet S->C" 83 in `logsys_categories`).
2. Offsets 0..19 of the placement payload and the destination of its 16-byte identifier.
3. Which of the two strings per plot entry in `sub_74C4C0` is the street address.
4. Whether the client renders a placed building from server data at all, and on which opcode.
