// nms_housing.cpp -- native RoF2 player housing (real estate).
//
// The RoF2 client ships the complete Real Estate UI (neighborhood, plot search,
// purchase, manage and items windows) and sends the housing opcodes declared in
// common/emu_oplist.h. Nothing under zone/ handled any of them, so every click a
// player made in that UI was a silent no-op and no property window ever filled in.
//
// This file is the server half. It answers the neighborhood and plot queries from
// nms_neighborhood / nms_plot, and logs every housing opcode it receives so a
// capture can confirm the wire layouts. Placement itself is not implemented yet.
//
// Wire formats were recovered from eqgame.exe build #630 with IDA. See
// docs/rof2-housing-racechange-opcodes.md for the full opcode table and payload
// layouts. Strings in these packets are u32 length-prefixed.

#include "client.h"
#include "questmgr.h"
#include "zonedb.h"

#include "../common/strings.h"

#include "fmt/format.h"

#include <algorithm>
#include <chrono>
#include <cstring>
#include <string>
#include <unordered_map>
#include <utility>
#include <vector>

namespace {

// RoF2 senders put the player-type in the plot list as 4 and the guild-type as 8.
constexpr uint32_t kPlotOwnerPlayer = 4;
constexpr uint32_t kPlotOwnerGuild  = 8;

struct NeighborhoodRow {
	uint32_t    id               = 0;
	std::string name;
	uint32_t    guild_id         = 0;
	uint32_t    max_player_plots = 0;
	uint32_t    owned_player     = 0;
	uint32_t    max_guild_plots  = 0;
	uint32_t    owned_guild      = 0;
};

// Little-endian writer for the real-estate wire format.
// Custom base64 alphabet used for the 16-character real-estate identifier (table at
// 0xB61D20). sub_80C920 accepts a 16-character string only when decoding and re-encoding it
// reproduces it exactly, so the value has to be produced with this alphabet.
constexpr char kRealEstateIdAlphabet[] = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz+-";

std::string MakeRealEstateId(uint32_t zone_id, uint32_t door_id)
{
	const uint8_t raw[12] = {
		0, 0, 0, 0,
		static_cast<uint8_t>(zone_id & 0xFF), static_cast<uint8_t>((zone_id >> 8) & 0xFF), 0, 0,
		static_cast<uint8_t>(door_id & 0xFF), 0, 0, 0
	};

	auto A = [](int i) { return kRealEstateIdAlphabet[i & 0x3F]; };

	std::string s(16, '\0');
	s[0]  = A(raw[0] >> 2);
	s[1]  = A((raw[1] >> 4) | (16 * (raw[0] & 3)));
	s[2]  = A((raw[2] >> 6) | (4 * (raw[1] & 0xF)));
	s[3]  = A(raw[2] & 0x3F);
	s[4]  = A(raw[3] >> 2);
	s[5]  = A((raw[4] >> 4) | (16 * (raw[3] & 3)));
	s[6]  = A((raw[5] >> 6) | (4 * (raw[4] & 0xF)));
	s[7]  = A(raw[5] & 0x3F);
	s[8]  = A(raw[6] >> 2);
	s[9]  = A((raw[7] >> 4) | (16 * (raw[6] & 3)));
	s[10] = A((raw[8] >> 6) | (4 * (raw[7] & 0xF)));
	s[11] = A(raw[8] & 0x3F);
	s[12] = A(raw[9] >> 2);
	s[13] = A((raw[10] >> 4) | (16 * (raw[9] & 3)));
	s[14] = A((raw[11] >> 6) | (4 * (raw[10] & 0xF)));
	s[15] = A(raw[11] & 0x3F);
	return s;
}

class Writer {
public:
	void U8(uint8_t v) { m_buf.push_back(v); }

	void Float(float v) {
		uint32_t bits = 0;
		std::memcpy(&bits, &v, 4);
		U32(bits);
	}

	// Overwrites a previously written u32 in place (used to backfill a count header).
	void PatchU32(size_t offset, uint32_t v) {
		if (offset + 4 <= m_buf.size()) {
			std::memcpy(m_buf.data() + offset, &v, 4);
		}
	}

	void U16(uint16_t v) {
		m_buf.push_back(v & 0xFF);
		m_buf.push_back((v >> 8) & 0xFF);
	}

	void U32(uint32_t v) {
		for (int i = 0; i < 4; ++i) {
			m_buf.push_back(static_cast<uint8_t>((v >> (8 * i)) & 0xFF));
		}
	}

	// Signed 64-bit, little endian: the cost-scheme values and escrow balances are i64/f64.
	void Wide(int64_t v) {
		for (int i = 0; i < 8; ++i) {
			m_buf.push_back(static_cast<uint8_t>((static_cast<uint64_t>(v) >> (8 * i)) & 0xFF));
		}
	}

	void Double(double v) {
		uint64_t bits = 0;
		std::memcpy(&bits, &v, 8);
		Wide(static_cast<int64_t>(bits));
	}

	void Str(const std::string &s) {
		U32(static_cast<uint32_t>(s.size()));
		m_buf.insert(m_buf.end(), s.begin(), s.end());
	}

	// Null-terminated string, for packets that read strings with strlen rather than a
	// length prefix (the 0x626e side does).
	void CStr(const std::string &s) {
		m_buf.insert(m_buf.end(), s.begin(), s.end());
		m_buf.push_back(0);
	}

	const std::vector<uint8_t> &Buffer() const { return m_buf; }

private:
	std::vector<uint8_t> m_buf;
};

std::string HexDump(const EQApplicationPacket *app, size_t limit = 160)
{
	std::string out;
	const size_t n = std::min<size_t>(app->size, limit);
	for (size_t i = 0; i < n; ++i) {
		out += fmt::format("{:02x}", app->pBuffer[i]);
		if ((i & 3) == 3 && i + 1 < n) {
			out += ' ';
		}
	}
	if (app->size > limit) {
		out += fmt::format(" ... ({} bytes total)", app->size);
	}
	return out;
}

std::vector<NeighborhoodRow> LoadNeighborhoods(const std::string &zone_short_name)
{
	std::vector<NeighborhoodRow> rows;

	auto results = database.QueryDatabase(fmt::format(
		"SELECT nb.id, nb.name, nb.guild_id, nb.max_player_plots, nb.max_guild_plots, "
		"  (SELECT COUNT(*) FROM nms_plot p WHERE p.neighborhood_id = nb.id "
		"     AND p.plot_type = 0 AND p.owner_char_id > 0) AS owned_player, "
		"  (SELECT COUNT(*) FROM nms_plot p WHERE p.neighborhood_id = nb.id "
		"     AND p.plot_type = 1 AND p.owner_guild_id > 0) AS owned_guild "
		"FROM nms_neighborhood nb WHERE nb.zone = '{}'",
		Strings::Escape(zone_short_name)
	));

	if (!results.Success()) {
		LogInfo("[Housing] nms_neighborhood query failed in zone [{}]", zone_short_name);
		return rows;
	}

	for (auto row : results) {
		NeighborhoodRow r;
		r.id               = Strings::ToUnsignedInt(row[0]);
		r.name             = std::string(row[1] ? row[1] : "");
		r.guild_id         = Strings::ToUnsignedInt(row[2]);
		r.max_player_plots = Strings::ToUnsignedInt(row[3]);
		r.max_guild_plots  = Strings::ToUnsignedInt(row[4]);
		r.owned_player     = Strings::ToUnsignedInt(row[5]);
		r.owned_guild      = Strings::ToUnsignedInt(row[6]);
		rows.push_back(r);
	}

	return rows;
}

void SendNeighborhoodList(Client *c, const std::string &zone_short_name)
{
	// No identity resend here. It was a safety net for a zone-in timing problem, but the
	// branch that would consume it is unreachable in this client build (see docs section 8b),
	// and the client re-requests the list on every dropdown change -- so it only multiplied
	// packets.
	const auto rows = LoadNeighborhoods(zone_short_name);

	Writer w;
	// Header. The client consumes a leading u32 and discards it, then reads a
	// kind byte; anything other than 4 or 8 takes the list path, where a u32
	// search type selects the neighborhood list (0/1/2) or the plot list (4/5).
	w.U32(0);
	w.U8(0);
	w.U32(0);

	w.U16(static_cast<uint16_t>(rows.size()));
	// The client only redraws the neighborhood window when this byte is non-zero
	// (sub_74AB50: "if ((_BYTE)v40) ... UpdateWindow"). Sending zero populates the
	// list but leaves the window stale.
	w.U8(1);
	w.U32(0);  // one value the client reads before the entries

	for (const auto &r : rows) {
		w.U32(r.id);
		w.Str(r.name);
		// The client treats 0xFFFFFFFF as "no guild owns this neighborhood".
		w.U32(r.guild_id ? r.guild_id : 0xFFFFFFFFu);
		w.U32(r.max_player_plots);
		w.U32(r.owned_player);
		w.U32(r.max_guild_plots);
		w.U32(r.owned_guild);
	}

	const auto &buf = w.Buffer();

	if (buf.empty()) {
		return;
	}

	auto outapp = new EQApplicationPacket(OP_RealEstateNeighborhood, static_cast<uint32>(buf.size()));
	std::memcpy(outapp->pBuffer, buf.data(), buf.size());

	c->QueuePacket(outapp);
	safe_delete(outapp);

	LogInfo(
		"[Housing] sent neighborhood list to [{}]: {} neighborhood(s), {} bytes",
		c->GetName(), rows.size(), buf.size()
	);
}

struct PlotRow {
	uint32_t    door_id    = 0;
	uint32_t    owner_type = 4;
	std::string owner_name;
	std::string address;
};// Only owned plots appear in the plot list: the client's reader (sub_74C4C0) adds a
// row only when the owner type is 4 (Player) or 8 (Guild). Vacant lots are simply
// absent from this list.
std::vector<PlotRow> LoadOwnedPlots(const std::string &zone_short_name)
{
	std::vector<PlotRow> rows;

	auto results = database.QueryDatabase(fmt::format(
		"SELECT p.door_id, p.plot_type, COALESCE(c.name, ''), COALESCE(g.name, ''), nb.name "
		"FROM nms_plot p "
		"JOIN nms_neighborhood nb ON nb.id = p.neighborhood_id "
		"LEFT JOIN character_data c ON c.id = p.owner_char_id "
		"LEFT JOIN guilds g ON g.id = p.owner_guild_id "
		"WHERE nb.zone = '{}' AND (p.owner_char_id > 0 OR p.owner_guild_id > 0) "
		"ORDER BY p.door_id",
		Strings::Escape(zone_short_name)
	));

	if (!results.Success()) {
		LogInfo("[Housing] nms_plot query failed in zone [{}]", zone_short_name);
		return rows;
	}

	for (auto row : results) {
		PlotRow r;
		r.door_id = Strings::ToUnsignedInt(row[0]);

		const uint32_t plot_type    = Strings::ToUnsignedInt(row[1]);
		const std::string char_name = std::string(row[2] ? row[2] : "");
		const std::string guild_name = std::string(row[3] ? row[3] : "");
		const std::string nb_name   = std::string(row[4] ? row[4] : "");

		if (plot_type == 1) {
			r.owner_type = kPlotOwnerGuild;
			r.owner_name = guild_name;
		}
		else {
			r.owner_type = kPlotOwnerPlayer;
			r.owner_name = char_name;
		}

		// The plot list's second per-entry string is the Address column (confirmed against the
		// live client: row order is Address, Type, Owner). There is no address data column, so
		// synthesize a stable one from the lot number and the neighborhood name.
		r.address = fmt::format("Lot {} {}", r.door_id, nb_name);

		rows.push_back(r);
	}

	return rows;
}

void SendPlotList(Client *c, const std::string &zone_short_name, uint32_t search_type)
{
	const auto rows = LoadOwnedPlots(zone_short_name);

	Writer w;
	w.U32(0);
	w.U8(0);
	w.U32(search_type);   // 4 or 5 selects the plot-list path (sub_74C4C0)
	w.U16(static_cast<uint16_t>(rows.size()));

	// sub_74C4C0 reads a length-prefixed string between the count and the entries (the
	// search text, fed to a virtual on the window). Leaving it out made the client read
	// the next u32 as a string length and run off the end of the packet -- that crashed
	// the RoF2 client.
	w.Str("");

	for (const auto &r : rows) {
		w.U32(r.door_id);
		w.U32(r.owner_type);
		w.U32(0);
		w.Str(r.owner_name);
		w.Str(r.address);   // second per-entry string = the Address column (live-confirmed)
	}

	const auto &buf = w.Buffer();

	if (buf.empty()) {
		return;
	}

	auto outapp = new EQApplicationPacket(OP_RealEstateNeighborhood, static_cast<uint32>(buf.size()));
	std::memcpy(outapp->pBuffer, buf.data(), buf.size());

	c->QueuePacket(outapp);
	safe_delete(outapp);

	LogInfo(
		"[Housing] sent plot list to [{}]: {} owned plot(s), search type [{}], {} bytes",
		c->GetName(), rows.size(), search_type, buf.size()
	);
}

uint32_t ReadU32(const EQApplicationPacket *app, size_t offset)
{
	if (offset + 4 > app->size) {
		return 0;
	}

	uint32_t value = 0;
	std::memcpy(&value, app->pBuffer + offset, 4);
	return value;
}

// A player may own at most two plots.
constexpr uint32_t kMaxPlotsPerPlayer = 2;

// RealEstate object field +60. sub_7F5F70() returns true only for this value, and
// RealEstate[+144] (which gates every real-estate action) is that field after the
// object is registered from the 0x6fd0 packet.
constexpr uint32_t kRealEstateKindNeighborhood = 5;

// The other definition kinds the client's predicates test for (sub_7F6280 tests 8,
// sub_7F6030 accepts {4, 8} for the "object under my feet" spatial test, and the
// house-ancestor walk mask sub_7F62B0() == 0x88 = kinds {4, 8}).
constexpr uint32_t kRealEstateKindHouse = 4;
constexpr uint32_t kRealEstateKindPlot  = 8;

// Per-plot definition and region ids. A region resolves through the estate's definition, so
// the plot's definition carries area_id = PlotRegionId(door) and the 0x49df record repeats it.
constexpr uint32_t kPlotDefinitionBase = 500;
constexpr uint32_t kPlotRegionBase     = 900000;

uint32_t PlotDefinitionId(uint32_t door_id) { return kPlotDefinitionBase + door_id; }
uint32_t PlotRegionId(uint32_t door_id)     { return kPlotRegionBase + door_id; }

// The client's placement payload carries the world position it acted on at
// offsets 52 (x) and 56 (y). Resolve that to the nearest lot marker.
struct NearestPlot {
	bool     found                = false;
	uint32_t plot_id              = 0;
	uint32_t door_id              = 0;
	uint32_t owner_char_id        = 0;
	uint32_t owner_guild_id       = 0;
	uint32_t plot_type            = 0;   // 0 player, 1 guild
	uint32_t neighborhood_guild_id = 0;  // 0 = open neighborhood
	double   distance             = 0.0;
};

NearestPlot FindNearestPlot(const std::string &zone_short_name, float x, float y)
{
	NearestPlot out;

	auto results = database.QueryDatabase(fmt::format(
		"SELECT p.id, p.door_id, p.owner_char_id, p.owner_guild_id, p.plot_type, nb.guild_id, "
		"  ((d.pos_x - {0}) * (d.pos_x - {0}) + (d.pos_y - {1}) * (d.pos_y - {1})) AS dist "
		"FROM nms_plot p "
		"JOIN nms_neighborhood nb ON nb.id = p.neighborhood_id "
		"JOIN doors d ON d.zone = nb.zone AND d.doorid = p.door_id AND d.version = 0 "
		"WHERE nb.zone = '{2}' "
		"ORDER BY dist LIMIT 1",
		x, y, Strings::Escape(zone_short_name)
	));

	if (!results.Success() || results.RowCount() == 0) {
		return out;
	}

	auto row = results.begin();
	out.found                 = true;
	out.plot_id               = Strings::ToUnsignedInt(row[0]);
	out.door_id               = Strings::ToUnsignedInt(row[1]);
	out.owner_char_id         = Strings::ToUnsignedInt(row[2]);
	out.owner_guild_id        = Strings::ToUnsignedInt(row[3]);
	out.plot_type             = Strings::ToUnsignedInt(row[4]);
	out.neighborhood_guild_id = Strings::ToUnsignedInt(row[5]);
	out.distance              = Strings::ToFloat(row[6]);

	return out;
}

uint32_t PlotsOwnedBy(uint32_t char_id)
{
	auto results = database.QueryDatabase(fmt::format(
		"SELECT COUNT(*) FROM nms_plot WHERE owner_char_id = {}", char_id
	));

	if (!results.Success() || results.RowCount() == 0) {
		return 0;
	}

	return Strings::ToUnsignedInt(results.begin()[0]);
}

// Ten years, matching the realtor in quests/neighborhood/Christine.lua.
constexpr uint32_t kHouseDuration = 315360000;

// A plot needs a house interior. Which house a plot gets is what the client's purchase
// window is meant to choose, and that handshake is not implemented, so every plot falls
// back to a one-bedroom interior for now.
constexpr const char *kDefaultHouseZone = "phinterior1a1";

// "Zimel Style Stucco House, Stucco interior" -- a real house item in this database.
constexpr uint32_t kDefaultHouseItem = 61823;

// A character keeps one house. If they already own one (for example through the realtor)
// the plot points at that house rather than creating a second interior.
void AttachHouseToPlot(Client *c, const NearestPlot &plot)
{
	uint32_t    house_id = 0;
	std::string house_zone;

	auto existing = database.QueryDatabase(fmt::format(
		"SELECT id, zone FROM house WHERE char_id = {} LIMIT 1", c->CharacterID()
	));

	if (existing.Success() && existing.RowCount()) {
		auto row = existing.begin();
		house_id   = Strings::ToUnsignedInt(row[0] ? row[0] : "0");
		house_zone = row[1] ? row[1] : kDefaultHouseZone;

		LogInfo(
			"[Housing] [{}] already has house #{} in [{}]; linking lot {} to it",
			c->GetName(), house_id, house_zone, plot.plot_id
		);
	}
	else {
		house_zone = kDefaultHouseZone;

		const uint32_t instance_id = quest_manager.CreateInstance(house_zone, 0, kHouseDuration);

		if (!instance_id) {
			LogInfo("[Housing] could not create an instance of [{}] for [{}]", house_zone, c->GetName());
			return;
		}

		auto inserted = database.QueryDatabase(fmt::format(
			"INSERT INTO house (char_id, instance_id, zone) VALUES ({}, {}, '{}')",
			c->CharacterID(), instance_id, Strings::Escape(house_zone)
		));

		if (!inserted.Success()) {
			LogInfo("[Housing] house insert failed for [{}] on lot {}", c->GetName(), plot.plot_id);
			return;
		}

		house_id = static_cast<uint32_t>(inserted.LastInsertedID());

		LogInfo(
			"[Housing] [{}] created house #{} in [{}] instance [{}] for lot {}",
			c->GetName(), house_id, house_zone, instance_id, plot.plot_id
		);
	}

	database.QueryDatabase(fmt::format(
		"UPDATE nms_plot SET house_id = {}, house_zone = '{}' WHERE id = {}",
		house_id, Strings::Escape(house_zone), plot.plot_id
	));
}

// Provisional: until the purchase handshake is confirmed against a live client,
// acting on a vacant lot claims it for the character and nothing else. The
// client is then sent the plot list, whose format is known.
void TryClaimPlot(Client *c, const std::string &zone_short_name, float x, float y)
{
	const auto plot = FindNearestPlot(zone_short_name, x, y);

	if (!plot.found) {
		LogInfo("[Housing] placement from [{}] at ({:.2f}, {:.2f}) matched no lot", c->GetName(), x, y);
		return;
	}

	if (plot.owner_char_id || plot.owner_guild_id) {
		LogInfo(
			"[Housing] placement from [{}] ignored: lot {} (door {}) is already owned by char [{}] / guild [{}]",
			c->GetName(), plot.plot_id, plot.door_id, plot.owner_char_id, plot.owner_guild_id
		);
		return;
	}

	const uint32_t guild_id = c->GuildID();

	// A neighborhood bound to a guild admits only that guild's members. This is the
	// "assignment of guilds to areas": dbstr 52656 (the charter) and eqstr 5317, "this is
	// a guild neighborhood and you are not a member of the guild".
	if (plot.neighborhood_guild_id && guild_id != plot.neighborhood_guild_id) {
		LogInfo(
			"[Housing] placement from [{}] refused: neighborhood owned by guild [{}], player guild [{}]",
			c->GetName(), plot.neighborhood_guild_id, guild_id
		);
		return;
	}

	const bool is_guild_plot = (plot.plot_type == 1);

	if (is_guild_plot && guild_id == 0) {
		LogInfo("[Housing] placement from [{}] refused: guild plot but player has no guild", c->GetName());
		return;
	}

	uint32_t owned = 0;

	if (!is_guild_plot) {
		owned = PlotsOwnedBy(c->CharacterID());

		if (owned >= kMaxPlotsPerPlayer) {
			LogInfo(
				"[Housing] placement from [{}] refused: already owns {} plot(s), limit is {}",
				c->GetName(), owned, kMaxPlotsPerPlayer
			);
			return;
		}
	}

	// Guild plots belong to the guild, player plots to the character.
	const char    *owner_column = is_guild_plot ? "owner_guild_id" : "owner_char_id";
	const uint32_t owner_id     = is_guild_plot ? guild_id : c->CharacterID();

	auto update = database.QueryDatabase(fmt::format(
		"UPDATE nms_plot SET {} = {}, purchased_at = NOW(), "
		"upkeep_paid_until = DATE_ADD(NOW(), INTERVAL 30 DAY) "
		"WHERE id = {} AND owner_char_id = 0 AND owner_guild_id = 0",
		owner_column, owner_id, plot.plot_id
	));

	if (!update.Success() || update.RowsAffected() == 0) {
		LogInfo("[Housing] claim of lot {} by [{}] did not apply", plot.plot_id, c->GetName());
		return;
	}

	LogInfo(
		"[Housing] [{}] claimed {} lot {} (door {}, {:.1f} units away) for {} [{}]{}",
		c->GetName(), is_guild_plot ? "guild" : "player", plot.plot_id, plot.door_id, plot.distance,
		is_guild_plot ? "guild" : "character", owner_id,
		is_guild_plot ? "" : fmt::format(" - now owns {} plot(s)", owned + 1)
	);

	AttachHouseToPlot(c, plot);

	// Do NOT send the plot list here. A claim used to answer with the 0x2691 plot list and
	// the RoF2 client crashed on it (its last packet was the same second the list went
	// out). The list layout is parser-derived only and has never been validated against a
	// live client, so it stays off until it is. The claim itself is persisted above.
	LogInfo("[Housing] lot {} claimed; plot list response suppressed pending format validation", plot.plot_id);
}

void LogHousingOpcode(Client *c, const EQApplicationPacket *app, const char *name)
{
	LogInfo(
		"[Housing] {} from [{}] size [{}] payload [{}]",
		name, c->GetName(), app->size, HexDump(app)
	);
}

} // namespace

// Defined with the other wire encoders below; the placement-begin handler answers with it.
bool SendPlacementPreview(Client *c, uint32_t door_id, uint32_t item_id, const std::string &model,
                          uint32_t zone_id, uint32_t neighborhood_id,
                          float x, float y, float z, float heading);

// Log-only handlers for the real-estate messages this server does not implement yet.
// They exist so the client's own clicks land in the zone log with a name and a hex dump:
// without them the packets arrive as unknown opcodes and vanish, which is why the UI looked
// dead while it was in fact talking to us.
#define NMS_HOUSING_LOG_ONLY(op)                                      \
	void Client::Handle_##op(const EQApplicationPacket *app)          \
	{                                                                 \
		LogHousingOpcode(this, app, #op);                              \
	}

NMS_HOUSING_LOG_ONLY(OP_RealEstatePickup)          // 0x2036 cursor pickup of a placed item
NMS_HOUSING_LOG_ONLY(OP_RealEstateItemOperation)   // 0x3424 item operation request
NMS_HOUSING_LOG_ONLY(OP_RealEstateHouseSwap)       // 0x21ba
NMS_HOUSING_LOG_ONLY(OP_RealEstateEscrow)          // 0x2aa6
NMS_HOUSING_LOG_ONLY(OP_RealEstateTextRequest)     // 0x3c8b
NMS_HOUSING_LOG_ONLY(OP_RealEstateItemInspect)     // 0x58c7
NMS_HOUSING_LOG_ONLY(OP_RealEstateLoadLayout)      // 0x5b41
NMS_HOUSING_LOG_ONLY(OP_RealEstatePack)            // 0x613d
NMS_HOUSING_LOG_ONLY(OP_RealEstateVotingOptOut)    // 0x6573
NMS_HOUSING_LOG_ONLY(OP_RealEstateStoreAll)        // 0x6917
NMS_HOUSING_LOG_ONLY(OP_RealEstateSale)            // 0x792c
NMS_HOUSING_LOG_ONLY(OP_RealEstateInspect)         // 0x796c
NMS_HOUSING_LOG_ONLY(OP_RealEstateAction5Request)  // 0x7ad1

#undef NMS_HOUSING_LOG_ONLY

// Defined with the wire encoders below.
void SendRealEstateExteriors(Client *c);

// Reads a float at an offset, for request bodies the client sends as floats.
float ReadFloatAt(const EQApplicationPacket *app, size_t offset)
{
	if (offset + 4 > app->size) {
		return 0.0f;
	}

	float value = 0.0f;
	std::memcpy(&value, app->pBuffer + offset, 4);
	return value;
}

// Claims a vacant lot for this character (or their guild, for a guild plot).
bool ClaimPlotByDoor(Client *c, const std::string &zone_name, uint32_t door_id)
{
	auto plot = database.QueryDatabase(fmt::format(
		"SELECT p.plot_type, p.owner_char_id, p.owner_guild_id FROM nms_plot p "
		"JOIN nms_neighborhood n ON n.id = p.neighborhood_id "
		"WHERE n.zone = '{}' AND p.door_id = {} LIMIT 1",
		Strings::Escape(zone_name), door_id
	));

	if (!plot.Success() || !plot.RowCount()) {
		return false;
	}

	auto row = plot.begin();

	const uint32_t plot_type   = Strings::ToUnsignedInt(row[0] ? row[0] : "0");
	const uint32_t owner_char  = Strings::ToUnsignedInt(row[1] ? row[1] : "0");
	const uint32_t owner_guild = Strings::ToUnsignedInt(row[2] ? row[2] : "0");

	if (owner_char || owner_guild) {
		return owner_char == c->CharacterID() ||
		       (plot_type == 1 && owner_guild && owner_guild == c->GuildID());
	}

	if (plot_type == 1 && !c->GuildID()) {
		return false;
	}

	auto update = database.QueryDatabase(fmt::format(
		"UPDATE nms_plot p JOIN nms_neighborhood n ON n.id = p.neighborhood_id "
		"SET p.owner_char_id = {}, p.owner_guild_id = {}, p.purchased_at = NOW(), "
		"    p.upkeep_paid_until = DATE_ADD(NOW(), INTERVAL 7 DAY) "
		"WHERE n.zone = '{}' AND p.door_id = {} AND p.owner_char_id = 0 AND p.owner_guild_id = 0",
		plot_type == 1 ? 0 : c->CharacterID(),
		plot_type == 1 ? c->GuildID() : 0,
		Strings::Escape(zone_name), door_id
	));

	LogInfo(
		"[Housing] claim lot [{}] for [{}]: type [{}] affected [{}]",
		door_id, c->GetName(), plot_type, update.Success() ? update.RowsAffected() : 0
	);

	return update.Success() && update.RowsAffected() > 0;
}

// 0x45be C2S purchase: 188-byte envelope, estate id at 0, price/upkeep components at 172/176.
// The S2C side consumes one byte; nonzero shows the management window.
void Client::Handle_OP_RealEstatePurchase(const EQApplicationPacket *app)
{
	LogHousingOpcode(this, app, "OP_RealEstatePurchase");

	if (!zone || app->size < 12) {
		return;
	}

	const uint32_t estate_id = ReadU32(app, 0);
	const uint32_t price     = app->size >= 176 ? ReadU32(app, 172) : 0;
	const uint32_t upkeep    = app->size >= 180 ? ReadU32(app, 176) : 0;

	if (!ClaimPlotByDoor(this, zone->GetShortName(), estate_id)) {
		Message(Chat::White, "[housing] that plot is not available.");
		return;
	}

	LogInfo(
		"[Housing] purchase by [{}]: estate [{}], price component [{}], upkeep component [{}]",
		GetName(), estate_id, price, upkeep
	);

	Writer response;
	response.U8(1);

	const auto &bytes = response.Buffer();
	auto outapp = new EQApplicationPacket(OP_RealEstatePurchase, static_cast<uint32>(bytes.size()));
	std::memcpy(outapp->pBuffer, bytes.data(), bytes.size());
	QueuePacket(outapp);
	safe_delete(outapp);

	Message(Chat::White, fmt::format("[housing] plot [{}] is yours.", estate_id).c_str());

	SendRealEstateIdentity();
}

// 0x711a C2S commit: 96 bytes -- estate 32, item 36, heading 44, position Y/X/Z 60..68. We
// persist the building pose and consume nothing (furniture custody is not implemented).
void Client::Handle_OP_RealEstatePlacementCommit(const EQApplicationPacket *app)
{
	LogHousingOpcode(this, app, "OP_RealEstatePlacementCommit");

	if (!zone || std::string(zone->GetShortName()) != "neighborhood" || app->size < 96) {
		return;
	}

	const uint32_t estate_id = ReadU32(app, 32);
	const uint32_t item_id   = ReadU32(app, 36);

	const float heading = ReadFloatAt(app, 44);
	const float pos_y   = ReadFloatAt(app, 60);
	const float pos_x   = ReadFloatAt(app, 64);
	const float pos_z   = ReadFloatAt(app, 68);

	auto update = database.QueryDatabase(fmt::format(
		"UPDATE nms_plot p JOIN nms_neighborhood n ON n.id = p.neighborhood_id "
		"SET p.house_x = {}, p.house_y = {}, p.house_z = {}, p.house_heading = {} "
		"WHERE n.zone = '{}' AND p.door_id = {} AND p.house_item_id = {} "
		"  AND (p.owner_char_id = {} OR (p.owner_guild_id > 0 AND p.owner_guild_id = {}))",
		pos_x, pos_y, pos_z, heading,
		Strings::Escape(zone->GetShortName()), estate_id, item_id,
		CharacterID(), GuildID()
	));

	LogInfo(
		"[Housing] placement commit from [{}]: estate [{}], item [{}], pose ({:.1f}, {:.1f}, {:.1f}) "
		"heading {:.1f}, rows [{}]",
		GetName(), estate_id, item_id, pos_x, pos_y, pos_z, heading,
		update.Success() ? update.RowsAffected() : 0
	);

	if (update.Success() && update.RowsAffected()) {
		SendRealEstateExteriors(this);
	}
}

// 0x050c C2S item query: answered with a well-formed EMPTY 0x1cef (estate id + zero count).
// The per-entry ItemPtr framing is not implemented, and a guessed entry can crash the client.
void Client::Handle_OP_RealEstateItemQuery(const EQApplicationPacket *app)
{
	LogHousingOpcode(this, app, "OP_RealEstateItemQuery");

	if (app->size < 4) {
		return;
	}

	const uint32_t estate_id = ReadU32(app, 0);

	Writer w;
	w.U32(estate_id);
	w.U32(0);

	const auto &buf = w.Buffer();
	auto outapp = new EQApplicationPacket(OP_RealEstateItemList, static_cast<uint32>(buf.size()));
	std::memcpy(outapp->pBuffer, buf.data(), buf.size());
	QueuePacket(outapp);
	safe_delete(outapp);

	LogInfo("[Housing] answered item query for estate [{}] with an empty list", estate_id);
}


void Client::Handle_OP_RealEstateNeighborhood(const EQApplicationPacket *app)
{
	LogHousingOpcode(this, app, "OP_RealEstateNeighborhood");

	// The search request carries its search type in the first u32: 4 and 5 are the
	// address searches that expect the plot list back, everything else is a
	// neighborhood query.
	const uint32_t search_type = ReadU32(app, 0);

	if (search_type == 4 || search_type == 5) {
		// Only ever on an explicit client request, never from a GM claim: the layout is
		// parser-derived and one omission in it already crashed the client once.
		SendPlotList(this, zone->GetShortName(), search_type);
	}
	else {
		SendNeighborhoodList(this, zone->GetShortName());
	}
}

void Client::Handle_OP_RealEstateGo(const EQApplicationPacket *app)
{
	LogHousingOpcode(this, app, "OP_RealEstateGo");

	// Observed body (12 bytes): estate id, item id, 0. The client sends this when the player
	// asks to enter an estate -- 19 / 61874 in our own capture, i.e. the lot and its building.
	// Zone them into the interior the lot is linked to; #housing enter does the same lookup
	// from the character side.
	if (!zone || app->size < 8) {
		return;
	}

	const uint32_t estate_id = ReadU32(app, 0);

	auto house = database.QueryDatabase(fmt::format(
		"SELECT h.instance_id FROM nms_plot p "
		"JOIN nms_neighborhood n ON n.id = p.neighborhood_id "
		"JOIN house h ON h.id = p.house_id "
		"WHERE n.zone = '{}' AND p.door_id = {} "
		"  AND (p.owner_char_id = {} OR (p.owner_guild_id > 0 AND p.owner_guild_id = {})) "
		"LIMIT 1",
		Strings::Escape(zone->GetShortName()), estate_id, CharacterID(), GuildID()
	));

	if (!house.Success() || !house.RowCount()) {
		LogInfo("[Housing] go: estate [{}] has no interior linked for [{}]", estate_id, GetName());
		return;
	}

	const uint32_t instance_id = Strings::ToUnsignedInt(house.begin()[0] ? house.begin()[0] : "0");

	if (!instance_id) {
		return;
	}

	Message(Chat::White, "[housing] entering your house...");
	MoveZoneInstance(static_cast<uint16>(instance_id));
}

void Client::Handle_OP_RealEstatePlacementBegin(const EQApplicationPacket *app)
{
	LogHousingOpcode(this, app, "OP_RealEstatePlacementBegin");

	// Recovered Begin body: GUID 18 + padding 2 + source location 12, estate id at 32,
	// item id at 36, opaque 4, action 4, flag 1, padding 3, screen x/y at 52/56.
	//
	// The two floats are SCREEN coordinates, not world units. The previous handler claimed
	// the nearest lot from them, which would have claimed an essentially arbitrary plot on
	// every placement. Claiming is now only the explicit #housing claim path.
	if (!zone || std::string(zone->GetShortName()) != "neighborhood" || app->size < 60) {
		return;
	}

	const uint32_t estate_id = ReadU32(app, 32);
	const uint32_t item_id   = ReadU32(app, 36);

	// Answer with the placement preview -- the documented server side of Begin -- when the
	// estate is a lot this character may build on. Anything else is logged and dropped: no
	// claim, no consume, no preview.
	auto rows = database.QueryDatabase(fmt::format(
		"SELECT d.pos_x, d.pos_y, d.pos_z, d.heading, n.id, COALESCE(it.idfile, ''), COALESCE(it.Name, '') "
		"FROM nms_plot p "
		"JOIN nms_neighborhood n ON n.id = p.neighborhood_id "
		"JOIN doors d ON d.zone = n.zone AND d.doorid = p.door_id AND d.version = 0 "
		"LEFT JOIN items it ON it.id = {} "
		"WHERE n.zone = '{}' AND p.door_id = {} "
		"  AND (p.owner_char_id = {} OR (p.owner_guild_id > 0 AND p.owner_guild_id = {})) "
		"LIMIT 1",
		item_id, Strings::Escape(zone->GetShortName()), estate_id, CharacterID(), GuildID()
	));

	if (!rows.Success() || !rows.RowCount()) {
		LogInfo(
			"[Housing] placement begin from [{}]: estate [{}] item [{}] is not a buildable lot for this character",
			GetName(), estate_id, item_id
		);
		return;
	}

	auto row = rows.begin();

	const std::string model = (row[5] && *row[5]) ? row[5] : (row[6] ? row[6] : "");

	if (model.empty()) {
		return;
	}

	SendPlacementPreview(
		this, estate_id, item_id, model, zone->GetZoneID(), Strings::ToUnsignedInt(row[4]),
		static_cast<float>(Strings::ToFloat(row[0] ? row[0] : "0")),
		static_cast<float>(Strings::ToFloat(row[1] ? row[1] : "0")),
		static_cast<float>(Strings::ToFloat(row[2] ? row[2] : "0")),
		static_cast<float>(Strings::ToFloat(row[3] ? row[3] : "0"))
	);
}

// ---------------------------------------------------------------------------
// Real-estate wire encoders.
//
// Field order and the documented/opaque split follow the public RoF2 housing
// reconstruction (github.com/nightstalker6669/eqemu-rof2-housing, GPLv3):
// protocol/STRUCTS.md plus overlay/common/housing/estate_wire.h and
// placement_wire.h. Those codecs were accepted in game against the same May 2013
// client build, so their serialization replaces the ad-hoc bodies this file used
// to hand-build -- notably the 0x626e preview and the estate snapshot tail.
//
// What they establish is layout only. Every catalog value below (capacities,
// prices, upkeep) stays labelled emulator policy, not recovered 2013 Live data.
// ---------------------------------------------------------------------------

struct EstateDefinition {
	uint32_t    id                   = 0;   // defs-map key: the client looks definitions up by it
	uint32_t    area_id              = 0;
	uint32_t    purchase_scheme      = 0;   // 0 = no cost scheme published
	uint32_t    upkeep_scheme        = 0;
	uint32_t    max_items            = 0;
	uint32_t    max_non_estate_items = 0;
	uint32_t    max_children         = 0;
	uint32_t    zone_id              = 0;
	uint32_t    dynamic_zone_id      = 0;
	uint32_t    type                 = 0;   // 5 neighborhood, 8 plot, 4 house
	uint32_t    group_id             = 0;
	std::string address;
	uint32_t    icon                 = 0;
	uint32_t    max_npc_items        = 0;
	float       switch_x             = 0.0f;
	float       switch_y             = 0.0f;
	float       switch_z             = 0.0f;
	float       switch_heading       = 0.0f;
	std::vector<uint32_t> children;
};

void WriteEstateDefinition(Writer &w, const EstateDefinition &d)
{
	for (uint32_t field : { d.id, d.area_id, d.purchase_scheme, d.upkeep_scheme, d.max_items,
	                        d.max_non_estate_items, d.max_children, d.zone_id, d.dynamic_zone_id,
	                        d.type, d.group_id }) {
		w.U32(field);
	}

	w.Str(d.address);
	w.U32(d.icon);
	w.U32(d.max_npc_items);
	w.Float(d.switch_x);
	w.Float(d.switch_y);
	w.Float(d.switch_z);
	w.Float(d.switch_heading);
	w.U32(static_cast<uint32_t>(d.children.size()));

	for (uint32_t child : d.children) {
		w.U32(child);
	}
}

// The body 0x6fd0 (zone context) and 0x63fd (snapshot) share. Fields the client reads
// but this server cannot populate yet (escrow currencies, upkeep components) are emitted
// as their zero/no-guild forms instead of being left out of the packet.
struct EstateSnapshot {
	uint32_t    estate_id     = 0;
	uint32_t    static_id     = 0;
	uint32_t    parent_id     = 0;
	uint32_t    definition_id = 0;
	uint32_t    guild_id      = 0xFFFFFFFF;   // 0xFFFFFFFF = no guild
	uint32_t    fellowship_id = 0;
	std::string owner_name;
	std::string owner_handle;
	uint32_t    default_permission_level = 0;
	std::vector<uint32_t> children;
	std::string dynamic_name;
	std::vector<std::pair<uint32_t, double>> escrow;   // currency key, balance
	uint32_t    upkeep_component = 0;
	uint32_t    expiry_time      = 0;   // unix seconds; 0 = not set
	uint8_t     voting_opted_out = 0;
};

void WriteEstateSnapshot(Writer &w, const EstateSnapshot &s)
{
	for (uint32_t field : { s.estate_id, s.static_id, s.parent_id, s.definition_id, s.guild_id,
	                        s.fellowship_id }) {
		w.U32(field);
	}

	w.Str(s.owner_name);
	w.Str(s.owner_handle);
	w.U32(s.default_permission_level);
	w.U32(static_cast<uint32_t>(s.children.size()));
	w.Str(s.dynamic_name);

	for (uint32_t child : s.children) {
		w.U32(child);
	}

	w.U8(static_cast<uint8_t>(s.escrow.size()));

	for (const auto &balance : s.escrow) {
		w.U32(balance.first);
		w.Double(balance.second);
	}

	w.U32(s.upkeep_component);
	w.U32(s.expiry_time);
	w.U8(s.voting_opted_out);
}

struct PlacementActor {
	std::string model;                    // building model/idfile, NUL-terminated on the wire
	std::string guid;                     // 16 characters from the real-estate alphabet
	uint8_t     is_npc             = 0;
	float       npc_height         = 0.0f;
	uint32_t    record_num         = 0;
	uint32_t    estate_id          = 0;
	uint32_t    item_id            = 0;
	float       scale              = 1.0f;
	float       heading            = 0.0f;
	float       pitch              = 0.0f;
	float       roll               = 0.0f;
	float       y                  = 0.0f;
	float       x                  = 0.0f;
	float       z                  = 0.0f;
	uint8_t     ignore_collisions  = 0;
	uint8_t     disable_rotation   = 0;
	uint8_t     disable_free       = 0;
	uint32_t    placement_type     = 0;
	float       min_scale          = 1.0f;
	float       max_scale          = 1.0f;
	float       default_scale      = 1.0f;
	float       model_heading      = 0.0f;
	float       model_pitch        = 0.0f;
	float       model_roll         = 0.0f;
	uint32_t    light_type         = 0;
};

void WritePlacementActor(Writer &w, const PlacementActor &a)
{
	w.CStr(a.model);
	w.U8(a.is_npc);
	w.Float(a.npc_height);
	w.U32(a.record_num);
	w.CStr(a.guid);          // 16 characters plus the NUL the client's model loader expects
	w.U32(a.estate_id);
	w.U32(a.item_id);
	w.Float(a.scale);
	w.Float(a.heading);
	w.Float(a.pitch);
	w.Float(a.roll);
	w.Float(a.y);            // recovered field order is y, x, z -- not x, y, z
	w.Float(a.x);
	w.Float(a.z);
	w.U8(a.ignore_collisions);
	w.U8(a.disable_rotation);
	w.U8(a.disable_free);
	w.U32(a.placement_type);
	w.Float(a.min_scale);
	w.Float(a.max_scale);
	w.Float(a.default_scale);
	w.Float(a.model_heading);
	w.Float(a.model_pitch);
	w.Float(a.model_roll);
	w.U32(a.light_type);
}

// The client refuses every real-estate action until it believes it is standing in a
// neighborhood. sub_74BB00 gates on RealEstate[+144] and shows eqstr 8078 ("You must be
// in a neighborhood to use that.") unless sub_7F5F70(+144) is true, which it only is for
// the value 5. +144 is written solely by wire opcode 0x6fd0, parsed by the RealEstate
// vtable slot 3 (sub_7FDF00); upstream EQEmu has no name for 0x6fd0.
// Sends the real-estate definition list (0x2698). sub_7F5B60 parses a u32 count, then per
// entry (sub_7F4C90) eleven u32s, a length-prefixed address, two u32s, four floats, a child
// count and the child ids -- the grammar WriteEstateDefinition emits. The tenth u32 is the
// kind: that is the value sub_7F4FA0 returns and sub_7F5F70 tests, where the raw integer 5 is
// the only value that means "in a neighborhood" and 10 is the miss default. sub_7F4C90 stores
// every field verbatim (mov dword; the "f32" in early notes was decompiler type noise, same
// as the file loader's COERCE_FLOAT), so the kind must be the integer 5 -- NOT the IEEE bits
// of 5.0f (0x40A00000), which falls through the gate predicate's switch like a miss.
//
// The fields upstream names area_id (index 1) and zone_id (index 7) are both set to the
// neighborhood id. Our §13 decode says the spatial resolver compares definition field 7 --
// the first u32 after the id -- to RealEstate[+140]; the published struct calls index 1
// area_id and index 7 zone_id. Until a capture separates them, writing the same value to
// both makes either reading true. Emitting zero there is what made areas unresolvable.
void SendRealEstateDefinitions(Client *c, uint32_t definition_id, uint32_t neighborhood_id)
{
	// Three definitions with distinct kinds: the zone itself is the neighborhood (kind 5,
	// what the identity lookup must return), id 1 is a plot (kind 8) and id 2 is a house
	// (kind 4). The client's predicates split on these: sub_7F5F70 accepts only 5 for the
	// +144 gate, sub_7F6280 tests 8 before registering an object's +36 as a map key, and
	// the "object under my feet" spatial test (sub_7F6030) plus the house-ancestor walk
	// (mask 0x88) only accept kinds {4, 8}.
	//
	// Three definitions with distinct kinds: the zone itself is the neighborhood (kind 5,
	// what the identity lookup must return), id 1 is a plot (kind 8) and id 2 is a house
	// (kind 4). The client's predicates split on these: sub_7F5F70 accepts only 5 for the
	// +144 gate, sub_7F6280 tests 8 before registering an object's +36 as a map key, and
	// the "object under my feet" spatial test (sub_7F6030) plus the house-ancestor walk
	// (mask 0x88) only accept kinds {4, 8}.
	//
	// Revision-1 emulator capacity defaults for a one-room personal estate (the
	// published recovery's docs/CONFIGURING-HOUSE-CAPACITIES.md): 300 total items, a
	// 300-item non-estate/vault subset, 5 NPC items and one child estate. Emulator
	// policy, not recovered 2013 Live values.
	constexpr uint32_t kMaxItems        = 300;
	constexpr uint32_t kMaxNonEstate    = 300;
	constexpr uint32_t kMaxNpcItems     = 5;
	constexpr uint32_t kMaxChildEstates = 1;

	std::vector<EstateDefinition> entries;

	EstateDefinition neighborhood;
	neighborhood.id      = definition_id;
	neighborhood.area_id = neighborhood_id;
	neighborhood.zone_id = neighborhood_id;
	neighborhood.type    = kRealEstateKindNeighborhood;
	entries.push_back(neighborhood);

	EstateDefinition house;
	house.id                   = 2;
	house.area_id              = neighborhood_id;
	house.zone_id              = neighborhood_id;
	house.type                 = kRealEstateKindHouse;
	house.max_items            = kMaxItems;
	house.max_non_estate_items = kMaxNonEstate;
	house.max_children         = kMaxChildEstates;
	house.max_npc_items        = kMaxNpcItems;
	entries.push_back(house);

	// One definition per owned plot: the region id is the definition's area_id, so a shared
	// "plot" definition cannot describe two lots.
	auto owned = database.QueryDatabase(fmt::format(
		"SELECT p.door_id FROM nms_plot p JOIN nms_neighborhood n ON n.id = p.neighborhood_id "
		"WHERE n.zone = '{}' AND (p.owner_char_id = {} OR (p.owner_guild_id > 0 AND p.owner_guild_id = {})) "
		"ORDER BY p.door_id",
		Strings::Escape(zone ? zone->GetShortName() : ""), c->CharacterID(), c->GuildID()
	));

	if (owned.Success() && owned.RowCount()) {
		for (auto row : owned) {
			if (!row[0]) {
				continue;
			}

			const uint32_t door_id = Strings::ToUnsignedInt(row[0]);

			EstateDefinition plot;
			plot.id                   = PlotDefinitionId(door_id);
			plot.area_id              = PlotRegionId(door_id);
			// Definition dword 7 is what sub_4B30F0 compares against the AREA ID:
			//   v9 = defmap_lookup(obj+32); v10 = *(v9 + 28); if (v10 == area_id) ...
			// It is not the neighbourhood link. The neighbourhood link is the object's +24.
			plot.zone_id              = PlotRegionId(door_id);
			plot.type                 = kRealEstateKindPlot;
			plot.max_items            = kMaxItems;
			plot.max_non_estate_items = kMaxNonEstate;
			plot.max_children         = kMaxChildEstates;
			plot.max_npc_items        = kMaxNpcItems;
			entries.push_back(plot);
		}
	}

	Writer w;
	w.U32(static_cast<uint32_t>(entries.size()));

	for (const auto &entry : entries) {
		WriteEstateDefinition(w, entry);
	}

	// Cost schemes. The native purchase window prices from this second list, and the
	// recovered grammar is known (scheme id, components, 16-byte type/subtype/amount
	// values -- WriteEstateDefinition already emits the count), but the 2013 tariff is
	// not recovered. Publishing no scheme is deliberate: a fabricated price would be a
	// claim about Live data we do not have.
	w.U32(0);

	const auto &buf = w.Buffer();
	auto outapp = new EQApplicationPacket(OP_RealEstateDefinitions, static_cast<uint32>(buf.size()));
	std::memcpy(outapp->pBuffer, buf.data(), buf.size());
	c->QueuePacket(outapp);
	safe_delete(outapp);

	LogInfo(
		"[Housing] sent real-estate definitions to [{}]: ids [{}] kind 5, [1] kind 8, [2] kind 4, neighborhood [{}], {} bytes",
		c->GetName(), definition_id, neighborhood_id, buf.size()
	);
}

// Sends the player's owned plots in this neighborhood as RealEstate objects on
// OP_RealEstateSnapshot (0x63fd). The client deserializes 0x63fd exactly like the 0x6fd0
// identity (same sub_7FDF00 layout; the dispatcher just passes one extra ignored argument)
// and runs the same apply path (sub_5B5A90), which registers the object in the client's plot
// map under its ids. That map is what the plot/manage gates test against: eqstr 727 in
// sub_747E50 requires RealEstate[+152] to be a registered object id whose definition kind is
// 4 or 8, and the apply only indexes an object's +36 when its defs kind is 8 (sub_7F6280).
void SendRealEstatePlotObjects(Client *c)
{
	if (!c || !zone || std::string(zone->GetShortName()) != "neighborhood") {
		return;
	}

	const uint32_t    zone_id   = zone->GetZoneID();
	const std::string zone_name = zone->GetShortName();

	auto rows = database.QueryDatabase(fmt::format(
		"SELECT p.door_id, p.plot_type, COALESCE(c.name, ''), COALESCE(g.name, ''), "
		"       p.owner_guild_id, COALESCE(UNIX_TIMESTAMP(p.upkeep_paid_until), 0), n.id "
		"FROM nms_plot p "
		"JOIN nms_neighborhood n ON n.id = p.neighborhood_id "
		"LEFT JOIN character_data c ON c.id = p.owner_char_id "
		"LEFT JOIN guilds g ON g.id = p.owner_guild_id "
		"WHERE n.zone = '{}' AND (p.owner_char_id = {} "
		"  OR (p.owner_guild_id > 0 AND p.owner_guild_id = {})) "
		"ORDER BY p.door_id",
		Strings::Escape(zone_name), c->CharacterID(), c->GuildID()
	));

	if (!rows.Success() || !rows.RowCount()) {
		return;
	}

	int sent = 0;
	for (auto row = rows.begin(); row != rows.end(); ++row) {
		if (!row[0]) {
			continue;
		}
		const uint32_t    door_id     = Strings::ToUnsignedInt(row[0]);
		const uint32_t    plot_type   = Strings::ToUnsignedInt(row[1]);
		const std::string owner_name  = std::string(row[2] ? row[2] : "");
		const std::string guild_name  = std::string(row[3] ? row[3] : "");
		const uint32_t    owner_guild = Strings::ToUnsignedInt(row[4]);
		const uint32_t    upkeep_unix = Strings::ToUnsignedInt(row[5]);
		const uint32_t    neighborhood_id = Strings::ToUnsignedInt(row[6] ? row[6] : "0");

		EstateSnapshot plot;
		plot.estate_id     = door_id;                  // +20: the id the plot list and Go use
		// +24 is a second plot-map key. sub_4B30F0 looks the object up by RealEstate[+140] and
		// then demands obj[+20] == +140, so a plot is only reachable when it is registered
		// under the neighbourhood id that 0x6fd0 put into +140. This field is that key.
		plot.static_id     = neighborhood_id;
		plot.parent_id     = zone_id;                  // +28: the neighborhood object
		plot.definition_id = PlotDefinitionId(door_id); // +32: this plot's own definition
		plot.guild_id      = owner_guild ? owner_guild : 0xFFFFFFFFu;
		plot.owner_name    = plot_type == 1 ? guild_name : owner_name;
		plot.dynamic_name  = fmt::format("Plot {}", door_id);
		plot.expiry_time   = upkeep_unix;   // 0 = no paid-upkeep timestamp

		Writer w;
		WriteEstateSnapshot(w, plot);

		const auto &buf = w.Buffer();

		// One opcode only. IDA shows the 0x63fd branch calls the same manager apply (vtable+36)
		// as 0x6fd0, so registration happens here; sending it again on 0x6fd0 would re-register
		// and -- worse -- the identity re-send that followed shadowed the plot object under the
		// same id, which is exactly what the 727 walk needs to find.
		auto outapp = new EQApplicationPacket(OP_RealEstateSnapshot, static_cast<uint32>(buf.size()));
		std::memcpy(outapp->pBuffer, buf.data(), buf.size());
		c->QueuePacket(outapp);
		safe_delete(outapp);

		++sent;

		LogInfo("[Housing] sent plot object to [{}]: door [{}], {} bytes", c->GetName(), door_id, buf.size());
	}

	if (sent) {
		LogInfo("[Housing] sent [{}] plot object(s) to [{}]", sent, c->GetName());
	}
}

// Delayed re-burst state. The identity/defs/plot-object/area burst is ALSO sent during
// CAuth, but the client constructs its area manager (dword_DCEE30, sub_5338A0) partway
// through its zone-load sequence, and the 0x49df dispatcher case silently drops the
// manifest while that pointer is null. So after the client has been in the neighborhood
// for a settle period, resend the whole burst with the client fully loaded.
struct HousingZoneInState {
	std::string zone_key;
	uint32_t    seen_ms = 0;
	uint32_t    last_seen_ms = 0;
	bool        sent = false;
};
static std::unordered_map<uint32_t, HousingZoneInState> s_housing_zonein;

constexpr uint32_t kHousingSettleDelayMs = 8000;   // after zone-in before the re-burst
constexpr uint32_t kHousingVisitGapMs    = 30000;  // absence longer than this = new visit

static uint32_t HousingNowMs()
{
	return static_cast<uint32_t>(
		std::chrono::duration_cast<std::chrono::milliseconds>(
			std::chrono::steady_clock::now().time_since_epoch()).count());
}

// Called from Client::Process every tick. Sends the housing burst once per neighborhood
// visit, kHousingSettleDelayMs after the client was first seen in-zone.
void HousingClientProcess(Client *c)
{
	if (!c || !c->Connected() || !zone || std::string(zone->GetShortName()) != "neighborhood") {
		return;
	}

	const uint32_t char_id = c->CharacterID();
	const uint32_t now_ms  = HousingNowMs();
	const std::string zone_key = fmt::format("{}:{}", zone->GetZoneID(), zone->GetInstanceID());

	auto it = s_housing_zonein.find(char_id);
	if (it == s_housing_zonein.end()) {
		s_housing_zonein[char_id] = {zone_key, now_ms, now_ms, false};
		return;
	}

	auto &st = it->second;
	if (now_ms - st.last_seen_ms > kHousingVisitGapMs) {
		// back after a long absence: treat as a fresh zone-in
		st.zone_key = zone_key;
		st.seen_ms = now_ms;
		st.sent = false;
	}
	st.last_seen_ms = now_ms;

	if (st.sent || st.zone_key != zone_key) {
		return;
	}
	if (now_ms - st.seen_ms < kHousingSettleDelayMs) {
		return;
	}

	st.sent = true;
	LogInfo("[Housing] re-sending housing burst to [{}] after zone settle", c->GetName());
	c->SendRealEstateIdentity();
}

// Sends the owned plots' FOOTPRINTS as an area manifest on 0x49df (18911). This is what
// makes the client recognize "you are standing in your plot": the client deserializes each
// entry into an EQAreaBase object (sub_8D2E30) and hashes it into the spatial index the
// 1 Hz updater scans (sub_4B2F40). An entry is:
//   u32      area id  -- hashed key; must match the plot object's id (+20 = door_id) so the
//                       updater can resolve it in the client's plot map
//   f32 x16  row-major 4x4 mapping LOCAL [-1,+1]^3 -> WORLD. Columns are the half-extent
//            axis vectors, the 4th row is the world center. The inside test (sub_505BA0 +
//            sub_505F60) transforms the player position by the INVERSE and requires every
//            component within +/-1, so an axis-aligned box centered at the lot with
//            half-extents (hx,hy,hz) is [hx 0 0 0 / 0 hy 0 0 / 0 0 hz 0 / cx cy cz 1].
//   u32 x5   trailing fields (land at area+72..88; not read by the inside test)
// When the test passes the updater sets RealEstate[+148] to the plot object id and
// sub_5B00E0 walks it (kind 8 matches the {4,8} ancestor mask), setting +152 -- which is
// exactly what the eqstr-727 manage/plot-edit gate (sub_747E50) requires.
void SendRealEstateAreaManifest(Client *c, int variant = 0)
{
	if (!c || !zone || std::string(zone->GetShortName()) != "neighborhood") {
		return;
	}

	const std::string zone_name = zone->GetShortName();

	// The box size is derived from the lot markers instead of being guessed: lot markers in
	// this zone sit 200-400 units apart, so the 15-unit box we shipped earlier covered only a
	// corner of the lot and the player was almost never "inside". Half the distance to the
	// nearest neighbouring marker, capped, tracks whatever the zone actually uses.
	auto rows = database.QueryDatabase(fmt::format(
		"SELECT p.door_id, d.pos_x, d.pos_y, d.pos_z, "
		"  (SELECT MIN(SQRT(POW(d2.pos_x - d.pos_x, 2) + POW(d2.pos_y - d.pos_y, 2))) "
		"     FROM doors d2 WHERE d2.zone = d.zone AND d2.name = 'OBP_LOTSQUARE' "
		"       AND d2.version = 0 AND d2.doorid <> d.doorid) AS spacing "
		"FROM nms_plot p "
		"JOIN nms_neighborhood n ON n.id = p.neighborhood_id "
		"JOIN doors d ON d.zone = n.zone AND d.doorid = p.door_id AND d.version = 0 "
		"WHERE n.zone = '{}' AND (p.owner_char_id = {} "
		"  OR (p.owner_guild_id > 0 AND p.owner_guild_id = {}))",
		Strings::Escape(zone_name), c->CharacterID(), c->GuildID()
	));

	if (!rows.Success() || !rows.RowCount()) {
		return;
	}

	// Half-extents of the recognized footprint, in world units. Plots are the ~20m
	// stone-bordered squares; being generous only widens the inside test.
	constexpr float kHalfX = 15.0f;
	constexpr float kHalfY = 15.0f;
	constexpr float kHalfZ = 20.0f;

	Writer w;
	int sent = 0;
	w.U32(0);   // count placeholder; sub_4B2AB0 reads it before the records

	auto write_region = [&w](uint32_t id, float cx, float cy, float cz,
	                         float hx, float hy, float hz) {
		w.U32(id);

		// The form the published recovery emits (RegionWire::AxisBoxServerXYZ): extents Y/X
		// into m[0]/m[5], translation Y/X/Z at m[12..14].
		w.Float(hy); w.Float(0.0f); w.Float(0.0f); w.Float(0.0f);
		w.Float(0.0f); w.Float(hx); w.Float(0.0f); w.Float(0.0f);
		w.Float(0.0f); w.Float(0.0f); w.Float(hz); w.Float(0.0f);
		w.Float(cy); w.Float(cx); w.Float(cz); w.Float(1.0f);

		w.Float(0.0f); w.Float(0.0f); w.Float(0.0f);   // opaque vector
		w.U32(0xFFFFFFFF); w.U32(0xFFFFFFFF);          // opaque ids
	};

	for (auto row = rows.begin(); row != rows.end(); ++row) {
		if (!row[0]) {
			continue;
		}

		const uint32_t door_id = Strings::ToUnsignedInt(row[0]);

		const float cx      = Strings::ToFloat(row[1] ? row[1] : "0");
		const float cy      = Strings::ToFloat(row[2] ? row[2] : "0");
		const float cz      = Strings::ToFloat(row[3] ? row[3] : "0");
		const float spacing = Strings::ToFloat(row[4] ? row[4] : "0.0");

		// 45% of the marker spacing, clamped: wide enough to cover the lot the player stands on,
		// narrow enough not to claim the neighbour's. Labelled emulator policy.
		float        half = spacing > 0.0f ? spacing * 0.45f : kHalfX;
		if (half < 40.0f) {
			half = 40.0f;
		}
		if (half > 160.0f) {
			half = 160.0f;
		}

		const float kHalfX = half;
		const float kHalfY = half;
		const float kHalfZ = 80.0f;

		if (variant == 4) {
			// World->local form, in case the native inside test does NOT invert the matrix:
			// 1/h diagonal with -centre/h translation. Everything we have sent so far is the
			// local->world form, so this is the only orientation never tried.
			w.U32(door_id);
			w.Float(1.0f / kHalfY); w.Float(0.0f); w.Float(0.0f); w.Float(0.0f);
			w.Float(0.0f); w.Float(1.0f / kHalfX); w.Float(0.0f); w.Float(0.0f);
			w.Float(0.0f); w.Float(0.0f); w.Float(1.0f / kHalfZ); w.Float(0.0f);
			w.Float(-cy / kHalfY); w.Float(-cx / kHalfX); w.Float(-cz / kHalfZ); w.Float(1.0f);
			w.Float(0.0f); w.Float(0.0f); w.Float(0.0f);
			w.U32(0xFFFFFFFF); w.U32(0xFFFFFFFF);
			++sent;
			continue;
		}

		if (variant == 3) {
			// Box the PLAYER at 200 units. If this still leaves the client outside, the
			// geometry is not the problem -- the id resolution or the ingest is.
			write_region(door_id, c->GetX(), c->GetY(), c->GetZ(), 200.0f, 200.0f, 200.0f);
			++sent;
			continue;
		}

		if (variant == 1) {
			write_region(door_id, cx, cy, cz, kHalfX, kHalfY, kHalfZ);
			++sent;
			continue;
		}

		if (variant == 2) {
			write_region(PlotRegionId(door_id), cx, cy, cz, kHalfX, kHalfY, kHalfZ);
			++sent;
			continue;
		}

		// Default: the same box under BOTH candidate keys -- the estate id (the plot map is
		// keyed by +20) and the definition's area_id. One of them has to be what the resolver
		// indexes; the second record is 88 wasted bytes if not.
		write_region(door_id, cx, cy, cz, kHalfX, kHalfY, kHalfZ);
		write_region(PlotRegionId(door_id), cx, cy, cz, kHalfX, kHalfY, kHalfZ);
		sent += 2;
	}

	if (!sent) {
		return;
	}

	w.PatchU32(0, static_cast<uint32_t>(sent));

	const auto &buf = w.Buffer();
	auto outapp = new EQApplicationPacket(OP_RealEstateRegions, static_cast<uint32>(buf.size()));
	std::memcpy(outapp->pBuffer, buf.data(), buf.size());
	c->QueuePacket(outapp);
	safe_delete(outapp);

	LogInfo(
		"[Housing] sent area manifest to [{}]: [{}] plot region(s), variant [{}], {} bytes",
		c->GetName(), sent, variant, buf.size()
	);
}
// 0x626e S2C: the placement preview. The ActorRecord becomes the world object that draws
// the building; the 34-byte suffix (source kind, three source slots, three flags, three
// dwords, a region KEY/RESULT map and the required final zone KEY/RESULT pair) is what the
// placement controller reads. RESULT 0 means permitted.
bool SendPlacementPreview(Client *c, uint32_t door_id, uint32_t item_id, const std::string &model,
                          uint32_t zone_id, uint32_t neighborhood_id,
                          float x, float y, float z, float heading)
{
	if (!c || !zone || model.empty()) {
		return false;
	}

	PlacementActor actor;
	actor.model     = model;
	actor.guid      = MakeRealEstateId(zone_id, door_id);
	actor.estate_id = door_id;
	actor.item_id   = item_id;
	actor.heading   = heading;
	actor.x         = x;
	actor.y         = y;
	actor.z         = z;

	Writer w;
	WritePlacementActor(w, actor);
	w.U8(0);                                  // source kind: stored/property item
	w.U16(33); w.U16(0xFFFF); w.U16(0xFFFF);  // source slots: cursor slot 33, no bag
	w.U8(0); w.U8(0); w.U8(0);                // flags
	w.U32(0); w.U32(0); w.U32(0);             // opaque words
	w.U32(1);                                 // region map count
	w.U32(door_id); w.U32(0);                 // KEY = area id, RESULT = 0 (permitted)
	w.U32(neighborhood_id); w.U32(0);         // required final pair: zone estate + result

	const auto &buf = w.Buffer();
	auto outapp = new EQApplicationPacket(OP_RealEstatePlacementBegin, static_cast<uint32>(buf.size()));
	std::memcpy(outapp->pBuffer, buf.data(), buf.size());
	c->QueuePacket(outapp);
	safe_delete(outapp);

	LogInfo(
		"[Housing] sent placement preview to [{}]: lot [{}], item [{}], model [{}], "
		"({:.1f}, {:.1f}, {:.1f}) heading {:.1f}, {} bytes",
		c->GetName(), door_id, item_id, model, x, y, z, heading, buf.size()
	);

	return true;
}

// 0x1045 S2C: places a world actor. This -- not 0x626e -- is what makes an already-placed
// building exist in the world; 0x626e is only the preview the client draws while it is
// positioning something. Body: one ActorRecord, no suffix, no ItemPtr. 0x2a9e removes it.
bool SendRealEstateWorldItem(Client *c, uint32_t door_id, uint32_t item_id, const std::string &model,
                             uint32_t zone_id, float x, float y, float z, float heading)
{
	if (!c || !zone || model.empty()) {
		return false;
	}

	PlacementActor actor;
	actor.model     = model;
	actor.guid      = MakeRealEstateId(zone_id, door_id);
	actor.estate_id = door_id;
	actor.item_id   = item_id;
	actor.heading   = heading;
	actor.x         = x;
	actor.y         = y;
	actor.z         = z;

	Writer w;
	WritePlacementActor(w, actor);

	const auto &buf = w.Buffer();
	auto outapp = new EQApplicationPacket(OP_RealEstateWorldItem, static_cast<uint32>(buf.size()));
	std::memcpy(outapp->pBuffer, buf.data(), buf.size());
	c->QueuePacket(outapp);
	safe_delete(outapp);

	LogInfo(
		"[Housing] sent world item to [{}]: lot [{}], item [{}], model [{}], "
		"({:.1f}, {:.1f}, {:.1f}), {} bytes",
		c->GetName(), door_id, item_id, model, x, y, z, buf.size()
	);

	return true;
}

// Re-sends the exterior preview for every building placed on a lot this character may see.
// Placement consumes the item, so the building survives a client restart only because the
// lot records which item built it (nms_plot.house_item_id, custom migration 264).
void SendRealEstateExteriors(Client *c)
{
	if (!c || !zone || std::string(zone->GetShortName()) != "neighborhood") {
		return;
	}

	const uint32_t    zone_id   = zone->GetZoneID();
	const std::string zone_name = zone->GetShortName();

	auto rows = database.QueryDatabase(fmt::format(
		"SELECT p.door_id, p.house_item_id, COALESCE(it.idfile, ''), COALESCE(it.Name, ''), "
		"       d.pos_x, d.pos_y, d.pos_z, d.heading, n.id "
		"FROM nms_plot p "
		"JOIN nms_neighborhood n ON n.id = p.neighborhood_id "
		"JOIN doors d ON d.zone = n.zone AND d.doorid = p.door_id AND d.version = 0 "
		"LEFT JOIN items it ON it.id = p.house_item_id "
		"WHERE n.zone = '{}' AND p.house_item_id > 0 "
		"  AND (p.owner_char_id = {} OR (p.owner_guild_id > 0 AND p.owner_guild_id = {})) "
		"ORDER BY p.door_id",
		Strings::Escape(zone_name), c->CharacterID(), c->GuildID()
	));

	if (!rows.Success() || !rows.RowCount()) {
		return;
	}

	for (auto row : rows) {
		const uint32_t    door_id        = Strings::ToUnsignedInt(row[0]);
		const uint32_t    item_id        = Strings::ToUnsignedInt(row[1]);
		const std::string idfile         = std::string(row[2] ? row[2] : "");
		const std::string item_name      = std::string(row[3] ? row[3] : "");
		const float       px             = static_cast<float>(Strings::ToFloat(row[4] ? row[4] : "0"));
		const float       py             = static_cast<float>(Strings::ToFloat(row[5] ? row[5] : "0"));
		const float       pz             = static_cast<float>(Strings::ToFloat(row[6] ? row[6] : "0"));
		const float       heading        = static_cast<float>(Strings::ToFloat(row[7] ? row[7] : "0"));

		// The world model is the item's idfile ("IT20020"); the display name is only a
		// fallback for rows whose idfile is empty (the name is not a model and will not
		// render, but the packet shape stays valid).
		const std::string model = idfile.empty() ? item_name : idfile;

		SendRealEstateWorldItem(c, door_id, item_id, model, zone_id, px, py, pz, heading);
	}
}

void Client::SendRealEstateIdentity()
{
	if (!zone) {
		return;
	}

	// House interior: the neighborhood model does not apply, but the client still needs an
	// estate context or every real-estate action -- Manage included -- is refused with
	// "you must be inside a plot or house". One house-kind object for the lot this interior
	// belongs to gives the client's hierarchy walk a kind-4 estate to find.
	if (std::string(zone->GetShortName()) != "neighborhood") {
		auto interior = database.QueryDatabase(fmt::format(
			"SELECT p.door_id, n.id FROM house h "
			"JOIN nms_plot p ON p.house_id = h.id "
			"JOIN nms_neighborhood n ON n.id = p.neighborhood_id "
			"WHERE h.char_id = {} AND h.zone = '{}' LIMIT 1",
			CharacterID(), Strings::Escape(zone->GetShortName())
		));

		if (!interior.Success() || !interior.RowCount()) {
			return;
		}

		auto row = interior.begin();

		const uint32_t door_id = Strings::ToUnsignedInt(row[0] ? row[0] : "0");
		const uint32_t nb_id   = Strings::ToUnsignedInt(row[1] ? row[1] : "0");

		EstateDefinition house_def;
		house_def.id                   = 2;
		house_def.area_id              = nb_id;
		house_def.zone_id              = nb_id;
		house_def.type                 = kRealEstateKindHouse;
		house_def.max_items            = 300;
		house_def.max_non_estate_items = 300;
		house_def.max_npc_items        = 5;

		Writer defs;
		defs.U32(1);
		WriteEstateDefinition(defs, house_def);
		defs.U32(0);

		const auto &def_bytes = defs.Buffer();
		auto def_packet = new EQApplicationPacket(OP_RealEstateDefinitions, static_cast<uint32>(def_bytes.size()));
		std::memcpy(def_packet->pBuffer, def_bytes.data(), def_bytes.size());
		QueuePacket(def_packet);
		safe_delete(def_packet);

		EstateSnapshot interior_snapshot;
		interior_snapshot.estate_id     = door_id;
		interior_snapshot.definition_id = 2;
		interior_snapshot.owner_name    = GetName();
		interior_snapshot.dynamic_name  = fmt::format("Plot {}", door_id);

		Writer w;
		WriteEstateSnapshot(w, interior_snapshot);

		const auto &buf = w.Buffer();
		auto outapp = new EQApplicationPacket(OP_RealEstateZoneContext, static_cast<uint32>(buf.size()));
		std::memcpy(outapp->pBuffer, buf.data(), buf.size());
		QueuePacket(outapp);
		safe_delete(outapp);

		LogInfo(
			"[Housing] sent house context to [{}] in [{}]: lot [{}], {} bytes",
			GetName(), zone->GetShortName(), door_id, buf.size()
		);
		return;
	}

	const std::string  zone_name = zone->GetShortName();

	// The first u32 becomes RealEstate[+140] (the neighborhood id the search request
	// echoes back). The fourth u32 becomes RealEstate[+144] after a lookup in the
	// client's own real-estate definition table, whose key is the zone id (zone 712 is
	// registered as 'neighborhood' by the sub_7DC430 call at 0x7E32F7 and must also
	// appear in RealEstateDefs.txt with kind 5).
	uint32_t    neighborhood_id   = 1;
	uint32_t    neighborhood_guild = 0;
	std::string neighborhood_name = "Sunrise Hills";

	auto nb = database.QueryDatabase(fmt::format(
		"SELECT id, name, guild_id FROM nms_neighborhood WHERE zone = '{}' LIMIT 1", Strings::Escape(zone_name)
	));

	if (nb.Success() && nb.RowCount()) {
		auto row = nb.begin();
		if (row[0]) {
			neighborhood_id = Strings::ToUnsignedInt(row[0]);
		}
		if (row[1]) {
			neighborhood_name = row[1];
		}
		if (row[2]) {
			neighborhood_guild = Strings::ToUnsignedInt(row[2]);
		}
	}

	const uint32_t zone_id = zone->GetZoneID();

	// The definition list must be in the client's table BEFORE this packet is processed: the
	// lookup below returns struct index 15, whose miss default is 10, and the client appears to
	// latch the neighborhood value from the first identity it sees. The packet is well-formed
	// now (every trailing field present, plus the second list's count), so it no longer crashes.
	SendRealEstateDefinitions(this, zone_id, neighborhood_id);

	// The plots this character may act on. They are also the child estates of the
	// neighborhood object, so the client can resolve the children once the 0x63fd objects
	// that follow arrive -- and the count-driven parser makes an empty list harmless.
	std::vector<uint32_t> owned_plots;

	auto owned = database.QueryDatabase(fmt::format(
		"SELECT p.door_id FROM nms_plot p JOIN nms_neighborhood n ON n.id = p.neighborhood_id "
		"WHERE n.zone = '{}' AND (p.owner_char_id = {} OR (p.owner_guild_id > 0 AND p.owner_guild_id = {})) "
		"ORDER BY p.door_id",
		Strings::Escape(zone_name), CharacterID(), GuildID()
	));

	if (owned.Success() && owned.RowCount()) {
		for (auto row : owned) {
			if (row[0]) {
				owned_plots.push_back(Strings::ToUnsignedInt(row[0]));
			}
		}
	}

	// The zone-context object is the player's OWN PLOT when they hold one, not the
	// neighbourhood. sub_4B2F40 resolves a region by calling sub_4B30F0(area_id, +140), and
	// that resolver demands the found object's +20 == +140. 0x6fd0 writes +140 from this
	// object's +20, so the identity has to carry the plot id for the plot object to be
	// selectable. The definition stays the neighbourhood one, so +144 (defs lookup of +32)
	// is still kind 5 and the "you must be in a neighborhood" gate stays satisfied.
	EstateSnapshot snapshot;
	snapshot.estate_id     = owned_plots.empty() ? neighborhood_id : owned_plots.front();
	snapshot.parent_id     = 0;
	snapshot.definition_id = zone_id;           // +32: the defs key -> RealEstate[+144] = kind 5
	snapshot.guild_id      = neighborhood_guild ? neighborhood_guild : 0xFFFFFFFFu;
	snapshot.owner_name    = neighborhood_name;
	snapshot.owner_handle  = zone_name;
	// Children stay empty: the plot objects are pushed separately, and a child list is
	// exactly the kind of unresolved id the client would try to walk.
	snapshot.children.clear();

	auto send_identity = [&]() {
		Writer w;
		WriteEstateSnapshot(w, snapshot);

		const auto &buf = w.Buffer();
		auto outapp = new EQApplicationPacket(OP_RealEstateZoneContext, static_cast<uint32>(buf.size()));
		std::memcpy(outapp->pBuffer, buf.data(), buf.size());
		QueuePacket(outapp);
		safe_delete(outapp);

		LogInfo(
			"[Housing] sent real-estate identity to [{}]: neighborhood [{}] '{}', zone [{}], {} bytes",
			GetName(), neighborhood_id, neighborhood_name, zone_id, buf.size()
		);
	};

	send_identity();

	// Register the player's owned plots right after the identity so the client's plot map has
	// the kind-8 objects the plot/manage gates look up, then send the plot footprints so the
	// spatial updater recognizes "standing in the plot" (the eqstr-727 gate's requirement).
	// Order matters: the zone context is applied first, then the plots. Both use id 19 (the
	// context is the player's plot), and the apply prepends to the bucket, so the LAST one
	// wins the id -- and it has to be the plot object, because the walk needs a kind-8 estate.
	SendRealEstatePlotObjects(this);

	SendRealEstateAreaManifest(this);

	// Buildings already placed on those lots: the preview is what actually draws them, and
	// it has to be re-sent on every zone-in because the client keeps no copy.
	SendRealEstateExteriors(this);
}

// Leaves a house interior. Retail houses have no doors on purpose -- you leave with the real
// estate window or the /leaverealestate command, which zones you back to the neighborhood just
// outside the plot. The client's own path is gated, so the server does the zoning.
void HousingLeave(Client *c)
{
	auto home = database.QueryDatabase(fmt::format(
		"SELECT h.zone FROM house h WHERE h.char_id = {} LIMIT 1", c->CharacterID()
	));

	const std::string here = zone ? zone->GetShortName() : "";
	const bool in_interior = home.Success() && home.RowCount() &&
		home.begin()[0] && std::string(home.begin()[0]) == here;

	if (!in_interior) {
		c->Message(Chat::White, "[housing] you are not inside a house interior.");
		return;
	}

	auto nb = database.QueryDatabase(
		"SELECT safe_x, safe_y, safe_z, zoneidnumber FROM zone WHERE short_name = 'neighborhood' LIMIT 1");

	float    sx = 2035.0f, sy = -3006.0f, sz = 4.0f;
	uint32_t zone_id = 712;

	if (nb.Success() && nb.RowCount()) {
		auto row = nb.begin();
		sx = static_cast<float>(Strings::ToFloat(row[0] ? row[0] : "2035"));
		sy = static_cast<float>(Strings::ToFloat(row[1] ? row[1] : "-3006"));
		sz = static_cast<float>(Strings::ToFloat(row[2] ? row[2] : "4"));
		zone_id = Strings::ToUnsignedInt(row[3] ? row[3] : "712");
	}

	c->Message(Chat::White, "[housing] returning to the neighborhood...");
	c->MovePC(zone_id, sx, sy, sz, 0.0f);
}

// The game's own command name for this, available to every player.
void command_leaverealestate(Client *c, const Seperator *sep)
{
	HousingLeave(c);
}

// GM surface for the housing subsystem. Exists because the client's native real-estate
// UI is gated behind its own data files, so this is the only way to exercise and verify
// the server half (lot claiming, guild binding, plot ownership) in game.
void command_housing(Client *c, const Seperator *sep)
{
	const int argc = sep->argnum;

	if (!argc) {
		c->Message(Chat::White, "#housing list - show the neighborhood and plot ownership here");
		c->Message(Chat::White, "#housing claim <door_id> - claim a vacant lot for yourself");
		c->Message(Chat::White, "#housing release <door_id> - give a lot back");
		c->Message(Chat::White, "#housing bind <guild_id|0> - bind this neighborhood to a guild");
		c->Message(Chat::White, "#housing place <door_id> [item_id] - place a house item from your inventory on a lot");
		c->Message(Chat::White, "#housing exterior <door_id> [item_id] [model] - (re)send a lot's building world item");
		c->Message(Chat::White, "#housing areas <0-4> - resend the plot regions (0 both keys, 1 estate key, 2 area-id key, 3 player box, 4 world->local)");
		c->Message(Chat::White, "#housing send - re-send the real-estate identity packet");
		c->Message(Chat::White, "#housing send list - identity, then the neighborhood list");
		c->Message(Chat::White, "#housing send defs - real-estate definitions, then identity (experimental)");
		c->Message(Chat::White, "#housing enter - zone into your house interior");
		c->Message(Chat::White, "#housing leave - return from a house interior to the neighborhood");
		c->Message(Chat::White, "#housing guildplot <door_id> [off] - make a lot a guild plot");
		return;
	}

	const std::string sub  = sep->arg[1];
	const std::string zone_name = zone ? zone->GetShortName() : "";

	// Places a house item the character is carrying onto a lot: the item is consumed, the
	// lot is claimed, and the house row + interior instance persist. This is the
	// item-driven placement the client's own purchase window is meant to do.
	if (sub == "place" && sep->IsNumber(2)) {
		const uint32_t door_id = Strings::ToUnsignedInt(sep->arg[2]);

		// Which item counts as a house is a data question: the residence/deed items live in the
		// items table (all itemtype 11, no dedicated marker), so auto-detection is name-based.
		// The HoT house items are named inconsistently ("...Stone Residence, ... interior" vs
		// "Zimel Style Stucco Hut, ..."), hence the word list. The explicit form
		// (#housing place <door_id> <item_id>) always works and should be preferred.
		uint32_t item_id = 0;

		if (sep->IsNumber(3)) {
			item_id = Strings::ToUnsignedInt(sep->arg[3]);
		}
		else {
			auto found = database.QueryDatabase(fmt::format(
				"SELECT i.item_id FROM inventory i JOIN items it ON it.id = i.item_id "
				"WHERE i.character_id = {} "
				"  AND (it.Name LIKE '%Residence%' OR it.Name LIKE '%Deed%' OR it.Name LIKE '%House%' "
				"    OR it.Name LIKE '%Hut%' OR it.Name LIKE '%Cottage%' OR it.Name LIKE '%Manor%' "
				"    OR it.Name LIKE '%Villa%' OR it.Name LIKE '%Chalet%' OR it.Name LIKE '%Cabin%' "
				"    OR it.Name LIKE '%Lodge%') "
				"  AND it.Name NOT LIKE '%Key%' LIMIT 1",
				c->CharacterID()
			));

			if (found.Success() && found.RowCount() && found.begin()[0]) {
				item_id = Strings::ToUnsignedInt(found.begin()[0]);
			}
		}

		if (!item_id) {
			c->Message(
				Chat::White,
				"[housing] no house item (residence or deed) found in your inventory. "
				"Carry the house item, or pass it explicitly: #housing place <door_id> <item_id>"
			);
			return;
		}

		const uint32_t carried = c->CountItem(item_id);

		LogInfo(
			"[Housing] place requested by [{}]: lot door [{}], item [{}] x{}",
			c->GetName(), door_id, item_id, carried
		);

		if (!carried) {
			c->Message(
				Chat::White,
				fmt::format("[housing] you are not carrying house item [{}].", item_id).c_str()
			);
			return;
		}

		auto r = database.QueryDatabase(fmt::format(
			"SELECT d.pos_x, d.pos_y, d.pos_z, d.heading, n.id "
			"FROM doors d JOIN nms_neighborhood n ON n.zone = d.zone "
			"WHERE d.zone = '{}' AND d.doorid = {} AND d.version = 0 LIMIT 1",
			Strings::Escape(zone_name), door_id
		));

		if (!r.Success() || r.RowCount() == 0) {
			c->Message(Chat::White, fmt::format("[housing] there is no lot with door id [{}] here.", door_id).c_str());
			return;
		}

		auto lot = r.begin();

		const float    px              = static_cast<float>(Strings::ToFloat(lot[0] ? lot[0] : "0"));
		const float    py              = static_cast<float>(Strings::ToFloat(lot[1] ? lot[1] : "0"));
		const float    pz              = static_cast<float>(Strings::ToFloat(lot[2] ? lot[2] : "0"));
		const float    heading         = static_cast<float>(Strings::ToFloat(lot[3] ? lot[3] : "0"));

		// The exterior model the client draws is the item's idfile ("IT20020"); the display
		// name is only a fallback for rows with no idfile.
		std::string model;

		auto model_row = database.QueryDatabase(fmt::format(
			"SELECT COALESCE(idfile, ''), COALESCE(Name, '') FROM items WHERE id = {} LIMIT 1", item_id
		));

		if (model_row.Success() && model_row.RowCount()) {
			auto m = model_row.begin();
			model = (m[0] && *m[0]) ? m[0] : (m[1] ? m[1] : "");
		}

		TryClaimPlot(c, zone_name, px, py);

		auto owned = database.QueryDatabase(fmt::format(
			"SELECT p.owner_char_id, p.owner_guild_id, p.plot_type FROM nms_plot p "
			"JOIN nms_neighborhood nb ON nb.id = p.neighborhood_id "
			"WHERE nb.zone = '{}' AND p.door_id = {} LIMIT 1",
			Strings::Escape(zone_name), door_id
		));

		// A guild plot belongs to the guild, so ownership is the guild id, not the character.
		const bool is_mine = owned.Success() && owned.RowCount() && [&]() {
			const uint32_t owner_char  = Strings::ToUnsignedInt(owned.begin()[0] ? owned.begin()[0] : "0");
			const uint32_t owner_guild = Strings::ToUnsignedInt(owned.begin()[1] ? owned.begin()[1] : "0");
			const uint32_t plot_type   = Strings::ToUnsignedInt(owned.begin()[2] ? owned.begin()[2] : "0");

			if (plot_type == 1) {
				return owner_guild != 0 && owner_guild == c->GuildID();
			}

			return owner_char == c->CharacterID();
		}();

		if (!is_mine) {
			c->Message(
				Chat::White,
				fmt::format("[housing] lot [{}] is not available; the item was kept.", door_id).c_str()
			);
			return;
		}

		AttachHouseToPlot(c, FindNearestPlot(zone_name, px, py));

		// Remember which item built the building: the item is consumed below, and the lot has
		// to be able to draw (and re-draw on every later zone-in) without it.
		database.QueryDatabase(fmt::format(
			"UPDATE nms_plot p JOIN nms_neighborhood nb ON nb.id = p.neighborhood_id "
			"SET p.house_item_id = {} WHERE nb.zone = '{}' AND p.door_id = {}",
			item_id, Strings::Escape(zone_name), door_id
		));

		auto linked = database.QueryDatabase(fmt::format(
			"SELECT p.house_id, p.house_zone FROM nms_plot p "
			"JOIN nms_neighborhood nb ON nb.id = p.neighborhood_id "
			"WHERE nb.zone = '{}' AND p.door_id = {} LIMIT 1",
			Strings::Escape(zone_name), door_id
		));

		LogInfo(
			"[Housing] place: lot door [{}] now house_id [{}] zone [{}]; consuming item [{}]",
			door_id,
			(linked.Success() && linked.RowCount() && linked.begin()[0]) ? linked.begin()[0] : "0",
			(linked.Success() && linked.RowCount() && linked.begin()[1]) ? linked.begin()[1] : "",
			item_id
		);

		// 0x1045 is what draws the building; the item is consumed only once that packet is on
		// the wire. A consumed item and an empty lot is the worst outcome and already happened.
		if (!SendRealEstateWorldItem(c, door_id, item_id, model, zone->GetZoneID(),
		                             px, py, pz, heading)) {
			c->Message(
				Chat::White,
				fmt::format(
					"[housing] lot [{}] is linked to your house, but nothing was consumed: item [{}] "
					"has no idfile, so there is no world model to draw. "
					"Use #housing exterior <door_id> <item_id> <model> once you know the model.",
					door_id, item_id
				).c_str()
			);
			return;
		}

		c->RemoveItem(item_id, 1);

		c->Message(
			Chat::White,
			fmt::format("[housing] placed house item [{}] on lot [{}]; it is now yours.", item_id, door_id).c_str()
		);
		return;
	}

	// Leaves a house interior. The interior zones carry no doors at all (phinterior1a1 has zero
	// rows in the doors table), and the client's own CMD_REAL_ESTATE_LEAVE goes through the same
	// neighborhood gate as every other real-estate action, so there is no working UI exit to
	// click. This is the exit.
	if (sub == "leave") {
		HousingLeave(c);
		return;
	}

	// Enters the interior of the house the character owns. Same lookup the Sunrise Hills key
	// uses, so this is also the quickest way to prove a placed house is really wired up.
	if (sub == "enter") {
		auto house = database.QueryDatabase(fmt::format(
			"SELECT id, instance_id, zone FROM house WHERE char_id = {} LIMIT 1",
			c->CharacterID()
		));

		if (!house.Success() || house.RowCount() == 0) {
			c->Message(Chat::White, "[housing] you do not own a house.");
			return;
		}

		auto row         = house.begin();
		const uint32_t instance_id = Strings::ToUnsignedInt(row[1] ? row[1] : "0");

		if (!instance_id) {
			c->Message(Chat::White, "[housing] your house has no interior instance.");
			return;
		}

		c->Message(
			Chat::White,
			fmt::format(
				"[housing] entering house #{} in [{}] instance [{}]...",
				row[0] ? row[0] : "0", row[2] ? row[2] : "", instance_id
			).c_str()
		);

		c->MoveZoneInstance(static_cast<uint16>(instance_id));
		return;
	}

	// Forces the packets on demand, so testing does not depend on zone-in timing or on
	// the client having been ready when the zone-in copy went out.
	// Diagnostic: re-send the area manifest in a chosen encoding. 0 is what zone-in sends,
	// 1 moves the translation into the 4th column, 2 sends the world->local form, and 3
	// boxes the player themselves (200 units) to prove whether any "inside" answer reaches
	// the updater. Stand on the lot, run a variant, then try Manage.
	if (sub == "areas") {
		const int variant = sep->IsNumber(2) ? Strings::ToInt(sep->arg[2]) : 0;
		SendRealEstateAreaManifest(c, variant);
		c->Message(Chat::White, fmt::format("[housing] area manifest variant [{}] sent.", variant).c_str());
		return;
	}

	if (sub == "send") {
		c->SendRealEstateIdentity();
		c->Message(Chat::White, "[housing] real-estate identity sent.");

		if (sep->arg[2] && !strcasecmp(sep->arg[2], "list")) {
			SendNeighborhoodList(c, zone_name);
			c->Message(Chat::White, "[housing] neighborhood list sent.");
		}

		if (sep->arg[2] && !strcasecmp(sep->arg[2], "defs")) {
			SendRealEstateDefinitions(c, zone->GetZoneID(), 1);
			c->SendRealEstateIdentity();
			c->Message(Chat::White, "[housing] definitions + identity sent.");
		}
		return;
	}

	// Draws (or re-draws) a lot's building on the client: the 0x626e placement preview, the
	// same packet placement sends. <door_id> [item_id] [model] -- item_id defaults to the
	// lot's recorded house item and model to that item's idfile, so the plain form is the
	// repair path for a lot whose building did not draw. The client's own placement commit
	// (0x711a) is still unhandled, so this is the only way to place from the client UI.
	if (sub == "exterior" && sep->IsNumber(2)) {
		const uint32_t door_id = Strings::ToUnsignedInt(sep->arg[2]);

		auto r = database.QueryDatabase(fmt::format(
			"SELECT d.pos_x, d.pos_y, d.pos_z, d.heading, n.id, p.house_item_id, "
			"       COALESCE(it.idfile, ''), COALESCE(it.Name, '') "
			"FROM doors d "
			"JOIN nms_neighborhood n ON n.zone = d.zone "
			"JOIN nms_plot p ON p.neighborhood_id = n.id AND p.door_id = d.doorid "
			"LEFT JOIN items it ON it.id = p.house_item_id "
			"WHERE d.zone = '{}' AND d.doorid = {} AND d.version = 0 LIMIT 1",
			Strings::Escape(zone_name), door_id
		));

		if (!r.Success() || r.RowCount() == 0) {
			c->Message(Chat::White, fmt::format("[housing] there is no lot with door id [{}] here.", door_id).c_str());
			return;
		}

		auto row = r.begin();

		const float    px              = static_cast<float>(Strings::ToFloat(row[0] ? row[0] : "0"));
		const float    py              = static_cast<float>(Strings::ToFloat(row[1] ? row[1] : "0"));
		const float    pz              = static_cast<float>(Strings::ToFloat(row[2] ? row[2] : "0"));
		const float    heading         = static_cast<float>(Strings::ToFloat(row[3] ? row[3] : "0"));

		const uint32_t    item_id = sep->IsNumber(3) ? Strings::ToUnsignedInt(sep->arg[3])
		                                             : Strings::ToUnsignedInt(row[5]);
		const std::string recorded_model = (row[6] && *row[6]) ? row[6] : (row[7] ? row[7] : "");
		const std::string model = sep->arg[4] ? sep->arg[4] : recorded_model;

		if (!item_id) {
			c->Message(
				Chat::White,
				fmt::format(
					"[housing] lot [{}] has no recorded house item. "
					"Use #housing exterior <door_id> <item_id> [model].",
					door_id
				).c_str()
			);
			return;
		}

		if (model.empty()) {
			c->Message(
				Chat::White,
				fmt::format("[housing] item [{}] has no idfile; pass the model explicitly.", item_id).c_str()
			);
			return;
		}

		SendRealEstateWorldItem(c, door_id, item_id, model, zone->GetZoneID(), px, py, pz, heading);

		c->Message(
			Chat::White,
			fmt::format(
				"[housing] exterior sent for lot [{}]: item [{}], model [{}].",
				door_id, item_id, model
			).c_str()
		);
		return;
	}

	if (sub == "list") {
		const auto rows = LoadNeighborhoods(zone_name);

		if (rows.empty()) {
			c->Message(Chat::White, fmt::format("[housing] no neighborhood is defined for zone [{}]", zone_name).c_str());
			return;
		}

		for (const auto &r : rows) {
			c->Message(
				Chat::White,
				fmt::format(
					"[housing] #{} '{}' guild [{}]  player plots {}/{}  guild plots {}/{}",
					r.id, r.name, r.guild_id,
					r.owned_player, r.max_player_plots, r.owned_guild, r.max_guild_plots
				).c_str()
			);
		}

		auto mine = database.QueryDatabase(fmt::format(
			"SELECT p.door_id, p.plot_type, p.owner_guild_id FROM nms_plot p "
			"JOIN nms_neighborhood nb ON nb.id = p.neighborhood_id "
			"WHERE nb.zone = '{}' AND (p.owner_char_id = {} OR (p.owner_guild_id > 0 AND p.owner_guild_id = {})) "
			"ORDER BY p.door_id",
			Strings::Escape(zone_name), c->CharacterID(), c->GuildID()
		));

		if (mine.Success() && mine.RowCount()) {
			for (auto row : mine) {
				c->Message(
					Chat::White,
					fmt::format(
						"[housing] you hold lot door [{}], type [{}], guild [{}]",
						row[0] ? row[0] : "0", row[1] ? row[1] : "0", row[2] ? row[2] : "0"
					).c_str()
				);
			}
		}
		return;
	}

	if (sub == "claim" && sep->IsNumber(2)) {
		const uint32_t door_id = Strings::ToUnsignedInt(sep->arg[2]);

		auto r = database.QueryDatabase(fmt::format(
			"SELECT pos_x, pos_y FROM doors WHERE zone = '{}' AND doorid = {} AND version = 0 LIMIT 1",
			Strings::Escape(zone_name), door_id
		));

		if (!r.Success() || r.RowCount() == 0) {
			c->Message(Chat::White, fmt::format("[housing] there is no lot with door id [{}] in this zone", door_id).c_str());
			return;
		}

		auto row = r.begin();
		const auto px = static_cast<float>(Strings::ToFloat(row[0] ? row[0] : "0"));
		const auto py = static_cast<float>(Strings::ToFloat(row[1] ? row[1] : "0"));

		TryClaimPlot(c, zone_name, px, py);
		return;
	}

	if (sub == "release" && sep->IsNumber(2)) {
		const uint32_t door_id = Strings::ToUnsignedInt(sep->arg[2]);

		auto r = database.QueryDatabase(fmt::format(
			"UPDATE nms_plot p JOIN nms_neighborhood nb ON nb.id = p.neighborhood_id "
			"SET p.owner_char_id = 0, p.owner_guild_id = 0, p.purchased_at = NULL, p.upkeep_paid_until = NULL "
			"WHERE nb.zone = '{}' AND p.door_id = {}", Strings::Escape(zone_name), door_id
		));

		c->Message(
			Chat::White,
			fmt::format(
				"[housing] release of lot door [{}] {}.",
				door_id, (r.Success() && r.RowsAffected()) ? "done" : "had nothing to do"
			).c_str()
		);
		return;
	}

	if (sub == "bind" && sep->IsNumber(2)) {
		const uint32_t guild_id = Strings::ToUnsignedInt(sep->arg[2]);

		auto r = database.QueryDatabase(fmt::format(
			"UPDATE nms_neighborhood SET guild_id = {} WHERE zone = '{}'",
			guild_id, Strings::Escape(zone_name)
		));

		if (!r.Success() || r.RowsAffected() == 0) {
			c->Message(Chat::White, fmt::format("[housing] neighborhood is already bound to guild [{}]", guild_id).c_str());
			return;
		}

		c->Message(Chat::White, fmt::format("[housing] this neighborhood now belongs to guild [{}] (0 = open to all).", guild_id).c_str());
		return;
	}

	// Mark a lot as a guild plot (or turn that off). Nothing in the data says which physical lots
	// are guild plots in Live, so this is the switch that makes the guild half reachable.
	if (sub == "guildplot" && sep->IsNumber(2)) {
		const uint32_t door_id = Strings::ToUnsignedInt(sep->arg[2]);
		const bool     on      = !(sep->arg[3] && !strcasecmp(sep->arg[3], "off"));
		const uint32_t type    = on ? 1 : 0;

		auto r = database.QueryDatabase(fmt::format(
			"UPDATE nms_plot p JOIN nms_neighborhood nb ON nb.id = p.neighborhood_id "
			"SET p.plot_type = {} WHERE nb.zone = '{}' AND p.door_id = {}",
			type, Strings::Escape(zone_name), door_id
		));

		database.QueryDatabase(fmt::format(
			"UPDATE nms_neighborhood nb SET nb.max_guild_plots = "
			"(SELECT COUNT(*) FROM nms_plot p WHERE p.neighborhood_id = nb.id AND p.plot_type = 1), "
			"nb.max_player_plots = "
			"(SELECT COUNT(*) FROM nms_plot p WHERE p.neighborhood_id = nb.id AND p.plot_type = 0) "
			"WHERE nb.zone = '{}'",
			Strings::Escape(zone_name)
		));

		c->Message(
			Chat::White,
			fmt::format(
				"[housing] lot door [{}] is now a {} plot.",
				door_id, on ? "guild" : "player"
			).c_str()
		);
		return;
	}

	c->Message(Chat::White, "[housing] unknown sub-command. Try #housing list.");
}
