#ifndef EQEMU_ZONE_FELLOWSHIP_CAMPSITE_MATERIALS_H
#define EQEMU_ZONE_FELLOWSHIP_CAMPSITE_MATERIALS_H

#include "../common/fellowship/campsite_catalogue.h"
#include "../common/fellowship/service.h"

class Client;

bool HasFellowshipCampsiteMaterials(Client& client, const Fellowship::Campsites::Definition& definition);

Fellowship::Result<Fellowship::Snapshot> CreatePaidFellowshipCampsite(
	Client& client,
	const Fellowship::Campsites::Definition& definition,
	const Fellowship::Campfire& campfire,
	uint64_t now,
	uint64_t expected_revision,
	uint32_t expected_fellowship_id);

#endif
