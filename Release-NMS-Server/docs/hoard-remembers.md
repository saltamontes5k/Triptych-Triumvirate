# The Hoard Remembers — curio click-traps in Veeshan's Peak and Plane of Air

> **Status, 2026-11-09: designed, partly shipped, and not working.** The
> handler logic, the rule, and 19 Veeshan's Peak door rows are in the tree and
> in the live database; the 309 Plane of Air rows are not in the live database.
> But no authored trap can fire, because every authored door id is above 255 and
> the client/server door id is a byte. The stock Phara Dar hoard doors (162–206)
> can still react; the new traps cannot. This document is the design record and
> the post-mortem, not a "shipped and verified" note.
>
> **Update, 2026-11-10: the object route is implemented but not yet live-tested.**
> Plane of Air's 309 props are now `object` rows of type `CurioTrigger` at the
> exact WLD placements (v372), with `EVENT_CLICK_OBJECT` in `poair/player.pl`.
> Veeshan's Peak's 19 authored doors were renumbered from 601–630 to 1–19
> (v373), which fits the uint8 band and stops the stock-door aliasing. Both
> migrations are applied, `zone.exe`/`world.exe` build, and the handlers are
> synced; the remaining step is a live zone boot/click test.

## What this is

A raid leader on a classic-era server used to shout "don't touch the loot!" at
anyone who wandered too close to a treasure pile. This feature makes the warning
true: clicking the named curios in Veeshan's Peak (treasure piles, dragon
statues, thrones) and Plane of Air (clockgem crystals, bookcases, flying books,
goblets, scrolls) rolls something bad — a port, a stun, a buff wipe, guardian
adds, a death touch, or a NetHack-style throne fate. It is deliberately petty:
the hoard notices, and it remembers.

## Feature design

### Trigger tables

**Veeshan's Peak — treasure** (stock doors 162–184 and 195–204; v316 odd doors
601, 603, … 611). One roll out of 100:

| Roll | Outcome |
|---|---|
| < 20 | Port to Plane of Air (`movepc(215, 884, 532, -90, 0)`) |
| < 40 | Drunken Stupor brew, spell `7536` |
| < 55 | `BuffFadeAll()` — every blessing unravels |
| < 70 | Lair guardian adds (`curio_guardians`) |
| < 80 | Color Cloud `7261` paralyze |
| < 90 | Veeshan's wrath: `Damage(1000000)` |
| else | Nothing. This time. |

**Veeshan's Peak — statues** (stock 205–206; v316 even doors 602, 604, … 612):
a straight 50/50 between guardian adds and the Color Cloud paralyze. No mercy
roll.

**Plane of Air — crystals, goblets, scrolls** (v361 doors 601–793 and 888–909):

| Roll | Outcome |
|---|---|
| < 15 | Doomseeker adds (`215018`, `215021`) |
| < 30 | Color Cloud `7261` paralyze |
| < 45 | `BuffFadeAll()` |
| < 60 | Drunken Stupor `7536` |
| < 85 | Xegony's rage: `Damage(1000000)` |
| else | Nothing; a coatl screams past |

**Plane of Air — bookcases and flying books** (v361 doors 794–887): no roll.
Every click files the character into the Plane of Knowledge library at
`movepc(202, 1016, 16, 390.7, 130)` — the rumour, made true.

### Thrones

The ordinary throne triggers are v331 doors 621–626 (one beside each lair
throne, model `VEBRAZ101`). Two thirds of clicks do nothing: "You feel somehow
out of place…", or "You feel very comfortable here." once the character has been
crowned. The other third rolls one of twelve fates:

| d12 | Fate |
|---|---|
| 0 | Insight: mana to maximum |
| 1 | "Much, much better": HP to maximum |
| 2 | See Invisible, spell `80` |
| 3 | A brief attribute blessing (`3467` Virtue, `173` Benevolence, `9466` Nimbus) |
| 4 | Tithe: 15% max HP plus `7536` |
| 5 | Electric shock: Spiroc Thunder `987` |
| 6 | Gold tithe: 10% of the purse, only if it holds ≥ 100,000 copper |
| 7 | Royal court summoned (guardian adds) |
| 8 | Curse: `7536` |
| 9 | Wrenching: teleport to another lair |
| 10 | Pretzel: Vertigo `8562` |
| 11 | Crowning: Crown of King Tranix, item `4504`, once per character |

Crowning uses the character data bucket `curio_crowned_<charid>`; a second
crowning roll says "You feel like a fraud." There are no wishes and no genocide
in the table — the throne only threatens.

Door 630 is Phara Dar's **Queen Throne**, a Vlad's Throne homage with a pure
curse table (`rand(6)`): 30% max HP plus `7536`; grease via Color Shift `177`;
Torbas' Acid Blast `1415`; the Queen's court (guardian adds); a grudging heal or
a curse; or a forced teleport to one of the other five lairs.

### Spell and item ids

| Id | Name | Used for |
|---|---|---|
| `7261` | Color Cloud | AOE paralyze |
| `7536` | Lethargy I | the "Drunken Stupor" brew / stupor rider |
| `8562` | Vertigo | the pretzel |
| `987` | Spiroc Thunder | electric shock |
| `1415` | Torbas' Acid Blast | acid drench |
| `80` | See Invisible | throne mercy |
| `177` | Color Shift | the "grease" result |
| `4504` | Crown of King Tranix (item) | crowning |

### Gate, cooldown, GM wink

- Rule `Custom:CurioTraps`, compiled default `true` in `common/ruletypes.h`.
  The handler returns unless the live value is the string `true`.
- Per-character data bucket `curio_cd_<charid>`, set with a 120-second TTL on
  the first qualifying click. The key is character-scoped, not zone-scoped, so
  a Veeshan's Peak click also covers a Plane of Air click for the same 120
  seconds.
- GMs bypass the rolls: "The hoard respects its makers. Door N felt your touch
  and spared you."

## How it is wired

### Doors as click triggers

The props themselves are static zone mesh, and the `object` table is empty for
both zones, so the traps are ordinary `doors` rows with `opentype 58`. The
click path is:

`OP_ClickDoor` (16 bytes, `uint8 doorid`) → `Client::Handle_OP_ClickDoor` →
`entity_list.FindDoor(cd->doorid)` → distance check against
`Range:MaxDistanceToClickDoors` → `parse->EventPlayer(EVENT_CLICK_DOOR, …,
std::to_string(cd->doorid))` → `EVENT_CLICKDOOR` in the zone's `player.pl`.

Each handler opens with a whitelist and returns for anything not on it. The
whitelist **is** the trap:

- `veeshan/player.pl`: treasure `162..184, 195..204, 601, 603, … 611`; statues
  `205, 206, 602, 604, … 612`; thrones `621..626, 630`. The Phara Dar seal
  (`56`, `57`) is handled before the curio call and is not trapped.
- `poair/player.pl`: everything in `601..909`. Stock door `1` (the keyed
  rainbow), `2` (the potranquility exit book), and `21` (the tranquility pad)
  fall through untouched. Door `1`'s key-`28638` unlock logic runs above the
  curio call.

### Door bands and migrations

| Band | Zone | Model(s) | Rows | Source |
|---|---|---|---|---|
| 162–184 | veeshan | `VEJEWL101/102`, `VECOINS101/102` | 23 | stock |
| 195–204 | veeshan | `VEBOX101/102/103` | 10 | stock |
| 205–206 | veeshan | `VEDRSTAT101` | 2 | stock |
| 601–612 | veeshan | `VECOINS101` / `VEDRSTAT101` | 12 | v316 |
| 621–626, 630 | veeshan | `VEBRAZ101` | 7 | v331 |
| 601–793 | poair | `POACRYS500/502` | 193 | v361 |
| 794–863 | poair | `POABKSHF501/502` | 70 | v361 |
| 864–887 | poair | `POAFLYBK500/502` | 24 | v361 |
| 888–898 | poair | `POAGBLT500` | 11 | v361 |
| 899–909 | poair | `POASCROLL500` | 11 | v361 |

The poair rows were generated from the zone file, not hand-placed: one door on
each named `0x15` ActorInstance, with `size` set to the instance scale × 100
(crystals `25`/`55`, bookcases `65`, books `80`, goblets `60`, scrolls `15`–`20`).
The veeshan rows are hand-placed at lair-floor `z`, not boss body `z` (the
dragons hover).

### Manifest entries

| Version | File | Gate | Live outcome |
|---|---|---|---|
| 316 | `20261103_curio_traps_v316.sql` | `empty` | 12 VP rows applied |
| 331 | `20261104_throne_of_the_first_brood_v331.sql` | `empty` | 7 VP rows applied (via the idempotent twin) |
| 332 | `20261104_vt_shard_rates.sql` | `not_empty` | **not** the poair file |
| 361 | `20261104_poair_curio_props_v361.sql` | `not_empty` | never runs; 0 rows |

`20261104_poair_curio_props_v332.sql` is a near-identical twin of the v361 file
(it differs only in comments). It never had a manifest entry: version 332 in
the manifest belongs to the Vex Thal shard-rate migration. Treat the v332 poair
file as dead; do not apply it by hand without deciding what it is for.

## Why the traps do not fire

### 1. Door ids are 8-bit — the hard blocker

The database column is `smallint`, and the repository reads it as `int16`, but
everything that actually identifies a door at runtime is a byte:

- `zone/doors.h`: `uint8 GetDoorID()` and `uint8 m_door_id`.
- `zone/entity.h`: `Doors *FindDoor(uint8 door_id)`.
- `common/patches/rof2_structs.h`: `Door_Struct.doorId` is `uint8`; the
  `ClickDoor_Struct.doorid` in the click packet is also `uint8`.
- `zone/doors.cpp`: the constructor assigns `m_door_id = door.doorid` (silent
  narrowing), and `CreateDatabaseEntry()` refuses to create a door once
  `GetDoorsDBCountPlusOne(...) - 1 >= 255`.

So a row with `doorid = 601` is loaded as door **89**; `612` becomes `100`;
`621` becomes `109`; `630` becomes `118`. The client is told 89, clicks 89, and
the server looks up 89. The handler is called with `$doorid = 89` — never with
601. Every whitelist entry above 255 is unreachable. In practice a click on one
of these rows either hits a different, low-numbered door or produces the red
"Unable to find door, please notify a GM (DoorID: 89)" message.

The 601–909 poair band would wrap to 89–255 then 0–141. Some of those low ids
collide with stock doors: poair rows in 768–790 would land on 0–22, stomping the
rainbow (1), the exit book (2), and the tranquility pad (21/22). In Veeshan's
Peak the 601–612 set lands in a gap (89–100), but the throne triggers
621/622/624/626/630 land on stock ids 109/110/112/114/118 and alias onto real
doors.

There is also a capacity problem no renumbering can fix: Plane of Air has 309
trap props and a byte has 256 values, four of which are stock. One door per
named prop cannot fit. A working design needs a subset (named props only), a
different trigger mechanism (objects, ground spawns, or proximity), or several
zones' worth of rows.

### 2. Plane of Air never got its rows

Two independent data-pipeline failures:

- The v332 poair migration was never in the manifest — version 332 is the Vex
  Thal shard-rate migration.
- The v361 entry that replaced it is gated `not_empty`. The manifest runner's
  `ShouldRunMigration` returns true for `not_empty` only when the check query
  returns a row; the check probes for door 601. On a database that has never
  had the payload — the normal case — the probe is empty, so the migration is
  skipped and the 309 rows are never bootstrapped. On a database that already
  has door 601, the migration runs, but `INSERT IGNORE` skips that one row and
  only fills gaps. The gate is backwards for a bootstrap migration: it cannot
  create the first row.

This is the same inversion that commit `99c34f14` fixed for v316 and v331; the
v361 entry was added afterwards and reintroduced it.

The live database confirms it: `db_version.custom_version` is 368, well past
361, while `SELECT COUNT(*) FROM doors WHERE zone='poair' AND doorid BETWEEN
601 AND 909` returns 0. Plane of Air still has only its four stock door ids
(1, 2, 21, 22, each in versions 0 and 100).

### 3. The "unknown model = no click geometry" test is not load-bearing

The v316 and v361 headers record a 2026-11-03 live test: a player clicking all
over Xygoz's lair against doors with invisible model names produced no
`OP_ClickDoor` at all, so "doors whose model the client cannot resolve have no
click geometry." That may be true, but it was not the blocker and the test is
not reproducible from the tree:

- `#door create` allocates `MAX(doorid) + 1`. Before the 601-band rows landed,
  that was 240 — a valid byte, so the test could have been meaningful.
- After the 601-band rows landed, the max is above 255. `CreateDatabaseEntry()`
  then returns early at the 255 guard, so a repeat of the test creates no
  persistent door; the in-memory door also gets a truncated id. A repeat would
  produce "no click" for a completely different reason.

Keep the model-resolution rule as a hypothesis to re-test on a door id ≤ 254,
not as the explanation for this failure.

## Client-contract notes that do hold

- **Doors load at zone init, but `#reload doors` reloads them live.**
  `Zone::Init` calls `LoadZoneDoors()`. `#reload doors` (and
  `#reload objects` / `#reload groundspawns`) routes through
  `ServerReload::Doors` → `Zone::ReloadStaticData()`, which removes all doors,
  reloads them, and respawns them for clients. `#reloadquest` reloads scripts
  only. So a script change needs `#reloadquest`; a door-row change needs
  `#reload doors`; neither needs a zone restart. The earlier "new doors always
  need a zone restart" claim is wrong for this tree.
- **Door version matters.** The trap rows are `version = 0` only. Veeshan's Peak
  also carries an 82-row `version = 100` door set (a second door set); a zone
  opened at another door version will not load the v0 traps. Verify the
  instance version before calling a door "missing."
- **Model resolution still matters for the visual/click contract.** The safest
  door models are the ones the zone's own stock doors already render
  (`VECOINS101`, `VEDRSTAT101`, `VEBRAZ101`, `POACRYS502`, `POABKSHF501`,
  `POAFLYBK502`, `POAGBLT500`, `POASCROLL500`). Do not assume an arbitrary
  model name resolves.
- **"Invisibility by perfection"** — name the door after the prop's own model
  and place it at the instance's exact position, heading, and scale; the
  duplicate renders pixel-identical on top of the original and is effectively
  invisible. This is a good trick, but it only matters after the id fits.
- **Survey stock data first.** Veeshan's Peak already ships clickable curio
  doors in Phara Dar's lair (162–184 coins/jewels, 195–204 boxes, 205–206
  statues). They need no DB rows; they only need the whitelist. Any new trap
  design should start by asking what the zone already has.
- **Never trap a working exit.** Plane of Air door 2 is the flying-book porter
  to potranquility (`dest_zone` set). Door 1 is the keyed rainbow; door 21 is
  the tranquility pad. The poair whitelist deliberately starts at 601.

## S3D/WLD reverse engineering

This is the reusable part: the zone file is the only complete source of static
prop placements, and the reader is small enough to keep in-tree.

### PFS v2 (RoF2-era container)

- `u32 dir_offset` at byte 0; the magic `"PFS "` at byte 4.
- The directory lives at `dir_offset`: `u32 count`, then `count × (u32 crc,
  u32 offset, u32 size)`.
- The entry with `crc == 0x61580AC9` is the directory payload. Other entries
  are files.
- Payloads are **block sequences**, not a single zlib stream: repeated
  `(u32 comp_len, u32 infl_len, zlib bytes)` until `infl_len` is satisfied.
- The directory payload is `u32 listed`, then per file (in ascending offset
  order) `u32 name_len` followed by the name. The `listed` count may differ
  from the table count; trust the table and the offsets.

### WLD fragments

- Magic `0x54503D02` at byte 0, `u32 version` at 4, `u32 frag_count` at 8,
  `u32 string_size` at 20, string table at 28 (XOR-encoded), then 4-byte
  alignment.
- Each fragment: `u32 size`, `u32 type`, then `size` bytes of payload.
- A fragment payload starts with `i32 name_ref`; a value ≤ 0 names the
  fragment via `strings[|name_ref|]`.
- The string table is XOR-encoded with the 8-byte key
  `95 3A C5 2A 95 7A 95 6A`, cycling by offset.

### 0x15 ActorInstance

The body after `name_ref` is:

| Offset | Field |
|---|---|
| +4 | `i32 ref` — negative = string offset; `strings[-ref]` is the actor name |
| +8 | `u32` (unused) |
| +12 | `u32` (unused) |
| +16 | `f32 × 3` position |
| +28 | `f32 × 3` rotation |
| +40 | `f32 × 3` scale; element `[2]` is the uniform scale used here |

The position is at payload byte 16, after two `u32`s following the `ref` — not
one. Getting that wrong shifts every placement by four bytes and produces
plausible-but-wrong coordinates.

### Axis mapping and heading

Calibrated against five in-game locations on 2026-11-07:

```
EQ(x, y, z) = (WLD_y, WLD_x, WLD_z)
```

X and Y are swapped; Z passes through. The five calibration points (clockgem
pillar, floating bookcase, scroll, book, goblet) matched within 12 world units.

Heading is **not** settled. The extractor's docstring says `rot_z`, but
`tools/poair_statics.py` and `tools/gen_poair_traps_v332.py` actually use the
first rotation component, `rot[0] % 512`. Those cannot both be right. The safe
procedure is: place with the extracted heading, look at the duplicate in game,
and if it is mirrored apply `heading = 512 - heading`. That flip was pre-written
for the poair band:

```sql
UPDATE doors SET heading = 512 - heading
 WHERE zone = 'poair' AND doorid BETWEEN 601 AND 909;
```

### Where placements live

- `<zone>.s3d`'s `objects.wld` holds the ActorInstance placements. For poair it
  carried 521 of the 522 `0x15` fragments.
- The main `<zone>.wld` is the world-baked BSP/zone mesh; it carried one
  instance and is not the placement source.
- `<zone>_obj.s3d` holds model definitions only — do not read it as a
  placement file.

### Tools

- `tools/poair_statics.py` — PFS + WLD reader, placement dump, five-loc
  calibration. Generalizes to any zone by changing the `.s3d` path and the
  `LOCS`/`PROP_TYPES` tables.
- `tools/gen_poair_traps_v332.py` — zone extraction → migration generator. It
  writes the twin SQL, retires the old poair block, splices the manifest entry,
  and splits the SQL into MSVC-safe raw literals. It aborts on concurrent-session
  drift.
- `tools/split_manifest_literals.py` — idempotent splitter for any raw literal
  over the C2026 threshold (keeps each piece under 12 KB).

## Migration engineering notes

- **The boot runner ate `INSERT … SELECT` silently.** v316's header records
  that the derived-table form misfired inside `QueryDatabaseMulti` at world boot
  (the rule row on the live DB came from the rule bootstrap; the doors never
  landed) while the same SQL ran fine from the mysql CLI. The shipped form is a
  plain multi-row `INSERT IGNORE … VALUES`. Keep it that way.
- **`doors` has `UNIQUE KEY DoorIndex (zone, doorid, version)`.** `INSERT
  IGNORE` is a safe no-op on re-run, which is what makes the twin SQL usable as
  a repair path. A migration that is skipped by its gate is not repaired by
  re-running the manifest; run the idempotent twin by hand if the version
  counter has already passed it.
- **Manifest `condition` semantics are inverted from intuition.**
  `ShouldRunMigration` returns true for `empty` when the check query returns no
  rows, and true for `not_empty` when it returns a row. Door inserts want
  `empty`: "run when the probe door is absent." A `not_empty` gate checks the
  post-state: it cannot bootstrap the first row, and once the probe row exists
  `INSERT IGNORE` only fills gaps. For a fresh insert, `empty` is the correct
  gate.
- **MSVC C2026:** a raw string literal over roughly 16 KB fails. Split the SQL
  into adjacent literals separated by whitespace, not a comma:

  ```cpp
  R"TAG_A(…first half…)TAG_A" R"TAG_B(…second half…)TAG_B"
  ```

  A comma after a designated initializer is C7556; a space between adjacent
  literals is simple concatenation.
- **The rule bootstrap auto-inserts `ruletypes.h` defaults at world boot.** The
  live `Custom:CurioTraps` row was created by the bootstrap on 2026-11-03
  ("Adding new rule … value [true]"), not by the migration. Fingerprint the
  `notes` text to tell a bootstrap row from a migration row; `ON DUPLICATE KEY
  UPDATE rule_value` does not update the notes.
- **Concurrent sessions race the version counter.** Re-grep the manifest's max
  `.version =` immediately before appending, and bump `common/version.h` in the
  same step. Two sessions that both read 361 will both try to write 362.
- **A skipped migration is still stamped.** Once `db_version.custom_version`
  passes an entry, the runner will not revisit it. A payload lost to an
  inverted gate is permanently lost unless it is re-issued as a later version
  or applied from the idempotent twin.

## Status and verification checklist

### Shipped

| Item | State |
|---|---|
| `20261103_curio_traps_v316.sql` | In tree; manifest gate `empty`; 12 VP rows live |
| `20261104_throne_of_the_first_brood_v331.sql` | In tree; manifest gate `empty`; 7 VP rows live |
| `20261104_poair_curio_props_v361.sql` | In tree; 309 rows; manifest gate `not_empty`; **0 rows live** |
| `20261104_poair_curio_props_v332.sql` | Dead twin; no manifest entry (332 is the VT shard-rate migration) |
| `veeshan/player.pl`, `poair/player.pl` | In tree and in the runtime quests tree |
| `Custom:CurioTraps` | Compiled default `true`; live value `true` |
| Authored traps that can fire | **None** |

### Verified

- The live database has 19 VP rows in the trap bands (601–612, 621–630) and 0
  poair rows in 601–909.
- `doorid` is `uint8` in `Doors`, `Door_Struct`, `ClickDoor_Struct`, and
  `FindDoor`; the 601+ rows narrow to 89–118 at load.
- The poair extractor reproduces 309 props from `poair.s3d` and matches all five
  calibration locations.
- Spell `7261`, `7536`, `8562`, `987`, `1415`, `80`, `177`, and item `4504`
  resolve to the names in the table above.

### Owed

1. **Renumber into ≤ 254.** Veeshan's Peak has 19 authored traps and 82
   distinct stock ids (all of which also exist at `version = 100`). The free ids
   are the gaps in the stock 0–239 set; check each candidate against both door
   versions before using it, and re-check the whitelist constants in both
   `player.pl` files.
2. **Decide Plane of Air.** 309 props cannot all be doors under a byte. Pick the
   named curios only, or use a non-door trigger. The 309-row v361 payload is not
   usable as shipped even if its gate is fixed.
3. **Fix or retire the v361 gate.** If the payload is kept, change
   `.condition` to `empty` and re-issue it as a new version (361 is already
   stamped). Re-grep the manifest max before choosing the number: the
   working-tree manifest max is 369 and the live custom version is 368. If not,
   retire both the v332 and v361 twins and document the decision here.
4. **Settle the heading axis.** Compare `rot[0]` and `rot[2]` against an in-game
   duplicate; apply the `512 - heading` flip only to the band that needs it.
5. **Test without a restart.** Use `#reload doors` after a row change and
   `#reloadquest` after a script change. Record the door id the handler actually
   receives (the truncated one), not the id in the SQL.
6. **Regression pass:** Phara Dar seal doors `56`/`57`; poair rainbow door `1`
   and its key `28638`; poair exit book door `2` (potranquility); poair pad door
   `21`; the stock VP hoard doors `162–206` (which are intentionally trapped).

### What a correct test looks like

```sql
-- 1. Are the rows loaded at a door id the protocol can carry?
SELECT doorid, name FROM doors
 WHERE zone = 'veeshan' AND doorid BETWEEN 601 AND 630;
-- expect 19 rows, all of which are wrong (601 > 255)

-- 2. What does the handler see? Add a temporary quest::say($doorid) or
--    watch the zone log for "Door [NN] client handle" after a click.

-- 3. Did the payload land at all?
SELECT COUNT(*) FROM doors WHERE zone = 'poair' AND doorid BETWEEN 601 AND 909;
-- currently 0
```

## Files

- `Release-NMS-Server/utils/sql/20261103_curio_traps_v316.sql`
- `Release-NMS-Server/utils/sql/20261104_throne_of_the_first_brood_v331.sql`
- `Release-NMS-Server/utils/sql/20261104_poair_curio_props_v332.sql` (dead twin)
- `Release-NMS-Server/utils/sql/20261104_poair_curio_props_v361.sql`
- `Release-NMS-Server/common/database/database_update_manifest_custom.cpp`
- `Release-NMS-Quests/veeshan/player.pl`
- `Release-NMS-Quests/poair/player.pl`
- `tools/poair_statics.py`
- `tools/gen_poair_traps_v332.py`
- `tools/split_manifest_literals.py`
