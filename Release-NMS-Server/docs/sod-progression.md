# SoD Progression (raspersrealm miscProgression)

Implementation of the Seeds of Destruction intra-expansion progression from
`raspersrealm.com/Everquest/SoD/miscProgression.html` (plus the five theme
and raid pages). Generated SQL: `utils/sql/20261003_sod_progression.sql`
(v89), `utils/sql/20261002_sod_raids.sql` (v91), `utils/sql/20261002_sod_rk3.sql`
(v92), `utils/sql/20261005_sod_progression2.sql` (v111) — regenerate with
`python sod_content/gen_progression.py`, `gen_raids.py`, `gen_rk3.py`
(rk3 needs the mysql CLI), `gen_progression2.py`; keep the manifest twins
in sync (`sod_content/manifest_v91.py`, `manifest_v92.py`,
`manifest_v111.py`).

## Rules implemented (miscProgression)

| Rule | Mechanism |
|---|---|
| 4 group themes (Oceangreen, Kithicor, Kunark/Field of Scale, Rathe) | task chains 303000-05, 303010-12, 303020-24, 303030-36 → account subflag `<theme>-group` |
| 4 raid themes | real raid expeditions (v91) → boss-kill tasks 303060-63 → `<theme>-raid` |
| Void version = 1 + themes (group+raid of same theme count once) | `SodVoidVersion()` in `plugins/NMS_sod_utils.pl` → zones thevoida..thevoidg |
| Korafax + Kuua → Void F | Kuua chain 303040-51 → `korafax-kuua` |
| Discord Tower raids → Void G | 303067 (The Mindblight raid) → `discord-tower` |
| Korafax access: all 4 group OR all 4 raid, never mixed | `SodKorafaxAccess()`; enforced in `discord/player.pl` |
| Citadel: Korafax access + 3 Korafax raids + Tower Key | `SodCitadelAccess()`; Tower Key = item 88343, granted as task reward by 303064/65/66; enforced in `discordtower/player.pl` |
| Mercenary tiers (OG=T2..Rathe=T5) | theme flags are the record; mercs are disabled server-wide (`Mercs:AllowMercs=false`) so nothing further unlocks |
| Raid targets unlock Rank 3 spells in The Void (v92) | Loremaster of the Timeshear (478750-478756) in each thevoida..g scribes Rk. III tiers for completed raid flags; tier→level-band mapping in `plugins/NMS_sod_rk3_data.pl` |

## Raid expeditions (v91)

Request flow: say **request** at the giver — creates the expedition, assigns
the raid task, 72h replay lockout; say **ready** — zones into the held
expedition (`plugin::SodRaidRequest` / `SodRaidEnter`, table `%SOD_RAIDS`).
Encounters follow the Steam Factory pattern: `<zone>/<npc_id>.lua` +
`lua_modules/sod_raids.lua` + a controller anchor per instance
(478730-478737) that registers the chest loot event and adds the 72h
expedition lockout on the completion signal.

| Task | Raid (Rasper page) | Instance | Boss |
|---|---|---|---|
| 303060 | Stop the Ascension (raidOG2) | bertoxtemple v51 | #Rottrued_the_Twisted 478700 |
| 303061 | Fall of General Bahgresh (raidKith) | oldkithicor v51 | #General_Bahgresh 478701 (+kyv trio, camps) |
| 303062 | A Council Divided (raidKunark1) | oldkaesoraa v51 | 8 councilors 478707-714 (4 discord-aligned, emote-identified) |
| 303063 | Eriak's Downfall (raidRathe3) | rathechamber v51 | #Xadrith_the_Voice 478715 → #Eriak_Dechard 478716 |
| 303064 | Pallorax the Soul Slayer (raidKorafax) | discord v51 | 478717 (portal phases 80/60/40/20) |
| 303065 | The Mindshear Avatar (raidKorafax) | discord v52 | 478718 (acolyte waves) |
| 303066 | Venom Lord Ksathrax (raidKorafax) | discord v53 | 478719 (room cycle, projection) |
| 303067 | The Mindblight (raidDiscord) | discordtower v51 | 471001 (room aura, dissolve cycles) |
| 303078 | Queen Malarian (v111) | oceangreenhills v51 | #Queen_Malarian 478758 (brood waves 75/50/25) |
| 303079 | Showdown at the Crystal Core (v111) | korascian v51 | #The_Crystal_Core 478760 (coresieger waves, ground shatter, shard splits) |

Raid requests enforce the page's prerequisite tasks (`%SOD_OFFERS` prereq
lists, v111): Stop the Ascension requires the five OG group tasks; Queen
Malarian requires its four OG prereq tasks (303070-73); Bahgresh accepts
either the Light path (Charges of Treason + Vengeance and Deliverance +
Safe Passage + Bitter Victuals) or the Obliteration path (Destroy the
Impostor + Rain of Ruin); the Field of Scale raid requires the five Kunark
tasks; Eriak's Downfall requires Find Your Allies + Champions No More +
Murdunk's Last Stand; Showdown requires The Crystal Bloom; the Korafax
raids still require the Kuua chain; the Citadel raid requires the three
Korafax raids plus a Tower Key on the character (`towerkey` prereq).
Prereq engine semantics: a scalar prereq is a task id, a chain flag,
`korafax`, or `towerkey`; an ARRAY prereq is an OR over its elements and an
ARRAY element is an AND over its own entries (`[[a,b],[c,d]]` =
(a AND b) OR (c AND d)). GMs bypass prereqs.

## Raid-prereq tasks + remaining raids (v111 completion pass)

The 8 page tasks skipped in v89 plus the 2 missing raids, closing the
miscProgression page fully:

| Task | Giver | Objective (our adaptation) |
|---|---|---|
| 303070 A Secret Hidden in Plain Sight | Apothecary Cadmael 467066 | undead soldiers, oceangreenvillage |
| 303071 A Corrupted Arch Priest | Apothecary Cadmael 467066 | putrid lectors + plagued ritualists, bertoxtemple |
| 303072 Remove the Head and the Disease Will Die | Apothecary Cadmael 467066 | dreadwardens + cabalists, bertoxtemple |
| 303073 The Bubonians Are Coming! | Jerom Bertrand 467069 | festering/pustulant/putrescent corpses, oceangreenhills |
| 303074 Charges of Treason | Lord Tephys 456172 | Army of Light infiltrators, oldkithicor |
| 303075 Vengeance and Deliverance | Firiona Vie 456171 | Obliteration knights + warlords, oldkithicor |
| 303076 Destroy the Impostor | Laarthik V`Shin 456175 | Obliteration nightblades + infiltrator, oldkithicor |
| 303077 The Crystal Bloom | Ulgin Darkhammer 476041 | crystalline corrupters + spheres, korascian |
| 303078 Queen Malarian (raid) | Apothecary Cadmael 467066 | boss 478758 in oceangreenhills v51 |
| 303079 Showdown at the Crystal Core (raid) | Ulgin Darkhammer 476041 | boss 478760 in korascian v51 |

Givers 467069/456172/456175/476041 are pre-existing PEQ spawns with new
one-liner `<zone>/<npc_id>.pl` scripts (Cadmael/Firiona offer the new tasks
through their existing scripts). New NPCs: #Queen_Malarian 478758 +
a_malarian_broodling 478759 (clone the oldkithicor giant spider),
#The_Crystal_Core 478760 + a_Rallosian_coresieger 478761 +
a_shard_of_the_core 478762 (clone korascian crystal/Rallosian models),
controllers 478738/478739, chests 478748/478749; spawngroups
1520008644-1520008647. Completing either 303060 or 303078 sets
`oceangreen-raid`, and either 303063 or 303079 sets `rathe-raid`
(`%SOD_CHAIN_ANY` — a theme with two raid victories counts once). The v111
tasks award faction 1222 like the v110 convention (+150 group, +300 raid).

v111 also adds the missing `zone` table version rows for ALL ten SoD raid
instances (bertoxtemple/oldkithicor/oldkaesoraa/rathechamber/
oceangreenhills/korascian v51, discord v51/52/53, discordtower v51 —
clones of each zone's version 0 row). The v91 instances never had these
rows; if instanced zone-in ever fails with "not yet able to claim", the
missing row was the suspect.

## Wiring

- **State**: per-account subflags under the existing `'SoD'` stage of
  `NMS_progression_utils.pl` (`SetSubflag($client,'SoD',...)` →
  `<accountid>-progress-flag-SoD`). Era gating and the SoD stage prereqs
  (Kerafyrm) are untouched; the intra-SoD chain is orthogonal.
- **Completion**: `global/global_player.pl` `EVENT_TASK_COMPLETE` →
  `plugin::SodOnTaskComplete` — sets the chain flag when every task in the
  chain is completed.
- **Givers** (all pre-existing PEQ SoD spawns, script = `<zone>/<npc_id>.pl`):
  Bronal 466141 / Tillin 466035 / Raxtor 466160 (oceangreenhills),
  Cadmael 467066 (oceangreenvillage), Lanys 456178 / Barvian 456174 /
  Firiona 456171 (oldkithicor), Jaled`Dar 452147 (oldfieldofbone),
  Sterik 476122 / Nedsin 476115 / Ylatra 476110 (korascian),
  Vurig 472055 (oldbloodfield), Yemall 474036 (olddranik),
  a disheveled human 470000 / Telivar 470020 / Herald of Druzzil Ro 470001
  (discord). Hail lists offers; say "ready" to accept a group task,
  "request" to claim a raid, "ready" to zone into a held raid; say
  "progress" for a full SoD standings report.
- **Gates** (`EVENT_ENTERZONE` in `<zone>/player.pl`): thevoida-g version
  check + redirect to the earned version zone; `discord` Korafax check;
  `discordtower` Citadel check. GMs bypass everywhere.
- **Portals** (custom NPCs 478600-478606, clones of 470000, faction 0,
  spawngroups 1520008600-1520008612): `a_void_rift` in each of the 5 theme
  zones (→ thevoida, then version-redirected), `a_timeshear_rift` in all
  seven void zones (→ Korafax, gated), `a_citadel_rift` in discord
  (→ Citadel, gated). The stock PEQ void `zone_points` in these zones are
  0,0,0 placeholders and were left untouched. NOTE: the original portal
  spawngroup block 1520008000-8012 was later taken by the SoF gyrospire
  migrations (which wiped the 478601-478606 spawns); the block was moved to
  1520008600-8612 (commit 5713ed6dd).

## Rank 3 spells (v92)

`plugins/NMS_sod_rk3_data.pl` (generated by `sod_content/gen_rk3.py`, needs
mysql) holds the 768 SoD Rk. III spell ids (spells_new level 76-85 band)
grouped into tiers: 1 Oceangreen 76-77, 2 Kithicor 78-79, 3 Kunark/FoS 80-81,
4 Rathe 82-83, 5 Korafax 84, 6 Citadel 85. `plugin::SodLoremaster` (called
from `<thevoid*>/47875*.pl`) scribes a tier's spells via
`HasSpellScribed` + `GetNextAvailableSpellBookSlot` + `ScribeSpell` when the
matching raid flag(s) are set; Korafax tier requires all three Korafax raid
chains. Group chains unlock no Rk. III (raids only, per Rasper).

## ID allocations (verified collision-free at write time)

- tasks 303000-303067 (range was empty; 41 tasks); 303070-303079
  (verified empty, v111)
- npc_types 478600-478606 (portals), 478700-478749 (raid content:
  bosses/adds/council/controllers 478730-737/chests 478740-747),
  478750-478757 (loremasters + potimea rift), v111 raid content
  478738/478739/478748/478749/478758-478762 — blocks verified empty
- spawngroups 1520008600-1520008612 (portals; moved from the old
  1520008000-8012 block, see above), 1520008620-1520008643 (raid spawns),
  1520008650-1520008657 (loremasters + potimea rift), 1520008644-1520008647
  (v111 raid spawns)
- zone table: v111 adds version rows (51-53) for the ten SoD raid instance
  zones; no version rows existed for them before
- No new items: Tower Key 88343 already existed in `items`.

## Simplifications vs live (deliberate, per scoping decision)

- **Raid loot economy out of scope**: Treasure_of_* punch chests are
  loot-event anchors only (empty); Tower Key arrives via the task rewards
  303064-66. Runes/essence loot and hard modes are not modelled.
- **Council kill-credit counts any 4 of the 8 members** (loyalists are
  killable and count; the live simultaneous-kill / loyalist-reset rules are
  not modelled — the 4 discord-aligned members are harder, AE from emotes).
- **Mindblight is one kill** (live: five directional dissolve cycles to
  reach 35%); un-killed oozes do not split into five; Disgusting Goop not
  modelled.
- Each theme raid simplifies its event's full mechanics to its headline
  phases (documented in each encounter's header, per Rasper page).
- (g) group missions are implemented as open-zone shared tasks — no dynamic
  zones. Kill activities reuse the theme zones' existing PEQ trash; explore
  boxes are anchored to zone safe points.
- **Citadel visible armor out of scope**: the T3 pieces exist (Eon Forged
  family, items 104400+) but the Citadel-tier upgrade set does not exist in
  the DB (Coeval/Primeval items are essences only), so there is no turn-in
  NPC to author. Revisit if a Citadel armor set is imported.
- **Void/Oceangreen vendors (v110, `20261005_sod_vendors`)**: per
  themeVoid.html / themeOceangreen.html, generated by
  `sod_content/gen_vendors.py`.
  - Zebuxoruk (459000-465000) stocks each version per the page: Void A
    Mutating Tinea + class Polymorphic Cocoons, Void B no-drop Archaic armor
    (items 103300-103327) + Minor quartzites, C-E Greater Corrupted/Dyadic
    pieces + Temporal Cells + Culling Vortexes + Mutation Nexuses, Void F
    full Greater family, Void G full Glowing family. Prices are plat
    stand-ins for the live Chronal Shear purity currency (not modelled);
    buy price lives in `items.price` (merchantlist has no price column).
  - Rk. II: peq's Faycite Shard items are inert (itemtype 54, scrolleffect
    -1) and the functional "Scroll: X Rk. II" catalog only covers levels
    91-105, so the generator creates 768 "Scroll: X Rk. II" items (block
    180000+, one per spells_new Rk. II spell in the 76-85 band, each
    validated against the server's spells_us.txt) and sells them on
    Cirtan at Warmly.
  - Cirtan, Bayle's Herald (466046): merchant 999999 (was a dead stub),
    npc_faction_id 1222, crest items at Indifferent (`faction_required` 0),
    Rk. II scrolls at Warmly (750) — merchantlist faction gating is
    enforced in client_packet.cpp. All SoD tasks 303000-303067 plus the
    v111 tasks 303070-303079 award faction 1222 (+150 group, +300 raid),
    so 5 group tasks reach Warmly.
    The page's Ally tier (faycite shards + Emblem of Deep Sea) is omitted:
    the shards are the inert items above and the Emblem does not exist in
    the DB.
  - Void version routing fix: theme-zone rifts and the potimea entry rift
    now route to the player's EARNED Void version
    (`SodPortalUse` → `SodVoidZone(SodVoidVersion($client))`); previously
    every rift hard-coded thevoida and nothing moved a player up to
    thevoidb..g (those zones have no inbound zone_points).
  - Entry rift: a_void_rift 478757 in potimea at the Herald of Druzzil Ro's
    PoK landing spot (110, 0, 8), spawngroup 1520008657 — "The Void is
    reached via the Plane of Time". potimea is entered via the Herald of
    Druzzil Ro in PoK (requires the stock potime zone flag, target
    110, 0, 8); Zebuxoruk 459000-465000 also got hail scripts
    (`SodReport`).
- Portal/instance/boss coordinates are TUNABLE (anchored to safe points);
  nudge with `/loc` in game. Boss/add HP is TUNABLE (between SoD trash ~8k
  and SoF raid-boss conventions).

## Theme completion: Oceangreen + Kithicor (v143-v146, 2026-10-12)

Completes the raspersrealm themeOceangreen/themeKithicor pages beyond the
miscProgression chains (Chronobines out of scope). Four migrations:

- **v143** (`20261012_sod_og_missions.sql`): group missions **Freedom!**
  (303080, Raxtor Darkpaw 466160) and **Disrupting the Ritual** (303081,
  Elder Mystic Foppye 466155), open-zone shared tasks in oldblackburrow,
  faction 1222 +150. Freedom! joins the chain live-faithfully: Raxtor
  offers it after the Tillin tasks, and **Beat the Blackburrow Boss
  (303005) now requires 303080 + Summary Execution + What Evil Lurks**
  (the live page's full request gate).
- **v144** (`20261012_sod_kithicor_faction.sql`): the Kithicor partisan
  chain tasks (303010-303012, 303074-303076) raise **Silla Herald (1223)**
  instead of Cirtan. **Army necklace scouts**: Scout Talendien 456002
  (Army of Light Pendant 41118), Scout Zialdiruun 456003 (Army of
  Obliteration Medallion 41119), Herald Silla 456001 (progress report) in
  oldkithicor; `%SOD_NECKLACE_GATES` in the plugin gates the Kithicor/Old
  Commons side-task givers on wearing an army pendant (GM bypass; the
  progression chain givers stay un-gated).
- **v145** (`20261012_sod_theme_tasks.sql`): the 40 theme
  solo/partisan tasks 303100-303146 (20 Oceangreen, 13 Kithicor partisan,
  7 Old Commonlands incl. the five Refugee Rescue lines) + 23 one-liner
  giver scripts. Oceangreen tasks raise 1222, Kithicor/Old Commons raise
  1223 (+150). Not chain tasks (no flags); completion = standard task.
- **v146** (`20261012_sod_themerares.sql`): the **63 static named rares**
  (always up, version 0, respawn 1h): oldblackburrow 13, oceangreenhills
  11, oceangreenvillage 13, bertoxtemple 10, oldkithicor 9, oldcommons 7.
  Instance-only rares (Javrik K`Than, High Ritualist Valdeev, Terrorvenom)
  intentionally absent. npc 1120002010-2015 = the six oldblackburrow
  rares wired into the v145 "a Blackburrow rare" kill steps; ALL 13 BB
  rares drop Severed Gnoll Finger (17313) x6 @100%. Per-rare loot =
  page items @25%, namesake upgrade @15%, 1-5pp coin. A shared supply
  lootdrop (Kithicor Apple 41121 / Freeport Sea Salt 41122 / Bag of Black
  Powder 36724 @35%) rides the windcaller (94508) and blademaster (94493)
  loottables to feed the v145 Army supply tasks.

### Theme ID allocations (verified empty 2026-10-12)

- tasks 303080-303081, 303100-303146 (band 303080-303199 reserved)
- npc_types 1120002010-1120002072 (rare band; 1120002000 was the prior max)
- spawngroups 1520008660-1520008722 (the planned 1520008650+ block was
  partially taken by v92 loremasters 1520008650-8656)
- loottables 1520008330-1520008392, lootdrops 1520008368-1520008431
  (1520008431 = shared supply drop)

### Theme simplifications vs live

- Tradeskill/forage chains (Cure the Crud, Salving Grace, Paint Supplies)
  are modelled as loot steps of the same final items (all exist and already
  drop on the era mobs in PEQ).
- Escort/dialogue-gated encounters (Run to Daylight, Disruptive Influences,
  Truth and Consequences, Power Play, Questionable Loyalties) are modelled
  as explore/speak/kill steps.
- PEQ never authored the live "poacher" and "prisoner" mobs: Poach the
  Poachers kills gnoll scouts, Truth and Consequences kills Obliteration
  knights instead.
- The Deathless' spawned treant is folded into a larger tree kill;
  Acts of Sabotage's /open warchests are kill targets (6 spawn).
- Supply pickups (apples/salt/black powder) drop from Army mobs instead of
  ground spawns (task LOOT credit from corpse loot is guaranteed).
- Rare NPC models are donor clones and spawn coordinates are TUNABLE
  (anchor + deterministic scatter); nudge in game with /loc.

## Theme completion: Kunark (v147, 2026-10-12)

Completes the raspersrealm themeKunark page (Field of Scale + Kaesora
Library/Hatchery + Kurn's Tower). One migration
(`20261012_sod_kunark_theme.sql`, generator `sod_content/gen_kunarktheme.py`):

- **Doors**: FoS's Kaesora Library (38/39/44) and Hatchery (36/37) teleport
  doors were unwired (`dest NONE`) — the two dungeons were unreachable.
  Wired to the dungeon safe points. Kurn's Tower was already wired
  (zone lines 200/210); FoS's own OBJ_VOIDPORTAL (45) already led back.
- **Tynoc faction chain**: Tynoc 452153 (Herald vendor, merchant 999999
  shared with Cirtan) had npc_faction_id 0, so his Warmly scroll gate could
  never resolve. Added npc_faction `overhaul_1224` (1520000104), and
  faction_association cascades: killing Sarnak Collective (307) or
  Sebilisian Empire (1229) trash now raises **Tynoc, Herald of Scale
  (1224)** +25/kill (`faction_amount = -25` on the theme trash flips them
  to the RewardFaction path). Kunark tasks (303020-303024 +150,
  303062 +300) raise 1224 instead of Cirtan, per the page.
- **Herald vendor** (999999): + Bone Wiring Tools 42782 (page
  Apprehensive tier, no gate) and + Emblem of Scale 103102 (page Ally
  tier = 1101). Warmly Rk. II scrolls were already at 750. Faction
  pacing: base 0 (Apprehensive) → ~3 tasks + a few kills for Warmly →
  5 tasks + raid + kills for Ally. gen_vendors.py patched to match.
- **The Grand Illusion**: Bone Mask of the Ancient Iksar 80061 existed
  with NO click effect and no source. Now clicktype 5 → Illusion: Ancient
  Iksar (13394, 2s, unlimited) — the positive-faction non-KoS illusion —
  handed out by **oldfieldofbone/452150.pl (Phara Dar)** for Skull of
  Commander Koth 17382 + Iksar Ribcage 17381 (the two FoS_T_10-14 mats
  this content set carries; they already drop from Commander Koth and the
  Imperial Advisors), +300 Tynoc.
- **37 static named rares** (always up, version 0, respawn 1h,
  donor-clone convention): Field of Scale 9, Kaesora Library 11,
  Kaesora Hatchery 7, Kurn's Tower 10. Slact the Frozen Hand and
  Researcher Neskuisa already existed. Page loot: plain items 25%,
  namesake/raid piece 15%. Spawn points are REAL elite spawn2
  coordinates read at generation time (never invented geometry) — nudge
  in game with /loc if one lands awkwardly.

### Kunark ID allocations (verified empty 2026-10-12)

- npc_types 1120002073-1120002109 (continues the v146 rare band)
- spawngroups 1520008723-1520008759
- loottables 1520008393-1520008429, lootdrops 1520008432-1520008468
- npc_faction 1520000104 (`overhaul_1224`)

### Kunark simplifications vs live

- The page's named set is the live-EQ list; this content set is
  Al'Kabor-lineage, so the 37 missing named are built as donor clones at
  real elite spawn points instead of live coordinates/models.
- Phara Dar's four sub-task chain (FoS_T_10-13) collapses to one hand-in
  of the two mats that exist in this content set (skull + ribcage); the
  Tharoff-remains and Marthor's-foot mats were never authored here.
- The theme collection reward illusion (the page's second illusion item)
  is not built — EQS has no SoD collections system; the Bone Mask covers
  the non-KoS illusion role.
- Live's Ally-tier Faycite shards are represented by the Warmly Rk. II
  scroll band (768 scrolls on the shared Herald list) + the Rk. III
  loremasters; the Al'Kabor shard items (76600+) remain dead tokens.

## Theme completion: Rathe (v150, 2026-10-13)

Completes the raspersrealm themeRathe page (Toskirakk + Korascian Warrens +
Rathe Council Chambers). One migration (`20261013_sod_rathe_theme.sql`,
generator `sod_content/gen_rathetheme.py`, manifest `manifest_v150.py`).
The cheapest theme pass: zones were already populated (v0: toskirakk 336 /
korascian 341 / rathechamber 264 spawns) and fully connected (toskirakk
zone line from all seven thevoid* zones; toskirakk<->korascian<->
rathechamber zone lines both ways), and the miscProgression chain
(303030-36) + raids (303063/303077/303079) existed since v89/v111.

- **Mitius faction chain**: Mitius, Herald of Change (475006, toskirakk)
  is the theme's Herald vendor (merchant 999999 shared with Cirtan/Tynoc)
  but had npc_faction_id 0 -- same Tynoc defect v147 fixed. Added
  npc_faction `overhaul_1225` (1520000105), pointed Mitius at it, and
  flipped the theme trash to the RewardFaction path (faction_amount -25):
  npc_faction 1520000085/86/88 (Toskirakk Slavers + Rallosian
  guards/invaders; the quest givers sharing 1520000085 are gated on
  nothing, so the flip is inert for them) plus the crystalline family by
  name (the Darkhammer delvers share npc_faction 1520000090 and stay on
  the classic path). faction_association rows 1212/1213/1216/1220 ->
  1225 already existed in this DB (re-asserted DELETE+INSERT so the twin
  is self-contained). The 10 Rathe tasks (303030-36, 303063, 303077,
  303079) now raise 1225 instead of Cirtan.
- **Herald vendor** (999999): + Miniature Armor Repair Kit 42820 /
  Miniature Armor Frame 42821 / Timeshear Coalescing Device 42886 /
  Timeshear Fragment Coalescing Device 42885 ungated (page Apprehensive
  tier; 42885/42886 were already stocked at slots 3/4 and were re-homed
  -- merchantlist has a unique (merchantid,item) key) + Emblem of Earth
  103103 at 1101 (page Ally tier; sibling of v147's Emblem of Scale).
  Warmly Rk. II = the existing 768-scroll band. Buy prices live in
  items.price and were pre-set by the content set.
- **25 theme tasks 303147-303171** (69 activities): 7 Partisan of
  Toskirakk (injured slave 475008 -> Dwerina 475002 x4 -> Wazlum 475014
  -> Jink 475010 group), 6 Mercenary of Toskirakk (Galadvert 475003 x3,
  Fregg 475058, Blurik 475029, Keruk 475066), 9 Partisan of Darkhammer
  Dwarves (Dalikand 476113 -> Delver Hagorn 476043 x4 -> Ulgin 476041 x4,
  page's full AND prereqs), 3 Hero of Toskirakk "missions" (Trilyaris
  475005; open-zone shared tasks per convention, type 2). 11 new
  one-liner giver scripts + %SOD_OFFERS entries (not chain tasks, no
  flags). All award faction 1225 +150. Hand-in items all already dropped
  on the theme trash (shackle keys on slavers, Millik parts on the ogre
  ranks, Mihkan items on slaver/bruiser/seer/champion, rat heads on
  dreadrats, Basta's head + Hornbook on their nameds, crystal fluid on
  the crystallines) EXCEPT Fresh Supplies 48961 (live hands it out as a
  task item) -- wired onto the war boar loottable (94834) at 100%.
- **33 static named rares** (v146/v147 donor-clone convention, always up,
  version 0, respawn 1h, real elite spawn2 coordinates read at gen time):
  toskirakk 13, korascian 16, rathechamber 4 (Crystalline Sorcidont
  476023 already existed). Page loot: last item 15%, the rest 25% -- all
  ~130 loot names resolved in items (this content set carries the full
  SoD Rathe loot tables incl. Enchanted/Legendary variants). The rares
  carry faction_amount -25 so they raise Mitius too.

### Rathe ID allocations (verified empty 2026-10-13)

- tasks 303147-303171 (band 303080-303199 reserved)
- npc_types 1120002110-1120002142 (continues the v147 rare band)
- spawngroups 1520008760-1520008792
- loottables 1520008430-1520008462, lootdrops 1520008469-1520008502
  (1520008502 = the Fresh Supplies war-boar drop)
- npc_faction 1520000105 (`overhaul_1225`), merchantlist 999999 slots
  775-779
- NOTE: v148/v149 were taken by concurrent same-day passes (LoN ornament
  augtype; AA level-req banding) -- the Rathe pass is v150.

### Rathe simplifications vs live

- Chronobines and the per-task Miniature Rallosian armor-shell rewards
  are out of scope (Experience 250000 per task, v145 convention).
- Live instanced missions (Trilyaris x3, request/entry phrases) are
  open-zone shared tasks; the M_1 overseer/pig/leader encounter collapses
  to overseer kills, M_2's commanders/jailors collapse to ward sergeants
  + sentinels.
- "A Plague of Mephits": PEQ never authored mephits here -- the delve
  vermin are moss spiders + the Rathecharmed scarab.
- Purchase steps (Massive Retaliation's PoK quill/vellum/ink, Cult of
  Lakkung's steak/grog from Drednig Cleave -- he IS a merchant here,
  slots 1-2) are folded away; the kill/loot substance remains.
- Blurik's Toil: Zahikk Crystal does not exist in items; the task uses 6
  Dasiron Crystals (ward sergeants drop them).
- The Prince Must Die!'s pop-up Tardunk encounter collapses to explores
  (page's own clue coordinates) + honor-guard kills; General Lobroan
  (Crimes of War's 4th general) does not exist -- the task kills Arblok,
  Bardak and Grusix (the new korascian rare, npc 1120002130).
- Augury of Time's goblin ambushes collapse to Rallosian slayer kills +
  the Blurik hail; the page's Kindly-with-Toskirakk-Slaves gates on
  Augury and the three missions are not modeled.

## Theme completion: Discord (v152, 2026-10-13)

Completes the raspersrealm themeDiscord page (Old Bloodfields + City of
Dranik + Korafax). One migration (`20261013_sod_discord_theme.sql`,
generator `sod_content/gen_discotheme.py`, manifest `manifest_v152.py`).
The progression scaffolding was already live (the Korafax arc 303040-51,
raids 303064-66, tower 303067, Void F routing, and the Korafax herald's
full 34-row page stock date to v91/v110); this pass adds what the page
has that the server didn't: the partisans, the faction split, Argoth's
stock, and the statics.

- **The two-herald faction split** (the page's signature: "Unlike other
  themes Discord has two factions"). Both heralds had npc_faction_id 0
  (vendor gates could never resolve) and all 15 existing Discord tasks
  paid Cirtan 1222 -- the same defect v147/v150 fixed elsewhere.
  - npc_faction `overhaul_1226` (1520000106) -> **Herald Argoth (1226)**:
    the herald (472002) + all 12 Bloodfields/Dranik quest NPCs. This also
    repairs a latent KOS bug: the dragorn partisans sat on the trash rows
    (1520000082/83), so GoD veterans with deep negative Discordant Army
    were attacked by their own givers; grinding now makes them warmer.
  - npc_faction `overhaul_1227` (1520000107) -> **Herald of Druzzil Ro
    (1227)**: the Korafax herald (470001) + the stranger/Telivar NPCs.
  - npc_faction `korafax_discordant` (1520000108) -> NEW faction_list
    5058 'Korafax Discordians': Korafax trash (34 npc rows / ~200 spawns)
    moves here with the kill flip, because faction_association holds ONE
    target per source faction and Bloodfields/Dranik kills (primaries
    1210/1209/1013/1767/1768) must cascade to 1226 while Korafax kills
    cascade to 1227. All theme trash runs faction_amount -25 (+25 herald
    per kill via the -1.0 associations).
  - Task flips per the page: 303040/303041 -> 1226; 303042-303051,
    303064-66, 303067 -> 1227 (amounts kept at the v91 values).
- **Argoth's vendor** (472002, slots 57-89): Apprehensive
  coalescing/repair items at -1100 (the merchant's own v110 convention),
  the Bloodfields Warmly Rk. II spells at 750, the Ally Faycite Shards +
  Emblem of Chaos 103104 at 1101 (the v150 tier convention).
  **'Song: Tempest Blade' is skipped** -- the spell does not exist in
  this content set and a dead scroll would ship broken (12 of 13 Warmly
  items resolve; add spell + item + client spells_us.txt line if wanted
  later).
- **15 partisan tasks 303172-303186** (32 activities), all solo type 0
  per the page (no (g) marks): 8 Partisan of Old Bloodfields (Yemall
  472039, Ramel 472057, Mikuv 472056, Prezul 472051 x4, Nahsulen
  472022) + 7 Partisan of City of Dranik (Azerug 474016 x2, Avlonnon
  474005, Ziven 474019, Nardic 474012 x2, Givrund 474011). 10 new
  one-liner giver scripts + %SOD_OFFERS entries (v152 block; not chain
  tasks, no flags). All award Argoth +150. The Korafax page lists are
  the pre-existing missions -- nothing new to author there.
- **Babel crystal loot**: the page's crystal rewards are out of scope
  (Experience 250000 per task, v145 convention), but Lost Memories and
  Favors of the Hopelost use the pieces as task loot -- Babel Crystal
  Chip 42825 wired at 30% onto the Old Bloodfields ikaav castigator
  loottable (94790), Babel Crystal Shard 42828 onto the City of Dranik
  one (94816), so the Dark Soul Crystal pieces are at least obtainable.
- **31 static named rares**: 29 new donor clones (oldbloodfield 9,
  olddranik 7, discord 13; always up, version 0, respawn 1h, real elite
  spawn2 coordinates read at gen time) + **#Grg`nok (470036) and #Shzalk
  (474115) patched** -- they existed but carried only MAGELO-GEN junk,
  so their page drops are appended as extra lootdrops. Page loot: last
  item 15%, the rest 25% -- all ~130 loot names resolved in items
  (zero skips; this content set carries the full SoD Discord tables).

### Discord ID allocations (verified empty 2026-10-13)

- tasks 303172-303186 (band 303080-303199 reserved, continues v150)
- npc_types 1120002143-1120002171 (continues the v150 rare band)
- spawngroups 1520008793-1520008821
- loottables 1520008463-1520008491, lootdrops 1520008503-1520008535
  (8532/8533 = the babel crystal drops, 8534/8535 = the rare patches)
- npc_faction 1520000106-1520000108, faction_list 5058, merchantlist
  472002 slots 57-89
- NOTE: v151 = a concurrent same-day pass (ornament weapon ability);
  v153 = another (warrior epic pair achievement criteria) -- both already
  in the manifest when this pass landed. version.h stays at 152, so the
  v153 entry activates on the next version bump.

### Discord simplifications vs live

- The per-task Babel/Entropy Crystal rewards (Dark Soul Crystal augment
  chain) are out of scope; the crystal pieces drop as task loot instead
  (above). The combine container is not wired.
- Lost Memories collapses to a chip gather + return (live's dialogue
  memory-layers are not modeled); Deliver the Message and A Limit to
  Despair are speak chains across the real zone NPCs.
- The Missing Chalice: no chalice item exists in this content set, so
  the task kills the thieving Acolyte Torsk and returns to Givrund
  rather than recovering an item.
- Vendor tier pacing uses the v150 conventions (-1100 / 750 / 1101);
  the Korafax herald's pre-existing stock stays flat at -1100 (v110).

## Operations notes

- This box runs with `disable_auto_updates: true`, so migrations are applied
  manually (all three SQL files sourced — done); `db_version.custom_version`
  deliberately lags the manifest max here.
- Keep manifest SQL chunks <= ~14 KB (MSVC C2026 split-literal convention);
  v91 ships as two R"SODRAID91(...)" chunks, v92 as two R"SODRK392(...)".
- Restart servers (stop-servers.bat / start-servers.bat) to pick up new
  spawns/scripts; watch zone boot logs for quest-load errors.
- Testing path: era-gate first — SoD zones require the account
  `kerafyrm`/`kerafyrm-crystallos` subflags (existing `SoD` stage prereqs),
  or GM. Then say "progress" to any giver to see flag/void state; each chain
  is testable by completing tasks in order; raids via "request"/"ready".
