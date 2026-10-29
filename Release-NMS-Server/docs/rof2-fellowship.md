# RoF2 fellowship

Native fellowship support for the May 10 2013 Rain of Fear 2 client (build 630):
membership and invitations, roster window, cross-zone `/fsay` (channel 21),
597 campsite definitions with exact kit/lumber debits, campsite world entities
and effects, insignia travel, and normal/AA vitality banking.

The stock client already renders the fellowship window: no UI override, no
`dbstr_us.txt` edit and no client patch are required.

## Provenance

Ported from the public `nightstalker6669/eqemu-rof2-fellowship` package at
commit `9382453264f4f84ac7e83a9ee5c9c9a1391c6017` (2026-10-23). That package is
an overlay for a pinned EQEmu checkout (`8175ae6`) plus the companion
`eqemu-rof2-housing` repository at `9aad4cc`, and ships a 506-path base
manifest. This tree is neither of those bases, so the overlay sources were
vendored and the integration hooks were applied by hand; the upstream patch was
used as a reference only and is not applied.

What was deliberately not ported:

- The housing permission layer (`overlay/common/housing/fellowship_membership.h`
  and the `zone/client_housing.cpp` hunks). Our housing adoption is the
  self-contained `zone/nms_housing.cpp` wire layer; there is no housing
  inventory-session or estate-permission infrastructure to hook.
- The housing inventory admission leases used by upstream's paid-campsite path.
  Replaced with a local exact-row debit adapter (see below).

Upstream's explicit limits are preserved in [Deferred gaps](#deferred-gaps);
none of them is a defect introduced here.

## Wire contract

Six opcodes, recovered from the matching client artifact and verified absent
from this tree before the port:

| Opcode | Wire | Direction | Payload |
|---|---:|---|---:|
| `OP_FellowshipUpdate` | `0x6e4d` | zone to client | 2564 (0xa04) |
| `OP_FellowshipAction` | `0x7121` | client to zone | 1076 (0x434) |
| `OP_FellowshipInvite` | `0x62ab` | zone to client | 1076 (0x434) |
| `OP_FellowshipCampRequest` | `0x0c12` | client to zone | 8 |
| `OP_FellowshipCampList` | `0x074d` | zone to client | variable |
| `OP_FellowshipVitality` | `0x2cc6` | zone to client | 32 |

`common/fellowship/rof2_wire.h` is an explicit little-endian codec. It does not
cast a compiler-packed struct onto the wire, so packing or compiler differences
cannot silently change the layout.

Mappings live in `utils/patches/patch_RoF2.conf` and must also be deployed to
the runtime copy at `Build/bin/Release/patch_RoF2.conf` (the runtime reads the
deployed copy, not the source tree).

Internal world/zone messages: `ServerOP_FellowshipRefresh` (`0x5125`, zero
payload), `ServerOP_FellowshipChat` (`0x5126`) and
`ServerOP_FellowshipChatDeliver` (`0x5127`). World re-derives every recipient
from freshly loaded membership; a zone's `actor_id` is the only identity it
accepts, and it must match the authenticated zone connection.

## Schema

Custom schema versions 270 to 273, all additive InnoDB tables with no foreign
keys into stock tables:

| Version | Table(s) | Mirror |
|---:|---|---|
| 270 | `fellowship_guard`, `fellowships`, `fellowship_members`, `fellowship_invitations` | `utils/sql/20261029_fellowship_membership.sql` |
| 271 | `fellowship_vitality` | `utils/sql/20261029_fellowship_vitality.sql` |
| 272 | `fellowship_xp_commits` | `utils/sql/20261029_fellowship_xp_commits.sql` |
| 273 | `fellowship_campsite_catalogue` (597 rows) | `utils/sql/20261029_fellowship_campsite_catalogue.sql` |

The catalogue SQL is 333 KB and is stored as seven chunked raw-string literals
in `common/database/database_update_manifest_custom.cpp` (MSVC caps a single
string literal at 65,535 bytes). The rows must stay in step with
`common/fellowship/campsite_catalogue_data.inc`.

## Rules

| Rule | Default | Meaning |
|---|---|---|
| `Custom:Fellowships` | `false` | Master gate. Off means no roster, no `/fsay`, no camp, no vitality. |
| `Custom:FellowshipCamps` | `true` | Campsite creation and effects. |
| `Custom:FellowshipVitality` | `true` | Vitality banking and XP/AA sharing. |
| `Custom:FellowshipCampMembers` | `2` | Living members, including the camper, that must be nearby and out of combat to camp. Clamped to 1-12. |

All entry points test the gate and fail closed. Flip the master rule on only
after the schema is present: `SELECT rule_value FROM rule_values WHERE
rule_name='Custom:Fellowships'`.

## Integration points

| Area | File | Behaviour |
|---|---|---|
| Roster/action handling | `zone/client_fellowship.cpp` | Decodes native actions, authenticates target/membership, sends snapshots and kit lists. |
| Chat | `zone/fellowship_chat.cpp`, `world/zoneserver.cpp`, `zone/worldserver.cpp` | Zone to world to zone; each receiving zone re-checks sender and fellowship before display. |
| Camp entities | `zone/fellowship_campfire.cpp` | Polls durable camps every 5 s, spawns the race-567 visual, reconciles effects, clears on zone teardown. |
| Effects | `zone/fellowship_campsite_bonuses.cpp`, `zone/spell_effects.cpp` | Native buffs, focus merge, illusion appearance, insignia travel for spell 7618. |
| Vitality | `zone/client_fellowship_vitality.cpp`, `zone/exp.cpp` | Combat award intercepted before XP is written; award and bank commit in one transaction. |
| Persistence guards | `zone/client.cpp`, `zone/zonedb.cpp` | Saves are refused while a fellowship XP transaction is in flight or has failed; campsite aura buffs are excluded from buff persistence. |
| Deletion | `common/database.cpp` | Promotes the earliest surviving member, drops rosters and clears vitality; deletion is withheld if cleanup fails. |

Only combat XP on a kill is shared (`ExpSource::Kill`, non-rez). Quest, script
and resurrection awards are never intercepted.

## Multiclass

This server runs every character as a multiclass character: one level, one
normal-XP pool, one AA pool, and a class bitmask. The fellowship code is
class-agnostic by construction:

- Sharing divides the character's own combat award; it never touches classes,
  so there is no per-class splitter to bypass. The vitality finalizer re-enters
  `SetEXP` with the transaction flag set, which is the same path a solo kill
  takes on a multiclass character.
- Caps are computed from level and the configured maximum level
  (`Character:MaxExpLevel`, falling back to `Character:MaxLevel`), not from class.
- The roster's class column carries the character's base class only; it is a
  display value and drives nothing.

The camp-member floor is `Custom:FellowshipCampMembers` (default 2). The native
client may still gate its own Camp button on a threshold it computes locally, in
which case the server floor only decides whether a request that arrives is
accepted.

## Paid campsite materials

Upstream requires the housing repository for paid campsites: authenticated
inventory admission leases, persisted raw-row identity and pending-operation
guards. That infrastructure does not exist here.

`common/fellowship/campsite_materials.cpp` replaces it with a narrower,
fail-closed debit that runs inside the campfire transaction on a dedicated
database connection:

1. The zone selects two personal slots and verifies the runtime item (id, item
   type 58, stackable, charges, no augments, no evolving payload).
2. Inside the transaction both rows are re-read `FOR UPDATE` and must still
   match exactly (item id, charges, all six augments zero, no evolving unique
   id, no custom payload). The item definition must still be type 58, class 0,
   stackable, non-charm, non-evolving.
3. Only then is each row decremented (or deleted at one charge). Any mismatch
   aborts the camp; `SetCampfire` rolls the transaction back.
4. After `COMMIT` the zone mirrors the already-durable decrement into the
   client view with `DeleteItemInInventory(slot, 1, true, false)`, so no second
   inventory write can diverge.

If the commit outcome is uncertain the client is disconnected with an
authoritative-reload message rather than guessing.

## Verification

Database:

```sql
SELECT custom_version FROM db_version;                                   -- 273
SELECT COUNT(*) FROM fellowship_campsite_catalogue;                      -- 597
SELECT rule_name, rule_value FROM rule_values WHERE rule_name LIKE 'Custom:Fellowship%';
```

Server:

- World and zones both rebuilt from the same commit (the opcode enum is shared).
- Boot log shows versions 270-273 applied, and `patch_RoF2.conf` in
  `Build/bin/Release/` contains the six fellowship mappings.

In game (three members unless stated):

1. Create a fellowship; verify the roster window and insignia.
2. Invite/accept/decline; verify the five-minute invitation expiry.
3. Roster and MOTD persist across relog and a zone restart.
4. `/fsay` to a member in another zone; verify no duplicate echo for the sender.
5. Free camp with the configured minimum of members within range, out of combat; verify the visual.
6. One paid camp: exact kit and lumber decrement, inventory view correct
   without relog, and a second attempt with insufficient materials fails closed.
7. Out-of-range and expired camp behaviour; insignia travel into the camp zone.
8. Kill XP with 2 and 3 participants, normal and AA; verify a multiclass
   character still splits as a solo kill does.
9. Leader transfer, leave, disband, and character deletion cleanup.

## Deferred gaps

Carried over from the upstream package; these are documented limits, not
regressions:

- Campsite effect radius (100 units) and deterministic maximum focus are
  emulator policy; Live random focus distribution and the true radius are not
  recovered.
- The campfire timer's native clock origin and second timestamp are unresolved;
  the client consumes a nonzero presence value while server epoch expiry
  governs effects.
- Action byte +0x10 and several roster bytes have unknown semantics and are not
  interpreted. Native accept/decline has no nonce, so acceptance binds to the
  invitation actually delivered on the current connection.
- Vitality AA high words and the exact native minimum packet size are unproven;
  the server emits a zero-padded 32-byte packet.
- Cross-level XP/AA conversion is not established; normal and AA banks are
  separate.
- Housing integration (fellowship-aware personal plots) is intentionally not
  part of this port.

## Notices

Upstream package notice, reproduced as published:

> EQEmu RoF2 Fellowship
>
> Production fellowship extension for EQEmu, targeting the May 10, 2013 RoF2 client.
> EQEmu upstream copyright and GPLv3 notices are preserved; see LICENSE.
> Requires the separately published EQEmu RoF2 Housing integration described in docs/INSTALL.md.
> An independent community project, not affiliated with Daybreak Games. EverQuest
> and related names are trademarks of their respective owners. No client executable,
> DLL, archive, texture, map, packet capture or personal database is distributed.
> Protocol documentation records observed binary interfaces and explicit emulator policies.

This port is distributed under the same GPLv3 terms as the rest of this
repository.
