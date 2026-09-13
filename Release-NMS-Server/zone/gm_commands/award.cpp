#include "../client.h"
#include "../zone.h"
#include "../../common/repositories/character_data_repository.h"
#include "../questmgr.h"

void command_award(Client *c, const Seperator *sep)
{
    int arguments = sep->argnum;
    if (arguments <= 3) {
        c->Message(Chat::White, "Insufficient Number of Arguments");
        c->Message(Chat::White, "Usage: #award [Character Name] [Amount] [Reason]");
        return;
    }

    std::string character_name = Strings::Escape(sep->arg[1]);

    if (!Strings::IsNumber(sep->arg[2])) {
        c->Message(Chat::White, "Specify an award amount.");
        c->Message(Chat::White, "Usage: #award [Character Name] [Amount] [Reason]");
    }

    const auto& l = CharacterDataRepository::GetWhere(
        database,
        fmt::format(
            "`name` = '{}'",
            character_name
        )
    );

    if (l.empty()) {
        c->Message(Chat::White, "Unable to find character %s", character_name.c_str());
        c->Message(Chat::White, "Usage: #award [Character Name] [Amount] [Reason]");
        return;
    }

    auto& e = l.front();

    // Join all arguments from sep->arg[3] onwards to form the reason string
    std::string reason;
    for (int i = 3; i <= arguments; i++) {
        if (i > 3) {
            reason += " ";
        }
        reason += sep->arg[i];
    }

    if (reason.empty()) {
        c->Message(Chat::White, "Reason is a required argument");
        c->Message(Chat::White, "Usage: #award [Character Name] [Amount] [Reason]");
        return;
    }

    // The award is parked in the character's "TriuneOfFate-Award" bucket and consumed
    // by plugin::UpdateTriuneOfFateAward (NMS_custom_events.pl) the next time the character
    // zones or logs in, so this works for offline characters too. Awards issued
    // before the bucket is consumed must ACCUMULATE, not overwrite each other.
    DataBucketKey k;
    k.character_id = e.id;
    k.key = "TriuneOfFate-Award";

    const auto existing = DataBucket::GetData(k);
    int pending = Strings::ToInt(existing.value);

    const int award_amount = Strings::ToInt(sep->arg[2]);
    pending += award_amount;
    k.value = std::to_string(pending);

    DataBucket::SetData(k);

    c->Message(Chat::White, "Awarded %d Triune of Fate to %s (pending total %d). Reason: %s", award_amount, character_name.c_str(), pending, reason.c_str());
    zone->SendDiscordMessage("admin", fmt::to_string(c->GetCleanName()) + " awarded " + sep->arg[2] + " Triune of Fate to " + character_name + " Reason: " + reason);

	quest_manager.CrossZoneSignal(CZUpdateType_Expedition, 0, 666, character_name.c_str());
}
