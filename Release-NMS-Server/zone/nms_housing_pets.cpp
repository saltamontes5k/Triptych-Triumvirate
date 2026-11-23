// nms_housing_pets.cpp -- RoF2 housing pets (interior-only v1).
// See nms_housing_pets.h for the subsystem contract. Behavior is a port of
// nightstalker6669/EQEmu develop housing_pets.cpp with the settled adaptations
// (zone-bound containment instead of region volumes, owner-presence authority,
// nms_house_item row identity instead of custody ids).

#include "nms_housing_pets.h"

#include "client.h"
#include "entity.h"
#include "npc.h"
#include "mob_movement_manager.h"
#include "zone.h"
#include "zonedb.h"

#include "nms_housing_actors.h"

#include "../common/rulesys.h"
#include "../common/strings.h"

#include "fmt/format.h"

#include <algorithm>
#include <chrono>
#include <cmath>
#include <cstring>
#include <map>
#include <string>
#include <unordered_map>
#include <vector>

extern Zone *zone;

namespace {

// House-interior handles are kHouseEstateBase + door (nms_housing.cpp); pets only ever
// answer for interiors, so a handle arriving above the base strips back to the door.
constexpr uint32_t kHouseEstateBase = 600000;

constexpr uint32_t kMaxPets       = 128; // upstream's per-estate binding cap
constexpr uint32_t kCommandRange  = 20;  // units, upstream
constexpr float    kRunspeedRate  = 0.7f;// NPCType runspeed rate, upstream
constexpr float    kWalkStep      = 0.5f;
constexpr float    kRunStep       = 1.5f;
constexpr double   kGoldenAngle   = 2.399963229728653;
constexpr float    kYardRadius    = 60.0f; // yard pets stay within this of their placed pose

enum class Mode : uint32_t {
	Stay     = 16175,
	Walk     = 16176,
	Run      = 16177,
	Follow   = 16178,
	PlayDead = 16179,
};

bool ModeFromParam(uint32_t parameter, Mode &out)
{
	switch (parameter) {
		case 16175: out = Mode::Stay;     return true;
		case 16176: out = Mode::Walk;     return true;
		case 16177: out = Mode::Run;      return true;
		case 16178: out = Mode::Follow;   return true;
		case 16179: out = Mode::PlayDead; return true;
		default:    return false;
	}
}

struct Entry {
	NPC      *actor    = nullptr;
	uint16_t  spawn_id = 0;
	Mode      mode     = Mode::Stay;
	uint32_t  owner_char = 0;   // nms_plot.owner_char_id for the row's lot
	uint32_t  follow_char = 0; // Follow target character id (the owner, v1)
	float     pose_x = 0, pose_y = 0, pose_z = 0; // placed pose = spiral centre
	float     goal_x = 0, goal_y = 0;
	uint32_t  sequence = 0;     // golden-angle walk target counter
	float     size = 6;
	uint32_t  estate_id = 0;
	uint32_t  row_id = 0;
	uint32_t  item_id = 0;
	uint16_t  pet_race = 0;
	uint8_t   pet_gender = 0;
	std::string pet_name;
	bool      yard = false; // neighborhood placement: contained by radius, not the zone bound
	std::chrono::steady_clock::time_point created = std::chrono::steady_clock::now();
};

uint64_t KeyOf(uint32_t estate_id, uint32_t row_id)
{
	return (static_cast<uint64_t>(estate_id) << 32) | static_cast<uint64_t>(row_id);
}

// Zone-static state: a zone process hosts one zone, so the map never mixes estates from
// elsewhere. Cleared wholesale when the route stops matching (zone id changed).
std::map<uint64_t, Entry> pets;
std::chrono::steady_clock::time_point next_tick     = std::chrono::steady_clock::time_point{};
std::chrono::steady_clock::time_point next_validate = std::chrono::steady_clock::time_point{};
uint32_t bound_zone_id = 0;

bool Route()
{
	return zone && bound_zone_id == zone->GetZoneID();
}

bool Live(const Entry &e)
{
	Mob *mob = entity_list.GetMob(e.spawn_id);
	return e.actor && mob == e.actor && mob->IsNPC() && !mob->CastToNPC()->GetDepop();
}

void StopEntry(Entry &e)
{
	if (!Live(e)) {
		return;
	}
	e.actor->StopNavigation();
	e.actor->SetMoving(false);
	MobMovementManager::Get().SendCommandToClients(e.actor, 0.0f, 0.0f, 0.0f, 0.0f, 0, ClientRangeAny);
}

void RemoveEntry(Entry &e)
{
	if (Live(e)) {
		e.actor->Depop(false);
	}
}

bool IsPetInteriorZone()
{
	if (!zone) {
		return false;
	}
	const std::string name = zone->GetShortName();
	// Interiors host pets directly; the neighborhood hosts the YARD pets (placement_type 1
	// rows, contained by a radius around their placed pose instead of the zone bound).
	return name.rfind("phinterior", 0) == 0 || name.rfind("plhogrinteriors", 0) == 0 ||
	       name == "neighborhood";
}

// The zone's placed pet rows: interior furniture whose placeable profile carries a
// pet_race, with the lot owner for authority. Interior zones take placement_type 0 rows
// scoped by the house-template zone (each phinterior* hosts its own houses); the
// neighborhood takes placement_type 1 (yard) rows on its plots.
bool LoadWanted(std::vector<Entry> &wanted)
{
	const bool yard = std::string(zone->GetShortName()) == "neighborhood";

	auto rows = database.QueryDatabase(fmt::format(
		"SELECT h.door_id, h.id, h.item_id, h.pos_x, h.pos_y, h.pos_z, h.heading, "
		"       p.owner_char_id, pl.pet_race, pl.pet_gender, pl.pet_size, COALESCE(pl.pet_name, '') "
		"FROM nms_house_item h "
		"JOIN nms_plot p ON p.door_id = h.door_id "
		"JOIN nms_neighborhood nb ON nb.id = p.neighborhood_id "
		"JOIN nms_housing_placeable pl ON pl.item_id = h.item_id "
		"WHERE nb.zone = 'neighborhood' AND h.container = -1 AND h.stowed = 0 "
		"  AND pl.pet_race IS NOT NULL AND h.placement_type = {} "
		"  {}",
		yard ? 1 : 0,
		yard ? "" : fmt::format(
			"AND COALESCE(pl.pet_yard_only, 0) = 0 " // mounts (yard-only profiles) never spawn inside
			"AND EXISTS (SELECT 1 FROM nms_house_template t JOIN nms_plot p2 ON p2.house_item_id = t.item_id "
			"WHERE p2.door_id = h.door_id AND t.zone_id = {})",
			zone->GetZoneID()
		)
	));

	if (!rows.Success()) {
		return false;
	}

	for (auto row : rows) {
		Entry e;
		e.estate_id   = Strings::ToUnsignedInt(row[0]);
		e.row_id      = Strings::ToUnsignedInt(row[1]);
		e.item_id     = Strings::ToUnsignedInt(row[2]);
		e.pose_x      = Strings::ToFloat(row[3] ? row[3] : "0");
		e.pose_y      = Strings::ToFloat(row[4] ? row[4] : "0");
		e.pose_z      = Strings::ToFloat(row[5] ? row[5] : "0");
		e.owner_char  = Strings::ToUnsignedInt(row[7] ? row[7] : "0");
		e.pet_race    = static_cast<uint16_t>(Strings::ToUnsignedInt(row[8] ? row[8] : "0"));
		e.pet_gender  = static_cast<uint8_t>(Strings::ToUnsignedInt(row[9] ? row[9] : "0"));
		e.size        = Strings::ToFloat(row[10] ? row[10] : "6");
		e.pet_name    = row[11] ? row[11] : "";
		e.yard        = yard;

		wanted.push_back(e);
	}

	return true;
}

// Spawn one actor from the row profile (the row carries the pose; the placeable profile
// carries race/gender/size/name -- fetched separately so the wanted query stays lean).
bool SpawnEntry(Entry &e, uint16_t pet_race, uint8_t pet_gender, const std::string &pet_name)
{
	auto type = std::make_unique<NPCType>();
	std::memset(type.get(), 0, sizeof(NPCType));

	// NPC names cannot carry spaces; upstream does the same replacement.
	std::string name = pet_name.empty() ? "a house pet" : pet_name;
	for (char &c : name) {
		if (c == ' ') {
			c = '_';
		}
	}
	if (name.size() > 63) {
		name.resize(63);
	}
	std::memcpy(type->name, name.data(), name.size());

	type->race             = pet_race;
	type->gender           = pet_gender;
	type->class_           = 1;
	type->bodytype         = 1;
	type->level            = 1;
	type->current_hp       = 1;
	type->max_hp           = 1;
	type->size             = e.size > 0 ? e.size : 6;
	type->runspeed         = kRunspeedRate;
	type->npc_aggro        = false;
	type->skip_global_loot = true;
	type->skip_auto_scale  = true;
	type->trackable        = false;
	type->findable         = false;
	type->show_name        = true;

	// GravityBehavior::Flying keeps the transient NPC off the ground solver until the
	// movement tick places it, exactly like the furniture/service actors.
	auto npc = std::make_unique<NPC>(type.get(), nullptr,
		glm::vec4(e.pose_x, e.pose_y, e.pose_z, 0.0f), GravityBehavior::Flying);
	if (!npc) {
		return false;
	}

	// The Mob override first, then the NPC override: the NPC one alone leaves the mob
	// "AI controlled" with a null autocast timer (the phinterior3a1 service-NPC crash).
	npc->Mob::AI_Stop();
	npc->AI_Stop();
	npc->SetInvul(true);
	npc->SaveGuardSpot();

	// The same entity-variable names the furniture actors use: Mob::FillSpawnStruct reads
	// them, so the spawn tail carries the binding from the very first packet.
	npc->SetEntityVariable("housing_estate_id", std::to_string(e.estate_id));
	npc->SetEntityVariable("housing_row_id", std::to_string(e.row_id));
	npc->SetEntityVariable("housing_item_row", std::to_string(e.row_id));
	npc->SetEntityVariable("housing_item_guid", NmsHousingActors::GuidForRow(e.row_id));
	npc->SetEntityVariable("housing_item_id", std::to_string(e.item_id));

	entity_list.AddNPC(npc.get());
	if (!npc->GetID()) {
		return false;
	}

	e.actor    = npc.get();
	e.spawn_id = npc->GetID();
	e.goal_x   = e.pose_x;
	e.goal_y   = e.pose_y;
	e.mode     = Mode::Stay;
	e.created  = std::chrono::steady_clock::now();
	npc.release();
	type.release();

	LogInfo(
		"[HousingPets] spawned [{}] spawn [{}] for estate [{}] row [{}] item [{}] (race {})",
		e.actor->GetCleanName(), e.spawn_id, e.estate_id, e.row_id, e.item_id, pet_race
	);
	return true;
}

// Drop entries that are gone or whose row no longer matches the wanted set, then spawn
// the missing ones. Reconcile runs on the zone-settle burst (and after despawn hooks the
// registry only shrinks, so a fresh reconcile re-spawns nothing stale).
void Reconcile()
{
	std::vector<Entry> wanted;
	if (!LoadWanted(wanted) || wanted.size() > kMaxPets) {
		return;
	}

	// Retire: entries whose row vanished from the wanted set or whose actor is dead.
	for (auto it = pets.begin(); it != pets.end();) {
		bool still_wanted = false;
		for (const auto &w : wanted) {
			if (w.estate_id == it->second.estate_id && w.row_id == it->second.row_id) {
				still_wanted = true;
				break;
			}
		}
		if (!still_wanted || !Live(it->second)) {
			RemoveEntry(it->second);
			it = pets.erase(it);
			continue;
		}
		++it;
	}

	for (auto &w : wanted) {
		const uint64_t key = KeyOf(w.estate_id, w.row_id);
		if (pets.count(key)) {
			continue;
		}

		if (!SpawnEntry(w, w.pet_race, w.pet_gender, w.pet_name)) {
			continue;
		}
		pets.emplace(key, w);
	}
}

// Publish every binding this process holds to one client (interiors host one estate, so
// no per-estate filter -- mirrors upstream's estate-scoped Publish, simplified).
void PublishAll(Client *c)
{
	for (auto &pair : pets) {
		Entry &e = pair.second;
		if (!Live(e)) {
			continue;
		}
		NmsHousingActors::PublishBinding(c, e.estate_id, e.row_id, e.spawn_id,
		                                 NmsHousingActors::GuidForRow(e.row_id));
	}
}

bool OwnerPresent(uint32_t owner_char)
{
	if (!owner_char) {
		return false;
	}
	for (const auto &pair : entity_list.GetClientList()) {
		Client *c = pair.second;
		if (c && c->Connected() && c->ClientDataLoaded() && c->CharacterID() == owner_char) {
			return true;
		}
	}
	return false;
}

Client *FindClient(uint32_t char_id)
{
	for (const auto &pair : entity_list.GetClientList()) {
		Client *c = pair.second;
		if (c && c->Connected() && c->ClientDataLoaded() && c->CharacterID() == char_id) {
			return c;
		}
	}
	return nullptr;
}

// 250ms movement + 5s authority tick, ported from upstream Process() with the region
// checks replaced by the zone bound (an interior coordinate is in-property by
// construction; ground/LoS rejections still fence the walk targets).
void ProcessTick()
{
	if (pets.empty() || !Route()) {
		return;
	}

	const auto now = std::chrono::steady_clock::now();
	if (now < next_tick) {
		return;
	}
	next_tick = now + std::chrono::milliseconds(250);
	const bool validate = now >= next_validate;
	if (validate) {
		next_validate = now + std::chrono::seconds(5);
	}

	for (auto it = pets.begin(); it != pets.end();) {
		Entry &e = it->second;

		// Dead actor, or owner no longer present in the zone: drop the pet.
		if (!Live(e) || (validate && !OwnerPresent(e.owner_char))) {
			RemoveEntry(e);
			it = pets.erase(it);
			continue;
		}
		++it;

		if (e.mode == Mode::Stay || e.mode == Mode::PlayDead) {
			continue;
		}

		const float x = e.actor->GetX();
		const float y = e.actor->GetY();
		const float z = e.actor->GetZ();

		if (e.mode == Mode::Follow) {
			Client *follower = FindClient(e.follow_char);
			if (!follower) {
				// The follower left: revert to Stay, like upstream.
				e.mode = Mode::Stay;
				e.follow_char = 0;
				StopEntry(e);
				continue;
			}
			e.goal_x = follower->GetX();
			e.goal_y = follower->GetY();
			if (std::hypot(e.goal_x - x, e.goal_y - y) < 6) {
				StopEntry(e);
				continue;
			}
		} else if (std::hypot(e.goal_x - x, e.goal_y - y) < 1) {
			// Golden-angle spiral around the placed pose, radius 4..12 (upstream).
			++e.sequence;
			const double angle   = e.sequence * kGoldenAngle;
			const float  radius  = 4 + static_cast<float>(e.sequence % 5) * 2;
			e.goal_x = e.pose_x + static_cast<float>(radius * std::cos(angle));
			e.goal_y = e.pose_y + static_cast<float>(radius * std::sin(angle));
		}

		const float dx = e.goal_x - x;
		const float dy = e.goal_y - y;
		const float length = std::hypot(dx, dy);
		if (!std::isfinite(length) || length < 0.01f) {
			continue;
		}
		const float step = std::min(length, e.mode == Mode::Walk ? kWalkStep : kRunStep);
		const float nx = x + dx / length * step;
		const float ny = y + dy / length * step;

		// Yard pets live in the shared neighborhood zone: the radius around their placed
		// pose is the containment bound (the interior's zone bound does not apply here).
		if (e.yard && std::hypot(nx - e.pose_x, ny - e.pose_y) > kYardRadius) {
			e.goal_x = x;
			e.goal_y = y;
			StopEntry(e);
			continue;
		}

		if (!zone->zonemap) {
			StopEntry(e);
			continue;
		}
		glm::vec3 point(nx, ny, z);
		const float ground = zone->zonemap->FindBestZ(point, nullptr);
		// The pet's server z sits at floor level (the spawn pose is the placed furniture's
		// floor z), so the walk target does too. Adding the model size here -- upstream's
		// height-offset policy -- put every target 6 units above the walker and tripped the
		// +/-3 height fence: Walk/Run/Follow never moved while Stay/Play Dead (no movement)
		// worked. The size stays on the NPCType, where the model scale belongs.
		const float nz = ground;
		if (!std::isfinite(ground) || ground < -100000 || std::abs(nz - z) > 3 ||
		    !zone->zonemap->CheckLoS(glm::vec3(x, y, z), glm::vec3(nx, ny, nz))) {
			// Unreachable target: park here and pick a new one on the next arrival check.
			e.goal_x = x;
			e.goal_y = y;
			StopEntry(e);
			continue;
		}

		e.actor->SetHeading(e.actor->CalculateHeadingToTarget(nx, ny));
		e.actor->SetPosition(nx, ny, nz);
		e.actor->SetMoving(true);
		MobMovementManager::Get().SendCommandToClients(
			e.actor, 0.0f, 0.0f, 0.0f, 0.0f,
			e.mode == Mode::Walk ? e.actor->GetWalkspeed() : e.actor->GetRunspeed(),
			ClientRangeAny
		);
	}
}

} // namespace

namespace NmsHousingPets {

bool IsInteriorZone()
{
	return IsPetInteriorZone();
}

void ClientProcess(Client *c)
{
	if (!c || !zone || !RuleB(Custom, HousingPets) || !IsPetInteriorZone()) {
		return;
	}

	// Zone handoff: a different zone id in the same process means the old map is stale.
	if (!pets.empty() && !Route()) {
		for (auto &pair : pets) {
			RemoveEntry(pair.second);
		}
		pets.clear();
		next_tick = std::chrono::steady_clock::time_point{};
	}
	bound_zone_id = zone->GetZoneID();

	// Zone-settle reconcile + publish, once per character per zone stay, plus a slow shared
	// periodic reconcile: the once-per-stay pass missed rows placed mid-session (the 2026-11-21
	// Holgresh placement spawned no actor until the next zone-in). LoadWanted is one small
	// indexed query; 3s keeps new placements appearing without any burst.
	static std::unordered_map<uint32_t, std::pair<uint32_t, bool>> settled; // char -> (zone id, published)
	static std::chrono::steady_clock::time_point last_reconcile{};
	const uint32_t char_id = c->CharacterID();
	auto st = settled.find(char_id);
	if (st == settled.end() || st->second.first != bound_zone_id) {
		settled[char_id] = {bound_zone_id, false};
		st = settled.find(char_id);
	}
	const bool initial = !st->second.second && c->ClientDataLoaded();
	const auto now = std::chrono::steady_clock::now();
	const bool periodic = c->ClientDataLoaded() &&
	    (last_reconcile == std::chrono::steady_clock::time_point{} ||
	     now - last_reconcile > std::chrono::seconds(3));
	if (initial || periodic) {
		Reconcile();
		if (initial) {
			PublishAll(c);
			st->second.second = true;
		}
		last_reconcile = now;
	}

	ProcessTick();
}

bool Command(Client *c, uint32_t estate_id, uint32_t row_id, uint32_t parameter)
{
	if (!c || !zone || !RuleB(Custom, HousingPets) || !IsPetInteriorZone()) {
		return false;
	}

	if (estate_id >= kHouseEstateBase) {
		estate_id -= kHouseEstateBase;
	}
	if (!estate_id || estate_id == UINT32_MAX || !row_id || row_id == UINT32_MAX) {
		return false;
	}

	Mode mode;
	if (!ModeFromParam(parameter, mode)) {
		return false;
	}

	auto it = pets.find(KeyOf(estate_id, row_id));
	if (it == pets.end() || !Live(it->second)) {
		return false;
	}
	Entry &e = it->second;

	// Owner-only v1 (the ACL system upstream checks does not exist here), and the
	// 20-unit range is upstream's.
	if (c->CharacterID() != e.owner_char) {
		LogInfo("[HousingPets] command from [{}] refused: not the owner of pet row [{}]",
		        c->GetName(), e.row_id);
		return false;
	}
	const float dx = c->GetX() - e.actor->GetX();
	const float dy = c->GetY() - e.actor->GetY();
	const float dz = c->GetZ() - e.actor->GetZ();
	if (std::sqrt(dx * dx + dy * dy + dz * dz) > kCommandRange) {
		LogInfo("[HousingPets] command from [{}] refused: pet row [{}] out of range",
		        c->GetName(), e.row_id);
		return false;
	}

	StopEntry(e);
	e.mode = mode;
	e.follow_char = (mode == Mode::Follow) ? c->CharacterID() : 0;
	e.goal_x = e.actor->GetX();
	e.goal_y = e.actor->GetY();
	e.actor->SetAppearance(mode == Mode::PlayDead ? eaDead : eaStanding);

	LogInfo("[HousingPets] command [{}] from [{}] applied to row [{}] (estate [{}])",
	        parameter, c->GetName(), e.row_id, e.estate_id);
	return true;
}

void OnRowRemoved(uint32_t estate_id, uint32_t row_id)
{
	if (estate_id >= kHouseEstateBase) {
		estate_id -= kHouseEstateBase;
	}
	auto it = pets.find(KeyOf(estate_id, row_id));
	if (it == pets.end()) {
		return;
	}
	RemoveEntry(it->second);
	pets.erase(it);
	LogInfo("[HousingPets] despawned pet for estate [{}] row [{}]", estate_id, row_id);
}

} // namespace NmsHousingPets

// ------------------------------------------------------------------
// Packet handler (registered in client_packet.cpp; carried in the log-only list no longer).
// ------------------------------------------------------------------

// 0x51e3 C2S, 12 bytes: estate id, estate-item id (= nms_house_item row id), menu parameter.
void Client::Handle_OP_RealEstateCustomInteraction(const EQApplicationPacket *app)
{
	LogInfo("[HousingPets] custom interaction from [{}] ({} bytes)", GetName(), app ? app->size : 0);

	if (!app || app->size != 12) {
		return;
	}

	auto read32 = [app](size_t at) {
		return static_cast<uint32_t>(
			app->pBuffer[at] |
			(static_cast<uint32_t>(app->pBuffer[at + 1]) << 8) |
			(static_cast<uint32_t>(app->pBuffer[at + 2]) << 16) |
			(static_cast<uint32_t>(app->pBuffer[at + 3]) << 24));
	};

	const uint32_t estate   = read32(0);
	const uint32_t row_item = read32(4);
	const uint32_t param    = read32(8);

	if (!NmsHousingPets::Command(this, estate, row_item, param)) {
		LogInfo("[HousingPets] interaction refused: estate [{}] item [{}] param [{}]",
		        estate, row_item, param);
	}
}
