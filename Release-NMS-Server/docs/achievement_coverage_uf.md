# RoF2 / Underfoot achievement coverage

This is the content-coverage record for the achievement resource snapshot used by
the **Underfoot (UF)** profile. The audited profile is **launch through Underfoot,
level 85**. It extends and supersedes the
[RoF2 / Dragons of Norrath coverage](achievement_coverage.md) profile.

For runtime behavior see [RoF2 achievement support](achievements.md); for
components, criteria, rewards, and the quest API see
[Achievement content authoring](achievement_authoring.md).

## What is actually live today

The profiles below are **prepared targets, not installed content**. The live `peq` database
holds only the server-authored **Triptych** achievements and **zero ToB-imported**
achievements:

| Namespace | Enabled | Rewarded |
| --- | ---: | ---: |
| `950xxxx` Triptych line (Explorer / Veteran / Pest Control / Trailblazer) | 10 | 1 |
| `960xxxx` Original + General (Exploration, Hunter, Raids, Level, Advancement, Class, Keys) | 306 | 0 |
| **Total live** | **316** | **1** |

- 1,630 live criteria; every `960xxxx` definition has at least one.
- Live event mix: 1,268 NPC-name kills, 95 own item, 86 achievement complete, 82
  zone enter, 48 skill cap, 29 AA, 21 level, 1 NPC-type kill.
- Only **`9500040 Trailblazer`** has a reward (set `9506000 "Choose Your Boon"`, four
  options: 1 platinum, Watchman's Spectacles, 10 AA points, the Trailblazer suffix
  title). **315 of 316 live achievements have no reward mapping.**
- Live criteria health: **all 1,630 resolve** against the content database. Level,
  AA, zone-enter, owned-item, NPC-type, and NPC-name criteria all check out.
  (Zone-name matching must be case-insensitive: `spawn2.zone` mixes `'Everfrost'`
  and `'everfrost'`.)

The live set is **classic-heavy**. The DoN slice in
[achievement_coverage.md](achievement_coverage.md) and the DoDH→UF slice in this
document are engineering targets; installing the imported profile is a larger,
separate step than extending the live custom set. The per-achievement reward gap is
in `reference/bonzz-achievements/live-achievements.csv`.

## Snapshot provenance

- Source: `C:/games/EQTriune/Resources/Achievements`, copied byte-for-byte from
  `D:/EverQuest/Resources/Achievements`. All five resource files are present.
- Totals: **296 categories, 6,574 achievements, 6,642 category associations,
  32,206 components, 4,475 displayed counts.**
- The DoN reviewed closure is **cumulative**: `reviewed_profile_requested` is true
  for DoN and every later profile, while the 99-ID DoN denylist remains DoN-only.
  A UF import therefore keeps the audited DoN criteria — 510 native / 214
  quest-manual / 20 presentation / 330 unavailable — instead of regressing them.
  DoN and UF both report exactly `(510, 214, 20, 330)` with no coverage rejection.

## Audit result

Underfoot selects **1,851 definitions** (1,152 expansion, 467 skill cap, 47 item,
17 level, 6 level-locked progression, plus the reviewed DoN coverage). It emits
**8,083 fixed criteria plus 123 item-name mappings**.

| Bucket | Components | Treatment |
| --- | ---: | --- |
| Server-native | 8,141 | Deterministic criteria emitted by the importer |
| Presentation only | 602 | RoF2 type-3 rows; never completion facts |
| Needs review | 1,119 | No criterion yet — quest-manual or unavailable |

State-bearing components total 9,260. Of the 1,119 needs-review components,
**620 are in the Depths of Darkhollow → Underfoot gap**; the remainder is earlier
content (classic Collections 288, classic Hunter 69, PoP 71, and so on).

### Native trigger matrix

| Event | Criteria rows | Authoritative source |
| --- | ---: | --- |
| Manual (0) | 214 | Reviewed DoN quest-manual hooks; a script calls progress |
| Level (1) | 23 | Current level, reconciled at login |
| Task complete (4) | 66 | Durable completed-task persistence |
| Zone enter (5) | 398 | Traveler zone IDs, boundary-checked |
| Own item (7) | 22 | Reviewed DoN item components |
| Achievement complete (11) | 1,010 | Prerequisite achievement state |
| NPC name kill (12) | 3,487 | Zone-scoped canonical NPC-name hash |
| Skill cap (13) | 2,863 | DB-backed class skill caps by milestone level |

Item-name mappings add 123 more Own Item criteria by exact name join.

## Depths of Darkhollow → Underfoot review queue

The 620 gap components with no criterion yet, by expansion and sub-category:

| Expansion | Sub-category | Components |
| --- | --- | ---: |
| Underfoot | Quests | 122 |
| Seeds of Destruction | Quests | 116 |
| Seeds of Destruction | Hunts | 59 |
| Underfoot | Raids | 49 |
| Underfoot | General | 48 |
| Underfoot | Conquests | 40 |
| Underfoot | Hunts | 36 |
| Seeds of Destruction | Progression | 32 |
| Seeds of Destruction | Missions | 26 |
| Underfoot | Missions | 23 |
| Seeds of Destruction | Raids | 21 |
| Secrets of Faydwer | Hunts | 17 |
| Underfoot | Progression | 8 |
| Secrets of Faydwer | Quests | 7 |
| The Buried Sea | Exploration | 5 |
| Depths of Darkhollow | Hunts | 3 |
| The Serpent's Spine | Hunts | 3 |
| Seeds of Destruction | General | 2 |
| Seeds of Destruction | Exploration | 2 |
| Secrets of Faydwer | General | 1 |
| **Total** | | **620** |

The complete component list is in
`reference/bonzz-achievements/uf-unassigned-components.csv`.

## Hunter availability audit

Hunter rows are emitted as native zone-scoped NPC-name kills. That criterion only
fires when the credited kill's canonical name matches the client component name.
Checking every emitted criterion against the live `npc_types`/`spawn2` data:

| Result | Whole profile (3,487) | DoDH → UF gap (849) |
| --- | ---: | ---: |
| Resolves to a static spawn in the mapped zone | 2,050 | 418 |
| Exists in `npc_types` but has no static spawn in that zone | 448 | 14 |
| **Absent from `npc_types` entirely** | **892** | **417** |
| Zone has no static `spawn2` rows (dynamic/instanced) | 96 | 0 |
| Zone id did not resolve | 1 | 0 |

**417 of the 849 DoDH→UF Hunter targets (49%) do not exist in this server's
`npc_types`.** They are concentrated in `Hunter of Sverag, Stronghold of Rage`
(41), `Hunter of The Buried Sea` (26), `Hunter of The Elddar Forest` (17),
`Hunter of The Cooling Chamber` (16), `Hunter of Valdeholm` (15),
`Hunter of Brell's Rest` (15), `Hunter of Pellucid Grotto` (15), and
`Hunter of Theater of Blood` (14). The UF zones are populated with generic
spawns, but their named populations are not authored.

These criteria are emitted and will simply never fire until the NPCs are added
(or the achievements are disabled). Full lists:

- `reference/bonzz-achievements/hunter-npcs-absent.csv`
- `reference/bonzz-achievements/hunter-npcs-unlinked.csv`

## Definitions re-enabled relative to the DoN denylist

The DoN profile force-disables 99 IDs. A UF profile re-enables 21 of them because
they are in-era. All referenced zone rows exist; they need a content-availability
pass rather than a denylist:

- Keys: `90003` Efreeti's Key, `90033` Passkey of the Twelve, `90034` Keys of War,
  `90035` Riftbreakers' Ornaments.
- Plane of War: `200071`, `521300`–`521310`.
- Revamped/event Travelers: `100038400` Freeport Sewers, `100040800` The
  Commonlands, `100049300`/`100049400` Wedding Chapel, `100049500` Dragoncrypt.

## Reconciliation with the NMS Slayer system

Slayer is not expansion-scoped: `--enable-slayer` selects the complete validated
top-level Slayer hierarchy (180 definitions, 1,825 points, IDs `11000000+`). The
chosen direction is the **bridge** option: the custom `NMS_slayer_utils.pl`
race-kill counters and titles stay, the Live Slayer/Hunter achievements drive
progress from the same credited kills, and overlapping buckets (for example the
custom `god` bucket versus `11000026 Your God Has Found You Lacking`, whose
reward is the “Godslayer” title) are mapped rather than duplicated. Hunter is
bridged the same way. See the plan for the open mapping work.

## Quest hook and reconciliation contract

- Call `SetAchievementProgress(achievement_id, component_type, component_id, 1)`
  only after the source quest state is durably successful.
- Use the expedition/world state-update API for group, raid, DZ, or task members
  who may be in another zone.
- Keep durable task, item, and prerequisite facts in criteria so login and reload
  reconcile existing characters.
- Do not fan native Hunter kills out from `global/global_npc.lua`: the native
  merit event already runs for every credited local member.
