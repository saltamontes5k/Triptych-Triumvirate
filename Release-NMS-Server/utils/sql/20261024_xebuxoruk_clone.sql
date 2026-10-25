-- Xebuxoruk, The Forsaken: the evil time-clone of Zebuxoruk who activates in
-- potimea at (125, 3, 182) once Quarm has fallen and the post-Quarm Druzzil
-- Ro dialogue completes. An earlier authoring pass had inserted the clone
-- directly into npc_types slot 223238 -- a live PEQ id belonging to
-- #Shadow_of_Terlok, the earth trial's replay-version boss, which silently
-- broke the Trial of Earth and the phase-5 door gate in potimeb. This entry
-- re-homes the clone to the custom band (1120001288, freeing the orphan id
-- from that same pass) and restores 223238 from its three intact sibling
-- shadows, whose stat template mirrors their champions exactly
-- (hp/AC/resists/spell set = #Shadow_of_<champion> == <Champion>'s row).
--
-- Clone row: name 'Xebuxoruk' (the pass's 'Zebuxoruk_' trailing-underscore
-- hack displays in-game), npc_faction 703 PoTime KOS (the pass had the
-- "Gargoyle" placeholder 79), runspeed 1.25 (the pass had 10, which would
-- kite the fight across the zone), aggroradius 250 for an open-world boss.
-- He stays passive until engaged (npc_aggro 0) -- you travel to him.
-- Loot: loottable 794330 "Zebuxoruk_Augs" authored by that pass.
-- Encounter script: potimea/encounters/xebuxoruk_clone.lua. Gates:
-- quest_globals xebuxoruk_unlock (forever; set at the end of the Druzzil Ro
-- dialogue) and xebuxoruk_cooldown (72h; set on defeat).
--
-- Twin of manifest entry 222.
-- Rollback: 20261024_xebuxoruk_clone_rollback.sql

-- Dormant spawn point. He respawns every 10 minutes; the encounter script
-- depops him unless the unlock global is set and the defeat cooldown has
-- expired, so first activation lands within ~10 minutes of Quarm's death and
-- repop follows the same cadence after each 72h cooldown.
INSERT INTO spawngroup (id, name, spawn_limit)
VALUES (1520009100, 'Xebuxoruk_Cycle', 1)
ON DUPLICATE KEY UPDATE name = VALUES(name), spawn_limit = VALUES(spawn_limit);

INSERT INTO spawn2 (id, spawngroupID, zone, version, x, y, z, heading,
                    respawntime, variance, pathgrid, path_when_zone_idle,
                    _condition, cond_value, animation, min_expansion, max_expansion)
VALUES (1520023800, 1520009100, 'potimea', 0, 125, 3, 182, 0,
        600, 0, 0, 0, 0, 1, 0, -1, -1)
ON DUPLICATE KEY UPDATE
  spawngroupID = VALUES(spawngroupID), zone = VALUES(zone),
  version = VALUES(version), x = VALUES(x), y = VALUES(y), z = VALUES(z),
  heading = VALUES(heading), respawntime = VALUES(respawntime),
  variance = VALUES(variance);

-- PK is (spawngroupID, npcID): repointing the cycle to the clone needs a
-- delete + insert, not an upsert.
DELETE FROM spawnentry WHERE spawngroupID = 1520009100;

INSERT INTO spawnentry (spawngroupID, npcID, chance)
VALUES (1520009100, 1120001288, 100);

-- Restore #Shadow_of_Terlok: copy of #Shadow_of_Rythor (identical chassis --
-- AC 351, regen 23, aggro 160, Corrup/PhR 93/52) with Terlok_of_Earth's
-- model (race 220, bodytype 24, texture 1), stats (hp 258000, dmg
-- 1152/278, AC 351, resists 100s), no casting (npc_spells_id 0), and the
-- champion's special-ability set.
DELETE FROM npc_types WHERE id = 223238;

INSERT INTO npc_types (
  id, name, lastname, level, race, class, bodytype, hp, mana, gender,
  texture, helmtexture, herosforgemodel, size, hp_regen_rate,
  hp_regen_per_second, mana_regen_rate, loottable_id, npc_spells_id,
  npc_spells_effects_id, npc_faction_id, mindmg, maxdmg, attack_count,
  npcspecialattks, special_abilities, aggroradius, assistradius, face,
  luclin_hairstyle, luclin_haircolor, luclin_eyecolor, luclin_eyecolor2,
  luclin_beardcolor, luclin_beard, drakkin_heritage, drakkin_tattoo,
  drakkin_details, armortint_id, armortint_red, armortint_green,
  armortint_blue, d_melee_texture1, d_melee_texture2, ammo_idfile,
  prim_melee_type, sec_melee_type, ranged_type, runspeed, MR, CR, DR, FR,
  PR, Corrup, PhR, see_invis, see_invis_undead, AC, npc_aggro,
  attack_delay, STR, STA, DEX, AGI, `_INT`, WIS, CHA, ATK, Accuracy,
  Avoidance, slow_mitigation, scalerate, flymode, exp_mod,
  heroic_strikethrough, walkspeed, show_name
)
SELECT
  223238, '#Shadow_of_Terlok', lastname, level, 220, class, 24, 258000,
  mana, gender, 1, helmtexture, herosforgemodel, size, hp_regen_rate,
  hp_regen_per_second, mana_regen_rate, 0, 0,
  npc_spells_effects_id, npc_faction_id, 278, 1152, attack_count,
  npcspecialattks, '1,1^2,1^7,1^13,1^14,1^15,1^16,1^17,1^21,1^31,1^32,1,130',
  aggroradius, assistradius, face,
  luclin_hairstyle, luclin_haircolor, luclin_eyecolor, luclin_eyecolor2,
  luclin_beardcolor, luclin_beard, drakkin_heritage, drakkin_tattoo,
  drakkin_details, armortint_id, armortint_red, armortint_green,
  armortint_blue, d_melee_texture1, d_melee_texture2, ammo_idfile,
  prim_melee_type, sec_melee_type, ranged_type, runspeed, 100, 100, 100,
  100, 100, Corrup, PhR, see_invis, 1, AC, 0,
  30, STR, STA, DEX, AGI, `_INT`, WIS, CHA, ATK, Accuracy,
  Avoidance, slow_mitigation, scalerate, flymode, exp_mod,
  heroic_strikethrough, walkspeed, show_name
FROM npc_types WHERE id = 223239;

-- The clone itself, on the freed custom-band id. Stat spread from the final
-- pass row (level 75 / 3.75M hp / AC 900 / dmg 1800-4000 / delay 25, 400s
-- across stats and resists) plus the fixes noted above.
INSERT INTO npc_types (
  id, name, lastname, level, race, class, bodytype, hp, mana, gender,
  texture, helmtexture, size, loottable_id, npc_faction_id, mindmg, maxdmg,
  attack_count, npcspecialattks, special_abilities, aggroradius,
  assistradius, face, luclin_hairstyle, luclin_haircolor, luclin_eyecolor,
  luclin_eyecolor2, luclin_beardcolor, luclin_beard, ammo_idfile,
  prim_melee_type, sec_melee_type, ranged_type, runspeed, MR, CR, DR, FR,
  PR, see_invis, AC, npc_aggro, attack_delay, STR, STA, DEX, AGI, `_INT`,
  WIS, CHA, ATK, Accuracy, trackable, `exclude`, walkspeed, flymode,
  exp_mod, heroic_strikethrough, keeps_sold_items, show_name
) VALUES (
  1120001288, 'Xebuxoruk', 'The Forsaken', 75, 295, 1, 0, 3750000, 0, 2,
  0, 0, 30, 794330, 703, 1800, 4000,
  -1, '', '1,1^2,3,1,10^3,4,1,15^4,1,5^6,1^7,1^12,1^13,1^14,1^15,1^16,1^17,1^21,1',
  250, 70, 1, 1, 1, 1, 1, 1, 0, 'IT10',
  28, 28, 7, 1.25, 400, 400, 400, 400,
  400, 1, 900, 0, 25, 400, 400, 400, 400, 400,
  400, 400, 1900, 360, 1, 1, 18, -1,
  100, 10, 1, 1
);
