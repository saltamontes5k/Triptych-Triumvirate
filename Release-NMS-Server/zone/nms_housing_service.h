// nms_housing_service.h -- guest service NPCs bound to an estate row.
//
// The second layer on top of nms_housing_actors: an NPC spawned at a placed item's pose and
// bound to that estate row, whose class makes the client open a service window -- a vendor, a
// banker, a tribute master, the guild bank, the guild-hall teleport seller or a portal pad.
//
// Deliberately narrow: the class is not forced. A binding names a real npc_types row and the
// service kind has to match that row's class, exactly the way the fork pins its guild-hall
// NPCs to reviewed originals -- so nothing here invents an appearance or a catalogue. Row
// 345000 (Yenny, merchant 26 items), 345002 (banker), 345003 (guild banker), 345001 (guild
// tribute) and 345004 (teleport merchant 22 items) are the guild-hall set this expects.
//
// Access is proximity + estate ownership: the plot's owner may use every service in their
// house, the owning guild may use everything in its hall, and a visitor may use the
// non-guild services (vendor, banker, personal tribute) but never a guild-only one.
#pragma once

#include <cstddef>
#include <cstdint>
#include <string>
#include <vector>

class Client;
class Mob;
class Seperator;

namespace NmsHousingService {

enum class Service : uint8_t {
	None = 0,
	Vendor = 1,
	Banker = 2,
	PersonalTribute = 3,
	GuildTribute = 4,
	GuildBank = 5,
	TeleportMerchant = 6,
	TeleportPad = 7,
};

const char *Name(Service service);
bool        Parse(const std::string &text, Service &out);
uint8_t     ClassFor(Service service);
bool        GuildOnly(Service service);

struct Binding {
	uint32_t door_id     = 0; // estate (lot door id)
	uint32_t row_id      = 0; // nms_house_item.id the service stands on
	uint32_t npc_type_id = 0;
	uint32_t guild_id    = 0; // required for the guild-only kinds
	Service  service     = Service::None;
};

// A purchasable service contract: the estate item that grants an assistant. Ids 66639-66646 are
// the original "Friendly Guild ..." contracts the neighbourhood vendor sells (Brent Harnak,
// Guildhall Accessories, npc 712091); 66644 and 66646 have no npc type of their own in this
// database yet, so the personal tribute maps to the shipped Summoned Tribute Master (class 63)
// and the teleport device stays unbound until the portal step exists.
struct Contract {
	uint32_t    item_id;
	Service     service;
	uint32_t    npc_type_id; // 0 = the device is not an assistant yet
	const char *label;
};

const Contract *ContractForItem(uint32_t item_id);

// Turn a just-placed contract item into its assistant. Writes the binding row and reconciles, so
// buying and placing a contract is the whole acquisition path -- no GM command needed. Guild-only
// contracts require a guild plot; a personal plot is refused with a message.
bool BindPlacedContract(Client *c, uint32_t door_id, uint32_t row_id, uint32_t item_id);

// Every enabled binding for one estate, in row order.
std::vector<Binding> Load(uint32_t door_id);

// Spawn (or re-spawn) every enabled binding of one estate at its row pose, then publish the
// bindings each client in this instance is allowed to use. Returns false when the estate has
// no usable binding at all.
bool Reconcile(Client *c, uint32_t door_id);

// Depop every service NPC this process owns.
void Clear();

// Depop one binding (the row was removed or is no longer a service).
bool RemoveOne(uint32_t door_id, uint32_t row_id);

// Publish the estate's bindings to one client, filtered by Allows().
void PublishFor(Client *c, uint32_t door_id);

bool             Managed(const Mob *mob);
const Binding   *Find(const Mob *mob);

// One live binding and the actor that carries it. The portal layer needs the pads this way:
// it walks them by kind instead of looking one up by mob.
struct LiveBinding {
	Binding  binding;
	uint16_t spawn_id = 0;
};

std::vector<LiveBinding> LiveBindings(Service service);
bool             Allows(Client *c, const Mob *mob, Service service);

// True for any NPC that is not ours, so ordinary merchants are never affected.
bool AllowsMerchant(Client *c, const Mob *mob);

std::size_t Count();

// "#housing service ..."
bool HandleCommand(Client *c, const Seperator *sep);

} // namespace NmsHousingService
