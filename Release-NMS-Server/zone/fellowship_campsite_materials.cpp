#include "fellowship_campsite_materials.h"

#include "client.h"
#include "../common/eqemu_config.h"
#include "../common/fellowship/campsite_materials.h"

namespace Camps = Fellowship::Campsites;

namespace {

struct MaterialDebit {
	int16_t        slot{};
	EQ::ItemInstance* item{};
	int32_t        serial{};
	int16_t        charges{};
	uint32_t       id{};
};

bool Stage(Client& client, const Camps::Definition& definition, std::array<MaterialDebit, 2>& plan)
{
	const auto recipe = Camps::RequiredMaterials(definition);
	for (size_t i = 0; i < plan.size(); ++i) {
		const auto slot = client.GetInv().HasItem(recipe[i].item_id, 1, invWherePersonal);
		auto* item      = client.GetInv().GetItem(slot);
		if (slot == INVALID_INDEX || !item || !item->GetItem() ||
			item->GetItem()->ID != recipe[i].item_id || item->GetItem()->ItemType != 58 ||
			!item->IsStackable() || item->GetCharges() < 1 || item->GetEvolveUniqueID()) {
			return false;
		}
		plan[i] = {slot, item, item->GetSerialNumber(), item->GetCharges(), recipe[i].item_id};
	}
	return plan[0].slot != plan[1].slot;
}

bool Frame(Client& client, const std::array<MaterialDebit, 2>& plan)
{
	for (const auto& p : plan) {
		auto* item = client.GetInv().GetItem(p.slot);
		if (item != p.item || !item || item->GetSerialNumber() != p.serial ||
			item->GetCharges() != p.charges || !item->GetItem() || item->GetItem()->ID != p.id) {
			return false;
		}
	}
	return true;
}

void ReloadRequired(Client& client)
{
	// The durable outcome may differ from the in-memory inventory; the only safe
	// recovery is an authoritative reload from the database.
	client.Kick("Campsite inventory outcome requires authoritative reload");
}

}

bool HasFellowshipCampsiteMaterials(Client& client, const Camps::Definition& definition)
{
	std::array<MaterialDebit, 2> plan{};
	return Stage(client, definition, plan);
}

Fellowship::Result<Fellowship::Snapshot> CreatePaidFellowshipCampsite(Client& client,
	const Camps::Definition& definition, const Fellowship::Campfire& campfire, uint64_t now,
	uint64_t expected_revision, uint32_t expected_fellowship_id)
{
	using Error = Fellowship::Error;
	if (definition.id != campfire.type || !expected_revision || !expected_fellowship_id) {
		return {{}, Error::InvalidArgument};
	}

	std::array<MaterialDebit, 2> plan{};
	if (!Stage(client, definition, plan)) {
		return {{}, Error::InvalidArgument};
	}

	const auto* config = EQEmuConfig::get();
	if (!config) {
		return {{}, Error::DatabaseFailure};
	}

	// Dedicated connection: the material debit and the campfire write must share
	// one transaction, never the zone's shared character connection.
	Database exclusive;
	if (!exclusive.Connect(config->DatabaseHost, config->DatabaseUsername, config->DatabasePassword,
			config->DatabaseDB, config->DatabasePort, "fellowship-campsite-materials")) {
		return {{}, Error::DatabaseFailure};
	}

	Fellowship::Service service(exclusive);
	auto result = service.SetCampfire(client.CharacterID(), campfire, now, [&](Database& db) {
		// No packet, quest or yield has occurred since Stage(); the in-memory rows
		// must still be the ones we validated before the durable debit runs.
		if (!Frame(client, plan)) {
			return false;
		}
		return Camps::ConsumeMaterialsUnderTransaction(db, client.CharacterID(), definition.id, {plan[0].slot, plan[1].slot});
	}, expected_revision, expected_fellowship_id);

	if (result.error == Error::CommitUncertain) {
		ReloadRequired(client);
		return result;
	}
	if (!result) {
		return result;
	}

	// The debit is already durable; mirror it into the client view without
	// issuing another database inventory write.
	if (!Frame(client, plan)) {
		ReloadRequired(client);
		return {{}, Error::CommitUncertain};
	}
	for (const auto& p : plan) {
		client.DeleteItemInInventory(p.slot, 1, true, false);
	}
	return result;
}
