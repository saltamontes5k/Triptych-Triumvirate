# Quest Script Audit - 2026-10-12

Full-tree audit of `Release-NMS-Quests` (4,803 .pl / 5,337 .lua at audit time) for
obviously broken quest scripts, plus a fix pass for everything confirmed broken.
Triggered by Crescent Reach tradeskill masters answering hails with recipe text
instead of a greeting.

## Method

- **Syntax:** `perl -c` on every .pl with the bundled server perl (5.24.4, engine
  parity) and a `loadfile()` check on every .lua with the engine's luajit.
- **Dead handlers:** every `sub EVENT_X` / `function event_x` diffed against the
  engine's actual dispatch tables (`zone/embparser.cpp` `QuestEventSubroutines[]`
  for perl, `zone/lua_parser.cpp` `LuaEvents[]` for lua). A handler whose name is
  not in the table never fires.
- **Plugin refs:** every `plugin::X(` resolved against subs actually defined in
  `quests/plugins/*.pl` (the engine loads every .pl there into `package plugin`).
- **Drift:** live tree (`Build/bin/Release/quests`) vs source; pl+lua shadow-pair
  scan (lua wins by extension order, matching `quest_parser_collection.cpp`).
- Raw data: `tmp/quest_audit/` (audit_static.json, syntax_perl.json, syntax_lua.json).

## Summary

| Category                        | Count | Action |
|---------------------------------|-------|--------|
| CR hail clobbered by task text  | 27 NPCs | **fixed** (generator + regen) |
| Dead handlers (typo/wrong name) | 12 files | **fixed** |
| Hard syntax errors              | 10 files | **fixed** |
| Missing plugin functions        | 4 files | 2 **fixed**, 2 report-only |
| pl+lua shadow pairs             | 573 | report-only |
| Live-only (stale) scripts       | 157 | report-only |
| Zero-byte scripts               | 26 | report-only |
| False positives triaged away    | ~2,430 | none |

Post-fix lint: 0 perl syntax failures (was 12), 0 lua syntax failures (was 2),
unknown handlers 19 -> 9 (the 9 left are local helper subs / framework
callbacks, not engine events), missing-plugin files 7 -> 3 (the 3 left are
commented-out debug hooks and one orphaned script, see below).

## 1. Crescent Reach: greeting clobbered by task text (the reported bug)

**Root cause:** `tools/gen_tss_cr_bm_completion.py` (SoF content commit `7c14c0b39`)
authored a greeting line (`voice`) for every generator-written NPC but its
`npc_script()` emitter never wrote it, so a first hail fell straight into the
"Simple <item>" task-offer text. Every generator-written NPC was affected: the
10 Artisans' Row / tradeskill masters in `crescent/`, the library/tinkering/
training givers, and the 9 Blightfire Moors quest givers in `moors/`.

**Fixed in the generator** (note: `tools/` is gitignored, so the generator fix is
local-only): `npc_script()` now emits the header comment block and the greeting
as the first hail line before the task-state logic; the duplicate
`plugin::return_items` (the `handin()` body plus the emitter's own line) is gone;
the dead `script()`/`ts_script()` emitters were removed.

**Regenerated** all 33 generator-written scripts (diff = header + greeting line +
return_items dedupe per file; task data and the SQL are byte-identical). The
three side-task NPCs (Moonreader Ewera, Dreamseeker Ellowind, Whisperwalk
Maroline) got their greeting the same way.

**Bonus fix:** Fletcher Tahirah's task 600580 was *unassignable* - the offer
linked `[branches]` but the handler only matched `/carving/i`, so clicking the
saylink did nothing. Keyword and voice line now agree on `[branches]`.

## 2. Dead handlers - events that could never fire

Handler names checked against the engine dispatch tables. Canonical spellings in
this engine: perl `EVENT_ITEM` (not `EVENT_TRADE`), `EVENT_ENTERZONE` (not
`EVENT_ENTER_ZONE`), `EVENT_ITEM_ENTER_ZONE`, `EVENT_SPELL_EFFECT_CLIENT/_NPC`;
lua `event_trade` (not `event_item`), `event_signal`, `event_enter_zone`.
Lua has `event_enter_zone` while perl has `EVENT_ENTERZONE` - they differ.

| File | Was | Now | Player-visible effect before the fix |
|------|-----|-----|--------------------------------------|
| thevoid{a..g}/47875{0..6}.pl (7 files) | `--` lua-style comment header on a perl file | `#` | **All 7 SoD Void Loremaster NPCs (Rk. III spell unlocks) never compiled - dead since the SoD miscProgression commit** |
| cshome/player.pl | `EVENT_TRADE` | `EVENT_ITEM` | ssf-key instance handin dead |
| global/items/CHRMTimeInZone2.pl | `EVENT_ITEM_ENTERZONE` | `EVENT_ITEM_ENTER_ZONE` | item init handler dead |
| guildhall/player.pl | `EVENT_ENTER_ZONE` | `EVENT_ENTERZONE` | guildhall zone controller enter logic dead |
| kerraridge/player.pl | `EVENT_ENTER_ZONE` | `EVENT_ENTERZONE` | Marl Kastane Truespirit spawn dead |
| lavastorm/v0/player.pl | `EVENT_ENTER_ZONE` | `EVENT_ENTERZONE` | v0 shunt/reroute on zone-in dead |
| global/spells/11574.pl | `EVENT_SPELL_EFFECT` | `EVENT_SPELL_EFFECT_CLIENT` | fae-dust release activity dead |
| abysmal/#Verna_Abella.lua | `event_singal` | `event_signal` | signal dialogue dead |
| erudnint/Barodreth_Firefingers.lua | `event_item` | `event_trade` | Dagger of the Craft Keeper turn-in dead |
| hohonorb/Lord_Mithaniel_Marr.lua | `event_item` | `event_trade` | Marr artifact turn-in dead |
| mechanotus/player.lua | `event_load` (not an engine event) | `event_enter_zone` | Spy Reports task 300036 observation timer never started |

## 3. Syntax errors - scripts that never compiled

- `cabeast/keytest.pl` - missing operator in `say("..." $expansion)`.
- `global/Zapf.pl` - `summonitem(1$prizes)`; plus `$status => 80` (fat-comma,
  always true) -> `>=`, so the GM-only `Train` path was reachable by anyone
  typing "train".
- `global/Other_Elvish_Security_Officer.pl` - file was a paste disaster
  (truncated reward-picker fragment spliced mid-file, duplicated handlers,
  dangling fragment at EOF); rewritten clean from its own intact parts.
- `cazicthule/1500000200.pl` - `use strict` without declaring engine globals;
  the Revamped Cazic-Thule expedition NPC never loaded. Added
  `our ($client, $npc, $text, $instanceversion);` (same pattern as the other
  strict scripts).
- `poknowledge/A_Planar_Projection.lua` - `}.` instead of `},` at line 159; the
  PoK Planar Projection (PoP flag-gate greeter) has been silent.
- `jaggedpine/encounters/jpfwar.lua` - missing `end` (an `elseif` chain nested
  one level too deep); the Jaggedpine war encounter never loaded.

## 4. Plugin fixes

- `kodtaz/Tublik_Narwethar.pl`, `paineel/#Avatar_of_Terror.pl`:
  `plugin::returnitems` -> `plugin::return_items` (undefined sub aborted the
  whole EVENT_ITEM after items were consumed).
- **New `Release-NMS-Plugins/check_mq_handin.pl`** (clean-room, call contract
  taken from the callers): `rathemtn/Hasten_Bootstrutter.pl` (Journeyman Boots)
  and `qeytoqrg/Guard_Cheslin.pl` (illusion cards) call `mq_process_items` /
  `check_mq_handin`, which did not exist anywhere - those EVENT_ITEM handlers
  died after consuming the items. Credits multi-quest progress per NPC type id
  in process memory; consumed on successful payout.
- Plugin sources live in `Release-NMS-Plugins/` (61 files, versioned, synced to
  `quests/plugins` by `Sync-Quests.ps1`). Note for future readers: in this
  engine `plugin::return_items` is an intentional no-op stub -
  `$npc->CheckHandin` auto-returns unmatched items - so the double
  `return_items` calls the generator used to emit were harmless cosmetics.

## 5. Report-only findings (no action taken)

- **`global/#TPTriggerG.pl`** calls `plugin::update_zone_entry(...)` which is
  defined nowhere and read by nothing; no TPTrigger NPCs are spawned in the DB.
  Orphaned write-path of an unfinished system - delete or finish it someday.
- **Blessing debug calls** (`BlessingDebugPassword/Toggle`) are commented out in
  both Blessing of the Gods scripts - flagged by the scanner, not a bug.
- **573 pl+lua shadow pairs** (same basename in one zone dir; lua shadows pl).
  471 flagged by a size/handler heuristic, which is noisy across languages -
  treat as a to-review inventory, not a defect list. Full list in
  `tmp/quest_audit/audit_static.json`.
- **157 live-only scripts** (robocopy sync never deletes; e.g.
  `kithicar/#Void_Defense_Controller.pl`, `crescent/Jilian_Florantine.pl`,
  DoN camp scripts). Stale code still being served from the live dir; reconcile
  deliberately rather than bulk-deleting. Full list in the appendix.
- **26 zero-byte scripts**, mostly `player.pl`/`player.lua` placeholders (benign
  by convention). NPC-named ones (e.g. `guildhall/#Porter.pl`,
  `butcher/Guard_Gonin.lua`, `global/Priest_of_Discord.lua`) are silent NPCs.
- **24 "mixed language" flags** are commented-out legacy code or `$name` inside
  say-strings - noise, no action.

## Verification

- `perl -c` (bundled 5.24.4) on every changed .pl: clean.
- luajit `loadfile()` on every changed .lua: clean.
- Generator re-run is idempotent; task/SQL output byte-identical to pre-audit.

## Deploy

`Release-NMS-Deploy/build-scripts/Sync-Quests.ps1` copies quests and plugins
source -> live; then `#reload quest` in game picks up script and plugin
changes (per the sync script's own docs). If anything plugin-related misbehaves,
a zone restart re-initializes the plugin package from scratch.

## Appendix: live-only scripts (157)

Present in `Build/bin/Release/quests` but not in source. Not deleted - reconcile deliberately.

- `acrylia/encounters/burrower.lua`
- `acrylia/the_vile_statue.lua`
- `crescent/Jilian_Florantine.pl`
- `gfaydark/Elder_Ritualist_Longshadow.pl`
- `gfaydark/Skinwalker.pl`
- `gfaydark/a_revealed_skinwalker1.pl`
- `gfaydark/a_revealed_skinwalker2.pl`
- `gfaydark/a_revealed_skinwalker3.pl`
- `global/Dulia_Jestes.lua`
- `global/spells/122100.pl`
- `halas/Lebounde_ab_Dolmen.lua`
- `highpasshold/TSS_Porter.lua`
- `kithicor/#Void_Defense_Controller.pl`
- `kithicor/A_Silly_Puppet.pl`
- `kithicor/Cathil.pl`
- `kithicor/The_Legion_Commander_of_the_Void.pl`
- `kithicor/a_void_bloodmage.pl`
- `kithicor/a_void_legionnaire.pl`
- `kithicor/a_void_ravager.pl`
- `korascian/476041.pl`
- `korascian/478739.lua`
- `korascian/478760.lua`
- `nektulos/DoD_Porter.lua`
- `oceangreenhills/478738.lua`
- `oceangreenhills/478758.lua`
- `oceangreenvillage/467069.pl`
- `oldkithicor/456172.pl`
- `oldkithicor/456175.pl`
- `plugins/ArcheryAttack.pl`
- `plugins/DiaWind.pl`
- `plugins/Doors_Manip.pl`
- `plugins/Instances.pl`
- `plugins/MP3.pl`
- `plugins/Multiple_QGlobals.pl`
- `plugins/MySQL.pl`
- `plugins/NMS_custom_events.pl`
- `plugins/NMS_general.pl`
- `plugins/NMS_instance_utils.pl`
- `plugins/NMS_item_utils.pl`
- `plugins/NMS_multiclass_utils.pl`
- `plugins/NMS_popup_utils.pl`
- `plugins/NMS_progression_utils.pl`
- `plugins/NMS_seasonal_utils.pl`
- `plugins/NMS_slayer_utils.pl`
- `plugins/NMS_sod_rk3_data.pl`
- `plugins/NMS_sod_utils.pl`
- `plugins/NMS_soulmark_utils.pl`
- `plugins/NMS_title_utils.pl`
- `plugins/Quest_Credit.pl`
- `plugins/Quest_Credit2.pl`
- `plugins/Task_Utils.pl`
- `plugins/TriuneOfFate.pl`
- `plugins/anim.pl`
- `plugins/ascendant_april_fools.pl`
- `plugins/ascendant_gambling.pl`
- `plugins/ascendant_insight_trainer.pl`
- `plugins/ascendant_philanthropist.pl`
- `plugins/ascendant_tome_translator.pl`
- `plugins/check_handin.pl`
- `plugins/check_hasitem.pl`
- `plugins/client_functions.pl`
- `plugins/client_messages.pl`
- `plugins/constants.pl`
- `plugins/default-actions.pl`
- `plugins/default.pl`
- `plugins/deity_blessings.pl`
- `plugins/directional.pl`
- `plugins/formation_tools.pl`
- `plugins/globals.pl`
- `plugins/group_utility.pl`
- `plugins/guildmasters.pl`
- `plugins/illusion_tools.pl`
- `plugins/mob_utils.pl`
- `plugins/notd.pl`
- `plugins/npc_extras.pl`
- `plugins/npc_tools.pl`
- `plugins/path_tools.pl`
- `plugins/popup_window_utils.pl`
- `plugins/random_message.pl`
- `plugins/random_utils.pl`
- `plugins/rathunt.pl`
- `plugins/rejection.pl`
- `plugins/soulbinders.pl`
- `plugins/spawn_utils.pl`
- `plugins/text_formatting.pl`
- `plugins/time_tools.pl`
- `plugins/utility.pl`
- `plugins/weapon_tools.pl`
- `plugins/zone_tools.pl`
- `pojustice/Al-Corisalm.lua`
- `pojustice/Alkus_McNeeson.lua`
- `pojustice/Aneya_Mallar.lua`
- `pojustice/Archpriest_Del-Maque.lua`
- `pojustice/Baxo_Numbalin.lua`
- `pojustice/Bimlee_Mellswar.lua`
- `pojustice/Captain_Nyra.lua`
- `pojustice/Drazl.lua`
- `pojustice/Dremekal.lua`
- `pojustice/Dumann_the_Quick.lua`
- `pojustice/Elzabetha_Ianthe.lua`
- `pojustice/Evia_N-Cizai.lua`
- `pojustice/Genni_Dulzane.lua`
- `pojustice/Golikan.lua`
- `pojustice/Grum.lua`
- `pojustice/Guardian_Ionew.lua`
- `pojustice/Gubkuk.lua`
- `pojustice/High_Shaman_Dannal.lua`
- `pojustice/Iyalinaoukh.lua`
- `pojustice/Jhyric_Kan_Voth.lua`
- `pojustice/Kimry_Joolimel.lua`
- `pojustice/Klaren_Dunn.lua`
- `pojustice/Kuraal_Nem_Azmih.lua`
- `pojustice/Lasiya.lua`
- `pojustice/Librarian_Rushal.lua`
- `pojustice/Master_Vhezar.lua`
- `pojustice/Moobik.lua`
- `pojustice/Mublok.lua`
- `pojustice/Nemli.lua`
- `pojustice/Quillon.lua`
- `pojustice/Ra-Silyas.lua`
- `pojustice/Rhionn_Leafsblade.lua`
- `pojustice/Royal_Guardian_Finro.lua`
- `pojustice/Shaldyn_Thunderhoof.lua`
- `pojustice/Sheyna_D-Leen.lua`
- `pojustice/Sister_Tomyn.lua`
- `pojustice/Tamsin.lua`
- `pojustice/Tamyna_Willowsong.lua`
- `pojustice/Thrak_Riftwing.lua`
- `pojustice/Trader_Sha-Deno.lua`
- `pojustice/Trazin_D-Feyl.lua`
- `pojustice/Trisha_Pettals.lua`
- `pojustice/Vulur_Stonehold.lua`
- `pojustice/Welas_Hollander.lua`
- `pojustice/Wraith_of_Domagr.lua`
- `pojustice/Wurgoz.lua`
- `pojustice/Yalaki.lua`
- `pojustice/Yventa_Va-Ssula.lua`
- `pojustice/Zakis_Var_Sl-tad.lua`
- `pojustice/Zayenaekk.lua`
- `poknowledge/Edmund_Strangeways.pl`
- `poknowledge/Illis_Taberish.pl`
- `poknowledge/Rhaeda_Evel.pl`
- `potimea/478757.pl`
- `potorment/#Argan_Milek.pl`
- `potorment/Argan_Milek_2272.pl`
- `rivervale/Artisan_Bill_Whistletop copy.lua`
- `southro/PoR_Porter.lua`
- `steamfont/SoF_Porter.lua`
- `stillmoonb/encounters/reflections_of_silver.lua`
- `thevoida/459000.pl`
- `thevoidb/460000.pl`
- `thevoidc/461000.pl`
- `thevoidd/462000.pl`
- `thevoide/463000.pl`
- `thevoidf/464000.pl`
- `thevoidg/465000.pl`
- `tox/TBS_Porter.lua`

Live-only non-script files: `plugins/.gitattributes`, `plugins/README.md`, `task_sql/dodh_access.sql`
