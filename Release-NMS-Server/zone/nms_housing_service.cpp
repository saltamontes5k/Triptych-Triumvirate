// nms_housing_service.cpp -- guest service NPCs bound to an estate row.
//
// See nms_housing_service.h for the model. Implementation notes that matter:
//
//   * The class is never forced. A binding names a real npc_types row and the row's class has
//     to match the service kind, so a bad authoring pair is refused with a message instead of
//     spawning something that looks like a banker and behaves like a warrior.
//   * The NPC is built from a heap copy of the content row and hands ownership to the NPC, so
//     the per-service "this is furniture, not a monster" clean-up cannot leak into the shared
//     content type every zone reads.
//   * No spawn2, no grid, no AI: the NPC stands where the estate row says and never wanders.
//   * Bindings are published per viewer. A guest who may not use a guild-only service keeps
//     seeing the actor but gets no binding for it, so the client never offers the window.

#include "client.h"
#include "entity.h"
#include "npc.h"
#include "zone.h"
#include "zonedb.h"

#include "nms_housing_actors.h"
#include "nms_housing_service.h"

#include "../common/classes.h"
#include "../common/strings.h"

#include "fmt/format.h"

#include <cmath>
#include <map>
#include <memory>
#include <string>
#include <vector>

namespace NmsHousingService {
namespace {

struct Entry {
	Binding  binding;
	uint16_t entity = 0;
	NPC     *owned  = nullptr;
};

std::map<uint64_t, Entry> service_registry;
uint32_t active_zone         = 0;
uint16_t active_instance     = 0;

uint64_t ServiceKeyOf(uint32_t door_id, uint32_t row_id)
{
	return (static_cast<uint64_t>(door_id) << 32) | static_cast<uint64_t>(row_id);
}

bool Route()
{
	return zone && active_zone == zone->GetZoneID() && active_instance == zone->GetInstanceID() && active_instance;
}

bool Live(const Entry &entry)
{
	Mob *mob = entity_list.GetMob(entry.entity);
	return mob && mob == entry.owned && mob->IsNPC() && !mob->CastToNPC()->GetDepop() &&
	       mob->GetNPCTypeID() == entry.binding.npc_type_id &&
	       static_cast<uint8_t>(mob->GetClass()) == ClassFor(entry.binding.service) &&
	       mob->GetEntityVariable("housing_service") == Name(entry.binding.service);
}

void DropActor(Entry &entry)
{
	if (Mob *mob = entity_list.GetMob(entry.entity); mob && mob == entry.owned && mob->IsNPC()) {
		mob->CastToNPC()->Depop(false);
	}
}

Entry *FindEntry(const Mob *mob)
{
	if (!mob) {
		return nullptr;
	}

	for (auto &[key, entry] : service_registry) {
		if (entry.owned == mob && entity_list.GetMob(entry.entity) == mob) {
			return &entry;
		}
	}

	return nullptr;
}

void Say(Client *c, const std::string &text)
{
	if (c) {
		c->Message(Chat::White, text.c_str());
	}
}

// The service NPC's pose comes from the estate row it is bound to: the item is the anchor.
bool RowPose(uint32_t row_id, float &x, float &y, float &z, float &heading, std::string &why)
{
	auto result = database.QueryDatabase(fmt::format(
		"SELECT pos_x, pos_y, pos_z, heading FROM nms_house_item WHERE id = {} LIMIT 1", row_id
	));

	if (!result.Success() || !result.RowCount()) {
		why = fmt::format("estate row {} does not exist", row_id);
		return false;
	}

	auto row = result.begin();
	x = Strings::ToFloat(row[0] ? row[0] : "0");
	y = Strings::ToFloat(row[1] ? row[1] : "0");
	z = Strings::ToFloat(row[2] ? row[2] : "0");
	heading = Strings::ToFloat(row[3] ? row[3] : "0");

	if (!std::isfinite(x) || !std::isfinite(y) || !std::isfinite(z) || !std::isfinite(heading)) {
		why = fmt::format("estate row {} has a non-finite pose", row_id);
		return false;
	}

	return true;
}

struct PlotOwner {
	uint32_t character_id = 0;
	uint32_t guild_id     = 0;
	bool     guild_plot   = false;
};

PlotOwner LookupOwner(uint32_t door_id)
{
	PlotOwner owner;

	auto result = database.QueryDatabase(fmt::format(
		"SELECT owner_char_id, owner_guild_id, plot_type FROM nms_plot WHERE door_id = {} LIMIT 1", door_id
	));

	if (result.Success() && result.RowCount()) {
		auto row = result.begin();
		owner.character_id = Strings::ToUnsignedInt(row[0] ? row[0] : "0");
		owner.guild_id     = Strings::ToUnsignedInt(row[1] ? row[1] : "0");
		owner.guild_plot   = Strings::ToUnsignedInt(row[2] ? row[2] : "0") != 0;
	}

	return owner;
}

bool SpawnBinding(const Binding &binding, float x, float y, float z, float heading, std::string &why)
{
	const NPCType *base = content_db.LoadNPCTypesData(binding.npc_type_id);
	if (!base) {
		why = fmt::format("npc type {} does not exist", binding.npc_type_id);
		return false;
	}

	if (static_cast<uint8_t>(base->class_) != ClassFor(binding.service)) {
		why = fmt::format(
			"npc type {} is class {}, but {} needs class {}",
			binding.npc_type_id, static_cast<int>(base->class_), Name(binding.service),
			static_cast<int>(ClassFor(binding.service))
		);
		return false;
	}

	// A copy per actor: the clean-up below must never touch the shared content type.
	auto type = std::make_unique<NPCType>(*base);
	type->loottable_id          = 0;
	type->npc_spells_id         = 0;
	type->npc_spells_effects_id = 0;
	type->npc_faction_id        = 0;
	type->faction_amount        = 0;
	type->npc_aggro             = false;
	type->aggroradius           = 0;
	type->assistradius          = 0;
	type->runspeed              = 0.0f;

	auto npc = new NPC(type.get(), nullptr, glm::vec4(x, y, z, heading), GravityBehavior::Flying);
	if (!npc) {
		why = "NPC allocation failed";
		return false;
	}

	npc->GiveNPCTypeData(type.release());
	// See nms_housing_actors.cpp: Mob::AI_Stop must run first so pAIControlled is false before
	// NPC::AI_Stop nulls the autocast timer, or NPC::AI_IdleCastCheck dereferences null.
	npc->Mob::AI_Stop();
	npc->AI_Stop();
	npc->SetInvul(true);
	npc->SetEntityVariable("housing_service", Name(binding.service));
	npc->SetEntityVariable("housing_service_estate", std::to_string(binding.door_id));
	npc->SetEntityVariable("housing_service_row", std::to_string(binding.row_id));
	// Read by Mob::FillSpawnStruct: the spawn tail then carries the housing identity, which is
	// what makes the client treat this NPC as an estate item and not a stray merchant.
	npc->SetEntityVariable("housing_item_guid", NmsHousingActors::GuidForRow(binding.row_id));
	npc->SetEntityVariable("housing_estate_id", std::to_string(binding.door_id));
	npc->SetEntityVariable("housing_item_row", std::to_string(binding.row_id));
	npc->SetEntityVariable("housing_service_guild", std::to_string(binding.guild_id));
	npc->SaveGuardSpot();

	entity_list.AddNPC(npc);
	if (!npc->GetID()) {
		safe_delete(npc);
		why = "the entity list refused the NPC";
		return false;
	}

	Entry entry;
	entry.binding = binding;
	entry.entity  = npc->GetID();
	entry.owned   = npc;
	service_registry[ServiceKeyOf(binding.door_id, binding.row_id)] = entry;

	LogInfo(
		"[HousingService] spawned {} [{}] for estate [{}] row [{}] npc type [{}]",
		Name(binding.service), entry.entity, binding.door_id, binding.row_id, binding.npc_type_id
	);

	return true;
}

} // namespace

const char *Name(Service service)
{
	switch (service) {
		case Service::Vendor:           return "vendor";
		case Service::Banker:           return "banker";
		case Service::PersonalTribute:  return "tribute";
		case Service::GuildTribute:     return "guildtribute";
		case Service::GuildBank:        return "guildbank";
		case Service::TeleportMerchant: return "teleportmerchant";
		case Service::TeleportPad:      return "teleportpad";
		default:                        return "none";
	}
}

bool Parse(const std::string &text, Service &out)
{
	struct Pair {
		const char *name;
		Service     service;
	};

	static const Pair pairs[] = {
		{"vendor", Service::Vendor},
		{"merchant", Service::Vendor},
		{"banker", Service::Banker},
		{"bank", Service::Banker},
		{"tribute", Service::PersonalTribute},
		{"personal", Service::PersonalTribute},
		{"guildtribute", Service::GuildTribute},
		{"guild-tribute", Service::GuildTribute},
		{"guildbank", Service::GuildBank},
		{"guild-bank", Service::GuildBank},
		{"teleportmerchant", Service::TeleportMerchant},
		{"teleport-merchant", Service::TeleportMerchant},
		{"teleportpad", Service::TeleportPad},
		{"pad", Service::TeleportPad},
	};

	for (const auto &pair : pairs) {
		if (strcasecmp(text.c_str(), pair.name) == 0) {
			out = pair.service;
			return true;
		}
	}

	return false;
}

uint8_t ClassFor(Service service)
{
	switch (service) {
		case Service::Vendor:           return Class::Merchant;
		case Service::TeleportMerchant: return Class::Merchant;
		case Service::Banker:           return Class::Banker;
		case Service::PersonalTribute:  return Class::TributeMaster;
		case Service::GuildTribute:     return Class::GuildTributeMaster;
		case Service::GuildBank:        return Class::GuildBanker;
		case Service::TeleportPad:      return Class::Warrior;
		default:                        return 0;
	}
}

bool GuildOnly(Service service)
{
	return service == Service::GuildTribute || service == Service::GuildBank ||
	       service == Service::TeleportMerchant || service == Service::TeleportPad;
}

std::vector<Binding> Load(uint32_t door_id)
{
	std::vector<Binding> bindings;

	auto result = database.QueryDatabase(fmt::format(
		"SELECT row_id, service, npc_type_id, guild_id FROM nms_house_service "
		"WHERE door_id = {} AND enabled = 1 ORDER BY row_id", door_id
	));

	if (!result.Success()) {
		return bindings;
	}

	for (auto row = result.begin(); row != result.end(); ++row) {
		Binding binding;
		binding.door_id     = door_id;
		binding.row_id      = Strings::ToUnsignedInt(row[0] ? row[0] : "0");
		binding.service     = static_cast<Service>(Strings::ToUnsignedInt(row[1] ? row[1] : "0"));
		binding.npc_type_id = Strings::ToUnsignedInt(row[2] ? row[2] : "0");
		binding.guild_id    = Strings::ToUnsignedInt(row[3] ? row[3] : "0");

		if (binding.row_id && binding.npc_type_id && binding.service != Service::None) {
			bindings.push_back(binding);
		}
	}

	return bindings;
}

bool Reconcile(Client *c, uint32_t door_id)
{
	if (!c || !door_id || !zone) {
		return false;
	}

	const auto bindings = Load(door_id);
	if (bindings.empty()) {
		Say(c, fmt::format("[housing] estate [{}] has no service bindings.", door_id));
		return false;
	}

	if (!service_registry.empty() && !Route()) {
		Clear();
	}

	active_zone     = zone->GetZoneID();
	active_instance = zone->GetInstanceID();

	std::size_t spawned = 0;
	for (const auto &binding : bindings) {
		float x = 0.0f, y = 0.0f, z = 0.0f, heading = 0.0f;
		std::string why;

		if (!RowPose(binding.row_id, x, y, z, heading, why)) {
			Say(c, "[housing] " + why);
			continue;
		}

		// Re-bind replaces: an edited pose or npc type must not leave a stale actor behind.
		RemoveOne(binding.door_id, binding.row_id);

		if (!SpawnBinding(binding, x, y, z, heading, why)) {
			Say(c, "[housing] " + why);
			continue;
		}

		++spawned;
	}

	PublishFor(c, door_id);

	Say(c, fmt::format("[housing] estate [{}]: {} of {} service(s) up.", door_id, spawned, bindings.size()));
	return spawned > 0;
}

void Clear()
{
	for (auto &[key, entry] : service_registry) {
		DropActor(entry);
	}

	service_registry.clear();
	active_zone     = 0;
	active_instance = 0;
}

bool RemoveOne(uint32_t door_id, uint32_t row_id)
{
	auto it = service_registry.find(ServiceKeyOf(door_id, row_id));
	if (it == service_registry.end()) {
		return false;
	}

	DropActor(it->second);
	service_registry.erase(it);
	return true;
}

void PublishFor(Client *c, uint32_t door_id)
{
	if (!c) {
		return;
	}

	for (const auto &[key, entry] : service_registry) {
		if (entry.binding.door_id != door_id || !Live(entry)) {
			continue;
		}

		// A viewer who may not use this service still sees the actor; only the binding, which
		// is what tells the client the item is interactive, is withheld.
		if (!Allows(c, entry.owned, entry.binding.service)) {
			continue;
		}

		NmsHousingActors::PublishBinding(
			c, entry.binding.door_id, entry.binding.row_id, entry.entity,
			NmsHousingActors::GuidForRow(entry.binding.row_id)
		);
	}
}

std::vector<LiveBinding> LiveBindings(Service service)
{
	std::vector<LiveBinding> bindings;
	for (const auto &[key, entry] : service_registry) {
		if (entry.binding.service == service && Live(entry)) {
			bindings.push_back(LiveBinding{entry.binding, entry.entity});
		}
	}

	return bindings;
}

bool Managed(const Mob *mob)
{
	if (!mob) {
		return false;
	}

	// GetEntityVariable is not const in this tree; the registry lookup is, and it is the
	// authoritative answer anyway -- the entity variable is only a marker for other subsystems.
	return FindEntry(mob) != nullptr || !const_cast<Mob *>(mob)->GetEntityVariable("housing_service").empty();
}

const Binding *Find(const Mob *mob)
{
	Entry *entry = FindEntry(mob);
	return entry ? &entry->binding : nullptr;
}

bool Allows(Client *c, const Mob *mob, Service service)
{
	Entry *entry = FindEntry(mob);
	if (!c || !entry || !Route() || !Live(*entry) || entry->binding.service != service) {
		return false;
	}

	const double dx = c->GetX() - mob->GetX();
	const double dy = c->GetY() - mob->GetY();
	const double dz = c->GetZ() - mob->GetZ();
	if (!std::isfinite(dx) || !std::isfinite(dy) || !std::isfinite(dz) ||
	    (dx * dx + dy * dy + dz * dz) > USE_NPC_RANGE2) {
		return false;
	}

	const PlotOwner owner = LookupOwner(entry->binding.door_id);

	// The owner of the plot may use every service standing on it.
	if (owner.character_id && owner.character_id == c->CharacterID()) {
		return true;
	}

	// The guild whose hall this is may use everything, including the guild-only kinds.
	const uint32_t required_guild = entry->binding.guild_id ? entry->binding.guild_id : owner.guild_id;
	if (required_guild && c->IsInAGuild() && c->GuildID() == required_guild) {
		return true;
	}

	// A visitor may use the non-guild services in someone else's house; a guild-only service
	// is never offered to someone outside that guild.
	return !GuildOnly(service);
}

bool AllowsMerchant(Client *c, const Mob *mob)
{
	if (!mob || !Managed(mob)) {
		return true;
	}

	const Binding *binding = Find(mob);
	return binding && Allows(c, mob, binding->service);
}

std::size_t Count()
{
	std::size_t live = 0;
	for (const auto &[key, entry] : service_registry) {
		if (Live(entry)) {
			++live;
		}
	}

	return live;
}

// The original "Friendly Guild ..." contract items. The npc type is the assistant a contract
// becomes; 0 means the item is real but this server spawns no assistant for it yet, which is
// only the teleport device until the portal step lands.
const Contract *ContractForItem(uint32_t item_id)
{
	static const Contract contracts[] = {
		{66639, Service::Vendor,           345000, "Friendly Guild General Supply Merchant"},
		{66640, Service::TeleportMerchant, 345004, "Friendly Guild Teleportation Assistant"},
		{66641, Service::Banker,           345002, "Friendly Guild Personal-Banker"},
		{66642, Service::GuildBank,        345003, "Friendly Guild Guild-Banker"},
		{66643, Service::GuildTribute,     345001, "Friendly Guild Guild-Tribute Master"},
		{66644, Service::PersonalTribute,  774,    "Friendly Guild Personal-Tribute Master"},
		{66646, Service::TeleportPad,      345008, "Guild Teleportation Device"},
	};

	for (const auto &contract : contracts) {
		if (contract.item_id == item_id) {
			return &contract;
		}
	}

	return nullptr;
}

bool BindPlacedContract(Client *c, uint32_t door_id, uint32_t row_id, uint32_t item_id)
{
	const Contract *contract = ContractForItem(item_id);
	if (!c || !contract || !door_id || !row_id) {
		return false;
	}

	Say(c, fmt::format("[housing] contract: {}.", contract->label));

	if (!contract->npc_type_id) {
		Say(c, "[housing] this device is not an assistant yet -- it becomes one with the portal step.");
		return false;
	}

	const NPCType *base = content_db.LoadNPCTypesData(contract->npc_type_id);
	if (!base) {
		Say(c, fmt::format("[housing] contract npc type [{}] does not exist; nothing was bound.",
			contract->npc_type_id));
		return false;
	}

	if (static_cast<uint8_t>(base->class_) != ClassFor(contract->service)) {
		Say(c, fmt::format("[housing] contract npc type [{}] is class {}, but {} needs class {}.",
			contract->npc_type_id, static_cast<int>(base->class_), Name(contract->service),
			static_cast<int>(ClassFor(contract->service))));
		return false;
	}

	// Guild-only assistants only make sense on a guild plot, and the binding has to name that
	// guild or the access check can never pass for anyone but the plot owner.
	const PlotOwner owner = LookupOwner(door_id);
	uint32_t guild_id = owner.guild_id;
	if (GuildOnly(contract->service) && !guild_id) {
		Say(c, fmt::format("[housing] {} needs a guild plot; this estate has no owning guild.",
			Name(contract->service)));
		return false;
	}

	auto result = database.QueryDatabase(fmt::format(
		"INSERT INTO nms_house_service (door_id, row_id, service, npc_type_id, guild_id, enabled) "
		"VALUES ({}, {}, {}, {}, {}, 1) "
		"ON DUPLICATE KEY UPDATE service = VALUES(service), npc_type_id = VALUES(npc_type_id), "
		"guild_id = VALUES(guild_id), enabled = 1",
		door_id, row_id, static_cast<int>(contract->service), contract->npc_type_id, guild_id
	));

	if (!result.Success()) {
		LogError("[HousingService] contract bind failed for estate [{}] row [{}]", door_id, row_id);
		Say(c, "[housing] the contract could not be bound; see the zone log.");
		return false;
	}

	// The assistant appears where the contract was just placed.
	return Reconcile(c, door_id);
}

bool HandleCommand(Client *c, const Seperator *sep)
{
	if (!c || !sep) {
		return false;
	}

	const std::string action = sep->argnum >= 2 ? sep->arg[2] : "";

	if (action == "list") {
		const uint32_t door_id = sep->IsNumber(3) ? Strings::ToUnsignedInt(sep->arg[3]) : 0;
		const auto bindings = Load(door_id);
		if (bindings.empty()) {
			Say(c, fmt::format("[housing] no service bindings{}.",
				door_id ? fmt::format(" for estate [{}]", door_id) : ""));
			return true;
		}

		Say(c, fmt::format("[housing] {} service binding(s):", bindings.size()));
		for (const auto &binding : bindings) {
			const Mob *mob = nullptr;
			auto it = service_registry.find(ServiceKeyOf(binding.door_id, binding.row_id));
			if (it != service_registry.end()) {
				mob = entity_list.GetMob(it->second.entity);
			}

			Say(c, fmt::format(
				"[housing]   estate [{}] row [{}] {} npc_type [{}] guild [{}] {}",
				binding.door_id, binding.row_id, Name(binding.service), binding.npc_type_id,
				binding.guild_id, mob ? "up" : "down"
			));
		}
		return true;
	}

	if (action == "clear") {
		const std::size_t count = service_registry.size();
		Clear();
		Say(c, fmt::format("[housing] dropped [{}] service NPC(s).", count));
		return true;
	}

	if (action.empty()) {
		Say(c, "[housing] usage: #housing service add <door_id> <row_id> <service> [npc_type_id] [guild_id]");
		Say(c, "[housing]        #housing service remove <door_id> <row_id>");
		Say(c, "[housing]        #housing service list [door_id]");
		Say(c, "[housing]        #housing service spawn <door_id>   - (re)spawn every binding of an estate");
		Say(c, "[housing]        #housing service clear             - depop every service NPC here");
		return true;
	}

	if (action == "spawn" || action == "reconcile") {
		if (!sep->IsNumber(3)) {
			Say(c, "[housing] usage: #housing service spawn <door_id>");
			return true;
		}

		Reconcile(c, Strings::ToUnsignedInt(sep->arg[3]));
		return true;
	}

	if (action == "remove") {
		if (!sep->IsNumber(3) || !sep->IsNumber(4)) {
			Say(c, "[housing] usage: #housing service remove <door_id> <row_id>");
			return true;
		}

		const uint32_t door_id = Strings::ToUnsignedInt(sep->arg[3]);
		const uint32_t row_id  = Strings::ToUnsignedInt(sep->arg[4]);
		auto result = database.QueryDatabase(fmt::format(
			"DELETE FROM nms_house_service WHERE door_id = {} AND row_id = {}", door_id, row_id
		));

		RemoveOne(door_id, row_id);
		Say(c, fmt::format("[housing] estate [{}] row [{}]: {} row(s) removed.",
			door_id, row_id, result.Success() ? result.RowsAffected() : 0));
		return true;
	}

	if (action == "add") {
		if (!sep->IsNumber(3) || !sep->IsNumber(4) || !sep->arg[5]) {
			Say(c, "[housing] usage: #housing service add <door_id> <row_id> <service> <npc_type_id> [guild_id]");
			return true;
		}

		const uint32_t door_id = Strings::ToUnsignedInt(sep->arg[3]);
		const uint32_t row_id  = Strings::ToUnsignedInt(sep->arg[4]);

		Service service = Service::None;
		if (!Parse(sep->arg[5], service)) {
			Say(c, "[housing] unknown service. One of: vendor banker tribute guildtribute guildbank teleportmerchant teleportpad");
			return true;
		}

		if (!sep->IsNumber(6)) {
			Say(c, fmt::format("[housing] {} needs an npc_type id whose class is {}.",
				Name(service), static_cast<int>(ClassFor(service))));
			return true;
		}

		const uint32_t npc_type_id = Strings::ToUnsignedInt(sep->arg[6]);
		const uint32_t guild_id    = sep->IsNumber(7) ? Strings::ToUnsignedInt(sep->arg[7]) : 0;

		float x = 0.0f, y = 0.0f, z = 0.0f, heading = 0.0f;
		std::string why;
		if (!RowPose(row_id, x, y, z, heading, why)) {
			Say(c, "[housing] " + why);
			return true;
		}

		const NPCType *base = content_db.LoadNPCTypesData(npc_type_id);
		if (!base) {
			Say(c, fmt::format("[housing] npc type [{}] does not exist.", npc_type_id));
			return true;
		}

		if (static_cast<uint8_t>(base->class_) != ClassFor(service)) {
			Say(c, fmt::format("[housing] npc type [{}] is class {}, but {} needs class {}.",
				npc_type_id, static_cast<int>(base->class_), Name(service),
				static_cast<int>(ClassFor(service))));
			return true;
		}

		if (GuildOnly(service) && !guild_id) {
			Say(c, fmt::format("[housing] {} is a guild service and needs a guild id.", Name(service)));
			return true;
		}

		auto result = database.QueryDatabase(fmt::format(
			"INSERT INTO nms_house_service (door_id, row_id, service, npc_type_id, guild_id, enabled) "
			"VALUES ({}, {}, {}, {}, {}, 1) "
			"ON DUPLICATE KEY UPDATE service = VALUES(service), npc_type_id = VALUES(npc_type_id), "
			"guild_id = VALUES(guild_id), enabled = 1",
			door_id, row_id, static_cast<int>(service), npc_type_id, guild_id
		));

		if (!result.Success()) {
			Say(c, "[housing] the binding was not written; see the zone log.");
			LogError("[HousingService] binding write failed for estate [{}] row [{}]", door_id, row_id);
			return true;
		}

		Say(c, fmt::format("[housing] estate [{}] row [{}] bound to {} (npc type [{}], guild [{}]).",
			door_id, row_id, Name(service), npc_type_id, guild_id));

		if (service == Service::Vendor || service == Service::TeleportMerchant) {
			auto stock = database.QueryDatabase(fmt::format(
				"SELECT COUNT(*) FROM merchantlist WHERE merchantid = {}", base->merchanttype
			));
			const auto count = (stock.Success() && stock.RowCount()) ? Strings::ToUnsignedInt(stock.begin()[0]) : 0;
			Say(c, fmt::format("[housing] that npc type sells from merchant [{}] with [{}] row(s).",
				base->merchanttype, count));
		}

		Reconcile(c, door_id);
		return true;
	}

	Say(c, "[housing] usage: #housing service add|remove|list|spawn|clear ...");
	return true;
}

} // namespace NmsHousingService
