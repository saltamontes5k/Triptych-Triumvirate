// nms_friendship.cpp -- friendship consider (server byte).
//
// UCS persists /friend adds and removes to the friends table (type 1; /ignore
// rows are type 0 and never load here). Before this file the zone never read
// that table: a player conning another player got the stock faction byte 1 on
// the wire, which the RoF2 client ignores for player targets anyway (it draws
// its own consider UI from locally cached state -- see
// reference/nsqemu-spirit-shrouds/src/tob/opcodes.md). The server byte still
// matters for the future dinput8 display hook, so a target on the considerer's
// /friend list now cons Amiably (4) and every other player con carries
// Indifferent (5); the 5 baseline is deliberate so the later spouse branch
// (Ally = 1) stays distinguishable from a stranger on the wire.
//
// The list is read once per zone-in and refreshed on OP_FriendsWho; no
// consider ever queries the database. Custom:FriendConsiderAmiable gates it.

#include "../common/global_define.h"

#include "../common/eqemu_logsys.h"
#include "../common/rulesys.h"
#include "../common/strings.h"

#include "client.h"
#include "zone.h"

#include <fmt/format.h>
#include <set>
#include <string>

void Client::LoadFriendState()
{
	m_friend_names.clear();
	if (!RuleB(Custom, FriendConsiderAmiable) || !CharacterID()) {
		return;
	}

	auto r = database.QueryDatabase(
		fmt::format(
			"SELECT name FROM friends WHERE charid = {} AND type = 1",
			CharacterID()
		)
	);
	if (!r.Success()) {
		LogError(
			"Friends list unreadable for character [{}]: [{}]",
			CharacterID(),
			r.ErrorMessage()
		);
		return;
	}

	for (auto row = r.begin(); row != r.end(); ++row) {
		if (!row[0] || !row[0][0]) {
			continue;
		}
		m_friend_names.insert(Strings::ToLower(row[0]));
	}

	// TEMP [friends-test]: zone-in evidence for the friend-con tests; remove
	// once the in-game tests have been observed.
	LogInfo("[friends] charid [{}] loaded [{}] friend names", CharacterID(), m_friend_names.size());
}

bool Client::IsFriendName(const char *name) const
{
	if (!name || !name[0]) {
		return false;
	}
	return m_friend_names.find(Strings::ToLower(name)) != m_friend_names.end();
}
