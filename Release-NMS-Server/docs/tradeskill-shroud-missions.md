# Tradeskill Shroud Missions — Build Guide

How to add a repeatable, monster-mission-style quest that turns players into a
shroud form, throws waves of NPCs at them, and pays out a tradeskill increase.
The **Fool's Gold Cake Defense** (Baking) is the reference implementation; every
ID below is its real one, so you can copy the pattern and swap values.

> Tested on the RoF2 client with the patched `dinput8.dll`. The shroud system is
> server-side; the only client-side pieces are the shroud flag patch and the
> exported client data files.

---

## 1. What the mission is

A small expedition is created by a quest-giver NPC. On zone-in the expedition
members are transformed into a monster shroud form (immobile, form-only
abilities). The form survives 3 waves of NPCs; clearing all 3 pays a tradeskill
increase (or a fallback prize at the cap) and applies a replay lockout. Any
member death fails the run.

Design goals that make it work:

* **The form is its own creature.** Real gear, real AAs/tomes, the Nautilus
  Proc Locker, and deity blessings are all suppressed while shrouded (see §14).
  Tune for the form, not the geared character.
* **The form is immobile** by design ("tower defense"): a permanent, unbreakable
  root keeps the cake in place while the waves come to it.
* **No prep timer.** Players start the fight when they are ready, by saying a
  phrase. Every member must declare.
* **Per-character replay timer**, keyed by the expedition name.

---

## 2. Prerequisites

| Piece | Required | Notes |
|---|---|---|
| `Custom:ShroudsEnabled` | `true` | `rule_values` / `ruletypes.h` |
| `Custom:ShroudLiveMode` | `12` recommended (bit 4) | bit 4 = live-like strip + monster points + shroud AA purchases |
| `shroud.cpp` core | present | `ApplyShroud`, `RemoveShroud`, `RemoveShroudSilent`, snapshots |
| Patched client `dinput8.dll` | present | retargets the profile shroud-state store; needed for the RoF2 shroud flag |
| Client data exports | on demand | `dbstr_us.txt` for new AA strings, `spells_us.txt` if you add/edit spells |
| Custom migration twin | per DB version | see §13 |

The server enforces `RuleB(Custom, ShroudsEnabled)` inside `Client::ApplyShroud`;
with the rule off, the whole feature is inert.

---

## 3. Architecture

```
Quest giver (Bazaar, npc_types)  --hail / "ready"-->  CreateExpedition
                                                        |  zone = <zone> v<ver>
                                                        |  duration = 2h
                                                        |  compass / safereturn / zonein
                                                        v
                       Dynamic zone instance (zone table clone, version N)
                                                        |
              +-----------------------------------------+----------------------+
              |                                                                |
   player.lua (zone player script)                          #Controller (npc script)
   - every member must say the ready phrase                  - 5s poll
   - signals the controller when all cakes are ready         - shroud / re-shroud members
   - on death: unshroud + signal fail                        - cast icing + root
                                                             - spawn waves / count kills
                                                             - win: skill reward + lockout
                                                             - fail: message + kick
```

### Components and the cake's IDs

| Component | Table / file | Cake value |
|---|---|---|
| Instance zone version | `zone` | `id 9147`, `zoneidnumber 19`, `version 202` |
| Quest giver | `npc_types` + `bazaar/Wendel_Sweetcrumb.lua` | `1520001800` |
| Controller | `npc_types` + `rivervale/#Cake_Defense_Baker.lua` | `1520001801` |
| Shroud form | `shrouds` | `500` "Birthday Cake 25" |
| Ability catalog | `shroud_abilities` + `aa_ability`/`aa_ranks`/`aa_rank_effects`/`db_str` | `90102-90114` |
| Wave NPCs | `npc_types` | `1520001810/1811/1812` |
| Spawns | `spawngroup`/`spawnentry`/`spawn2` | `5004501/5004502` |
| Zone player script | `<zone>/player.lua` | `rivervale/player.lua` |
| Safety net | `global/global_player.pl` | race 629 branch |

ID bands used by this fork: `15200018xx` for mission NPCs, `5004xxx` for
spawngroups, `1520023xxx` for spawn2, `90xxx` for the hand-made ability band
(the guide catalog uses `91xxx`). Keep all AA ids **under 100000** — the patched
client scans only to 100000.

---

## 4. Pick the tradeskill

The reward uses the **skill id**, which is *not* the recipe `tradeskill` id.
Use the `SkillType` enum (`common/skills.h`), which matches the client and the
recipe table:

| Skill | ID | Skill | ID |
|---|---|---|---|
| Fishing | 55 | Baking | 60 |
| Make Poison | 56 | Tailoring | 61 |
| Tinkering | 57 | Blacksmithing | 63 |
| Research | 58 | Fletching | 64 |
| Alchemy | 59 | Brewing | 65 |
| Jewelry Making | 68 | Pottery | 69 |

> **Gotcha:** `IncreaseSkill(56, ...)` trains Make Poison, not Baking. Verify with
> `SELECT tradeskill, name FROM tradeskill_recipe WHERE tradeskill=<id> LIMIT 1;`
> — bread/cake/pie recipes are `60`. The cap is 300 (the quest clamps).

Pick one mission per skill. Give each mission a **unique expedition name** —
that name is the replay-timer key, so different missions naturally have
different timers.

---

## 5. Create the shroud form

One row in `shrouds`. `progression`/`branch` are the catalog keys the quest's
`ApplyShroud` and the ability gate use.

```sql
DELETE FROM `shrouds` WHERE `id` = 500 OR `progression` = 'Confections';
INSERT INTO `shrouds`
  (`id`,`name`,`progression`,`branch`,`level`,`race`,`gender`,`class`,
   `texture`,`helmet_texture`,`size`,`hp`,`mana`,`endurance`)
SELECT
  500, 'Birthday Cake 25', 'Confections', 'Birthday Cake', b.`level`,
  629, 2, 14, 0, 255, 6.0,
  CAST(ROUND(5 + b.`hp` + b.`hp_fac` * 75) AS SIGNED),
  CASE WHEN b.`mana` > 0
       THEN CAST(ROUND(b.`mana` + b.`mana_fac` * 75) AS SIGNED) ELSE 0 END,
  CAST(ROUND(b.`end` + b.`end_fac` * 75) AS SIGNED)
FROM base_data b
WHERE b.`level` = 25 AND b.`class` = 14;
```

Notes:

* `race` is the model/race id. **629** is the cake model. It also drives the
  movement anchor and the `global_player.pl` safety net — if you use a new race,
  update both.
* `class` is the **form's** class (14 = Enchanter). This is what the client sees
  and what class skills are granted (`ShroudApplyClassSkills`).
* `hp`/`mana`/`endurance` are the values sent to the client for the shroud stat
  block. The **actual** server pool is `base_data` for that class/level plus
  bonuses — see §15.
* `size` is the model scale (6.0 = three times the default 2.0 cake).

---

## 6. Create the ability catalog

The form's abilities are normal AAs. Four rows per rank plus the mapping.

### 6.1 `aa_ability` (one per line)

```sql
INSERT INTO `aa_ability`
 (`id`,`name`,`category`,`classes`,`races`,`drakkin_heritage`,`deities`,
  `status`,`type`,`charges`,`grant_only`,`first_rank_id`,`enabled`,
  `reset_on_death`,`auto_grant_enabled`)
VALUES
 (90104,'Birthday Blowout',-1,65535,65535,127,131071,0,1,0,0,90303,1,0,0);
```

`category = -1` is fine (the shroud byte is what marks the row for the monster
pane). `first_rank_id` points at the first `aa_ranks` row.

### 6.2 `aa_ranks` (one per rank)

```sql
INSERT INTO `aa_ranks`
 (`id`,`upper_hotkey_sid`,`lower_hotkey_sid`,`title_sid`,`desc_sid`,
  `cost`,`level_req`,`spell`,`spell_type`,`recast_time`,`expansion`,
  `prev_id`,`next_id`)
VALUES
 (90303, 90104, 90104, 90104, 90104, 1, 1, 8328, 0, 120, 0, -1, -1);
```

* **`upper_hotkey_sid` / `lower_hotkey_sid` must equal `title_sid`.** If they are
  `-1` the client puts a blank button on the hotbar.
* `spell` is the real spell cast by an **active** ability (e.g. Gale Force 8328).
  A **passive** must use `spell = -1` and carry its effect in `aa_rank_effects`,
  or the client will treat it as a castable button.
* `cost` is monster points (1 is typical for a 10-ability kit; the level-25 pool
  is 36).
* Chain ranks with `prev_id`/`next_id` when a line has multiple ranks.

### 6.3 `aa_rank_effects` (passives only)

```sql
INSERT INTO `aa_rank_effects` (`rank_id`,`slot`,`effect_id`,`base1`,`base2`)
VALUES (90301, 1, 6, 2, 0);   -- SPA 6 = AGI, +2
```

### 6.4 `db_str` (name/category/short/description)

```sql
INSERT INTO `db_str` (`id`,`type`,`value`) VALUES
 (90104,1,'Birthday Blowout'),
 (90104,2,'Confection'),
 (90104,3,'Blowout'),
 (90104,4,'Unleash a shockwave of party candles. (All Classes)');
```

Type 1 = name, 2 = category label, 3 = short name, 4 = description.

### 6.5 `shroud_abilities` (the gate)

```sql
INSERT INTO `shroud_abilities`
 (`progression`,`branch`,`min_level`,`kind`,`max_rank`,`aa_id`,`display_order`)
VALUES
 ('Confections','Birthday Cake',1,'active',0,90104,3);
```

This is what `LoadShroudAbilityCaps` reads. The form only sees the rows matching
its `progression`, `branch` (or empty branch), and `min_level <= form level`.
`kind` is `active`/`passive`; `max_rank = 0` means "not recorded" and does not
block a purchase.

> Any catalog row also marks the AA as a shroud AA for `IsShroudAA()` (along
> with the legacy `90100-90199` band). That is how reused classic AAs work.

### 6.6 Client export

New/changed `db_str` rows require a **`dbstr_us.txt` re-export** and a copy to
the client root and `Resources/`, then a client restart. Changing `aa_ranks`
hotkey sids does **not** need an export (the strings already exist); only the
zone needs a restart so the new AA table is sent.

---

## 7. Wave NPCs

Three tiers, one per wave, in `npc_types`. They must have `npc_aggro = 1` so
they charge the cakes.

```sql
INSERT INTO `npc_types`
 (`id`,`Name`,`lastname`,`level`,`race`,`class`,`bodytype`,`hp`,`gender`,
  `texture`,`helmtexture`,`size`,`runspeed`,`mindmg`,`maxdmg`,`attack_delay`,
  `AC`,`npc_aggro`,`aggroradius`,`npc_faction_id`,`npc_spells_id`,
  `merchant_id`,`loottable_id`)
VALUES
 (1520001810,'a_peckish_adventurer','Could eat a whole halfling',
  24,1,1,1,270,0,0,0,6,1.25,5,12,30,200,1,150,0,0,0,0),
 (1520001811,'a_famished_adventurer','Has not eaten in days',
  25,1,1,1,330,0,1,0,6,1.25,6,14,30,220,1,150,0,0,0,0),
 (1520001812,'a_ravenous_adventurer','Smells frosting from a zone away',
  26,1,1,1,390,0,2,0,6,1.25,7,16,30,240,1,150,0,0,0,0);
```

`special_abilities = '21,1'` (FleeingImmunity) stops them from running at low HP.

`npc_types` is cached at zone boot — **restart the zone layer** after edits.

---

## 8. Create the instance zone version

Clone the base zone row as a new `version`. The version is what isolates the
instance from the live zone (spawns only load when `spawn2.version = <version>`
or `-1`).

```sql
DELETE FROM `zone` WHERE `zoneidnumber` = 19 AND `version` = 202;
DROP TEMPORARY TABLE IF EXISTS `tmp_zone`;
CREATE TEMPORARY TABLE `tmp_zone` AS
  SELECT * FROM `zone` WHERE `zoneidnumber` = 19 AND `version` = 0 LIMIT 1;
UPDATE `tmp_zone`
   SET `id` = (SELECT COALESCE(MAX(`id`),0) + 1 FROM `zone`),
       `version` = 202,
       `long_name` = 'Rivervale: Fool''s Gold Cake Defense';
INSERT INTO `zone` SELECT * FROM `tmp_zone`;
DROP TEMPORARY TABLE `tmp_zone`;
```

`CREATE TABLE ... AS SELECT` drops `auto_increment`, so assign `id` explicitly.

---

## 9. Spawns

The quest giver is a normal world spawn. The controller lives in the instance.

```sql
DELETE FROM `spawngroup` WHERE `id` IN (5004501,5004502);
DELETE FROM `spawnentry` WHERE `spawngroupID` IN (5004501,5004502);
DELETE FROM `spawn2` WHERE `id` IN (1520023003,1520023004);

INSERT INTO `spawngroup` (`id`,`name`) VALUES
 (5004501,'wendel_sweetcrumb_bazaar'),
 (5004502,'cake_defense_controller_rivervale_202');

INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES
 (5004501,1520001800,100),
 (5004502,1520001801,100);

INSERT INTO `spawn2`
 (`id`,`spawngroupID`,`zone`,`version`,`x`,`y`,`z`,`heading`,`respawntime`,`variance`)
VALUES
 (1520023003,5004501,'bazaar',   0, 150,-496,3,0,7200,0),
 (1520023004,5004502,'rivervale',202,-160,-90,3,0,0,0);
```

* The controller's `spawn2.version` **must** be the instance version (or `-1`);
  otherwise the instance boots with no controller and nothing happens.
* The `spawn2` id band is shared across sessions — re-grep `MAX(id)` before
  inserting in a live DB.
* Quest scripts resolve by **NPC name**: renaming an NPC orphans its script.

---

## 10. The quest giver

`quests/bazaar/<Npc_Name>.lua`. Handles the pitch, the level gate, creating the
expedition, and moving members in.

```lua
local EXPEDITION_NAME = "The Fool's Gold Cake Defense"
local MIN_LEVEL       = 25

local cake_defense = {
	expedition = { name = EXPEDITION_NAME, min_players = 1, max_players = 6 },
	instance   = { zone = "rivervale", version = 202, duration = eq.seconds("2h") },
	compass    = { zone = "bazaar", x = 150, y = -496, z = 3 },
	safereturn = { zone = "bazaar", x = 185, y = -835, z = 4, h = 390 },
	zonein     = { x = -134, y = -61, z = 3, h = 0 },
}

local function on_expedition(client)
	local dz = client:GetExpedition()
	return dz.valid and dz:GetName() == EXPEDITION_NAME
end

function event_say(e)
	if e.message:findi("hail") then
		e.self:Say(string.format(
			"Fresh bread! Ask me about the %s.", eq.say_link("Cake Defense")))
	elseif e.message:findi("cake defense") then
		if e.other:GetLevel() < MIN_LEVEL then
			e.self:Say("Come back at level 25.")
		elseif on_expedition(e.other) then
			e.self:Say("Your defense is assembling -- say 'ready'.")
		else
			e.self:Say("Guard the cake. Say " .. eq.say_link("ready") .. ".")
		end
	elseif e.message:findi("ready") then
		if on_expedition(e.other) then
			e.other:MovePCDynamicZone(e.other:GetExpedition():GetZoneID())
		else
			local dz = e.other:CreateExpedition(cake_defense)
			if dz.valid then
				e.self:Say("Into the oven! Others say " .. eq.say_link("ready") .. " to follow.")
			end
		end
	end
end
```

`CreateExpedition` is blocked while the character has a live replay lockout for
that expedition name; that is the per-mission timer.

---

## 11. The controller (the state machine)

`quests/<zone>/#<Controller_Name>.lua`. One NPC, one script, one poll.

### 11.1 Structure

```lua
local VERSION      = 202
local SHROUD_ID    = 500
local ZONE_ID      = 19          -- zoneidnumber, not zone.id
local ICING_SPELL  = 44025       -- optional flavour/slow
local ROOT_SPELL   = 13836       -- Parsing Root: the real immobilizer
local WAVE_NPCS    = { 1520001810, 1520001811, 1520001812 }
local WAVE_BASE    = 2
local WAVE_MULT    = 1           -- solo = WAVE_BASE + 1
local RING         = { {35,0},{0,35},{-35,0},{0,-35},
                       {25,25},{-25,25},{25,-25},{-25,-25} }
local CENTER       = { x = -134, y = -61, z = 3 }
local HOME_ZONE    = 151
local HOME         = { x = 185, y = -835, z = 4, h = 390 }
local INTERWAVE    = eq.seconds("60s") * 1000
local POLL         = 5000
local SEND_HOME    = eq.seconds("10s") * 1000
local SKILL        = 60          -- Baking
local CAP          = 300
local REWARD       = 30
local BOOBY        = { { id = 13046, stack = 100, name = "fruit" },
                       { id = 13088, stack = 100, name = "snake eggs" } }

local state, wave = "idle", 0
local seen_unshrouded, prepared, poll_count = {}, {}, 0
```

### 11.2 Helpers

* `members_in_zone()` — clients whose `GetExpedition()` matches this zone +
  version.
* `cakes_in_zone(members)` — members with `GetRace() == <form race>`.
* `wave_npcs_alive()` — count NPCs of the current tier.
* `dismiss_pets(client)` — `client:GetPet()` then `pet:Depop()`. **`RemovePet`
  only detaches the owner**, so depop the mob itself. Call it on shroud and on
  every poll.
* `strip_icing(client)` — `BuffFadeBySpellID(ROOT)` and `(ICING)`.
* `spawn_wave()` — `count = min((WAVE_BASE + #cakes) * WAVE_MULT, #RING)`;
  `eq.spawn2(tier, 0, 0, CENTER.x + off[1], CENTER.y + off[2], CENTER.z, 0)`.

### 11.3 The poll (every 5 s)

1. Bail if `state` is `won`/`failed`.
2. **Death check:** any member with `GetHP() <= 0` -> strip, unshroud silently,
   `fail_defense()`.
3. **Prepare members** (the 5 s zone-settle window matters — the RoF2 client
   crashes if `OP_Shroud` arrives mid-zone-build):
   * If `GetRace() ~= <form race>` and the member was present last poll:
     `ApplyShroud(SHROUD_ID)`, `dismiss_pets`, `BuffFadeAll()`, cast
     `ICING_SPELL`, cast `ROOT_SPELL`, mark prepared, message the player.
   * If already the form race but not prepared (a **persisted** shroud from a
     logout): same preparation once.
   * If prepared: recast icing/root when `FindBuff()` is false.
4. **Idle chatter** (optional).
5. **Wave logic** (state `wave`): re-fixate hate on the cakes; if
   `wave_npcs_alive() == 0`, advance:
   * `wave > 3` -> **victory**: `AddReplayLockout(18h)`, reward each cake, home
     in 10 s.
   * else -> `state = "prep"`, one-minute timer, then spawn the next wave.

### 11.4 The ready check (player.lua)

`quests/<zone>/player.lua` is a zone-wide player script. It owns the
per-character declaration table and only signals the controller when **every**
cake has declared.

```lua
local VERSION, ZONE_ID = 202, 19
local CONTROLLER = 1520001801
local PHRASE = "i am delicious"
local declared = {}

local function on_expedition(c)
	local dz = c:GetExpedition()
	return dz.valid and dz:GetZoneID() == ZONE_ID and dz:GetZoneVersion() == VERSION
end

local function cake_counts()
	local total, ready = 0, 0
	for c in eq.get_entity_list():GetClientList().entries do
		if c.valid and c:GetRace() == 629 and on_expedition(c) then
			total = total + 1
			if declared[c:CharacterID()] then ready = ready + 1 end
		end
	end
	return ready, total
end

function event_say(e)
	if eq.get_zone_instance_version() ~= VERSION then return end
	if not e.message:findi(PHRASE) or not on_expedition(e.self) then return end
	if e.self:GetRace() ~= 629 then
		e.self:Message(15, "Wait until the baker coats you.")
		return
	end
	local id = e.self:CharacterID()
	if declared[id] then
		e.self:Message(15, "You already declared. Let the others speak.")
		return
	end
	declared[id] = true
	local ready, total = cake_counts()
	eq.zone_emote(15, string.format("%s declares their deliciousness. %d of %d cakes ready.",
		e.self:GetCleanName(), ready, total))
	if total > 0 and ready >= total then
		declared = {}
		eq.signal(CONTROLLER, 1)
	end
end

function event_death(e)
	if eq.get_zone_instance_version() ~= VERSION then return end
	if not on_expedition(e.self) then return end
	e.self:RemoveShroudSilent()
	eq.signal(CONTROLLER, 2)
end
```

Signal `1` = start, `2` = fail. Guard `event_death` by expedition membership so
a stray GM death does not wipe the run.

### 11.5 Victory

```lua
local exp = eq.get_expedition()
if exp.valid then exp:AddReplayLockout(eq.seconds("18h")) end
for _, cake in ipairs(cakes) do
	strip_icing(cake)
	cake:RemoveShroud()
	local skill = cake:GetSkill(SKILL)
	if skill < CAP then
		local gain = math.min(REWARD, CAP - skill)
		local newvalue = skill + gain
		cake:SetSkill(SKILL, newvalue)          -- NOT IncreaseSkill
		cake:Message(15, string.format("You have learned %d points (now %d/%d).",
			gain, newvalue, CAP))
	else
		local prize = BOOBY[math.random(1, #BOOBY)]
		cake:AddAAPoints(1)
		cake:SummonItem(prize.id, prize.stack)
		cake:Message(15, string.format("You take a stack of %s instead.", prize.name))
	end
end
eq.set_timer("send_home", SEND_HOME)
```

**`IncreaseSkill` is an inline that only adds to `m_pp.skills[]`** — it never
saves and never sends `OP_SkillUpdate`, so the reward vanishes on zone. Use
`SetSkill`.

### 11.6 Defeat

Loud, then a hard kick:

```lua
eq.zone_emote(MT.Red, "The defense has FAILED.")
for _, c in ipairs(members_in_zone()) do
	c:SendMarqueeMessage(MT.Red, 255, 1000, 1500, 4000, "THE DEFENSE HAS FAILED")
	c:Message(MT.Red, "You are cast out of the expedition.")
	c:SendSound()
	strip_icing(c)
	c:RemoveShroud()
end
eq.set_timer("fail_kick", 5000)
-- later:
local exp = eq.get_expedition()
if exp.valid then
	exp:SetLocked(true, 2)
	exp:RemoveAllMembers()   -- tears down the expedition / teleports clients out
end
```

`RemoveAllMembers()` is exposed to Lua (`Lua_Expedition::RemoveAllMembers`). It
removes every member and the zone teleports the clients out to the safe return.
No replay lockout on failure — the group can retry immediately.

### 11.7 The form's immobility

A pure speed debuff is **not** enough: `mob.cpp` floors a snare at -85% and the
client does the same, so the cake only crawls. Use a **beneficial, unresistable,
permanent root**:

* `Parsing Root` (spell 13836): beneficial (`goodEffect=1`), `resisttype 0`,
  `SPA 99`, formula 50 (permanent). Damage cannot break it
  (`TryRootFadeByDamage` only runs for detrimental roots) and the per-tick
  player root check returns 100 for `resisttype 0`.
* It is stock content, so it needs **no spell export or shared-memory regen**.

Keep a flavour spell (the icing) for the visual/slow, but the root is what
actually stops movement. There is also a race-anchored server-side position
push in `client_packet.cpp`, kept as belt-and-suspenders.

---

## 12. The safety net (zone-out / LD)

`quests/global/global_player.pl`, `EVENT_ENTERZONE`. The shroud snapshot
re-applies the form on **every** zone-in, so a cake that leaves the mission must
be unshrouded on arrival.

```perl
if ($client->GetRace() == 629
    && !($zonesn eq 'rivervale' && $client->GetZoneInstanceVersion() == 202)) {
    $client->BuffFadeBySpellID(13836);
    $client->BuffFadeBySpellID(44025);
    $client->RemoveShroudSilent();
}
```

Add a clause per mission if it uses a different form race or zone. Also re-apply
deity blessings on respawn (`plugin::BlessingOnEnterZone($client)`) as the file
already does.

---

## 13. Persistence: migration manifest + SQL twin

Every mission must exist in two places:

1. **`common/database/database_update_manifest_custom.cpp`** — a `ManifestEntry`
   asking for the new DB version. Use an idempotent `check` (e.g.
   `SELECT id FROM shrouds WHERE id = 500`) and a `condition` of `empty`.
2. **`utils/sql/<date>_<mission>.sql`** — the same SQL, applied by hand on this
   server (the manifest runner does **not** apply custom migrations here).

Workflow on this box:

```bash
mysql -u eqemu -peqemu peq < utils/sql/20261008_cake_defense.sql
mysql -u eqemu -peqemu peq -e "UPDATE db_version SET custom_version=121"
# restart zones
```

Keep the two copies byte-identical (the manifest is the fresh-install path; the
twin is the live path). Bump `CUSTOM_BINARY_DATABASE_VERSION` in
`common/version.h` with the entry.

---

## 14. What the shroud system already does for you

These are automatic for **any** shroud form; do not re-implement them in the
quest:

| Behaviour | Where |
|---|---|
| Real gear (stats, focus, weapon procs) suppressed | `Client::CalcBonuses` |
| Real AAs/tomes suppressed; only `IsShroudAA` lines apply | `Mob::CalcAABonuses` |
| Nautilus Proc Locker focus suppressed | `Mob::GetFocusEffect` |
| Deity blessings/procs suppressed | `plugins/deity_blessings.pl` (`$c->IsShrouded()`) |
| Melee uses the form's hands, not real weapons | `Mob::Attack` / `GetWeaponDamage` |
| XP re-based to the form's level (no level-up back to real level) | `shroud.cpp` + `SetEXP` |
| Form class skills granted | `ShroudApplyClassSkills` |
| Shroud snapshot across zones/relogs | `character_shroud_snapshot` |
| Monster-point purchases | `character_shroud_points` / `aa` |

Pets are **not** automatic — the mission must dismiss them (see §11.2).

---

## 15. Tuning knobs

| Knob | Where | Effect |
|---|---|---|
| `WAVE_BASE` / `WAVE_MULT` | controller | adventurers per wave |
| `INTERWAVE` | controller | pause between waves |
| `npc_types.hp/mindmg/maxdmg/AC` | DB | wave difficulty |
| `shrouds.hp/mana/endurance` | DB | **displayed** form pool (see caveat) |
| `shrouds.size` | DB | model scale |
| `SKILL` / `CAP` / `REWARD` | controller | reward rate |
| `BOOBY` | controller | at-cap fallback |
| replay lockout | controller | pacing (`AddReplayLockout`) |
| `aa_ranks.recast_time` / `cost` | DB | ability power/purchase cost |

**Caveat:** the form's actual HP/mana come from `base_data` (class/level) plus
bonuses, not from the `shrouds` columns — those feed the client's shroud stat
block. If a form feels too squishy after gear suppression, either tune the wave
NPCs or add a form-owned resource override in `CalcMaxHP`/`CalcMaxMana`.

---

## 16. Testing checklist

1. **Boot** — restart zones; check the zone log for quest errors.
2. **Create** — hail the giver, say the link, say `ready`; confirm the expedition
   window and that you land at `zonein`.
3. **Shroud** — within ~5 s you should be the form, rooted, and messaged. Confirm
   race/level in the target window.
4. **Abilities** — open the AA window, buy one, drag it to a hotbar. It must show
   a **name** (blank = hotkey sids) and work.
5. **Pets** — summon a pet before entering; it must be gone after the shroud.
6. **Ready check** — with two players, only one declaring must **not** start the
   wave; both must.
7. **Waves** — count the spawns; verify the tier per wave and the pause.
8. **Win** — clear 3 waves; verify `character_skills` for the reward, the
   lockout row, and the ride home.
9. **Fail** — die; verify the red marquee/sound, the unshroud, and the kick.
10. **Zone-out** — leave mid-run; verify the race-629 safety net unshrouds you.

Useful queries:

```sql
SELECT id, name, race, class, level, size FROM shrouds WHERE id = 500;
SELECT character_id, skill_id, value FROM character_skills WHERE skill_id = 60;
SELECT * FROM character_expedition_lockouts WHERE character_id = <id>;
SELECT id, Name, hp, mindmg, maxdmg, npc_aggro FROM npc_types
  WHERE id BETWEEN 1520001810 AND 1520001812;
```

---

## 17. Pitfalls (all of these bit us)

| Symptom | Cause | Fix |
|---|---|---|
| Blank hotbar buttons | `upper/lower_hotkey_sid = -1` | set them equal to `title_sid` |
| Reward trains the wrong skill | `IncreaseSkill(56)` is Make Poison; Baking is 60 | verify with `tradeskill_recipe` |
| Reward vanishes on zone | `IncreaseSkill` is an inline, unsaved | use `SetSkill` |
| `Ambiguous, candidates` in Lua | duplicate `BuffFadeBySpellID` bindings | one binding only |
| Cake still moves | only a speed debuff was applied | add a beneficial permanent root (13836) |
| Adventurers "invulnerable" | shroud gear failed the level/class check -> 0 damage | form fights with its hands |
| Real tomes/procs/locker/blessings on the form | not suppressed | the §14 core guards |
| Deaths don't fail the run | `event_death` had no membership guard | guard by expedition |
| Only one cake declares | `player.lua` signalled on the first say | per-character ready check |
| Level jumps back to real level on first kill | `m_pp.exp` not re-based | shroud core re-base (already in) |
| Controller missing in instance | `spawn2.version` not the instance version | set 202 (or -1) |
| Quest script ignored after rename | scripts resolve by NPC name | rename the script too |
| `CREATE TABLE AS SELECT` + `SET id=NULL` fails | auto_increment dropped | assign `id` explicitly |
| Duplicate spawn ids across sessions | shared `1520023xxx` band | re-grep `MAX(id)` |
| Lua `entity_list` iteration | `.entries` is an iterator function | `for x in list.entries do` |
| No `EVENT_SHOUT` / `EVENT_LEAVE_ZONE` | old event set | use `/say` and zone scripts |
| NPC `CastSpell` of a beneficial root fails checks | `NPCBuffLevelRestrictions` | rule is off by default |

---

## 18. Copy-paste templates

### 18.1 Mission skeleton (controller)

```lua
-- <zone>/#<Controller>.lua
local VERSION, SHROUD_ID, ZONE_ID = 202, 500, 19
local ICING, ROOT = 44025, 13836
local WAVE = { 1520001810, 1520001811, 1520001812 }
local BASE, MULT = 2, 1
local RING = { {35,0},{0,35},{-35,0},{0,-35},
               {25,25},{-25,25},{25,-25},{-25,-25} }
local C = { x = -134, y = -61, z = 3 }
local HOME_ZONE, HOME = 151, { x = 185, y = -835, z = 4, h = 390 }
local SKILL, CAP, REWARD = 60, 300, 30
local BOOBY = { { id = 13046, stack = 100, name = "fruit" } }
local state, wave, poll_count = "idle", 0, 0
local seen, prepared = {}, {}

local function members()
	local out = {}
	for c in eq.get_entity_list():GetClientList().entries do
		if c.valid then
			local dz = c:GetExpedition()
			if dz.valid and dz:GetZoneID() == ZONE_ID and dz:GetZoneVersion() == VERSION then
				table.insert(out, c)
			end
		end
	end
	return out
end

local function cakes(m)
	local out = {}
	for _, c in ipairs(m) do if c:GetRace() == 629 then table.insert(out, c) end end
	return out
end

local function alive()
	local n = 0
	for x in eq.get_entity_list():GetNPCList().entries do
		if x.valid and wave > 0 and x:GetNPCTypeID() == WAVE[wave] then n = n + 1 end
	end
	return n
end

local function strip(c)
	c:BuffFadeBySpellID(ROOT); c:BuffFadeBySpellID(ICING)
end

local function pets(c)
	local p = c:GetPet()
	if p and p.valid then p:Depop() end
end

local function spawn_wave()
	local n = math.min((BASE + #cakes(members())) * MULT, #RING)
	eq.zone_emote(15, string.format("Wave %d!", wave))
	for i = 1, n do
		local o = RING[i]
		eq.spawn2(WAVE[wave], 0, 0, C.x + o[1], C.y + o[2], C.z, 0)
	end
end

local function fail()
	state = "failed"
	for _, id in ipairs(WAVE) do eq.depop(id) end
	eq.zone_emote(MT.Red, "The defense has FAILED.")
	for _, c in ipairs(members()) do
		c:SendMarqueeMessage(MT.Red, 255, 1000, 1500, 4000, "THE DEFENSE HAS FAILED")
		c:Message(MT.Red, "You are cast out of the expedition.")
		c:SendSound()
		strip(c); c:RemoveShroud()
	end
	eq.set_timer("fail_kick", 5000)
end

function event_spawn(e)
	state, wave, poll_count, seen, prepared = "idle", 0, 0, {}, {}
	eq.set_timer("poll", 5000)
end

function event_signal(e)
	if e.signal == 1 and state == "idle" then
		state, wave = "wave", 1
		spawn_wave()
	elseif e.signal == 2 and (state == "prep" or state == "wave") then
		fail()
	end
end

function event_timer(e)
	if e.timer == "poll" then
		if state == "won" or state == "failed" then return end
		poll_count = poll_count + 1
		local m = members()
		for _, c in ipairs(m) do
			if c:GetHP() <= 0 then strip(c); c:RemoveShroudSilent(); fail(); return end
		end
		for _, c in ipairs(m) do
			pets(c)
			local id = c:CharacterID()
			if c:GetRace() ~= 629 then
				if seen[id] then
					c:ApplyShroud(SHROUD_ID); c:BuffFadeAll()
					e.self:CastSpell(ICING, c:GetID()); e.self:CastSpell(ROOT, c:GetID())
					prepared[id] = true; seen[id] = nil
					c:Message(15, "You are the form now. Say the ready phrase.")
				else
					seen[id] = true
				end
			else
				seen[id] = nil
				if not prepared[id] then
					prepared[id] = true; c:BuffFadeAll()
					e.self:CastSpell(ICING, c:GetID()); e.self:CastSpell(ROOT, c:GetID())
				else
					if not c:FindBuff(ICING) then e.self:CastSpell(ICING, c:GetID()) end
					if not c:FindBuff(ROOT) then e.self:CastSpell(ROOT, c:GetID()) end
				end
			end
		end
		if state == "wave" then
			for x in eq.get_entity_list():GetNPCList().entries do
				if x.valid and x:GetNPCTypeID() == WAVE[wave] then
					for _, c in ipairs(cakes(m)) do x:AddToHateList(c, 100, 0) end
				end
			end
			if alive() == 0 then
				wave = wave + 1
				if wave > 3 then
					state = "won"
					local dz = eq.get_expedition()
					if dz.valid then dz:AddReplayLockout(eq.seconds("18h")) end
					for _, c in ipairs(cakes(m)) do
						strip(c); c:RemoveShroud()
						local s = c:GetSkill(SKILL)
						if s < CAP then
							local g = math.min(REWARD, CAP - s)
							c:SetSkill(SKILL, s + g)
							c:Message(15, string.format("You learned %d points.", g))
						else
							local p = BOOBY[math.random(1, #BOOBY)]
							c:AddAAPoints(1); c:SummonItem(p.id, p.stack)
							c:Message(15, string.format("Take a stack of %s.", p.name))
						end
					end
					eq.set_timer("home", 10000)
				else
					state = "prep"
					eq.set_timer("next", 60000)
				end
			end
		end
	elseif e.timer == "next" then
		if state ~= "prep" then return end
		state = "wave"; spawn_wave()
	elseif e.timer == "home" then
		for _, c in ipairs(members()) do
			c:MovePC(HOME_ZONE, HOME.x, HOME.y, HOME.z, HOME.h)
		end
		eq.depop()
	elseif e.timer == "fail_kick" then
		local dz = eq.get_expedition()
		if dz.valid then dz:SetLocked(true, 2); dz:RemoveAllMembers() end
		eq.depop()
	end
end
```

### 18.2 Idempotent SQL template

```sql
-- 1. zone version clone
-- 2. shrouds row
-- 3. aa_ability / aa_ranks / aa_rank_effects / db_str / shroud_abilities
-- 4. npc_types (giver, controller, 3 waves)
-- 5. spawngroup / spawnentry / spawn2
-- Every block starts with a DELETE keyed on the mission's ids.
```

---

## 19. Mission registry

Track the line here so ids and timers do not collide.

| Mission | Skill | ID | Zone / ver | Form | Giver | Controller | Lockout |
|---|---|---|---|---|---|---|---|
| Fool's Gold Cake Defense | Baking (60) | 500 | rivervale / 202 | Birthday Cake 25 (race 629) | 1520001800 | 1520001801 | 18 h |
| _(next)_ | | | | | | | |

Each row gets its own expedition name (its own timer), its own giver NPC, and —
if it uses a different form race — its own safety-net clause in
`global_player.pl`.
