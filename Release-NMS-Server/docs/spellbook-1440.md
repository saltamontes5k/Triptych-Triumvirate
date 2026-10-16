# Spellbook 720 → 1440 (RoF2) — what changed and where

Port of https://github.com/thezerodivide/SpellbookSizeUpdate (doubles the RoF2
client spell book from 720 to 1440 slots / 90 to 180 pages). Read this before
touching anything spellbook- or profile-related: several constraints below are
invisible in the source.

## The compatibility contract

**The server and every client must be patched together.** The spell book rides
in the player profile; a patched server sends a 1440-entry book that an
unpatched client cannot parse (it stops reading mid-profile and fails to enter
the world), and a patched client against an unpatched server fails the same
way. The server cannot tell clients apart. Clients get the book binary patch
described below — there is no version negotiation.

## Server (this repo)

- `common/patches/rof2_limits.h` — `SPELLBOOK_SIZE = 1440`. Everything
  (scribe/memorize/swap, profile encode in `rof2.cpp`, `PlayerProfile_Struct`,
  DB load/save via `CharacterSpellsRepository`) follows the constant. **Never
  wholesale-replace this file from upstream**: it carries EQS-custom constants
  (`SAY_LINK_BODY_SIZE = 77`, `MAX_BAZAAR_TRANSACTION`, `BONUS_*_END`).
- `common/patches/rof2.cpp` `BuildShroudProfileBlock()` — the shroud profile
  block mirrors the client's FIXED in-memory shroud layout (spell book at
  0x1ABC..0x25FC, mem-spells at 0x25FC, refresh at 0x263C, buffs at 0x2674).
  The loop is deliberately capped at **720** entries: the shroud block does not
  grow with `SPELLBOOK_SIZE`, and writing 1440 dwords would stomp the shroud
  form's gems and buffs. Slots 720+ simply don't render while shrouded.
- `zone/client.cpp` `GetScribeableSpells` / `GetLearnableDisciplines` — counters
  are `uint32`. **`SPDAT_RECORDS` is the spell-array size (max spell id + 1),
  not the row count**, and it is 122,101 because custom spells live at ids
  121,860+. Any `uint16` loop bounded by `SPDAT_RECORDS` spins forever when the
  counter wraps at 65,535 — the zone main thread pins a core, the log goes
  silent, the process survives (so eqlaunch never respawns it) and every client
  on that zone hangs. This is what the first `#scribespells` run hit. Audit for
  this pattern before adding spell-id loops.
- Database: no migration. `character_spells.slot_id` is `smallint unsigned`
  (fits 0..1439). The array is sparse — empty slots are `0xFFFFFFFF`.

## Client binary (NOT in this repo)

The eqgame.exe patch moves the spell book array out of `_CHARINFO2` to a tail
block at +0x9950, grows the character object allocation to 0xAFD0, raises the
page limit 90→180, re-points ~115 call sites, and appends a `.sbook` PE
section. Produced with the upstream patcher (`tools/patcher/patch-eqgame.js
--4gb`) against the 4GB-patched stock RoF2 client; the upstream-referenced md5s
are input `389709ec…` → output `f10534e3ae4ebe64f6dc9d56459c8ecd`
(byte-identical to the upstream-tested build). Live copies and backups:

- Live client dir (`C:\games\EQTriune`): patched `eqgame.exe`; originals kept
  as `eqgame_4gb_720.bak.exe` and `dinput8.pre1440.dll`; `testeqgame.exe`
  (md5 `240c8080…`) is the pristine stock client kept as an unpatched
  reference — it is expected to FAIL to zone in against the patched server.
- The binary patch list with per-site bytes: upstream repo
  `evidence/patch-list.txt` (clone kept at `tmp/SpellbookSizeUpdate`).

## dinput8 (Release-NMS-Client/eqgame_dll)

No hook collisions with the binary patch (all dll hooks are hardcoded RVAs
elsewhere; the two `CSpellBookWnd` call targets keep their entry addresses).
Struct side: `EQData.h` `NUM_BOOK_SLOTS` is `0x5a0` and the book is read via
`CHAR_SPELLBOOK(pc, n)` at object tail +0x9950 — the old `0x2520` field is
retired (`OldSpellBook_UNUSED`). Consumers: the spell datatype search and
/memspell only. Rebuild with
`MSBuild eqgame_dll.sln -p:Configuration=Release -p:Platform=Win32
-p:PlatformToolset=v143 -p:WindowsTargetPlatformVersion=10.0.22621.0`
(box has no v141 SDK). `ClientFiles/dinput8.dll` is gitignored — staging is
disk-only; keep live, `Release\` and `ClientFiles\` in sync.

## UI (live dir is authoritative: C:\games\EQTriune\uifiles)

Page-number labels (`SBW_LeftPageNum` / `SBW_RightPageNum`) were 20px wide in
most skins, so pages 100–179 rendered as two digits. Widened for 3 digits,
re-centered per skin: `default` via the upstream script (X 127/340, CX 40);
manual values for Bigzz_NMS_UI 5/40+224/40, Blue 0/36+168/36, gearcore and
shinsparxx 0/40+209/38, sneaky_defiance_ui 161/54+559/54. Per-skin originals
kept as `EQUI_SpellBookWnd.xml.orig-720`. `nms_ui` has no spellbook XML and
inherits `default`. The six edited files are mirrored into
`Release-NMS-Client/ClientFiles/uifiles/<skin>/` (tracked) so future client
bundles keep the fix — **the live dir remains the source of truth**.

## Rollout / rollback

Cutover order (used 2026-10-11): stop servers → back up binaries and
`character_spells` → rebuild → swap client exe/dll → restart. The DB dump and
binary backups from that cutover live in `tmp/spellbook-cutover/`. Rollback =
restore old binaries + old `eqgame.exe` + the dump; slots ≥720 are invisible
to old binaries and harmless. `start-servers.bat` does not work headless —
start each exe via nohup with the bundled perl PATH (see restart-zones.bat).

## Verification status

Verified working: zone boots with achievements loading, level/proficiency
achievement completions, client login + zone-in with the patched exe, in-game
achievement flows. Playtester pass still owed: fill book past 720, `/book 179`
and 3-digit labels per skin, memorize/cast from slot ≥720, camp/relog
persistence, zone with the book open, shroud form entry, LoN + say-links after
the dll rebuild.
