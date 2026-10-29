# Shard's Landing Partisan content

This scoped package adds **Welcome to Shard's Landing**, the seven following Partisan tasks, and the Eastern Wastes portal activation. It includes the achievement definition/bindings, quest hooks, recipes, papers, necessary zone access and door corrections. It requires the root achievement engine patches **0001 through 0005** and a compatible PEQ database.

**All nine scoped task routes now have native completion evidence**, including both optional tasks and persisted Partisan completion. This is not a complete Rain of Fear quest catalogue or a native validation of a separate clean installation. See `provenance/native-status.json` for exact per-route boundaries.

| Quest | NPC | Keyword |
|---|---|---|
| Welcome to Shard's Landing | Overseer Drent | hail |
| Exploring Shard's Landing | Overseer Drent | scouting |
| Words of the Unspoken | Councilman Nostulia | prove |
| Unspoken Verse | Councilman Nostulia | job |
| Unusual Goral Coral | Engineer Eilisia | interested |
| The Harbingers of Thule | Director Idris Manaar | capable |
| Conquering Your Fears | Director Idris Manaar | ready |
| The Believers | Harbinger Glask | job |
| Eastern Wastes portal activation | Leopold Crunchbasher | attune |

The arc requires level 85 and preceding quest completions. Exploring and Unspoken Verse are optional components in the admitted catalogue shape. Their type2 criteria use Optional behavior1; the historical admission does not independently prove that required/optional shape was unchanged by May2013. The package admits only **Partisan of Shard's Landing**; it does not enable unrelated RoF achievements or invent the achievement's unrecovered reward.

## Dependencies and conflicts

Build the server with the root five-patch source series, including `0005-shards-native-quest-support.patch`. It provides the lossless read-only Lua `GetSharedTaskIdentity()` API and narrowly scoped item-cast target permissions used by these quests. The root publication records a clean `zone`/`world` build; source builds and native gameplay checks are different claims.

Use the PEQ quest baseline `2124cc0f069f05f5b90916162fb2ffa430a531bf`, or manually review equivalent callbacks. Standard PEQ `items` helpers remain required. `preflight.py` checks native item/click/spell shapes, NPC/task identities, schema columns and definition/criterion semantics. Missing baseline items or changed spells are reported rather than replaced with guessed records.

Quest hooks are a **focused patch**, not a replacement `global_player.lua`. The 171 hook files are absent from the reviewed stock PEQ baseline; the two authored Lua modules are installed alongside them. Hook wrappers preserve previous callbacks and propagate nonzero return values. A server with an existing custom file at one of these paths must merge the relevant wrapper into its own callback body. `apply_quests.py` stops on an unknown preimage and never automatically discards that custom code. It also rejects alternate Lua/Perl callbacks selected by NPC ID, name plus ID, instance version, or default fallback, including zone overrides of global item/spell hooks. Merge these manually before installing: the engine selects one local script, so merely adding a second file is insufficient. Symlinked managed paths are rejected. If the server has additional configured quest roots, pass each with `--additional-quests /other/quests`; the installer cannot discover roots from server configuration.

The 14 canonical NPC filename corrections use hyphens where the native loader normalizes backticks/apostrophes. `obsolete-aliases.json` identifies only the known old copies; installation removes them only when their exact reviewed hashes match. Unknown aliases require manual review. The stale Kael test-NPC wrapper is excluded.

## Install

Back up the database and quest directory. Use a maintenance window so no active character is partway through an older task-stage layout. This package never modifies character progress tables.

Create a local MySQL/MariaDB client option file with your connection settings; keep credentials outside this release. Run these read-only checks:

```sh
python3 preflight.py --connection-file /path/to/mysql-client.cnf --database YOUR_DATABASE
python3 apply_quests.py --quests /path/to/quests
```

On Windows use `python` and Windows paths. Add `--client mysql` if that is the installed SQL client. Akk-stack users can execute the same SQL through their normal database-container command; no local container names or credentials are embedded in this package.

Apply these SQL files in order, without the client's `--force` option:

1. `sql/010-shards-catalogue.sql`
2. `sql/015-welcome-prerequisite.sql`
3. `sql/020-shards-partisan.sql`

For example:

```sh
mariadb --defaults-extra-file=/path/to/mysql-client.cnf YOUR_DATABASE < sql/010-shards-catalogue.sql
```

Repeat for the next files. PowerShell users may pipe `Get-Content -Raw FILE` into their SQL client instead. The final main migration consolidates the current authored task/world changes and all door/paper corrections in one strict-mode transaction. Temporary-table guards stop unexpected identities; a failure must be investigated before continuing.

Install the checked quest patch/modules with an explicit backup directory outside the quest tree:

```sh
python3 apply_quests.py --quests /path/to/quests --apply --backup /path/to/new-shards-backup
```

Restart all world/zone processes through your normal management procedure after installing both SQL and hooks. Idle zones retain task caches and may be skipped by a global task reload. Reapplying replaces owned task stages and criteria; it is not an automatic merge of custom content. The old mode-zero task-completion criteria and the known type2 Required-behavior mistake are recognized upgrade preimages. They are replaced by Boolean mappings with Optional behavior for the two admitted type2 components.

## Playing the restored tasks

- Exploring is repeatable: ask Drent about **scouting** again after completing it. Repeat acceptance was checked with a fresh first stage and no duplicate AA award. The original replay duration is unrecovered (`UnknownExactTimer`); the explicit server setting is zero seconds, not a claim about the Live timer.
- Keep a clear cursor before quest combines. Recipes use native output delivery and consume their real inputs.
- Collect and translate the ten Words papers. Their precise models/headings reuse PEQ-collected scenery, with the period map coordinates establishing item association. Duplicate itemless paper models and two explicitly labelled collector placeholders are addressed by the guarded migration.
- For Unspoken Verse, carry the ten papers, five inks and one blood through the locations; no invented book click or dropping step is required.
- Activate the Dire Tuning Crystal's full 30-second cast in the feartouched Eastern Wastes, then return to Shard's Landing. A cancelled cast does not attune the character. Ordinary-player travel through the real portals was checked separately.
- For Conquering, designate one crafter to loot all six NoTrade shards. Shared progress does not move physical ingredients between players. The native run exercised one participant; additional two-member credit and foreign-instance checks passed as described below; the full acquisition route was completed in the single-member run.
- The Believers head is passive: carry it to the Silent Hall, finish the combat steps, leave the city, then return the exact head to Glask. There is no fabricated click effect.

## Additional multiplayer coverage

- **Shared acceptance and kill credit:** normal Director dialogue accepted two grouped level85 members. Two original East Wastes kills, one by each member, produced exactly two shared increments and matching persisted counts for both members.
- **Creator absent:** a real crystal cast spawned the nightmare. After its creator zoned away, the other shared member killed it and both saved the expected single increment.
- **Separate instances:** an ungrouped character with the same objective active in a different shared instance killed the creator-owned nightmare. Its counter remained zero, and the owner's existing counter was unchanged. The creator was offline after a client zoning failure during this case.

The advanced scenarios used clearly labelled QA stage setup and a supplied crystal. The tested nightmare objective remained at its initial count until real combat. These checks supplement the previously completed full single-member route; they do not establish a full two-member acquisition/completion replay or exact Live encounter balance. Unspoken Verse checks also passed: a genuine grouped entry kill advanced both personal objectives once; a non-owner exit kill in a separate party gave no progress. Exactly one apparition remained alive through repeated trigger cycles with both same-party and foreign eligible characters. Its QA setup supplied earlier stages and writing materials; the tested ambush objectives were never granted. Secondary setup privileges were restored before combat, and the supplied QA blood was removed afterward to prevent retriggering.

## Evidence and remaining fidelity limits

The [April 20, 2013 progression guide](https://everquest.allakhazam.com/wiki.html?p=eq:Progression_Through_Rain_of_Fear&oldid=461435) establishes the period task roster. Separate dated sources establish individual objectives, language gains and selected AA/cash rewards. Historical identity admission is not proof that every modern description/reward was unchanged in May 2013.

Flat XP, extraction probabilities, trigger radii, timers and some combat/model profiles are labelled reconstruction settings. The authoritative current settings are in `quests/lua_modules/shards_partisan_config.lua`; obsolete staged JSON/build snapshots are not distributed. To change supported Lua defaults before installation, run for example `python3 configure.py --extractor-chance 25 --radius 40 --sermon-seconds 60 --meditation-seconds 30`. This changes the release package and its hashes, with the previous module hash retained as a known upgrade preimage. It does not change a running server or its database. Flat task XP remains explicitly labelled in the SQL; review any intentional SQL customization separately. Exact Live encounter balance, model fidelity and every multiplayer branch are not claimed. No client binaries/resources, raw captures, private character records, research logs or test files are included.
