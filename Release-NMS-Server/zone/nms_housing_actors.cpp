// nms_housing_actors.cpp -- housing world actors: spawn, bind, reconcile.
//
// See nms_housing_actors.h for the wire contract. The lifecycle here is deliberately the
// same shape the fork uses (Housing::ActorPublication / Housing::Pets): an NPC is created
// from a real npc_types row, frozen (invulnerable, AI stopped, guard spot saved) and added
// to the entity list, then the client is told which estate item that spawn stands for.
// Nothing in this file grants or revokes anything: when the guest NPCs land, eligibility
// (estate ownership, guild rank, item custody) is checked by the caller before Spawn().

#include "client.h"
#include "entity.h"
#include "npc.h"
#include "zone.h"
#include "zonedb.h"

#include "nms_housing_actors.h"

#include "../common/strings.h"

#include "fmt/format.h"

#include <cmath>
#include <cstring>
#include <map>

namespace NmsHousingActors {

namespace {

// One binding per estate row. Keyed by (estate, row) so a re-place of the same row
// replaces its actor instead of stacking a second one.
std::map<uint64_t, Published> actor_registry;

constexpr uint32_t kBindPacketSize = 32;

uint64_t ActorKeyOf(uint32_t estate_id, uint32_t row_id)
{
	return (static_cast<uint64_t>(estate_id) << 32) | static_cast<uint64_t>(row_id);
}

std::string ActorGuidFor(uint32_t row_id)
{
	return fmt::format("{:016x}", static_cast<uint64_t>(row_id));
}

// 0x21ea: spawn-to-item binding. u32 spawn id, 16 hex guid bytes, u32 estate, u32 row.
void ActorSendBinding(Client *c, const Published &published)
{
	if (!c) {
		return;
	}

	auto app = EQApplicationPacket(OP_RealEstateBindSpawn, kBindPacketSize);
	std::memset(app.pBuffer, 0, kBindPacketSize);

	auto put = [&app](unsigned at, uint32_t value) {
		for (unsigned i = 0; i < 4; ++i) {
			app.pBuffer[at + i] = static_cast<unsigned char>(value >> (i * 8));
		}
	};

	put(0, published.spawn_id);
	std::memcpy(app.pBuffer + 4, published.guid.data(), 16);
	put(24, published.estate_id);
	put(28, published.row_id);

	c->QueuePacket(&app);
}

void ActorSay(Client *c, const std::string &text)
{
	if (c) {
		c->Message(Chat::White, text.c_str());
	}
}

} // namespace

bool Spawn(Client *c, uint32_t estate_id, uint32_t row_id, uint32_t npc_type_id, uint32_t item_id,
           float x, float y, float z, float heading)
{
	if (!c || !zone) {
		return false;
	}

	if (!npc_type_id) {
		ActorSay(c, "[housing] actor spawn needs an npc_type id.");
		return false;
	}

	if (!std::isfinite(x) || !std::isfinite(y) || !std::isfinite(z) || !std::isfinite(heading)) {
		ActorSay(c, "[housing] actor spawn refused: position is not finite.");
		return false;
	}

	const NPCType *base = content_db.LoadNPCTypesData(npc_type_id);
	if (!base) {
		ActorSay(c, fmt::format("[housing] npc_type [{}] does not exist.", npc_type_id));
		return false;
	}

	// One actor per estate row: re-binding replaces.
	Remove(estate_id, row_id);

	auto npc = new NPC(base, nullptr, glm::vec4(x, y, z, heading), GravityBehavior::Flying);
	if (!npc) {
		ActorSay(c, "[housing] actor spawn failed: NPC allocation.");
		return false;
	}

	// A house guest is scenery. Nothing may attack it, it holds still, and it keeps the
	// spot it was placed at instead of wandering off the lot.
	npc->SetInvul(true);
	npc->AI_Stop();

	entity_list.AddNPC(npc);
	if (!npc->GetID()) {
		safe_delete(npc);
		ActorSay(c, "[housing] actor spawn failed: entity list refused the NPC.");
		return false;
	}

	Published published;
	published.estate_id   = estate_id;
	published.row_id      = row_id;
	published.item_id     = item_id;
	published.npc_type_id = npc_type_id;
	published.spawn_id    = npc->GetID();
	published.guid        = ActorGuidFor(row_id);

	// The binding is also carried as entity variables so a later pickup, inspect or
	// eligibility re-check can find the row from the entity alone -- and so a GM can see
	// what an actor is bound to without a DB read.
	npc->SetEntityVariable("housing_estate_id", std::to_string(estate_id));
	npc->SetEntityVariable("housing_row_id", std::to_string(row_id));
	npc->SetEntityVariable("housing_item_guid", published.guid);
	if (item_id) {
		npc->SetEntityVariable("housing_item_id", std::to_string(item_id));
	}

	npc->SaveGuardSpot();

	actor_registry[ActorKeyOf(estate_id, row_id)] = published;
	ActorSendBinding(c, published);

	LogInfo(
		"[HousingActors] spawned [{}] spawn [{}] for estate [{}] row [{}] item [{}] by [{}]",
		npc->GetCleanName(), published.spawn_id, estate_id, row_id, item_id, c->GetName()
	);

	return true;
}

bool Remove(uint32_t estate_id, uint32_t row_id)
{
	auto it = actor_registry.find(ActorKeyOf(estate_id, row_id));
	if (it == actor_registry.end()) {
		return false;
	}

	if (Mob *mob = entity_list.GetMob(it->second.spawn_id); mob && mob->IsNPC()) {
		mob->CastToNPC()->Depop(false);
	}

	LogInfo(
		"[HousingActors] removed spawn [{}] for estate [{}] row [{}]",
		it->second.spawn_id, estate_id, row_id
	);

	actor_registry.erase(it);
	return true;
}

bool Republish(Client *c, uint32_t estate_id, uint32_t row_id)
{
	auto it = actor_registry.find(ActorKeyOf(estate_id, row_id));
	if (it == actor_registry.end()) {
		return false;
	}

	ActorSendBinding(c, it->second);
	return true;
}

void PublishEstate(Client *c, uint32_t estate_id)
{
	if (!c) {
		return;
	}

	for (const auto &[key, published] : actor_registry) {
		if (published.estate_id == estate_id) {
			ActorSendBinding(c, published);
		}
	}
}

void Process()
{
	for (auto it = actor_registry.begin(); it != actor_registry.end();) {
		Mob *mob = entity_list.GetMob(it->second.spawn_id);
		if (!mob || !mob->IsNPC() || mob->CastToNPC()->GetDepop()) {
			it = actor_registry.erase(it);
			continue;
		}

		++it;
	}
}

void Clear()
{
	for (auto &[key, published] : actor_registry) {
		if (Mob *mob = entity_list.GetMob(published.spawn_id); mob && mob->IsNPC()) {
			mob->CastToNPC()->Depop(false);
		}
	}

	actor_registry.clear();
}

std::size_t Count()
{
	Process();
	return actor_registry.size();
}

const Published *Find(uint32_t estate_id, uint32_t row_id)
{
	auto it = actor_registry.find(ActorKeyOf(estate_id, row_id));
	return it == actor_registry.end() ? nullptr : &it->second;
}

bool HandleCommand(Client *c, const Seperator *sep)
{
	if (!c || !sep) {
		return false;
	}

	const std::string action = sep->argnum >= 2 ? sep->arg[2] : "";

	// #housing actor list
	if (action == "list") {
		Process();
		if (actor_registry.empty()) {
			ActorSay(c, "[housing] no published actors in this zone.");
			return true;
		}

		ActorSay(c, fmt::format("[housing] {} published actor(s):", actor_registry.size()));
		for (const auto &[key, published] : actor_registry) {
			Mob *mob = entity_list.GetMob(published.spawn_id);
			ActorSay(c, fmt::format(
				"[housing]   estate [{}] row [{}] item [{}] npc_type [{}] spawn [{}] {} guid [{}]",
				published.estate_id, published.row_id, published.item_id, published.npc_type_id,
				published.spawn_id, mob ? mob->GetCleanName() : "(gone)", published.guid
			));
		}
		return true;
	}

	// #housing actor remove <estate_id> <row_id> | remove all
	if (action == "remove") {
		if (sep->arg[3] && strcasecmp(sep->arg[3], "all") == 0) {
			const std::size_t count = actor_registry.size();
			Clear();
			ActorSay(c, fmt::format("[housing] dropped [{}] actor(s).", count));
			return true;
		}

		if (!sep->IsNumber(3) || !sep->IsNumber(4)) {
			ActorSay(c, "[housing] usage: #housing actor remove <estate_id> <row_id> | remove all");
			return true;
		}

		const uint32_t estate_id = Strings::ToUnsignedInt(sep->arg[3]);
		const uint32_t row_id    = Strings::ToUnsignedInt(sep->arg[4]);
		ActorSay(c, Remove(estate_id, row_id)
			? fmt::format("[housing] estate [{}] row [{}] actor removed.", estate_id, row_id)
			: fmt::format("[housing] nothing is bound to estate [{}] row [{}].", estate_id, row_id));
		return true;
	}

	// #housing actor bind <estate_id> <row_id>  -- re-send the binding to yourself
	if (action == "bind") {
		if (!sep->IsNumber(3) || !sep->IsNumber(4)) {
			ActorSay(c, "[housing] usage: #housing actor bind <estate_id> <row_id>");
			return true;
		}

		const uint32_t estate_id = Strings::ToUnsignedInt(sep->arg[3]);
		const uint32_t row_id    = Strings::ToUnsignedInt(sep->arg[4]);
		if (Republish(c, estate_id, row_id)) {
			ActorSay(c, fmt::format("[housing] re-sent the binding for estate [{}] row [{}].", estate_id, row_id));
		}
		else {
			ActorSay(c, fmt::format("[housing] nothing is bound to estate [{}] row [{}].", estate_id, row_id));
		}
		return true;
	}

	// #housing actor spawn <estate_id> <npc_type_id> [row_id] [item_id]
	if (action == "spawn" || action == "here") {
		const bool here = action == "here";
		const int  npc_at = here ? 3 : 4;
		const int  row_at = here ? 4 : 5;
		const int  item_at = here ? 5 : 6;
		const int  estate_at = here ? -1 : 3;

		if (!sep->IsNumber(npc_at)) {
			ActorSay(c, "[housing] usage: #housing actor spawn <estate_id> <npc_type_id> [row_id] [item_id]");
			return true;
		}

		const uint32_t npc_type_id = Strings::ToUnsignedInt(sep->arg[npc_at]);
		const uint32_t estate_id   = here ? 0 : Strings::ToUnsignedInt(sep->arg[estate_at]);
		const uint32_t row_id      = sep->IsNumber(row_at) ? Strings::ToUnsignedInt(sep->arg[row_at]) : 0;
		const uint32_t item_id     = sep->IsNumber(item_at) ? Strings::ToUnsignedInt(sep->arg[item_at]) : 0;

		if (!Spawn(c, estate_id, row_id, npc_type_id, item_id,
				c->GetX(), c->GetY(), c->GetZ(), c->GetHeading())) {
			return true;
		}

		ActorSay(c, fmt::format(
			"[housing] actor [{}] spawned at your feet: estate [{}] row [{}] item [{}], binding sent (0x21ea).",
			npc_type_id, estate_id, row_id, item_id
		));

		if (!row_id) {
			ActorSay(c, "[housing] note: row 0 is a test actor -- it carries no estate item and the client may ignore the binding.");
		}
		return true;
	}

	ActorSay(c, "[housing] usage: #housing actor spawn <estate_id> <npc_type_id> [row_id] [item_id]");
	ActorSay(c, "[housing]        #housing actor remove <estate_id> <row_id> | remove all");
	ActorSay(c, "[housing]        #housing actor bind <estate_id> <row_id>   - re-send one binding");
	ActorSay(c, "[housing]        #housing actor list                       - what this zone has published");
	return true;
}

} // namespace NmsHousingActors
