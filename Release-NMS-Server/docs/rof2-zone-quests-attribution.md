# RoF2 zone quest content — source attribution

The Rain of Fear zone quest content shipped in migrations v302-v311
(Blightfire Moors, Stone Hive, Goru'kar Mesa, Shard's Landing, Crescent
Reach) is a verbatim port of the reconstruction published at
https://github.com/nightstalker6669/eqemu-rof2-achievements (commit 334a0e2),
which reconstructs the retail May-2013-era zone quest lines from historical
sources documented in that repository's per-package provenance JSONs.

That repository is GPL-3.0 licensed (LICENSE inherited from its pinned EQEmu
upstream base, commit c9c8747). Its engine patch series (0002-0009) was
already present in this tree before the port; the only engine additions made
here are two Lua client bindings mirroring existing Perl bindings
(GetZoneInstanceVersion, GetTaskActivityDoneCount).

Local adaptations made during the port, all documented in the affected twin
files under `utils/sql/20261101_rof2_*.sql`:

- blightfire-bixies: the five thrall spawn points normalized to chance=100
  (our import had them at 50).
- stonehive: the ground-spawn guard accepts our `Bixie_War_Plans` naming
  where the reconstruction expects `IT63_ACTORDEF`.
- mesa: the catalogue pre-guard accepts enabled=0 on first-time import and
  allows our two retail progression-lock component rows (component 7014);
  their missing .300 Serpent tuple added.
- spirits: the `prior_akins` guard's prerequisite tasks are seeded before
  apply (the reconstruction's own file then replaces them wholesale).
- giver scripts: where this server's live TSS/custom chains existed on the
  same NPCs, the retired scripts were folded into the reconstructed givers
  (see the v302-v311 commit messages for the per-NPC list). Task rows of
  retired broken duplicates (600030-600104, 600242-256, 600577 and friends)
  remain in the database for completion history but are no longer obtainable.

## Second wave — migrations v335-v346 (2026-11-05)

Migrations v335-v346 port the expansion of the same author's work, now
published at https://github.com/nightstalker6669/EQEmu branch
`rof2-achievements` (same GPL-3.0 license, pinned EQEmu base c9c8747 plus
its nine-patch series, all already in this tree). Packages ported:
mesa-remaining (36 quests/277 activities/27 recipes), Blackfeather Roost,
Short Sharp Sting, Mesa centaur chain + corruption, Mesa Bring Friends,
Mesa Save the Queen, Steppes, Sunderock Springs, Vergalid Mines,
Dragonscale Hills, oculus-task-leaves (criteria bindings) and the Alaran
language training addition to shards-landing. All content is SQL/Lua;
no engine changes were needed.

Local adaptations, documented in each `utils/sql/20261105_rof2b_*.sql`
twin header:

- Catalogue guards widened to accept `enabled` 0-or-1 preimages (our stock
  lineage rows sit disabled; the upserts set 1) and to skip our retail
  progression-lock component rows (component 7014).
- normalize-before-guards blocks where our stock rows drifted from the
  reconstruction preimage: the 21 Fantoma wolf-pool spawn chances (50 to 100),
  five Roost royal-trinket ground spawns (collector name, 300s timer), the
  Shade of Corruption profile and spawn timer (researched level-55 group
  values), the Vergalid chest npc regen/aggro/faction and the
  Skullrend/Vuryn spawn chances (50 to 100).
- 25 stock brew/craft duplicate recipes for the May-2013 Mesa items
  (930423, 930619, 930620, 930621, 930628, 930629, 931771, 932871-3,
  933775-6, 933782, 935701-3, 939561-2, 939564, 939566-71) retired in
  favor of the researched overlays 3041001-3041027.
- Sunderock: the six npc update targets and the courier loot routes reset
  to their staged before-images so the guarded overlays apply; the
  sting/bixie faction guards accept our wildlife faction 1520000047.
- Steppes: the two encounter-actor npc ids colliding with our own custom
  npcs (Voltak_Shadethorn 399900, Wendel_Skyreach 399901) remapped to
  399911/399912 in the SQL, the encounter config lua and the actor
  dispatch scripts; the six pickup ground rows aligned to the staged
  shapes.
- Dragonscale: spawnentry groups reset to the staged before-images; npc
  rows overlaid from the restoration staging; each faction-guard npc set
  to an accepted faction value. Sunderock drops its per-file session-var
  resets so the activation guard sees them.
- Their fork-only `housing_disable_rotation`/`housing_disable_free_placement`
  item columns have no counterpart in our schema; those two terms were
  dropped from full-row item preimages (all remaining columns compare).
- Parent achievements are enabled by the twins (upstream's DB carried
  them enabled from earlier steps our flow does not reproduce); the
  Mesa 20th capture quest and its criteria stay disabled as upstream
  ships them.
- Script-side compositions (folds of our live content into the
  reconstruction's dispatchers): the seven TSS Roost giver scripts
  (Adrian 398022, Lucian 398023, Coryn 398029, Fenith 398018, Dorinda
  398039, Mestle 398047, Ashrana 398070) and the twelve SoF faction-task
  givers in Dragonscale Hills (442013-442182) keep their original
  dialogue and task offers alongside the reconstruction's routes; zone
  player.lua scripts (moors, stonehive, mesa, roost, steppes, sunderock,
  vergalid, dragonscale) carry the global-player hook chains that we
  cannot install as a global lua (our global_player.pl is load-bearing);
  per-NPC actor dispatch scripts replace the upstream composed global
  npc handler for the save-queen guards/protectors, centaur corruption
  population, steppes/sunderock/vergalid encounter actors.
- The shards-landing partisan module (shards_partisan.lua +
  shards_partisan_config.lua) is now installed on the lua_modules path
  with the Alaran masters; the v310 twin had shipped shardslanding
  player.lua requiring it without the module present (dead require since
  ship, fixed here). The Alaran rare drop chances are operator-chosen
  upstream; 5 percent adopted for both.
