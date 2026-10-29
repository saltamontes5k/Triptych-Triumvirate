# RoF2 achievement content — staged, not installed

Source: <https://github.com/nightstalker6669/eqemu-rof2-achievements>
Vendored from `main` on 2026-10-29 into this directory. Nothing here runs.
No SQL in these folders has been applied to `peq`, and none of the quest
scripts are in a zone directory the quest loader reads.

## Why it is staged instead of installed

These packages are drop-in replacements for quest content we already ship in
Perl. Installing them alongside the existing scripts would run two
implementations of the same quest on the same NPC (EQEmu attaches both the
`<npcid>.lua` and the `#Name.pl` handler to a spawn). Measured overlap against
the live `npc_types` table:

| Zone | Staged NPC-id scripts | Already scripted here |
| --- | ---: | ---: |
| `crescent` | 39 | 29 |
| `moors` (Blightfire) | 64 | 12 |
| `stonehive` | 8 | 2 |

The overlapping NPCs:

- crescent: #Moswen, #Anarynn, #Herald_Nexeu, Councilmember_Heshyrr,
  #Champion_Utenka, #Disgruntled_Boawb, Vunder_the_Dark, Farmer_Joen,
  #Guard_Captain_Minka, #Smithy_Bronson, Historian_Pewdri, Council_Aide_Shay,
  #Akins, Councilmember_Reakash, Tailor_Meikolu, Farmer_Lize, Assistant_Geejulin,
  #Skinner_Bezuth, Councilmember_Myjinn, Smithy_Drawlyn, Master_Vanguard_Regan,
  #Jeweler_Kamilah, Baker_Shivra, Councilmember_Lizzrel, Butcher_Katorr,
  Councilmember_Vakk`dra, Councilmember_Ithakis, Quartermaster_Thatun,
  Yuvill_the_Spirithunter
- moors: Defan_the_Watch_Captain, Ordunn_the_Miner, Merchant_Makesn,
  Scout_Captain_Slynn, Scout_Ethaniel, Scout_Vreshnar, Botanist_Brezuu,
  Cook_Idriak, #Gubjak_the_Lost, #Buzzazar, #Zan_the_Witch_Hunter,
  #Selay_the_Cascade
- stonehive: Warwing_Wendlez, Scout_Neauza

`shards-landing` does not collide with anything: we have no Shard's Landing
quest content, and the zone is not in the rotation. Its SQL is included for the
day the zone opens.

## What each package installs

Each package has `sql/` (achievement catalogue, tasks, scenes, rewards),
`quests/` (Lua scripts by NPC id, plus `lua_modules/`), `provenance/` and its own
`README.md`. Read the package README before installing; they list the exact
coverage and the parts that are historical reconstruction rather than verified
Live behaviour.

Order from the upstream README, for reference:

1. `crescent/sql/010..050` then its quests
2. `blightfire-moors` (010 catalogue, 020 quests), then its quests
3. `blightfire-bixies` after Blightfire Moors
4. `blightfire-spirits` after Crescent Reach
5. `blightfire-welcome` after Crescent Reach + Blightfire Moors
6. `blightfire-champion` after Crescent Reach + Blightfire Moors (needs engine patch 0008)
7. `stonehive` (010..040)
8. `blightfire-parent-rewards` (010) last, it completes the eight family rewards

Each SQL file opens with guarded preflights (`_blightfire_guard`,
`_stonehive_guard`, ...) that abort on conflicting custom content, but they do
not check for the Perl scripts above, because upstream never had them.

## Adopting a package

Pick per zone:

1. **Replace** — move the overlapping `#Name.pl` files out of the zone folder,
   then copy the package's `quests/<zone>/*` in and run its SQL. The reviewed
   Lua then owns those NPCs.
2. **Coexist** — install only the package's non-overlapping NPCs (the counts
   above minus the overlap) and skip the achievements that depend on replaced
   NPCs.
3. **Reference only** — leave it here.

The achievement catalogue in `peq` already holds this project's definitions
(`achievements.id` 500000000-50009xxxx, 145 rows, 127 of them with no criteria),
so option 1 or 2 is what makes those rows live. Nothing regenerates them from
tracked SQL today.
