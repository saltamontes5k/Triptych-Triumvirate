# RoF2 achievement port (2026-10-29)

Source: <https://github.com/nightstalker6669/eqemu-rof2-achievements>, patches
0002-0008 plus the protocol and engine notes. Patch 0001 (EQEmu PR5119) was
already in this tree; only the follow-ups were missing.

## What changed

| Upstream patch | Here |
| --- | --- |
| 0002 class rewards and common-only claims | `reward_options.class_mask` + class filtering + common-only claim token. Deviation: eligibility uses `Client::GetClassesBits()` (union of the character's permanent classes) instead of `GetBaseClass()`. |
| 0003 RoF2 destructible objects and ground-spawn charges | `common/patches/rof2.cpp` keeps `Bitfields->invis` for destructible spawns and no longer forces the suffix bit; `Zone::LoadGroundSpawns` applies `MaxCharges`. |
| 0004 unbound component completion barrier | `ClientAchievementState::EvaluateDefinition` treats every unmapped type-1 component as an unsatisfied requirement. |
| 0005/0007/0008 restricted quest item targeting | `zone/quest_item_target_permissions.h` (Shards soul targets, Slashclaw cubs, Moorwalkers) and the `SpellOnTarget` hook. Adds `Client:GetSharedTaskIdentity()`. |
| 0006 NPC-bound task selector | `Client:TaskSelectorFromNPC(npc, {tasks})`. |

Deviation in the spell hook: it also requires `IsClient()` before touching
`CastToClient()->GetInv()`, and uses this tree's legacy `SE_CHA`/`SE_Blank`
macros rather than `SpellEffect::`. Every branch is fail-closed: a spell that
does not match the exact item, task activity and target list keeps the original
"not a beneficial target" refusal.

## Schema

`reward_options.class_mask INT UNSIGNED NOT NULL DEFAULT 65535` —
`manifest_entries_custom` version 267, companion SQL
`utils/sql/20261029_achievement_reward_classes.sql`, and
`utils/sql/git/2026_10_27_achievement_reward_classes.sql`.
`CUSTOM_BINARY_DATABASE_VERSION` is 267. This project runs with
`auto_database_updates` off, so the companion SQL is applied by hand.

## Multiclass semantics

`class_mask` is a 16-bit class bitmask (bit 0 Warrior .. bit 15 Berserker).
`OptionEligibleForClass` tests `mask & GetClassesBits()`, so a Paladin /
Shadow Knight / Warrior character qualifies for an option restricted to any one
of those three. With `Custom:MulticlassingEnabled` off, `GetClassesBits()`
returns the single class bit and the behaviour is the upstream one.

## Not installed

The reviewed content (Crescent, the five Blightfire packages, Stone Hive,
Shard's Landing) is staged under `Release-NMS-Quests/_staging/rof2-achievements/`
and its SQL has not been applied. See that directory's README: the packages
re-implement NPCs we already script in Perl (29 in Crescent, 12 in Blightfire,
2 in Stone Hive), so installing them without replacing the Perl would run two
quest implementations on one spawn.
