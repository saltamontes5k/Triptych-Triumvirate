#ifndef NMS_VAULT_ITEM_H
#define NMS_VAULT_ITEM_H

#include "types.h"

static constexpr uint32 NMS_VAULT_ARMORY_ITEM_ID = 9011009;

// 9011009 % 1000000 == 11009. Remainder-only matching is forbidden: the >= guard is what
// keeps stock ids like 11013 (Boots of Quickness) from ever counting as the vault key.
inline bool NmsVaultIsArmoryItem(uint32 item_id)
{
	return item_id >= NMS_VAULT_ARMORY_ITEM_ID
		&& (item_id % 1000000u) == (NMS_VAULT_ARMORY_ITEM_ID % 1000000u);
}

#endif
