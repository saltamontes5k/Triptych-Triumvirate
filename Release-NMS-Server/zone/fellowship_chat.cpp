#include "client.h"
#include "zonedb.h"
#include "worldserver.h"
#include "../common/fellowship/service.h"
#include "../common/servertalk.h"
#include "../common/rulesys.h"
#include "../common/strings.h"
#include <ctime>

extern ZoneDatabase database;
extern WorldServer worldserver;

void Client::SendFellowshipChat(const char* message)
{
    if (!RuleB(Custom, Fellowships) || !message || !message[0]) {
        return;
    }
    Fellowship::Service fellowships(database);
    const auto group = fellowships.GetByCharacter(CharacterID(), static_cast<uint64_t>(std::time(nullptr)));
    if (!group) {
        Message(Chat::Red, "Fellowship chat is temporarily unavailable.");
        return;
    }
    if (!group.value.id) {
        Message(Chat::Red, "You are not a member of a fellowship.");
        return;
    }
    ServerPacket packet(ServerOP_FellowshipChat, sizeof(FellowshipChatRequest));
    auto* request = reinterpret_cast<FellowshipChatRequest*>(packet.pBuffer);
    request->actor_id = CharacterID();
    strn0cpy(request->message, message, sizeof(request->message));
    if (!worldserver.SendPacket(&packet)) {
        Message(Chat::Red, "Fellowship chat is unavailable while the world server is disconnected.");
    }
}
