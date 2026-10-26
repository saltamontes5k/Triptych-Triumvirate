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
#include <cstring>
#include <string>
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

	void U16(uint16_t v) {
		m_buf.push_back(v & 0xFF);
		m_buf.push_back((v >> 8) & 0xFF);
	}

	void U32(uint32_t v) {
		for (int i = 0; i < 4; ++i) {
			m_buf.push_back(static_cast<uint8_t>((v >> (8 * i)) & 0xFF));
		}
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

	auto outapp = new EQApplicationPacket(OP_RealEstateSearchRequest, static_cast<uint32>(buf.size()));
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
};

// Only owned plots appear in the plot list: the client's reader (sub_74C4C0) adds a
// row only when the owner type is 4 (Player) or 8 (Guild). Vacant lots are simply
// absent from this list.
std::vector<PlotRow> LoadOwnedPlots(const std::string &zone_short_name)
{
	std::vector<PlotRow> rows;

	auto results = database.QueryDatabase(fmt::format(
		"SELECT p.door_id, p.plot_type, COALESCE(c.name, ''), COALESCE(g.name, '') "
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

		if (plot_type == 1) {
			r.owner_type = kPlotOwnerGuild;
			r.owner_name = guild_name;
		}
		else {
			r.owner_type = kPlotOwnerPlayer;
			r.owner_name = char_name;
		}

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
		w.Str("");   // the second per-entry string is a separate column; which one is
		             // the street address is not yet confirmed against a live client
	}

	const auto &buf = w.Buffer();

	if (buf.empty()) {
		return;
	}

	auto outapp = new EQApplicationPacket(OP_RealEstateSearchRequest, static_cast<uint32>(buf.size()));
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

float ReadFloat(const EQApplicationPacket *app, size_t offset)
{
	if (offset + 4 > app->size) {
		return 0.0f;
	}

	float value = 0.0f;
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

void Client::Handle_OP_RealEstateNeighborhoodRequest(const EQApplicationPacket *app)
{
	LogHousingOpcode(this, app, "OP_RealEstateNeighborhoodRequest");
	SendNeighborhoodList(this, zone->GetShortName());
}

void Client::Handle_OP_RealEstateRequest(const EQApplicationPacket *app)
{
	LogHousingOpcode(this, app, "OP_RealEstateRequest");
	SendNeighborhoodList(this, zone->GetShortName());
}

void Client::Handle_OP_RealEstateSearchRequest(const EQApplicationPacket *app)
{
	LogHousingOpcode(this, app, "OP_RealEstateSearchRequest");

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

void Client::Handle_OP_RealEstatePlotSelect(const EQApplicationPacket *app)
{
	LogHousingOpcode(this, app, "OP_RealEstatePlotSelect");
}

void Client::Handle_OP_RealEstatePlacement(const EQApplicationPacket *app)
{
	LogHousingOpcode(this, app, "OP_RealEstatePlacement");

	// The placement payload carries the world position at offsets 52 (x) and 56 (y).
	TryClaimPlot(this, zone->GetShortName(), ReadFloat(app, 52), ReadFloat(app, 56));
}

// The client refuses every real-estate action until it believes it is standing in a
// neighborhood. sub_74BB00 gates on RealEstate[+144] and shows eqstr 8078 ("You must be
// in a neighborhood to use that.") unless sub_7F5F70(+144) is true, which it only is for
// the value 5. +144 is written solely by wire opcode 0x6fd0, parsed by the RealEstate
// vtable slot 3 (sub_7FDF00); upstream EQEmu has no name for 0x6fd0.
// Sends the real-estate definition list (0x2698). The client parses it in sub_7F5B60: a u32
// count, then per entry (sub_7F4C90) u32 id, eight u32s, a u32 kind, a u32, a length-prefixed
// string, six more u32s and a child count. The kind lands in struct index 15 (node+60) -- the
// exact value sub_7F4FA0 returns and sub_7F5F70 tests, where the raw integer 5 is the only
// value that means "in a neighborhood" and 10 is the miss default. sub_7F4C90 stores every
// field verbatim (mov dword; the "f32" in early notes was decompiler type noise, same as the
// file loader's COERCE_FLOAT), so the kind must be the integer 5 -- NOT the IEEE bits of
// 5.0f (0x40A00000), which falls through the gate predicate's switch exactly like a miss.
void SendRealEstateDefinitions(Client *c, uint32_t definition_id)
{
	// Three definitions with distinct kinds: the zone itself is the neighborhood (kind 5,
	// what the identity lookup must return), id 1 is a plot (kind 8) and id 2 is a house
	// (kind 4). The client's predicates split on these: sub_7F5F70 accepts only 5 for the
	// +144 gate, sub_7F6280 tests 8 before registering an object's +36 as a map key, and
	// the "object under my feet" spatial test (sub_7F6030) plus the house-ancestor walk
	// (mask 0x88) only accept kinds {4, 8}.
	struct DefEntry {
		uint32_t id;
		uint32_t kind;
	};
	const DefEntry entries[3] = {
		{ definition_id, kRealEstateKindNeighborhood },
		{ 1,             kRealEstateKindPlot         },
		{ 2,             kRealEstateKindHouse        },
	};
	const int count = 3;

	Writer w;
	w.U32(count);

	for (const auto &entry : entries) {
		w.U32(entry.id);
		for (int i = 0; i < 8; ++i) {
			w.U32(0);
		}

		w.U32(entry.kind);   // index 15: raw integer kind (see the note above)
		w.U32(0);
		w.Str("");

		// Everything below is mandatory. sub_7F4C90 keeps reading after the string, and when
		// the buffer runs out it does not fall back to zero -- it uses the reader's own address
		// as the value, which drives a loop for billions of iterations and crashes the client.
		w.U32(0);   // +17
		w.U32(0);   // +18
		w.U32(0);   // +19 (float)
		w.U32(0);   // +20 (float)
		w.U32(0);   // +21 (float)
		w.U32(0);   // +22
		w.U32(0);   // child count -- MUST be present and 0
	}

	// sub_7FC6B0 then parses a second list from the same buffer; same trap, so give it a count.
	w.U32(0);

	const auto &buf = w.Buffer();
	auto outapp = new EQApplicationPacket(OP_RealEstateDefinitions, static_cast<uint32>(buf.size()));
	std::memcpy(outapp->pBuffer, buf.data(), buf.size());
	c->QueuePacket(outapp);
	safe_delete(outapp);

	LogInfo(
		"[Housing] sent real-estate definitions to [{}]: ids [{}] kind 5, [1] kind 8, [2] kind 4, {} bytes",
		c->GetName(), definition_id, buf.size()
	);
}

// Sends the player's owned plots in this neighborhood as RealEstate objects on
// OP_RealEstateObject (0x63fd). The client deserializes 0x63fd exactly like the 0x6fd0
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
		"SELECT p.door_id FROM nms_plot p "
		"JOIN nms_neighborhood n ON n.id = p.neighborhood_id "
		"WHERE n.zone = '{}' AND (p.owner_char_id = {} "
		"  OR (p.owner_guild_id > 0 AND p.owner_guild_id = {}))",
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
		const uint32_t door_id = Strings::ToUnsignedInt(row[0]);

		Writer w;
		w.U32(door_id);              // +20  own id -- the plot list uses door_id as plot_id
		w.U32(0);                    // +24
		w.U32(zone_id);              // +28  parent: the neighborhood object from the identity
		w.U32(1);                    // +32  defs key: definition id 1, kind 8 (plot)
		w.U32(0);                    // +36
		w.U32(0);                    // +40
		w.Str(zone_name);            // +48
		w.Str(fmt::format("Plot {}", door_id));  // +44
		w.U32(0);                    // +52
		w.U32(0);                    // child id list count
		w.Str("");                   // +56
		w.U8(0);                     // key/value pair count
		w.U32(kRealEstateKindPlot);  // +60  own kind
		w.U32(0);                    // +64
		w.U8(0);                     // +68

		const auto &buf = w.Buffer();
		auto outapp = new EQApplicationPacket(OP_RealEstateObject, static_cast<uint32>(buf.size()));
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

void Client::SendRealEstateIdentity()
{
	if (!zone || std::string(zone->GetShortName()) != "neighborhood") {
		return;
	}

	const std::string  zone_name = zone->GetShortName();

	// The first u32 becomes RealEstate[+140] (the neighborhood id the search request
	// echoes back). The fourth u32 becomes RealEstate[+144] after a lookup in the
	// client's own real-estate definition table, whose key is the zone id (zone 712 is
	// registered as 'neighborhood' by the sub_7DC430 call at 0x7E32F7 and must also
	// appear in RealEstateDefs.txt with kind 5).
	uint32_t    neighborhood_id = 1;
	std::string neighborhood_name = "Sunrise Hills";

	auto nb = database.QueryDatabase(fmt::format(
		"SELECT id, name FROM nms_neighborhood WHERE zone = '{}' LIMIT 1", Strings::Escape(zone_name)
	));

	if (nb.Success() && nb.RowCount()) {
		auto row = nb.begin();
		if (row[0]) {
			neighborhood_id = Strings::ToUnsignedInt(row[0]);
		}
		if (row[1]) {
			neighborhood_name = row[1];
		}
	}

	const uint32_t zone_id = zone->GetZoneID();

	// The definition list must be in the client's table BEFORE this packet is processed: the
	// lookup below returns struct index 15, whose miss default is 10, and the client appears to
	// latch the neighborhood value from the first identity it sees. The packet is well-formed
	// now (every trailing field present, plus the second list's count), so it no longer crashes.
	SendRealEstateDefinitions(this, zone_id);

	Writer w;
	w.U32(neighborhood_id);          // object +20 -> RealEstate[+140]
	w.U32(0);                        // +24
	w.U32(0);                        // +28
	w.U32(zone_id);                  // +32  real-estate object id
	w.U32(0);                        // +36
	w.U32(0);                        // +40
	w.Str(neighborhood_name);        // +48
	w.Str(zone_name);                // +44
	w.U32(0);                    // +52
	w.U32(0);                    // child id list count
	w.Str("");                   // +56
	w.U8(0);                     // key/value pair count
	w.U32(kRealEstateKindNeighborhood);  // +60  <- the value sub_7F5F70 tests for
	w.U32(0);                    // +64
	w.U8(0);                     // +68

	const auto &buf = w.Buffer();

	auto outapp = new EQApplicationPacket(OP_RealEstateZone, static_cast<uint32>(buf.size()));
	std::memcpy(outapp->pBuffer, buf.data(), buf.size());
	QueuePacket(outapp);
	safe_delete(outapp);

	LogInfo(
		"[Housing] sent real-estate identity to [{}]: neighborhood [{}] '{}', zone [{}], {} bytes",
		GetName(), neighborhood_id, neighborhood_name, zone_id, buf.size()
	);

	// Register the player's owned plots right after the identity so the client's plot map has
	// the kind-8 objects the plot/manage gates look up.
	SendRealEstatePlotObjects(this);
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
			"SELECT pos_x, pos_y FROM doors WHERE zone = '{}' AND doorid = {} AND version = 0 LIMIT 1",
			Strings::Escape(zone_name), door_id
		));

		if (!r.Success() || r.RowCount() == 0) {
			c->Message(Chat::White, fmt::format("[housing] there is no lot with door id [{}] here.", door_id).c_str());
			return;
		}

		const float px = static_cast<float>(Strings::ToFloat(r.begin()[0] ? r.begin()[0] : "0"));
		const float py = static_cast<float>(Strings::ToFloat(r.begin()[1] ? r.begin()[1] : "0"));

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
	if (sub == "send") {
		c->SendRealEstateIdentity();
		c->Message(Chat::White, "[housing] real-estate identity sent.");

		if (sep->arg[2] && !strcasecmp(sep->arg[2], "list")) {
			SendNeighborhoodList(c, zone_name);
			c->Message(Chat::White, "[housing] neighborhood list sent.");
		}

		if (sep->arg[2] && !strcasecmp(sep->arg[2], "defs")) {
			SendRealEstateDefinitions(c, zone->GetZoneID());
			c->SendRealEstateIdentity();
			c->Message(Chat::White, "[housing] definitions + identity sent.");
		}
		return;
	}

	// EXPERIMENTAL: build and send the 0x626e server->client packet for a lot, which is what
	// makes a placed building draw. Every field the client reads is bounds-checked, so a
	// short or partly-zero packet is safe -- it just leaves fields at their defaults. Field
	// semantics beyond the name and the position are still unknown, hence "experimental".
	if (sub == "exterior" && sep->IsNumber(2)) {
		const uint32_t door_id = Strings::ToUnsignedInt(sep->arg[2]);

		auto r = database.QueryDatabase(fmt::format(
			"SELECT pos_x, pos_y, pos_z, heading FROM doors WHERE zone = '{}' AND doorid = {} AND version = 0 LIMIT 1",
			Strings::Escape(zone_name), door_id
		));

		if (!r.Success() || r.RowCount() == 0) {
			c->Message(Chat::White, fmt::format("[housing] there is no lot with door id [{}] here.", door_id).c_str());
			return;
		}

		auto   row = r.begin();
		const float px = static_cast<float>(Strings::ToFloat(row[0] ? row[0] : "0"));
		const float py = static_cast<float>(Strings::ToFloat(row[1] ? row[1] : "0"));
		const float pz = static_cast<float>(Strings::ToFloat(row[2] ? row[2] : "0"));

		Writer w;
		// Both of these are null-terminated strings in this packet (the client measures them
		// with strlen, not a length prefix). Writing a length prefix here misaligned every
		// field after it, which is why the earlier attempts could not have rendered.
		w.CStr("Cobbler Style Stone Residence");  // max 63 bytes
		w.U8(0);
		w.U32(0);
		w.U32(0);
		w.CStr(MakeRealEstateId(zone->GetZoneID(), door_id));  // 16 chars, round-trip valid
		w.U32(0);
		w.U32(0);
		// The client's own placement request carries world x/y as *integers*: sub_5384D0 stores
		// its int parameters straight into the payload and bounds-checks them against integer
		// world limits. So these dwords are integer world units, not float bit patterns.
		w.U32(static_cast<uint32_t>(static_cast<int32_t>(px)));
		w.U32(static_cast<uint32_t>(static_cast<int32_t>(py)));
		w.U32(static_cast<uint32_t>(static_cast<int32_t>(pz)));
		for (int i = 0; i < 4; ++i) {
			w.U32(0);
		}
		w.U8(0); w.U8(0); w.U8(0);
		// Exactly eight dwords: the parser reads +156, +160, +164, +168, +172, +176, +180 and
		// +184. Two extra would shift the small object by 8 bytes and everything after it
		// would be read from the wrong offsets.
		for (int i = 0; i < 8; ++i) {
			w.U32(0);
		}
		// The small object (sub_4D60E0: u8 + 3 x u16) and the three following bytes are the
		// fields whose meaning is unknown, and they are what get handed to sub_558BB0 as the
		// placement parameters. Sweep them with the optional variant argument rather than
		// rebuilding for each guess.
		const int variant = sep->IsNumber(3) ? Strings::ToInt(sep->arg[3]) : 0;

		switch (variant) {
			case 1:   // u16 triple carries the low 16 bits of the world position
				w.U8(1); w.U16(static_cast<uint16>(px)); w.U16(static_cast<uint16>(py)); w.U16(static_cast<uint16>(pz));
				w.U8(1); w.U8(0); w.U8(0);
				break;
			case 2:   // u16 triple is a heading/type triple
				w.U8(0); w.U16(1); w.U16(1); w.U16(0);
				w.U8(0); w.U8(0); w.U8(1);
				break;
			case 3:   // all flags raised
				w.U8(1); w.U16(1); w.U16(1); w.U16(1);
				w.U8(1); w.U8(1); w.U8(1);
				break;
			default:  // zeros
				w.U8(0); w.U16(0); w.U16(0); w.U16(0);
				w.U8(0); w.U8(0); w.U8(0);
				break;
		}

		w.U32(0); w.U32(0); w.U32(0);
		w.U32(0);                               // child count
		w.U32(0); w.U32(0);

		const auto &buf = w.Buffer();
		auto outapp = new EQApplicationPacket(OP_RealEstatePlacement, static_cast<uint32>(buf.size()));
		std::memcpy(outapp->pBuffer, buf.data(), buf.size());
		c->QueuePacket(outapp);
		safe_delete(outapp);

		LogInfo("[Housing] experimental exterior for lot [{}] variant [{}] at ({:.1f}, {:.1f}, {:.1f}), {} bytes",
			door_id, variant, px, py, pz, buf.size());
		c->Message(Chat::White, "[housing] experimental exterior packet sent.");
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
