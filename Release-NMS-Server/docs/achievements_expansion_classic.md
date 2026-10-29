# Classic expansion achievements: Kunark / Velious / Luclin / Planes of Power

Batch record for manifest entries **238-255** (2026-10-25), twin
`utils/sql/20261025_achievements_expansion_classic.sql` (+ `_rollback`).

## What shipped

The four classic expansion achievement trees were brought live out of the
already-imported live-EQ definitions (categories Ruins of Kunark 200, Scars of
Velious 300, Shadows of Luclin 400, Planes of Power 500):

| Outcome | Count |
| --- | ---: |
| Newly enabled with criteria | 202 |
| Already enabled, kept (accepted partials) | 4 |
| Deferred (stay disabled, reported) | 75 |
| Excluded: duplicate-name key rows / temporary Quarm row | 19 / 1 |
| New criteria (explicit ids 7000000-7000572) | 573 |
| New claimable reward sets (9508000-9508205) / rewards (9540000-9540411) | 206 / 412 |

All 99 Exploration achievements, 49 of 81 Hunter, 50 of 57 Raids, the
Explorer metas and Conqueror of Kunark are live. Per-achievement outcomes and
deferral reasons: `docs/achievements_expansion_classic_deferred.csv`.

## Method

- Baseline criteria were generated with the existing importer
  (`utils/scripts/import_achievement_resources.py`, kunark-through-pop
  profile, `--preserve-enable-state`): 300 definitions, 1,191 criteria
  (99 traveler, 234 dependency, 858 named-kill). Its reviewed NPC/zone
  mappings are authoritative; nothing was re-derived.
- A strict filter then kept only criteria that resolve against this server's
  data: zone-enter needs a live `zone` row, name-kill needs a canonical FNV-1a
  hash match in `npc_types` (static spawns NOT required), own-item needs the
  item, task criteria need the task id, and achievement-complete needs the
  dependency enabled (resolved to a fixpoint, so metas follow their children).
  An achievement enables only when every required state-bearing component has
  at least one resolving criterion. Manual (event-0) components defer.
- Reward policy follows the 10-16 convention: AA = max(1, points/10) plus a
  coin component, one single-option "Claim rewards" set per achievement
  (never `reward_source_entries`; the automatic lane is retired). The coin
  component shipped as points/2 platinum (amount = points x 500 copper) and
  was swapped on 2026-10-28 to a flat 5 Triunes of Fate (alternate currency
  6, item 46779): the expansion block via manifest entry 259, and all
  remaining achievement-sourced copper rewards — the entry-220 claimable sets
  and the Trailblazer coin purse — via manifest entry 260
  (`20261028_achievements_triune_all_rewards.sql`). Every claimable
  achievement coin slot now pays 5 Triunes of Fate. The platinum values of
  the 8 converted rows live in `nms_ach_copper_triune_backup` until that
  file's rollback runs; claimed Triunes are never clawed back.

## Decisions on record

- The 19 disabled live key rows that duplicate enabled custom Keys-category
  achievements (Trakanon Idol, Key to Charasis, the PoP keys, ...) were
  skipped; the custom rows stay canonical.
- 352640 Conqueror of The Plane of Mischief was disabled: its only criterion
  targeted nonexistent zone 526 and its named NPCs are absent, so it could
  never complete. It had zero character progress.
- 250880 / 415440 / 415840 / 520440 (previously enabled, one absent kill each)
  stay enabled as documented accepted partials.
- The 13 event-0 manual criteria (4 PoP Progression keys without items, 9 PoP
  raid phase rows) were left inert and in place.
- Exploration rewards are separately togglable: the
  `Achievements:ExplorationRewards` rule (default on) gates reward delivery
  for every zone-enter-only achievement, so an operator who finds "an AA for
  zoning in" too generous can withhold just those rewards while the
  achievements keep tracking and awarding points.

## Prerequisite (not reproducible from the repo alone)

The imported definition set is loaded into `peq` out of band; the migration
chain does not create it. A fresh restore needs, before this batch is
meaningful: the client resource snapshot
(`C:/games/EQTriune/Resources/Achievements`, sha256 prefixes:
AchievementsClient `586bbacd721bb4aa`, AchievementComponentsClient
`a5c0410014cbbf44`, AchievementCategories `781086ad569cbc16`,
AchievementCategoryAssociationsClient `d2888dcee5208484`,
AchievementAssociationsClient `92b0700f94cc10ef`) imported via
`utils/scripts/import_achievement_resources.py` with its own enable
selection, or a `release-peq.zip` snapshot already carrying the imported
rows.

## Pre-existing issues found (not touched here)

- 15 enabled achievements with claimable sets but no completable criteria
  (1749150-1749168, an earlier batch's missions) — reward sources exist
  yet nothing can complete them.
- 9 enabled task-complete criteria outside these expansions target task ids
  that do not exist in `tasks`.
- 20 imported kill criteria are group labels/verified mappings whose hashes do
  not match any single NPC name; correct by design, do not rehash.

## Verification

SQL canaries (all eight assertion classes) returned zero on the live database
after application, and again after the server boot; the boot ran manifest
entries 238-255 through the binary (custom_version 237 -> 255) and every zone
loaded the replacement snapshot (a failed load refuses to start the zone;
all zones stayed up). Entry 259 ran at the next boot (custom_version 259):
zero copper rows remained in the 9540000-9540411 block. Entry 260 ran at the
2026-10-28 evening boot (custom_version 260): zero achievement-sourced copper
rewards remain anywhere, 214 rewards pay alternate currency 6, and the 8
original platinum values sit in `nms_ach_copper_triune_backup`. In-game
checklist: the four expansion tabs render in the achievement window, a
zone-enter Traveler step ticks on entry, a raid kill credits its step, and
the Choose/claim flow delivers AA + 5 Triunes of Fate on one achievement.
