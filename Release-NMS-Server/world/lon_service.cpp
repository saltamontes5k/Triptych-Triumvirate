// lon_service.cpp -- the Legends of Norrath card service (see lon_service.h).
//
// Everything the card game needs from a server for single-player play:
//   login            GetConnectionServer (gateway) -> SendSessionID (our token) -> Results,
//                    IntroduceAccount, Sync Start; the client's Update starts the collection
//                    sync (StartInstances, SendInstances x n, Complete) and the deck list.
//   packs / decks    ProcessBulkFulfillment opens products the player owns (RemoveInstances,
//                    StartDelivery, Complete); boosters roll live's 11 C / 3 U / 1 R layout.
//   loot cards       ECommCommand_RedeemItemGrant: "Choose a Pack" gives the chosen booster,
//                    an EverQuest loot card becomes the EQ item in the account's /claim list.
//   decks            AddOnlineDeck / DeleteOnlineDeck are stored per account.
//   rewards          AccountCommand_RecordSinglePlayerGame + SetCampaignStatus: a scenario
//                    win pays live's reward card once per scenario x difficulty, and the
//                    scenario's first-win EverQuest loot card once per account.
//   gifts            a new account gets one random starter deck (fixed cards, no loot). Monthly
//                    "Choose a Pack" cards (Custom:LoNMonthlyPacks) are OFF by default -- free
//                    boosters invite throwaway accounts (design decision).
//   Loremaster       Journal achievements pay XP -> Loremaster level -> each booster's chance
//                    of an extra Loremaster loot card. The Profile window reads the level from
//                    account properties 0x1082-0x1087 (it crashes EQ without them).
//   preferences      AccountCommand_SetPreferences is stored and sent back at login.
//   casual PvP       Casual Games lobby: Create / Join a match, both Ready starts it; one client hosts
//                    (our dinput8), world relays the game commands (Custom:LoNPvPEnabled, off by default).
//   results          both clients' dinput8 report how a game ended (class 0x7F0); agreed results go to
//                    lon_pvp_match / lon_pvp_stats (Elo rating, Profile win/loss, Journal 72-74).
//   tournaments      Tournaments lobby (group 5): one open queue, single elimination, best of one, no
//                    item prizes; each pairing is a PvP game.
//
// Wire format (research/eqlib_LoN/LoN.h 55.3): 4-byte big-endian frame length; custom varints; strings
// carry their NUL; each class level writes (classId, version) before its fields.
// Field layouts: research/eqlib_LoN/LoN_messages.txt. All numbers below come from there.

#include "lon_service.h"

#include "worlddb.h"
#include "zonelist.h"

#include "../common/compression.h"
#include "../common/emu_constants.h"
#include "../common/eqemu_logsys.h"
#include "../common/net/tcp_server.h"
#include "../common/random.h"
#include "../common/rulesys.h"
#include "../common/strings.h"

#include "fmt/format.h"

#include <algorithm>
#include <cctype>
#include <cmath>
#include <cstdint>
#include <cstdlib>
#include <cstring>
#include <ctime>
#include <fstream>
#include <iterator>
#include <map>
#include <memory>
#include <set>
#include <sstream>
#include <string>
#include <unordered_map>
#include <vector>

namespace {

// ---------------------------------------------------------------------------
// Class ids and versions (LoN_messages.txt)
// ---------------------------------------------------------------------------
constexpr uint32_t kGetConnectionServer  = 0x19E;  // v1, 3 header levels
constexpr uint32_t kLoginResults         = 0x051;  // v6, 3
constexpr uint32_t kDisplayMOTD          = 0x135;  // v1, 3 (LoginCommand_DisplayMOTD; home screen box = key 1)
constexpr uint32_t kHomeNews             = 0x1C9;  // v1, 1 (NetworkCommand_News: the home screen's Getting Started)
constexpr uint32_t kLeaderBoardData      = 0x1CA;  // v1, 1 (the home screen's Leaderboards box)
constexpr uint32_t kSendPassword         = 0x19A;  // client -> server
constexpr uint32_t kSendSessionID        = 0x19B;  // client -> server
constexpr uint32_t kIntroduceAccount     = 0x072;  // v1, 2
constexpr uint32_t kSyncStart            = 0x053;  // v3, 3
constexpr uint32_t kSyncStartInstances   = 0x054;  // v2, 3
constexpr uint32_t kSyncSendInstances    = 0x055;  // v2, 3
constexpr uint32_t kSyncComplete         = 0x056;  // v2, 3
constexpr uint32_t kSyncUpdate           = 0x057;  // client -> server
constexpr uint32_t kSyncStartDelivery    = 0x08D;  // v6, 3
constexpr uint32_t kSyncRemoveInstances  = 0x08F;  // v1, 3
constexpr uint32_t kSyncBulkFulfillment  = 0x139;  // client -> server
constexpr uint32_t kDeckAddOnline        = 0x169;  // client -> server
constexpr uint32_t kDeckDeleteOnline     = 0x16A;  // client -> server
constexpr uint32_t kDeckPopulate         = 0x16B;  // v1, 3
constexpr uint32_t kRedeemItemGrant      = 0x1B9;  // v3, 2 (both directions)
constexpr uint32_t kRecordSinglePlayer   = 0x1E7;  // client -> server
constexpr uint32_t kSetCampaignStatus    = 0x19F;  // client -> server
constexpr uint32_t kSetPreferences       = 0x076;  // client -> server
constexpr uint32_t kAchievement          = 0x1E0;  // v1, 1 (an object inside the two below)
constexpr uint32_t kNotifyAchievement    = 0x1E1;  // v1, 2
constexpr uint32_t kSendAchievementList  = 0x1E2;  // v1, 2
constexpr uint32_t kRequestGameplay      = 0x1E3;  // client -> server
// Posted trades (research/lon_posted_trades.md). TradeCommand_* = 3 header levels,
// then AccountID + TradeSessionID; PostedTrade is a data object with one header pair.
constexpr uint32_t kAcceptPostedTrade    = 0x18D;  // client -> server
constexpr uint32_t kAddPostedTrade       = 0x18E;  // v1, 3 (both directions)
constexpr uint32_t kCancelPostedTrade    = 0x18F;  // v1, 3 (both directions)
constexpr uint32_t kEndPostedTrades      = 0x190;  // v1, 3
constexpr uint32_t kRequestPostedTrades  = 0x191;  // client -> server
constexpr uint32_t kStartPostedTrades    = 0x192;  // v1, 3
constexpr uint32_t kTransferPostedTrade  = 0x193;  // v2, 3
constexpr uint32_t kPostedTrade          = 0x194;  // v3, 1
constexpr uint32_t kPostedTradeError     = 0x195;  // v1, 3
constexpr uint32_t kSetListenStatus      = 0x1AF;  // client -> server
constexpr uint32_t kGetAccountsByName    = 0x1CB;  // v2, 2 (both directions)
constexpr uint32_t kGetGuildsByName      = 0x1CD;  // v1, 3 (both directions)
constexpr uint32_t kErrLoginCanceled     = 0x3B;   // "Your login attempt has been canceled."
// Custom avatars (research/lon_misc_research.md section A). ArchCommand = 2 levels.
constexpr uint32_t kGetArchetypeID       = 0x1C0;  // v1, 2 (both directions)
constexpr uint32_t kStoreArchetype       = 0x1C1;  // client -> server, no reply
constexpr uint32_t kDeleteArchetype      = 0x1C2;  // client -> server, no reply
constexpr uint32_t kAddArchetypesToDB    = 0x1C3;  // v2, 2
constexpr uint32_t kValidateUsername     = 0x1C4;  // v1, 2 (both directions)
constexpr uint32_t kErrTooManyAvatars    = 0x9C;   // "You have too many custom avatars..."
constexpr uint32_t kErrNameTaken         = 0x4D;   // "This name is already taken."
constexpr uint32_t kErrNameIllegal       = 0x4E;   // "...contains illegal words or phrases."
constexpr uint32_t kPing                 = 0x070;  // echoed
constexpr uint32_t kDisconnect           = 0x116;
constexpr uint32_t kInstanceID           = 0x15E;  // v1
constexpr uint32_t kPropertySet          = 0x017;  // v1
constexpr uint32_t kValueData            = 0x016;  // v4

// Error codes the client shows from its own table (research/eqlib_LoN/LoN_errors.txt).
constexpr uint32_t kErrSessionInvalid    = 0x3F;   // "Your session is not valid."
constexpr uint32_t kErrNotOwned          = 0x67;   // "You did not own the item that you attempted to redeem."
constexpr uint32_t kErrNoChoice          = 0x78;   // "You did not choose which item you wanted to receive."
constexpr uint32_t kErrNotAvailable      = 0x7A;   // "...not yet available. Please try again later."
constexpr uint32_t kErrRedeemUnknown     = 0x66;   // "An unknown error has occurred while attempting to redeem this item."

constexpr uint32_t kPropQuantity         = 0x802;  // RedeemItemGrant PropertySet: quantity drop-down

// Account properties the Profile window's Loremaster header reads (WAUserInfoDialog, LoN
// 0x104C6DD0; research/lon_achievements.md). Without them the window asserts
// (0x1083 must be a string) and takes EQ down.
constexpr uint32_t kPropLoreLevel        = 0x1082;  // int: Loremaster level
constexpr uint32_t kPropLoreBonus        = 0x1083;  // string: bonus-loot %, "(%1% Chance of Bonus Loot)"
constexpr uint32_t kPropLoreNext         = 0x1084;  // string: next level's %, "Next: %1%"
constexpr uint32_t kPropLoreXp           = 0x1085;  // int: total XP
constexpr uint32_t kPropLoreFloor        = 0x1086;  // int: total XP where this level started
constexpr uint32_t kPropLoreNextXp       = 0x1087;  // int: total XP where the next level starts
// Account flags: a string list the client searches by name (LoN 0x10006100). "RegisteredUser"
// gates creating/accepting posted trades and guilds. Others it checks: SubscriptionMember,
// PremiumMember, Staff, Referee, ConventionGuest and the Show* content switches (unsent).
constexpr uint32_t kPropAccountFlags     = 0xFC5;
constexpr uint32_t kLootClaimBase        = 5000000; // /claim id of a loot item = this + item id (manifest v435)
constexpr size_t   kMaxFrame             = 4 * 1024 * 1024;
constexpr size_t   kArchetypesPerChunk   = 500;

// Card data keys (research/eqlib_LoN/LoN_README.md 9.3).
constexpr uint32_t kKeyName = 1, kKeySubtype = 5, kKeySet = 73, kKeyNumber = 74, kKeyRarity = 76;
constexpr uint32_t kKeyLoremaster = 2051;   // 1 = a Loremaster bonus-loot card (the Collection filter's 0x803)
constexpr int kCommon = 70035, kUncommon = 70036, kRare = 70037, kUltraRare = 70049,
              kPromo = 70038, kFixed = 70039;

// ---------------------------------------------------------------------------
// Codec
// ---------------------------------------------------------------------------
struct Reader {
	const uint8_t *d;
	size_t         n;
	size_t         p   = 0;
	bool           bad = false;

	Reader(const uint8_t *data, size_t size) : d(data), n(size) {}

	bool eof() const { return p >= n; }

	uint32_t U()
	{
		if (p >= n) { bad = true; return 0; }
		const uint8_t b0    = d[p++];
		const uint32_t hi   = b0 >> 4;
		const uint32_t extra = hi >> 1;
		const bool     neg  = (hi & 1) != 0;
		uint32_t mag   = b0 & 0x0F;
		uint32_t shift = 4;
		for (uint32_t i = 0; i < extra; ++i) {
			if (p >= n) { bad = true; return 0; }
			mag |= static_cast<uint32_t>(d[p++]) << shift;
			shift += 8;
		}
		return neg ? ~mag : mag;
	}

	int32_t I() { return static_cast<int32_t>(U()); }

	std::string S()
	{
		const uint32_t len = U();
		if (bad || len > 0x100000 || p + len + 1 > n) { bad = true; return {}; }
		std::string s(reinterpret_cast<const char *>(d + p), len);
		p += len + 1;   // the writer puts the NUL on the wire
		return s;
	}
};

struct Writer {
	std::vector<uint8_t> b;

	Writer &U(uint32_t v)
	{
		const uint32_t inv = ~v;
		uint32_t mag = v;
		uint32_t neg = 0;
		if (inv < v) { mag = inv; neg = 1; }
		uint8_t  out[5];
		uint32_t cnt  = 1;
		uint32_t rest = mag >> 4;
		while (rest && cnt < 5) {
			out[cnt++] = static_cast<uint8_t>(rest & 0xFF);
			rest >>= 8;
		}
		out[0] = static_cast<uint8_t>((mag & 0x0F) | ((((cnt - 1) * 2) + neg) << 4));
		b.insert(b.end(), out, out + cnt);
		return *this;
	}
	Writer &I(int32_t v) { return U(static_cast<uint32_t>(v)); }
	Writer &S(const std::string &s)
	{
		U(static_cast<uint32_t>(s.size()));
		b.insert(b.end(), s.begin(), s.end());
		b.push_back(0);
		return *this;
	}
	Writer &Raw(const uint8_t *p, size_t len) { b.insert(b.end(), p, p + len); return *this; }
	Writer &Header(uint32_t cls, uint32_t ver, int levels)
	{
		for (int i = 0; i < levels; ++i) { U(cls); U(ver); }
		return *this;
	}
	Writer &Instance(uint32_t arch, uint32_t series, uint32_t number)
	{
		return U(kInstanceID).U(1).U(arch).U(series).U(number);
	}

	std::vector<uint8_t> Frame() const
	{
		std::vector<uint8_t> f(4 + b.size());
		const uint32_t len = static_cast<uint32_t>(b.size());
		f[0] = static_cast<uint8_t>(len >> 24);
		f[1] = static_cast<uint8_t>(len >> 16);
		f[2] = static_cast<uint8_t>(len >> 8);
		f[3] = static_cast<uint8_t>(len);
		std::copy(b.begin(), b.end(), f.begin() + 4);
		return f;
	}
};

struct Inst {
	uint32_t arch;
	uint32_t series;
	uint32_t number;
};

// ---------------------------------------------------------------------------
// Card data (the client's own data files, copied to Custom:LoNDataPath)
// ---------------------------------------------------------------------------
struct CardInfo {
	std::string name;
	std::string subtype;
	int         set    = -1;
	int         number = 0;
	int         rarity = 0;
	bool        loremaster = false;
};

struct Pools {
	std::vector<uint32_t> common, uncommon, rare, ultra, loot;
};

struct Scenario {
	std::string           script;
	std::string           title;
	std::vector<uint32_t> reward_cards;   // [0] = Fighter/Scout/Generic, [1] = Mage/Priest when split
	bool                  reward_split = false;
	std::vector<uint32_t> loot_cards;       // EverQuest loot card(s) on the first win (Underfoot gives five)
};

// A campaign with a completion reward: "Receive one set of rewards for winning all ten
// scenarios in this campaign with each different (non-Generic) archetype (40 games on Easy
// or 40 games on Medium). Receive foil rewards on Hard difficulty (40 games on Hard)."
struct Campaign {
	int                      id = 0;
	std::vector<std::string> scripts;
	std::vector<uint32_t>    reward_cards;
};

struct Data {
	bool                                         loaded = false;
	std::unordered_map<uint32_t, CardInfo>       cards;          // every archetype
	std::map<int, Pools>                         pools;          // booster pools by set
	std::map<uint32_t, std::vector<uint32_t>>    product_cards;  // starter product -> its cards
	std::map<uint32_t, std::vector<uint8_t>>     product_deck;   // starter product -> its .eqd
	std::set<uint32_t>                           choose_a_pack;  // "Choose a Pack" loot cards
	std::map<std::string, Scenario>              scenarios;      // by script name
	std::vector<Campaign>                        campaigns;      // only those with a completion reward
	std::map<std::string, size_t>                campaign_of;    // script -> index into campaigns
	std::vector<uint32_t>                        first_starters; // what a new account gets one of
	std::map<int, std::vector<std::string>>      campaign_scripts; // every campaign id -> its scenario scripts
	std::vector<uint32_t>                        loremaster;     // EverQuest Loremaster bonus-loot cards
};

Data g_data;

bool ReadFile(const std::string &path, std::vector<uint8_t> &out)
{
	std::ifstream f(path, std::ios::binary);
	if (!f) {
		return false;
	}
	out.assign(std::istreambuf_iterator<char>(f), std::istreambuf_iterator<char>());
	return true;
}

// Name key for matching scenario text to card names: lowercase letters, digits and spaces
// only ("Pings Palliative Potion Pack" in the text = "Ping's Palliative Potion Pack").
std::string Norm(const std::string &in)
{
	std::string out;
	for (unsigned char c : in) {
		if (std::isalnum(c)) out.push_back(static_cast<char>(std::tolower(c)));
		else if (c == ' ' && !out.empty() && out.back() != ' ') out.push_back(' ');
	}
	while (!out.empty() && out.back() == ' ') out.pop_back();
	if (out == "unscribed glyph") out = "unwritten glyph";   // the card's real name
	return out;
}

std::string Trim(const std::string &s)
{
	size_t a = s.find_first_not_of(" \t\r\n.");
	size_t b = s.find_last_not_of(" \t\r\n.");
	return a == std::string::npos ? std::string() : s.substr(a, b - a + 1);
}

// One archetype record from storage.dat (research/eqlib_LoN/LoN_README.md 9.3): EQArchetype headers, id, two
// ints, then (flag 0, class 0x13, version) and a PropertySet of key -> ValueData.
bool ParseArchetype(const uint8_t *p, size_t n, uint32_t &arch, CardInfo &out)
{
	Reader r(p, n);
	for (int i = 0; i < 4; ++i) r.U();
	arch = r.U();
	r.U();
	r.U();
	if (r.bad) return false;
	if (r.U() != 0) return true;     // no properties
	r.U();
	r.U();
	if (r.U() != kPropertySet) return false;
	r.U();
	const uint32_t count = r.U();
	for (uint32_t i = 0; i < count && !r.bad; ++i) {
		const uint32_t key = r.U();
		r.U();                         // ValueData class
		r.U();                         // version
		const uint32_t type = r.U();
		r.U();                         // owning flag
		switch (type) {
			case 1:
				if (r.U() && key == kKeyLoremaster) out.loremaster = true;
				break;
			case 2: {
				const int32_t v = r.I();
				if (key == kKeySet)    out.set    = v;
				if (key == kKeyNumber) out.number = v;
				if (key == kKeyRarity) out.rarity = v;
				if (key == kKeyLoremaster && v == 1) out.loremaster = true;
				break;
			}
			case 3: {
				std::string s = r.S();
				if (key == kKeyName)    out.name    = s;
				if (key == kKeySubtype) out.subtype = s;
				break;
			}
			case 6: {
				const uint32_t k = r.U();
				for (uint32_t j = 0; j < k && !r.bad; ++j) r.I();
				break;
			}
			default:
				return false;
		}
	}
	return !r.bad;
}

// A deck file's 50 card ids: varint 50 followed by 50 (card, 0) pairs, found by scanning
// the file as a stream of varints (the same way the Python prototype proved it).
std::vector<uint32_t> DeckCards(const std::vector<uint8_t> &deck)
{
	std::vector<uint32_t> v;
	Reader r(deck.data(), deck.size());
	while (!r.eof()) {
		const uint32_t x = r.U();
		if (r.bad) break;
		v.push_back(x);
	}
	for (size_t i = 0; i < v.size(); ++i) {
		const uint32_t cnt = v[i];
		if (cnt < 30 || cnt > 80 || i + 2 * cnt >= v.size()) continue;
		bool ok = true;
		std::vector<uint32_t> cards;
		for (uint32_t j = 0; j < cnt && ok; ++j) {
			const uint32_t c = v[i + 1 + 2 * j];
			const uint32_t z = v[i + 2 + 2 * j];
			if (c < 99000000 || z != 0) ok = false;
			cards.push_back(c);
		}
		if (ok) return cards;
	}
	return {};
}

std::string DeckName(const std::vector<uint8_t> &deck, std::string *id = nullptr)
{
	Reader r(deck.data(), deck.size());
	for (int i = 0; i < 4; ++i) r.U();
	std::string name = r.S();
	r.S();
	std::string key = r.S();
	if (id) *id = r.bad ? std::string() : key;
	return r.bad ? std::string() : name;
}

// The same deck with its name and id strings (1st and 3rd after the headers) replaced.
std::vector<uint8_t> RenameDeck(const std::vector<uint8_t> &deck, const std::string &name)
{
	Reader r(deck.data(), deck.size());
	for (int i = 0; i < 4; ++i) r.U();
	const size_t head = r.p;
	r.S();
	const size_t after_name = r.p;
	const std::string second = r.S();
	r.S();
	const size_t after_id = r.p;
	if (r.bad) return deck;
	Writer w;
	w.Raw(deck.data(), head).S(name).S(second).S(name);
	w.Raw(deck.data() + after_id, deck.size() - after_id);
	(void) after_name;
	return w.b;
}

// The best card id for a reward name: an exact (case-insensitive) name match, preferring
// the Promo / Fixed printing (reward cards were those), never a loot card.
uint32_t CardByName(const std::unordered_map<std::string, std::vector<uint32_t>> &by_name, const std::string &name)
{
	auto it = by_name.find(Norm(Trim(name)));
	if (it == by_name.end()) return 0;
	uint32_t best = 0;
	int best_rank = 99;
	for (uint32_t id : it->second) {
		const CardInfo &c = g_data.cards[id];
		const int rank = (c.rarity == kPromo || c.rarity == kFixed) ? 0 : 1;
		if (rank < best_rank || (rank == best_rank && id < best)) {
			best = id;
			best_rank = rank;
		}
	}
	return best;
}

// "Reward card - X." / "Reward card - X (Fighter, Scout, or Generic) or Y (Mage or Priest)."
// / "Loot card - A (EQ) or B (EQII). ..." -- the scenario summary text after "--".
void ParseRewards(Scenario &sc, const std::string &summary,
	const std::unordered_map<std::string, std::vector<uint32_t>> &by_name,
	const std::unordered_map<std::string, std::vector<uint32_t>> &loot_by_name)
{
	// The reward text follows "--" in most summaries; a few (Underfoot) have no dash.
	const size_t dash = summary.find("--");
	const std::string t = dash == std::string::npos ? summary : summary.substr(dash + 2);

	// "Loot card - A (EQ) or B (EQII)" or "Loot cards - A, B, C, D, and E (EQ) or ...".
	size_t lc = t.find("Loot card - ");
	size_t lskip = 12;
	if (lc == std::string::npos) { lc = t.find("Loot cards - "); lskip = 13; }
	if (lc != std::string::npos) {
		const size_t st = lc + lskip;
		const size_t e = t.find(" (EQ)", st);
		if (e != std::string::npos) {
			std::string rest = t.substr(st, e - st);
			for (;;) {
				const size_t cut = rest.find(", ");
				std::string part = cut == std::string::npos ? rest : rest.substr(0, cut);
				if (part.rfind("and ", 0) == 0) part = part.substr(4);
				auto it = loot_by_name.find(Norm(Trim(part)));
				if (it != loot_by_name.end() && !it->second.empty()) {
					sc.loot_cards.push_back(*std::min_element(it->second.begin(), it->second.end()));
				}
				if (cut == std::string::npos) break;
				rest = rest.substr(cut + 2);
			}
		}
	}

	size_t rc = t.find("Reward card - ");
	size_t skip = 14;
	if (rc == std::string::npos) { rc = t.find("Reward cards - "); skip = 15; }
	if (rc == std::string::npos) return;
	std::string body = t.substr(rc + skip);
	const size_t stop = body.find(". ");
	if (stop != std::string::npos) body = body.substr(0, stop);
	body = Trim(body);

	const size_t split = body.find(" (Fighter");
	if (split != std::string::npos) {
		const size_t or_pos = body.find(") or ", split);
		const std::string a = body.substr(0, split);
		std::string b;
		if (or_pos != std::string::npos) {
			b = body.substr(or_pos + 5);
			const size_t paren = b.find(" (");
			if (paren != std::string::npos) b = b.substr(0, paren);
		}
		const uint32_t ia = CardByName(by_name, a);
		const uint32_t ib = CardByName(by_name, b);
		if (ia) sc.reward_cards.push_back(ia);
		if (ib) sc.reward_cards.push_back(ib);
		sc.reward_split = ia && ib;
		return;
	}

	// One name, or "A, B, and C". Try the whole text first: card names can hold commas.
	if (uint32_t id = CardByName(by_name, body)) {
		sc.reward_cards.push_back(id);
		return;
	}
	std::string rest = body;
	for (;;) {
		size_t cut = rest.find(", ");
		std::string part = cut == std::string::npos ? rest : rest.substr(0, cut);
		if (part.rfind("and ", 0) == 0) part = part.substr(4);
		if (uint32_t id = CardByName(by_name, part)) sc.reward_cards.push_back(id);
		if (cut == std::string::npos) break;
		rest = rest.substr(cut + 2);
	}
}

bool LoadData(const std::string &root)
{
	std::vector<uint8_t> index, storage;
	if (!ReadFile(root + "/archetypes/index.dat", index) || !ReadFile(root + "/archetypes/storage.dat", storage)) {
		LogError("[LoN] card data missing under [{}] -- copy the client's LegendsOfNorrath/data there", root);
		return false;
	}

	Reader ir(index.data(), index.size());
	ir.U();
	ir.U();
	int parsed = 0, failed = 0;
	std::vector<char> buf;
	while (!ir.eof() && !ir.bad) {
		const uint32_t a = ir.U(), c = ir.U(), u = ir.U(), o = ir.U();
		if (ir.bad) break;
		if (static_cast<size_t>(o) + c > storage.size() || u == 0 || u > 8 * 1024 * 1024) { ++failed; continue; }
		buf.resize(u + 64);
		const uint32_t got = EQ::InflateData(reinterpret_cast<const char *>(storage.data() + o), c, buf.data(), static_cast<uint32>(buf.size()));
		uint32_t arch = 0;
		CardInfo info;
		if (got == 0 || !ParseArchetype(reinterpret_cast<const uint8_t *>(buf.data()), got, arch, info)) { ++failed; continue; }
		g_data.cards[arch] = info;
		++parsed;
		(void) a;
	}

	std::unordered_map<std::string, std::vector<uint32_t>> by_name, loot_by_name;
	for (auto &kv : g_data.cards) {
		const uint32_t id = kv.first;
		const CardInfo &c = kv.second;
		if (c.name.find("Choose a Pack") != std::string::npos) g_data.choose_a_pack.insert(id);
		// Loremaster cards are loot cards for EQ, EQII and EQII Pass; only EverQuest's can be
		// redeemed here, so only those are the bonus pool.
		if (c.loremaster && c.subtype == "EverQuest Loot Card") g_data.loremaster.push_back(id);
		if (id < 20000000 || c.set < 0) continue;
		const bool is_loot = c.subtype.size() > 10 && c.subtype.compare(c.subtype.size() - 10, 10, " Loot Card") == 0;
		if (is_loot) {
			if (c.subtype == "EverQuest Loot Card") {
				g_data.pools[c.set].loot.push_back(id);
				loot_by_name[Norm(c.name)].push_back(id);
			}
			continue;
		}
		by_name[Norm(c.name)].push_back(id);
		Pools &p = g_data.pools[c.set];
		switch (c.rarity) {
			case kCommon:    p.common.push_back(id); break;
			case kUncommon:  p.uncommon.push_back(id); break;
			case kRare:      p.rare.push_back(id); break;
			case kUltraRare: p.ultra.push_back(id); break;
			default: break;
		}
	}
	for (auto &kv : g_data.pools) {
		for (auto *v : {&kv.second.common, &kv.second.uncommon, &kv.second.rare, &kv.second.ultra, &kv.second.loot}) {
			std::sort(v->begin(), v->end());
		}
	}

	// Starter decks: products N900002-5 have a deck file of the same number.
	for (uint32_t set = 1; set <= 20; ++set) {
		for (uint32_t k = 2; k <= 5; ++k) {
			const uint32_t product = set * 1000000 + 900000 + k;
			std::vector<uint8_t> deck;
			if (!ReadFile(fmt::format("{}/decks/{}.eqd", root, product), deck)) continue;
			std::vector<uint32_t> cards = DeckCards(deck);
			if (cards.empty()) continue;
			// Eight shipped starter decks (the Oathbound and Forsworn ones) have an EMPTY name,
			// and a nameless deck crashes the client at Select Deck (DeckDB.cpp:194). Give them
			// the product's own name ("Oathbound Fighter Starter Deck") in the name and id
			// strings -- the first and third strings after the four header varints.
			if (DeckName(deck).empty() && g_data.cards.count(product) && !g_data.cards[product].name.empty()) {
				deck = RenameDeck(deck, g_data.cards[product].name);
			}
			g_data.product_cards[product] = cards;
			g_data.product_deck[product]  = deck;
			if (set == 1) g_data.first_starters.push_back(product);
		}
	}

	// Scenarios and their rewards (campaign.dat: count, then Campaign objects 0x1C5 v4
	// holding CampaignScenario objects 0x1C6 v7 -- research/eqlib_LoN/LoN_campaigns.txt).
	std::vector<uint8_t> camp;
	if (ReadFile(root + "/campaign.dat", camp)) {
		Reader r(camp.data(), camp.size());
		const uint32_t ncamp = r.U();
		for (uint32_t i = 0; i < ncamp && !r.bad; ++i) {
			r.U(); const uint32_t cver = r.U();
			Campaign cp;
			cp.id = r.I();
			r.U(); r.S(); r.S();
			const std::string cdesc = r.S();
			const uint32_t nsc = r.U();
			for (uint32_t j = 0; j < nsc && !r.bad; ++j) {
				r.U(); const uint32_t sver = r.U();
				Scenario sc;
				r.U();
				sc.title = r.S();
				r.S();
				const std::string summary = r.S();
				sc.script = r.S();
				if (sver >= 2) { r.S(); r.U(); }
				if (sver >= 3) { r.U(); r.U(); }
				if (sver >= 4) r.U();
				if (sver >= 5) r.U();
				if (sver >= 6) { r.U(); r.U(); }
				if (sver >= 7) r.S();
				ParseRewards(sc, summary, by_name, loot_by_name);
				if (!sc.script.empty()) {
					g_data.scenarios[sc.script] = sc;
					cp.scripts.push_back(sc.script);
				}
			}
			g_data.campaign_scripts[cp.id] = cp.scripts;
			if (cdesc.find("with each different (non-Generic) archetype") != std::string::npos) {
				Scenario tmp;
				ParseRewards(tmp, "--" + cdesc, by_name, loot_by_name);
				cp.reward_cards = tmp.reward_cards;
				if (!cp.reward_cards.empty() && !cp.scripts.empty()) {
					for (const std::string &sc_name : cp.scripts) g_data.campaign_of[sc_name] = g_data.campaigns.size();
					g_data.campaigns.push_back(cp);
				}
			}
			if (cver >= 2) r.U();
			if (cver >= 3) r.U();
			if (cver >= 4) r.U();
		}
		if (r.bad) LogError("[LoN] campaign.dat did not parse to the end -- scenario rewards may be incomplete");
	}

	int with_reward = 0;
	for (auto &kv : g_data.scenarios) if (!kv.second.reward_cards.empty() || !kv.second.loot_cards.empty()) ++with_reward;
	std::sort(g_data.loremaster.begin(), g_data.loremaster.end());
	LogInfo("[LoN] card data: [{}] archetypes ([{}] unreadable), [{}] booster sets, [{}] starter decks, [{}] scenarios ([{}] with rewards), [{}] campaign rewards, [{}] Loremaster cards",
		parsed, failed, g_data.pools.size(), g_data.product_cards.size(), g_data.scenarios.size(), with_reward, g_data.campaigns.size(), g_data.loremaster.size());
	return parsed > 0 && !g_data.pools.empty();
}

// ---------------------------------------------------------------------------
// Database helpers
// ---------------------------------------------------------------------------
EQ::Random g_rng;

uint32_t ToU(const char *s) { return s ? static_cast<uint32_t>(std::strtoul(s, nullptr, 10)) : 0; }

std::string Hex(const std::vector<uint8_t> &b)
{
	static const char *k = "0123456789ABCDEF";
	std::string s;
	s.reserve(b.size() * 2);
	for (uint8_t c : b) { s.push_back(k[c >> 4]); s.push_back(k[c & 15]); }
	return s;
}

std::vector<uint8_t> Unhex(const char *s)
{
	std::vector<uint8_t> out;
	if (!s) return out;
	auto v = [](char c) -> int {
		if (c >= '0' && c <= '9') return c - '0';
		if (c >= 'A' && c <= 'F') return c - 'A' + 10;
		if (c >= 'a' && c <= 'f') return c - 'a' + 10;
		return 0;
	};
	for (size_t i = 0; s[i] && s[i + 1]; i += 2) out.push_back(static_cast<uint8_t>(v(s[i]) * 16 + v(s[i + 1])));
	return out;
}

// Adds copies to an account and returns them as instances (instance number = row id).
std::vector<Inst> GiveCards(uint32_t account_id, const std::vector<uint32_t> &archetypes, const std::string &source)
{
	std::vector<Inst> out;
	for (uint32_t a : archetypes) {
		auto r = database.QueryDatabase(fmt::format(
			"INSERT INTO lon_card (account_id, archetype, source) VALUES ({}, {}, '{}')",
			account_id, a, Strings::Escape(source)));
		if (r.Success() && r.LastInsertedID()) out.push_back({a, 0, r.LastInsertedID()});
	}
	return out;
}

// Removes exactly these copies if the account owns them all; false (and nothing removed) if not.
bool TakeCards(uint32_t account_id, const std::vector<Inst> &cards)
{
	for (const Inst &c : cards) {
		auto r = database.QueryDatabase(fmt::format(
			"SELECT COUNT(*) FROM lon_card WHERE id = {} AND account_id = {} AND archetype = {}",
			c.number, account_id, c.arch));
		if (!r.Success() || r.RowCount() == 0 || ToU(r.begin()[0]) != 1) return false;
	}
	for (const Inst &c : cards) {
		database.QueryDatabase(fmt::format("DELETE FROM lon_card WHERE id = {} AND account_id = {}", c.number, account_id));
	}
	return true;
}

std::vector<Inst> CopiesOf(uint32_t account_id, uint32_t archetype, uint32_t limit)
{
	std::vector<Inst> out;
	auto r = database.QueryDatabase(fmt::format(
		"SELECT id FROM lon_card WHERE account_id = {} AND archetype = {} ORDER BY id LIMIT {}",
		account_id, archetype, limit));
	if (r.Success()) for (auto row : r) out.push_back({archetype, 0, ToU(row[0])});
	return out;
}

// ---------------------------------------------------------------------------
// Products
// ---------------------------------------------------------------------------
uint32_t Pick(const std::vector<uint32_t> &v) { return v[static_cast<size_t>(g_rng.Int(0, static_cast<int>(v.size()) - 1))]; }

std::vector<uint32_t> RollBooster(int set)
{
	auto it = g_data.pools.find(set);
	if (it == g_data.pools.end()) return {};
	const Pools &p = it->second;
	if (p.common.empty() || p.uncommon.empty() || p.rare.empty()) return {};
	std::vector<uint32_t> out;
	for (int i = 0; i < 11; ++i) out.push_back(Pick(p.common));
	for (int i = 0; i < 3; ++i) out.push_back(Pick(p.uncommon));
	if (!p.loot.empty() && g_rng.Int(1, 1000) <= RuleI(Custom, LoNLootPermille)) {
		out.push_back(Pick(p.loot));
	}
	else if (!p.ultra.empty() && g_rng.Int(1, 1000) <= RuleI(Custom, LoNUltraRarePermille)) {
		out.push_back(Pick(p.ultra));
	}
	else {
		out.push_back(Pick(p.rare));
	}
	return out;
}

bool IsBooster(uint32_t arch) { return arch < 20000000 && arch % 1000000 == 900001; }

// What opening one product gives; empty = not a product we can open.
std::vector<uint32_t> OpenProduct(uint32_t arch)
{
	auto it = g_data.product_cards.find(arch);
	if (it != g_data.product_cards.end()) return it->second;
	if (IsBooster(arch)) return RollBooster(static_cast<int>(arch / 1000000));
	return {};
}

// ---------------------------------------------------------------------------
// Connections
// ---------------------------------------------------------------------------
struct Session {
	std::shared_ptr<EQ::Net::TCPConnection> conn;
	std::vector<uint8_t> in;
	uint32_t account_id   = 0;
	uint32_t character_id = 0;
	std::string name;
	std::string gateway_session;
	std::string gateway_user;
	bool     synced       = false;
	uint32_t delivery     = 0;
	int      difficulty   = 0;    // highest SetCampaignStatus Difficulty Level since the last game end
	int      archetype    = 0;    // SetCampaignStatus CustomInt = the hero archetype (70001-70005)
	bool     lore_dirty   = false; // an achievement paid XP: resend the Loremaster properties
	bool     trade_listen = false; // the Posted Trades window is open (TradeCommand_SetListenStatus)
	uint32_t lobby_group  = 0;     // the type-1 lobby this connection is in (3 Trade Lobby, 2 Casual Games), 0 = none
	uint32_t lobby_status = 3;     // the client's own LobbyCommand_ChangeStatus (2 online, 7 trading)
	uint32_t pvp_match    = 0;     // the casual PvP match this connection plays in (M), 0 = none
	uint32_t room         = 0;     // the Casual Games match room it sits in before the game starts (M)
	std::set<uint32_t> known_matches;   // child groups this client holds: matches, tournament queues and
	                                    // tournaments (sent AddGroups, no RemoveGroups yet)
	std::string ip;                     // the player's address (rating and tournament IP rules)
	uint32_t queue        = 0;          // the tournament queue it waits in (Q), 0 = none
	uint32_t game_screen  = 0;          // the PvP game screen it may still show (M), cleared when the client
	                                    // leaves it -- a tournament round never launches over an old game
};

std::unique_ptr<EQ::Net::TCPServer> g_server;
std::map<EQ::Net::TCPConnection *, std::shared_ptr<Session>> g_sessions;
std::set<uint32_t> g_card_lock;   // lon_card ids offered in a live trade right now (posted trades skip them)
uint32_t g_last_process = 0;

void Send(Session &s, const Writer &w)
{
	const std::vector<uint8_t> f = w.Frame();
	if (s.conn && s.conn->IsConnected()) s.conn->Write(reinterpret_cast<const char *>(f.data()), f.size());
}

Writer RemoveInstances(const std::vector<Inst> &v)
{
	Writer w;
	w.Header(kSyncRemoveInstances, 1, 3).U(static_cast<uint32_t>(v.size()));
	for (const Inst &i : v) w.Instance(i.arch, i.series, i.number);
	return w;
}

// source "trade" with source_id = -posted trade id makes the Delivery window say "Posted trade: N".
Writer StartDelivery(uint32_t delivery, const std::vector<Inst> &v, bool silent,
	const std::string &source = "", int32_t source_id = 0)
{
	std::set<uint32_t> distinct;
	for (const Inst &i : v) distinct.insert(i.arch);
	Writer w;
	w.Header(kSyncStartDelivery, 6, 3)
		.U(static_cast<uint32_t>(distinct.size()))  // ArchetypeCount
		.U(0)                                       // CollectionModID
		.U(silent ? 1 : 0)                          // Silent: 0 shows the Delivery window
		.U(delivery)                                // DeliveryID
		.U(delivery)                                // TransactionID
		.S(source)                                  // TransactionSource
		.I(source_id).U(0)                          // TransactionSourceID, ID2
		.U(static_cast<uint32_t>(v.size()));
	for (const Inst &i : v) w.Instance(i.arch, i.series, i.number);
	w.U(0);                                         // NonTradableInstances
	return w;
}

Writer Complete(uint32_t delivery)
{
	Writer w;
	w.Header(kSyncComplete, 2, 3).U(delivery);
	return w;
}

void Deliver(Session &s, const std::vector<Inst> &removed, const std::vector<Inst> &added, bool silent = false)
{
	const uint32_t id = ++s.delivery;
	if (!removed.empty()) Send(s, RemoveInstances(removed));
	Send(s, StartDelivery(id, added, silent));
	Send(s, Complete(id));
}

// Saved decks + the starter decks of every starter product the account has opened.
void SendDecks(Session &s)
{
	std::vector<std::vector<uint8_t>> decks;
	auto r = database.QueryDatabase(fmt::format("SELECT HEX(deck) FROM lon_deck WHERE account_id = {} ORDER BY id", s.account_id));
	if (r.Success()) for (auto row : r) decks.push_back(Unhex(row[0]));

	auto o = database.QueryDatabase(fmt::format(
		"SELECT DISTINCT source FROM lon_card WHERE account_id = {} AND source LIKE 'starter:%'", s.account_id));
	std::set<std::string> have_names;
	for (auto &d : decks) have_names.insert(DeckName(d));
	if (o.Success()) {
		for (auto row : o) {
			const uint32_t product = ToU(row[0] + 8);
			auto it = g_data.product_deck.find(product);
			if (it == g_data.product_deck.end()) continue;
			const std::string nm = DeckName(it->second);
			if (nm.empty() || have_names.count(nm)) continue;   // a nameless deck crashes Select Deck
			decks.push_back(it->second);
			have_names.insert(nm);
		}
	}

	Writer w;
	w.Header(kDeckPopulate, 1, 3).U(static_cast<uint32_t>(decks.size()));
	for (auto &d : decks) { w.U(0); w.Raw(d.data(), d.size()); }
	Send(s, w);
}

void SendCollection(Session &s)
{
	struct Item { std::vector<Inst> tradable, locked; };
	std::map<uint32_t, Item> items;
	auto r = database.QueryDatabase(fmt::format(
		"SELECT archetype, series, id, tradable FROM lon_card WHERE account_id = {} ORDER BY archetype, id", s.account_id));
	if (r.Success()) {
		for (auto row : r) {
			Inst i{ToU(row[0]), ToU(row[1]), ToU(row[2])};
			(ToU(row[3]) ? items[i.arch].tradable : items[i.arch].locked).push_back(i);
		}
	}

	Writer st;
	st.Header(kSyncStartInstances, 2, 3).U(s.account_id).U(0).U(static_cast<uint32_t>(items.size())).U(0);
	Send(s, st);

	std::vector<const Item *> order;
	for (auto &kv : items) order.push_back(&kv.second);
	for (size_t base = 0; base < order.size() || base == 0; base += kArchetypesPerChunk) {
		const size_t end = std::min(order.size(), base + kArchetypesPerChunk);
		Writer w;
		w.Header(kSyncSendInstances, 2, 3).U(static_cast<uint32_t>(base)).U(static_cast<uint32_t>(end - base));
		size_t n = 0;
		for (size_t k = base; k < end; ++k) n += order[k]->tradable.size();
		w.U(static_cast<uint32_t>(n));
		for (size_t k = base; k < end; ++k) for (const Inst &i : order[k]->tradable) w.Instance(i.arch, i.series, i.number);
		n = 0;
		for (size_t k = base; k < end; ++k) n += order[k]->locked.size();
		w.U(static_cast<uint32_t>(n));
		for (size_t k = base; k < end; ++k) for (const Inst &i : order[k]->locked) w.Instance(i.arch, i.series, i.number);
		w.U(0);
		Send(s, w);
		if (order.empty()) break;
	}
	Send(s, Complete(0));
	SendDecks(s);
	LogInfo("[LoN] [{}] collection sent: [{}] archetypes", s.name, items.size());
}

// ---------------------------------------------------------------------------
// Loremaster (research/lon_achievements.md)
// ---------------------------------------------------------------------------
// Live: Journal achievements pay XP, XP makes the Loremaster level, and every level adds
// 0.5% to a booster's chance of an extra Loremaster loot card. The achievement names and
// descriptions ship in the client (keyed by id); the server sends which ones exist, their
// XP and what the account completed. Live's XP values were never published -- these are
// ours (design decision), sized to Sony's one example: level 4 needs 111 XP.
struct AchievementDef {
	int         id;
	const char *icon;       // the Journal icon and sort group: LM_icon_<category>_
	int         xp;
	const char *stat;       // gameplay achievements: the client's stat name ("" = server-tracked)
	int         threshold;  // the client reports the stat once it reaches this
	bool        hidden;     // "Hidden" / "???" until completed
};

// Not listed: 1 (foil in a booster -- our boosters have no foils), 5 (no promo packs), the
// multiplayer ones world cannot see (raids 34-54, friends/guild 70-71) and the 2013 SOE Live
// event ones (57, 58, 77-81).
const AchievementDef kAchievements[] = {
	{0,  "LM_icon_pack_",       25, "", -1, true},    // Secret Surprise! -- a Loremaster bonus card
	{2,  "LM_icon_pack_",       25, "", -1, false},   // Precious Find -- an ultra rare from a booster
	{3,  "LM_icon_pack_",       10, "", -1, false},   // Open a Booster Pack
	{4,  "LM_icon_pack_",       10, "", -1, false},   // Open a Starter Deck
	{56, "LM_icon_pack_",       25, "", -1, false},   // Treasure Hunter -- a loot card from a booster
	{6,  "LM_icon_scenario_",   25, "", -1, false},   // Win a Scenario on Hard
	{7,  "LM_icon_scenario_",   15, "", -1, false},   // ... on Medium
	{8,  "LM_icon_scenario_",   10, "", -1, false},   // ... on Easy
	{9,  "LM_icon_scenario_",   10, "", -1, false},   // ... with Fighter
	{10, "LM_icon_scenario_",   10, "", -1, false},   // ... with Generic
	{11, "LM_icon_scenario_",   10, "", -1, false},   // ... with Mage
	{12, "LM_icon_scenario_",   10, "", -1, false},   // ... with Priest
	{13, "LM_icon_scenario_",   10, "", -1, false},   // ... with Scout
	{14, "LM_icon_scenario_",  100, "", -1, false},   // Oathbound block campaigns
	{15, "LM_icon_scenario_",  100, "", -1, false},   // Ethernauts block
	{16, "LM_icon_scenario_",  100, "", -1, false},   // Travelers block
	{17, "LM_icon_scenario_",  100, "", -1, false},   // Dragonbrood block
	{18, "LM_icon_scenario_",   50, "", -1, false},   // Legacies campaign
	{19, "LM_icon_scenario_",   50, "", -1, false},   // Debt of the Ratonga campaign
	{20, "LM_icon_gameplay_",   25, "QuestsCompleted",       10, false},
	{21, "LM_icon_gameplay_",   25, "PlayedUnits",           10, false},
	{22, "LM_icon_gameplay_",   25, "DamageBonusMax",        10, false},
	{23, "LM_icon_gameplay_",   25, "DamageDealt",           20, false},
	{24, "LM_icon_gameplay_",   25, "HealingAvatar",         10, false},
	{25, "LM_icon_gameplay_",   25, "HealingUnits",          10, false},
	{26, "LM_icon_gameplay_",   25, "HealingTotal",          20, false},
	{27, "LM_icon_gameplay_",   25, "DestroyedUnits",        10, false},
	{28, "LM_icon_gameplay_",   25, "MaxCombatDifferential", 10, false},
	{29, "LM_icon_gameplay_",   15, "PlayedItems",            5, false},
	{30, "LM_icon_gameplay_",   15, "PlayedAbilities",        5, false},
	{31, "LM_icon_gameplay_",   15, "PlayedTactics",          5, false},
	{32, "LM_icon_gameplay_",   15, "DestroyedItems",         5, false},
	{33, "LM_icon_gameplay_",   15, "DamageReduced",          5, false},
	{85, "LM_icon_gameplay_",   15, "QuestsCompleted",        5, false},
	{86, "LM_icon_gameplay_",   15, "PlayedUnits",            5, false},
	{87, "LM_icon_gameplay_",   15, "DamageBonusMax",         5, false},
	{88, "LM_icon_gameplay_",   15, "DestroyedUnits",         5, false},
	{89, "LM_icon_gameplay_",   15, "MaxCombatDifferential",  5, false},
	{90, "LM_icon_gameplay_",   25, "DamageReduced",         10, false},
	{91, "LM_icon_gameplay_",   25, "PlayedTactics",         10, false},
	{92, "LM_icon_gameplay_",   25, "PlayedAbilities",       10, false},
	// Win by avatar kill / by questing: the client reports VictoryType at every win (threshold 1
	// matches both), so HandleGameplayAchievement picks the one by the value -- the loser's loss
	// type from gameWonByPlayer (LoN 0x10269AC0): 0x11175 avatar killed, 0x11177 quest/script win.
	{75, "LM_icon_game_",       10, "VictoryType",            1, false},
	{76, "LM_icon_game_",       10, "VictoryType",            1, false},
	{55, "LM_icon_tutorial_",   50, "", -1, false},   // Master of Lessons -- all 11 tutorials
	{59, "LM_icon_deck_",       10, "", -1, false},   // Build a Fighter Deck
	{60, "LM_icon_deck_",       10, "", -1, false},   // ... Generic
	{61, "LM_icon_deck_",       10, "", -1, false},   // ... Mage
	{62, "LM_icon_deck_",       10, "", -1, false},   // ... Priest
	{63, "LM_icon_deck_",       10, "", -1, false},   // ... Scout
	{64, "LM_icon_deck_",       25, "", -1, false},   // Builder of Decks -- all five
	{65, "LM_icon_avatar_",     10, "", -1, false},   // Create a Fighter Avatar
	{66, "LM_icon_avatar_",     10, "", -1, false},   // ... Mage
	{67, "LM_icon_avatar_",     10, "", -1, false},   // ... Priest
	{68, "LM_icon_avatar_",     10, "", -1, false},   // ... Scout
	{69, "LM_icon_avatar_",     25, "", -1, false},   // Creator of Avatars -- all four
	{84, "LM_icon_trade_",      10, "", -1, false},   // Post a Trade
	{82, "LM_icon_trade_",      10, "", -1, false},   // Complete a Posted Trade as Buyer
	{83, "LM_icon_trade_",      10, "", -1, false},   // Complete a Posted Trade as Seller
	// PvP (RecordPvPResult): only a game won or lost by questing, avatar defeat or decking that both
	// clients reported alike, between two accounts on two addresses, long enough to count.
	{72, "LM_icon_game_",       25, "", -1, false},   // Friendly Combat -- win a casual game
	{73, "LM_icon_game_",       10, "", -1, false},   // Honorable Defeat -- lose a casual game
	{74, "LM_icon_game_",       50, "", -1, false},   // Win a Tournament Game
};

const AchievementDef *FindAchievement(int id)
{
	for (const AchievementDef &a : kAchievements) if (a.id == id) return &a;
	return nullptr;
}

// The campaign groups behind achievements 14-19 (campaign ids from campaign.dat).
const std::map<int, std::vector<int>> kCampaignGroups = {
	{14, {1, 2, 3, 4, 5, 6, 8, 9, 10, 11, 12, 13}},        // Oathbound, Forsworn, Inquisitor, Oathbreaker
	{15, {15, 16, 17, 22, 23, 24, 31, 32, 33}},            // Ethernauts, Against the Void, Storm Break
	{16, {38, 39, 40, 45, 46, 47, 53, 54, 55}},            // Travelers, Vengeful Gods, Doom of the Ancient Ones
	{17, {60, 61, 62, 74, 75}},                            // Dragonbrood, Priestess of the Anarchs, Fall of the Estarim
	{18, {67, 68, 69}},                                    // Legacies
	{19, {78}},                                            // Debt of the Ratonga
};

// Hero / deck archetype -> the "with Fighter" ... "with Scout" achievement, and the deck one.
int ScenarioArchetypeAchievement(int arch) { return arch >= 70001 && arch <= 70005 ? 9 + (arch - 70001) : -1; }
int DeckArchetypeAchievement(int arch)     { return arch >= 70001 && arch <= 70005 ? 59 + (arch - 70001) : -1; }
// Create a Fighter / Mage / Priest / Scout Avatar (65-68); Generic (70002) has none.
int AvatarHeroAchievement(int arch)
{
	switch (arch) {
		case 70001: return 65;
		case 70003: return 66;
		case 70004: return 67;
		case 70005: return 68;
		default:    return -1;
	}
}

bool SkipValue(Reader &r, uint32_t type);

// A saved custom avatar's hero type (70001-70005): property 0x11609 of the archetype's PropertySet,
// the first PropertySet header (0x17, version 1) in the object the client stored. 0 if not found.
int AvatarHeroType(const std::vector<uint8_t> &blob)
{
	constexpr uint32_t kPropHeroType = 0x11609;
	static const uint8_t kSetHeader[] = {0x27, 0x01, 0x01};   // U(0x17) U(1)
	auto at = std::search(blob.begin(), blob.end(), std::begin(kSetHeader), std::end(kSetHeader));
	if (at == blob.end()) return 0;
	Reader r(blob.data(), blob.size());
	r.p = static_cast<size_t>(at - blob.begin()) + sizeof(kSetHeader);
	const uint32_t n = r.U();
	for (uint32_t i = 0; i < n && i < 256 && !r.bad; ++i) {
		const uint32_t key = r.U();
		if (r.U() != kValueData || r.U() != 4) return 0;
		const uint32_t type = r.U();
		r.U();   // owning
		if (key == kPropHeroType && (type == 1 || type == 2)) return static_cast<int>(r.U());
		if (!SkipValue(r, type)) return 0;
	}
	return 0;
}

struct Lore {
	int      level;
	uint32_t xp, floor, next;
};

// Level 1 starts at 0 XP; level L needs 75 + 9L more (level 4: 111, as live's example).
Lore LoreFor(uint32_t xp)
{
	Lore l{1, xp, 0, 0};
	for (;;) {
		const uint32_t span = 75 + 9 * static_cast<uint32_t>(l.level);
		if (xp < l.floor + span || l.level >= 500) { l.next = l.floor + span; return l; }
		l.floor += span;
		++l.level;
	}
}

uint32_t TotalXp(uint32_t account_id)
{
	auto r = database.QueryDatabase(fmt::format(
		"SELECT IFNULL(SUM(xp), 0) FROM lon_achievement WHERE account_id = {}", account_id));
	return (r.Success() && r.RowCount()) ? ToU(r.begin()[0]) : 0;
}

std::string Percent(int permille) { return fmt::format("{:.1f}", permille / 10.0); }

void PropInt(Writer &w, uint32_t key, int32_t v)
{
	w.U(key).Header(kValueData, 4, 1).U(2).U(1).I(v);
}

void PropStr(Writer &w, uint32_t key, const std::string &v)
{
	w.U(key).Header(kValueData, 4, 1).U(3).U(1).S(v);
}

// ---------------------------------------------------------------------------
// PvP record and ratings on the Profile (lon_casual_games_spec.md 9.3, checked in the client)
// ---------------------------------------------------------------------------
// winLossTable (WAUserInfoDialog 0x104C9AF0) reads 0x1055 as a map<int,int> -- ValueData type 13
// ONLY: any other type trips its assert "mTypeID == kIntIntMapTypeID" and EQ exits. A row shows when
// both its keys exist: 0x14 / 0x15 casual wins / losses ("Casual Timed Games"), 0x0A / 0x0B tournament.
// ratingsTable (0x104C79E0) reads ints: 0xFC8 Overall, 0xFC9 Constructed, 0xFCA Multiplayer, 0xFCB
// Limited, 0x1062 Sprint (a non-int shows 0). Casual Games are unrated (design decision, as live: "non-rated
// games"), so the only rating is the tournament one: Overall AND Constructed both carry it (same int
// writer as before, so nothing new reaches the client; a frozen casual number would only mislead). The
// others are not sent and show 0. lon_pvp_stats.rating_casual stays in the table, unused.
constexpr uint32_t kPropWinLoss          = 0x1055;
constexpr uint32_t kPropRatingOverall    = 0xFC8;
constexpr uint32_t kPropRatingConstructed = 0xFC9;
constexpr uint32_t kPvPPropCount         = 3;   // the keys WritePvPProps writes

struct PvPStats {
	int32_t  rating_casual = 0, rating_tournament = 0;
	uint32_t casual_wins = 0, casual_losses = 0, tourn_wins = 0, tourn_losses = 0;
};

PvPStats LoadPvPStats(uint32_t account)
{
	PvPStats st;
	st.rating_casual = st.rating_tournament = RuleI(Custom, LoNRatingStart);
	auto r = database.QueryDatabase(fmt::format(
		"SELECT rating_casual, rating_tournament, casual_wins, casual_losses, tourn_wins, tourn_losses "
		"FROM lon_pvp_stats WHERE account_id = {}", account));
	if (r.Success() && r.RowCount()) {
		auto row = r.begin();
		st.rating_casual     = row[0] ? std::atoi(row[0]) : st.rating_casual;
		st.rating_tournament = row[1] ? std::atoi(row[1]) : st.rating_tournament;
		st.casual_wins   = ToU(row[2]);
		st.casual_losses = ToU(row[3]);
		st.tourn_wins    = ToU(row[4]);
		st.tourn_losses  = ToU(row[5]);
	}
	return st;
}

// kPvPPropCount PropertySet entries.
void WritePvPProps(Writer &w, const PvPStats &st)
{
	w.U(kPropWinLoss).Header(kValueData, 4, 1).U(13).U(1)   // map<int,int>: count, then key/value pairs
		.U(4)
		.U(0x0A).U(st.tourn_wins).U(0x0B).U(st.tourn_losses)
		.U(0x14).U(st.casual_wins).U(0x15).U(st.casual_losses);
	PropInt(w, kPropRatingOverall, st.rating_tournament);
	PropInt(w, kPropRatingConstructed, st.rating_tournament);
}

// AccountCommand_IntroduceAccount v1: AccountID, AccountName, a PropertySet (MANDATORY --
// an absent one trips the client's own assert), Gender. The client merges the set key by
// key, so a resend carries only what changed. With prefs = the saved preferences too.
void SendAccount(Session &s, bool prefs)
{
	std::vector<std::vector<uint8_t>> saved;
	if (prefs) {
		auto r = database.QueryDatabase(fmt::format(
			"SELECT prop_key, HEX(value) FROM lon_account_pref WHERE account_id = {} ORDER BY prop_key", s.account_id));
		if (r.Success()) {
			for (auto row : r) {
				Writer e;
				e.U(ToU(row[0]));
				const std::vector<uint8_t> v = Unhex(row[1]);
				e.Raw(v.data(), v.size());
				saved.push_back(e.b);
			}
		}
	}
	const Lore l = LoreFor(TotalXp(s.account_id));
	const int per = RuleI(Custom, LoNBonusLootPermillePerLevel);

	Writer ia;
	ia.Header(kIntroduceAccount, 1, 2).U(s.account_id).S(s.name)
		.U(0).Header(kPropertySet, 1, 1).U(static_cast<uint32_t>(saved.size() + 6 + kPvPPropCount + (prefs ? 1 : 0)));
	for (auto &e : saved) ia.Raw(e.data(), e.size());
	if (prefs) {
		ia.U(kPropAccountFlags).Header(kValueData, 4, 1).U(7).U(1).U(1).S("RegisteredUser");
	}
	WritePvPProps(ia, LoadPvPStats(s.account_id));
	PropInt(ia, kPropLoreLevel, l.level);
	PropStr(ia, kPropLoreBonus, Percent(l.level * per));
	PropStr(ia, kPropLoreNext, Percent((l.level + 1) * per));
	PropInt(ia, kPropLoreXp, static_cast<int32_t>(l.xp));
	PropInt(ia, kPropLoreFloor, static_cast<int32_t>(l.floor));
	PropInt(ia, kPropLoreNextXp, static_cast<int32_t>(l.next));
	ia.U(0);
	Send(s, ia);
	s.lore_dirty = false;
}

// Achievement v1 (one header level): id, type (5 = a gameplay stat the client tracks),
// icon, base XP, bonus XP, completions needed, shown while incomplete, hidden, reward
// cards, ?, has reward, stat name, threshold, XP paid, completion time (0 = not yet).
void WriteAchievement(Writer &w, const AchievementDef &a, uint32_t completed_at)
{
	const bool gameplay = a.stat[0] != 0;
	w.Header(kAchievement, 1, 1)
		.I(a.id).I(gameplay ? 5 : 1).S(a.icon)
		.I(a.xp).I(0)
		.I(1).I(1).I(a.hidden ? 1 : 0)
		.U(0)
		.I(0).I(0)
		.S(a.stat).I(gameplay ? a.threshold : -1)
		.I(completed_at ? a.xp : 0).U(completed_at);
}

std::map<int, uint32_t> CompletedAchievements(uint32_t account_id)
{
	std::map<int, uint32_t> done;
	auto r = database.QueryDatabase(fmt::format(
		"SELECT achievement_id, UNIX_TIMESTAMP(completed_at) FROM lon_achievement WHERE account_id = {}", account_id));
	if (r.Success()) for (auto row : r) done[static_cast<int>(ToU(row[0]))] = ToU(row[1]);
	return done;
}

// AccountCommand_SendAchievementList v1: AccountID, then the Achievement objects. Must reach
// the client before a game starts -- that is when it picks the gameplay ones to watch.
void SendAchievementList(Session &s)
{
	const std::map<int, uint32_t> done = CompletedAchievements(s.account_id);
	Writer w;
	w.Header(kSendAchievementList, 1, 2).U(s.account_id).U(static_cast<uint32_t>(std::size(kAchievements)));
	for (const AchievementDef &a : kAchievements) {
		auto it = done.find(a.id);
		WriteAchievement(w, a, it == done.end() ? 0 : it->second);
	}
	Send(s, w);
}

// Completes one achievement (once per account). notify = tell the client now: the toast
// ("+N XP"), then the Loremaster properties (FlushLore), which pop "You are now level N".
bool Award(Session &s, int id, bool notify)
{
	const AchievementDef *a = FindAchievement(id);
	if (!a) return false;
	auto r = database.QueryDatabase(fmt::format(
		"INSERT IGNORE INTO lon_achievement (account_id, achievement_id, xp) VALUES ({}, {}, {})",
		s.account_id, id, a->xp));
	if (!r.Success() || r.RowsAffected() != 1) return false;
	LogInfo("[LoN] [{}] achievement [{}] (+[{}] XP)", s.name, id, a->xp);
	if (notify) {
		Writer w;
		w.Header(kNotifyAchievement, 1, 2).U(s.account_id).U(0);
		WriteAchievement(w, *a, static_cast<uint32_t>(time(nullptr)));
		Send(s, w);
		s.lore_dirty = true;
	}
	return true;
}

void FlushLore(Session &s)
{
	if (s.lore_dirty) SendAccount(s, false);
}

// Everything the server can see in its own tables. Run at login (notify = false: this is
// live's back-grant of earlier progress) and after every pack, scenario, deck and tutorial.
void CheckProgress(Session &s, bool notify)
{
	const std::map<int, uint32_t> done = CompletedAchievements(s.account_id);
	auto need = [&](int id) { return done.find(id) == done.end(); };
	auto exists = [&](const std::string &sql) {
		auto r = database.QueryDatabase(sql);
		return r.Success() && r.RowCount() > 0 && ToU(r.begin()[0]) > 0;
	};
	const uint32_t acct = s.account_id;

	// Packs: a card that came out of a booster / a starter deck.
	if (need(3) && exists(fmt::format("SELECT COUNT(*) FROM lon_card WHERE account_id = {} AND source LIKE 'pack:%'", acct))) Award(s, 3, notify);
	if (need(4) && exists(fmt::format("SELECT COUNT(*) FROM lon_card WHERE account_id = {} AND source LIKE 'starter:%'", acct))) Award(s, 4, notify);
	if (need(2) || need(56)) {
		auto r = database.QueryDatabase(fmt::format(
			"SELECT DISTINCT archetype FROM lon_card WHERE account_id = {} AND source LIKE 'pack:%'", acct));
		bool ur = false, loot = false;
		if (r.Success()) {
			for (auto row : r) {
				auto it = g_data.cards.find(ToU(row[0]));
				if (it == g_data.cards.end()) continue;
				ur   = ur || it->second.rarity == kUltraRare;
				loot = loot || it->second.subtype == "EverQuest Loot Card";
			}
		}
		if (ur && need(2)) Award(s, 2, notify);
		if (loot && need(56)) Award(s, 56, notify);
	}

	// Scenarios: every paid win is a lon_reward_claim row per difficulty up to the one won.
	{
		auto r = database.QueryDatabase(fmt::format(
			"SELECT MAX(difficulty) FROM lon_reward_claim WHERE account_id = {} AND difficulty >= 1 AND script NOT LIKE 'campaign:%'", acct));
		const int best = (r.Success() && r.RowCount() && r.begin()[0]) ? std::atoi(r.begin()[0]) : 0;
		if (best >= 1 && need(8)) Award(s, 8, notify);
		if (best >= 2 && need(7)) Award(s, 7, notify);
		if (best >= 3 && need(6)) Award(s, 6, notify);
		auto v = database.QueryDatabase(fmt::format(
			"SELECT DISTINCT variant FROM lon_reward_claim WHERE account_id = {} AND difficulty >= 1 AND script NOT LIKE 'campaign:%'", acct));
		if (v.Success()) {
			for (auto row : v) {
				const int id = ScenarioArchetypeAchievement(std::atoi(row[0] ? row[0] : "0"));
				if (id >= 0 && need(id)) Award(s, id, notify);
			}
		}
	}
	for (const auto &g : kCampaignGroups) {
		if (!need(g.first)) continue;
		std::string list;
		size_t total = 0;
		for (int cid : g.second) {
			auto it = g_data.campaign_scripts.find(cid);
			if (it == g_data.campaign_scripts.end()) continue;
			for (const std::string &sc : it->second) {
				if (!list.empty()) list += ",";
				list += "'" + Strings::Escape(sc) + "'";
				++total;
			}
		}
		if (!total) continue;
		auto c = database.QueryDatabase(fmt::format(
			"SELECT COUNT(DISTINCT script) FROM lon_reward_claim WHERE account_id = {} AND difficulty >= 1 AND script IN ({})", acct, list));
		if (c.Success() && c.RowCount() && ToU(c.begin()[0]) >= total) Award(s, g.first, notify);
	}

	// Tutorials: eleven different ones won.
	if (need(55)) {
		auto c = database.QueryDatabase(fmt::format(
			"SELECT COUNT(DISTINCT script) FROM lon_game WHERE account_id = {} AND game_type = 1 AND result = 1", acct));
		if (c.Success() && c.RowCount() && ToU(c.begin()[0]) >= 11) Award(s, 55, notify);
	}

	// Decks: one saved per archetype, then all five.
	{
		std::set<int> have;
		auto d = database.QueryDatabase(fmt::format("SELECT DISTINCT archetype FROM lon_deck WHERE account_id = {}", acct));
		if (d.Success()) {
			for (auto row : d) {
				const int id = DeckArchetypeAchievement(std::atoi(row[0] ? row[0] : "0"));
				if (id < 0) continue;
				have.insert(id);
				if (need(id)) Award(s, id, notify);
			}
		}
		if (have.size() == 5 && need(64)) Award(s, 64, notify);
	}

	// Custom avatars: one per hero type, then all four (Generic has no avatar achievement).
	{
		std::set<int> have;
		auto a = database.QueryDatabase(fmt::format(
			"SELECT HEX(`blob`) FROM lon_custom_avatar WHERE account_id = {} AND `blob` IS NOT NULL", acct));
		if (a.Success()) {
			for (auto row : a) {
				const int id = AvatarHeroAchievement(AvatarHeroType(Unhex(row[0])));
				if (id < 0) continue;
				have.insert(id);
				if (need(id)) Award(s, id, notify);
			}
		}
		if (have.size() == 4 && need(69)) Award(s, 69, notify);
	}

	// Posted trades: posted one; completed one as the buyer (accepted) or the seller (posted it).
	if (need(84) && exists(fmt::format("SELECT COUNT(*) FROM lon_posted_trade WHERE account_id = {}", acct))) Award(s, 84, notify);
	if (need(82) && exists(fmt::format("SELECT COUNT(*) FROM lon_posted_trade WHERE accepted_by = {} AND state = 1", acct))) Award(s, 82, notify);
	if (need(83) && exists(fmt::format("SELECT COUNT(*) FROM lon_posted_trade WHERE account_id = {} AND state = 1", acct))) Award(s, 83, notify);
	FlushLore(s);
}

// AccountCommand_RequestGameplayAchievement v1: AccountID, stat name, the stat's value. The
// client sends it whenever a watched stat reaches a threshold of an achievement it still
// lists as open -- repeatedly, so the INSERT IGNORE in Award is the dedupe.
void HandleGameplayAchievement(Session &s, Reader &r)
{
	r.U();
	const std::string stat = r.S();
	const int32_t value = r.I();
	if (r.bad) return;
	// Only during a game the client reported starting (the stats are single-player ones).
	auto g = database.QueryDatabase(fmt::format(
		"SELECT COUNT(*) FROM lon_game WHERE account_id = {} AND began_at > NOW() - INTERVAL 6 HOUR", s.account_id));
	if (!g.Success() || g.RowCount() == 0 || ToU(g.begin()[0]) == 0) {
		LogInfo("[LoN] [{}] gameplay achievement [{}]={} with no game in progress -- ignored", s.name, stat, value);
		return;
	}
	if (stat == "VictoryType") {
		// Loss types (LoN 0x10269AC0): 0x11175 avatar killed, 0x11177 the winner's quest or
		// script win; 0x11176 out of cards, 1 concede, 2 timeout, 4 sub-game concede pay nothing.
		constexpr int32_t kLossAvatarKilled = 0x11175;
		constexpr int32_t kLossQuestWin     = 0x11177;
		LogInfo("[LoN] [{}] win, VictoryType [{:#x}]", s.name, value);
		if (value == kLossAvatarKilled) Award(s, 75, true);
		else if (value == kLossQuestWin) Award(s, 76, true);
		FlushLore(s);
		return;
	}
	for (const AchievementDef &a : kAchievements) {
		if (stat == a.stat && value >= a.threshold) Award(s, a.id, true);
	}
	FlushLore(s);
}

// Skips one ValueData value of a type the preference sets use; false = a type we do not store.
bool SkipValue(Reader &r, uint32_t type)
{
	switch (type) {
		case 1: case 2: r.U(); break;
		case 3: r.S(); break;
		case 6: { const uint32_t n = r.U(); for (uint32_t i = 0; i < n && !r.bad && i < 4096; ++i) r.U(); break; }
		case 7: { const uint32_t n = r.U(); for (uint32_t i = 0; i < n && !r.bad && i < 4096; ++i) r.S(); break; }
		case 13: { const uint32_t n = r.U(); for (uint32_t i = 0; i < n && !r.bad && i < 4096; ++i) { r.U(); r.U(); } break; }
		default: return false;
	}
	return !r.bad;
}

// AccountCommand_SetPreferences v1: AccountID, a nullable PropertySet. Every key is kept as
// its raw ValueData and sent back in IntroduceAccount at the next login.
void HandleSetPreferences(Session &s, Reader &r)
{
	r.U();
	if (r.U() != 0) return;   // no set
	r.U(); r.U();             // PropertySet header
	const uint32_t count = r.U();
	int stored = 0;
	for (uint32_t i = 0; i < count && !r.bad && i < 256; ++i) {
		const uint32_t key = r.U();
		const size_t start = r.p;
		r.U(); r.U();
		const uint32_t type = r.U();
		r.U();
		if (!SkipValue(r, type)) {
			LogInfo("[LoN] [{}] preference [{:#x}] has value type [{}] -- not stored, rest of the set skipped", s.name, key, type);
			return;
		}
		if ((key >= kPropLoreLevel && key <= kPropLoreNextXp) || key == kPropAccountFlags || key == kPropWinLoss ||
			key == kPropRatingOverall || key == kPropRatingConstructed) continue;   // ours, not the client's
		const std::vector<uint8_t> v(r.d + start, r.d + r.p);
		if (v.size() > 4096) continue;
		database.QueryDatabase(fmt::format(
			"REPLACE INTO lon_account_pref (account_id, prop_key, value) VALUES ({}, {}, UNHEX('{}'))",
			s.account_id, key, Hex(v)));
		++stored;
	}
	LogInfo("[LoN] [{}] saved [{}] preference(s)", s.name, stored);
}

// New account: one random first-set starter deck. Every account: the monthly packs, and
// anything bought elsewhere that is still waiting.
void GrantOnLogin(Session &s)
{
	database.QueryDatabase(fmt::format("INSERT IGNORE INTO lon_account (account_id) VALUES ({})", s.account_id));
	auto r = database.QueryDatabase(fmt::format(
		"SELECT starter_granted, last_monthly FROM lon_account WHERE account_id = {}", s.account_id));
	if (!r.Success() || r.RowCount() == 0) return;
	auto row = r.begin();
	const bool starter = ToU(row[0]) != 0;
	const uint32_t last_monthly = ToU(row[1]);

	if (!starter && !g_data.first_starters.empty()) {
		const uint32_t product = Pick(g_data.first_starters);
		GiveCards(s.account_id, {product}, "gift:starter");
		database.QueryDatabase(fmt::format("UPDATE lon_account SET starter_granted = 1 WHERE account_id = {}", s.account_id));
		LogInfo("[LoN] [{}] new card player -- starter deck [{}]", s.name, product);
	}

	const time_t now = time(nullptr);
	struct tm tmv{};
#ifdef _WIN32
	localtime_s(&tmv, &now);
#else
	localtime_r(&now, &tmv);
#endif
	const uint32_t ym = static_cast<uint32_t>((tmv.tm_year + 1900) * 100 + tmv.tm_mon + 1);
	const int monthly = RuleI(Custom, LoNMonthlyPacks);
	if (monthly > 0 && last_monthly != ym && !g_data.choose_a_pack.empty()) {
		std::vector<uint32_t> packs(static_cast<size_t>(monthly), *g_data.choose_a_pack.begin());
		GiveCards(s.account_id, packs, "gift:monthly");
		database.QueryDatabase(fmt::format("UPDATE lon_account SET last_monthly = {} WHERE account_id = {}", ym, s.account_id));
		LogInfo("[LoN] [{}] monthly gift: [{}] Choose a Pack", s.name, monthly);
	}

	auto d = database.QueryDatabase(fmt::format(
		"SELECT id, archetype, quantity, source FROM lon_delivery WHERE account_id = {} AND delivered_at IS NULL", s.account_id));
	if (d.Success()) {
		for (auto dr : d) {
			std::vector<uint32_t> v(ToU(dr[2]), ToU(dr[1]));
			GiveCards(s.account_id, v, std::string("bought:") + (dr[3] ? dr[3] : ""));
			database.QueryDatabase(fmt::format("UPDATE lon_delivery SET delivered_at = NOW() WHERE id = {}", ToU(dr[0])));
		}
	}
}

// ---------------------------------------------------------------------------
// One card game per PC (Custom:LoNActiveLooterOnly)
// ---------------------------------------------------------------------------
// Return true if this character is allowed to use the card game on its PC (e.g. your active-looter system). Default: allow.
bool IsActiveLooter(uint32_t character_id)
{
	if (!RuleB(Custom, LoNActiveLooterOnly)) return true;
	(void) character_id;
	return true;
}

void TellCharacter(const Session &s, const std::string &text)
{
	if (s.name.empty() || s.name.rfind("Account", 0) == 0) return;
	ZSList::Instance()->SendEmoteMessageRaw(s.name.c_str(), 0, 0, Chat::Red, text.c_str());
}

void SendCustomAvatars(Session &s);   // custom avatars section, below
void SendLobbyGroups(Session &s);     // Trade Lobby section, below
void LeaveLobby(Session &s);

void LoginReply(Session &s, bool ok, uint32_t explanation)
{
	// LoginCommand_Results v6: Succeeded, Explanation, AccountID, UseExplanation, ServerID,
	// SessionID, then a zlib block holding the empty account-restrictions vector.
	static const uint8_t kEmptyVectorZ[] = {0x78, 0x9C, 0x63, 0x00, 0x00, 0x00, 0x01, 0x00, 0x01};
	Writer w;
	w.Header(kLoginResults, 6, 3)
		.U(ok ? 1 : 0).U(explanation).U(ok ? s.account_id : 0).U(ok ? 0 : 1).U(1)
		.S(ok ? "NMS" : "")
		.U(1).U(sizeof(kEmptyVectorZ)).Raw(kEmptyVectorZ, sizeof(kEmptyVectorZ));
	Send(s, w);
}

// ---------------------------------------------------------------------------
// Home screen panels (research/lon_home_screen_and_links.md 2)
// ---------------------------------------------------------------------------
// The home screen (WAMapScreen) fills Message of the Day, Getting Started and Leaderboards ONLY from
// these three messages. Crash rules from the client's read/execute code:
// - News 0x1C9 and LeaderBoardData 0x1CA are ONE header level; their execute indexes the second and
//   third lists by the first list's count with no bounds check (_invalid_parameter_noinfo = EQ dies),
//   so every list of a group is built in one loop and is always the same length. Empty lists are safe
//   (each loop is guarded on the vector's begin pointer).
// - LeaderBoardData's wire order is group B (ids, names, ratings) then group A; the box shows group A
//   only, so group B is sent empty. Names are plain text there (setText); the rating is QString::number.
// - News titles and bodies, and the MOTD, are inserted as HTML, so text world did not write is escaped.
// - DisplayMOTD is THREE header levels (leaf, LoginCommand, NetworkCommand), then S, U(key), U, S(text).
//   On the home screen key 1 fills the box; on any other screen (the login screen, right after
//   LoginReply) the client ALSO pops up a small MOTD dialog -- the home box reads the stored key 1
//   when it is built.
constexpr uint32_t kHomeBoardRows = 10;
constexpr size_t   kHomeNewsMax   = 20;

std::string HtmlEscape(const std::string &in)
{
	std::string out;
	out.reserve(in.size());
	for (char c : in) {
		switch (c) {
			case '&':  out += "&amp;";  break;
			case '<':  out += "&lt;";   break;
			case '>':  out += "&gt;";   break;
			case '"':  out += "&quot;"; break;
			case '\r': break;
			case '\n': out += "<br>";   break;
			default:   out += c;        break;
		}
	}
	return out;
}

void SendMotd(Session &s)
{
	// A second login of an account that already has a card game connection gets no MOTD: off the home
	// screen it would pop up a dialog again.
	for (auto &kv : g_sessions) {
		if (kv.second.get() != &s && kv.second->account_id == s.account_id) return;
	}
	std::string text = RuleS(Custom, LoNMOTD);
	if (text.size() > 2000) text.resize(2000);
	if (text.empty()) return;
	Writer w;
	w.Header(kDisplayMOTD, 1, 3).S("").U(1).U(0).S(HtmlEscape(text));
	Send(s, w);
}

void SendHomeNews(Session &s)
{
	std::vector<std::string> titles, bodies;
	std::vector<uint32_t>    keys;
	auto r = database.QueryDatabase(fmt::format(
		"SELECT `title`, `body`, `sort_key` FROM `lon_news` WHERE `enabled` = 1 ORDER BY `sort_key` DESC, `id` LIMIT {}",
		kHomeNewsMax));
	if (r.Success()) {
		for (auto row : r) {
			std::string title = row[0] ? row[0] : "";
			std::string body  = row[1] ? row[1] : "";
			if (title.size() > 200)  title.resize(200);
			if (body.size() > 2000)  body.resize(2000);
			titles.push_back(HtmlEscape(title));
			bodies.push_back(HtmlEscape(body));
			keys.push_back(row[2] ? ToU(row[2]) : 0);
		}
	}
	const uint32_t n = static_cast<uint32_t>(titles.size());   // all three lists: exactly n
	Writer w;
	w.Header(kHomeNews, 1, 1);
	w.U(n);
	for (const auto &t : titles) w.S(t);
	w.U(n);
	for (const auto &b : bodies) w.S(b);
	w.U(n);
	for (uint32_t k : keys) w.U(k);
	Send(s, w);
}

struct HomeBoardRow {
	uint32_t    account = 0;
	std::string name;
	int32_t     rating = 0;
	bool operator==(const HomeBoardRow &o) const { return account == o.account && name == o.name && rating == o.rating; }
};

// The tournament rating: the only rating there is (Casual Games are unrated). "ranked" counts rated
// tournament games and opponents (RefreshRanked).
std::vector<HomeBoardRow> LoadHomeBoard()
{
	std::vector<HomeBoardRow> rows;
	auto r = database.QueryDatabase(fmt::format(
		"SELECT `account_id`, `char_name`, `rating_tournament` FROM `lon_pvp_stats` WHERE `ranked` = 1 AND `hidden` = 0 "
		"ORDER BY `rating_tournament` DESC, `games` DESC, `account_id` LIMIT {}", kHomeBoardRows));
	if (!r.Success()) return rows;
	for (auto row : r) {
		HomeBoardRow b;
		b.account = row[0] ? ToU(row[0]) : 0;
		b.name    = row[1] ? row[1] : "";
		if (b.name.size() > 64) b.name.resize(64);
		b.rating  = row[2] ? static_cast<int32_t>(std::atoi(row[2])) : 0;
		rows.push_back(b);
	}
	return rows;
}

void SendHomeBoard(Session &s, const std::vector<HomeBoardRow> &rows)
{
	const uint32_t n = static_cast<uint32_t>(rows.size());   // all three group A lists: exactly n
	Writer w;
	w.Header(kLeaderBoardData, 1, 1);
	w.U(0).U(0).U(0);                                         // group B (never shown): empty
	w.U(n);
	for (const auto &b : rows) w.U(b.account);
	w.U(n);
	for (const auto &b : rows) w.S(b.name);
	w.U(n);
	for (const auto &b : rows) w.I(b.rating);
	Send(s, w);
}

// The board as last sent. When it changes (a rated result, a GM's hidden flag, a newly ranked player)
// every logged-in card game gets the new one; event 0xAE redraws an open home screen live.
std::vector<HomeBoardRow> g_home_board;
bool                      g_home_board_loaded = false;

void RefreshHomeBoard(Session *joining)
{
	std::vector<HomeBoardRow> rows = LoadHomeBoard();
	if (!g_home_board_loaded || !(rows == g_home_board)) {
		const bool first = !g_home_board_loaded;
		g_home_board        = rows;
		g_home_board_loaded = true;
		if (!first) {
			for (auto &kv : g_sessions) {
				if (kv.second->account_id && kv.second.get() != joining) SendHomeBoard(*kv.second, g_home_board);
			}
		}
	}
	if (joining) SendHomeBoard(*joining, g_home_board);
}

void HandleLogin(Session &s, const std::string &token)
{
	auto r = database.QueryDatabase(fmt::format(
		"SELECT s.account_id, s.character_id, IFNULL(c.name, '') FROM lon_session s "
		"LEFT JOIN character_data c ON c.id = s.character_id "
		"WHERE s.token = '{}' AND s.expires_at > NOW()", Strings::Escape(token)));
	if (!r.Success() || r.RowCount() == 0) {
		LogInfo("[LoN] refused a login from [{}] -- unknown or expired session", s.conn ? s.conn->RemoteIP() : "?");
		LoginReply(s, false, kErrSessionInvalid);
		return;
	}
	auto row = r.begin();
	s.account_id   = ToU(row[0]);
	s.character_id = ToU(row[1]);
	s.name         = row[2] ? row[2] : "";
	if (s.name.empty()) s.name = fmt::format("Account{}", s.account_id);
	s.synced = false;
	s.ip     = s.conn ? s.conn->RemoteIP() : "";

	if (!IsActiveLooter(s.character_id)) {
		LogInfo("[LoN] refused [{}] -- IsActiveLooter() said no", s.name);
		TellCharacter(s, "Only your computer's active looter can play Legends of Norrath. "
			"Make this character your active looter, then open the card game again.");
		s.account_id = 0;
		LoginReply(s, false, kErrLoginCanceled);
		return;
	}

	GrantOnLogin(s);
	CheckProgress(s, false);   // live's back-grant: progress made before Loremaster existed
	LoginReply(s, true, 0);
	SendAccount(s, true);
	SendAchievementList(s);
	SendCustomAvatars(s);   // before the collection, so the avatar copies and decks resolve
	SendLobbyGroups(s);     // the Trade Lobby and Casual Games exist and have room
	SendHomeNews(s);        // the home screen: Getting Started, Leaderboards, Message of the Day
	RefreshHomeBoard(&s);
	SendMotd(s);

	auto c = database.QueryDatabase(fmt::format(
		"SELECT COUNT(DISTINCT archetype) FROM lon_card WHERE account_id = {}", s.account_id));
	const uint32_t archetypes = (c.Success() && c.RowCount()) ? ToU(c.begin()[0]) : 0;
	Writer st;
	st.Header(kSyncStart, 3, 3).U(s.account_id).U(0).U(archetypes).U(0);
	Send(s, st);
	LogInfo("[LoN] [{}] (account [{}]) logged in to the card game", s.name, s.account_id);
}

void HandleBulkFulfillment(Session &s, Reader &r)
{
	std::vector<Inst> products;
	const uint32_t n = r.U();
	for (uint32_t i = 0; i < n && !r.bad && i < 100; ++i) {
		r.U(); r.U();
		Inst p{r.U(), r.U(), r.U()};
		products.push_back(p);
	}
	if (r.bad) return;

	std::vector<Inst> removed, added;
	bool starter = false, bonus = false;
	const int bonus_permille = LoreFor(TotalXp(s.account_id)).level * RuleI(Custom, LoNBonusLootPermillePerLevel);
	for (const Inst &p : products) {
		std::vector<uint32_t> contents = OpenProduct(p.arch);
		if (contents.empty() || !TakeCards(s.account_id, {p})) {
			LogInfo("[LoN] [{}] cannot open [{}] (not a product, or not theirs)", s.name, p.arch);
			continue;
		}
		// Loremaster bonus loot (live): a booster can hold one extra card, a Loremaster loot card.
		if (IsBooster(p.arch) && !g_data.loremaster.empty() && bonus_permille > 0 && g_rng.Int(1, 1000) <= bonus_permille) {
			const uint32_t card = Pick(g_data.loremaster);
			contents.push_back(card);
			bonus = true;
			LogInfo("[LoN] [{}] Loremaster bonus loot card [{}] in booster [{}]", s.name, card, p.arch);
		}
		const bool is_starter = g_data.product_cards.count(p.arch) != 0;
		starter = starter || is_starter;
		std::vector<Inst> got = GiveCards(s.account_id, contents,
			fmt::format("{}:{}", is_starter ? "starter" : "pack", p.arch));
		removed.push_back(p);
		added.insert(added.end(), got.begin(), got.end());
	}
	if (removed.empty()) return;
	Deliver(s, removed, added);
	if (starter) SendDecks(s);
	LogInfo("[LoN] [{}] opened [{}] product(s) -> [{}] cards", s.name, removed.size(), added.size());
	if (bonus) Award(s, 0, true);
	CheckProgress(s, true);
}

// Writes an EverQuest item to the character's parcels (from "Legends of Norrath").
bool SendParcel(uint32_t character_id, uint32_t item_id, const std::string &card_name)
{
	auto r = database.QueryDatabase(fmt::format(
		"SELECT IFNULL(MAX(slot_id), 0) FROM character_parcels WHERE char_id = {}", character_id));
	const uint32_t slot = (r.Success() && r.RowCount()) ? ToU(r.begin()[0]) + 1 : 1;
	auto w = database.QueryDatabase(fmt::format(
		"INSERT INTO character_parcels (char_id, item_id, slot_id, quantity, from_name, note, sent_date) "
		"VALUES ({}, {}, {}, 1, 'Legends of Norrath', '{}', NOW())",
		character_id, item_id, slot, Strings::Escape(fmt::format("Your loot card: {}", card_name))));
	return w.Success();
}

void HandleRedeem(Session &s, Reader &r, uint32_t version)
{
	// ECommCommand_RedeemItemGrant v3 (research/eqlib_LoN/LoN_README.md 9.4): AccountID, ArchetypeID, PropertySet,
	// Response, ErrorCode, IsConversion, Alternate (v2), TradableState (v3).
	r.U();
	const uint32_t grant = r.U();
	const size_t props_start = r.p;
	uint32_t qty = 1;
	if (r.U() == 0) {
		r.U(); r.U();
		const uint32_t count = r.U();
		for (uint32_t i = 0; i < count && !r.bad; ++i) {
			const uint32_t key = r.U();
			r.U(); r.U();
			const uint32_t type = r.U();
			r.U();
			if (type == 3) {
				const std::string v = r.S();
				if (key == kPropQuantity) qty = std::max(1, std::atoi(v.c_str()));
			}
			else if (type == 2 || type == 1) {
				const uint32_t v = r.U();
				if (key == kPropQuantity && v) qty = v;
			}
			else {
				r.bad = true;
			}
		}
	}
	const std::vector<uint8_t> props(r.d + props_start, r.d + r.p);
	r.U(); r.U(); r.U();
	const uint32_t alternate = version > 1 ? r.U() : 0;
	const int32_t  tradable  = version > 2 ? r.I() : -1;
	if (r.bad) return;
	qty = std::min<uint32_t>(qty, 50);

	auto answer = [&](bool ok, uint32_t err) {
		Writer w;
		w.Header(kRedeemItemGrant, 3, 2).U(s.account_id).U(grant);
		w.Raw(props.data(), props.size());
		w.U(ok ? 1 : 0).U(err).U(0).U(alternate).I(tradable);
		Send(s, w);
	};

	const std::string card_name = g_data.cards.count(grant) ? g_data.cards[grant].name : std::to_string(grant);

	if (g_data.choose_a_pack.count(grant)) {
		if (!IsBooster(alternate) && !g_data.product_cards.count(alternate)) { answer(false, kErrNoChoice); return; }
		std::vector<Inst> cards = CopiesOf(s.account_id, grant, qty);
		if (cards.size() < qty || !TakeCards(s.account_id, cards)) { answer(false, kErrNotOwned); return; }
		std::vector<Inst> added = GiveCards(s.account_id, std::vector<uint32_t>(qty, alternate), "redeem:choose");
		answer(true, 0);
		Deliver(s, cards, added);
		LogInfo("[LoN] [{}] redeemed [{}] x[{}] for product [{}]", s.name, card_name, qty, alternate);
		return;
	}

	auto li = database.QueryDatabase(fmt::format("SELECT item_id FROM lon_loot_item WHERE card_archetype = {}", grant));
	if (!li.Success() || li.RowCount() == 0) {
		LogInfo("[LoN] [{}] tried to redeem [{}] ([{}]) -- no EverQuest item mapped", s.name, card_name, grant);
		answer(false, kErrNotAvailable);
		return;
	}
	const uint32_t item_id = ToU(li.begin()[0]);
	std::vector<Inst> one = CopiesOf(s.account_id, grant, 1);
	if (one.empty() || !TakeCards(s.account_id, one)) { answer(false, kErrNotOwned); return; }
	// The item goes to the account's /claim list (account-wide, so the player
	// picks the character): template 5000000 + item id (manifest v435). An item with no template
	// falls back to a parcel for the character that opened the card game.
	const uint32_t claim = kLootClaimBase + item_id;
	auto t = database.QueryDatabase(fmt::format(
		"SELECT COUNT(*) FROM veteran_reward_templates WHERE claim_id = {} AND item_id = {}", claim, item_id));
	const bool has_template = t.Success() && t.RowCount() && ToU(t.begin()[0]) > 0;
	bool ok = false;
	if (has_template) {
		auto w = database.QueryDatabase(fmt::format(
			"INSERT INTO account_rewards (account_id, reward_id, amount) VALUES ({}, {}, 1) "
			"ON DUPLICATE KEY UPDATE amount = amount + 1", s.account_id, claim));
		ok = w.Success();
	}
	else if (s.character_id) {
		ok = SendParcel(s.character_id, item_id, card_name);
	}
	if (!ok) {
		GiveCards(s.account_id, {grant}, "refund:claim-failed");
		answer(false, kErrRedeemUnknown);
		return;
	}
	database.QueryDatabase(fmt::format(
		"INSERT INTO lon_loot_redemption (account_id, character_id, card_archetype, item_id) VALUES ({}, {}, {}, {})",
		s.account_id, s.character_id, grant, item_id));
	answer(true, 0);
	Send(s, RemoveInstances(one));
	LogInfo("[LoN] [{}] redeemed loot card [{}] -> item [{}] ({})", s.name, card_name, item_id, has_template ? "/claim" : "parcel");
}

// ---------------------------------------------------------------------------
// Posted trades (research/lon_posted_trades.md)
// ---------------------------------------------------------------------------
// The client only builds, sends and displays; the server owns every trade. Offered copies are held
// (escrow) while the trade is open: their lon_card rows move to account 0 with a
// lon_posted_trade_escrow row naming the poster, so nothing else -- opening, redeeming a loot card,
// another trade -- can touch them. Accepting swaps both sides in one guarded transaction; a trade is
// claimed first with a conditional UPDATE (state 0 -> 4), so it can be accepted only once.
// Live's limits: 20 public posts per account (client + server); 50 cards per side (our cap, live's
// live-trade cap). Expiry: Custom:LoNPostedTradeDays. Guild-only trades are not offered (the client
// tests guild membership itself and we have no card-game guilds), so the guild lookup answers none.
constexpr uint32_t kMaxPublicPosts   = 20;
constexpr uint32_t kMaxPosts         = 50;   // all open posts, targeted ones included
constexpr uint32_t kMaxCardsPerSide  = 50;
enum : int { kTradeOpen = 0, kTradeCompleted = 1, kTradeCancelled = 2, kTradeExpired = 3, kTradeAccepting = 4 };
// PostedTradeError codes (fixed client texts). From the Post Trade builder:
constexpr uint32_t kPtErrTooManyCards = 6, kPtErrRecipient = 0x0D, kPtErrMaxPosts = 0x0E;
// From the trade detail window:
constexpr uint32_t kPtErrBeingCompleted = 1, kPtErrCompleted = 3, kPtErrWrongAccount = 4,
	kPtErrPosterShort = 7, kPtErrYouShort = 8, kPtErrLock = 0x0B;

struct PostedTrade {
	uint32_t id = 0, account = 0, recipient = 0, posted = 0;
	int state = kTradeOpen;
	std::string poster, recipient_name;
	std::map<uint32_t, uint32_t> offered, wanted;
};

bool KnownArchetype(uint32_t a)
{
	return g_data.cards.count(a) || g_data.product_cards.count(a) || IsBooster(a);
}

bool CanSee(const PostedTrade &t, uint32_t account)
{
	return t.recipient == 0 || t.recipient == account || t.account == account;
}

std::string IdList(const std::vector<Inst> &v)
{
	std::string s;
	for (const Inst &i : v) { if (!s.empty()) s += ","; s += std::to_string(i.number); }
	return s;
}

// Trades by a WHERE clause on lon_posted_trade, with their card lines.
std::vector<PostedTrade> LoadTrades(const std::string &where)
{
	std::vector<PostedTrade> out;
	auto r = database.QueryDatabase(fmt::format(
		"SELECT id, account_id, poster_name, recipient_account_id, recipient_name, UNIX_TIMESTAMP(created_at), state "
		"FROM lon_posted_trade WHERE {} ORDER BY id", where));
	if (!r.Success() || r.RowCount() == 0) return out;
	std::map<uint32_t, size_t> at;
	std::string ids;
	for (auto row : r) {
		PostedTrade t;
		t.id = ToU(row[0]); t.account = ToU(row[1]); t.poster = row[2] ? row[2] : "";
		t.recipient = ToU(row[3]); t.recipient_name = row[4] ? row[4] : "";
		t.posted = ToU(row[5]); t.state = static_cast<int>(ToU(row[6]));
		at[t.id] = out.size();
		if (!ids.empty()) ids += ",";
		ids += std::to_string(t.id);
		out.push_back(t);
	}
	auto l = database.QueryDatabase(fmt::format(
		"SELECT trade_id, side, archetype, quantity FROM lon_posted_trade_line WHERE trade_id IN ({})", ids));
	if (l.Success()) {
		for (auto row : l) {
			auto it = at.find(ToU(row[0]));
			if (it == at.end()) continue;
			PostedTrade &t = out[it->second];
			(ToU(row[1]) == 0 ? t.offered : t.wanted)[ToU(row[2])] = ToU(row[3]);
		}
	}
	return out;
}

Writer TradeCmd(uint32_t op, uint32_t ver, uint32_t account)
{
	Writer w;
	w.Header(op, ver, 3).U(account).U(0);   // TradeCommand: AccountID, TradeSessionID
	return w;
}

// PostedTrade v3 as a nullable object.
void WritePostedTrade(Writer &w, const PostedTrade &t)
{
	w.U(0).Header(kPostedTrade, 3, 1).U(t.id).U(t.account).S(t.poster).U(t.posted);
	for (const auto *m : {&t.offered, &t.wanted}) {
		w.U(static_cast<uint32_t>(m->size()));
		for (const auto &kv : *m) w.U(kv.first).U(kv.second);
	}
	w.U(t.recipient).S(t.recipient_name)   // recipient account, its name (#2)
		.U(0).S("")                          // guild id, guild name: no guild-only trades
		.S(t.poster).S(t.recipient_name)     // v2: the poster's display name, recipient name (#1)
		.U(0);                               // v3: archetypes to add to the client's DB -- none
}

void SendTradeError(Session &s, uint32_t code, bool from_add)
{
	Send(s, TradeCmd(kPostedTradeError, 1, s.account_id).U(code).U(from_add ? 1 : 0));
}

void SendTradeGone(Session &s, uint32_t id)
{
	Send(s, TradeCmd(kCancelPostedTrade, 1, s.account_id).U(id));
}

// Cards changing hands because of posted trade `id` (the Delivery window says "Posted trade: id").
void DeliverTrade(Session &s, const std::vector<Inst> &removed, const std::vector<Inst> &added, uint32_t id)
{
	if (!removed.empty()) Send(s, RemoveInstances(removed));
	if (added.empty()) return;
	const uint32_t d = ++s.delivery;
	Send(s, StartDelivery(d, added, false, "trade", -static_cast<int32_t>(id)));
	Send(s, Complete(d));
}

// Tells every logged-in card game that can see trade t that it is gone, except `skip`.
void BroadcastTradeGone(const PostedTrade &t, uint32_t skip_account)
{
	for (auto &kv : g_sessions) {
		Session &o = *kv.second;
		if (!o.account_id || !o.synced || o.account_id == skip_account || !CanSee(t, o.account_id)) continue;
		SendTradeGone(o, t.id);
	}
}

// Up to `want` tradable copies of an archetype, locked for the current transaction.
std::vector<Inst> TradableCopies(uint32_t account, uint32_t arch, uint32_t want)
{
	std::vector<Inst> out;
	std::string locked;
	for (uint32_t id : g_card_lock) { locked += locked.empty() ? " AND id NOT IN (" : ","; locked += std::to_string(id); }
	if (!locked.empty()) locked += ")";
	auto r = database.QueryDatabase(fmt::format(
		"SELECT id, series FROM lon_card WHERE account_id = {} AND archetype = {} AND tradable = 1{} "
		"ORDER BY id LIMIT {} FOR UPDATE", account, arch, locked, want));
	if (r.Success()) for (auto row : r) out.push_back({arch, ToU(row[1]), ToU(row[0])});
	return out;
}

// The escrowed copies of a trade, as instances (and their owner before the trade).
std::vector<Inst> EscrowOf(uint32_t id)
{
	std::vector<Inst> out;
	auto r = database.QueryDatabase(fmt::format(
		"SELECT c.id, c.archetype, c.series FROM lon_posted_trade_escrow e JOIN lon_card c ON c.id = e.card_id "
		"WHERE e.trade_id = {} AND c.account_id = 0 ORDER BY c.id", id));
	if (r.Success()) for (auto row : r) out.push_back({ToU(row[1]), ToU(row[2]), ToU(row[0])});
	return out;
}

void HandleSetListenStatus(Session &s, Reader &r)
{
	r.U(); r.U();
	const bool on = r.U() != 0;
	if (!r.bad) s.trade_listen = on;
}

void HandleRequestPostedTrades(Session &s)
{
	std::vector<PostedTrade> all = LoadTrades(fmt::format("state = {}", static_cast<int>(kTradeOpen)));
	std::vector<const PostedTrade *> mine;
	for (const PostedTrade &t : all) if (CanSee(t, s.account_id)) mine.push_back(&t);

	Send(s, TradeCmd(kStartPostedTrades, 1, s.account_id).U(static_cast<uint32_t>(mine.size())));
	for (const PostedTrade *t : mine) {
		Writer w = TradeCmd(kTransferPostedTrade, 2, s.account_id);
		WritePostedTrade(w, *t);
		w.U(0);   // the batch vector: one trade per message
		Send(s, w);
	}
	Send(s, TradeCmd(kEndPostedTrades, 1, s.account_id));
}

void HandleAddPostedTrade(Session &s, Reader &r)
{
	r.U(); r.U();
	if (r.U() != 0) return;   // no trade object
	const uint32_t cls = r.U(), ver = r.U();
	if (r.bad || cls != kPostedTrade) return;
	PostedTrade t;
	r.U(); r.U(); r.S(); r.U();   // id, poster, name, time: the server fills them
	auto read_map = [&r](std::map<uint32_t, uint32_t> &m) {
		const uint32_t n = r.U();
		for (uint32_t i = 0; i < n && !r.bad && i < 200; ++i) {
			const uint32_t a = r.U(), q = r.U();
			if (q) m[a] += q;
		}
	};
	read_map(t.offered);
	read_map(t.wanted);
	t.recipient = r.U();
	r.S();
	const uint32_t guild = r.U();
	r.S();
	if (ver > 1) { r.S(); r.S(); }
	if (r.bad) return;

	auto fail = [&](uint32_t code, const char *why) {
		LogInfo("[LoN] [{}] posted trade refused: {}", s.name, why);
		SendTradeError(s, code, true);
	};
	uint32_t give = 0, take = 0;
	for (auto &kv : t.offered) { give += kv.second; if (!KnownArchetype(kv.first)) { fail(kPtErrTooManyCards, "unknown offered card"); return; } }
	for (auto &kv : t.wanted)  { take += kv.second; if (!KnownArchetype(kv.first)) { fail(kPtErrTooManyCards, "unknown wanted card"); return; } }
	if (give + take == 0 || give > kMaxCardsPerSide || take > kMaxCardsPerSide) { fail(kPtErrTooManyCards, "card count"); return; }
	if (guild) { fail(kPtErrRecipient, "guild-only trade"); return; }
	if (t.recipient) {
		if (t.recipient == s.account_id) { fail(kPtErrRecipient, "posted to self"); return; }
		auto a = database.QueryDatabase(fmt::format(
			"SELECT c.name FROM lon_account l JOIN character_data c ON c.account_id = l.account_id "
			"WHERE l.account_id = {} AND c.deleted_at IS NULL ORDER BY c.last_login DESC LIMIT 1", t.recipient));
		if (!a.Success() || a.RowCount() == 0) { fail(kPtErrRecipient, "recipient never played"); return; }
		t.recipient_name = a.begin()[0] ? a.begin()[0] : "";
	}
	auto c = database.QueryDatabase(fmt::format(
		"SELECT COUNT(*), SUM(recipient_account_id = 0) FROM lon_posted_trade WHERE account_id = {} AND state IN ({}, {})",
		s.account_id, static_cast<int>(kTradeOpen), static_cast<int>(kTradeAccepting)));
	const uint32_t open_all = c.Success() && c.RowCount() ? ToU(c.begin()[0]) : 0;
	const uint32_t open_pub = c.Success() && c.RowCount() ? ToU(c.begin()[1]) : 0;
	if (open_all >= kMaxPosts || (!t.recipient && open_pub >= kMaxPublicPosts)) { fail(kPtErrMaxPosts, "too many open posts"); return; }

	// Hold the offered copies and record the trade, all or nothing.
	if (!database.TransactionBegin().Success()) { fail(kPtErrTooManyCards, "no transaction"); return; }
	std::vector<Inst> held;
	bool ok = true;
	for (auto &kv : t.offered) {
		std::vector<Inst> got = TradableCopies(s.account_id, kv.first, kv.second);
		if (got.size() < kv.second) { ok = false; break; }
		held.insert(held.end(), got.begin(), got.end());
	}
	uint32_t id = 0;
	if (ok) {
		auto ins = database.QueryDatabase(fmt::format(
			"INSERT INTO lon_posted_trade (account_id, poster_name, recipient_account_id, recipient_name) VALUES ({}, '{}', {}, '{}')",
			s.account_id, Strings::Escape(s.name), t.recipient, Strings::Escape(t.recipient_name)));
		id = ins.Success() ? static_cast<uint32_t>(ins.LastInsertedID()) : 0;
		ok = id != 0;
	}
	if (ok) {
		std::string values;
		for (int side = 0; side < 2; ++side) {
			for (auto &kv : side == 0 ? t.offered : t.wanted) {
				if (!values.empty()) values += ",";
				values += fmt::format("({},{},{},{})", id, side, kv.first, kv.second);
			}
		}
		ok = database.QueryDatabase("INSERT INTO lon_posted_trade_line (trade_id, side, archetype, quantity) VALUES " + values).Success();
	}
	if (ok && !held.empty()) {
		auto mv = database.QueryDatabase(fmt::format(
			"UPDATE lon_card SET account_id = 0 WHERE id IN ({}) AND account_id = {} AND tradable = 1", IdList(held), s.account_id));
		ok = mv.Success() && mv.RowsAffected() == held.size();
		if (ok) {
			std::string values;
			for (const Inst &i : held) {
				if (!values.empty()) values += ",";
				values += fmt::format("({},{},{})", i.number, id, s.account_id);
			}
			ok = database.QueryDatabase("INSERT INTO lon_posted_trade_escrow (card_id, trade_id, account_id) VALUES " + values).Success();
		}
	}
	if (!ok || !database.TransactionCommit().Success()) {
		database.TransactionRollback();
		// No builder text fits "you no longer have those cards"; live never escrowed. 6 is the closest.
		fail(kPtErrTooManyCards, "could not hold the offered cards");
		return;
	}

	t.id = id;
	t.account = s.account_id;
	t.poster = s.name;
	t.posted = static_cast<uint32_t>(time(nullptr));
	if (!held.empty()) Send(s, RemoveInstances(held));
	Writer echo = TradeCmd(kAddPostedTrade, 1, s.account_id);
	WritePostedTrade(echo, t);
	Send(s, echo);
	// Others with the window open get it as a transfer (an AddPostedTrade would close their own builder).
	for (auto &kv : g_sessions) {
		Session &o = *kv.second;
		if (!o.account_id || !o.trade_listen || o.account_id == s.account_id || !CanSee(t, o.account_id)) continue;
		Writer w = TradeCmd(kTransferPostedTrade, 2, o.account_id);
		WritePostedTrade(w, t);
		w.U(0);
		Send(o, w);
		Send(o, TradeCmd(kEndPostedTrades, 1, o.account_id));
	}
	LogInfo("[LoN] [{}] posted trade [{}]: [{}] card(s) offered, [{}] wanted{}", s.name, id, give, take,
		t.recipient ? fmt::format(", for [{}]", t.recipient_name) : "");
	CheckProgress(s, true);   // Post a Trade
}

// Closes an open trade without a buyer (cancelled by the poster or expired) and gives the held
// copies back. poster = 0 means any poster (expiry). False = it was not open (or not theirs).
bool CloseTrade(uint32_t id, uint32_t poster, int state)
{
	std::vector<PostedTrade> v = LoadTrades(fmt::format("id = {}", id));
	if (v.empty()) return false;
	const PostedTrade &t = v[0];
	if (t.state != kTradeOpen || (poster && t.account != poster)) return false;

	if (!database.TransactionBegin().Success()) return false;
	auto st = database.QueryDatabase(fmt::format(
		"UPDATE lon_posted_trade SET state = {}, closed_at = NOW() WHERE id = {} AND state = {}",
		state, id, static_cast<int>(kTradeOpen)));
	bool ok = st.Success() && st.RowsAffected() == 1;
	std::vector<Inst> back;
	if (ok) {
		back = EscrowOf(id);
		if (!back.empty()) {
			auto mv = database.QueryDatabase(fmt::format(
				"UPDATE lon_card SET account_id = {} WHERE id IN ({}) AND account_id = 0", t.account, IdList(back)));
			ok = mv.Success() && mv.RowsAffected() == back.size();
		}
	}
	if (ok) ok = database.QueryDatabase(fmt::format("DELETE FROM lon_posted_trade_escrow WHERE trade_id = {}", id)).Success();
	if (!ok || !database.TransactionCommit().Success()) {
		database.TransactionRollback();
		LogError("[LoN] posted trade [{}] could not be closed -- left open", id);
		return false;
	}

	for (auto &kv : g_sessions) {
		Session &o = *kv.second;
		if (o.account_id != t.account || !o.synced) continue;
		DeliverTrade(o, {}, back, id);
		SendTradeGone(o, id);
	}
	BroadcastTradeGone(t, t.account);
	LogInfo("[LoN] posted trade [{}] by [{}] {} -- [{}] card(s) returned", id, t.poster,
		state == kTradeExpired ? "expired" : "cancelled", back.size());
	return true;
}

void HandleCancelPostedTrade(Session &s, Reader &r)
{
	r.U(); r.U();
	const uint32_t id = r.U();
	if (r.bad || !id) return;
	if (!CloseTrade(id, s.account_id, kTradeCancelled)) SendTradeGone(s, id);   // already gone: drop the row
}

void HandleAcceptPostedTrade(Session &s, Reader &r)
{
	r.U(); r.U();
	const uint32_t id = r.U();
	r.U();
	if (r.bad || !id) return;
	auto fail = [&](uint32_t code, const char *why) {
		LogInfo("[LoN] [{}] could not accept posted trade [{}]: {}", s.name, id, why);
		SendTradeError(s, code, false);
	};

	std::vector<PostedTrade> v = LoadTrades(fmt::format("id = {}", id));
	if (v.empty()) { fail(kPtErrCompleted, "no such trade"); SendTradeGone(s, id); return; }
	const PostedTrade &t = v[0];
	if (t.state == kTradeAccepting) { fail(kPtErrBeingCompleted, "being accepted"); return; }
	if (t.state != kTradeOpen) { fail(kPtErrCompleted, "closed"); SendTradeGone(s, id); return; }
	if (t.account == s.account_id || (t.recipient && t.recipient != s.account_id)) { fail(kPtErrWrongAccount, "not for this account"); return; }

	// Claim it: only one accept can move it from open to accepting.
	auto claim = database.QueryDatabase(fmt::format(
		"UPDATE lon_posted_trade SET state = {}, accepted_by = {} WHERE id = {} AND state = {}",
		static_cast<int>(kTradeAccepting), s.account_id, id, static_cast<int>(kTradeOpen)));
	if (!claim.Success() || claim.RowsAffected() != 1) { fail(kPtErrBeingCompleted, "lost the race"); return; }
	auto release = [&]() {
		database.QueryDatabase(fmt::format(
			"UPDATE lon_posted_trade SET state = {}, accepted_by = 0 WHERE id = {} AND state = {}",
			static_cast<int>(kTradeOpen), id, static_cast<int>(kTradeAccepting)));
	};

	if (!database.TransactionBegin().Success()) { release(); fail(kPtErrLock, "no transaction"); return; }
	std::vector<Inst> paid;
	uint32_t short_code = 0;
	for (auto &kv : t.wanted) {
		std::vector<Inst> got = TradableCopies(s.account_id, kv.first, kv.second);
		if (got.size() < kv.second) { short_code = kPtErrYouShort; break; }
		paid.insert(paid.end(), got.begin(), got.end());
	}
	std::vector<Inst> got = EscrowOf(id);
	uint32_t offered = 0;
	for (auto &kv : t.offered) offered += kv.second;
	if (!short_code && got.size() != offered) short_code = kPtErrPosterShort;
	bool ok = !short_code;
	if (ok && !paid.empty()) {
		auto mv = database.QueryDatabase(fmt::format(
			"UPDATE lon_card SET account_id = {} WHERE id IN ({}) AND account_id = {} AND tradable = 1",
			t.account, IdList(paid), s.account_id));
		ok = mv.Success() && mv.RowsAffected() == paid.size();
	}
	if (ok && !got.empty()) {
		auto mv = database.QueryDatabase(fmt::format(
			"UPDATE lon_card SET account_id = {} WHERE id IN ({}) AND account_id = 0", s.account_id, IdList(got)));
		ok = mv.Success() && mv.RowsAffected() == got.size();
	}
	if (ok) ok = database.QueryDatabase(fmt::format("DELETE FROM lon_posted_trade_escrow WHERE trade_id = {}", id)).Success();
	if (ok) {
		auto st = database.QueryDatabase(fmt::format(
			"UPDATE lon_posted_trade SET state = {}, closed_at = NOW() WHERE id = {} AND state = {}",
			static_cast<int>(kTradeCompleted), id, static_cast<int>(kTradeAccepting)));
		ok = st.Success() && st.RowsAffected() == 1;
	}
	if (!ok || !database.TransactionCommit().Success()) {
		database.TransactionRollback();
		release();
		fail(short_code ? short_code : kPtErrLock, short_code == kPtErrYouShort ? "acceptor lacks the wanted cards"
			: short_code ? "held cards missing" : "swap failed");
		return;
	}

	DeliverTrade(s, paid, got, id);
	SendTradeGone(s, id);
	for (auto &kv : g_sessions) {
		Session &o = *kv.second;
		if (o.account_id != t.account || !o.synced) continue;
		DeliverTrade(o, {}, paid, id);
		SendTradeGone(o, id);
	}
	BroadcastTradeGone(t, s.account_id);
	CheckProgress(s, true);   // buyer
	for (auto &kv : g_sessions) if (kv.second->account_id == t.account && kv.second->synced) CheckProgress(*kv.second, true);   // seller
	LogInfo("[LoN] [{}] accepted posted trade [{}] from [{}]: got [{}] card(s), gave [{}]",
		s.name, id, t.poster, got.size(), paid.size());
}

// ---------------------------------------------------------------------------
// Custom avatars (research/lon_misc_research.md section A)
// ---------------------------------------------------------------------------
// The client builds the avatar itself; the server hands out its archetype id, checks the name,
// keeps the object bytes the client stores and gives them back at every login
// (ArchCommand_AddArchetypesToDB), because the client's shipped archetype files do not have it.
// Ids start at 200000001 (lon_custom_avatar AUTO_INCREMENT). The client reads a 3 or 4 in the
// hundred-thousands digit as a foil, so an id with one is never handed out (it is 200300000+,
// years of avatars away).
// Cap per account: Custom:LoNMaxCustomAvatars (default 5). The copy in the collection is
// not tradable.
void HandleGetArchetypeID(Session &s, Reader &r)
{
	r.U();
	if (r.bad) return;
	auto reply = [&](uint32_t err, uint32_t id) {
		Writer w;
		w.Header(kGetArchetypeID, 1, 2).U(s.account_id).U(err).U(id);
		Send(s, w);
	};
	database.QueryDatabase(fmt::format(
		"DELETE FROM lon_custom_avatar WHERE account_id = {} AND `blob` IS NULL AND created_at < NOW() - INTERVAL 1 DAY", s.account_id));
	auto c = database.QueryDatabase(fmt::format(
		"SELECT COUNT(*) FROM lon_custom_avatar WHERE account_id = {} AND `blob` IS NOT NULL AND deleted_at IS NULL", s.account_id));
	const uint32_t have = c.Success() && c.RowCount() ? ToU(c.begin()[0]) : 0;
	if (have >= static_cast<uint32_t>(std::max(0, RuleI(Custom, LoNMaxCustomAvatars)))) {
		LogInfo("[LoN] [{}] has [{}] custom avatars -- at the cap", s.name, have);
		reply(kErrTooManyAvatars, 0);
		return;
	}
	auto ins = database.QueryDatabase(fmt::format("INSERT INTO lon_custom_avatar (account_id) VALUES ({})", s.account_id));
	const uint32_t id = ins.Success() ? static_cast<uint32_t>(ins.LastInsertedID()) : 0;
	const uint32_t digit = (id / 100000) % 10;
	if (!id || digit == 3 || digit == 4) {
		LogError("[LoN] [{}] could not reserve a custom avatar id ([{}])", s.name, id);
		reply(0, 0);   // id 0 closes the dialog
		return;
	}
	reply(0, id);
	LogInfo("[LoN] [{}] creating custom avatar [{}]", s.name, id);
}

void HandleValidateUsername(Session &s, Reader &r)
{
	r.U(); r.U();
	const std::string name = r.S();
	const uint32_t id = r.U();
	if (r.bad) return;
	auto reply = [&](uint32_t err) {
		Writer w;
		w.Header(kValidateUsername, 1, 2).U(s.account_id).U(err).S(name).U(id);
		Send(s, w);
	};
	// 3-24 letters, single spaces or apostrophes between them.
	bool ok = name.size() >= 3 && name.size() <= 24 && std::isalpha(static_cast<unsigned char>(name.front()))
		&& std::isalpha(static_cast<unsigned char>(name.back()));
	for (size_t i = 0; ok && i < name.size(); ++i) {
		const char ch = name[i];
		if (std::isalpha(static_cast<unsigned char>(ch))) continue;
		ok = (ch == ' ' || ch == '\'') && i > 0 && std::isalpha(static_cast<unsigned char>(name[i - 1]));
	}
	if (ok) {
		auto f = database.QueryDatabase(fmt::format(
			"SELECT 1 FROM name_filter WHERE LENGTH(name) > 2 AND LOCATE(LOWER(name), LOWER('{}')) > 0 LIMIT 1",
			Strings::Escape(name)));
		ok = f.Success() && f.RowCount() == 0;
	}
	if (!ok) { reply(kErrNameIllegal); return; }
	auto t = database.QueryDatabase(fmt::format(
		"SELECT 1 FROM lon_custom_avatar WHERE name = '{}' AND archetype_id <> {} AND deleted_at IS NULL LIMIT 1",
		Strings::Escape(name), id));
	if (!t.Success() || t.RowCount() > 0) { reply(kErrNameTaken); return; }
	auto u = database.QueryDatabase(fmt::format(
		"UPDATE lon_custom_avatar SET name = '{}' WHERE archetype_id = {} AND account_id = {} AND `blob` IS NULL",
		Strings::Escape(name), id, s.account_id));
	if (!u.Success()) { reply(kErrNameTaken); return; }   // the UNIQUE key lost a race
	reply(0);
}

void HandleStoreArchetype(Session &s, Reader &r)
{
	r.U(); r.U();
	const size_t start = r.p;
	if (r.bad || start >= r.n || r.n - start > 64 * 1024) return;
	// The nullable object, kept verbatim: it is exactly what AddArchetypesToDB takes back.
	const std::vector<uint8_t> blob(r.d + start, r.d + r.n);
	// Its archetype id must be one reserved for this account (it sits within the first fields).
	Reader b(blob.data(), blob.size());
	if (b.U() != 0) return;
	std::set<uint32_t> early;
	for (int i = 0; i < 12 && !b.bad; ++i) early.insert(b.U());
	auto q = database.QueryDatabase(fmt::format(
		"SELECT archetype_id FROM lon_custom_avatar WHERE account_id = {} AND `blob` IS NULL AND name IS NOT NULL", s.account_id));
	uint32_t id = 0;
	if (q.Success()) for (auto row : q) if (early.count(ToU(row[0]))) id = ToU(row[0]);
	if (!id) {
		LogInfo("[LoN] [{}] stored an avatar that was never reserved -- ignored", s.name);
		return;
	}
	auto u = database.QueryDatabase(fmt::format(
		"UPDATE lon_custom_avatar SET `blob` = UNHEX('{}') WHERE archetype_id = {} AND account_id = {} AND `blob` IS NULL",
		Hex(blob), id, s.account_id));
	if (!u.Success() || u.RowsAffected() != 1) return;
	database.QueryDatabase(fmt::format(
		"INSERT INTO lon_card (account_id, archetype, tradable, source) VALUES ({}, {}, 0, 'avatar:custom')", s.account_id, id));
	LogInfo("[LoN] [{}] saved custom avatar [{}] (hero type [{}])", s.name, id, AvatarHeroType(blob));
	CheckProgress(s, true);   // Create a <type> Avatar
}

void HandleDeleteArchetype(Session &s, Reader &r)
{
	r.U(); r.U();
	const uint32_t id = r.U();
	if (r.bad || !id) return;
	auto u = database.QueryDatabase(fmt::format(
		"UPDATE lon_custom_avatar SET deleted_at = NOW() WHERE archetype_id = {} AND account_id = {} AND deleted_at IS NULL",
		id, s.account_id));
	if (!u.Success() || u.RowsAffected() != 1) return;
	database.QueryDatabase(fmt::format("DELETE FROM lon_card WHERE account_id = {} AND archetype = {}", s.account_id, id));
	LogInfo("[LoN] [{}] deleted custom avatar [{}]", s.name, id);
}

// Before the collection: the account's custom avatars into the client's archetype DB.
void SendCustomAvatars(Session &s)
{
	auto q = database.QueryDatabase(fmt::format(
		"SELECT HEX(`blob`) FROM lon_custom_avatar WHERE account_id = {} AND `blob` IS NOT NULL AND deleted_at IS NULL ORDER BY archetype_id",
		s.account_id));
	if (!q.Success() || q.RowCount() == 0) return;
	Writer w;
	w.Header(kAddArchetypesToDB, 2, 2).U(s.account_id).U(static_cast<uint32_t>(q.RowCount()));
	for (auto row : q) {
		const std::vector<uint8_t> blob = Unhex(row[0]);
		w.U(static_cast<uint32_t>(blob.size())).Raw(blob.data(), blob.size());
		w.b.push_back(0);   // a string on the wire carries its NUL
	}
	Send(s, w);
}

// Zlib block on the wire: varint raw length, varint compressed length, the zlib bytes.
bool WriteZlib(Writer &w, const Writer &raw)
{
	std::vector<char> z(EQ::EstimateDeflateBuffer(static_cast<uint32>(raw.b.size())) + 64);
	const uint32 n = EQ::DeflateData(reinterpret_cast<const char *>(raw.b.data()), static_cast<uint32>(raw.b.size()),
		z.data(), static_cast<uint32>(z.size()));
	w.U(static_cast<uint32_t>(raw.b.size())).U(n).Raw(reinterpret_cast<const uint8_t *>(z.data()), n);
	return n != 0;   // DeflateData gives 0 on failure; a block that does not inflate asserts the client
}

// AccountCommand_GetAccountsByPartialName v2 (a trade posted to one player): the matching card
// players, by character name -- one row per account, the name the player typed against.
void HandleAccountLookup(Session &s, Reader &r, uint32_t ver)
{
	r.U();
	std::string partial = r.S();
	if (r.bad) return;
	std::string clean;
	for (char ch : partial) if (std::isalnum(static_cast<unsigned char>(ch))) clean.push_back(ch);
	std::vector<std::pair<uint32_t, std::string>> found;
	if (clean.size() >= 2) {
		auto q = database.QueryDatabase(fmt::format(
			"SELECT c.account_id, MIN(c.name) FROM character_data c JOIN lon_account l ON l.account_id = c.account_id "
			"WHERE c.name LIKE '{}%' AND c.deleted_at IS NULL AND c.account_id <> {} GROUP BY c.account_id LIMIT 20",
			clean, s.account_id));
		if (q.Success()) for (auto row : q) found.emplace_back(ToU(row[0]), row[1] ? row[1] : "");
	}
	Writer raw;
	raw.U(static_cast<uint32_t>(found.size()));
	for (auto &f : found) raw.U(f.first);
	for (int k = 0; k < 2; ++k) {
		raw.U(static_cast<uint32_t>(found.size()));
		for (auto &f : found) raw.S(f.second);
	}
	Writer w;
	w.Header(kGetAccountsByName, ver, 2).U(s.account_id).S(partial).U(0);
	if (WriteZlib(w, raw)) Send(s, w);
}

// GuildCommand_GetGuildsByPartialName: no card-game guilds, so never a match ("not found").
void HandleGuildLookup(Session &s, Reader &r, uint32_t ver)
{
	r.U();
	const std::string partial = r.S();
	if (r.bad) return;
	Writer raw;
	raw.U(0).U(0);
	Writer w;
	w.Header(kGetGuildsByName, ver, 3).U(s.account_id).S(partial).U(0);
	if (WriteZlib(w, raw)) Send(s, w);
}

// ---------------------------------------------------------------------------
// The Trade Lobby (research/lon_trade_lobby_spec.md -- every field checked in the
// client's read functions; a wrong one asserts and EverQuest exits)
// ---------------------------------------------------------------------------
// Live trades start from the Trade Lobby's player list: lobby group 3, type 1. The client asks to
// join it (LobbyCommand_Join), opens the lobby screen on our echo, and lists the others from
// BulkJoin; the right-click Trade item needs the other player present, status 2 and the
// "RegisteredUser" flag. Groups 3 and 2 (Casual Games) exist, nothing else: adding group 1 would make
// the client auto-join the main lobby, and a non-match child group crashes its right-click menu.
// A connection is in at most one of them; entering one leaves the other.
constexpr uint32_t kLobbyJoin         = 0x5C;   // v4, 3 (both directions)
constexpr uint32_t kLobbyLeave        = 0x5D;   // v3, 3 (both directions)
constexpr uint32_t kLobbyAddGroups    = 0x5E;   // v1, 3
constexpr uint32_t kLobbyObject       = 0x67;   // v3, 1 (a plain object: no nullable flag)
constexpr uint32_t kLobbySendText     = 0x61;   // v4, 3 (both directions)
constexpr uint32_t kLobbyBulkJoin     = 0x6A;   // v3, 3
constexpr uint32_t kLobbyChangeStatus = 0x89;   // v1, 3 (both directions)
constexpr uint32_t kLobbyStats        = 0x19C;  // v3, 3
constexpr uint32_t kTradeLobby        = 3;
// Casual Games (lon_casual_games_spec.md section 1): a second type-1 lobby built exactly like the
// Trade Lobby; GroupID 2 gives it the casual look (Create, Quick Join, practice, the match list).
// Never list groups 9..19: two or more casual lobbies make the navigator open a sub-lobby chooser.
constexpr uint32_t kCasualLobby       = 2;
// Tournaments (research/lon_tournaments_spec.md section 1): a third type-1 lobby, GroupID 5 opens WATournamentScreen.
constexpr uint32_t kTournLobby        = 5;
constexpr uint32_t kLobbyMax          = 1000;
constexpr uint32_t kStatusOnline      = 2;

void TradePartyLeft(uint32_t account);   // live trades section, below
void PvPLeftScreen(Session &s);
void SendOpenMatches(Session &s);                              // Casual Games matches, below
void HandleMatchJoin(Session &s, uint32_t match, uint32_t role, const std::string &password);
bool IsCasualMatch(uint32_t id);
void LeaveRoom(Session &s, const char *how);
void CasualGameOver(uint32_t id);
void SendTournGroups(Session &s);                              // Tournaments, below
bool IsTournQueue(uint32_t id);
void HandleQueueJoin(Session &s, uint32_t queue, uint32_t role);
void LeaveQueueEx(Session &s, const char *how, bool tell_self);

// A member's account properties: the flag the Trade item checks on both sides, and the PvP record and
// ratings its Profile shows to the others.
void WriteMemberProps(Writer &w, uint32_t account)
{
	w.Header(kPropertySet, 1, 1).U(1 + kPvPPropCount)
		.U(kPropAccountFlags).Header(kValueData, 4, 1).U(7).U(1).U(1).S("RegisteredUser");
	WritePvPProps(w, LoadPvPStats(account));
}

// One session per account in lobby `group` (the first found), never `except`.
std::vector<Session *> LobbyMembers(uint32_t group, uint32_t except_account)
{
	std::vector<Session *> out;
	std::set<uint32_t> seen;
	for (auto &kv : g_sessions) {
		Session &o = *kv.second;
		if (!o.account_id || o.lobby_group != group || o.account_id == except_account || seen.count(o.account_id)) continue;
		seen.insert(o.account_id);
		out.push_back(&o);
	}
	return out;
}

// Both maps are std::maps on the client: count + (group, value) pairs, keys ascending.
void SendLobbyStats(Session &s)
{
	const uint32_t casual = static_cast<uint32_t>(LobbyMembers(kCasualLobby, 0).size());
	const uint32_t trade  = static_cast<uint32_t>(LobbyMembers(kTradeLobby, 0).size());
	const uint32_t tourn  = static_cast<uint32_t>(LobbyMembers(kTournLobby, 0).size());
	Writer w;
	w.Header(kLobbyStats, 3, 3).U(s.account_id)
		.U(3).U(kCasualLobby).U(casual).U(kTradeLobby).U(trade).U(kTournLobby).U(tourn)   // current population
		.U(0).U(0)                                                     // two maps whose meaning is unknown: empty
		.U(kLobbyMax)                                                  // default max
		.U(3).U(kCasualLobby).U(kLobbyMax).U(kTradeLobby).U(kLobbyMax).U(kTournLobby).U(kLobbyMax);
	Send(s, w);
}

void BroadcastLobbyStats()
{
	for (auto &kv : g_sessions) if (kv.second->account_id) SendLobbyStats(*kv.second);
}

// One AddGroups per lobby (a vector of two is legal too, but posts extra client events).
void SendLobbyGroup(Session &s, uint32_t group)
{
	Writer w;
	w.Header(kLobbyAddGroups, 1, 3).U(s.account_id).U(1).Header(kLobbyObject, 3, 1);
	for (int i = 0; i < 5; ++i) w.U(0).Header(kPropertySet, 1, 1).U(0);   // five present, empty sets
	for (int i = 0; i < 5; ++i) w.U(0);                                   // five empty role lists
	w.U(0)              // ContainingGroupID
		.U(group)       // GroupID
		.U(1)           // eLobbyTypeID: a lobby room (members become status 2)
		.U(1)           // v2: deck -- null
		.U(0).U(0);     // v3: tournamentRound, subState
	Send(s, w);
}

// Once per login: the Trade Lobby, Casual Games and Tournaments exist, with room in them (else "Lobby Full").
void SendLobbyGroups(Session &s)
{
	SendLobbyGroup(s, kTradeLobby);
	SendLobbyGroup(s, kCasualLobby);
	SendLobbyGroup(s, kTournLobby);
	SendLobbyStats(s);
}

const char *LobbyName(uint32_t group)
{
	return group == kTradeLobby ? "the Trade Lobby" : group == kCasualLobby ? "Casual Games" :
	       group == kTournLobby ? "Tournaments" : "a lobby";
}

void LeaveLobby(Session &s)
{
	const uint32_t group = s.lobby_group;
	if (!group) return;
	s.lobby_group = 0;
	if (!s.account_id) return;
	if (group == kTradeLobby) TradePartyLeft(s.account_id);
	// A match room belongs to Casual Games: leaving the lobby leaves the room (a host closes it).
	if (group == kCasualLobby && s.room) LeaveRoom(s, "left the lobby, leaving");
	// The tournament queue belongs to Tournaments: leaving the lobby leaves the queue.
	if (group == kTournLobby && s.queue) LeaveQueueEx(s, "left Tournaments, leaving", true);
	for (Session *o : LobbyMembers(group, s.account_id)) {
		Writer w;
		w.Header(kLobbyLeave, 3, 3).U(s.account_id).U(group).U(0).U(0);
		Send(*o, w);
	}
	BroadcastLobbyStats();
	LogInfo("[LoN] [{}] left {}", s.name, LobbyName(group));
}

void HandleLobbyJoin(Session &s, Reader &r)
{
	r.U();   // LobbyCommand: AccountID first
	const uint32_t group = r.U();
	if (r.bad) return;
	if (IsCasualMatch(group)) {
		// Joining a listed match: RoleType, then (v2+) the Password the join dialog typed.
		const uint32_t role = r.U();
		std::string password = r.S();
		if (r.bad) password.clear();
		HandleMatchJoin(s, group, role, password);
		return;
	}
	if (IsTournQueue(group)) {
		HandleQueueJoin(s, group, r.U());
		return;
	}
	if (group != kTradeLobby && group != kCasualLobby && group != kTournLobby) {
		LogInfo("[LoN] [{}] asked to join lobby [{}] -- no such lobby", s.name, group);
		return;
	}
	// Esc on the trade screen sends Join(3) first: leaving a trade ends it.
	if (s.lobby_group == kTradeLobby) TradePartyLeft(s.account_id);
	// Switching lobbies: the old one is left now (the client's own Leave(old) then finds nothing).
	if (s.lobby_group && s.lobby_group != group) LeaveLobby(s);
	// Back in the lobby from a PvP game screen: that player has left the game.
	PvPLeftScreen(s);
	s.lobby_group  = group;
	s.lobby_status = kStatusOnline;

	// 1. The echo opens the joiner's lobby screen (no name: the account is already known).
	Writer echo;
	echo.Header(kLobbyJoin, 4, 3).U(s.account_id).U(group).U(1).S("").U(0).S("")
		.U(0).Header(kPropertySet, 1, 1).U(0).U(0);
	Send(s, echo);

	// 2. Everyone already there. The five lists run in parallel and must stay the same length.
	std::vector<Session *> others = LobbyMembers(group, s.account_id);
	const uint32_t n = static_cast<uint32_t>(others.size());
	Writer raw;
	raw.U(n);
	for (Session *o : others) raw.U(o->account_id);   // role 1 (player)
	raw.U(0).U(0).U(0).U(0);                           // roles 2-5
	raw.U(group);
	raw.U(n); for (Session *o : others) raw.U(o->account_id);
	raw.U(n); for (Session *o : others) raw.S(o->name);
	raw.U(n); for (size_t i = 0; i < others.size(); ++i) raw.U(0);   // gender
	raw.U(n); for (Session *o : others) WriteMemberProps(raw, o->account_id);
	raw.U(n); for (Session *o : others) raw.U(o->lobby_status);
	Writer bulk;
	bulk.Header(kLobbyBulkJoin, 3, 3).U(s.account_id);
	if (WriteZlib(bulk, raw)) Send(s, bulk);

	// 3. The others meet the newcomer (the name introduces the account; its properties are required).
	for (Session *o : others) {
		Writer w;
		w.Header(kLobbyJoin, 4, 3).U(s.account_id).U(group).U(1).S("").U(0).S(s.name).U(0);
		WriteMemberProps(w, s.account_id);
		w.U(0);   // gender
		Send(*o, w);
	}
	BroadcastLobbyStats();
	// 4. Casual Games: the open matches, after BulkJoin so every player in them is a known account.
	if (group == kCasualLobby) SendOpenMatches(s);
	// 5. Tournaments: the open queue and the tournaments running now (same reason: after BulkJoin).
	if (group == kTournLobby) SendTournGroups(s);
	LogInfo("[LoN] [{}] joined {} ([{}] others there)", s.name, LobbyName(group), n);
}

void HandleLobbyLeave(Session &s, Reader &r)
{
	r.U();   // AccountID
	const uint32_t group = r.U();
	if (r.bad) return;
	// Entering one type-1 lobby makes the client send Leave for the other (spec 1.3).
	if (group == kTradeLobby || group == kCasualLobby || group == kTournLobby) { if (s.lobby_group == group) LeaveLobby(s); }
	else if (s.pvp_match && group == s.pvp_match) PvPLeftScreen(s);   // the PvP game screen closed
	else if (s.room && group == s.room) LeaveRoom(s, "left");          // the match room closed (Cancel)
	else if (s.queue && group == s.queue) LeaveQueueEx(s, "left", false);   // the queue dialog closed (after a start: ignored)
	else if (s.game_screen && group == s.game_screen) s.game_screen = 0;   // a game screen closed after its match was gone
}

// Status changes reach the other members of the player's own lobby.
void HandleLobbyChangeStatus(Session &s, Reader &r)
{
	r.U();   // AccountID
	const uint32_t status = r.U();
	if (r.bad || status > 20) return;
	s.lobby_status = status;
	// 5 = on a game screen (LaunchGame); anything else = back in a lobby or a dialog.
	if (status == 5 && s.pvp_match) s.game_screen = s.pvp_match;
	else if (status != 5) s.game_screen = 0;
	if (!s.lobby_group) return;
	for (Session *o : LobbyMembers(s.lobby_group, s.account_id)) {
		Writer w;
		w.Header(kLobbyChangeStatus, 1, 3).U(s.account_id).U(status);
		Send(*o, w);
	}
}

// Lobby chat. The client shows no line of its own, so the sender gets it back too.
void HandleLobbySendText(Session &s, Reader &r, uint32_t ver)
{
	r.U();   // AccountID
	const uint32_t group = r.U(), target = r.U(), disposition = r.U();
	std::string text = r.S();
	const uint32_t quick  = ver > 1 ? r.U() : 0;
	const uint32_t chat   = ver > 2 ? r.U() : 0;
	const uint32_t locale = ver > 3 ? r.U() : 0;
	if (r.bad) return;
	const bool lobby = s.lobby_group && group == s.lobby_group;
	if (!lobby) return;
	if (text.size() > 255) text.resize(255);
	Writer w;
	w.Header(kLobbySendText, 4, 3).U(s.account_id).U(group).U(target).U(disposition)
		.S(text).U(quick ? 1 : 0).U(chat).U(locale);
	Send(s, w);
	for (Session *o : LobbyMembers(group, s.account_id)) {
		if (disposition == 0 && o->account_id != target) continue;   // a tell: only its target
		Send(*o, w);
	}
}

// ---------------------------------------------------------------------------
// Live trades (research/lon_live_trade_spec.md -- every field checked in the client)
// ---------------------------------------------------------------------------
// A asks B from the Trade Lobby list; the server brokers every step and the client moves nothing
// itself. Rules the client gives us no choice about (spec section 7):
// - trade messages only reach sessions in the Trade Lobby (their chat lines read the current lobby
//   with no null check -- StartTradeSync always);
// - at session start: other requests cancelled, StartTradeSync, the partner's tradable cards (a
//   type-3 sync), THEN AcceptTradeRequest, which opens the screen and wipes the client's dialog maps;
// - the trade's lobby id L is never a real group (1000000 + S) and never 3;
// - SetupFinalTradeAccept is v2 (v1 carries no lists); series is 0 on every card.
// Nothing is written before both final accepts; the swap is one guarded transaction re-checking
// every card, so a disconnect can neither lose nor copy a card.
constexpr uint32_t kIssueTradeRequest  = 0x93;   // v2, 3
constexpr uint32_t kAcceptTradeRequest = 0x94;   // v1, 3
constexpr uint32_t kAddCardToTrade     = 0x95;   // v1, 3
constexpr uint32_t kAcceptTrade        = 0x96;   // v1, 3
constexpr uint32_t kRemoveCardFromTrade= 0x97;   // v3, 3
constexpr uint32_t kCancelTradeRequest = 0x98;   // v2, 3
constexpr uint32_t kEndTradeSession    = 0x99;   // v1, 3
constexpr uint32_t kClearTrade         = 0x9A;   // v1, 3
constexpr uint32_t kFinalAcceptTrade   = 0x9B;   // v1, 3
constexpr uint32_t kSetupFinalTrade    = 0x9C;   // v2, 3
constexpr uint32_t kClearAcceptState   = 0x9D;   // v1, 3
constexpr uint32_t kStartTradeSync     = 0x110;  // v1, 3
constexpr uint32_t kLockTrade          = 0x111;  // v1, 3
constexpr uint32_t kErrorMsg           = 0x6B;   // v2, 2
constexpr uint32_t kTradeLobbyBase     = 1000000; // L = this + S
constexpr uint32_t kTradeRequestSecs   = 90;
// ErrorMsg codes (fixed client texts, LoN_errors.txt).
constexpr uint32_t kTrErrLocked = 0x22, kTrErrTooMany = 0x23, kTrErrPending = 0x25, kTrErrBusy = 0x26,
	kTrErrNotTradable = 0x2E;

enum class TradeState { Requested, Open, Final };

struct LiveTrade {
	uint32_t   id = 0, a = 0, b = 0;   // a = the issuer ("founder"), b = the one asked
	TradeState state = TradeState::Requested;
	uint32_t   created = 0;
	std::vector<Inst> a_cards, b_cards;   // what each side gives (cards they own)
	bool a_ok = false, b_ok = false;      // the accept boxes
	bool a_final = false, b_final = false;
	uint32_t lobby() const { return kTradeLobbyBase + id; }
};

std::map<uint32_t, LiveTrade> g_trades;
uint32_t g_next_trade = 1;

Session *LobbySession(uint32_t account)
{
	for (auto &kv : g_sessions) {
		Session &o = *kv.second;
		if (o.account_id == account && o.lobby_group == kTradeLobby) return &o;
	}
	return nullptr;
}

LiveTrade *TradeOf(uint32_t account)
{
	for (auto &kv : g_trades) if (kv.second.a == account || kv.second.b == account) return &kv.second;
	return nullptr;
}

void SendParties(const LiveTrade &t, const Writer &w)
{
	for (uint32_t acct : {t.a, t.b}) if (Session *p = LobbySession(acct)) Send(*p, w);
}

// Every TradeCommand: three header levels, AccountID, TradeSessionID.
Writer TradeMsg(uint32_t op, uint32_t ver, uint32_t account, uint32_t session)
{
	Writer w;
	w.Header(op, ver, 3).U(account).U(session);
	return w;
}

void SendTradeErrorMsg(Session &s, uint32_t code, const std::string &text = "")
{
	Writer w;
	w.Header(kErrorMsg, 2, 2).S(text).U(code);
	Send(s, w);
}

void UnlockTrade(const LiveTrade &t)
{
	for (const Inst &c : t.a_cards) g_card_lock.erase(c.number);
	for (const Inst &c : t.b_cards) g_card_lock.erase(c.number);
}

// Request withdrawn or refused (origin = who cancelled, 0 = timeout/server).
void CancelRequest(uint32_t id, uint32_t origin)
{
	auto it = g_trades.find(id);
	if (it == g_trades.end()) return;
	const LiveTrade t = it->second;
	g_trades.erase(it);
	SendParties(t, TradeMsg(kCancelTradeRequest, 2, t.b, t.id).U(t.a).U(origin));
}

// An open trade ends without a swap; the one who stayed is told and sent back to the lobby.
void AbortTrade(uint32_t id, uint32_t leaver)
{
	auto it = g_trades.find(id);
	if (it == g_trades.end()) return;
	const LiveTrade t = it->second;
	g_trades.erase(it);
	UnlockTrade(t);
	const uint32_t other = leaver == t.a ? t.b : t.a;
	if (Session *o = LobbySession(other)) {
		Session *l = LobbySession(leaver);
		SendTradeErrorMsg(*o, 0, fmt::format("{} left the trade.", l ? l->name : std::string("Your trade partner")));
		Send(*o, TradeMsg(kEndTradeSession, 1, other, t.id));
	}
	LogInfo("[LoN] live trade [{}] ended without a swap", t.id);
}

void TradePartyLeft(uint32_t account)
{
	LiveTrade *t = TradeOf(account);
	if (!t) return;
	if (t->state == TradeState::Requested) CancelRequest(t->id, account);
	else AbortTrade(t->id, account);
}

void ResetAccepts(LiveTrade &t)
{
	const bool any = t.a_ok || t.b_ok || t.state == TradeState::Final;
	const bool was_final = t.state == TradeState::Final;
	t.a_ok = t.b_ok = t.a_final = t.b_final = false;
	t.state = TradeState::Open;
	if (!any) return;
	for (uint32_t acct : {t.a, t.b}) {
		Session *p = LobbySession(acct);
		if (!p) continue;
		Send(*p, TradeMsg(kClearAcceptState, 1, acct, t.id));
		if (was_final) Send(*p, TradeMsg(kLockTrade, 1, acct, t.id).U(0));
	}
}

// The partner's tradable cards, as the trade screen's "Theirs" collection (sync type 3).
void SendPartnerCollection(Session &to, uint32_t partner)
{
	std::map<uint32_t, std::vector<uint32_t>> by_arch;
	auto r = database.QueryDatabase(fmt::format(
		"SELECT archetype, id FROM lon_card WHERE account_id = {} AND tradable = 1 ORDER BY archetype, id", partner));
	if (r.Success()) {
		for (auto row : r) {
			const uint32_t id = ToU(row[1]);
			if (!g_card_lock.count(id)) by_arch[ToU(row[0])].push_back(id);
		}
	}
	Writer st;
	st.Header(kSyncStartInstances, 2, 3).U(partner).U(3).U(static_cast<uint32_t>(by_arch.size())).U(0);
	Send(to, st);
	std::vector<const std::pair<const uint32_t, std::vector<uint32_t>> *> order;
	for (auto &kv : by_arch) order.push_back(&kv);
	for (size_t base = 0; base < order.size() || base == 0; base += kArchetypesPerChunk) {
		const size_t end = std::min(order.size(), base + kArchetypesPerChunk);
		size_t n = 0;
		for (size_t k = base; k < end; ++k) n += order[k]->second.size();
		Writer w;
		w.Header(kSyncSendInstances, 2, 3).U(static_cast<uint32_t>(base)).U(static_cast<uint32_t>(end - base))
			.U(static_cast<uint32_t>(n));
		for (size_t k = base; k < end; ++k) for (uint32_t id : order[k]->second) w.Instance(order[k]->first, 0, id);
		w.U(0).U(0);   // no non-tradable copies, DeliveryID 0
		Send(to, w);
		if (order.empty()) break;
	}
	Send(to, Complete(0));
}

void HandleIssueTrade(Session &s, Reader &r)
{
	r.U(); r.U();
	const uint32_t target = r.U();
	if (r.bad || s.lobby_group != kTradeLobby || target == s.account_id) return;
	if (LiveTrade *mine = TradeOf(s.account_id)) {
		if (mine->state == TradeState::Requested && mine->a == s.account_id) SendTradeErrorMsg(s, kTrErrPending);
		return;
	}
	Session *b = LobbySession(target);
	if (!b || b->lobby_status != kStatusOnline || TradeOf(target)) { SendTradeErrorMsg(s, kTrErrBusy); return; }
	LiveTrade t;
	t.id = g_next_trade++;
	t.a = s.account_id;
	t.b = target;
	t.created = static_cast<uint32_t>(time(nullptr));
	g_trades[t.id] = t;
	SendParties(t, TradeMsg(kIssueTradeRequest, 2, t.a, t.id).U(t.b).U(kTradeLobby));
	LogInfo("[LoN] [{}] asks [{}] to trade (session [{}])", s.name, b->name, t.id);
}

void HandleCancelTradeRequest(Session &s, Reader &r)
{
	r.U();
	const uint32_t id = r.U();
	if (r.bad) return;
	auto it = g_trades.find(id);
	// A dialog the server closes may send a stray Cancel: only a pending request is cancelled.
	if (it == g_trades.end() || it->second.state != TradeState::Requested) return;
	if (it->second.a != s.account_id && it->second.b != s.account_id) return;
	CancelRequest(id, s.account_id);
}

void HandleAcceptTradeRequest(Session &s, Reader &r)
{
	r.U();
	const uint32_t id = r.U();
	if (r.bad) return;
	auto it = g_trades.find(id);
	if (it == g_trades.end() || it->second.state != TradeState::Requested || it->second.b != s.account_id) return;
	LiveTrade &t = it->second;
	Session *a = LobbySession(t.a);
	if (!a) { CancelRequest(id, t.a); return; }

	// 1. Any other pending request of either player goes first (the screen wipes the dialogs).
	std::vector<uint32_t> others;
	for (auto &kv : g_trades) {
		const LiveTrade &o = kv.second;
		if (o.id != id && o.state == TradeState::Requested && (o.a == t.a || o.b == t.a || o.a == t.b || o.b == t.b)) others.push_back(o.id);
	}
	for (uint32_t o : others) CancelRequest(o, 0);
	// 2. Closes A's waiting dialog.
	SendParties(t, TradeMsg(kStartTradeSync, 1, t.b, t.id).U(t.a));
	// 3. Each side sees what the other can trade.
	SendPartnerCollection(*a, t.b);
	SendPartnerCollection(s, t.a);
	// 4. Opens both trade screens.
	t.state = TradeState::Open;
	SendParties(t, TradeMsg(kAcceptTradeRequest, 1, t.b, t.id).U(t.a).U(t.lobby()));
	LogInfo("[LoN] [{}] accepted [{}]'s trade request (session [{}])", s.name, a->name, t.id);
}

LiveTrade *OpenTradeFor(Session &s, uint32_t id)
{
	auto it = g_trades.find(id);
	if (it == g_trades.end() || it->second.state == TradeState::Requested) return nullptr;
	if (it->second.a != s.account_id && it->second.b != s.account_id) return nullptr;
	return &it->second;
}

void HandleAddCardToTrade(Session &s, Reader &r)
{
	const uint32_t owner = r.U(), id = r.U(), arch = r.U(), card = r.U();
	r.U();
	if (r.bad) return;
	LiveTrade *t = OpenTradeFor(s, id);
	if (!t || t->state != TradeState::Open || (owner != t->a && owner != t->b)) return;
	auto c = database.QueryDatabase(fmt::format(
		"SELECT archetype, tradable FROM lon_card WHERE id = {} AND account_id = {}", card, owner));
	if (!c.Success() || c.RowCount() == 0 || ToU(c.begin()[0]) != arch || ToU(c.begin()[1]) != 1) {
		SendTradeErrorMsg(s, kTrErrNotTradable);
		return;
	}
	if (g_card_lock.count(card)) { SendTradeErrorMsg(s, kTrErrLocked); return; }
	std::vector<Inst> &side = owner == t->a ? t->a_cards : t->b_cards;
	if (side.size() >= kMaxCardsPerSide) { SendTradeErrorMsg(s, kTrErrTooMany); return; }
	side.push_back({arch, 0, card});
	g_card_lock.insert(card);
	SendParties(*t, TradeMsg(kAddCardToTrade, 1, owner, t->id).U(arch).U(card).U(s.account_id));
	ResetAccepts(*t);
}

void HandleRemoveCardFromTrade(Session &s, Reader &r, uint32_t ver)
{
	r.U();
	const uint32_t id = r.U(), arch = r.U(), card = r.U();
	const uint32_t owner = ver > 1 ? r.U() : 0;
	if (ver > 2) r.U();
	if (r.bad) return;
	LiveTrade *t = OpenTradeFor(s, id);
	if (!t || t->state != TradeState::Open || (owner != t->a && owner != t->b)) return;
	std::vector<Inst> &side = owner == t->a ? t->a_cards : t->b_cards;
	auto it = std::find_if(side.begin(), side.end(), [card](const Inst &i) { return i.number == card; });
	if (it == side.end()) return;
	side.erase(it);
	g_card_lock.erase(card);
	SendParties(*t, TradeMsg(kRemoveCardFromTrade, 3, s.account_id, t->id).U(arch).U(card).U(owner).U(0));
	ResetAccepts(*t);
}

void HandleClearTrade(Session &s, Reader &r)
{
	r.U();
	const uint32_t id = r.U();
	if (r.bad) return;
	LiveTrade *t = OpenTradeFor(s, id);
	if (!t) return;
	std::vector<Inst> &side = s.account_id == t->a ? t->a_cards : t->b_cards;
	for (const Inst &c : side) g_card_lock.erase(c.number);
	side.clear();
	const bool was_final = t->state == TradeState::Final;
	SendParties(*t, TradeMsg(kClearTrade, 1, s.account_id, t->id));
	if (was_final) ResetAccepts(*t);
	else { t->a_ok = t->b_ok = false; }
}

void CommitTrade(LiveTrade &t);

void HandleAcceptTrade(Session &s, Reader &r)
{
	r.U();
	const uint32_t id = r.U();
	const bool ok = r.U() != 0;
	if (r.bad) return;
	LiveTrade *t = OpenTradeFor(s, id);
	if (!t) return;
	if (!ok && t->state == TradeState::Final) { ResetAccepts(*t); return; }
	if (t->state != TradeState::Open) return;
	(s.account_id == t->a ? t->a_ok : t->b_ok) = ok;
	const uint32_t partner = s.account_id == t->a ? t->b : t->a;
	if (Session *p = LobbySession(partner)) Send(*p, TradeMsg(kAcceptTrade, 1, s.account_id, t->id).U(ok ? 1 : 0));
	if (!(t->a_ok && t->b_ok) || (t->a_cards.empty() && t->b_cards.empty())) return;

	// Both accepted: lock, then the confirm window with A's and B's cards.
	t->state = TradeState::Final;
	for (uint32_t acct : {t->a, t->b}) {
		Session *p = LobbySession(acct);
		if (!p) continue;
		Send(*p, TradeMsg(kLockTrade, 1, acct, t->id).U(1));
		Writer w = TradeMsg(kSetupFinalTrade, 2, acct, t->id);
		w.U(static_cast<uint32_t>(t->a_cards.size()));
		for (const Inst &c : t->a_cards) w.Instance(c.arch, 0, c.number);
		w.U(static_cast<uint32_t>(t->b_cards.size()));
		for (const Inst &c : t->b_cards) w.Instance(c.arch, 0, c.number);
		Send(*p, w);
	}
}

void HandleFinalAcceptTrade(Session &s, Reader &r)
{
	r.U();
	const uint32_t id = r.U();
	const bool ok = r.U() != 0;
	if (r.bad) return;
	LiveTrade *t = OpenTradeFor(s, id);
	if (!t || t->state != TradeState::Final) return;   // a stray answer from a closed dialog
	if (!ok) { ResetAccepts(*t); return; }
	(s.account_id == t->a ? t->a_final : t->b_final) = true;
	if (t->a_final && t->b_final) CommitTrade(*t);
}

void CommitTrade(LiveTrade &t)
{
	auto move = [](const std::vector<Inst> &cards, uint32_t from, uint32_t to) {
		if (cards.empty()) return true;
		auto mv = database.QueryDatabase(fmt::format(
			"UPDATE lon_card SET account_id = {} WHERE id IN ({}) AND account_id = {} AND tradable = 1",
			to, IdList(cards), from));
		return mv.Success() && mv.RowsAffected() == cards.size();
	};
	bool ok = database.TransactionBegin().Success();
	ok = ok && move(t.a_cards, t.a, t.b) && move(t.b_cards, t.b, t.a);
	if (!ok || !database.TransactionCommit().Success()) {
		database.TransactionRollback();
		LogError("[LoN] live trade [{}] could not swap -- a card changed hands; back to open", t.id);
		for (uint32_t acct : {t.a, t.b}) {
			if (Session *p = LobbySession(acct)) {
				SendTradeErrorMsg(*p, 0, "The trade could not be completed: a card in it is no longer available. Check both offers and try again.");
			}
		}
		ResetAccepts(t);
		return;
	}
	const LiveTrade done = t;
	g_trades.erase(t.id);
	UnlockTrade(done);
	for (uint32_t acct : {done.a, done.b}) {
		Session *p = LobbySession(acct);
		if (!p) continue;
		const std::vector<Inst> &gave = acct == done.a ? done.a_cards : done.b_cards;
		const std::vector<Inst> &got  = acct == done.a ? done.b_cards : done.a_cards;
		if (!gave.empty()) Send(*p, RemoveInstances(gave));
		if (!got.empty()) {
			const uint32_t d = ++p->delivery;
			Send(*p, StartDelivery(d, got, false, "trade", static_cast<int32_t>(done.id)));
			Send(*p, Complete(d));
		}
		Send(*p, TradeMsg(kEndTradeSession, 1, acct, done.id));
	}
	LogInfo("[LoN] live trade [{}] done: [{}] card(s) one way, [{}] the other", done.id, done.a_cards.size(), done.b_cards.size());
}

void HandleEndTradeSession(Session &s, Reader &r)
{
	r.U();
	const uint32_t id = r.U();
	if (r.bad) return;
	if (OpenTradeFor(s, id)) AbortTrade(id, s.account_id);   // a finished or unknown session: ignore
}

// ---------------------------------------------------------------------------
// Casual PvP (research/lon_pvp_build_spec.md -- every message read in the client)
// ---------------------------------------------------------------------------
// Two players meet in Casual Games (a match room) or a tournament pairing. One of them hosts: world
// launches an ordinary network game on both clients, and the host's SetupGame
// carries the marker (Server ID 'NMSH', seat 1) on which our dinput8 turns that client's game into
// the authority. The guest is a stock replica. World only relays: every game command from one side
// goes to the other unchanged plus 4 zero bytes (a no-field command is unreadable without them, and
// an unreadable message jams the client's whole card-game stream). World never runs a rule, never
// rewrites a command and never builds one beyond the five classes below. No item prize ever (design
// decision: a second PC would farm it); the result goes to the Profile record, the rating and the Journal.
//
// Hard rules from the spec (each one an assert or a dead stream on the client):
// - GameID is never 0 (M = G = 2000000 + n); the teams are {1:1, 2:2} (same team = no winner);
// - guest first (LaunchGame, SetupGame seat 2), then host (LaunchGame, SetupGame seat 1 + marker,
//   SelectDeckForPlayer seat 1 then seat 2 -- decks only after SetupGame, and only to the host: the
//   master broadcasts both decks to the guest itself);
// - world-built game commands carry a TimeStamp of 2^28 or more (5 bytes; see Stamp);
// - a guest may only send seat 2's input; authority-only classes from it are dropped.
// Ends: concede / game over / end game seen in the stream (then 60 s of trailing relay); a side that
// disconnects or leaves the game screen first loses (RemovePlayer to the host / LostPlayer to the
// guest); 10 idle minutes = LostPlayer to both, no loser.
// Results: both clients' dinput8 report the ending (kPvPReport). Casual Games are unrated
// (live: "non-rated games"); only tournament games move a rating. A concede or a disconnect is a loss
// everywhere. Details at RecordPvPResult.
constexpr uint32_t kLaunchGame      = 0x11178;  // EQMatchCommand_LaunchGame v1, 5 levels
constexpr uint32_t kEQSetupGame     = 0x11177;  // EQGameCommand_SetupGame v12, 4 levels
constexpr uint32_t kSelectDeck      = 0x3A;     // GameCommand_SelectDeckForPlayer v2, 3
constexpr uint32_t kOutOfSync       = 0x40;
constexpr uint32_t kReadyForStart   = 0x75;
constexpr uint32_t kFatalError      = 0x84;
constexpr uint32_t kLostPlayer      = 0x8B;     // v2, 3
constexpr uint32_t kConcedeGame     = 0xA0;
constexpr uint32_t kAcceptAdjourn   = 0x107;
constexpr uint32_t kOfferAdjourn    = 0x108;
constexpr uint32_t kRemovePlayer    = 0x10B;    // v4, 3
constexpr uint32_t kGameOverReached = 0x17F;
constexpr uint32_t kEndGame         = 0x1D7;
constexpr uint32_t kHostMarker      = 0x4E4D5348;  // 'NMSH' in the host's SetupGame Server ID (dinput8 P1; must equal kPvPHostMarker in nms_lon_link.cpp)
constexpr uint32_t kGameVersion     = 1745;
constexpr uint32_t kPvPMatchBase    = 2000000;     // never 0, 3, -5 or a trade lobby id (1000000 + S)
constexpr uint32_t kPvPTrailSecs    = 60;
constexpr uint32_t kPvPIdleSecs     = 600;
// RemovePlayer loss type. 1 = the stock concede path. Never 2 (disconnect): it posts display action 0x45,
// which writes the turn-timer text that only exists when the game has a Duration (0x44) -- ours is 0,
// so the client writes through NULL and EQ crashes (observed crash in testing).
constexpr uint32_t kLossConcede     = 1;
constexpr size_t   kPvPMinDeckCards = 50;
// The result report both clients' dinput8 send at the end of a PvP game (P6/P7 in nms_lon_link.cpp): a
// class no client ever reads, version 1, one header level: MatchID, the reporter's seat, 1 lost / 2 won,
// the seat it names, the loss type, the game's turn number. It reaches world only (client -> world).
constexpr uint32_t kPvPReport       = 0x7F0;
constexpr uint32_t kModeCasual      = 1, kModeTournament = 2;   // lon_pvp_match.mode

// How a game ended: lon_pvp_match.end_type.
enum PvPEnd : uint32_t {
	kEndNone = 0, kEndAvatar, kEndDecked, kEndQuests, kEndConcede, kEndDisconnect, kEndNoShow,
	kEndTimeout, kEndError, kEndDisputed, kEndUnconfirmed,
	kEndNoReport,   // a tournament game with ONE report: the side that sent none stopped responding
};

const char *EndName(uint32_t e)
{
	switch (e) {
		case kEndAvatar:      return "avatar";
		case kEndDecked:      return "decked";
		case kEndQuests:      return "quests";
		case kEndConcede:     return "concede";
		case kEndDisconnect:  return "disconnect";
		case kEndNoShow:      return "noshow";
		case kEndTimeout:     return "timeout";
		case kEndError:       return "error";
		case kEndDisputed:    return "disputed";
		case kEndNoReport:    return "noreport";
		default:              return "unconfirmed";
	}
}

// Won or lost by the rules: the only endings that pay the Journal.
bool RulesEnd(uint32_t e) { return e == kEndAvatar || e == kEndDecked || e == kEndQuests; }
// An ending with a winner and a loser (the Profile record counts it).
bool DecidedEnd(uint32_t e)
{
	return RulesEnd(e) || e == kEndConcede || e == kEndDisconnect || e == kEndNoShow || e == kEndNoReport;
}
// A tournament game that was played but has no clear result: its pairing is played again once.
bool ReplayEnd(uint32_t e)
{
	return e == kEndTimeout || e == kEndError || e == kEndDisputed || e == kEndUnconfirmed;
}

// The client's loss types (end text 0x102657B0): 0x11175 avatar killed, 0x11176 out of cards, 0x11177
// quests, 1 / 3 / 4 concede. 2 (timed out) cannot happen with Duration 0.
uint32_t EndOfLossType(uint32_t loss)
{
	switch (loss) {
		case 0x11175: return kEndAvatar;
		case 0x11176: return kEndDecked;
		case 0x11177: return kEndQuests;
		case 1: case 3: case 4: return kEndConcede;
		default: return kEndUnconfirmed;
	}
}

// Every GameCommand class in the client's catalog.
bool IsGameCommand(uint32_t op)
{
	if (op >= 0x38 && op <= 0x49) return true;
	switch (op) {
		case 0x75: case 0x80: case 0x82: case 0x84: case 0x8B: case 0x8C: case 0x90: case 0x9E:
		case 0xA0: case 0xA1: case 0xA2: case 0xA5: case 0x106: case 0x107: case 0x108: case 0x10B:
		case 0x134: case 0x13A: case 0x140: case 0x142: case 0x145: case 0x146: case 0x17F: case 0x1D7:
			return true;
		default:
			return false;
	}
}

// Classes only the master sends; a guest sending one is dropped.
bool AuthorityOnly(uint32_t op)
{
	switch (op) {
		case 0x38: case 0x3A: case 0x41: case 0x42: case 0x43: case 0x44: case 0x45: case 0x49:
		case 0x80: case 0x82: case 0x8B: case 0x8C: case 0x90: case 0x106: case 0x10B: case 0x134:
		case 0x17F: case 0x1D7:
			return true;
		default:
			return false;
	}
}

struct PvPDeck {
	std::vector<uint8_t> bytes;   // the EQDeck object as the client stored it
	std::string          name;
	std::string          key;     // its id string (SelectDeckForPlayer "Deck ID")
};

struct PvPReportData {
	bool     have = false;
	uint32_t loser = 0, loss = 0, turns = 0;   // the seat that lost, its loss type, the game's turn number
};

struct PvPMatch {
	uint32_t      id = 0;                  // M = G
	uint32_t      host = 0, guest = 0;     // accounts: seat 1 (the authority), seat 2
	std::string   host_name, guest_name, host_ip, guest_ip;
	uint32_t      mode = kModeCasual;
	uint32_t      tourn = 0;               // a tournament game: the tournament's group T
	bool          ended = false;
	bool          host_left = false, guest_left = false;
	uint32_t      started_at = 0, last_traffic = 0, ended_at = 0;
	uint32_t      to_guest = 0, to_host = 0, dropped = 0;
	PvPReportData rep[3];                  // by the reporter's seat: [1] host, [2] guest
	uint32_t      world_end = kEndNone;    // what world saw itself (a concede in the stream, a disconnect...)
	uint32_t      world_loser = 0;         // ... and the seat that lost it, 0 = nobody
	uint32_t      gone_seat = 0;           // a seat whose client disconnected after the end, before reporting
	bool          resolved = false;        // the result is written
};

std::map<uint32_t, PvPMatch> g_matches;
uint32_t                     g_next_match = 1;

uint32_t PvPNow() { return static_cast<uint32_t>(time(nullptr)); }

// A world-built GameCommand's TimeStamp: the client's int64 reader needs 4 bytes left, so the low
// word must be a 5-byte varint (2^28 or more).
uint32_t Stamp() { return std::max<uint32_t>(PvPNow(), 1u << 28); }

Session *MatchSession(uint32_t account, uint32_t match)
{
	for (auto &kv : g_sessions) {
		Session &o = *kv.second;
		if (o.account_id == account && o.pvp_match == match) return &o;
	}
	return nullptr;
}

PvPMatch *MatchOf(uint32_t account)
{
	for (auto &kv : g_matches) {
		const PvPMatch &m = kv.second;
		if (m.host == account || m.guest == account) return &kv.second;
	}
	return nullptr;
}

// One line to a player, always in the EverQuest chat window. Never a card-game whisper: a whisper
// whose sender is the receiver leaves the client's [*listener*] slot empty and the card game aborts
// (observed crash in testing); whispers between two players are unproven as well.
void PvPTell(Session &to, const std::string &text)
{
	TellCharacter(to, text);
}

std::string TrimSpaces(const std::string &s)
{
	const size_t a = s.find_first_not_of(" \t\r\n");
	const size_t b = s.find_last_not_of(" \t\r\n");
	return a == std::string::npos ? std::string() : s.substr(a, b - a + 1);
}

// The decks the account can pick, as its Select Deck list shows them (SendDecks): saved decks newest
// first, then the starter decks of the starter products it opened.
std::vector<PvPDeck> PvPDecks(uint32_t account)
{
	std::vector<PvPDeck> out;
	std::set<std::string> names;
	auto r = database.QueryDatabase(fmt::format("SELECT HEX(deck) FROM lon_deck WHERE account_id = {} ORDER BY id DESC", account));
	if (r.Success()) {
		for (auto row : r) {
			PvPDeck d;
			d.bytes = Unhex(row[0]);
			d.name  = DeckName(d.bytes, &d.key);
			if (d.name.empty() || names.count(d.name)) continue;
			names.insert(d.name);
			out.push_back(d);
		}
	}
	auto o = database.QueryDatabase(fmt::format(
		"SELECT DISTINCT source FROM lon_card WHERE account_id = {} AND source LIKE 'starter:%' ORDER BY source", account));
	if (o.Success()) {
		for (auto row : o) {
			auto it = g_data.product_deck.find(ToU(row[0] + 8));
			if (it == g_data.product_deck.end()) continue;
			PvPDeck d;
			d.bytes = it->second;
			d.name  = DeckName(d.bytes, &d.key);
			if (d.name.empty() || names.count(d.name)) continue;
			names.insert(d.name);
			out.push_back(d);
		}
	}
	return out;
}

// Empty = playable: a full card list, every copy owned by the account (the client checks neither).
std::string DeckProblem(uint32_t account, const PvPDeck &d)
{
	const std::vector<uint32_t> cards = DeckCards(d.bytes);
	if (cards.size() < kPvPMinDeckCards) {
		return fmt::format("{} cannot be used: it needs at least {} cards.", d.name, kPvPMinDeckCards);
	}
	std::map<uint32_t, uint32_t> need;
	for (uint32_t c : cards) ++need[c];
	std::string list;
	for (auto &kv : need) list += (list.empty() ? "" : ",") + std::to_string(kv.first);
	std::map<uint32_t, uint32_t> have;
	auto r = database.QueryDatabase(fmt::format(
		"SELECT archetype, COUNT(*) FROM lon_card WHERE account_id = {} AND archetype IN ({}) GROUP BY archetype", account, list));
	if (r.Success()) for (auto row : r) have[ToU(row[0])] = ToU(row[1]);
	for (auto &kv : need) {
		if (have[kv.first] >= kv.second) continue;
		auto ci = g_data.cards.find(kv.first);
		const std::string card = ci != g_data.cards.end() && !ci->second.name.empty() ? ci->second.name : fmt::format("card {}", kv.first);
		return fmt::format("{} cannot be used: you own {} of the {} copies of {} it holds.", d.name, have[kv.first], kv.second, card);
	}
	return "";
}

// The named deck (any case), else the account's newest saved deck, else its first starter deck.
// Returns the reason it cannot be played, empty on success.
std::string ResolveDeck(uint32_t account, const std::string &name, PvPDeck &out)
{
	const std::vector<PvPDeck> decks = PvPDecks(account);
	if (decks.empty()) return "You have no decks. Open a starter deck or build one first.";
	const PvPDeck *pick = &decks.front();
	if (!name.empty()) {
		pick = nullptr;
		for (const PvPDeck &d : decks) if (Strings::EqualFold(d.name, name)) { pick = &d; break; }
		if (!pick) return fmt::format("You have no deck named \"{}\".", name);
	}
	const std::string why = DeckProblem(account, *pick);
	if (why.empty()) out = *pick;
	return why;
}

Writer LaunchGame(uint32_t account, uint32_t match)
{
	Writer w;
	w.Header(kLaunchGame, 1, 5).U(account).U(match);
	return w;
}

// EQGameCommand_SetupGame v12 (spec 2.3, field by field). seat 1 carries the host marker.
Writer SetupGame(const PvPMatch &m, uint32_t seat, uint32_t ts)
{
	Writer w;
	w.Header(kEQSetupGame, 12, 4)
		.U(seat).U(m.id).U(ts).U(0)        // PlayerID, GameID, TimeStamp low / high
		.U(0)                              // the command's element map: empty
		.U(m.id)                           // GameID again (the base read)
		.U(1)                              // Game Server ID
		.U(seat == 1 ? kHostMarker : 0)    // Server ID: our marker on the host only
		.U(2)                              // Player Count
		.U(2).U(1).U(2)                    // Player Order Data
		.U(2).U(m.host).U(m.guest)         // Ordered Account IDs (seat 1, seat 2)
		.U(kGameVersion).U(m.id)           // GameVersion, MatchID
		.U(0).U(1).U(0).U(0).U(0)          // Duration (no timer), GameType 1, PlayType, ExtraFormatFlag, GameNum
		.U(0).U(0)                         // pairs vector, LeagueID
		.U(1).U(0)                         // MatchStructure (a loss ends the game), EQ int
		.U(2).U(1).U(1).U(2).U(1)          // positions {1:1, 2:1}
		.U(2).U(1).U(1).U(2).U(2);         // teams {1:1, 2:2} -- required, else nobody can win
	return w;
}

// GameCommand_SelectDeckForPlayer v2: base fields, Deck ID, nullable EQDeck (present).
Writer SelectDeck(const PvPMatch &m, uint32_t seat, const PvPDeck &deck, uint32_t ts)
{
	Writer w;
	w.Header(kSelectDeck, 2, 3).U(seat).U(m.id).U(ts).U(0).U(0).S(deck.key).U(0);
	w.Raw(deck.bytes.data(), deck.bytes.size());
	return w;
}

// GameCommand_RemovePlayer v4 to the host: PlayerID carries the leaver's ACCOUNT id.
Writer RemovePlayer(const PvPMatch &m, uint32_t account)
{
	Writer w;
	w.Header(kRemovePlayer, 4, 3).U(account).U(m.id).U(Stamp()).U(0).U(0).U(kLossConcede);
	return w;
}

// GameCommand_LostPlayer v2: "Lost connection to <name>" -- shows a line, changes no game state.
Writer LostPlayer(const PvPMatch &m, uint32_t seat, uint32_t account)
{
	Writer w;
	w.Header(kLostPlayer, 2, 3).U(seat).U(m.id).U(Stamp()).U(0).U(0).U(account);
	return w;
}

void ResolvePvP(PvPMatch &m, bool final);   // results, below

void ClosePvP(uint32_t id, const std::string &why)
{
	auto it = g_matches.find(id);
	if (it == g_matches.end()) return;
	ResolvePvP(it->second, true);   // whatever is known now is the result
	it = g_matches.find(id);        // (the result may start nothing, but never trust an old iterator)
	if (it == g_matches.end()) return;
	const PvPMatch m = it->second;
	g_matches.erase(it);
	for (auto &kv : g_sessions) if (kv.second->pvp_match == id) kv.second->pvp_match = 0;
	LogInfo("[LoN] PvP [{}] closed ({}): [{}] frame(s) to the guest, [{}] to the host, [{}] dropped",
		id, why, m.to_guest, m.to_host, m.dropped);
	CasualGameOver(id);   // a Casual Games match: off every list
}

void EndPvP(PvPMatch &m, const std::string &result)
{
	if (m.ended) return;
	m.ended    = true;
	m.ended_at = PvPNow();
	LogInfo("[LoN] PvP [{}] [{}] vs [{}] ended: {}", m.id, m.host_name, m.guest_name, result);
}

// An ending world saw itself (a concede in the stream, a disconnect, an idle game, a fatal error). The
// first ending wins: after a reported end, a later disconnect is not the result.
void PvPWorldEnd(PvPMatch &m, uint32_t end, uint32_t loser_seat, const std::string &result)
{
	if (!m.ended && m.world_end == kEndNone) {
		m.world_end   = end;
		m.world_loser = loser_seat;
	}
	EndPvP(m, result);
}

// A side left before the game ended (disconnect, game screen closed): it loses.
void AbandonPvP(uint32_t id, bool host_side, const std::string &how)
{
	auto it = g_matches.find(id);
	if (it == g_matches.end()) return;
	PvPMatch &m = it->second;
	const std::string leaver = host_side ? m.host_name : m.guest_name;
	const uint32_t seat = host_side ? 1 : 2;
	if (!m.ended) {
		if (host_side) {
			// The guest has no authority left: a state-free notice; it leaves through its game menu.
			if (Session *g = MatchSession(m.guest, m.id)) {
				Send(*g, LostPlayer(m, 1, m.host));
				PvPTell(*g, fmt::format("{} {} -- the game cannot go on. Leave it from the game menu.", leaver, how));
			}
		}
		else if (Session *h = MatchSession(m.host, m.id)) {
			Send(*h, RemovePlayer(m, m.guest));   // the host wins normally
			PvPTell(*h, fmt::format("{} {} -- you win.", leaver, how));
		}
		PvPWorldEnd(m, kEndDisconnect, seat, fmt::format("{} {} (loses)", leaver, how));
	}
	else if (!m.rep[seat].have && !m.gone_seat) {
		m.gone_seat = seat;   // gone right after the end without its own report (report + disconnect)
	}
	ClosePvP(id, fmt::format("{} {}", leaver, how));
}

void PvPSessionGone(Session &s)
{
	if (!s.pvp_match || !s.account_id) return;
	auto it = g_matches.find(s.pvp_match);
	if (it == g_matches.end()) return;
	AbandonPvP(it->first, s.account_id == it->second.host, "disconnected");
}

// Leave(M) or Join(3) from a player of a match: they are off the game screen.
void PvPLeftScreen(Session &s)
{
	s.game_screen = 0;
	if (!s.pvp_match) return;
	auto it = g_matches.find(s.pvp_match);
	if (it == g_matches.end()) { s.pvp_match = 0; return; }
	PvPMatch &m = it->second;
	const bool host_side = s.account_id == m.host;
	if (!m.ended) { AbandonPvP(m.id, host_side, "left the game"); return; }
	(host_side ? m.host_left : m.guest_left) = true;
	s.pvp_match = 0;
	if (m.host_left && m.guest_left) ClosePvP(m.id, "both players left the game screen");
}

// Every GameCommand a client sends. data/len = the command bytes (the 12-byte preamble stripped).
void HandlePvPFrame(Session &s, const uint8_t *data, size_t len)
{
	Reader r(data, len);
	const uint32_t cls = r.U(), ver = r.U();
	for (int i = 0; i < 8; ++i) {
		const size_t save = r.p;
		const uint32_t a = r.U(), b = r.U();
		if (r.bad || a != cls || b != ver) { r.p = save; r.bad = false; break; }
	}
	const uint32_t player = r.U(), game = r.U();
	auto it = s.pvp_match ? g_matches.find(s.pvp_match) : g_matches.end();
	if (r.bad || it == g_matches.end() || game != it->second.id) {
		LogInfo("[LoN] PvP drop: [{}] sent class [{:#x}] PlayerID [{}] GameID [{}] ([{}] bytes) -- {}",
			s.name, cls, player, game, len, r.bad ? "unreadable" : it == g_matches.end() ? "no match" : "wrong GameID");
		if (it != g_matches.end()) ++it->second.dropped;
		return;
	}
	PvPMatch &m = it->second;
	const bool from_host = s.account_id == m.host;
	m.last_traffic = PvPNow();

	if (cls == kFatalError) {
		LogInfo("[LoN] PvP [{}] FatalError from [{}] -- aborting", m.id, s.name);
		const uint32_t id = m.id;
		if (Session *h = MatchSession(m.host, id)) { Send(*h, LostPlayer(m, 2, m.guest)); PvPTell(*h, "The card game hit an error -- the match was stopped."); }
		if (Session *g = MatchSession(m.guest, id)) { Send(*g, LostPlayer(m, 1, m.host)); PvPTell(*g, "The card game hit an error -- the match was stopped."); }
		PvPWorldEnd(m, kEndError, 0, "fatal error");
		ClosePvP(id, "fatal error");
		return;
	}

	if (from_host) {
		if (cls == kConcedeGame && (player == 1 || player == 2)) PvPWorldEnd(m, kEndConcede, player, fmt::format("seat {} conceded", player));
		if (cls == kGameOverReached || cls == kEndGame) EndPvP(m, fmt::format("game over (class [{:#x}] from the host)", cls));
		Session *g = MatchSession(m.guest, m.id);
		if (!g) { ++m.dropped; return; }
		Writer w;
		static const uint8_t kPad[4] = {0, 0, 0, 0};
		w.Raw(data, len).Raw(kPad, sizeof(kPad));
		Send(*g, w);
		++m.to_guest;
		LogInfo("[LoN] PvP [{}] host -> guest: class [{:#x}] PlayerID [{}] [{}] bytes", m.id, cls, player, len);
		return;
	}

	// From the guest: seat 2's own input only.
	const char *drop = nullptr;
	if (player != 2) drop = "not seat 2";
	else if (cls == kReadyForStart || cls == kOutOfSync) drop = "replica-only";
	else if (cls == kAcceptAdjourn || cls == kOfferAdjourn) drop = "adjournment unsupported";
	else if (AuthorityOnly(cls)) drop = "authority-only class";
	if (drop) {
		++m.dropped;
		LogInfo("[LoN] PvP [{}] drop from guest [{}]: class [{:#x}] PlayerID [{}] [{}] bytes -- {}", m.id, s.name, cls, player, len, drop);
		return;
	}
	if (cls == kConcedeGame) PvPWorldEnd(m, kEndConcede, 2, "seat 2 conceded");
	Session *h = MatchSession(m.host, m.id);
	if (!h) { ++m.dropped; return; }
	Writer w;
	static const uint8_t kPad[4] = {0, 0, 0, 0};
	w.Raw(data, len).Raw(kPad, sizeof(kPad));
	Send(*h, w);
	++m.to_host;
	LogInfo("[LoN] PvP [{}] guest -> host: class [{:#x}] [{}] bytes", m.id, cls, len);
}

// Launches a match: a Casual Games match M or a tournament pairing (match_id from the same counter).
// mode / tourn: lon_pvp_match.mode and the tournament's group T (0 for a casual game).
void StartPvP(Session &host, Session &guest, const PvPDeck &host_deck, const PvPDeck &guest_deck,
	uint32_t match_id, uint32_t mode, uint32_t tourn)
{
	PvPMatch m;
	m.id           = match_id;
	m.host         = host.account_id;
	m.guest        = guest.account_id;
	m.host_name    = host.name;
	m.guest_name   = guest.name;
	m.host_ip      = host.ip;
	m.guest_ip     = guest.ip;
	m.mode         = mode;
	m.tourn        = tourn;
	m.started_at   = PvPNow();
	m.last_traffic = m.started_at;
	host.pvp_match  = m.id;
	guest.pvp_match = m.id;
	host.game_screen  = m.id;
	guest.game_screen = m.id;
	g_matches[m.id] = m;

	const uint32_t ts = Stamp();
	// The guest first: its game and current turn exist before any master traffic reaches it.
	Send(guest, LaunchGame(guest.account_id, m.id));
	Send(guest, SetupGame(m, 2, ts));
	Send(host, LaunchGame(host.account_id, m.id));
	Send(host, SetupGame(m, 1, ts));
	Send(host, SelectDeck(m, 1, host_deck, ts));
	Send(host, SelectDeck(m, 2, guest_deck, ts));
	LogInfo("[LoN] PvP [{}] started ({}): host [{}] (account [{}], deck [{}]) vs guest [{}] (account [{}], deck [{}])",
		m.id, mode == kModeTournament ? "tournament" : "casual", m.host_name, m.host, host_deck.name,
		m.guest_name, m.guest, guest_deck.name);
}

// From Process(): trailing time after the end, idle games.
void ProcessPvP()
{
	const uint32_t now = PvPNow();
	std::vector<std::pair<uint32_t, std::string>> close;
	for (auto &kv : g_matches) {
		PvPMatch &m = kv.second;
		if (m.ended && now - m.ended_at >= kPvPTrailSecs) {
			close.push_back({m.id, "ended"});
		}
		else if (!m.ended && now - m.last_traffic >= kPvPIdleSecs) {
			// No loser is guessed: each side is told the other is gone.
			if (Session *h = MatchSession(m.host, m.id)) { Send(*h, LostPlayer(m, 2, m.guest)); PvPTell(*h, "Your card game timed out (10 minutes without a move)."); }
			if (Session *g = MatchSession(m.guest, m.id)) { Send(*g, LostPlayer(m, 1, m.host)); PvPTell(*g, "Your card game timed out (10 minutes without a move)."); }
			PvPWorldEnd(m, kEndTimeout, 0, "timeout");
			close.push_back({m.id, "timeout"});
		}
	}
	for (auto &c : close) ClosePvP(c.first, c.second);
}

// ---------------------------------------------------------------------------
// PvP results: record, rating, Journal
// ---------------------------------------------------------------------------
// lon_pvp_match keeps every game (a website leaderboard can read it); lon_pvp_stats keeps each
// account's record and its tournament rating (Elo; Custom:LoNRating*). Rules (as live:
// Casual Games = "non-rated games", Tournaments = "Compete to increase your ratings"):
// - a result needs both reports agreeing, or what world saw itself (a concede in the stream, a
//   disconnect), or one report naming as loser a side that disconnected before reporting; in a
//   TOURNAMENT one report also stands on its own (the side that sent none stopped responding: noreport);
// - the Profile record counts every game with a winner (concedes, disconnects, no-shows too) -- a
//   concede or a disconnect is always the leaver's loss;
// - CASUAL games never move a rating. They pay the Journal (72 winner, 73 loser) only when won by
//   questing, avatar defeat or decking, after Custom:LoNMinScenarioTurns turns and Custom:LoNPvPMinSeconds
//   seconds ("counted" = 1 then);
// - TOURNAMENT games move the tournament rating, both sides by the same Elo step: a game won by the rules
//   (same length minimums), and -- with Custom:LoNConcedeLosesRating on -- a concede, a disconnect or a
//   missing report (no length minimum: conceding a lost game must not dodge the loss, and the pairing was
//   drawn by world, not chosen, so the winner gains normally). Journal 74 only for a game won by the
//   rules. A forfeit before the game (noshow) is record only. Tournament advancement does not depend on
//   any of this: the winner of every decided game goes through (TournGameOver);
// - no rating or Journal at all between two accounts on the same address, nor after
//   Custom:LoNRatingPairDailyGames counted games of the same mode against the same opponent in 24 hours.
// - a TOURNAMENT game played with no clear result (idle timeout, fatal error, reports that disagree, no
//   report at all) is replayed once; a second one puts both players out. An idle timeout is not pinned
//   on one side: world never reads the game state, so it cannot tell whose turn stood still.
void TournGameOver(uint32_t tourn, uint32_t a, uint32_t b, uint32_t winner, uint32_t end);   // tournaments, below

// A logged-in card-game session of the account (the one with a character name), or nullptr.
Session *AccountSession(uint32_t account)
{
	Session *any = nullptr;
	for (auto &kv : g_sessions) {
		Session &o = *kv.second;
		if (o.account_id != account) continue;
		if (o.lobby_group || o.pvp_match || o.room || o.queue) return &o;
		if (!any) any = &o;
	}
	return any;
}

// The Journal entry, live (toast + Loremaster) when the player is online, else only stored.
void AwardAccount(uint32_t account, int id)
{
	if (Session *s = AccountSession(account)) {
		Award(*s, id, true);
		FlushLore(*s);
		return;
	}
	const AchievementDef *a = FindAchievement(id);
	if (!a) return;
	database.QueryDatabase(fmt::format(
		"INSERT IGNORE INTO lon_achievement (account_id, achievement_id, xp) VALUES ({}, {}, {})", account, id, a->xp));
}

// Profile refresh: IntroduceAccount with only the PvP keys (the client merges key by key, lon_achievements.md 3).
void SendPvPStats(Session &to, uint32_t account, const std::string &name)
{
	Writer ia;
	ia.Header(kIntroduceAccount, 1, 2).U(account).S(name)
		.U(0).Header(kPropertySet, 1, 1).U(kPvPPropCount);
	WritePvPProps(ia, LoadPvPStats(account));
	ia.U(0);   // gender
	Send(to, ia);
}

void EnsureStats(uint32_t account, const std::string &name)
{
	const int start = RuleI(Custom, LoNRatingStart);
	database.QueryDatabase(fmt::format(
		"INSERT IGNORE INTO lon_pvp_stats (account_id, char_name, rating_casual, rating_tournament) VALUES ({}, '{}', {}, {})",
		account, Strings::Escape(name), start, start));
	database.QueryDatabase(fmt::format(
		"UPDATE lon_pvp_stats SET char_name = '{}', last_played = NOW() WHERE account_id = {}", Strings::Escape(name), account));
}

// Rated TOURNAMENT games and their different opponents, then "ranked" (the leaderboard's entry rule,
// Custom:LoNRanked*). Casual games are unrated and never count here.
void RefreshRanked(uint32_t account)
{
	database.QueryDatabase(fmt::format(
		"UPDATE lon_pvp_stats SET "
		"games = (SELECT COUNT(*) FROM lon_pvp_match WHERE counted = 1 AND mode = {1} AND (host_account = {0} OR guest_account = {0})), "
		"opponents = (SELECT COUNT(DISTINCT IF(host_account = {0}, guest_account, host_account)) FROM lon_pvp_match "
		"WHERE counted = 1 AND mode = {1} AND (host_account = {0} OR guest_account = {0})) WHERE account_id = {0}",
		account, kModeTournament));
	database.QueryDatabase(fmt::format(
		"UPDATE lon_pvp_stats SET ranked = IF(games >= {} AND opponents >= {}, 1, 0) WHERE account_id = {}",
		std::max(0, RuleI(Custom, LoNRankedMinGames)), std::max(0, RuleI(Custom, LoNRankedMinOpponents)), account));
}

// Counted games of one mode between the two accounts in the last 24 hours (either seat).
uint32_t PairGamesToday(uint32_t a, uint32_t b, uint32_t mode)
{
	auto r = database.QueryDatabase(fmt::format(
		"SELECT COUNT(*) FROM lon_pvp_match WHERE counted = 1 AND mode = {2} AND ended_at > NOW() - INTERVAL 1 DAY AND "
		"((host_account = {0} AND guest_account = {1}) OR (host_account = {1} AND guest_account = {0}))", a, b, mode));
	return (r.Success() && r.RowCount()) ? ToU(r.begin()[0]) : 0;
}

const char *EndWords(uint32_t end)
{
	switch (end) {
		case kEndAvatar:     return "by avatar defeat";
		case kEndDecked:     return "by decking";
		case kEndQuests:     return "by questing";
		case kEndConcede:    return "by concession";
		case kEndDisconnect: return "because the other player left";
		case kEndNoShow:     return "by forfeit";
		case kEndNoReport:   return "on the only result report sent";
		default:             return "";
	}
}

void RecordPvPResult(PvPMatch &m, uint32_t end, uint32_t loser_seat, uint32_t loss)
{
	const uint32_t now     = PvPNow();
	const bool     decided = DecidedEnd(end) && (loser_seat == 1 || loser_seat == 2);
	const uint32_t loser   = decided ? (loser_seat == 1 ? m.host : m.guest) : 0;
	const uint32_t winner  = decided ? (loser_seat == 1 ? m.guest : m.host) : 0;
	const bool     tourn   = m.mode == kModeTournament;
	uint32_t turns = 0;
	if (m.rep[1].have && m.rep[2].have) turns = std::min(m.rep[1].turns, m.rep[2].turns);
	else if (m.rep[1].have) turns = m.rep[1].turns;
	else if (m.rep[2].have) turns = m.rep[2].turns;
	const uint32_t ended = m.ended_at ? m.ended_at : now;
	const uint32_t secs  = m.started_at && ended > m.started_at ? ended - m.started_at : 0;

	// counted = the game passed every anti-farm rule for its mode: a tournament game then moves the rating
	// (both sides, one Elo step), a casual game then pays the Journal. Casual games never move a rating.
	bool counted = false;
	std::string reason;
	if (!decided) reason = "no result";
	else if (m.host_ip.empty() || m.guest_ip.empty() || m.host_ip == m.guest_ip) reason = "same address";
	else if (end == kEndNoShow) reason = "forfeit, no game played";
	else if (RulesEnd(end)) {
		const uint32_t min_turns = static_cast<uint32_t>(std::max(0, RuleI(Custom, LoNMinScenarioTurns)));
		const uint32_t min_secs  = static_cast<uint32_t>(std::max(0, RuleI(Custom, LoNPvPMinSeconds)));
		if (turns < min_turns)     reason = fmt::format("too short ({} turns)", turns);
		else if (secs < min_secs)  reason = fmt::format("too short ({} seconds)", secs);
		else { counted = true; reason = tourn ? "rated" : "casual: Journal, no rating"; }
	}
	else if (!tourn) reason = "casual concede or disconnect: record only";
	else if (RuleB(Custom, LoNConcedeLosesRating)) { counted = true; reason = "rated (concede, disconnect or no report)"; }
	else reason = "concede, disconnect or no report: record only";
	if (counted &&
		PairGamesToday(m.host, m.guest, m.mode) >= static_cast<uint32_t>(std::max(0, RuleI(Custom, LoNRatingPairDailyGames)))) {
		counted = false;
		reason  = "daily limit against this opponent";
	}
	const bool rated = counted && tourn;

	// Elo on the tournament rating.
	int32_t delta = 0;
	if (decided) {
		EnsureStats(winner, loser_seat == 1 ? m.guest_name : m.host_name);
		EnsureStats(loser, loser_seat == 1 ? m.host_name : m.guest_name);
		if (rated) {
			const PvPStats w = LoadPvPStats(winner), l = LoadPvPStats(loser);
			const double rw = w.rating_tournament;
			const double rl = l.rating_tournament;
			const double expect = 1.0 / (1.0 + std::pow(10.0, (rl - rw) / 400.0));
			delta = std::max(1, static_cast<int32_t>(std::lround(std::max(1, RuleI(Custom, LoNRatingK)) * (1.0 - expect))));
		}
	}

	database.QueryDatabase(fmt::format(
		"INSERT INTO lon_pvp_match (game_id, mode, tournament_id, host_account, guest_account, host_name, guest_name, "
		"winner_account, loser_account, end_type, loss_type, turns, seconds, started_at, ended_at, counted, reason, rating_change) "
		"VALUES ({}, {}, {}, {}, {}, '{}', '{}', {}, {}, '{}', {}, {}, {}, FROM_UNIXTIME({}), FROM_UNIXTIME({}), {}, '{}', {})",
		m.id, m.mode, tourn ? m.tourn : 0, m.host, m.guest, Strings::Escape(m.host_name), Strings::Escape(m.guest_name),
		winner, loser, EndName(end), loss, turns, secs, m.started_at ? m.started_at : ended, ended, counted ? 1 : 0,
		Strings::Escape(reason), rated ? delta : 0));

	if (decided) {
		const char *w_col = tourn ? "tourn_wins" : "casual_wins";
		const char *l_col = tourn ? "tourn_losses" : "casual_losses";
		database.QueryDatabase(fmt::format(
			"UPDATE lon_pvp_stats SET {0} = {0} + 1, rating_tournament = rating_tournament + {1} WHERE account_id = {2}",
			w_col, rated ? delta : 0, winner));
		database.QueryDatabase(fmt::format(
			"UPDATE lon_pvp_stats SET {0} = {0} + 1, rating_tournament = GREATEST(100, rating_tournament - {1}) WHERE account_id = {2}",
			l_col, rated ? delta : 0, loser));
		RefreshRanked(winner);
		RefreshRanked(loser);
		RefreshHomeBoard(nullptr);   // every home screen, when the top rows changed
	}
	LogInfo("[LoN] PvP [{}] ({}) result: {} -- winner [{}] loser [{}] ({} turns, {} s), {} (rating {})",
		m.id, tourn ? "tournament" : "casual", EndName(end), winner, loser, turns, secs, reason, rated ? delta : 0);

	// Journal: only a counted game decided by the rules.
	if (counted && RulesEnd(end)) {
		if (tourn) AwardAccount(winner, 74);
		else {
			AwardAccount(winner, 72);
			AwardAccount(loser, 73);
		}
	}

	// Both Profiles (each player's client knows the other: they just played), and a line in EQ chat.
	for (int seat = 1; seat <= 2; ++seat) {
		Session *s = AccountSession(seat == 1 ? m.host : m.guest);
		if (!s) continue;
		SendPvPStats(*s, m.host, m.host_name);
		SendPvPStats(*s, m.guest, m.guest_name);
		const std::string other = seat == 1 ? m.guest_name : m.host_name;
		std::string line;
		if (!decided) {
			line = fmt::format("Your card game against {} ended with no result.", other);
		}
		else if (!tourn) {
			line = fmt::format("You {} your casual card game against {} {}. Casual games are not rated.",
				s->account_id == winner ? "won" : "lost", other, EndWords(end));
		}
		else {
			const PvPStats st = LoadPvPStats(s->account_id);
			const bool won = s->account_id == winner;
			const int32_t change = rated ? (won ? delta : -delta) : 0;
			line = fmt::format("You {} your tournament card game against {} {}. Tournament rating: {} ({}{}).",
				won ? "won" : "lost", other, EndWords(end), st.rating_tournament, change >= 0 ? "+" : "", change);
			if (!rated) line += fmt::format(" Not rated: {}.", reason);
		}
		TellCharacter(*s, line);
	}

	if (tourn) TournGameOver(m.tourn, m.host, m.guest, winner, end);
}

// Decides the result from what is known. Not final: only when both reports are in. Final (the match is
// closing): whatever is known now.
void ResolvePvP(PvPMatch &m, bool final)
{
	if (m.resolved) return;
	const PvPReportData &h = m.rep[1], &g = m.rep[2];
	const bool both  = h.have && g.have;
	const bool agree = both && h.loser == g.loser && EndOfLossType(h.loss) == EndOfLossType(g.loss) &&
	                   EndOfLossType(h.loss) != kEndUnconfirmed;
	if (!agree && !both && !final) return;   // wait for the other report, or for the close
	uint32_t end = kEndUnconfirmed, loser = 0, loss = 0;
	if (agree) {
		end   = EndOfLossType(h.loss);
		loser = h.loser;
		loss  = h.loss;
	}
	else if (m.world_end != kEndNone) {
		end   = m.world_end;
		loser = m.world_loser;
		loss  = end == kEndConcede ? 1 : 0;
	}
	else if (both && h.loser == g.loser && (h.loser == 1 || h.loser == 2)) {
		// Both name the same loser and differ only in how: the loser's own word on how it lost (it speaks
		// against itself), else the winner's. Neither readable = no clear result.
		const PvPReportData &own = m.rep[h.loser], &other = m.rep[3 - h.loser];
		const PvPReportData *use = EndOfLossType(own.loss) != kEndUnconfirmed ? &own
			: EndOfLossType(other.loss) != kEndUnconfirmed ? &other : nullptr;
		if (use) {
			end   = EndOfLossType(use->loss);
			loser = h.loser;
			loss  = use->loss;
		}
		else end = kEndDisputed;
		LogInfo("[LoN] PvP [{}] both reports name seat {} as the loser, loss types differ ({:#x} / {:#x}): {}",
			m.id, h.loser, h.loss, g.loss, EndName(end));
	}
	else if (both) {
		end = kEndDisputed;
		LogInfo("[LoN] PvP [{}] reports disagree: host says seat {} lost ({:#x}), guest says seat {} lost ({:#x})",
			m.id, h.loser, h.loss, g.loser, g.loss);
	}
	else if ((h.have || g.have) && m.gone_seat &&
		(h.have ? h : g).loser == m.gone_seat && EndOfLossType((h.have ? h : g).loss) != kEndUnconfirmed) {
		// One report, and the other side disconnected before sending its own: the report stands when the
		// side that vanished is the one it names as the loser.
		const PvPReportData &one = h.have ? h : g;
		end   = EndOfLossType(one.loss);
		loser = one.loser;
		loss  = one.loss;
	}
	else if ((h.have || g.have) && m.mode == kModeTournament) {
		// A tournament game with ONE report at the close: the side that sent none stopped responding.
		// The report stands either way: naming the silent side, that side loses; naming its
		// own sender, the sender admits the loss. Rated as a concede (never the Journal): the silent side
		// confirmed nothing.
		const PvPReportData &one = h.have ? h : g;
		if (one.loser == 1 || one.loser == 2) {
			end   = kEndNoReport;
			loser = one.loser;
			loss  = one.loss;
		}
	}
	m.resolved = true;
	RecordPvPResult(m, end, loser, loss);
}

// The result report (kPvPReport) from one of the two clients.
void HandlePvPReport(Session &s, Reader &r)
{
	const uint32_t match = r.U(), local = r.U(), kind = r.U(), seat = r.U(), loss = r.U(), turns = r.U();
	if (r.bad) return;
	auto it = g_matches.find(match);
	if (it == g_matches.end()) {
		LogInfo("[LoN] [{}] result report for PvP [{}], which is not running -- ignored", s.name, match);
		return;
	}
	PvPMatch &m = it->second;
	const uint32_t mine = s.account_id == m.host ? 1 : s.account_id == m.guest ? 2 : 0;
	if (!mine || local != mine || (seat != 1 && seat != 2) || (kind != 1 && kind != 2)) {
		LogInfo("[LoN] [{}] bad result report for PvP [{}]: seat {} (theirs {}), kind {}, seat {} -- ignored",
			s.name, match, local, mine, kind, seat);
		return;
	}
	PvPReportData &rep = m.rep[mine];
	if (rep.have || m.resolved) return;   // the first one counts
	rep.have  = true;
	rep.loser = kind == 1 ? seat : 3 - seat;
	rep.loss  = loss;
	rep.turns = turns;
	LogInfo("[LoN] PvP [{}] [{}] (seat {}) reports: seat {} lost, loss type {:#x}, turn {}", m.id, s.name, mine, rep.loser, loss, turns);
	EndPvP(m, fmt::format("seat {} reported the end", mine));   // leaving the game screen now is no abandon
	ResolvePvP(m, false);
}

// ---------------------------------------------------------------------------
// Casual Games matches (research/lon_casual_games_spec.md sections 2-4 -- every field
// checked in the client's read functions)
// ---------------------------------------------------------------------------
// Create = the client's AddGroups with one Match (its options + the creator's whole deck). World
// gives it an id M from the PvP counter (never a lobby, a trade session or another game), lists a
// CLEANED Match to everyone in Casual Games, then sends the creator the Join echo that opens the
// match room. Join(M) from the list, Quick Join or the practice button seats a guest; its deck
// comes in MatchCommand_SelectDeck (practice joins send none: world picks a starter deck). Each
// seat's deck is kept here and checked like a !challenge deck (it parses, every copy owned).
// Hard rules (each one an assert, a crash or a dead card-game stream on the client):
// - the Match reaches a client BEFORE any Join echo for it: the room dereferences it unchecked;
// - a type-2 child of a lobby is only ever a real Match (class 0x68 v3, two header levels);
// - 0xFA5 is only ever an int list; the password, deck name, guild and the client's own flag keys
//   are never sent back; Duration 0, MatchStructure 1, 2 players, game type 1 always;
// - one AddGroups per client per match (a duplicate leaks), RemoveGroups only where it went;
// - MatchCommand_* have four header levels; SelectDeck is never echoed;
// - a refused create or join gets nothing on the card-game wire, only a line in EQ chat.
constexpr uint32_t kLobbyRemoveGroups = 0x5F;   // v1, 3 (read 0x101485D0: AccountID, int list)
constexpr uint32_t kMatchObject       = 0x68;   // v3, 2 (a plain object in AddGroups: no flag)
constexpr uint32_t kMatchSetReady     = 0x63;   // v1, 4 (both directions)
constexpr uint32_t kMatchSelectDeck   = 0x65;   // v2, 4 (client -> server only)
constexpr uint32_t kMatchSetState     = 0x7C;   // v1, 4 (read 0x101620E0: AccountID, MatchID, State)
constexpr uint32_t kMatchStarted      = 4;      // a state > 3 marks it started; joins are refused
constexpr uint32_t kEQDeck            = 0x11172; // an EQDeck object's class (two header levels)
constexpr uint32_t kRolePlayer        = 2;
constexpr uint32_t kMatchTypeID       = 2;
// Match options (general PropertySet keys, Lobby::getProperty 0x10131BB0).
constexpr uint32_t kPropMatchFlags    = 0xFA5;  // int list: 1 friends, 2 password, 3 observers, 4 guild
constexpr uint32_t kPropMatchTitle    = 0xFA6;
constexpr uint32_t kPropGameType      = 0xFA7;  // 1 Constructed
constexpr uint32_t kPropPlayers       = 0xFA8;
constexpr uint32_t kPropPlayFormat    = 0xFA9;
constexpr uint32_t kPropStructure     = 0xFAA;  // 1 = one game
constexpr uint32_t kPropDuration      = 0x273;  // minutes; 0 = no chess clock
constexpr uint32_t kPropPassword      = 0xFAD;  // kept here, never sent
constexpr uint32_t kPropDeckName      = 0xFB0;  // never sent
constexpr uint32_t kFlagPassword      = 2;
constexpr uint32_t kFormatStandard    = 1, kFormatPractice = 0x11174, kFormatOpen = 0x11183;
constexpr uint32_t kCasualOpenSecs    = 900;    // an open match nobody joins closes after 15 minutes
constexpr size_t   kMatchTitleMax     = 40;

bool InTournament(uint32_t account);   // tournaments, below
void HandleQueueDeck(Session &s, uint32_t queue, const std::string &deck_id, bool id_only, bool has_deck,
	const std::vector<uint8_t> &bytes);

struct CasualMatch {
	uint32_t    id = 0;                    // M: a child group of Casual Games, the game id once it starts
	uint32_t    host = 0, guest = 0;       // accounts (role 2, host first); guest 0 = the seat is open
	std::string host_name, guest_name;
	std::string title, password;
	uint32_t    format = kFormatStandard;
	PvPDeck     host_deck, guest_deck;     // name empty = no deck yet
	bool        host_ready = false, guest_ready = false;
	bool        started = false;
	uint32_t    created = 0;
};

std::map<uint32_t, CasualMatch> g_casual;

bool IsCasualMatch(uint32_t id) { return g_casual.count(id) != 0; }

// The not-yet-started match an account hosts or sits in.
CasualMatch *CasualOf(uint32_t account)
{
	for (auto &kv : g_casual) {
		CasualMatch &m = kv.second;
		if (!m.started && (m.host == account || m.guest == account)) return &m;
	}
	return nullptr;
}

Session *RoomSession(uint32_t account, uint32_t match)
{
	for (auto &kv : g_sessions) {
		Session &o = *kv.second;
		if (o.account_id == account && o.room == match) return &o;
	}
	return nullptr;
}

// Every client that holds match M, never `except`.
std::vector<Session *> MatchKnowers(uint32_t match, uint32_t except_account)
{
	std::vector<Session *> out;
	for (auto &kv : g_sessions) {
		Session &o = *kv.second;
		if (o.account_id && o.account_id != except_account && o.known_matches.count(match)) out.push_back(&o);
	}
	return out;
}

// The Match as world lists it (spec 2.5): only what the list, the tiles and the room read.
void WriteMatch(Writer &w, const CasualMatch &m)
{
	w.Header(kMatchObject, 3, 2);
	w.U(0).Header(kPropertySet, 1, 1).U(7);                                // general set, 7 keys
	w.U(kPropMatchFlags).Header(kValueData, 4, 1).U(6).U(1);               // int list -- type 6 ONLY
	if (m.password.empty()) w.U(0); else w.U(1).U(kFlagPassword);
	PropStr(w, kPropMatchTitle, m.title);
	PropInt(w, kPropGameType, 1);
	PropInt(w, kPropPlayers, 2);
	PropInt(w, kPropPlayFormat, static_cast<int32_t>(m.format));
	PropInt(w, kPropStructure, 1);
	PropInt(w, kPropDuration, 0);
	for (int i = 0; i < 4; ++i) w.U(0).Header(kPropertySet, 1, 1).U(0);   // roles 2-5: present, empty
	w.U(0);                                                                // role 1 members
	if (m.guest) w.U(2).U(m.host).U(m.guest); else w.U(1).U(m.host);       // role 2: the host first
	w.U(0).U(0).U(0);                                                      // roles 3-5
	w.U(kCasualLobby).U(m.id).U(kMatchTypeID);                             // Containing, GroupID, type
	w.U(1);                                                                // v2: deck -- null, always
	w.U(0).U(0);                                                           // v3: tournamentRound, subState
	w.U(0);                                                                // Match: GameID
}

void SendMatchTo(Session &s, const CasualMatch &m)
{
	if (!s.account_id || s.known_matches.count(m.id)) return;
	Writer w;
	w.Header(kLobbyAddGroups, 1, 3).U(s.account_id).U(1);
	WriteMatch(w, m);
	Send(s, w);
	s.known_matches.insert(m.id);
}

// Entering Casual Games: the open matches. One already in play is left out (its players may have
// left the lobby since, and a member the client never met has no name in the list).
void SendOpenMatches(Session &s)
{
	for (auto &kv : g_casual) if (!kv.second.started) SendMatchTo(s, kv.second);
}

Writer LeaveMsg(uint32_t account, uint32_t group)
{
	Writer w;
	w.Header(kLobbyLeave, 3, 3).U(account).U(group).U(0).U(0);
	return w;
}

// Join for a match: the echo (to the player: opens its room) or the announcement (to everyone else:
// adds the player; the name introduces the account, so its properties are required).
Writer MatchJoinMsg(const Session &p, uint32_t match, bool echo)
{
	Writer w;
	w.Header(kLobbyJoin, 4, 3).U(p.account_id).U(match).U(kRolePlayer).S("").U(0);
	if (echo) {
		w.S("").U(0).Header(kPropertySet, 1, 1).U(0).U(0);
	}
	else {
		w.S(p.name).U(0);
		WriteMemberProps(w, p.account_id);
		w.U(0);   // gender
	}
	return w;
}

Writer ReadyMsg(uint32_t account, uint32_t match, bool ready)
{
	Writer w;
	w.Header(kMatchSetReady, 1, 4).U(account).U(match).U(ready ? 1 : 0);
	return w;
}

// The match goes from every client that holds it (rooms still open on it close themselves).
void RemoveMatch(uint32_t id, const std::string &why)
{
	for (auto &kv : g_sessions) {
		Session &o = *kv.second;
		if (o.room == id) o.room = 0;
		if (!o.known_matches.erase(id) || !o.account_id) continue;
		Writer w;
		w.Header(kLobbyRemoveGroups, 1, 3).U(o.account_id).U(1).U(id);
		Send(o, w);
	}
	g_casual.erase(id);
	LogInfo("[LoN] casual match [{}] removed ({})", id, why);
}

// Closed before it started (the host left, or nobody came). A room closes when a Leave names its
// own player: the guest gets the host's then its own; the host's own one only when it did not leave.
void CloseMatch(uint32_t id, const std::string &why, bool close_host_room)
{
	auto it = g_casual.find(id);
	if (it == g_casual.end()) return;
	const CasualMatch m = it->second;
	if (m.guest) {
		if (Session *g = RoomSession(m.guest, id)) {
			Send(*g, LeaveMsg(m.host, id));
			Send(*g, LeaveMsg(m.guest, id));
			PvPTell(*g, fmt::format("{} closed the card game.", m.host_name));
		}
	}
	if (close_host_room) {
		if (Session *h = RoomSession(m.host, id)) Send(*h, LeaveMsg(m.host, id));
	}
	RemoveMatch(id, why);
}

// Leave(M) (Cancel, closing the room, a lobby switch) or a disconnect before the game started.
void LeaveRoom(Session &s, const char *how)
{
	const uint32_t id = s.room;
	s.room = 0;
	auto it = g_casual.find(id);
	if (it == g_casual.end() || it->second.started) return;
	CasualMatch &m = it->second;
	if (s.account_id == m.host) {
		CloseMatch(id, fmt::format("host [{}] {}", s.name, how), false);
		return;
	}
	if (s.account_id != m.guest) return;
	m.guest = 0;
	m.guest_name.clear();
	m.guest_deck  = PvPDeck();
	m.guest_ready = false;
	for (Session *o : MatchKnowers(id, s.account_id)) Send(*o, LeaveMsg(s.account_id, id));
	if (Session *h = RoomSession(m.host, id)) PvPTell(*h, fmt::format("{} left your card game.", s.name));
	LogInfo("[LoN] [{}] {} casual match [{}]", s.name, how, id);
}

// MatchCommand_* carry four header levels; ReadHeader took three.
void SkipLevel(Reader &r, uint32_t op, uint32_t ver)
{
	const size_t save = r.p;
	const uint32_t a = r.U(), b = r.U();
	if (r.bad || a != op || b != ver) { r.p = save; r.bad = false; }
}

// A deck as the client sent it (in the Match or in SelectDeck): an EQDeck object that is named and
// passes DeckProblem (a full card list, every copy owned). Returns why not, empty = usable.
std::string ClientDeck(uint32_t account, const std::vector<uint8_t> &bytes, PvPDeck &out)
{
	Reader r(bytes.data(), bytes.size());
	const uint32_t c1 = r.U(), v1 = r.U(), c2 = r.U(), v2 = r.U();
	PvPDeck d;
	d.bytes = bytes;
	d.name  = DeckName(d.bytes, &d.key);
	if (r.bad || c1 != kEQDeck || c2 != kEQDeck || v1 != v2 || d.name.empty()) {
		return "The server could not read that deck. Choose another one.";
	}
	const std::string why = DeckProblem(account, d);
	if (why.empty()) out = d;
	return why;
}

// One of the account's decks by name or id string (the deck name 0xFB0 / SelectDeck's Deck ID).
std::string NamedDeck(uint32_t account, const std::string &want, PvPDeck &out)
{
	for (const PvPDeck &d : PvPDecks(account)) {
		if (!Strings::EqualFold(d.name, want) && d.key != want) continue;
		const std::string why = DeckProblem(account, d);
		if (why.empty()) out = d;
		return why;
	}
	return fmt::format("The server does not have your deck \"{}\". Save it in the deck builder, then try again.", want);
}

// Practice games ("a randomly chosen starter deck"): a random starter deck the account opened and
// owns in full, else its usual default deck. Never a deck it does not own.
std::string PracticeDeck(uint32_t account, PvPDeck &out)
{
	std::vector<PvPDeck> starters;
	auto o = database.QueryDatabase(fmt::format(
		"SELECT DISTINCT source FROM lon_card WHERE account_id = {} AND source LIKE 'starter:%' ORDER BY source", account));
	if (o.Success()) {
		for (auto row : o) {
			auto it = g_data.product_deck.find(ToU(row[0] + 8));
			if (it == g_data.product_deck.end()) continue;
			PvPDeck d;
			d.bytes = it->second;
			d.name  = DeckName(d.bytes, &d.key);
			if (!d.name.empty()) starters.push_back(d);
		}
	}
	if (!starters.empty()) {
		const size_t first = static_cast<size_t>(g_rng.Int(0, static_cast<int>(starters.size()) - 1));
		for (size_t i = 0; i < starters.size(); ++i) {
			const PvPDeck &d = starters[(first + i) % starters.size()];
			if (DeckProblem(account, d).empty()) { out = d; return ""; }
		}
	}
	return ResolveDeck(account, "", out);
}

// The title as others see it: plain text, at most 40 characters. The dialog's default is a text
// macro ("#owns([*actor*]) Match"); macros are never passed on.
std::string MatchTitle(const std::string &raw, const std::string &owner)
{
	std::string t;
	if (raw.find('#') == std::string::npos && raw.find('[') == std::string::npos) {
		for (unsigned char c : raw) {
			if (std::isalnum(c) || (c && std::strchr(" .,'!?-:&()", c))) t.push_back(static_cast<char>(c));
		}
		t = TrimSpaces(t);
	}
	if (t.empty()) t = owner + "'s Match";
	if (t.size() > kMatchTitleMax) t.resize(kMatchTitleMax);
	return t;
}

struct MatchCreate {
	std::string          title, password, deck_name;
	uint32_t             format   = kFormatStandard;
	bool                 has_deck = false;
	std::vector<uint8_t> deck;
};

// One ValueData (one header level, type, owning flag, value) of a type a create dialog writes.
bool ReadPropValue(Reader &r, uint32_t &type, int32_t &num, std::string &str)
{
	if (r.U() != kValueData) return false;
	r.U();   // version
	type = r.U();
	r.U();   // owning flag
	switch (type) {
		case 1: case 2: num = r.I(); break;
		case 3: str = r.S(); break;
		case 6: case 7: return SkipValue(r, type);
		default: return false;
	}
	return !r.bad;
}

// The client's AddGroups (spec 3.2), after its three header levels: AccountID, a vector holding
// exactly one Match. Values are read by type; an unknown type, a short field, or a deck not followed
// by the three zero ints (tournamentRound, subState, GameID) refuses the create.
bool ParseMatchCreate(Reader &r, MatchCreate &out)
{
	r.U();                                             // AccountID
	if (r.U() != 1 || r.bad) return false;            // one group
	for (int level = 0; level < 2; ++level) {          // Match v3, two header levels
		const uint32_t cls = r.U(), ver = r.U();
		if (r.bad || cls != kMatchObject || ver != 3) return false;
	}
	for (int set = 0; set < 5; ++set) {                // nullable PropertySets, roles 1..5
		const uint32_t flag = r.U();
		if (r.bad) return false;
		if (flag != 0) continue;
		if (r.U() != kPropertySet) return false;
		r.U();                                         // version
		const uint32_t n = r.U();
		if (r.bad || n > 64) return false;
		for (uint32_t i = 0; i < n; ++i) {
			const uint32_t key = r.U();
			uint32_t type = 0;
			int32_t num = 0;
			std::string str;
			if (!ReadPropValue(r, type, num, str)) return false;
			if (set != 0) continue;
			if (key == kPropMatchTitle && type == 3)       out.title     = str;
			else if (key == kPropPlayFormat && type == 2)  out.format    = static_cast<uint32_t>(num);
			else if (key == kPropPassword && type == 3)    out.password  = str;
			else if (key == kPropDeckName && type == 3)    out.deck_name = str;
		}
	}
	for (int role = 0; role < 5; ++role) {             // member lists: world builds its own
		const uint32_t n = r.U();
		if (r.bad || n > 64) return false;
		for (uint32_t i = 0; i < n; ++i) r.U();
	}
	r.U(); r.U(); r.U();                               // Containing, GroupID, type: world sets its own
	const uint32_t flag = r.U();                       // v2: nullable EQDeck
	if (r.bad) return false;
	if (flag != 0) {
		r.U(); r.U(); r.U();
		return !r.bad;
	}
	if (r.n < r.p + 3 + 8) return false;
	const size_t end = r.n - 3;
	if (r.d[end] != 0 || r.d[end + 1] != 0 || r.d[end + 2] != 0) return false;
	out.deck.assign(r.d + r.p, r.d + end);
	out.has_deck = true;
	return true;
}

// LobbyCommand_AddGroups from a client = Create, Quick Join with no match found, or practice.
void HandleMatchCreate(Session &s, Reader &r, const uint8_t *data, size_t len)
{
	if (!RuleB(Custom, LoNPvPEnabled)) { PvPTell(s, "Card game PvP is not open yet."); return; }
	if (s.lobby_group != kCasualLobby) {
		LogInfo("[LoN] [{}] sent a match create from outside Casual Games -- ignored", s.name);
		return;
	}
	if (s.room || s.pvp_match || s.queue || TradeOf(s.account_id) || MatchOf(s.account_id) || CasualOf(s.account_id) ||
		InTournament(s.account_id)) {
		PvPTell(s, "Finish your current card game, tournament or trade first.");
		return;
	}
	MatchCreate c;
	if (!ParseMatchCreate(r, c)) {
		LogInfo("[LoN] [{}] sent a match create the server cannot read ([{}] bytes): {}", s.name, len,
			Hex(std::vector<uint8_t>(data, data + len)));
		PvPTell(s, "The server could not read that game. Please try again.");
		return;
	}
	if (c.format != kFormatPractice && c.format != kFormatOpen) c.format = kFormatStandard;
	PvPDeck deck;
	std::string why;
	if (c.has_deck) why = ClientDeck(s.account_id, c.deck, deck);
	else if (!c.deck_name.empty()) why = NamedDeck(s.account_id, c.deck_name, deck);
	else if (c.format == kFormatPractice) why = PracticeDeck(s.account_id, deck);
	else why = "Choose a deck for your game.";
	if (!why.empty()) {
		PvPTell(s, why);
		LogInfo("[LoN] [{}] match create refused: {}", s.name, why);
		return;
	}

	CasualMatch m;
	m.id        = kPvPMatchBase + g_next_match++;
	m.host      = s.account_id;
	m.host_name = s.name;
	m.title     = MatchTitle(c.title, s.name);
	m.password  = c.password.substr(0, 64);
	m.format    = c.format;
	m.host_deck = deck;
	m.created   = PvPNow();
	g_casual[m.id] = m;
	// 1. Everyone in Casual Games lists it -- the creator too: the Match must exist before its echo.
	for (Session *o : LobbyMembers(kCasualLobby, 0)) SendMatchTo(*o, m);
	SendMatchTo(s, m);
	// 2. The creator's echo opens the match room.
	s.room = m.id;
	Send(s, MatchJoinMsg(s, m.id, true));
	LogInfo("[LoN] [{}] opened casual match [{}] \"{}\" (format [{:#x}], deck [{}]{})", s.name, m.id, m.title,
		m.format, deck.name, m.password.empty() ? "" : ", password");
}

// Join(M): a listed match (join dialog, user-list "Join hosted game"), Quick Join or practice.
void HandleMatchJoin(Session &s, uint32_t match, uint32_t role, const std::string &password)
{
	auto it = g_casual.find(match);
	if (it == g_casual.end()) return;
	CasualMatch &m = it->second;
	if (m.host == s.account_id || m.guest == s.account_id) return;   // already seated
	Session *h = RoomSession(m.host, match);
	std::string why;
	if (!RuleB(Custom, LoNPvPEnabled)) why = "Card game PvP is not open yet.";
	else if (role != kRolePlayer) why = "Watching card games is not supported.";
	else if (m.started) why = "That game has already started.";
	else if (m.guest) why = "That game is full.";
	else if (!m.password.empty() && password != m.password) why = "Wrong password for that game.";
	else if (s.lobby_group != kCasualLobby || s.room || s.pvp_match || s.queue || TradeOf(s.account_id) ||
		MatchOf(s.account_id) || CasualOf(s.account_id) || InTournament(s.account_id)) why = "Finish your current card game, tournament or trade first.";
	else if (!h) why = "That game's host is gone.";
	if (!why.empty()) {
		PvPTell(s, why);
		LogInfo("[LoN] [{}] could not join casual match [{}]: {}", s.name, match, why);
		return;
	}

	SendMatchTo(s, m);   // normally held already; the Match must exist before the echo
	m.guest       = s.account_id;
	m.guest_name  = s.name;
	m.guest_deck  = PvPDeck();
	m.guest_ready = false;
	s.room        = match;
	// A practice join sends no deck: one is picked here (a later SelectDeck replaces it).
	if (m.format == kFormatPractice) {
		PvPDeck d;
		if (PracticeDeck(s.account_id, d).empty()) m.guest_deck = d;
	}
	// 1. The joiner's room opens, with the host (already in the Match) and itself.
	Send(s, MatchJoinMsg(s, match, true));
	// 2. The host's room and every other list add the guest.
	for (Session *o : MatchKnowers(match, s.account_id)) Send(*o, MatchJoinMsg(s, match, false));
	// 3. A host already marked ready shows so in the guest's room.
	if (m.host_ready) Send(s, ReadyMsg(m.host, match, true));
	PvPTell(*h, fmt::format("{} joined your card game.", s.name));
	LogInfo("[LoN] [{}] joined [{}]'s casual match [{}]", s.name, m.host_name, match);
}

// Both seats ready with a usable deck: the game starts (spec 4.3) as a casual PvP match whose id is
// M. The creator hosts. Decks are checked again: cards can change hands by trade while
// a room is open.
void TryStart(uint32_t id)
{
	auto it = g_casual.find(id);
	if (it == g_casual.end()) return;
	CasualMatch &m = it->second;
	if (m.started || !m.guest || !m.host_ready || !m.guest_ready || m.host_deck.name.empty() || m.guest_deck.name.empty()) return;
	Session *h = RoomSession(m.host, id);
	Session *g = RoomSession(m.guest, id);
	if (!h || !g || h->pvp_match || g->pvp_match || g_matches.count(id)) return;
	for (int seat = 1; seat <= 2; ++seat) {
		Session &p     = seat == 1 ? *h : *g;
		PvPDeck &deck  = seat == 1 ? m.host_deck : m.guest_deck;
		const std::string why = DeckProblem(p.account_id, deck);
		if (why.empty()) continue;
		deck = PvPDeck();
		(seat == 1 ? m.host_ready : m.guest_ready) = false;
		Send(seat == 1 ? *g : *h, ReadyMsg(p.account_id, id, false));
		PvPTell(p, why + " Leave this game and join again with another deck.");
		LogInfo("[LoN] casual match [{}] not started: [{}]'s deck -- {}", id, p.name, why);
		return;
	}
	m.started = true;
	// 1. Every other list shows it started (and refuses joins: "The match has already started.").
	for (Session *o : MatchKnowers(id, 0)) {
		if (o->account_id == m.host || o->account_id == m.guest) continue;
		Writer w;
		w.Header(kMatchSetState, 1, 4).U(o->account_id).U(id).U(kMatchStarted);
		Send(*o, w);
	}
	// 2. The game. LaunchGame closes both rooms without a Leave; the players are no longer in them.
	h->room = 0;
	g->room = 0;
	StartPvP(*h, *g, m.host_deck, m.guest_deck, id, kModeCasual, 0);
	LogInfo("[LoN] casual match [{}] started: [{}] hosts [{}]", id, m.host_name, m.guest_name);
}

// The PvP game of a started Casual Games match closed: the match leaves every list.
void CasualGameOver(uint32_t id)
{
	auto it = g_casual.find(id);
	if (it != g_casual.end() && it->second.started) RemoveMatch(id, "game over");
}

// MatchCommand_SelectDeck v2: AccountID, MatchID, Deck ID, DeckIDOnly, nullable EQDeck.
void HandleMatchSelectDeck(Session &s, Reader &r, uint32_t ver)
{
	SkipLevel(r, kMatchSelectDeck, ver);
	r.U();
	const uint32_t match = r.U();
	const std::string deck_id = r.S();
	const uint32_t id_only = r.U();
	const uint32_t flag = r.eof() ? 1 : r.U();
	if (r.bad) return;
	if (IsTournQueue(match)) {   // the deck for a tournament queue (spec 2.4 step 4)
		HandleQueueDeck(s, match, deck_id, id_only != 0, flag == 0, std::vector<uint8_t>(r.d + r.p, r.d + r.n));
		return;
	}
	auto it = g_casual.find(match);
	if (it == g_casual.end() || it->second.started || s.room != match) return;
	CasualMatch &m = it->second;
	const bool host = s.account_id == m.host;
	if (!host && s.account_id != m.guest) return;
	PvPDeck d;
	const std::string why = !id_only && flag == 0
		? ClientDeck(s.account_id, std::vector<uint8_t>(r.d + r.p, r.d + r.n), d)
		: NamedDeck(s.account_id, deck_id, d);
	PvPDeck &seat = host ? m.host_deck : m.guest_deck;
	bool &ready   = host ? m.host_ready : m.guest_ready;
	if (!why.empty()) {
		seat = PvPDeck();
		if (ready) {
			ready = false;
			if (Session *o = RoomSession(host ? m.guest : m.host, match)) Send(*o, ReadyMsg(s.account_id, match, false));
		}
		PvPTell(s, why + " Leave this game and join again with another deck.");
		LogInfo("[LoN] [{}] deck refused in casual match [{}]: {}", s.name, match, why);
		return;
	}
	seat = d;
	LogInfo("[LoN] [{}] picked deck [{}] in casual match [{}]", s.name, d.name, match);
}

// MatchCommand_SetReady v1: stored and shown to the other player (the client ignores its own).
void HandleMatchSetReady(Session &s, Reader &r, uint32_t ver)
{
	SkipLevel(r, kMatchSetReady, ver);
	r.U();
	const uint32_t match = r.U();
	bool ready = r.U() != 0;
	if (r.bad) return;
	auto it = g_casual.find(match);
	if (it == g_casual.end() || it->second.started || s.room != match) return;
	CasualMatch &m = it->second;
	const bool host = s.account_id == m.host;
	if (!host && s.account_id != m.guest) return;
	if (ready && (host ? m.host_deck : m.guest_deck).name.empty()) {
		PvPTell(s, "The server has no usable deck for you in this game. Leave it and join again with a deck.");
		ready = false;
	}
	(host ? m.host_ready : m.guest_ready) = ready;
	const uint32_t other = host ? m.guest : m.host;
	if (Session *o = other ? RoomSession(other, match) : nullptr) Send(*o, ReadyMsg(s.account_id, match, ready));
	TryStart(match);
}

// From Process(): an open match nobody joined closes.
void ProcessCasual()
{
	const uint32_t now = PvPNow();
	std::vector<uint32_t> stale;
	for (auto &kv : g_casual) {
		const CasualMatch &m = kv.second;
		if (!m.started && !m.guest && now - m.created >= kCasualOpenSecs) stale.push_back(m.id);
	}
	for (uint32_t id : stale) {
		if (Session *h = RoomSession(g_casual[id].host, id)) PvPTell(*h, "Nobody joined your card game in 15 minutes, so it was closed.");
		CloseMatch(id, "nobody joined", true);
	}
}

// ---------------------------------------------------------------------------
// Tournaments (research/lon_tournaments_spec.md -- every message read in the client)
// ---------------------------------------------------------------------------
// The navigator's Tournaments button joins lobby group 5 (WATournamentScreen). Its child lobbies are
// plain Lobby objects: type 5 = a queue (queue table), type 6 = a started constructed tournament
// (started table). Design rules: free, constructed (bring your deck), single elimination, best of
// one, Custom:LoNTournamentPlayers players, ONE open queue that starts when full and is replaced at once,
// one entry per address (Custom:LoNTournamentOneEntryPerIP), NO item prizes -- the Journal (74) and the
// tournament rating only. Each pairing is an ordinary PvP game (StartPvP); its result comes from the PvP
// results code above (TournGameOver).
// Hard rules (each one an assert, a crash or a dead card-game stream on the client):
// - a lobby the client is told about (SetTournament, standings) reaches it in AddGroups first;
// - the queue's properties are int / string only, never the fee keys 0xFD7 / 0xFD9, the rating gate
//   0xFDE, 0xFDB / 0xFDC / 0xFA5 / 0x1069; 0xFA6 is a string; 0xFA7 = 1 (the join dialog then asks for a
//   deck); started tournaments list no members (a member the client never met has no name);
// - DisplayStats sets the client's tournament mode too: a player out of the tournament gets standings
//   (UpdateTournament) only, and everyone ends with SetTournament timer -1 (the client's Drop button
//   does the same) -- a client left in tournament mode cannot leave group 5;
// - a round's games launch only once both players are off the last game screen (a LaunchGame while the
//   old game still lives reuses it).
constexpr uint32_t kLobbyConcede       = 0x12A;    // v1, 3: the Drop button (client -> server; read 0x10140E50)
constexpr uint32_t kDisplayStats       = 0x124;    // v2, 3 (read 0x10143B10)
constexpr uint32_t kUpdateTournament   = 0x125;    // v1, 3 (read 0x10150750)
constexpr uint32_t kSetTournament      = 0x12B;    // v2, 3 (read 0x1014EB30: tid, round, timer, group)
constexpr uint32_t kStartTournamentMsg = 0x1CC;    // v1, 3 (read 0x1014F5A0)
constexpr uint32_t kTypeQueue          = 5;
constexpr uint32_t kTypeConstructed    = 6;
constexpr uint32_t kQueueBase          = 3000000;  // Q = this + queue number
constexpr uint32_t kTournBase          = 3100000;  // T = this + tournament id (lon_tournament.id)
constexpr uint32_t kPropTournNumber    = 0xFD5;    // int: the "#" column and the queue dialog's number
constexpr uint32_t kPropRounds         = 0xFD2;    // int
constexpr uint32_t kPropStructureName  = 0xFD3;    // string "single" (translated by the client)
constexpr uint32_t kPropRewardText     = 0xFD1;    // string, shown as is (model 0x103A3160: int or string)
constexpr uint32_t kPropNoTerritory    = 0x1057;   // present = skip the account-territory checks (0x104B8710)
constexpr int32_t  kOppBye             = -1;       // standings opponent: "Bye"
constexpr int32_t  kOppDropped         = -3;       // "Dropped" (out of the tournament)
constexpr uint32_t kMsgMatchups        = 0x13;     // "Matchups for round: %1"
constexpr uint32_t kMsgFinalStandings  = 0x14;     // "Final Standings."
constexpr uint32_t kTournLaunchSecs    = 15;       // the Matchups dialog shows this long before the games start

struct TournPlayer {
	uint32_t    account = 0;
	std::string name, ip;
	PvPDeck     deck;                   // name empty = no deck yet (queue)
	bool        out = false, dropped = false;
	uint32_t    wins = 0, losses = 0, out_round = 0;
	int32_t     opp = 0;                // this round's opponent: an account, kOppBye, kOppDropped
};

struct TournPair {
	uint32_t a = 0, b = 0;              // accounts; b 0 = a bye
	uint32_t match = 0;                 // the PvP game once launched
	bool     launched = false, done = false;
	uint32_t replays = 0;               // games replayed after no clear result (at most 1)
	uint32_t launch_at = 0;             // a replay's own start time; 0 = the round's (Tournament::launch_at)
};

struct TournQueue {
	uint32_t id = 0, number = 0;        // Q, and the number its "#" column shows
	std::vector<TournPlayer> players;
};

struct Tournament {
	uint32_t    group = 0, tid = 0, round = 0, rounds = 0, size = 0;
	std::string title;
	std::vector<TournPlayer> players;   // bracket order
	std::vector<TournPair>   pairs;     // this round
	uint32_t    launch_at = 0;          // this round's games start then
	bool        finished = false;       // ended; ProcessTourn drops it
};

TournQueue g_queue;
uint32_t   g_queue_numbers = 0;
std::map<uint32_t, Tournament> g_tourns;   // by group T

bool IsTournQueue(uint32_t id) { return id != 0 && id == g_queue.id; }

uint32_t TournSize() { return static_cast<uint32_t>(std::min(16, std::max(2, RuleI(Custom, LoNTournamentPlayers)))); }

uint32_t RoundsFor(uint32_t players)
{
	uint32_t r = 0;
	while ((1u << r) < players) ++r;
	return r;
}

std::string TournTitle()
{
	std::string t = MatchTitle(RuleS(Custom, LoNTournamentTitle), "Open");
	return t.empty() ? "Open" : t;
}

TournPlayer *FindPlayer(Tournament &t, uint32_t account)
{
	for (TournPlayer &p : t.players) if (p.account == account) return &p;
	return nullptr;
}

Tournament *TournamentOf(uint32_t account)
{
	for (auto &kv : g_tourns) {
		if (kv.second.finished) continue;
		for (const TournPlayer &p : kv.second.players) if (p.account == account && !p.out) return &kv.second;
	}
	return nullptr;
}

bool InTournament(uint32_t account) { return TournamentOf(account) != nullptr; }

// A queue (type 5) or a started tournament (type 6) as a child of group 5 (spec 8.3).
void WriteTournLobby(Writer &w, uint32_t group, uint32_t type, uint32_t number, const std::string &title,
	uint32_t size, uint32_t rounds, uint32_t round, const std::vector<uint32_t> &members)
{
	w.Header(kLobbyObject, 3, 1);
	w.U(0).Header(kPropertySet, 1, 1).U(9);                               // general set, 9 keys
	PropStr(w, kPropMatchTitle, title);
	PropInt(w, kPropTournNumber, static_cast<int32_t>(number));
	PropInt(w, kPropGameType, 1);                                          // Constructed: the dialog asks for a deck
	PropInt(w, kPropPlayers, static_cast<int32_t>(size));
	PropInt(w, kPropRounds, static_cast<int32_t>(rounds));
	PropStr(w, kPropStructureName, "single");
	PropStr(w, kPropRewardText, RuleS(Custom, LoNTournamentRewardText).substr(0, 60));
	PropInt(w, kPropPlayFormat, static_cast<int32_t>(kFormatStandard));
	PropInt(w, kPropNoTerritory, 1);
	for (int i = 0; i < 4; ++i) w.U(0).Header(kPropertySet, 1, 1).U(0);  // roles 2-5 sets: present, empty
	w.U(0);                                                                // role 1 members
	w.U(static_cast<uint32_t>(members.size()));                            // role 2: the players
	for (uint32_t a : members) w.U(a);
	w.U(0).U(0).U(0);                                                      // roles 3-5
	w.U(kTournLobby).U(group).U(type);                                     // Containing 5, GroupID, type
	w.U(1);                                                                // v2: deck -- null
	w.U(round).U(0);                                                       // v3: tournamentRound, subState
}

void SendQueueTo(Session &s)
{
	if (!s.account_id || !g_queue.id || s.known_matches.count(g_queue.id)) return;
	std::vector<uint32_t> members;
	for (const TournPlayer &p : g_queue.players) members.push_back(p.account);
	Writer w;
	w.Header(kLobbyAddGroups, 1, 3).U(s.account_id).U(1);
	WriteTournLobby(w, g_queue.id, kTypeQueue, g_queue.number, TournTitle(), TournSize(), RoundsFor(TournSize()), 0, members);
	Send(s, w);
	s.known_matches.insert(g_queue.id);
}

void SendTournTo(Session &s, const Tournament &t)
{
	if (!s.account_id || s.known_matches.count(t.group)) return;
	Writer w;
	w.Header(kLobbyAddGroups, 1, 3).U(s.account_id).U(1);
	WriteTournLobby(w, t.group, kTypeConstructed, t.tid, t.title, t.size, t.rounds, t.round, {});
	Send(s, w);
	s.known_matches.insert(t.group);
}

// The child group goes from every client that holds it.
void RemoveGroupEverywhere(uint32_t id)
{
	for (auto &kv : g_sessions) {
		Session &o = *kv.second;
		if (!o.known_matches.erase(id) || !o.account_id) continue;
		Writer w;
		w.Header(kLobbyRemoveGroups, 1, 3).U(o.account_id).U(1).U(id);
		Send(o, w);
	}
}

// There is always one open queue.
void EnsureQueue()
{
	if (g_queue.id) return;
	g_queue = TournQueue();
	g_queue.number = ++g_queue_numbers;
	g_queue.id     = kQueueBase + g_queue.number;
	for (Session *o : LobbyMembers(kTournLobby, 0)) SendQueueTo(*o);
}

// Entering Tournaments: the open queue and the running tournaments (after BulkJoin, so the queue's
// players are known accounts).
void SendTournGroups(Session &s)
{
	EnsureQueue();
	SendQueueTo(s);
	for (auto &kv : g_tourns) if (!kv.second.finished) SendTournTo(s, kv.second);
}

// Out of the queue. tell_self = the server took the player out: its dialog closes on the Leave naming it
// (and its own Leave(Q) back is ignored). Otherwise the client left and its dialog is closing already.
void LeaveQueueEx(Session &s, const char *how, bool tell_self)
{
	const uint32_t q = s.queue;
	s.queue = 0;
	if (!q || q != g_queue.id) return;
	auto &v = g_queue.players;
	auto it = std::find_if(v.begin(), v.end(), [&s](const TournPlayer &p) { return p.account == s.account_id; });
	if (it == v.end()) return;
	v.erase(it);
	for (Session *o : MatchKnowers(q, tell_self ? 0 : s.account_id)) Send(*o, LeaveMsg(s.account_id, q));
	LogInfo("[LoN] [{}] {} tournament queue [{}] ([{}] waiting)", s.name, how, q, v.size());
}

// Join{Q, role 2} from the queue's join dialog; its deck follows in MatchCommand_SelectDeck{Q}.
void HandleQueueJoin(Session &s, uint32_t queue, uint32_t role)
{
	std::string why;
	const uint32_t size = TournSize();
	if (!RuleB(Custom, LoNPvPEnabled)) why = "Card game tournaments are not open yet.";
	else if (role != kRolePlayer) why = "Watching tournaments is not supported.";
	else if (s.lobby_group != kTournLobby) why = "Open Tournaments first, then join the queue.";
	else if (s.queue == queue) return;   // already in it
	else if (s.queue || InTournament(s.account_id)) why = "You are already in a tournament.";
	else if (s.room || s.pvp_match || TradeOf(s.account_id) || MatchOf(s.account_id) || CasualOf(s.account_id)) {
		why = "Finish your current card game or trade first.";
	}
	else if (g_queue.players.size() >= size) why = "That tournament is full. The next one opens when it starts.";
	else if (RuleB(Custom, LoNTournamentOneEntryPerIP) && !s.ip.empty() &&
		std::any_of(g_queue.players.begin(), g_queue.players.end(), [&s](const TournPlayer &p) { return p.ip == s.ip; })) {
		why = "Someone from your address is already in this tournament.";
	}
	if (!why.empty()) {
		PvPTell(s, why);
		LogInfo("[LoN] [{}] could not join tournament queue [{}]: {}", s.name, queue, why);
		return;
	}
	SendQueueTo(s);   // normally held already; the queue must exist before its echo
	TournPlayer p;
	p.account = s.account_id;
	p.name    = s.name;
	p.ip      = s.ip;
	g_queue.players.push_back(p);
	s.queue = queue;
	// 1. The joiner's queue dialog opens. 2. Every other list counts the player (Cur #).
	Send(s, MatchJoinMsg(s, queue, true));
	for (Session *o : MatchKnowers(queue, s.account_id)) Send(*o, MatchJoinMsg(s, queue, false));
	PvPTell(s, fmt::format("You joined the tournament queue ({} of {} players). It starts when it is full; "
		"there are no item prizes, only the Journal and the tournament rating.", g_queue.players.size(), size));
	LogInfo("[LoN] [{}] joined tournament queue [{}] ([{}] of [{}])", s.name, queue, g_queue.players.size(), size);
}

void StartTournament();

// MatchCommand_SelectDeck{Q}: the deck the player brings (owned in full, a full card list).
void HandleQueueDeck(Session &s, uint32_t queue, const std::string &deck_id, bool id_only, bool has_deck,
	const std::vector<uint8_t> &bytes)
{
	if (s.queue != queue || !IsTournQueue(queue)) return;
	auto &v = g_queue.players;
	auto it = std::find_if(v.begin(), v.end(), [&s](const TournPlayer &p) { return p.account == s.account_id; });
	if (it == v.end()) return;
	PvPDeck d;
	const std::string why = !id_only && has_deck ? ClientDeck(s.account_id, bytes, d) : NamedDeck(s.account_id, deck_id, d);
	if (!why.empty()) {
		PvPTell(s, why + " Join the tournament again with another deck.");
		LeaveQueueEx(s, "had a deck refused in", true);
		return;
	}
	it->deck = d;
	LogInfo("[LoN] [{}] brings deck [{}] to tournament queue [{}]", s.name, d.name, queue);
	if (v.size() >= TournSize() &&
		std::all_of(v.begin(), v.end(), [](const TournPlayer &p) { return !p.deck.name.empty(); })) {
		StartTournament();
	}
}

// Standings: (account, points = wins, opponent) per player (UpdateTournament / DisplayStats map).
void WriteStandings(Writer &w, const Tournament &t)
{
	w.U(static_cast<uint32_t>(t.players.size()));
	for (const TournPlayer &p : t.players) w.U(p.account).U(p.wins).I(p.out ? kOppDropped : p.opp);
}

void SendUpdateTournament(Session &s, const Tournament &t)
{
	SendTournTo(s, t);   // a player who came back since holds no T yet
	Writer w;
	w.Header(kUpdateTournament, 1, 3).U(s.account_id).U(t.group).U(t.tid);
	WriteStandings(w, t);
	w.U(t.round).U(0);
	Send(s, w);
}

// The results dialog. Duration 0 (it also sets the client's tournament timer); the name map makes every
// player in the standings a known account.
void SendDisplayStats(Session &s, const Tournament &t, uint32_t msg, const std::string &arg)
{
	SendTournTo(s, t);
	Writer w;
	w.Header(kDisplayStats, 2, 3).U(s.account_id).U(t.group).U(t.tid).U(t.round);
	WriteStandings(w, t);
	w.U(msg).U(0).S(arg);
	w.U(static_cast<uint32_t>(t.players.size()));
	for (const TournPlayer &p : t.players) w.U(p.account).S(p.name);
	Send(s, w);
}

// timer -1 = leave tournament mode (WATournamentManager 0x104B4980 clears the context, as the Drop button).
void SendSetTournament(Session &s, const Tournament &t, int32_t timer)
{
	SendTournTo(s, t);
	Writer w;
	w.Header(kSetTournament, 2, 3).U(s.account_id).U(t.tid).U(std::max<uint32_t>(t.round, 1)).I(timer).U(t.group);
	Send(s, w);
}

void SendStandingsAll(const Tournament &t)
{
	for (const TournPlayer &p : t.players) {
		if (Session *s = AccountSession(p.account)) SendUpdateTournament(*s, t);
	}
}

void FinishTournament(Tournament &t);

// Pairs the players still in (bracket order) and shows the Matchups; the games start after
// kTournLaunchSecs in ProcessTourn. One player left = the end.
void StartRound(Tournament &t)
{
	std::vector<TournPlayer *> alive;
	for (TournPlayer &p : t.players) if (!p.out) alive.push_back(&p);
	if (alive.size() <= 1) {
		FinishTournament(t);
		return;
	}
	++t.round;
	t.pairs.clear();
	for (size_t i = 0; i < alive.size(); i += 2) {
		TournPair pr;
		pr.a = alive[i]->account;
		if (i + 1 < alive.size()) {
			pr.b = alive[i + 1]->account;
			alive[i]->opp     = static_cast<int32_t>(pr.b);
			alive[i + 1]->opp = static_cast<int32_t>(pr.a);
		}
		else {
			pr.done = true;   // a bye: through to the next round
			alive[i]->opp = kOppBye;
			++alive[i]->wins;
		}
		t.pairs.push_back(pr);
	}
	t.launch_at = PvPNow() + kTournLaunchSecs;
	SendStandingsAll(t);
	for (TournPlayer *p : alive) {
		if (Session *s = AccountSession(p->account)) {
			SendDisplayStats(*s, t, kMsgMatchups, std::to_string(t.round));
			PvPTell(*s, p->opp == kOppBye
				? fmt::format("Tournament {} round {}: you have a bye and go through to the next round.", t.tid, t.round)
				: fmt::format("Tournament {} round {}: your game starts in {} seconds, once both of you have left any game screen "
					"(after {} more seconds a player who has not forfeits).", t.tid, t.round, kTournLaunchSecs,
					std::max(30, RuleI(Custom, LoNTournamentNoShowSeconds))));
		}
	}
	LogInfo("[LoN] tournament [{}] round [{}]: [{}] players, [{}] pairings", t.tid, t.round, alive.size(), t.pairs.size());
}

// A player is out: standings stay visible, tournament mode ends (the Drop panel goes, group 5 can be left).
void Eliminated(Tournament &t, TournPlayer &p)
{
	p.out       = true;
	p.out_round = t.round;
	p.opp       = kOppDropped;
	if (Session *s = AccountSession(p.account)) {
		SendSetTournament(*s, t, -1);
		PvPTell(*s, fmt::format("You are out of tournament {}. The final standings follow when it ends.", t.tid));
	}
}

// A pairing's result (RecordPvPResult, a forfeit or a drop). winner 0 = nobody. A game PLAYED with no
// clear result (ReplayEnd: idle timeout, fatal error, disputed or missing reports) is replayed once --
// a new game, same players, a new coin flip for the host -- unless one of the two is already out (the
// other goes through). Otherwise winner 0 = both are out; StartRound gives byes as the bracket needs.
// The pair's players stay in tournament mode (SetTournament timer 0) through the replay; whoever goes
// out gets timer -1 in Eliminated, everyone at the end in FinishTournament.
void TournGameOver(uint32_t group, uint32_t a, uint32_t b, uint32_t winner, uint32_t end)
{
	auto it = g_tourns.find(group);
	if (it == g_tourns.end() || it->second.finished) return;
	Tournament &t = it->second;
	bool found = false;
	for (TournPair &pr : t.pairs) {
		if (pr.done || !((pr.a == a && pr.b == b) || (pr.a == b && pr.b == a))) continue;
		found = true;
		if (!winner) {
			const TournPlayer *pa = FindPlayer(t, pr.a), *pb = FindPlayer(t, pr.b);
			const bool a_in = pa && !pa->out, b_in = pb && !pb->out;
			if (a_in != b_in) winner = a_in ? pr.a : pr.b;   // the other one dropped meanwhile
			else if (a_in && b_in && ReplayEnd(end) && pr.replays == 0) {
				++pr.replays;
				pr.launched  = false;
				pr.match     = 0;
				pr.launch_at = PvPNow() + kTournLaunchSecs;
				LogInfo("[LoN] tournament [{}] round [{}]: [{}] vs [{}] had no clear result ({}) -- replayed once",
					t.tid, t.round, pr.a, pr.b, EndName(end));
				for (uint32_t acct : {pr.a, pr.b}) {
					if (Session *s = AccountSession(acct)) {
						PvPTell(*s, fmt::format("Tournament {} round {}: your game had no clear result, so it is played again "
							"once. Leave the game screen; the new game starts in {} seconds (after {} more seconds a player "
							"who has not come forfeits). If it has no clear result either, you are both out.",
							t.tid, t.round, kTournLaunchSecs, std::max(30, RuleI(Custom, LoNTournamentNoShowSeconds))));
					}
				}
				SendStandingsAll(t);
				return;
			}
		}
		pr.done = true;
		for (uint32_t acct : {pr.a, pr.b}) {
			TournPlayer *p = FindPlayer(t, acct);
			if (!p || p->out) continue;
			if (winner && acct == winner) { ++p->wins; continue; }
			++p->losses;
			Eliminated(t, *p);
		}
		break;
	}
	if (!found) return;
	LogInfo("[LoN] tournament [{}] round [{}]: [{}] vs [{}] -- winner [{}] ({})", t.tid, t.round, a, b, winner, EndName(end));
	if (std::all_of(t.pairs.begin(), t.pairs.end(), [](const TournPair &p) { return p.done; })) StartRound(t);
	else SendStandingsAll(t);
}

// A pairing that cannot be played: whoever is not there (or brings an unusable deck) loses it.
void ForfeitPair(Tournament &t, const TournPair &pr, bool a_ok, bool b_ok, const std::string &why)
{
	PvPMatch m;
	m.host  = pr.a;
	m.guest = pr.b;
	m.mode  = kModeTournament;
	m.tourn = t.group;
	if (const TournPlayer *p = FindPlayer(t, pr.a)) { m.host_name = p->name; m.host_ip = p->ip; }
	if (const TournPlayer *p = FindPlayer(t, pr.b)) { m.guest_name = p->name; m.guest_ip = p->ip; }
	m.started_at = m.ended_at = PvPNow();
	const uint32_t loser_seat = a_ok && !b_ok ? 2 : !a_ok && b_ok ? 1 : 0;
	LogInfo("[LoN] tournament [{}] round [{}]: [{}] vs [{}] not played ({})", t.tid, t.round, m.host_name, m.guest_name, why);
	for (uint32_t acct : {pr.a, pr.b}) {
		if (Session *s = AccountSession(acct)) PvPTell(*s, fmt::format("Tournament {}: your round {} game was not played ({}).", t.tid, t.round, why));
	}
	m.resolved = true;
	RecordPvPResult(m, kEndNoShow, loser_seat, 0);   // -> TournGameOver
}

// Free for a tournament game: online, off every game screen, not in a room, a queue or a trade.
Session *TournReady(uint32_t account)
{
	Session *s = AccountSession(account);
	if (!s || s->pvp_match || s->game_screen || s->room || s->queue) return nullptr;
	if (TradeOf(account) || MatchOf(account) || CasualOf(account)) return nullptr;
	return s;
}

void LaunchRound(Tournament &t, uint32_t now)
{
	if (t.finished || now < t.launch_at) return;
	const uint32_t round = t.round;
	const uint32_t grace = static_cast<uint32_t>(std::max(30, RuleI(Custom, LoNTournamentNoShowSeconds)));
	for (size_t i = 0; i < t.pairs.size() && t.round == round && !t.finished; ++i) {
		const TournPair pr = t.pairs[i];
		if (pr.done || pr.launched) continue;
		const uint32_t start = pr.launch_at ? pr.launch_at : t.launch_at;   // a replay waits for its own time
		if (now < start) continue;
		TournPlayer *pa = FindPlayer(t, pr.a), *pb = FindPlayer(t, pr.b);
		if (!pa || !pb) continue;
		Session *A = TournReady(pr.a), *B = TournReady(pr.b);
		// Decks are checked again: cards can change hands by trade while a tournament runs.
		const bool deck_a = DeckProblem(pr.a, pa->deck).empty();
		const bool deck_b = DeckProblem(pr.b, pb->deck).empty();
		if (A && B && deck_a && deck_b) {
			const bool a_hosts = g_rng.Int(0, 1) == 0;   // the host sees hidden cards: a coin flip
			const uint32_t id = kPvPMatchBase + g_next_match++;
			t.pairs[i].launched = true;
			t.pairs[i].match    = id;
			StartPvP(a_hosts ? *A : *B, a_hosts ? *B : *A, a_hosts ? pa->deck : pb->deck, a_hosts ? pb->deck : pa->deck,
				id, kModeTournament, t.group);
			continue;
		}
		if (deck_a && deck_b && now < start + grace) continue;   // still waiting for a player
		std::string why;
		if (!deck_a || !deck_b) why = "a deck can no longer be used";
		else why = "a player did not come in time";
		ForfeitPair(t, pr, A && deck_a, B && deck_b, why);
	}
}

// One player left (or nobody): final standings to everyone who played, tournament mode off, the
// tournament leaves every list, the rows for the leaderboard.
void FinishTournament(Tournament &t)
{
	if (t.finished) return;
	t.finished = true;
	std::vector<TournPlayer *> order;
	for (TournPlayer &p : t.players) order.push_back(&p);
	std::stable_sort(order.begin(), order.end(), [](const TournPlayer *x, const TournPlayer *y) {
		if (x->out != y->out) return !x->out;
		if (x->out_round != y->out_round) return x->out_round > y->out_round;
		return x->wins > y->wins;
	});
	const uint32_t winner = !order.empty() && !order.front()->out ? order.front()->account : 0;
	const std::string winner_name = winner ? order.front()->name : "nobody";
	for (TournPlayer &p : t.players) {
		Session *s = AccountSession(p.account);
		if (!s) continue;
		SendDisplayStats(*s, t, kMsgFinalStandings, "");
		SendSetTournament(*s, t, -1);
		PvPTell(*s, fmt::format("Tournament {} is over. Winner: {}.", t.tid, winner_name));
	}
	RemoveGroupEverywhere(t.group);
	database.QueryDatabase(fmt::format(
		"UPDATE lon_tournament SET winner_account = {}, rounds = {}, ended_at = NOW() WHERE id = {}", winner, t.round, t.tid));
	for (size_t i = 0; i < order.size(); ++i) {
		const TournPlayer &p = *order[i];
		database.QueryDatabase(fmt::format(
			"INSERT IGNORE INTO lon_tournament_entry (tournament_id, account_id, char_name, place, wins, losses, dropped) "
			"VALUES ({}, {}, '{}', {}, {}, {}, {})", t.tid, p.account, Strings::Escape(p.name), i + 1, p.wins, p.losses, p.dropped ? 1 : 0));
		EnsureStats(p.account, p.name);
		database.QueryDatabase(fmt::format(
			"UPDATE lon_pvp_stats SET tournaments_played = tournaments_played + 1, tournaments_won = tournaments_won + {} WHERE account_id = {}",
			p.account == winner ? 1 : 0, p.account));
	}
	LogInfo("[LoN] tournament [{}] finished after [{}] round(s): winner [{}]", t.tid, t.round, winner_name);
}

void StartTournament()
{
	Tournament t;
	t.players = g_queue.players;
	t.size    = static_cast<uint32_t>(t.players.size());
	t.rounds  = RoundsFor(t.size);
	t.title   = TournTitle();
	for (size_t i = t.players.size(); i > 1; --i) {   // random seeding
		std::swap(t.players[i - 1], t.players[static_cast<size_t>(g_rng.Int(0, static_cast<int>(i) - 1))]);
	}
	auto ins = database.QueryDatabase(fmt::format(
		"INSERT INTO lon_tournament (title, players, rounds, started_at) VALUES ('{}', {}, {}, NOW())",
		Strings::Escape(t.title), t.size, t.rounds));
	t.tid   = ins.Success() && ins.LastInsertedID() ? static_cast<uint32_t>(ins.LastInsertedID()) : 900000 + g_queue.number;
	t.group = kTournBase + t.tid;
	const uint32_t old_queue = g_queue.id;
	g_queue = TournQueue();   // id 0: EnsureQueue opens the next one below
	for (auto &kv : g_sessions) if (kv.second->queue == old_queue) kv.second->queue = 0;
	Tournament &T = g_tourns[t.group] = t;
	// 1. "Tournament N has begun..." 2. The tournament exists for everyone (before any SetTournament).
	for (const TournPlayer &p : T.players) {
		if (Session *s = AccountSession(p.account)) {
			Writer w;
			w.Header(kStartTournamentMsg, 1, 3).U(s->account_id).U(T.tid).U(T.tid);
			Send(*s, w);
			SendTournTo(*s, T);
		}
	}
	for (Session *o : LobbyMembers(kTournLobby, 0)) SendTournTo(*o, T);
	// 3. The full queue goes: its dialogs close (their Leave(Q) back is ignored).
	RemoveGroupEverywhere(old_queue);
	// 4. Tournament mode on: the Drop button.
	for (const TournPlayer &p : T.players) if (Session *s = AccountSession(p.account)) SendSetTournament(*s, T, 0);
	LogInfo("[LoN] tournament [{}] (group [{}]) started with [{}] players, [{}] round(s)", T.tid, T.group, T.size, T.rounds);
	// 5. The next open queue, then round 1.
	EnsureQueue();
	StartRound(T);
}

// LobbyCommand_Concede = the Drop button: the player leaves the tournament (the client already left
// tournament mode on its own).
void HandleTournDrop(Session &s)
{
	Tournament *tp = TournamentOf(s.account_id);
	if (!tp) return;
	Tournament &t = *tp;
	TournPlayer *p = FindPlayer(t, s.account_id);
	if (!p) return;
	p->dropped = true;
	LogInfo("[LoN] [{}] dropped from tournament [{}]", s.name, t.tid);
	// A game in progress: the drop is its loss.
	if (s.pvp_match) {
		auto it = g_matches.find(s.pvp_match);
		if (it != g_matches.end() && it->second.tourn == t.group && !it->second.ended) {
			AbandonPvP(it->first, s.account_id == it->second.host, "dropped from the tournament");
			return;
		}
	}
	// A pairing not started yet: the other player goes through.
	for (const TournPair &pr : t.pairs) {
		if (pr.done || pr.launched || (pr.a != s.account_id && pr.b != s.account_id)) continue;
		ForfeitPair(t, pr, pr.a != s.account_id, pr.b != s.account_id, fmt::format("{} dropped", s.name));
		return;
	}
	// Waiting for the next round: out now.
	if (!p->out) {
		Eliminated(t, *p);
		SendStandingsAll(t);
	}
}

// From Process(): this round's games, finished tournaments, the open queue.
void ProcessTourn()
{
	const uint32_t now = PvPNow();
	for (auto &kv : g_tourns) LaunchRound(kv.second, now);
	for (auto it = g_tourns.begin(); it != g_tourns.end();) {
		if (it->second.finished) it = g_tourns.erase(it);
		else ++it;
	}
}

void HandleAddDeck(Session &s, Reader &r)
{
	// DeckCommand_AddOnlineDeck v1: SerializedDeckLength, the raw EQDeck bytes, Archetype.
	// (ReadHeader already took all three header levels; DeckCommand has no fields.)
	const uint32_t len = r.U();
	if (r.bad || len == 0 || len > 1024 * 1024 || r.p + len > r.n) return;
	std::vector<uint8_t> deck(r.d + r.p, r.d + r.p + len);
	r.p += len;
	const uint32_t archetype = r.U();
	std::string key;
	const std::string name = DeckName(deck, &key);
	if (name.empty()) {
		LogInfo("[LoN] [{}] sent a deck with no name -- not stored (the client cannot list one)", s.name);
		return;
	}
	database.QueryDatabase(fmt::format(
		"REPLACE INTO lon_deck (account_id, name, archetype, deck) VALUES ({}, '{}', {}, UNHEX('{}'))",
		s.account_id, Strings::Escape(name), archetype, Hex(deck)));
	SendDecks(s);
	LogInfo("[LoN] [{}] saved deck [{}]", s.name, name);
	CheckProgress(s, true);
}

void HandleDeleteDeck(Session &s, Reader &r)
{
	const std::string id = r.S();
	if (r.bad || id.empty()) return;
	database.QueryDatabase(fmt::format(
		"DELETE FROM lon_deck WHERE account_id = {} AND name = '{}'", s.account_id, Strings::Escape(id)));
	SendDecks(s);
	LogInfo("[LoN] [{}] deleted deck [{}]", s.name, id);
}

// Hard-difficulty rewards are foil (live). A foil copy is its own archetype id: the client
// treats an id whose hundred-thousands digit is 3 or 4 as the foil printing of id - 300000
// (LoN 0x100457B0 / 0x10044EB0), so the foil of a card is card + 300000.
uint32_t Foil(uint32_t card)
{
	const uint32_t digit = (card % 1000000) / 100000;
	return (digit == 0 || digit == 1) ? card + 300000 : card;
}

constexpr int kHard = 3;   // the client's difficulty levels are 1 Easy, 2 Medium, 3 Hard

// The campaign-completion rewards: every scenario of the campaign won with each of the four
// non-Generic archetypes (any difficulty) = one set; all of those on Hard = the foil set.
void CheckCampaign(Session &s, const std::string &script, std::vector<uint32_t> &give)
{
	auto ci = g_data.campaign_of.find(script);
	if (ci == g_data.campaign_of.end()) return;
	const Campaign &cp = g_data.campaigns[ci->second];
	std::string list;
	for (const std::string &sc_name : cp.scripts) {
		if (!list.empty()) list += ",";
		list += "'" + Strings::Escape(sc_name) + "'";
	}
	const uint32_t need = static_cast<uint32_t>(cp.scripts.size()) * 4;
	for (const int tier : {1, kHard}) {
		auto c = database.QueryDatabase(fmt::format(
			"SELECT COUNT(DISTINCT script, variant) FROM lon_reward_claim WHERE account_id = {} "
			"AND script IN ({}) AND variant IN (70001, 70003, 70004, 70005) AND difficulty >= {}",
			s.account_id, list, tier));
		if (!c.Success() || c.RowCount() == 0 || ToU(c.begin()[0]) < need) continue;
		auto claim = database.QueryDatabase(fmt::format(
			"INSERT IGNORE INTO lon_reward_claim (account_id, script, difficulty, variant, archetype) VALUES ({}, 'campaign:{}', {}, 0, 0)",
			s.account_id, cp.id, tier));
		if (!claim.Success() || claim.RowsAffected() != 1) continue;
		for (uint32_t card : cp.reward_cards) give.push_back(tier == kHard ? Foil(card) : card);
		LogInfo("[LoN] [{}] completed campaign [{}]{} -- [{}] reward card(s)", s.name, cp.id, tier == kHard ? " on Hard" : "", cp.reward_cards.size());
	}
}

void PayScenario(Session &s, const std::string &script, int32_t game_id)
{
	auto it = g_data.scenarios.find(script);
	if (it == g_data.scenarios.end()) {
		LogInfo("[LoN] [{}] won [{}] -- not a scenario we know, no reward", s.name, script);
		return;
	}
	const Scenario &sc = it->second;

	// Anti-farm: the client must have reported this game's begin, long enough ago.
	auto g = database.QueryDatabase(fmt::format(
		"SELECT TIMESTAMPDIFF(SECOND, began_at, NOW()), turns FROM lon_game "
		"WHERE account_id = {} AND game_id = {} AND began_at IS NOT NULL", s.account_id, game_id));
	if (!g.Success() || g.RowCount() == 0) {
		LogInfo("[LoN] [{}] scenario [{}] win with no recorded begin -- no reward", s.name, script);
		return;
	}
	const int secs  = std::atoi(g.begin()[0] ? g.begin()[0] : "0");
	const int turns = std::atoi(g.begin()[1] ? g.begin()[1] : "0");
	if (secs < RuleI(Custom, LoNMinScenarioSeconds) || turns < RuleI(Custom, LoNMinScenarioTurns)) {
		LogInfo("[LoN] [{}] scenario [{}] won in [{}]s / [{}] turns -- too fast, no reward", s.name, script, secs, turns);
		return;
	}

	std::vector<uint32_t> give;

	// The reward card: once per scenario x difficulty x hero archetype -- live's "one reward
	// for winning this scenario with each different archetype on Easy, Medium, or Hard
	// difficulty (12 possible)". The client sends the archetype as SetCampaignStatus
	// CustomInt (game property "archetype", LoN 0x102C48D5) and one status per difficulty
	// from the one won down to 1, all before the game-end report.
	// Archetypes (from the starter decks): 70001 Fighter, 70002 Generic, 70003 Mage,
	// 70004 Priest, 70005 Scout. Split rewards: "X (Fighter, Scout, or Generic) or Y (Mage or Priest)".
	// One claim per difficulty from Easy up to the one won ("If you win on Medium or Hard,
	// you'll receive the reward for each lower difficulty (if you haven't already)" -- and the
	// client sends one status per difficulty for exactly that). The win is recorded even when
	// the scenario has no reward card of its own: campaign completion counts these rows.
	// Hard pays the foil printing.
	const int won = std::max(1, std::min(s.difficulty, kHard));
	for (int d = 1; d <= won; ++d) {
		uint32_t card = 0;
		if (!sc.reward_cards.empty()) {
			const bool caster = s.archetype == 70003 || s.archetype == 70004;
			card = (sc.reward_split && caster) ? sc.reward_cards[1] : sc.reward_cards[0];
			if (d >= kHard) card = Foil(card);
		}
		auto c = database.QueryDatabase(fmt::format(
			"INSERT IGNORE INTO lon_reward_claim (account_id, script, difficulty, variant, archetype) VALUES ({}, '{}', {}, {}, {})",
			s.account_id, Strings::Escape(script), d, s.archetype, card));
		if (card && c.Success() && c.RowsAffected() == 1) { give.push_back(card); }
	}
	// The first-win EverQuest loot card(s): once per scenario per account.
	if (!sc.loot_cards.empty()) {
		auto c = database.QueryDatabase(fmt::format(
			"INSERT IGNORE INTO lon_reward_claim (account_id, script, difficulty, variant, archetype) VALUES ({}, '{}', -1, 0, {})",
			s.account_id, Strings::Escape(script), sc.loot_cards[0]));
		if (c.Success() && c.RowsAffected() == 1) give.insert(give.end(), sc.loot_cards.begin(), sc.loot_cards.end());
	}
	CheckCampaign(s, script, give);
	if (give.empty()) {
		LogInfo("[LoN] [{}] scenario [{}] (difficulty [{}], archetype [{}]) already rewarded", s.name, script, s.difficulty, s.archetype);
		return;
	}
	std::vector<Inst> added = GiveCards(s.account_id, give, fmt::format("reward:{}", script));
	Deliver(s, {}, added);
	LogInfo("[LoN] [{}] scenario [{}] reward: [{}] card(s)", s.name, script, added.size());
}

void HandleRecordGame(Session &s, Reader &r)
{
	// AccountCommand_RecordSinglePlayerGame v1: AccountID, Activity (1 begin / 2 end),
	// GameType (1 tutorial / 2 scenario / 3 skirmish), Result (1 win / 2 lose), turns,
	// unique game id, script name.
	r.U();
	const int32_t activity = r.I(), type = r.I(), result = r.I(), turns = r.I(), game_id = r.I();
	const std::string script = r.S();
	if (r.bad) return;
	LogInfo("[LoN] [{}] game report: activity [{}] type [{}] result [{}] turns [{}] id [{}] script [{}]",
		s.name, activity, type, result, turns, game_id, script);

	if (activity == 1) {
		database.QueryDatabase(fmt::format(
			"REPLACE INTO lon_game (account_id, game_id, game_type, script, began_at) VALUES ({}, {}, {}, '{}', NOW())",
			s.account_id, game_id, type, Strings::Escape(script)));
		return;
	}
	if (activity != 2) return;
	auto u = database.QueryDatabase(fmt::format(
		"UPDATE lon_game SET ended_at = NOW(), result = {}, turns = {} "
		"WHERE account_id = {} AND game_id = {} AND ended_at IS NULL",
		result, turns, s.account_id, game_id));
	if (!u.Success() || u.RowsAffected() != 1) {
		LogInfo("[LoN] [{}] game end [{}] with no open begin -- ignored", s.name, game_id);
		return;
	}
	if (type == 2 && result == 1) PayScenario(s, script, game_id);
	if ((type == 1 || type == 2) && result == 1) CheckProgress(s, true);
	s.difficulty = 0;   // the next game's statuses start a new batch
	s.archetype  = 0;
}

void HandleCampaignStatus(Session &s, Reader &r, uint32_t version)
{
	// AccountCommand_SetCampaignStatus v3: AccountID, Campaign ID, Status, Difficulty Level,
	// CustomInt (v2), a string (v3).
	r.U();
	const int32_t campaign = r.I(), status = r.I(), difficulty = r.I();
	const int32_t custom = version >= 2 ? r.I() : 0;
	const std::string extra = version >= 3 ? r.S() : std::string();
	if (r.bad) return;
	s.difficulty = std::max(s.difficulty, difficulty);
	if (custom) s.archetype = custom;
	LogInfo("[LoN] [{}] campaign status: campaign [{}] status [{}] difficulty [{}] archetype [{}] [{}]",
		s.name, campaign, status, difficulty, custom, extra);
}

// Reads the (classId, version) header pairs: one per class level, all identical.
bool ReadHeader(Reader &r, uint32_t &op, uint32_t &ver)
{
	op  = r.U();
	ver = r.U();
	if (r.bad) return false;
	for (int i = 0; i < 2; ++i) {
		const size_t save = r.p;
		const uint32_t a = r.U(), b = r.U();
		if (r.bad || a != op || b != ver) { r.p = save; r.bad = false; break; }
	}
	return true;
}

bool KnownOp(uint32_t op)
{
	switch (op) {
		case kGetConnectionServer: case kSendPassword: case kSendSessionID: case kSyncUpdate:
		case kSyncBulkFulfillment: case kDeckAddOnline: case kDeckDeleteOnline: case kRedeemItemGrant:
		case kRecordSinglePlayer: case kSetCampaignStatus: case kPing: case kDisconnect:
		case 0x089: case 0x076: case 0x10F:
			return true;
		default:
			return op > 0 && op < 0x220;
	}
}

void HandleMessage(Session &s, const uint8_t *data, size_t len)
{
	// The client's send path puts 12 bytes (three words, the first = service id) ahead of the
	// message on connection sockets; its receive path never expects them (LoN.h 55.8).
	{
		Reader probe(data, len);
		const uint32_t op = probe.U();
		if ((probe.bad || !KnownOp(op)) && len > 12) { data += 12; len -= 12; }
	}
	Reader r(data, len);
	uint32_t op = 0, ver = 0;
	if (!ReadHeader(r, op, ver)) return;

	if (op == kPing) {
		Writer w;
		w.Raw(data, len);
		Send(s, w);
		return;
	}
	if (op == kGetConnectionServer) {
		s.gateway_session = r.S();
		s.gateway_user    = r.S();
		// Send the client back to the same local port: its dinput8 relays it here again.
		Writer w;
		w.Header(kGetConnectionServer, 1, 3).S(s.gateway_session).S(s.gateway_user).S("127.0.0.1").U(15782).U(1).U(0);
		Send(s, w);
		return;
	}
	if (op == kSendSessionID) { HandleLogin(s, r.S()); return; }
	if (op == kSendPassword) {
		// Only the token login is accepted -- a typed name and password prove nothing here.
		LoginReply(s, false, kErrSessionInvalid);
		return;
	}
	if (op == kDisconnect) return;
	if (!s.account_id) return;   // everything below needs a logged-in account

	// Our dinput8's PvP result report (world-only class).
	if (op == kPvPReport) { HandlePvPReport(s, r); return; }
	// Game commands belong to a casual PvP match (relayed) or to nothing (dropped and logged).
	if (IsGameCommand(op)) { HandlePvPFrame(s, data, len); return; }

	switch (op) {
		case kSyncUpdate:
			// An acknowledgement, not a request: answering every one loops (LoN.h 55.11). Once.
			if (!s.synced) { s.synced = true; SendCollection(s); }
			return;
		case kSyncBulkFulfillment: HandleBulkFulfillment(s, r); return;
		case kRedeemItemGrant:     HandleRedeem(s, r, ver); return;
		case kDeckAddOnline:       HandleAddDeck(s, r); return;
		case kDeckDeleteOnline:    HandleDeleteDeck(s, r); return;
		case kRecordSinglePlayer:  HandleRecordGame(s, r); return;
		case kSetCampaignStatus:   HandleCampaignStatus(s, r, ver); return;
		case kSetPreferences:      HandleSetPreferences(s, r); return;
		case kRequestGameplay:     HandleGameplayAchievement(s, r); return;
		case kSetListenStatus:     HandleSetListenStatus(s, r); return;
		case kRequestPostedTrades: HandleRequestPostedTrades(s); return;
		case kAddPostedTrade:      HandleAddPostedTrade(s, r); return;
		case kCancelPostedTrade:   HandleCancelPostedTrade(s, r); return;
		case kAcceptPostedTrade:   HandleAcceptPostedTrade(s, r); return;
		case kGetAccountsByName:   HandleAccountLookup(s, r, ver); return;
		case kGetGuildsByName:     HandleGuildLookup(s, r, ver); return;
		case kGetArchetypeID:      HandleGetArchetypeID(s, r); return;
		case kValidateUsername:    HandleValidateUsername(s, r); return;
		case kStoreArchetype:      HandleStoreArchetype(s, r); return;
		case kDeleteArchetype:     HandleDeleteArchetype(s, r); return;
		case kLobbyJoin:           HandleLobbyJoin(s, r); return;
		case kLobbyLeave:          HandleLobbyLeave(s, r); return;
		case kLobbyChangeStatus:   HandleLobbyChangeStatus(s, r); return;
		case kLobbySendText:       HandleLobbySendText(s, r, ver); return;
		case kLobbyAddGroups:      HandleMatchCreate(s, r, data, len); return;
		case kMatchSelectDeck:     HandleMatchSelectDeck(s, r, ver); return;
		case kMatchSetReady:       HandleMatchSetReady(s, r, ver); return;
		case kLobbyConcede:        HandleTournDrop(s); return;
		case kIssueTradeRequest:   HandleIssueTrade(s, r); return;
		case kCancelTradeRequest:  HandleCancelTradeRequest(s, r); return;
		case kAcceptTradeRequest:  HandleAcceptTradeRequest(s, r); return;
		case kAddCardToTrade:      HandleAddCardToTrade(s, r); return;
		case kRemoveCardFromTrade: HandleRemoveCardFromTrade(s, r, ver); return;
		case kClearTrade:          HandleClearTrade(s, r); return;
		case kAcceptTrade:         HandleAcceptTrade(s, r); return;
		case kFinalAcceptTrade:    HandleFinalAcceptTrade(s, r); return;
		case kEndTradeSession:     HandleEndTradeSession(s, r); return;
		default:
			LogInfo("[LoN] [{}] unhandled class [{:#x}] v[{}] ([{}] bytes)", s.name, op, ver, len);
			return;
	}
}

void OnRead(Session &s, const unsigned char *data, size_t size)
{
	s.in.insert(s.in.end(), data, data + size);
	size_t off = 0;
	while (s.in.size() - off >= 4) {
		const size_t n = (static_cast<size_t>(s.in[off]) << 24) | (static_cast<size_t>(s.in[off + 1]) << 16) |
			(static_cast<size_t>(s.in[off + 2]) << 8) | s.in[off + 3];
		if (n > kMaxFrame) {
			LogInfo("[LoN] dropping a connection that sent a [{}]-byte frame", n);
			s.in.clear();
			if (s.conn) s.conn->Disconnect();
			return;
		}
		if (s.in.size() - off - 4 < n) break;
		HandleMessage(s, s.in.data() + off + 4, n);
		off += 4 + n;
	}
	s.in.erase(s.in.begin(), s.in.begin() + static_cast<std::ptrdiff_t>(off));
}

} // namespace

namespace LoNService {

void Start()
{
	if (!RuleB(Custom, LoNEnabled)) {
		return;
	}
	if (!LoadData(RuleS(Custom, LoNDataPath))) {
		LogError("[LoN] card service NOT started");
		return;
	}
	g_data.loaded = true;

	database.QueryDatabase("DELETE FROM lon_session WHERE expires_at < NOW()");
	// An accept cut off by a shutdown never committed its swap: the trade is still open.
	database.QueryDatabase(fmt::format("UPDATE lon_posted_trade SET state = {}, accepted_by = 0 WHERE state = {}",
		static_cast<int>(kTradeOpen), static_cast<int>(kTradeAccepting)));

	const int port = RuleI(Custom, LoNPort);
	g_server = std::make_unique<EQ::Net::TCPServer>();
	g_server->Listen(port, false, [](std::shared_ptr<EQ::Net::TCPConnection> conn) {
		auto s = std::make_shared<Session>();
		s->conn = conn;
		EQ::Net::TCPConnection *key = conn.get();
		g_sessions[key] = s;
		conn->OnRead([](EQ::Net::TCPConnection *c, const unsigned char *data, size_t size) {
			auto it = g_sessions.find(c);
			if (it != g_sessions.end()) {
				std::shared_ptr<Session> keep = it->second;
				OnRead(*keep, data, size);
			}
		});
		conn->OnDisconnect([](EQ::Net::TCPConnection *c) {
			auto it = g_sessions.find(c);
			if (it != g_sessions.end()) {
				if (it->second->account_id) LogInfo("[LoN] [{}] left the card game", it->second->name);
				std::shared_ptr<Session> gone = it->second;
				g_sessions.erase(it);          // not a member any more when the others are told
				gone->conn.reset();
				if (gone->room) LeaveRoom(*gone, "disconnected from");
				if (gone->queue) LeaveQueueEx(*gone, "disconnected from", false);
				LeaveLobby(*gone);
				PvPSessionGone(*gone);
			}
		});
		conn->Start();
	});
	LogInfo("[LoN] card service listening on port [{}]", port);
}

void Process()
{
	if (!g_data.loaded) return;
	const uint32_t now = static_cast<uint32_t>(time(nullptr));
	if (now - g_last_process < 5) return;
	g_last_process = now;

	// Posted trades nobody accepted: back to the poster after Custom:LoNPostedTradeDays.
	static uint32_t last_expiry = 0;
	if (now - last_expiry >= 60) {
		last_expiry = now;
		auto e = database.QueryDatabase(fmt::format(
			"SELECT id FROM lon_posted_trade WHERE state = {} AND created_at < NOW() - INTERVAL {} DAY LIMIT 50",
			static_cast<int>(kTradeOpen), std::max(1, RuleI(Custom, LoNPostedTradeDays))));
		if (e.Success()) for (auto row : e) CloseTrade(ToU(row[0]), 0, kTradeExpired);
	}
	if (g_sessions.empty()) return;

	// A trade request nobody answers is withdrawn.
	{
		std::vector<uint32_t> stale;
		for (auto &kv : g_trades) {
			if (kv.second.state == TradeState::Requested && now - kv.second.created >= kTradeRequestSecs) stale.push_back(kv.first);
		}
		for (uint32_t id : stale) CancelRequest(id, 0);
	}

	// Casual PvP: finished or idle matches; Casual Games matches nobody joined; tournament rounds.
	ProcessPvP();
	ProcessCasual();
	ProcessTourn();

	// One card game per PC: a character IsActiveLooter() no longer allows is signed out.
	static uint32_t last_looter = 0;
	if (now - last_looter >= 10) {
		last_looter = now;
		std::vector<std::shared_ptr<Session>> drop;
		for (auto &kv : g_sessions) {
			if (kv.second->account_id && !IsActiveLooter(kv.second->character_id)) drop.push_back(kv.second);
		}
		for (auto &s : drop) {
			LogInfo("[LoN] [{}] no longer allowed by IsActiveLooter() -- card game closed", s->name);
			TellCharacter(*s, "Your card game was closed: this character is no longer your computer's active looter.");
			if (s->room) LeaveRoom(*s, "was signed out of");
			if (s->queue) LeaveQueueEx(*s, "was signed out of", true);
			LeaveLobby(*s);
			PvPSessionGone(*s);
			s->account_id = 0;
			if (s->conn) s->conn->Disconnect();
		}
	}

	for (auto &kv : g_sessions) {
		Session &s = *kv.second;
		if (!s.account_id || !s.synced) continue;
		auto d = database.QueryDatabase(fmt::format(
			"SELECT id, archetype, quantity, source FROM lon_delivery WHERE account_id = {} AND delivered_at IS NULL LIMIT 20",
			s.account_id));
		if (!d.Success() || d.RowCount() == 0) continue;
		std::vector<Inst> added;
		for (auto row : d) {
			auto claim = database.QueryDatabase(fmt::format(
				"UPDATE lon_delivery SET delivered_at = NOW() WHERE id = {} AND delivered_at IS NULL", ToU(row[0])));
			if (!claim.Success() || claim.RowsAffected() != 1) continue;
			std::vector<Inst> got = GiveCards(s.account_id, std::vector<uint32_t>(ToU(row[2]), ToU(row[1])),
				std::string("bought:") + (row[3] ? row[3] : ""));
			added.insert(added.end(), got.begin(), got.end());
		}
		if (!added.empty()) {
			Deliver(s, {}, added);
			LogInfo("[LoN] [{}] delivered [{}] purchased product(s)", s.name, added.size());
		}
	}
}

} // namespace LoNService
