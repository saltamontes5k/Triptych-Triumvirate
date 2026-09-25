#include "../client.h"
#include "../worldserver.h"
#include "../../common/repositories/petitions_repository.h"

extern WorldServer worldserver;

void command_petition(Client *c, const Seperator *sep)
{
	if (!sep->arg[1][0]) {
		c->Message(Chat::White, "Usage: #petition [text] - File a petition for a GM to review");
		return;
	}

	if (!worldserver.Connected()) {
		c->Message(Chat::White, "Error: World server disconnected!");
		return;
	}

	const auto has_open_petition = !PetitionsRepository::GetWhere(
		database,
		fmt::format(
			"accountname = '{}' AND ischeckedout = 0",
			Strings::Escape(c->AccountName())
		)
	).empty();

	if (has_open_petition) {
		c->Message(
			Chat::White,
			"You already have a petition in the queue, you must wait for it to be answered or have a GM delete it."
		);
		return;
	}

	std::string petition_text = sep->argplus[1];
	if (petition_text.size() > 1024) {
		petition_text.resize(1024);
	}

	auto petition = PetitionsRepository::NewEntity();

	petition.petid        = c->CharacterID();
	petition.charname     = c->GetCleanName();
	petition.accountname  = c->AccountName();
	petition.petitiontext = petition_text;
	petition.zone         = zone->GetShortName();
	petition.charclass    = c->GetClass();
	petition.charrace     = c->GetRace();
	petition.charlevel    = c->GetLevel();
	petition.senttime     = std::time(nullptr);

	const auto inserted = PetitionsRepository::InsertOne(database, petition);
	if (!inserted.dib) {
		c->Message(Chat::White, "Failed to file your petition. Please try again later.");
		return;
	}

	c->Message(
		Chat::White,
		fmt::format(
			"Your petition has been filed. Petition ID: {}.",
			inserted.petid
		).c_str()
	);

	worldserver.SendEmoteMessage(
		0,
		0,
		AccountStatus::QuestTroupe,
		Chat::Yellow,
		fmt::format(
			"{} has made a petition. ID: {}",
			c->GetCleanName(),
			inserted.petid
		).c_str()
	);
}
