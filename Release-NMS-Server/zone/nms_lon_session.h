// nms_lon_session.h -- zone-side Legends of Norrath helpers (see nms_lon_session.cpp).

#pragma once

#include <cstdint>

class Client;

// Right-click on a Legends of Norrath booster/deck pack item (the era-live global
// drop items): credits the card product to the account (lon_delivery, delivered by
// world at card-game login or within seconds while in it) and consumes the pack.
// Returns true when the clicked item was a pack (the click is fully handled).
bool NmsLoNTryOpenPack(Client *c, uint32 item_id, int16 slot_id);
