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
