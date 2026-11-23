// nms_housing_portal.cpp -- guild-hall teleport pad: stone hand-in becomes an estate alignment.
//
// See nms_housing_portal.h for the loop. Nothing here moves a player yet; this is the paid half,
// and it deliberately reuses the ordinary trade window so the stone is a real merchant purchase
// that leaves the inventory exactly once.

#include "client.h"
#include "entity.h"
#include "npc.h"
#include "zone.h"
#include "zonedb.h"

#include "nms_housing_portal.h"
#include "nms_housing_service.h"

#include "../common/strings.h"

#include "fmt/format.h"

#include <cmath>
#include <cstring>
#include <ctime>
#include <map>

namespace NmsHousingPortal {

namespace {

// Destination stones: the ids, names and arrival points of the deployed basic guild-hall quests.
// 88737 (the legacy guild-banner splinter) and 76008 are deliberately absent -- their original
// branches have no destination and must never be charged for or routed to a placeholder.
constexpr Destination kDestinations[] = {
	{10092, "The Plane of Hate",              186,  -393,   656,    3},
	{10094, "The Plane of Sky",                71,   539,  1384, -664},
	{64191, "Dragonscale Hills",              442, -1954,  3916,   19},
	{76000, "The Northern Plains of Karana",   13,  1209, -3685,   -5},
	{76001, "East Commonlands",                22,  -140, -1520,    3},
	{76002, "The Lavastorm Mountains",         27,   460,   460,  -86},
	{76003, "Toxxulia Forest",                 38,  -916, -1510,  -33},
	{76004, "The Greater Faydark",             54,  -441, -2023,    4},
	{76005, "The Dreadlands",                  86,  9658,  3047, 1052},
	{76006, "The Iceclad Ocean",              110,   385,  5321,  -17},
	{76007, "Cobalt Scar",                    117, -1634, -1065,  299},
	{76009, "The Twilight Sea",               170, -1028,  1338,   39},
	{76010, "Stonebrunt Mountains",           100,   673, -4531,    0},
	{76011, "Wall of Slaughter",              300,  -943,    13,  130},
	{76012, "Barindu, Hanging Gardens",       283,   209,  -515, -119},
	{76070, "The Undershore",                 362,  -750, -1002,   48},
	{88735, "Arcstone, Isle of Spirits",      369,  1630,  -279,    5},
	{88736, "Goru`kar Mesa",                  397,   -85, -2050,   19},
	{88738, "Katta Castrum",                  416,    -2,  -425,  -19},
	{88739, "The Plane of Time",              219,     0,   110,    8},
	{88740, "Brell`s Rest",                   480,   -23,  -619,   36},

	// Replacement stones this server authored for destinations the merchant used to stock with
	// originals. Mapped by the stone's own name, which is unambiguous for the first six; the last
	// five name zones outside the basic guild-hall list, so they use each zone's safe point.
	{876000, "The Northern Plains of Karana",   13,  1209, -3685,   -5},
	{876001, "East Commonlands",                22,  -140, -1520,    3},
	{876003, "Toxxulia Forest",                 38,  -916, -1510,  -33},
	{876004, "The Greater Faydark",             54,  -441, -2023,    4},
	{876005, "The Dreadlands",                  86,  9658,  3047, 1052},
	{876006, "The Iceclad Ocean",              110,   385,  5321,  -17},
	{976010, "Everfrost Peaks",                 30,   629,  3139,  -60},
	{976013, "The Scarlet Desert",             175, -1678, -1054,  -98},
	{976014, "The Western Wastes",             120, -3499, -4099,  -18},
	{976015, "The Field of Bone",               78,  1617, -1684,  -50},
	{976016, "Barindu, Hanging Gardens",       283,   590, -1457, -123},
};

void Say(Client *c, const std::string &text)
{
	if (c) {
		c->Message(Chat::White, text.c_str());
	}
}

} // namespace

const Destination *Lookup(uint32_t stone)
{
	for (const auto &destination : kDestinations) {
		if (destination.stone == stone) {
			return &destination;
		}
	}

	return nullptr;
}

bool Purchasable(uint32_t stone)
{
	return Lookup(stone) != nullptr;
}

const char *Name(uint32_t stone)
{
	const Destination *destination = Lookup(stone);
	return destination ? destination->name : "an unknown destination";
}

bool AlignmentFor(uint32_t door_id, uint32_t &stone, uint64_t &expires_epoch)
{
	stone         = 0;
	expires_epoch = 0;

	if (!door_id) {
		return false;
	}

	auto result = database.QueryDatabase(fmt::format(
		"SELECT stone_item_id, expires_epoch FROM nms_house_portal WHERE door_id = {} LIMIT 1", door_id
	));

	if (!result.Success() || !result.RowCount()) {
		return false;
	}

	auto row      = result.begin();
	stone         = Strings::ToUnsignedInt(row[0] ? row[0] : "0");
	expires_epoch = static_cast<uint64_t>(std::strtoull(row[1] ? row[1] : "0", nullptr, 10));

	return stone != 0 && expires_epoch > static_cast<uint64_t>(std::time(nullptr));
}

bool TryStoneHandIn(Client *c, NPC *npc)
{
	if (!c || !npc || !c->trade) {
		return false;
	}

	// Only the managed Guild Teleportation Assistant (+ item 66640) aligns a pad.
	const auto *binding = NmsHousingService::Find(npc);
	if (!binding || binding->service != NmsHousingService::Service::TeleportMerchant) {
		return false;
	}

	if (c->trade->cp || c->trade->sp || c->trade->gp || c->trade->pp) {
		Say(c, "The teleportation assistant accepts one destination stone. Your coins were returned.");
		return false;
	}

	// Exactly one stone, and it has to be a destination this service sells.
	int16_t stone_slot = -1;
	uint32_t stone_id  = 0;

	for (int16 slot = EQ::invslot::TRADE_BEGIN; slot <= EQ::invslot::TRADE_NPC_END; ++slot) {
		const EQ::ItemInstance *instance = c->GetInv().GetItem(slot);
		if (!instance) {
			continue;
		}

		if (!Purchasable(instance->GetID())) {
			Say(c, fmt::format(
				"{} is not a teleportation stone this assistant can align.", instance->GetItem()->Name
			));
			return false;
		}

		if (stone_slot >= 0) {
			Say(c, "Hand over one teleportation stone at a time.");
			return false;
		}

		stone_slot = slot;
		stone_id   = instance->GetID();
	}

	if (stone_slot < 0) {
		Say(c, "Hand the assistant a teleportation stone to align the pad.");
		return false;
	}

	const uint32_t door_id = binding->door_id;
	const uint64_t expires = static_cast<uint64_t>(std::time(nullptr)) + kAlignmentSeconds;

	// Consume the stone before writing: a failed write gives the player their stone back rather
	// than charging them for an alignment that does not exist.
	c->DeleteItemInInventory(stone_slot, 1);

	auto result = database.QueryDatabase(fmt::format(
		"INSERT INTO nms_house_portal (door_id, stone_item_id, expires_epoch, revision, aligned_by, aligned_at) "
		"VALUES ({}, {}, {}, 1, {}, NOW()) "
		"ON DUPLICATE KEY UPDATE stone_item_id = VALUES(stone_item_id), "
		"expires_epoch = VALUES(expires_epoch), revision = revision + 1, "
		"aligned_by = VALUES(aligned_by), aligned_at = NOW()",
		door_id, stone_id, expires, c->CharacterID()
	));

	if (!result.Success()) {
		LogError("[HousingPortal] alignment write failed for estate [{}]", door_id);
		Say(c, "The pad could not be aligned; please tell a guide.");
		return false;
	}

	LogInfo(
		"[HousingPortal] estate [{}] aligned to stone [{}] by [{}], expires [{}]",
		door_id, stone_id, c->GetName(), expires
	);

	Say(c, fmt::format(
		"The teleportation stone is now aligned to {} for one day.", Name(stone_id)
	));
	return true;
}

namespace {

// Per-client offer state. One pad at a time: while an offer is pending the client is not offered
// another, and the offer dies with the popup or when they walk away.
struct Offer {
	uint32_t door_id  = 0;
	uint32_t stone    = 0;
	uint64_t revision = 0;
	uint16_t pad      = 0;
	uint64_t expires  = 0;
};

std::map<Client *, Offer> offers;
std::map<Client *, uint64_t> next_check;

constexpr float kActivationRadius = 10.0f;
constexpr uint64_t kConfirmationSeconds = 30;

uint64_t Now()
{
	return static_cast<uint64_t>(std::time(nullptr));
}

double DistanceSquared(const Client *c, const Mob *mob)
{
	const double dx = c->GetX() - mob->GetX();
	const double dy = c->GetY() - mob->GetY();
	const double dz = c->GetZ() - mob->GetZ();
	if (!std::isfinite(dx) || !std::isfinite(dy) || !std::isfinite(dz)) {
		return -1.0;
	}

	return dx * dx + dy * dy + dz * dz;
}

// The pad the client is standing on, if any. Pads are live TeleportPad bindings whose actor is
// within the activation radius.
bool PadUnder(Client *c, NmsHousingService::LiveBinding &out)
{
	bool found = false;
	double best = 0.0;

	for (const auto &live : NmsHousingService::LiveBindings(NmsHousingService::Service::TeleportPad)) {
		Mob *mob = entity_list.GetMob(live.spawn_id);
		if (!mob) {
			continue;
		}

		const double distance = DistanceSquared(c, mob);
		if (distance < 0.0 || distance > static_cast<double>(kActivationRadius) * kActivationRadius) {
			continue;
		}

		if (!found || distance < best) {
			best  = distance;
			out   = live;
			found = true;
		}
	}

	return found;
}

} // namespace

void ClientProcess(Client *c)
{
	if (!c || !c->Connected() || !c->ClientDataLoaded() || !zone) {
		// Drop the per-client state rather than keeping a pointer to someone who left.
		offers.erase(c);
		next_check.erase(c);
		return;
	}

	const uint64_t now = Now();
	if (next_check[c] > now) {
		return;
	}
	next_check[c] = now + 1;

	auto offer = offers.find(c);
	if (offer != offers.end() && now >= offer->second.expires) {
		offers.erase(offer);
	}

	NmsHousingService::LiveBinding pad;
	if (!PadUnder(c, pad)) {
		// Walking away cancels the pending offer: a stale popup must not travel you.
		offers.erase(c);
		return;
	}

	if (offers.count(c)) {
		return;
	}

	uint32_t stone = 0;
	uint64_t expires = 0;
	if (!AlignmentFor(pad.binding.door_id, stone, expires)) {
		return;
	}

	auto alignment = database.QueryDatabase(fmt::format(
		"SELECT revision FROM nms_house_portal WHERE door_id = {} LIMIT 1", pad.binding.door_id
	));
	const uint64_t revision = (alignment.Success() && alignment.RowCount() && alignment.begin()[0])
		? std::strtoull(alignment.begin()[0], nullptr, 10) : 0;

	if (!revision) {
		return;
	}

	Offer fresh;
	fresh.door_id  = pad.binding.door_id;
	fresh.stone    = stone;
	fresh.revision = revision;
	fresh.pad      = pad.spawn_id;
	fresh.expires  = now + kConfirmationSeconds;
	offers[c]      = fresh;

	c->SendFullPopup(
		"Guild Hall Portal",
		fmt::format("Do you wish to travel to {}?", Name(stone)).c_str(),
		stone, stone, 1, static_cast<uint32>(kConfirmationSeconds), "Yes", "No", 0
	);

	LogInfo(
		"[HousingPortal] offered [{}] to [{}] on estate [{}] pad [{}]",
		Name(stone), c->GetName(), fresh.door_id, fresh.pad
	);
}

bool HandlePopup(Client *c, const void *popup_response)
{
	if (!c || !popup_response) {
		return false;
	}

	const auto *response = static_cast<const PopupResponse_Struct *>(popup_response);

	auto offer = offers.find(c);
	if (offer == offers.end() || response->popupid != offer->second.stone) {
		return false;
	}

	const Offer pending = offer->second;
	offers.erase(offer);

	// Everything is revalidated on the answer: the pad must still be there, the alignment must be
	// the same stone and revision, and the client must still be standing on it.
	NmsHousingService::LiveBinding pad;
	if (!PadUnder(c, pad) || pad.spawn_id != pending.pad || pad.binding.door_id != pending.door_id) {
		c->Message(Chat::Yellow, "The portal pad is no longer under you.");
		return true;
	}

	uint32_t stone = 0;
	uint64_t expires = 0;
	if (!AlignmentFor(pending.door_id, stone, expires) || stone != pending.stone) {
		c->Message(Chat::Yellow, "The portal alignment changed. Hand the assistant another stone.");
		return true;
	}

	auto alignment = database.QueryDatabase(fmt::format(
		"SELECT revision FROM nms_house_portal WHERE door_id = {} LIMIT 1", pending.door_id
	));
	const uint64_t revision = (alignment.Success() && alignment.RowCount() && alignment.begin()[0])
		? std::strtoull(alignment.begin()[0], nullptr, 10) : 0;
	if (!revision || revision != pending.revision || Now() >= pending.expires) {
		c->Message(Chat::Yellow, "That portal offer expired. Step back onto the pad.");
		return true;
	}

	const Destination *destination = Lookup(pending.stone);
	if (!destination) {
		c->Message(Chat::Yellow, "That destination is not available.");
		return true;
	}

	LogInfo(
		"[HousingPortal] [{}] travelling to [{}] (zone [{}]) from estate [{}]",
		c->GetName(), destination->name, destination->zone, pending.door_id
	);

	c->MovePC(destination->zone, destination->x, destination->y, destination->z, 0.0f);
	return true;
}

bool HandleCommand(Client *c, const Seperator *sep)
{
	if (!c || !sep) {
		return false;
	}

	const std::string action = sep->argnum >= 3 ? sep->arg[3] : "";
	const uint32_t    door_id = sep->IsNumber(4) ? Strings::ToUnsignedInt(sep->arg[4]) : 0;

	if (action == "list") {
		Say(c, fmt::format("{} destination(s):", sizeof(kDestinations) / sizeof(kDestinations[0])));
		for (const auto &destination : kDestinations) {
			Say(c, fmt::format("  stone [{}] {} -> zone [{}] {:.0f}, {:.0f}, {:.0f}",
				destination.stone, destination.name, destination.zone,
				destination.x, destination.y, destination.z));
		}
		return true;
	}

	if (!door_id) {
		Say(c, "[housing] usage: #housing portal status <door_id> | list");
		return true;
	}

	uint32_t stone = 0;
	uint64_t expires = 0;
	if (AlignmentFor(door_id, stone, expires)) {
		Say(c, fmt::format("[housing] estate [{}] pad is aligned to {} (stone [{}]) until [{}].",
			door_id, Name(stone), stone, static_cast<long long>(expires)));
	}
	else {
		Say(c, fmt::format("[housing] estate [{}] pad is not aligned.", door_id));
	}

	return true;
}

} // namespace NmsHousingPortal
