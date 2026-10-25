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
