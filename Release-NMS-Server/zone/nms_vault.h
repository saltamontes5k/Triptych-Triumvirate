#ifndef NMS_VAULT_H
#define NMS_VAULT_H

#include "../common/nms_vault_item.h"
#include "../common/types.h"
#include <string>
#include <vector>

class Client;
class Mob;
struct StatBonuses;
namespace EQ {
	class ItemInstance;
	struct ItemData;
}

static constexpr int NMS_VAULT_SLOT_MIN = 1;
static constexpr int NMS_VAULT_SLOT_MAX = 87;
static constexpr int NMS_VAULT_CLICKY_BEGIN = 61;
static constexpr int NMS_VAULT_CLICKY_END = 80;
static constexpr int NMS_VAULT_PROC_PRIMARY = 81;
static constexpr int NMS_VAULT_PROC_SECONDARY = 82;
static constexpr int NMS_VAULT_PROC_RANGED = 83;
// Free-form mod slots: a parked item lends only its skill mods, instrument mods, and
// focus effects - never stats or procs. The Ring/Belt/Neck/Ear placeholders are cosmetic.
static constexpr int NMS_VAULT_MOD_BEGIN = 84;
// Fixed page set - NmsVaultPageForSlot only ever returns a value in this range.
static constexpr int NMS_VAULT_PAGE_MIN = 1;
static constexpr int NMS_VAULT_PAGE_MAX = 9;

struct NmsVaultItem {
	int      slot = 0;
	int      bag_slot = 0;
	uint32   item_id = 0;
	int16    charges = 0;
	uint32   aug[6] = {0, 0, 0, 0, 0, 0};
	// Per-instance state. Without these a vault round trip silently returned a different
	// item than the one deposited: an attuned item came back unattuned, ornaments were
	// stripped, and quest/script state in custom_data was lost. The `inventory` table
	// persists exactly these fields (shareddb.cpp:436-442); the vault now does too.
	bool        attuned = false;
	std::string custom_data;
	uint32      ornament_icon = 0;
	uint32      ornament_idfile = 0;
	uint32      ornament_hero_model = 0;
	uint64      guid = 0;
};

bool NmsVaultEnabled();
int NmsVaultPageForSlot(int slot);
bool NmsVaultSlotValid(int slot);
bool NmsVaultTablesReady();

bool NmsVaultLoad(uint32 character_id, std::vector<NmsVaultItem> &out);
const NmsVaultItem *NmsVaultFind(const std::vector<NmsVaultItem> &items, int slot, int bag_slot);
bool NmsVaultSaveItem(uint32 character_id, const NmsVaultItem &item);
bool NmsVaultDeleteItem(uint32 character_id, int slot, int bag_slot);

void NmsVaultSendRefresh(Client *c, int open_page);
void NmsVaultHandlePage(Client *c, int page);
void NmsVaultHandleDeposit(Client *c, int slot);
void NmsVaultHandleWithdraw(Client *c, int slot, int quantity);
void NmsVaultHandleDepositBagItem(Client *c, int slot, int bag_slot);
void NmsVaultHandleWithdrawBagItem(Client *c, int slot, int bag_slot, int quantity);
void NmsVaultHandleBank(Client *c);
void NmsVaultHandleMerchant(Client *c);

void NmsVaultOnZoneIn(Client *c);
void NmsVaultGrantArmory(Client *c);
bool NmsVaultTryOpenFromItem(Client *c, uint32 item_id);
void NmsVaultOnMerchantEnd(Client *c);
void NmsVaultOnClientDestroy(Client *c);
void NmsVaultRefreshCache(Client *c);
void NmsVaultApplyClickies(Client *c);
const EQ::ItemData *NmsVaultProcItem(Client *c, uint16 hand);
int NmsVaultProcAugs(Client *c, uint16 hand, const EQ::ItemData **out_augs, int max_augs);
void NmsVaultApplyLockerBonuses(Client *c, StatBonuses *b);
bool NmsVaultBankAccess(Client *c);
bool NmsVaultIsMerchant(Client *c, uint16 entity_id);
void NmsVaultApplyModBonuses(Client *c, StatBonuses *b);
int NmsVaultLockerFocusList(Client *c, const EQ::ItemData **out, int max);
int NmsVaultTryDepositInstance(Client *c, EQ::ItemInstance *inst);

#endif
