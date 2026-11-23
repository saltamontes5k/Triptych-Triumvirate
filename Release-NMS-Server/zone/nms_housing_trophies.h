// nms_housing_trophies.h -- RoF2 personal housing trophies (free v1).
//
// The RoF2 real-estate UI ships a trophy window that opens on OP_RealEstateTrophyOpen
// (0x51a9): the player selects a benefit + tier into one of ten slots and toggles it
// active. While active and the placed trophy item stands on the owner's estate, the
// server applies a hidden stat item per selection (the same pattern the ordinary
// tribute system uses). This is the server half; the client renders benefit rows from
// ItemPackets typed ItemPacketPersonalTrophy (rewritten to the ordinary tribute item
// packet on the wire, slot-typed typeTrophyTribute).
//
// Port of nightstalker6669/EQEmu develop (trophy_anchor_wire.h wire, trophy_benefits.h
// state machine, client_housing_trophies.cpp handlers) onto the nms_housing substrate:
// eligibility is a placed nms_house_item row owned by the character -- no custody
// bridge, no estate regions. Free tier only: every seeded favor_cost is 0, and the
// toggle refuses any paid tier exactly like upstream (billing is a separate follow-up).
//
// Tables (migration v465): nms_housing_trophy_benefits (catalogue), _state (per-char
// enabled flag), _selections (per-char slot choices). Selection rows survive relog and
// zone-in; a stale row whose source is no longer placed is pruned in memory on every
// load and left in the table (harmless: revalidation never trusts it).
//
// Gate: RuleB(Custom, HousingTrophies) -- fail-closed, the opcodes stay log-only
// (client_packet.cpp k_log_only_rof2) when the rule is off.

#ifndef EQS_NMS_HOUSING_TROPHIES_H
#define EQS_NMS_HOUSING_TROPHIES_H

#include <cstdint>

class Client;

namespace NmsHousingTrophies {

inline constexpr uint32_t kWireSlots    = 10; // the trophy window's selection rows
inline constexpr uint32_t kCapacity     = 4;  // active slots; SPA 432 expansion not wired (v1)
inline constexpr uint32_t kEmptyBenefit = 0xFFFFFFFFu;

// Per-client tick (rides HousingClientProcess in nms_housing.cpp): populates the stat
// items after zone-in / rule flips, prunes stale state. Cheap when clean.
void ClientProcess(Client *c);

// Reload the character's trophy view from the DB and optionally resync the client
// (timer + list + clear + stat-item packets). Used by the three packet handlers too.
void Refresh(Client *c, bool notify);

// Drop the applied benefits and clear the client snapshot (rule off, source gone).
void Invalidate(Client *c);

// The placed trophy item left its estate (pickup or Store All): drop the applied
// benefits and tell the client the window is empty. Selection rows persist in the DB
// and revalidate (prune) on the next window action.
void OnSourceRemoved(Client *c, uint32_t item_id);

} // namespace NmsHousingTrophies

#endif // EQS_NMS_HOUSING_TROPHIES_H
