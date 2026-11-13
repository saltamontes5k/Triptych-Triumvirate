# EQS achievements vs the everquestnexus checklist

Audit of the live `peq` achievement data against
<https://everquestnexus.com/eq1/checklists/achievements> (Manafire's EverQuest
Nexus). Census run 2026-11-03 against live `peq`; nexus pages fetched the same
week. Companion register:
[achievements_enabled_nocriteria.csv](achievements_enabled_nocriteria.csv)
(178 rows). Extends
[UF coverage](achievement_coverage_uf.md) and
[classic expansion batch](achievements_expansion_classic.md).

## Headline

- The DB carries a **superset** of the nexus checklist in every category.
  Total delta **+2,118** (6,963 associations vs 4,845 nexus rows), reconciling
  exactly. The surplus is real client-snapshot content the nexus site chooses
  not to checklist — not data corruption.
- Every classic-expansion tree (Kunark / Velious / Luclin / PoP) is live and
  **100% criteria-covered for its enabled defs** (classic batch, entries
  238-255).
- The modern trees are a mixed bag: **THJ is 210/314 enabled (188 with
  criteria)**, **UF 165/165 enabled but only 57 with criteria**, SoD 91/91 (57
  crit) — i.e. the import-enabled modern trees are largely
  **enabled-but-incompletable**.
- **178 enabled achievements cannot ever complete** (zero criteria) — the
  largest single defect class. Register CSV.
- RoF remains the big deliberate gap: **1/351 enabled**.

## Live census (2026-11-03)

| Population | Defs | Enabled | Enabled w/ criteria |
| --- | ---: | ---: | ---: |
| Imported live-EQ snapshot | 6,574 | 834 | 656 |
| Custom band 9500000-9599999 (pilot/Triptych) | 26 | 26 | 26 |
| Custom band 9600000-9699999 (batch-2) | 306 | 306 | 306 |
| **Total** | **6,906** | **1,166** | **988** |

- 6,963 category associations (57 achievements multi-category), 0
  uncategorized; 4,770 criteria on 1,031 achievements; 33,866 components.
- Drift vs the 2026-10-25 doc: +16 defs, +40 enabled (imported-enabled went
  810 → 834; custom 316 → 332).

## Per-category reconciliation (nexus vs DB)

Nexus counts are the checklist hub's per-category "achievements" figures; DB
counts roll every achievement's category chain to its top-level root
(distinct per achievement).

| Category | Nexus | DB defs | DB enabled | en+crit | Verdict |
| --- | ---: | ---: | ---: | ---: | --- |
| General | 257 | 2,111 | 182 | 172 | Surplus +1,854 (see below); enabled = custom batch-2 + 11 imported |
| Tradeskill | 56 | 135 | 0 | 0 | **0/N** — import only, all disabled |
| The Hero's Journey | 283 | 314 | 210 | 188 | **210/314 enabled, 22 incompletable** — import-enabled |
| Slayer | 180 | 180 | 0 | 0 | Was 0/180 by policy — **shipped 2026-11-03**: 142/180 enabled with native race-kill criteria + claimable rewards, side-by-side with the NMS hunter titles (entries 317-330); 38 deferred ([slayer_bridge_deferred.csv](slayer_bridge_deferred.csv)) |
| Events | 190 | 196 | 0 | 0 | 0/N — out of era |
| Overseer | 31 | 31 | 0 | 0 | 0/N — Overseer server system absent |
| EverQuest (Original) | 218 | 357 | 135 | 135 | Surplus +139; enabled = custom batch-2 exact |
| Ruins of Kunark | 71 | 73 | 56 | 56 | Live (classic batch; +2 Hunter surplus vs nexus 23→25) |
| Scars of Velious | 55 | 55 | 42 | 42 | Live (classic batch) |
| Shadows of Luclin | 71 | 71 | 55 | 55 | Live (classic batch) |
| Planes of Power | 101 | 102 | 53 | 53 | Live (classic batch; 24 SoD-era Progression remain disabled/deferred) |
| Legacy of Ykesha | 16 | 16 | 0 | 0 | 0/N |
| Lost Dungeons of Norrath | 114 | 114 | 5 | 5 | Only the 5 LDoN Conqueror metas (pre-existing) |
| Gates of Discord | 40 | 40 | 0 | 0 | 0/N |
| Omens of War | 38 | 38 | 0 | 0 | 0/N |
| Dragons of Norrath | 19 | 19 | 19 | 19 | Fully live (DoN reviewed closure) |
| Depths of Darkhollow | 37 | 37 | 36 | 31 | Enabled, 5 incompletable |
| Prophecy of Ro | 32 | 32 | 32 | 30 | Enabled, 2 incompletable |
| The Serpent's Spine | 31 | 31 | 31 | 30 | Enabled, 1 incompletable |
| The Buried Sea | 28 | 28 | 28 | 27 | Enabled, 1 incompletable |
| Secrets of Faydwer | 37 | 37 | 36 | 31 | Enabled, 5 incompletable |
| Seeds of Destruction | 91 | 91 | 91 | 57 | **Enabled, 34 incompletable** |
| Underfoot | 165 | 165 | 165 | 57 | **Enabled, 108 incompletable** — worst criteria starvation |
| House of Thule | 159 | 160 | 0 | 0 | 0/N |
| Veil of Alaris | 154 | 155 | 0 | 0 | 0/N |
| Rain of Fear | 351 | 351 | 1 | 1 | **1/351** (2075225 Partisan of Shard's Landing) — the known gap |
| Call of the Forsaken | 237 | 240 | 0 | 0 | Out of era |
| The Darkened Sea → Shattering of Ro (12 trees) | 1,876 | 1,876 | 0 | 0 | Out of era, exact match |

## Where the +2,118 surplus lives

Nexus checklists a filtered subset of the same client snapshot. The surplus is
concentrated (DB vs nexus subcategory counts):

- **General Skills 1,070 vs 67**, **Vanity 503 vs 58**, **Class 179 vs 5**,
  **Advancement 120 vs 36**, **Progression 97 vs 16**, **Keys 83 vs 56**,
  **Level 57 vs 17** — per-skill/per-milestone and collection lines the site
  collapses or skips.
- **Original Exploration 179 / Hunter 103 / Collections 48** vs nexus's
  slimmer Original tree.
- **Tradeskill Special 44 + per-skill 11s** vs nexus 56.
- Classic trees match nearly exactly (Kunark +2 Hunter, PoP +1).

Name-level validation: `kunark/raids` returns **11/11 exact name match** with
DB category 206; kunark subcats reconcile 71 nexus vs 73 DB. The
"nexus mirrors the same snapshot" thesis holds at name level.

## Enabled-but-incompletable register (178)

Enabled with zero criteria — cannot ever complete, and any with claimable
reward sets are dead-weight claim targets. By family:

| Family | Count | Examples |
| --- | ---: | --- |
| Raids | 43 | 1645240 Conqueror of Field of Scale |
| Conquests (time trials) | 36 | 1748013 Don't Fear The Destroyer Time Trial |
| Quests | 27 | 1544205 Eron's Jewelry |
| Missions | 19 | 1645330 Hero of Kaesora |
| Progression | 17 | 90040 Dreadspire Keep Visitor |
| Keys | 10 | |
| Hunts | 10 | 1108200 Hunter of Corathus Lair |
| Classic city-quest lines | 23 | Cabilis 6, Grobb 3, Ak'Anon/Freeport/Qeynos 2 each, 9 singles (12xxx ids) |
| Exploration | 2 | 1443100 The Open Sea Traveler |
| General | 2 | 1700001 Paragon of the Underfoot |

Per-tree split: UF 108, SoD 34, THJ 22, General 10, DoDH/SoF 5+5, PoR 2,
TSS/TBS 1+1 (10 rows are multi-category; totals count unique achievements).
The docs' previously known "15 missions + 9 task criteria" is a small subset.

Other known carried defects (from the classic batch doc, still open): 9
enabled task-complete criteria pointing at task ids absent from `tasks`; 13
inert event-0 manual rows in PoP; 892 Hunter NPC names absent from
`npc_types` (417 in DoDH→UF).

## Gap-closing options (report-only, nothing approved)

1. **Retire the 178 dead rows** — disable them (or author their criteria).
   Disabling is a data-only migration and the safest win: it removes dead
   claim targets from the in-game window. The 23 city-quest lines and the
   UF/SoD quest/mission families could instead be criteria-authored quest by
   quest (the SoD/UF `sod_quest_criteria` / `uf_mission_criteria` pattern).
2. **Criteria-complete UF/SoD** — 620-component DoDH→UF queue already mapped
   (`uf-unassigned-components.csv`); the same importer flow emits criteria.
   Biggest single win: UF alone is 108 incompletable rows.
3. **RoF trees** — 351 defs waiting; zone subcategories absent. The
   nightstalker repo's RoF zone packages (Blightfire/Stone Hive/Shard's
   Landing/Crescent Reach) are the researched content source; class-masked
   reward eligibility (its patch 0002) is a prerequisite for the parent-gear
   sets.
4. **Slayer bridge** — author the 180 Slayer defs to grant existing
   title_sets, retire the perl auto-grant. Design drafted, never approved.
5. **LDoN/GoD/OoW/LoY enablement** — 208 defs, all disabled; would follow the
   classic-batch strict filter method (LoY 16, GoD 40, OoW 38, LDoN 109).
6. **Tradeskill (56)** — per-skill cap lines; needs the same SkillCap
   wildcard machinery batch-2 used.

## Method notes

- Census: `dbq.py` SELECTs on `achievements` /
  `achievement_category_associations` / `achievement_categories` /
  `achievement_criteria`, rolled to top-level roots locally
  (`tmp/ach_work/rollup_nexus_audit.py`); association counts deduped by
  achievement id (57 multi-category).
- Nexus: hub page (server-rendered counts) + `kunark` +
  `kunark/raids` checklist pages; checklist data extracted from the Next.js
  flight payload (`tmp/ach_work/nexus_checklist_extract.py`); URL slugs are
  short codes (`kunark`, `rof`, `sor`...), not full names.
- All DB access read-only.
