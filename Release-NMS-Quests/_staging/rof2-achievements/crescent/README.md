# Crescent Reach achievement content milestone

This package restores the **Council of Six**, **Making a Name for Yourself**, and **Becoming a Hero** quest routes, with the neighboring Crescent starter definitions and prerequisites needed to display and play them. It requires the achievement engine patch series and a compatible PEQ database/quest installation.

This is not a complete Rain of Fear achievement catalogue. Nine historically admitted Crescent identities are included. Both Baker Shivra routes are now included and passed native acquisition, handin, five-item reward and persisted achievement checks. **Graduate of Crescent Reach is not claimed fully native-validated:** the neighboring routes have different validation histories, and unrecovered achievement rewards are not invented.

## Included

- Nine definitions,57 components,45 enabled criteria (plus one preserved disabled historical mapping), four category ancestors and nine category associations.
- Scoped task definitions/activities and the reviewed Council, Making a Name and Becoming a Hero production SQL overlays.
- Confirmed reward-set dependencies for Important Errands, Making a Name and Becoming a Hero; permanent-class eligibility is server authored. Definitions with unrecovered rewards do not receive invented grants.
- Exact needed Crescent quest scripts, three Lua modules, recipes, quest ground objects, drops, merchant supplies and authored encounter objects.
- Historical source provenance and labelled configuration defaults. Exact original flat XP is often unknown; those rows use the approved PEQ-style XP defaults and are labelled accordingly.

No Shards Landing arc, Lore/Wanderlust plugin, housing/fellowship code, client assets, private character state, tests or captures are included. Librarian Hemfar's numeric script uses the pre-Lore PEQ callback body so City Charter works without importing the unrelated charm system.

## Before installing

Use the completed core source release and run its three schema migrations first, including `reward_options.class_mask`. This overlay assumes modern PEQ task, tradeskill and NPC columns compatible with the included SQL. The quest baseline was reviewed against PEQ quest commit `2124cc0f069f05f5b90916162fb2ffa430a531bf`. Standard PEQ `items.lua`, `check_handin` and `return_items` helpers remain required.

Back up your database and quest directory. Apply on a stopped server or during maintenance so cached tasks, recipes, loot and NPC definitions cannot disagree with the new data. Existing characters may retain their progress; this package never deletes or alters character tables. Do not apply task-stage replacements while a character is partway through an older custom version of the same task.

Create a local MySQL/MariaDB client option file containing your own host, user and password. Keep that file outside the release and restrict its permissions. Then run the read-only preflight:

```sh
python3 preflight.py --connection-file /path/to/mysql-client.cnf --database YOUR_DATABASE --quests /path/to/quests
```

On Windows use `python` and normal Windows paths. If your client executable is `mysql`, add `--client mysql`. The preflight rejects conflicting item/NPC/task identities, reserved world IDs, different component/criterion semantics and custom quest files instead of overwriting them. Merge custom callbacks manually and re-review their behavior; a hash mismatch is not permission to replace a customization.

## Install in order

Run these files against the same database, in order:

1. `sql/010-crescent-catalogue.sql`
2. `sql/015-native-task-dependencies.sql`
3. `sql/020-crescent-quests.sql`
4. `sql/030-making-a-name.sql`
5. `sql/040-becoming-a-hero.sql`
6. `sql/050-baker-quests.sql`

For example, each file can be imported with your local client:

```sh
mariadb --defaults-extra-file=/path/to/mysql-client.cnf YOUR_DATABASE < sql/010-crescent-catalogue.sql
```

In PowerShell, pipe `Get-Content -Raw sql/010-crescent-catalogue.sql` into the same `mariadb` command. Repeat for the ordered files. For Akk-stack, use the stack's database container command to run the same client/imports. No container name, database password or host-specific path is hard coded into the SQL.

Copy only the paths listed in `quest-manifest.json` from `quests/` into your server's quest directory, preserving subdirectories. Keep the matching Lua modules with the NPC scripts. NPC numeric scripts intentionally take precedence over the named PEQ counterpart; do not leave a different numeric handler active for the same NPC. Restart the server through your normal management procedure after both database and quest updates are installed.

Baker SQL uses enforced MariaDB CHECK guards before persistent changes and requires MariaDB10.2.1 or newer. Run imports without `--force`; a guard failure must stop the import. Its truffle chance defaults to a labelled50percent server reconstruction; edit `configuration/baker/config.json` and run its `configure.py` to regenerate the Baker SQL. XP500 per completion is also an approved labelled default. The renderer updates only its SQL/configuration entries in `payload-manifest.json`, preserving integrity checks for other files.

SQL upserts and scoped deletes make repeated application deterministic for the owned rows. Reapplying replaces the included task stages and criteria; it is not a merge tool for server customizations. The package neither grants achievements to every character nor imports unrelated modern definitions.

## What is verified

The source batches contain native observations from the existing running implementation, including Council completion and quest-object interactions. Those observations used development conveniences in some cases; the provenance files explain exactly which drops, route segments and fixtures were or were not exercised. The packaging audit performed read-only dependency and API review, not a new clean-server gameplay run.

Period sources establish identities/objectives where recorded. Reconstructed dialogue, spirit appearances, some coordinates, encounter templates and flat XP are labelled where exact historical values are unavailable. A current page or later comment is not treated as proof that a 2026 group-loot change existed in May2013.

See `provenance/milestone-status.json` for current packaging/native boundaries, `provenance/` for sources and limitations, `configuration/` for labelled defaults, and `payload-manifest.json` for release hashes. The root project license and attribution apply to the code and reconstructed overlays; linked research sources retain their own rights.
