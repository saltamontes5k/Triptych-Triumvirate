# RoF2 Player Housing — Investigation Findings

Status: server-side housing is implemented and working; the client-side neighborhood gate
(`RealEstate[+144]`) was **root-caused on 2026-10-25 — see §9**: the definition "kind" must be
the raw integer 5, and we were sending the IEEE bits of 5.0f. Everything below stands except
where §9 corrects it.

Client under test: RoF2 (`C:\Games\EQTriune\eqgame.exe`, ASLR on, image base 0x400000 in IDA).
Server: EQS / Triptych Triumvirate (`Release-NMS-Server`).

---

## 1. What works (verified in game or against the live DB)

| Feature | Evidence |
|---|---|
| Neighborhood list renders in the client | the client requests it (0x2691) and we answer; user saw the window populate |
| Item-based placement persists | DB: lot 19 owned by char 3, `house_id 2`, `house_zone phinterior1a1`, item 61922 consumed from slot 26 |
| House interior reachable | user's key test; `#housing enter` uses the same `MoveZoneInstance` path |
| Enter / leave | `#housing enter`, `#housing leave`, `#leaverealestate` all work |
| Guild plots | `#housing guildplot`, guild-aware ownership in `place`, `#housing bind`; SQL verified (promote lot 18 → 75 player / 1 guild, reverted cleanly) |

Server surface: `nms_housing.cpp` (~1000 lines), `nms_neighborhood` + `nms_plot` tables, commands
`list claim release bind place enter leave guildplot send exterior`.

---

## 2. The neighborhood gate — the blocker

`sub_74BB00` (the handler behind every real-estate action and `CMD_REAL_ESTATE_LEAVE`):

```c
if ( sub_7F5F70( manager[36] ) )   // manager + 0x90 = +144
    sub_74BA70(this);
else
    ShowError(eqstr 8078);          // "You must be in a neighborhood to use that."
```

`sub_7F5F70` returns **true only for the value 5**; `10` is the miss default.

### Who writes +144

Exactly three sites in the whole binary (found by scanning every `mov [reg+0x90], imm` and
`mov [reg+0x90], reg` in .text):

- the manager constructor `sub_5B21E0` and two resets — write the constant **10**
- `0x5B30C3`, inside `case 0x6FD0` of `RealEstate::HandlePacket` (`sub_5B2500`)

```c
case 0x6FD0u:
  v39 = sub_7FE100(new 0x58);            // RealEstate object
  (*v39->vtable[3])(v39, &payload);      // deserialize  (sub_7FDF00)
  a1[35] = v39[5];                       // +140
  a1[36] = sub_7F4FA0(v39[8]);           // +144 = lookup(object+32)
```

### Object deserializer `sub_7FDF00` (vtable slot 3, vtable at 0xA1052C)

Reads in order, all bounds-checked:

| payload | lands at |
|---|---|
| u32 ×3 | +20, +24, +28 |
| **u32 (4th)** | **+32 — the lookup key** |
| u32 ×2 | +36, +40 |
| string, string | +48, +44 |
| u32 | +52 |
| u32 count | — |
| string | +56 |

### Definition table

- Lookup `sub_7F4FA0(this, key)`: buckets at `*(this+1)`, count at `*(this+2)`,
  key compared against `node[27]` (+108), **returns `node[15]` (+60)**, miss → 10.
- Insert `sub_7F52F0(this, struct, key)`: buckets at `*this`, count at `*(this+1)`,
  writes key to `node+108`, no validation.
- Insert is called with `ecx+4`, lookup with `ecx`, so **both resolve to manager+120/+124** —
  the same hash array and the same modulo. Verified by disassembling the 0x2698 case at
  0x5B27A2 (`mov ecx,[ebp+74h]`) and the 0x6FD0 case at 0x5B30AE.

### Definitions: ONE map, fed from the file at startup AND merged from the wire (§9)

```c
case 0x2698u:
  v13 = a1[29];            // the file-fed definition map (manager dword 29 / +116)
  sub_7F5B60(v13, &reader);  // parse entries (sub_7F4C90) and insert into v13+4
  sub_7FC6B0(&reader);     // second list
  sub_5AAAD0(a1[30]);
```

CORRECTED 2026-10-25 (§9): the manager constructor builds the definition map itself
(`sub_5B21E0` → `sub_7F5CE0`, stored at manager dword 29 / +116) and populates it from
`RealEstateDefs.txt` via `sub_7F5380`; parse problems are reported to `RealEstateErrors.txt`.
`case 0x2698` merges wire entries into that **same map** (`v13 = a1[29]` at 0x5B27A2), and the
`0x6FD0` lookup reads the same `a1[29]`. The file ships with no client, but the client does read
it when present. "Seeding the file changed nothing" was true and misleading at once: insert
PREPENDS to the bucket chain (`sub_7F52F0`), so the wire entry for the same id shadowed the
file's — and the wire entry carried the broken kind value (§9).

Definition entry format (`sub_7F4C90`), all fields mandatory:

```
u32 id · u32 ×8 · u32 kind · u32 · string (length-prefixed)
u32 · u32 · u32 ×3 · u32 · u32 child-count (+ count × u32 children)
```

- The kind is struct index 15 (node+60) — the gate value. Defaults to 10, must be the **raw
  integer 5**. CORRECTED 2026-10-25 (§9): every field is stored verbatim (`mov dword`; the
  "f32" here was Hex-Rays type noise), and sending the IEEE bits of 5.0f (0x40A00000) as the
  kind is what broke the gate. Field order verified: id, slots 7–14, kind (15), slot 16,
  string (slot 3), slots 17/18, slots 19–21, slot 22, child count.
- **Short reads do not fail safe.** Three parsers in this handler (`sub_7F5B60`,
  `sub_7F4C90` line ~146, `sub_7FC6B0`) fall back to using the *reader's own address* as the
  value when the buffer is exhausted, which then drives a `do { } while` loop for billions of
  iterations and **crashes the client**. Every trailing field and the second list's count must
  be present.

---

## 3. The exterior packet `0x626E`

Dispatcher `case 25198` at 0x4D058A. Parsers run big-object first, then small-object
(confirmed via the thunks at 0x4D5510 / 0x4D6780, which take the *pushed* pointer).

```
sub_505400:  string(null-terminated, ≤63), u8, u32, u32, string16(null-terminated, ≤16),
             u32 ×3 (+36,+40), u32 ×9 (+124…+148 in the caller's reads),
             u8 ×3, u32 ×8 (+156…+184)
sub_4D60E0:  u8, u16, u16, u16
inline:      u8, u8, u8, u32, u32, u32, u32 count, count × (u32,u32), u32, u32
```

Four defects found and fixed, each independently fatal:

1. **Strings are null-terminated**, not length-prefixed (`strlen`, not a u32 length).
2. **The 16-char identifier must be valid** — `sub_80C920` accepts it only when `strlen == 16`
   *and* decode/re-encode reproduces it. Codec: custom base64, alphabet `0-9A-Za-z+-`,
   table at 0xB61D20; `sub_80C6A0` packs, `sub_80C520` unpacks.
3. **World coordinates are integers**, not float bit patterns (`sub_5384D0` stores int params
   straight into its payload and bounds-checks against integer world limits).
4. **Eight tail dwords, not ten** — two extra shifted the small object by 8 bytes.

With those corrected the packet is 161 bytes and a faithful port of the parser consumes exactly
161/161.

Observed behaviour in game: the client **parses** it (a real-estate placement flow opens) then
rejects it locally with eqstr **5223** "Your real estate item request failed" and sends nothing
back. So it is being read as an *item placement*, not a building spawn — the field semantics
beyond the name/position are still unknown.

Useful safety property: unlike the plot-list reader, every read in `sub_505400`/`sub_505A50` is
bounds-checked, so a short packet leaves defaults rather than overrunning. `sub_80C9B0` (used by
the plot list) is the one that overruns.

### Placement call mapping (0x4D07A3)

`sub_558BB0` receives: a2 manager+0x84, a3 big object, a4 small object, a5–a7 the three bytes,
a8–a10 the three u32s, a11 0. So the small object and those bytes carry the placement parameters
— they are the most likely home of the transform or model selector.

---

## 4. Exteriors are not in the zone's asset list

`neighborhood_assets.txt` (identical in both clients) lists only:

```
stonesquare.eqg  Tradeskill_objects.eqg  phteleporting.eqg  voidportal.eqg
furniture01/03/06/07/10/12.eqg  it12043.eqg  IT23651.eqg
```

No house models — houses are streamed in by the real-estate system. But the models exist on disk:
`thulehouse1.eqg` (24.7 MB), `thulehouse2.eqg` (25.8 MB), `chapterhouse.eqg`,
`housegarden.eqg`. They are PFS archives, so object names are not in plain text and would need
the PFS container parsed.

A static-object stand-in (add the `.eqg` to `neighborhood_assets.txt`, place it as a `doors` row)
remains the pragmatic route to a *visible* exterior if the renderer stays unreachable.

---

## 5. Retail design notes (from the official HoT housing guide)

- Neighborhoods are instanced zones with ~71 plots; more spawn as they fill; each has a name.
- Max **two** plots per player. Bought by clicking the stone marker or the low stone border.
- **Houses are placeable items**, one per plot; placing one grants access to a separate instanced
  zone. Entering is via the house's front door; **retail houses have no interior door** — you leave
  through the real-estate window or `/leaverealestate`, which zones you back outside the plot.
- Plot storage is the "shed", interior storage is the "closet", vault slots cap lower than total
  items (e.g. 300 total / 60 vault).
- Guilds effectively get their own neighborhood; unguilded players form the shared "guildless"
  pool. `nms_neighborhood.guild_id = 0` models that today.

---

## 6. Hypotheses that were disproved

Recorded because each cost real time:

- **"The gate setter is unreachable."** False — the 0x6FD0 case runs; the client echoes back the
  `+140` value we send.
- **"`RealEstateDefs.txt` must exist and be correct."** False — it ships with no client.
- **"The definitions file is loading because no error file appears."** Meaningless — the error
  writer is not a file logger; absence proves nothing either way.
- **"Insert and lookup use different tables."** False — both resolve to manager+120/+124.
- **"The definition entry is keyed wrongly."** False — `lea ecx,[ebp-7C]` then
  `call sub_7F4C90`, and the key is read straight back from that slot.
- **"Ordering: send definitions before the first identity."** Implemented; the gate still refuses.
- **"The 16-byte id is optional / the strings are length-prefixed / coordinates are floats."**
  All three were wrong and all three were fixed; none of them made the building appear.
- **"The definition kind is a float — send the IEEE bits of 5.0f."** THE ROOT CAUSE (§9). The
  parser stores raw dwords and `sub_7F5F70` accepts only the integer 5.
- **"Seeding RealEstateDefs.txt changes nothing, so the file is a dead end."** Misleading — the
  file IS loaded by the manager ctor, but insert prepends, so the wire entry for the same id
  shadowed the file's node (§9).

---

## 7. Open questions

1. ~~**Why does the lookup still return 10**~~ ANSWERED (§9): it was never returning 10 on the
   hit path — the hit returned 0x40A00000 (the IEEE bits of 5.0f we sent as the kind), which
   fails `sub_7F5F70`'s switch exactly like a miss. Table identity was never the problem: one
   map at manager dword 29, shared by the file loader, the 0x2698 merge, and the 0x6FD0 lookup.
2. **What are the real semantics of the `0x626E` placement fields** (small object and the three
   bytes)? Needs a reference packet. The cleanest source would be the client's own *writer* for
   0x2698 and 0x626E — read the sender instead of inferring from the receiver. This is the single
   highest-value next step and is cheap now that an IDA MCP is available.
3. **Interior identity.** `SendRealEstateIdentity` only fires when the zone is named
   `neighborhood`; inside `phinterior*` the client has no real-estate context at all, which is
   why the Real Estate Items window shows *Yard/House/Crate: N/A* and an empty list there.

## 8. Unexplained observation

An upstream EQS-derived server is reported to have working housing/trophy placement, with
screenshots and video of Plot Search working. That means the gate is satisfiable on some client
build. What upstream does differently is unknown and was **not** pursued further — probing another
live server is a ban risk and not worth it.

---

## 9. Resolution (2026-10-25): the gate kind must be the raw integer 5

Every link below was read from the binary (IDA, `shroudref/ida/eqgame.i64`; addresses verified
byte-identical between the IDA build and the live spellbook-patched exe, so all RVAs hold):

1. The definition map is a **single object at manager dword 29 (+116)**: the manager ctor
   `sub_5B21E0` builds it via `sub_7F5CE0`, which loads `RealEstateDefs.txt` (`sub_7F5380`:
   first line discarded as a header, 23 `^` tokens per record; the MaxNonRE/MaxPets
   validation CLAMPS to MaxItems and logs to `RealEstateErrors.txt` — it never rejects a
   record), then `sub_5B5890` stores it at `a1[29]`.
2. `case 0x2698` calls `sub_7F5B60(a1[29], reader)`: per entry it parses the record with
   `sub_7F4C90` and inserts with `sub_7F52F0(map+4, record, &id)` — the **same map** the ctor
   fed. Insert **prepends** to the bucket chain, so a wire entry for an id that also exists in
   the file shadows the file's node.
3. `case 0x6FD0` deserializes the identity object (`sub_7FDF00`), then
   `sub_7F4FA0(a1[29], object+32)`: buckets at `*(map+1)`, key compared raw against
   `node[27]`, **returns `node[15]` verbatim**, miss → 10.
4. `sub_7F5F70` is a switch on that value; **only case 5 returns true**. Any other value —
   including 0x40A00000 — falls through to default → false → eqstr 8078.
5. `sub_7F4C90` stores every field with a plain `mov dword` (Hex-Rays renders these as float
   only because the record local is reused for floats later — same illusion as the file
   loader's `COERCE_FLOAT`, which the assembly at 0x7F553B disproves: `mov dword ptr
   [ebp+ArgList], eax`). The file parser likewise stores `atoi(token 14)` raw. The kind is an
   integer everywhere.

The server was sending `memcpy`'d IEEE bits of `5.0f` (`0x40A00000`) as the kind. Every gate
test ever run failed on that alone; "the lookup returns 10" was an inference from the miss
default, never an observation. This also explains why the stand-in file "changed nothing": the
file's kind-5 node was loaded at ctor, then shadowed at zone-in by the wire node carrying
0x40A00000 for the same id.

**Fixes applied 2026-10-25:**
- `nms_housing.cpp` `SendRealEstateDefinitions`: send `U32(5)` raw; comments corrected. Server
  rebuilt green and restarted.
- `RealEstateDefs.txt` / `RealEstateDefRel.txt` refreshed in the live client dir and copied to
  `Release-NMS-Client/ClientFiles` (kind 5; MaxItems 300 / MaxNonRE 60 / MaxPets 10; dangling
  `1^1` DefRel row removed). The file is the belt, the wire defs the suspenders — both now
  produce kind 5, so shadowing order is irrelevant.

**In-game verify owed:** full client RESTART (the map is a per-process singleton built once at
ctor — a re-zone is not enough), zone into `neighborhood`, attempt a gated action; expect no
eqstr 8078. `RealEstateErrors.txt` should stay absent.

---

## 10. Post-verify (2026-10-25): gate 8078 is dead; the second gate (eqstr 727) is decoded

**Verified in game:** after the §9 fix the client accepts the neighborhood — the Plot Search
window renders owned plots ("Type Player / Owner Judy") and the previously ubiquitous
"You must be in a neighborhood" spam is gone. Plot recognition works.

### The second gate: eqstr 727 — "You must be inside a plot or house to use that."

Fired by `sub_747E50` (registered through a UI callback table at `0x9f86dc`; this is what
lot-door edit / manage actions run through):

```c
sel = *(manager + 152);                    // dword 38, ctor/reset default -1
if (sel == -1) → 727
node = plot_map_lookup(sel);               // map at manager+4: buckets mgr+4, count mgr+8
if (!node || node[0] == 0) → 727           // nodes: [0]=object ptr, [1]=key id, [2]=next
else proceed
```

### Manager state model (offsets, all CONFIRMED)

| Offset | Meaning |
|---|---|
| +136 | last spatial-update timestamp |
| +140 | current neighborhood id (0x6FD0 object+20) |
| +144 | context kind (defs lookup of object+32; only 5 passes `sub_7F5F70`) |
| +148 | the real-estate object id under the player's feet |
| +152 | the id of the HOUSE object on that plot (what eqstr 727 tests) |
| +156, +160 | further selection slots (+160 = a sub-result's +20 from `sub_5B0A10`) |
| +164/+168 | placement-request in-flight flag / timer |
| ctor `sub_5B21E0`, reset `sub_5B1CF0` | all of the above to -1 / 10 / 0 |

### The spatial updater — who writes +148/+152

`sub_5B0A10` (manager tick, ~1 Hz):

```
if (mgr+12 <= 0)  # no real-estate context
    +148 = +140; +152 = -1; +156 = -1; +160 = -1
else
    +148 = sub_4B3040(player_ctx) = sub_4B2F40(player_ctx+644)   # object under my feet (spatial)
    if (+148 == -1) +148 = +140                                   # fallback: the neighborhood
    sub_5B00E0:  object = plot_map[+148];
                 +152 = sub_4D6790(object, house_kind_mask)->+20  # walk PARENT chain (+28), max 10,
                                                                   # first ancestor whose defs kind
                                                                   # matches the mask; -1 if none
```

`sub_4D6790` is the hierarchy walk: each RealEstate object carries **+28 = parent object id**,
and defs kind → bitmask via `sub_7F5E30`; masks come from `sub_7F62B0`/`sub_7F62C0`. The kind
predicates so far: **5 = neighborhood** (`sub_7F5F70`, gate 8078), **8 = plot** (`sub_7F6280`).
Kinds 1-11 all exist in the predicate switch.

### The RealEstate object model (0x58 objects, `sub_7FE100`)

Arrive on **0x6FD0** (identity — decoded in §7) and on **0x63FD (25597)** — the second case in
`sub_5B2500`, deserialized with the same vtable slot 3 plus an extra argument, applied the same
way, and refreshing windows when the object's +20 equals the current +152 selection.

| Object field | Meaning |
|---|---|
| +20 | own id (becomes manager +140 for the identity packet) |
| +24 | second id (registered if > 0) |
| +28 | **parent object id** (the hierarchy link `sub_4D6790` walks) |
| +32 | own real-estate definition id (the defs-map key; drives +144) |
| +36 | related id — registered as a map key **only when defs-kind(+32) == 8** |
| +44/+48 | strings; +52 u32; child count + children; +56 string; +60 kind; +64/+68 |

Apply path: `sub_5B5A90` registers the object in the plot map under +20, +24 (if > 0), +32, and
+36 (only when kind(+32) == 8); `sub_5B7C70` (vtable[10], "load by id") indexes it into a map at
manager dword 9 (by +32) and manager dword 17 (by +36 when kind 8) and recurses through children
(+72 count / +76 ids); `sub_5B59A0` erases (unload).

### Why 727 still fires for us

Our identity object registers only id 712 with kind 5. The spatial test finds no plot object
under the player (we send no placement data), so +148 falls back to 712, and the house-walk in
`sub_5B00E0` fails (parent id 0 is not registered; kind 5 is not in the house mask) → +152 = -1
→ 727. It fires even inside `phinterior1a1` because nothing links the interior instance to an
exterior plot object client-side.

### Dead end recorded: 0x2AA6 items data

The dispatcher's 0x2AA6 handler `sub_741670` parses ONE record (u32, u32, u32, cstring ≤63,
cstring ≤31, u8, u32, then count × items via `sub_7FB870`) into a stack local and **discards
it** — parse-and-discard in this build. It is not what populates the selection or the plot map,
and it explains the Real Estate Items window showing "Yard/House/Crate: N/A" with an empty list.

### Implementation path to satisfy eqstr 727 (next phase)

1. Definitions: add kind-8 entries (plots) to the 0x2698 definitions packet — keep 712 = 5.
2. Send plot objects (0x63FD or 0x6FD0) forming the hierarchy: plot object (+32 = plot def id,
   +28 = 712, +20 = plot id) and the placed house as its child, so the apply registers real ids.
3. Feed the spatial index — placement data for each plot (the S→C 0x626E packet decoded in §3,
   161 bytes). Retest the eqstr-5223 rejection with the hierarchy registered first (ordering:
   defs → objects → placements). If the spatial index (`sub_4B2F40` at player_ctx+644) does not
   consume placement objects, decode what does.
4. Server-side interim answer stays `#housing place` (now with a widened name-word auto-detect:
   Hut/Cottage/Manor/Villa/Chalet/Cabin/Lodge join Residence/Deed/House; house items are
   itemtype 11 with no data marker, so names are the only handle — the explicit
   `#housing place <door_id> <item_id>` form always works).

---

## 11. Third batch (2026-10-25): kind-8/4 definitions + 0x63fd plot objects shipped

### 0x63fd ≡ 0x6fd0 on the wire

The 0x63fd case in `sub_5B2500` deserializes with the same vtable slot 3 (`sub_7FDF00`, now
confirmed `__fastcall(object, unused_edx, reader)` — the dispatcher's extra argument is pushed
but ignored) and runs the same apply path. Same wire layout, so plot objects reuse the identity
builder shape. The case additionally refreshes windows when object+20 equals the current +152
selection (`sub_74DCB0`), consistent with 0x63fd being the "your plot data" packet.

### eqstr 5223 is the GENERIC placement failure

`sub_5B0200` executes a placement attempt through a window vtable call and maps the returned
error code: **20→5231, 21→5275, 42→5283, 74→5407, everything else→5223**. Our experimental
`#housing exterior` packet executed and failed with an unmapped code — the reject was never a
parse failure. With the object hierarchy registered the error may become a specific code, which
then names the exact failing validation.

### Shipped in this batch

- `SendRealEstateDefinitions` now sends three definitions with distinct kinds: zone id = 5
  (neighborhood, the +144 gate), id 1 = 8 (plot), id 2 = 4 (house).
- New `SendRealEstatePlotObjects` (called at the end of `SendRealEstateIdentity`): sends every
  plot the player owns in this neighborhood as a 0x63fd object — +20 = door_id (the plot id the
  plot list uses), +28 = zone id (parent = the registered neighborhood object), +32 = 1 (the
  kind-8 def), +60 = 8. The apply registers it in the client's plot map.
- `OP_RealEstateObject=0x63fd` added to `emu_oplist.h` + `patch_RoF2.conf`.

### The one remaining link: the spatial index

The 727 gate reads +152, written by the 1 Hz updater only when the client's spatial index finds
a real-estate object under the player's feet. That index is a hash at `player_ctx + 644`
(`dword_DD2630` context; buckets +644, count +648), scanned by `sub_4B2F40`, whose entries pass
`sub_8D2AD0` and resolve through `sub_4B30F0` to objects whose defs kind `sub_7F6030` accepts —
**only 4 and 8**. The neighborhood fallback (+140) can never satisfy the walk (kind 5 is not in
the 0x88 mask, and the parent chain from the root has nowhere to go), so a placement-driven
spatial registration is mandatory. The insert side is not yet located statically: the placement
result handler `sub_558BB0` constructs the world object (0x504xxx/0x505xxx/0x506xxx creation
helpers), which is the most likely feeder. Next decode: the +644 hash insert (or a runtime probe
of `sub_4B2F40`/`sub_5B00E0` on live), then correct the 0x626e placement semantics.

---

## 12. Fourth batch (2026-10-25): placement positions are floats; plot address column identified

### sub_558BB0 fully read — the 0x626e response spawns the world object, and its positions are FLOATS

The spawn path is `sub_5056B0(new 0xC0 object, big_object, flags…, byte3, u32_1, u32_2, u32_3)`,
and the big object's coordinates are read back as **IEEE floats**: `sub_558BB0` compares
`*(float *)(object + 140 / +144 / +148)` against the player position (a `sqrt(dx²+dy²+dz²) <
radius` visibility gate), and also consults `+132` / `+136` and the tail fields `+176` / `+180`
as floats. The earlier "world coordinates are integers" finding applies **only to the
client→server request** (`sub_5384D0`); the server→client response is float-encoded. The first
`#housing exterior` builds put integer units at +124/+128/+132 and zeros at +140..+148 — the
object could only ever appear at a garbage position near zero, which is exactly the observed
"consumes the item, nothing renders". The builder now writes float bit patterns at
+140/+144/+148, with variants 0-3 sweeping the +132/+136 encodings (zero floats, heading float,
duplicated x/y, and the legacy integer encoding as baseline). The small object
(`u8 + 3×u16`) and the three bytes land on the placement controller (`this[6..8]`) and are reset
once the placement settles, so zeros are a valid baseline there.

Also mapped in `sub_558BB0`: a nonzero byte 1 (`a5`) diverts to an "attach to existing object"
path (`sub_5996E0(u32_3)` resolves a parent world object), byte 2 (`a6`) gates object creation,
and the object's render model comes from the big object via `sub_5056B0` — the 16-char id and
the name string are the identity handles.

### Plot list: the second per-entry string is the Address column

Live-confirmed from the Plot Search window (row order **Address, Type, Owner**; the Address was
blank because we sent `Str("")`): `sub_74C4C0` formats the second string into the Address
column and the first string into Owner. `SendPlotList` now synthesizes a stable address
(`<door_id> <neighborhood name>`); there is no address data column in the schema.

### In-game state after batch 3 (b060b644)

`#housing place 19` consumes the house item and creates the interior (instance works, expiry
message shows), but nothing renders on the lot — expected, the exterior is the 0x626e path
fixed above. Manage/plot-edit still prints eqstr 727 on the lot and inside `phinterior1a1` —
consistent with the spatial index being the last unsatisfied link. Plot objects (0x63fd) and
kind-8/4 definitions are confirmed shipped (zone logs show the plot-object sends).

---

## 13. Sixth batch (2026-10-25): the plot-recognition packet — opcode 0x49df

This is the "plots recognized by the client first" layer upstream shipped before placements.

### The spatial index, fully decoded

- The manager singleton pointer lives at `dword_DCEE30`; the object holds TWO hashes:
  **+0x00** = the ACTIVE area hash (buckets@+0, modulus@+4), **+0x14** = the placement
  override hash (buckets@+0x14, modulus@+0x18, fed by the 0x626e key/value pair list —
  cleared per packet by `sub_4D5B90`; not the scanner's input).
- The scanner `sub_4B2F40` (via the thunk `sub_4B3040`; player position is stored at
  player ctx `dword_DD2630` +0x284) walks the +0x00 hash. Node = {area object, area id,
  next}. Per node: `sub_8D2AD0` → `sub_505BA0` (invert the area's 4×4) → `sub_505F60`
  (transform player position; inside iff every |component| ≤ 1). Then `sub_4B30F0(area_id,
  mgr+140)` must resolve the id in the client's PLOT MAP to an object whose **definition
  field 7 == the current neighborhood id**, with defs kind in {4, 8} (`sub_7F6030`) —
  on success the updater sets RealEstate[+148] = object+20, then `sub_5B00E0` walks the
  {4,8} ancestor mask (mask `sub_7F62B0()` = 0x88) and sets +152 — what eqstr 727 tests.
- **Field 7 of the definition record is the NEIGHBORHOOD LINK** (defs file token "I1";
  first of the eight u32s on the wire). Ours were 0 — the resolution could never match
  even with areas present.

### The 0x49df (18911) area manifest

Dispatcher case at `0x4CA7A5` (`cmp 0x49DF` at 0x4c45c3): builds the reader
(`sub_410C40` = {ptr,len,pos}), then — when `dword_DCEE30` is live — `sub_4B2740` (clear
the +0x14 override hash) and `sub_4B2AB0`: reads `u32 count`, then per entry a new 0x5C
EQAreaBase object filled by `sub_8D2E30`:

```
u32        area id            -> object dword 1 (the hashed key)
f32 x16    4x4 row-major      -> four 16-byte blocks (sub_8D3200): LOCAL [-1,+1]^3 -> WORLD;
                              columns = half-extent axis vectors, 4th row = world center
u32 x5     trailing fields    -> object dwords 18..22 (not read by the inside test)
```

The inside test inverts the 4×4 (`sub_505BA0`) and transforms the player position; the
player is "in" the area when the local coordinates are within ±1 per axis. An axis-aligned
box at the lot is therefore `[hx 0 0 0 / 0 hy 0 0 / 0 0 hz 0 / cx cy cz 1]`.

### Shipped

- `SendRealEstateAreaManifest` (after the identity + plot objects on zone-in): one area per
  owned plot, id = door_id, box centered at the door's world position, half-extents
  15/15/20 — only resolvable ids matter, so owned plots suffice.
- Definitions now carry field 7 = neighborhood id (wire and `RealEstateDefs.txt`; the
  client file also gains explicit plot(1, kind 8) / house(2, kind 4) rows).
- `OP_RealEstateAreas=0x49df` in `emu_oplist.h` + `patch_RoF2.conf`.

### Expected end-to-end (pending in-game verify)

Zone in → defs (field 7 = 1) → identity (+140 = 1) → 0x63fd plot objects (plot map) →
0x49df areas (spatial index) → 1 Hz updater: player on lot ⇒ inside area ⇒ +148 = door_id ⇒
plot object kind 8 ⇒ +152 = door_id ⇒ **Manage no longer prints eqstr 727**.
