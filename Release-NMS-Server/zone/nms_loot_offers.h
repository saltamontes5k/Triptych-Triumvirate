#ifndef NMS_LOOT_OFFERS_H
#define NMS_LOOT_OFFERS_H

// /nmsloot personal loot offers, ported from mukluk4/Modular-Options modules/loot-offers
// (post voidforged 939a7501, which added the Hailstone client protocol). Two window paths
// share one offer model:
//   - our dinput8.dll: OP_NmsLootOffer 0x140C / OP_NmsLootDecision 0x140D
//   - the Hailstone add-on: OP_PersonalLoot* 0x1410-0x1414 after its Hello (action 20)
// A client without either sees nothing, so Custom:NmsLootOffers ships off.

#include "../common/types.h"
#include <string>
#include <vector>

class Client;
class Corpse;
class EQApplicationPacket;
class NPC;

enum class NmsLootAction : uint32 {
	None = 0,
	Keep = 1,
	Sell = 2,
	Tribute = 3,
	Bank = 4,
	Vault = 5,
	Destroy = 6,
	Pass = 7,
	Refresh = 8, // /nmsloot: resend the pending list, no decision
	ReturnToPasser = 9
};

struct NmsLootOffer {
	uint32      id = 0;
	uint32      character_id = 0;
	uint32      zone_id = 0;
	uint32      instance_id = 0;
	uint32      corpse_id = 0;
	uint64      corpse_serial = 0;
	uint32      item_id = 0;
	uint32      icon = 0;
	int16       charges = 1;
	uint8       bonus = 0;
	std::string name;
	uint32      aug[6] = {0, 0, 0, 0, 0, 0};
	bool        passed = false;
	std::string passed_from;
	int         expire_remaining = 0;
};

bool NmsLootOffersEnabled();
bool NmsLootOfferTablesReady();

void NmsLootOfferOnCorpseOpen(Client *c, Corpse *corpse);
void NmsLootOfferOnCorpseCreated(Corpse *corpse, Client *credit, NPC *source);
bool NmsLootOfferEmptiesCorpse(Client *credit);
void NmsLootOfferRestoreOnZoneIn(Client *c);
void NmsLootOfferHandleDecision(Client *c, const EQApplicationPacket *app);
void NmsLootOfferHandlePersonalLootAction(Client *c, const EQApplicationPacket *app);
bool NmsLootOfferApply(Client *c, const NmsLootOffer &offer, NmsLootAction action, const std::string &pass_to);
struct LootItem;
void NmsLootOfferForgetCorpseItem(uint32 character_id, uint32 corpse_id, uint64 corpse_serial, const LootItem *item);

// Zone boot: reclaim rows whose owner never returned (offline-expired offers have nobody to
// deliver to; the in-zone expiry path delivers instead of deleting).
void NmsLootOfferSweepExpired();

#endif
