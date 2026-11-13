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

// Full RoF2 item-stream serializer (common/patches/rof2.cpp). The housing item list
// embeds complete item bodies, not the 16-byte InternalSerializedItem_Struct that
// ItemInstance::Serialize() produces; the client parses the body as a full item and
// a pointer struct makes it read a garbage length (the bed/qty-250 symptom).
namespace RoF2 {
void SerializeItem(EQ::OutBuffer& ob, const EQ::ItemInstance *inst, int16 slot_id, uint8 depth, ItemPacketType packet_type);
}

namespace {

// RoF2 senders put the player-type in the plot list as 4 and the guild-type as 8.
constexpr uint32_t kPlotOwnerPlayer = 4;
constexpr uint32_t kPlotOwnerGuild  = 8;

// Street address for a lot. The native windows title a plot "<neighbourhood>, <address>", and
// the address is a server-supplied string -- the client has no per-lot address of its own.
//
// Real addresses come from nms_plot_address, recovered from the client's own map file
// (maps/neighborhood_1.txt): the P-labels there are map-space, and world = (-x, -y), with each
// label sitting about 113 units off its door. Loaded once per process and cached.
// utils/sql/20261106_housing_plot_addresses.sql seeds the table.
//
// Anything unmapped falls back to the generated "<100 + door_id> <street>" form, which keeps
// every lot addressable even on a database without the table.
std::string PlotStreetAddress(uint32_t door_id)
{
	static std::unordered_map<uint32_t, std::string> s_addresses;
	static bool s_loaded = false;

	if (!s_loaded) {
		s_loaded = true;

		auto rows = database.QueryDatabase("SELECT door_id, address FROM nms_plot_address");
		if (rows.Success()) {
			for (auto row : rows) {
				if (row[0] && row[1]) {
					s_addresses[Strings::ToUnsignedInt(row[0])] = std::string(row[1]);
				}
			}
		}
	}

	const auto found = s_addresses.find(door_id);
	if (found != s_addresses.end()) {
		return found->second;
	}

	static const char *streets[] = {
		"Bazaar Street", "Sunrise Lane", "Market Row", "Willow Way",
		"Lantern Court", "Harvest Row", "Beacon Street", "Orchard Lane"
	};

	constexpr size_t street_count = sizeof(streets) / sizeof(streets[0]);

	return fmt::format("{} {}", 100 + door_id, streets[door_id % street_count]);
}

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

std::string EncodeRealEstateId(const uint8_t raw[12])
{
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

std::string MakeRealEstateId(uint32_t zone_id, uint32_t door_id)
{
	const uint8_t raw[12] = {
		0, 0, 0, 0,
		static_cast<uint8_t>(zone_id & 0xFF), static_cast<uint8_t>((zone_id >> 8) & 0xFF), 0, 0,
		static_cast<uint8_t>(door_id & 0xFF), 0, 0, 0
	};

	return EncodeRealEstateId(raw);
}

// Interior furniture needs a distinct GUID per placed item on one lot: the building GUID
// leaves raw bytes 6/7 and 9..11 zero, so the furniture row id rides in 9..11 (24 bits).
// The custom-alphabet round-trip (sub_80C920) still validates because the encoding stays
// canonical, and the door byte (8) is untouched.
std::string MakeFurnitureId(uint32_t zone_id, uint32_t door_id, uint32_t row_id)
{
	const uint8_t raw[12] = {
		0, 0, 0, 0,
		static_cast<uint8_t>(zone_id & 0xFF), static_cast<uint8_t>((zone_id >> 8) & 0xFF), 0, 0,
		static_cast<uint8_t>(door_id & 0xFF),
		static_cast<uint8_t>(row_id & 0xFF),
		static_cast<uint8_t>((row_id >> 8) & 0xFF),
		static_cast<uint8_t>((row_id >> 16) & 0xFF)
	};

	return EncodeRealEstateId(raw);
}

// Inverse of the alphabet encode: decodes a 16-character real-estate id back to its raw
// fields. False when the string is not a valid id (length or alphabet). Pickup resolves
// the furniture row from this, since the C2S body's exact field layout is only partly
// recovered while the GUID is echoed verbatim from the actor the client saw.
bool DecodeRealEstateId(const std::string &id, uint32_t &zone_id, uint32_t &door_id, uint32_t &row_id)
{
	zone_id = 0;
	door_id = 0;
	row_id  = 0;

	if (id.size() != 16) {
		return false;
	}

	auto index = [](char c) -> int {
		if (c >= '0' && c <= '9') { return c - '0'; }
		if (c >= 'A' && c <= 'Z') { return c - 'A' + 10; }
		if (c >= 'a' && c <= 'z') { return c - 'a' + 36; }
		if (c == '+') { return 62; }
		if (c == '-') { return 63; }
		return -1;
	};

	uint8_t raw[12] = {};

	for (size_t g = 0; g < 4; ++g) {
		const int v0 = index(id[g * 4 + 0]);
		const int v1 = index(id[g * 4 + 1]);
		const int v2 = index(id[g * 4 + 2]);
		const int v3 = index(id[g * 4 + 3]);

		if (v0 < 0 || v1 < 0 || v2 < 0 || v3 < 0) {
			return false;
		}

		raw[g * 3 + 0] = static_cast<uint8_t>((v0 << 2) | (v1 >> 4));
		raw[g * 3 + 1] = static_cast<uint8_t>(((v1 & 0xF) << 4) | (v2 >> 2));
		raw[g * 3 + 2] = static_cast<uint8_t>(((v2 & 0x3) << 6) | v3);
	}

	zone_id = raw[4] | (static_cast<uint32_t>(raw[5]) << 8);
	door_id = raw[8];
	row_id  = raw[9] | (static_cast<uint32_t>(raw[10]) << 8) | (static_cast<uint32_t>(raw[11]) << 16);

	return true;
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

	// Raw embedded bytes (the item-list entries carry a full item serialization).
	void Bytes(const std::string &s) {
		m_buf.insert(m_buf.end(), s.begin(), s.end());
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
};// Every plot in the neighbourhood appears in the plot list, including vacant ones: the
// client's reader (sub_74C4C0) adds a row only when the owner type is 4 (Player) or 8
// (Guild), so a vacant lot is published as type 4 with an empty owner name -- enough for
// the row to render (address in the first column) and for the purchase path to reach it.
std::vector<PlotRow> LoadOwnedPlots(const std::string &zone_short_name)
{
	std::vector<PlotRow> rows;

	auto results = database.QueryDatabase(fmt::format(
		"SELECT p.door_id, p.plot_type, COALESCE(c.name, ''), COALESCE(g.name, ''), nb.name "
		"FROM nms_plot p "
		"JOIN nms_neighborhood nb ON nb.id = p.neighborhood_id "
		"LEFT JOIN character_data c ON c.id = p.owner_char_id "
		"LEFT JOIN guilds g ON g.id = p.owner_guild_id "
		"WHERE nb.zone = '{}' "
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
		r.address = PlotStreetAddress(r.door_id);

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

// The inventory-source profile of the 44-byte placement Source (0x3424 deposits and
// inventory-source 0x626e Begins). Identity is carried by the sentinels: estate id and item
// id are 0xFFFFFFFF and the opaque word is 0. The slot packing is NOT what the reference
// validator assumes: a live deposit (2026-11-09 capture) carried the slot (0x1B = 27) in
// location[0] low with a type word high, and 0x9000 in location[1] low -- not the reference's
// location[0]==0 with the slot in location[1]. Both shapes are accepted; only the slot is
// load-bearing server-side (GetInv lookup), and the client-generated GUID is ignored.
bool DecodeInventorySource(const EQApplicationPacket *app, uint32_t &slot_out, uint32_t &sub_out);

// A house item (residence/deed): the same word list #housing place uses. These route to the
// building flow, not the furniture flow. Defined after the estate-id constants below.
bool IsHousePlacementItem(uint32_t item_id);

// Estate ids at/above kHouseEstateBase are house-interior handles for door (id - base).
uint32_t NormalizeEstateDoor(uint32_t estate_id);

bool DecodeInventorySource(const EQApplicationPacket *app, uint32_t &slot_out, uint32_t &sub_out)
{
	if (ReadU32(app, 32) != UINT32_MAX || ReadU32(app, 36) != UINT32_MAX || ReadU32(app, 40) != 0) {
		return false;
	}

	const uint32_t loc0 = ReadU32(app, 20);
	const uint32_t loc1 = ReadU32(app, 24);

	uint32_t slot = 0;
	uint32_t sub  = 0;

	// Each word packs (sub << 16) | main. sub 0 is a top-level item; a non-zero sub is the
	// index inside the bag sitting in the main slot -- observed live as 0x0006001A = bag 26,
	// item 6, which the old decoder read as "take the bag itself".
	if (loc0 != 0 && (loc0 & 0xFFFF0000u) != 0xFFFF0000u) {
		slot = loc0 & 0xFFFFu;   // live client: slot in location[0] low
		sub  = loc0 >> 16;
	} else if (loc0 == 0) {
		slot = loc1 & 0xFFFFu;   // reference validator shape: slot in location[1] low
		sub  = loc1 >> 16;
	} else {
		return false;
	}

	if (slot < 23 || slot > 33) {
		return false;
	}

	slot_out = slot;
	sub_out  = sub;
	return true;
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
// House-interior estates: each housed plot exposes one child estate (id = base + door) whose
// definition is type 2 -- the house-interior kind. The client's Items-window binder
// (sub_5AFFC0) walks the plot-underfoot's children for a type-2/3 definition and binds
// RealEstate[+156] to it; that field is what the window's House pane (+624) renders and what
// ungreys the Shed/Closet buttons (sub_73B7E0 reads +152/+156/+160 into +620/+624/+628).
// Estate ids at/above the base normalize back to the door id in every handler that keys rows.
constexpr uint32_t kHouseEstateBase      = 600000;
constexpr uint32_t kHouseInteriorDefBase = 600000;

uint32_t PlotDefinitionId(uint32_t door_id) { return kPlotDefinitionBase + door_id; }
uint32_t PlotRegionId(uint32_t door_id)     { return kPlotRegionBase + door_id; }

// The reviewed RoF2 house-template registry (nms_house_template): which interior zone a placed
// building item opens, and the catalogue definition/type it belongs to. The building on the lot
// decides the interior -- never a global default.
struct HouseTemplateRow {
	uint32_t    definition_id = 0;
	uint32_t    house_type    = 0;
	uint32_t    zone_id       = 0;
	std::string model;
};

bool LoadHouseTemplate(uint32_t item_id, HouseTemplateRow &out)
{
	if (!item_id) {
		return false;
	}

	auto r = database.QueryDatabase(fmt::format(
		"SELECT definition_id, house_type, zone_id, COALESCE(model, '') "
		"FROM nms_house_template WHERE item_id = {} LIMIT 1", item_id
	));

	if (!r.Success() || !r.RowCount()) {
		return false;
	}

	auto row = r.begin();

	out.definition_id = Strings::ToUnsignedInt(row[0] ? row[0] : "0");
	out.house_type    = Strings::ToUnsignedInt(row[1] ? row[1] : "0");
	out.zone_id       = Strings::ToUnsignedInt(row[2] ? row[2] : "0");
	out.model         = row[3] ? row[3] : "";

	return out.zone_id != 0;
}

// zone.zoneidnumber is the canonical numeric id; the template stores that, the schema stores
// short names.
std::string ZoneShortNameForNumber(uint32_t zone_id)
{
	if (!zone_id) {
		return {};
	}

	auto r = database.QueryDatabase(fmt::format(
		"SELECT short_name FROM zone WHERE zoneidnumber = {} ORDER BY version LIMIT 1", zone_id
	));

	if (!r.Success() || !r.RowCount() || !r.begin()[0]) {
		return {};
	}

	return r.begin()[0];
}

// Per-house capacity profile (nms_house_capacity). A zero in a subset field means "no
// artificial sub-cap": the reviewed source left those null and never established them, so the
// server must not pretend they are recovered limits.
struct HouseCapacity {
	uint32_t max_items      = 300;
	uint32_t max_non_estate = 0;
	uint32_t max_npc        = 0;
	uint32_t max_vault      = 60;
};

HouseCapacity LoadHouseCapacity(uint32_t definition_id)
{
	HouseCapacity out;

	if (!definition_id) {
		return out;
	}

	auto r = database.QueryDatabase(fmt::format(
		"SELECT max_items, max_non_estate_items, max_npc_items, max_vault "
		"FROM nms_house_capacity WHERE definition_id = {} LIMIT 1", definition_id
	));

	if (!r.Success() || !r.RowCount()) {
		return out;
	}

	auto row = r.begin();

	const uint32_t max_items = Strings::ToUnsignedInt(row[0] ? row[0] : "0");

	out.max_items      = max_items ? max_items : out.max_items;
	out.max_non_estate = Strings::ToUnsignedInt(row[1] ? row[1] : "0");
	out.max_npc        = Strings::ToUnsignedInt(row[2] ? row[2] : "0");
	out.max_vault      = Strings::ToUnsignedInt(row[3] ? row[3] : "0");

	return out;
}

// The catalogue definition of the building on a lot (nms_house_template.definition_id).
uint32_t PlotHouseDefinition(uint32_t door_id)
{
	auto r = database.QueryDatabase(fmt::format(
		"SELECT COALESCE(t.definition_id, 0) FROM nms_plot p "
		"LEFT JOIN nms_house_template t ON t.item_id = p.house_item_id "
		"WHERE p.door_id = {} LIMIT 1", door_id
	));

	if (!r.Success() || !r.RowCount() || !r.begin()[0]) {
		return 0;
	}

	return Strings::ToUnsignedInt(r.begin()[0]);
}

// Rows a lot holds. container -2 counts everything (placed + all containers).
uint32_t PlotItemCount(uint32_t door_id, int container)
{
	const std::string filter = (container == -2) ? "" : fmt::format(" AND container = {}", container);

	auto r = database.QueryDatabase(fmt::format(
		"SELECT COUNT(*) FROM nms_house_item WHERE door_id = {}{}", door_id, filter
	));

	if (!r.Success() || !r.RowCount() || !r.begin()[0]) {
		return 0;
	}

	return Strings::ToUnsignedInt(r.begin()[0]);
}

// Container ids: -1 placed in the world, 0 closet (house), 1 shed (yard), 2 crate.
constexpr int kContainerPlaced = -1;
constexpr int kContainerCloset = 0;
constexpr int kContainerShed   = 1;
constexpr int kContainerCrate  = 2;

const char *ContainerName(int container)
{
	switch (container) {
		case kContainerCloset: return "closet";
		case kContainerShed:   return "shed";
		case kContainerCrate:  return "crate";
		default:               return "placed";
	}
}


// A house item (residence/deed): the same word list #housing place uses. These route to the
// building flow, not the furniture flow.
bool IsHousePlacementItem(uint32_t item_id)
{
	auto found = database.QueryDatabase(fmt::format(
		"SELECT 1 FROM items WHERE id = {} "
		"  AND (Name LIKE '%Residence%' OR Name LIKE '%Deed%' OR Name LIKE '%House%' "
		"    OR Name LIKE '%Hut%' OR Name LIKE '%Cottage%' OR Name LIKE '%Manor%' "
		"    OR Name LIKE '%Villa%' OR Name LIKE '%Chalet%' OR Name LIKE '%Cabin%' "
		"    OR Name LIKE '%Lodge%') "
		"  AND Name NOT LIKE '%Key%' LIMIT 1",
		item_id
	));

	return found.Success() && found.RowCount();
}

// Estate ids at/above kHouseEstateBase are house-interior handles for door (id - base).
uint32_t NormalizeEstateDoor(uint32_t estate_id)
{
	return estate_id >= kHouseEstateBase ? estate_id - kHouseEstateBase : estate_id;
}

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

// Last-resort interior when neither the building item nor an existing house row names one
// (a GM claim before any building is placed).
constexpr const char *kDefaultHouseZone = "phinterior1a1";

// "Zimel Style Stucco House, Stucco interior" -- a real house item in this database.
constexpr uint32_t kDefaultHouseItem = 61823;

// A plot needs a house interior, and WHICH interior is the building item's business: the
// reviewed RoF2 registry maps every house/guild-hall item to its interior zone
// (nms_house_template). A GM claim with no building yet falls back to the default one-bedroom;
// a placed building -- or an explicit house item -- always wins, and an existing interior is
// re-pointed when the building changes the type of house. Retail: the house on the lot decides
// the zone its door opens into.
void AttachHouseToPlot(Client *c, const std::string &zone_name, uint32_t door_id, uint32_t house_item_id)
{
	uint32_t    house_id = 0;
	std::string house_zone;

	// The building says which interior; a character's existing house only fills the gap.
	HouseTemplateRow tpl;

	if (LoadHouseTemplate(house_item_id, tpl)) {
		house_zone = ZoneShortNameForNumber(tpl.zone_id);

		if (house_zone.empty()) {
			LogInfo(
				"[Housing] house item [{}] maps to zone [{}], which is not in the zone table; "
				"falling back to [{}]",
				house_item_id, tpl.zone_id, kDefaultHouseZone
			);
		}
	}

	auto existing = database.QueryDatabase(fmt::format(
		"SELECT id, zone FROM house WHERE char_id = {} LIMIT 1", c->CharacterID()
	));

	if (existing.Success() && existing.RowCount()) {
		auto row = existing.begin();
		house_id = Strings::ToUnsignedInt(row[0] ? row[0] : "0");

		const std::string old_zone = row[1] ? row[1] : "";

		if (house_zone.empty()) {
			house_zone = old_zone.empty() ? kDefaultHouseZone : old_zone;
		}

		if (old_zone != house_zone) {
			// The building changed the type of house: the interior has to be a new instance of
			// the matching zone. The house id -- and the player's key -- survives.
			const uint32_t instance_id = quest_manager.CreateInstance(house_zone, 0, kHouseDuration);

			if (!instance_id) {
				LogInfo("[Housing] could not create an instance of [{}] for [{}]", house_zone, c->GetName());
				return;
			}

			database.QueryDatabase(fmt::format(
				"UPDATE house SET instance_id = {}, zone = '{}' WHERE id = {}",
				instance_id, Strings::Escape(house_zone), house_id
			));

			LogInfo(
				"[Housing] re-templated house #{} for [{}]: [{}] -> [{}], instance [{}]",
				house_id, c->GetName(), old_zone, house_zone, instance_id
			);
		}
		else {
			LogInfo(
				"[Housing] [{}] already has house #{} in [{}]; linking lot {} to it",
				c->GetName(), house_id, house_zone, door_id
			);
		}
	}
	else {
		if (house_zone.empty()) {
			house_zone = kDefaultHouseZone;
		}

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
			LogInfo("[Housing] house insert failed for [{}] on lot {}", c->GetName(), door_id);
			return;
		}

		house_id = static_cast<uint32_t>(inserted.LastInsertedID());

		LogInfo(
			"[Housing] [{}] created house #{} in [{}] instance [{}] for lot {} (item [{}])",
			c->GetName(), house_id, house_zone, instance_id, door_id, house_item_id
		);
	}

	// Key the lot by door: the yard and the interior both resolve through it.
	auto linked = database.QueryDatabase(fmt::format(
		"UPDATE nms_plot p JOIN nms_neighborhood n ON n.id = p.neighborhood_id "
		"SET p.house_id = {}, p.house_zone = '{}' "
		"WHERE n.zone = '{}' AND p.door_id = {}",
		house_id, Strings::Escape(house_zone), Strings::Escape(zone_name), door_id
	));

	if (!linked.Success() || linked.RowsAffected() == 0) {
		// A call from outside the neighborhood (interior, PoK): the door id is the identity
		// every other housing row uses.
		database.QueryDatabase(fmt::format(
			"UPDATE nms_plot SET house_id = {}, house_zone = '{}' WHERE door_id = {}",
			house_id, Strings::Escape(house_zone), door_id
		));
	}
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

	AttachHouseToPlot(c, zone_short_name, plot.door_id, 0);

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

// Interior furniture (v1), defined with the wire encoders below. The placement Begin/Commit
// handlers call these, and the identity burst renders the rows.
bool IsPlaceableHousingItem(uint32_t item_id);
bool ResolveOwnedInterior(Client *c, uint32_t &door_id, uint32_t &nb_id);
bool FurniturePlotIsMine(Client *c, uint32_t door_id);
bool SendRealEstateFurnitureWorldItem(Client *c, uint32_t door_id, uint32_t row_id, uint32_t item_id,
                                      const std::string &model, uint32_t zone_id,
                                      float x, float y, float z, float heading, float scale);
bool SendRealEstateFurnitureWorldRemove(Client *c, uint32_t door_id, uint32_t row_id,
                                        uint32_t item_id, uint32_t zone_id);
void SendRealEstateFurniture(Client *c, uint32_t door_id);
bool ReturnFurnitureRow(Client *c, uint32_t row_id);
bool StoreFurnitureRow(Client *c, uint32_t row_id, int container);

// Client-UI placement (v2): the estate item list that fills the Items window, the placement
// preview for furniture rows, and the 0x1228 result that closes the preview loop.
void SendRealEstateItemList(Client *c, uint32_t estate_id);
bool SendRealEstateFurniturePreview(Client *c, uint32_t door_id, uint32_t row_id, uint32_t item_id,
                                    const std::string &model, uint32_t zone_id, uint32_t neighborhood_id,
                                    float x, float y, float z, float heading, float pitch, float roll,
                                    float scale);
void SendRealEstateOperationResult(Client *c, uint32_t result);

// Log-only coverage for the remaining real-estate messages lives in Client::MapOpcodes
// (k_log_only_rof2), which registers them against Client::Handle_OP_Unimplemented.

// 0x2b35 S2C: the native client consumes exactly one mode byte. Mode 1 opens the Plot Search
// window and enables selected-row 0x796c inspection; see docs/rof2-opcode-harvest.md.
void SendRealEstatePlotSearchOpen(Client *c, uint8_t mode);

// Defined with the housing commands below; the 0x1da9 handler answers with it.
void HousingLeave(Client *c, bool notify = true);

// 0x21ec C2S item menu: a fixed 768-byte frame. Recovered layout: 16-character GUID + 2 zero
// bytes, 2 bytes of padding, three u32 location words at 20/24/28, estate id at 32, item id
// at 36, opaque at 40, title field 44..107, action records 108..747 (16 bytes each: type,
// parameter, eqstr label, UINT32_MAX), profile byte 748, mouse at 752/756, opaque 760/764.
// The reply reuses that frame with our own GUID and only the actions this server can honour.
void Client::Handle_OP_RealEstateItemMenu(const EQApplicationPacket *app)
{
	LogHousingOpcode(this, app, "OP_RealEstateItemMenu");

	if (!zone || app->size != 768) {
		return;
	}

	const uint32_t estate_id = ReadU32(app, 32);
	const uint32_t item_id   = ReadU32(app, 36);

	if (!estate_id || estate_id == UINT32_MAX || !item_id || item_id == UINT32_MAX) {
		return;
	}

	// House-interior handles normalize to the door id; the reply echoes what arrived.
	const uint32_t door = NormalizeEstateDoor(estate_id);

	// Only the building this server actually placed on the lot is interactive: there is no
	// furniture custody here, so any other item id would offer actions that cannot be kept.
	auto plot = database.QueryDatabase(fmt::format(
		"SELECT p.house_item_id, p.owner_char_id, p.owner_guild_id "
		"FROM nms_plot p JOIN nms_neighborhood n ON n.id = p.neighborhood_id "
		"WHERE n.zone = '{}' AND p.door_id = {} LIMIT 1",
		Strings::Escape(zone->GetShortName()), door
	));

	if (!plot.Success() || !plot.RowCount()) {
		LogInfo("[Housing] item menu for unknown estate [{}] from [{}]", estate_id, GetName());
		return;
	}

	auto row = plot.begin();

	const uint32_t house_item_id  = Strings::ToUnsignedInt(row[0] ? row[0] : "0");
	const uint32_t owner_char_id  = Strings::ToUnsignedInt(row[1] ? row[1] : "0");
	const uint32_t owner_guild_id = Strings::ToUnsignedInt(row[2] ? row[2] : "0");

	if (!house_item_id || item_id != house_item_id) {
		// Not the building: a furniture row. The frame's item id is the nms_house_item row id
		// (the identity the item list and world actor carry), and the reply's GUID must be the
		// row's MakeFurnitureId form so the client correlates the actions to that actor.
		auto furn = database.QueryDatabase(fmt::format(
			"SELECT h.item_id, h.placed_by, p.owner_char_id, p.owner_guild_id, COALESCE(c.name, '') "
			"FROM nms_house_item h "
			"JOIN nms_plot p ON p.door_id = h.door_id "
			"JOIN nms_neighborhood nb ON nb.id = p.neighborhood_id "
			"LEFT JOIN character_data c ON c.id = h.placed_by "
			"WHERE nb.zone = '{}' AND h.door_id = {} AND h.id = {} LIMIT 1",
			Strings::Escape(zone->GetShortName()), door, item_id
		));

		if (!furn.Success() || !furn.RowCount()) {
			LogInfo(
				"[Housing] item menu for estate [{}] item [{}] ignored: not the building [{}] and not a placed row",
				estate_id, item_id, house_item_id
			);
			return;
		}

		auto f = furn.begin();

		const bool owner = Strings::ToUnsignedInt(f[2] ? f[2] : "0") == CharacterID() ||
			(Strings::ToUnsignedInt(f[3] ? f[3] : "0") != 0 &&
			 Strings::ToUnsignedInt(f[3] ? f[3] : "0") == GuildID());

		const std::string guid = MakeFurnitureId(zone->GetZoneID(), door, item_id);

		std::vector<uint8_t> frame(768, 0);
		auto put32 = [&frame](size_t at, uint32_t value) {
			for (int i = 0; i < 4; ++i) {
				frame[at + i] = static_cast<uint8_t>((value >> (8 * i)) & 0xFF);
			}
		};

		std::memcpy(frame.data(), guid.data(), guid.size() < 16 ? guid.size() : 16);
		put32(20, UINT32_MAX);
		put32(24, UINT32_MAX);
		put32(28, UINT32_MAX);
		put32(32, estate_id);
		put32(36, item_id);

		// Title at 44: the item name keeps the frame shape; the client displays it as the menu heading.
		std::string title;
		const auto *fdata = database.GetItem(Strings::ToUnsignedInt(f[0] ? f[0] : "0"));
		if (fdata) {
			title = std::string(fdata->Name);
			if (title.size() > 63) {
				title.resize(63);
			}
			for (char &ch : title) {
				const auto c = static_cast<unsigned char>(ch);
				if (c < 32 || c > 126) {
					ch = ' ';
				}
			}
		}
		std::memcpy(frame.data() + 44, title.data(), title.size());
		std::fill(frame.begin() + 108, frame.begin() + 748, 0xFF);

		size_t record = 108;
		auto action = [&](uint32_t type, uint32_t parameter, uint32_t label) {
			if (record + 16 > 748) {
				return;
			}
			put32(record, type);
			put32(record + 4, parameter);
			put32(record + 8, label);
			put32(record + 12, UINT32_MAX);
			record += 16;
		};

		action(7, 0, 720);            // eqstr 720: Inspect (the 0x58c7 handler serves rows too)
		if (owner) {
			action(2, 1, 5244);       // eqstr 5244: Move -- the client re-places via Begin/Commit
			action(4, 0, 724);        // eqstr 724: Pick Up -- answered by 0x2036 -> row return
		}

		// 748 nonzero hides the edit actions (2/param 1, 3, 4, 11, 14); set it only when we
		// actually offered none, or an ownerless menu would hide its own Inspect.
		frame[748] = (record > 108) ? 0 : 1;
		put32(752, ReadU32(app, 752));
		put32(756, ReadU32(app, 756));

		auto outapp = new EQApplicationPacket(OP_RealEstateItemMenu, static_cast<uint32>(frame.size()));
		std::memcpy(outapp->pBuffer, frame.data(), frame.size());
		QueuePacket(outapp);
		safe_delete(outapp);

		LogInfo(
			"[Housing] item menu for [{}]: estate [{}] furniture row [{}] owner [{}], actions [{}]",
			GetName(), estate_id, item_id, owner, record > 108 ? (record - 108) / 16 : 0
		);
		return;
	}

	const auto *data = database.GetItem(item_id);
	if (!data) {
		return;
	}

	const bool owner = owner_char_id == CharacterID() ||
		(owner_guild_id && owner_guild_id == GuildID());

	std::string title(data->Name);
	if (title.size() > 63) {
		title.resize(63);
	}
	for (char &ch : title) {
		const auto c = static_cast<unsigned char>(ch);
		if (c < 32 || c > 126) {
			ch = ' ';
		}
	}

	std::vector<uint8_t> frame(768, 0);
	auto put32 = [&frame](size_t at, uint32_t value) {
		for (int i = 0; i < 4; ++i) {
			frame[at + i] = static_cast<uint8_t>((value >> (8 * i)) & 0xFF);
		}
	};

	const std::string guid = MakeRealEstateId(zone->GetZoneID(), estate_id);
	std::memcpy(frame.data(), guid.data(), guid.size() < 16 ? guid.size() : 16);

	put32(20, UINT32_MAX);
	put32(24, UINT32_MAX);
	put32(28, UINT32_MAX);
	put32(32, estate_id);
	put32(36, item_id);

	std::memcpy(frame.data() + 44, title.data(), title.size());
	std::fill(frame.begin() + 108, frame.begin() + 748, 0xFF);

	size_t record = 108;
	auto action = [&](uint32_t type, uint32_t parameter, uint32_t label) {
		if (record + 16 > 748) {
			return;
		}
		put32(record, type);
		put32(record + 4, parameter);
		put32(record + 8, label);
		put32(record + 12, UINT32_MAX);
		record += 16;
	};

	action(7, 0, 720);            // eqstr 720: Inspect
	if (owner) {
		action(1, 0, 723);         // eqstr 723: Enter
		action(17, 0, 5336);       // eqstr 5336: Swap Houses -- 0x21ba carries the choice
	}

	frame[748] = (record > 108) ? 0 : 1;   // nonzero hides the edit actions; we always send Inspect
	put32(752, ReadU32(app, 752));
	put32(756, ReadU32(app, 756));

	auto outapp = new EQApplicationPacket(OP_RealEstateItemMenu, static_cast<uint32>(frame.size()));
	std::memcpy(outapp->pBuffer, frame.data(), frame.size());
	QueuePacket(outapp);
	safe_delete(outapp);

	LogInfo(
		"[Housing] item menu for [{}]: estate [{}] item [{}] '{}', owner [{}], actions [{}]",
		GetName(), estate_id, item_id, title, owner, record > 108 ? (record - 108) / 16 : 0
	);
}

// 0x796c C2S inspect: exactly 4 bytes, the estate id. The recovered reply is the single-plot
// inspection record: u32 request, u8 estate type (4 personal plot / 8 guild plot), u32 subtype,
// u16 count (1), five u32 ids (estate, parent, definition, guild, fellowship), four
// length-prefixed strings (context, display name, owner name, owner handle), four opaque
// words, u8 show. The reply rides on 0x2691 (see SendRealEstateInspection); we answer for
// plots only, with the ids the 0x6fd0/0x63fd snapshot already registered for the same door:
// estate = door id, parent = zone id, definition = PlotDefinitionId(door).
bool SendRealEstateInspection(Client *c, uint32_t estate_id, bool show);
void SendRealEstateAccessList(Client *c, uint32_t estate_id);

void Client::Handle_OP_RealEstateInspect(const EQApplicationPacket *app)
{
	LogHousingOpcode(this, app, "OP_RealEstateInspect");

	if (!zone || app->size != 4) {
		return;
	}

	const uint32_t estate_id = ReadU32(app, 0);

	SendRealEstateInspection(this, estate_id, true);
	// The manage window's access data rides along with the inspection in the retail flow.
	SendRealEstateAccessList(this, estate_id);
}

// Builds and sends the single-plot inspection record for one estate. show=true opens the
// purchase window (the answer to a client inspect or a lot-marker click); show=false just
// seeds the client's estate data, which is what we push on zone-in so the Manage window has
// something to render the moment it is opened.
//
// The record rides on OP_RealEstateNeighborhood (0x2691), not on the inspect request's own
// value: the client only ever SENDS 0x796c (PlotSearch selected-row path, sub_74C110, reached
// through vtable 0x9F8F30) and has no incoming dispatch case for it anywhere. On 0x2691 the
// record branch (sub_5B0F80 -> sub_7F6030) fires when the kind byte is 4 or 8, registers the
// estate, and is the only code in the client that fills and shows RealEstatePurchaseWnd.
bool SendRealEstateInspection(Client *c, uint32_t estate_id, bool show)
{
	if (!c || !zone || !estate_id || estate_id == UINT32_MAX) {
		return false;
	}

	auto plot = database.QueryDatabase(fmt::format(
		"SELECT p.plot_type, COALESCE(c.name, ''), COALESCE(g.name, ''), p.owner_guild_id, "
		"       COALESCE(nb.name, '') "
		"FROM nms_plot p "
		"JOIN nms_neighborhood nb ON nb.id = p.neighborhood_id "
		"LEFT JOIN character_data c ON c.id = p.owner_char_id "
		"LEFT JOIN guilds g ON g.id = p.owner_guild_id "
		"WHERE nb.zone = '{}' AND p.door_id = {} LIMIT 1",
		Strings::Escape(zone->GetShortName()), estate_id
	));

	if (!plot.Success() || !plot.RowCount()) {
		LogInfo("[Housing] inspect for unknown estate [{}] from [{}]", estate_id, c->GetName());
		return false;
	}

	auto row = plot.begin();

	const uint32_t    plot_type   = Strings::ToUnsignedInt(row[0] ? row[0] : "0");
	const std::string char_name   = std::string(row[1] ? row[1] : "");
	const std::string guild_name  = std::string(row[2] ? row[2] : "");
	const uint32_t    owner_guild = Strings::ToUnsignedInt(row[3] ? row[3] : "0");
	const std::string context     = std::string(row[4] ? row[4] : "");

	Writer w;
	// Request id, not the estate. The reference encoder (estate_wire.h EncodeInspection) takes
	// this as a parameter that defaults to 0; the client skips these four bytes unconditionally
	// (sub_5B0F80 advances the reader before touching the kind byte), so 0 is always safe.
	w.U32(0);                                      // request id
	// Estate type per the recovered single-plot inspection record: 4 = personal plot,
	// 8 = guild plot. nms_plot plot_type 1 is the guild-owned row. The client's record branch
	// (sub_5B0F80 -> sub_7F6030) fires only on 4/8; any other first byte parses the body as a
	// plot-search mode instead.
	w.U8(plot_type == 1 ? 8 : 4);
	w.U32(0);
	w.U8(1);                                       // the show gate tests this u16 pair > 0
	w.U8(0);
	w.U32(estate_id);
	w.U32(zone->GetZoneID());                      // parent: the neighbourhood object, as 0x6fd0 sent it
	w.U32(PlotDefinitionId(estate_id));
	w.U32(owner_guild ? owner_guild : 0);          // 0 = no guild; -1 would fail the client's plot predicate
	w.U32(0);                                      // fellowship
	// Four strings, reference names "context, display name, owner name, owner handle". The
	// client keeps three of them on the estate record: display name (2nd) becomes the purchase
	// window title (sub_74DCB0 reads record+0x38), owner handle (4th) lands at record+0x2C and
	// is both the window's Owner row and the owner record the Manage kind-4 predicate wants
	// (sub_5B41D0). The 1st string is read and discarded; the 3rd sits at +0x30 unwitnessed.
	const std::string address = PlotStreetAddress(estate_id);
	w.Str(context);
	w.Str(context.empty() ? address : fmt::format("{}, {}", context, address));
	w.Str(plot_type == 1 ? guild_name : char_name);
	w.Str(plot_type == 1 ? guild_name : char_name); // owner handle: the popup's Owner row
	for (int i = 0; i < 4; ++i) {
		w.U32(0);                                  // opaque tail: four unwitnessed words
	}
	w.U8(show ? 1 : 0);                            // 1 opens the window, 0 only seeds the data

	// The record rides on OP_RealEstateNeighborhood (0x2691): the client only ever SENDS
	// 0x796c and has no incoming dispatch case for it; sub_5B0F80's record branch is the only
	// code that fills and shows RealEstatePurchaseWnd.
	const auto &buf = w.Buffer();
	auto outapp = new EQApplicationPacket(OP_RealEstateNeighborhood, static_cast<uint32>(buf.size()));
	std::memcpy(outapp->pBuffer, buf.data(), buf.size());
	c->QueuePacket(outapp);
	safe_delete(outapp);

	LogInfo(
		"[Housing] inspection record for [{}]: estate [{}] type [{}] owner '{}' context '{}' show [{}] ({} bytes)",
		c->GetName(), estate_id, plot_type, plot_type == 1 ? guild_name : char_name, context,
		show ? 1 : 0, buf.size()
	);

	return true;
}

// 0x58c7 C2S item inspect: 8 bytes, estate id + item id. The client consumes a direct
// serialized item here -- no estate ids, result word or item-type prefix -- so the reply is
// the same body an ItemPacket carries.
void Client::Handle_OP_RealEstateItemInspect(const EQApplicationPacket *app)
{
	LogHousingOpcode(this, app, "OP_RealEstateItemInspect");

	if (!zone || app->size < 8) {
		return;
	}

	const uint32_t estate_id = ReadU32(app, 0);
	const uint32_t item_id   = ReadU32(app, 4);

	if (!estate_id || estate_id == UINT32_MAX || !item_id || item_id == UINT32_MAX) {
		return;
	}

	auto plot = database.QueryDatabase(fmt::format(
		"SELECT p.house_item_id FROM nms_plot p JOIN nms_neighborhood n ON n.id = p.neighborhood_id "
		"WHERE n.zone = '{}' AND p.door_id = {} LIMIT 1",
		Strings::Escape(zone->GetShortName()), estate_id
	));

	if (!plot.Success() || !plot.RowCount()) {
		return;
	}

	const uint32_t house_item_id = Strings::ToUnsignedInt(plot.begin()[0] ? plot.begin()[0] : "0");
	if (!house_item_id || item_id != house_item_id) {
		return;
	}

	const auto *data = database.GetItem(item_id);
	if (!data) {
		return;
	}

	auto *inst = database.CreateBaseItem(data, 1);
	if (!inst) {
		return;
	}

	const std::string body = inst->Serialize(EQ::invslot::slotCursor);
	safe_delete(inst);

	if (body.empty()) {
		return;
	}

	auto outapp = new EQApplicationPacket(OP_RealEstateItemInspect, static_cast<uint32>(body.size()));
	std::memcpy(outapp->pBuffer, body.data(), body.size());
	QueuePacket(outapp);
	safe_delete(outapp);

	LogInfo("[Housing] inspected item [{}] on estate [{}] for [{}]: {} bytes", item_id, estate_id, GetName(), body.size());
}

void SendRealEstatePlotSearchOpen(Client *c, uint8_t mode)
{
	if (!c) {
		return;
	}

	Writer w;
	w.U8(mode ? 1 : 0);

	const auto &buf = w.Buffer();
	auto outapp = new EQApplicationPacket(OP_RealEstatePlotSearchOpen, static_cast<uint32>(buf.size()));
	std::memcpy(outapp->pBuffer, buf.data(), buf.size());
	c->QueuePacket(outapp);
	safe_delete(outapp);

	LogInfo("[Housing] sent plot-search open mode [{}] to [{}]", mode ? 1 : 0, c->GetName());
}

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


// 0x2a9e S2C: retires a world actor. The consumer reads the GUID at 0..15 and the
// estate/item pair at 32/36; 16..31 is padding.
bool SendRealEstateWorldRemove(Client *c, uint32_t door_id, uint32_t item_id, uint32_t zone_id)
{
	if (!c) {
		return false;
	}

	const std::string guid = MakeRealEstateId(zone_id, door_id);

	Writer w;
	w.CStr(guid);          // 16 characters plus NUL
	w.U8(0);               // pad the GUID field to the fixed 18 bytes the layout uses
	w.U32(0); w.U32(0); w.U32(0);   // 20..31: not read by the retire path
	w.U32(door_id);        // 32: estate id
	w.U32(item_id);        // 36: item id

	const auto &buf = w.Buffer();
	auto outapp = new EQApplicationPacket(OP_RealEstateWorldRemove, static_cast<uint32>(buf.size()));
	std::memcpy(outapp->pBuffer, buf.data(), buf.size());
	c->QueuePacket(outapp);
	safe_delete(outapp);

	LogInfo("[Housing] sent world remove to [{}]: estate [{}] item [{}]", c->GetName(), door_id, item_id);
	return true;
}


// A lot marker is a door. Clicking it is the client's only way to ask about a plot, and the
// window that comes up is filled from the 0x2691 inspection record (the client never requests
// a 0x796c reply by itself -- it cannot even dispatch one). So the click is the request: answer
// it with show=true and the plot's details.
void Client::HousingDoorClick(uint32_t door_id)
{
	if (!zone || std::string(zone->GetShortName()) != "neighborhood") {
		return;
	}

	auto plot = database.QueryDatabase(fmt::format(
		"SELECT 1 FROM nms_plot p JOIN nms_neighborhood n ON n.id = p.neighborhood_id "
		"WHERE n.zone = '{}' AND p.door_id = {} LIMIT 1",
		Strings::Escape(zone->GetShortName()), door_id
	));

	if (!plot.Success() || !plot.RowCount()) {
		return;
	}

	LogInfo("[Housing] lot marker [{}] clicked by [{}]", door_id, GetName());

	SendRealEstateInspection(this, door_id, true);
}

// 0x792c C2S "Move Out": a 188-byte envelope whose only recovered field is the estate id at 0.
// Relinquishes the plot, its building and its interior. The result goes back on 0x66bf as a
// single u32 (0 = applied), and the client gets a fresh identity so the windows redraw.
void Client::Handle_OP_RealEstateSale(const EQApplicationPacket *app)
{
	LogHousingOpcode(this, app, "OP_RealEstateSale");

	if (!zone || app->size < 4) {
		return;
	}

	const uint32_t estate_id = ReadU32(app, 0);

	uint32_t result = 1;

	auto plot = database.QueryDatabase(fmt::format(
		"SELECT p.id, p.plot_type, p.owner_char_id, p.owner_guild_id, p.house_id, p.house_item_id "
		"FROM nms_plot p JOIN nms_neighborhood n ON n.id = p.neighborhood_id "
		"WHERE n.zone = '{}' AND p.door_id = {} LIMIT 1",
		Strings::Escape(zone->GetShortName()), estate_id
	));

	if (plot.Success() && plot.RowCount()) {
		auto row = plot.begin();

		const uint32_t plot_row    = Strings::ToUnsignedInt(row[0] ? row[0] : "0");
		const uint32_t plot_type   = Strings::ToUnsignedInt(row[1] ? row[1] : "0");
		const uint32_t owner_char  = Strings::ToUnsignedInt(row[2] ? row[2] : "0");
		const uint32_t owner_guild = Strings::ToUnsignedInt(row[3] ? row[3] : "0");
		const uint32_t house_id    = Strings::ToUnsignedInt(row[4] ? row[4] : "0");
		const uint32_t house_item  = Strings::ToUnsignedInt(row[5] ? row[5] : "0");

		const bool mine = plot_type == 1
			? (owner_guild != 0 && owner_guild == GuildID())
			: (owner_char != 0 && owner_char == CharacterID());

		if (mine) {
			database.QueryDatabase(fmt::format(
				"UPDATE nms_plot SET owner_char_id = 0, owner_guild_id = 0, purchased_at = NULL, "
				"upkeep_paid_until = NULL, house_id = 0, house_zone = '', house_item_id = 0, "
				"house_x = NULL, house_y = NULL, house_z = NULL, house_heading = NULL "
				"WHERE id = {}", plot_row
			));

			if (house_id) {
				database.QueryDatabase(fmt::format("DELETE FROM house WHERE id = {}", house_id));
			}

			if (house_item) {
				SendRealEstateWorldRemove(this, estate_id, house_item, zone->GetZoneID());
			}

			result = 0;

			Message(
				Chat::White,
				fmt::format("[housing] you have moved out of [{}].", PlotStreetAddress(estate_id)).c_str()
			);

			LogInfo(
				"[Housing] move out by [{}]: estate [{}] released, house [{}] retired",
				GetName(), estate_id, house_id
			);
		}
	}

	Writer w;
	w.U32(result);

	const auto &buf = w.Buffer();
	auto outapp = new EQApplicationPacket(OP_RealEstateSaleResult, static_cast<uint32>(buf.size()));
	std::memcpy(outapp->pBuffer, buf.data(), buf.size());
	QueuePacket(outapp);
	safe_delete(outapp);

	if (result == 0) {
		SendRealEstateIdentity();
	}
}

// 0x507f C2S ownership transfer: 188 bytes, estate id at 0, recipient name in a fixed 64-byte
// field at 108. Result on 0x68ba (u32 at 0, 0 = applied).
void Client::Handle_OP_RealEstateTransfer(const EQApplicationPacket *app)
{
	LogHousingOpcode(this, app, "OP_RealEstateTransfer");

	if (!zone || app->size < 172) {
		return;
	}

	const uint32_t estate_id = ReadU32(app, 0);

	char target[65] = {};
	std::memcpy(target, app->pBuffer + 108, 64);

	if (!target[0]) {
		return;
	}

	uint32_t result = 1;

	auto plot = database.QueryDatabase(fmt::format(
		"SELECT p.id, p.plot_type, p.owner_char_id, p.owner_guild_id "
		"FROM nms_plot p JOIN nms_neighborhood n ON n.id = p.neighborhood_id "
		"WHERE n.zone = '{}' AND p.door_id = {} LIMIT 1",
		Strings::Escape(zone->GetShortName()), estate_id
	));

	auto recipient = database.QueryDatabase(fmt::format(
		"SELECT id FROM character_data WHERE name = '{}' LIMIT 1",
		Strings::Escape(target)
	));

	if (plot.Success() && plot.RowCount() && recipient.Success() && recipient.RowCount()) {
		auto row = plot.begin();

		const uint32_t plot_row    = Strings::ToUnsignedInt(row[0] ? row[0] : "0");
		const uint32_t plot_type   = Strings::ToUnsignedInt(row[1] ? row[1] : "0");
		const uint32_t owner_char  = Strings::ToUnsignedInt(row[2] ? row[2] : "0");
		const uint32_t owner_guild = Strings::ToUnsignedInt(row[3] ? row[3] : "0");
		const uint32_t target_id   = Strings::ToUnsignedInt(recipient.begin()[0] ? recipient.begin()[0] : "0");

		const bool mine = plot_type == 1
			? (owner_guild != 0 && owner_guild == GuildID())
			: (owner_char != 0 && owner_char == CharacterID());

		if (mine && target_id && target_id != owner_char) {
			database.QueryDatabase(fmt::format(
				"UPDATE nms_plot SET owner_char_id = {}, owner_guild_id = 0 WHERE id = {}",
				target_id, plot_row
			));

			result = 0;

			Message(
				Chat::White,
				fmt::format("[housing] [{}] is now owned by [{}].", PlotStreetAddress(estate_id), target).c_str()
			);

			LogInfo(
				"[Housing] transfer by [{}]: estate [{}] -> [{}] (char {})",
				GetName(), estate_id, target, target_id
			);
		}
	}

	Writer w;
	w.U32(result);

	const auto &buf = w.Buffer();
	auto outapp = new EQApplicationPacket(OP_RealEstateTransferResult, static_cast<uint32>(buf.size()));
	std::memcpy(outapp->pBuffer, buf.data(), buf.size());
	QueuePacket(outapp);
	safe_delete(outapp);

	if (result == 0) {
		SendRealEstateIdentity();
	}
}

// 0x711a C2S commit: 96 bytes -- estate 32, item 36, heading/pitch/roll/scale 44..56,
// position Y/X/Z 60..68, actor-local extents 72..80, center 84..92. Neighborhood commits
// persist the building pose and consume nothing; interior commits place one furniture row
// and consume the item.
void Client::Handle_OP_RealEstatePlacementCommit(const EQApplicationPacket *app)
{
	LogHousingOpcode(this, app, "OP_RealEstatePlacementCommit");

	if (!zone || app->size < 96) {
		return;
	}

	// House-interior handles (kHouseEstateBase + door) key the same rows as the door id.
	const uint32_t estate_id = NormalizeEstateDoor(ReadU32(app, 32));
	const uint32_t item_id   = ReadU32(app, 36);

	const float heading = ReadFloatAt(app, 44);
	const float pitch   = ReadFloatAt(app, 48);
	const float roll    = ReadFloatAt(app, 52);
	const float scale   = ReadFloatAt(app, 56);
	const float pos_y   = ReadFloatAt(app, 60);
	const float pos_x   = ReadFloatAt(app, 64);
	const float pos_z   = ReadFloatAt(app, 68);

	if (std::string(zone->GetShortName()) == "neighborhood") {
		// 1. A furniture row move: the commit echoes the row identity the item list, menu and
		// preview gave the client (row id at 36, lot at 32). Fail-closed on ownership via the
		// plot join; a row id only matches when the client is re-placing a listed item.
		auto moved = database.QueryDatabase(fmt::format(
			"UPDATE nms_house_item h "
			"JOIN nms_plot p ON p.door_id = h.door_id "
			"JOIN nms_neighborhood nb ON nb.id = p.neighborhood_id "
			"SET h.pos_x = {}, h.pos_y = {}, h.pos_z = {}, h.heading = {}, h.pitch = {}, "
			"    h.roll = {}, h.scale = {}, h.stowed = 0 "
			"WHERE nb.zone = '{}' AND h.door_id = {} AND h.id = {} "
			"  AND (p.owner_char_id = {} OR (p.owner_guild_id > 0 AND p.owner_guild_id = {}))",
			pos_x, pos_y, pos_z, heading, pitch, roll, scale > 0.0f ? scale : 1.0f,
			Strings::Escape(zone->GetShortName()), estate_id, item_id,
			CharacterID(), GuildID()
		));

		if (moved.Success() && moved.RowCount() && moved.RowsAffected()) {
			auto model_row = database.QueryDatabase(fmt::format(
				"SELECT COALESCE(it.idfile, ''), COALESCE(it.Name, '') FROM nms_house_item h "
				"JOIN items it ON it.id = h.item_id WHERE h.id = {} LIMIT 1",
				item_id
			));

			if (model_row.Success() && model_row.RowCount()) {
				auto mr = model_row.begin();
				const std::string model = (mr[0] && *mr[0]) ? mr[0] : (mr[1] ? mr[1] : "");

				if (!model.empty()) {
					SendRealEstateFurnitureWorldItem(
						this, estate_id, item_id, 0, model, zone->GetZoneID(),
						pos_x, pos_y, pos_z, heading, scale > 0.0f ? scale : 1.0f
					);
				}
			}

			SendRealEstateItemList(this, estate_id);
			SendRealEstateOperationResult(this, 0);
			LogInfo(
				"[Housing] furniture move commit from [{}]: lot [{}], row [{}], pose ({:.1f}, {:.1f}, {:.1f})",
				GetName(), estate_id, item_id, pos_x, pos_y, pos_z
			);
			return;
		}

		// 2a. A HOUSE placement: the commit claims the lot's building slot. This is the
		// non-GM house placement the Items window drives -- the same identity the building
		// preview sent (template id at 36, lot at 32).
		if (IsHousePlacementItem(item_id) && CountItem(item_id)) {
			auto claim = database.QueryDatabase(fmt::format(
				"UPDATE nms_plot p JOIN nms_neighborhood n ON n.id = p.neighborhood_id "
				"SET p.house_item_id = {}, p.house_x = {}, p.house_y = {}, p.house_z = {}, "
				"    p.house_heading = {} "
				"WHERE n.zone = '{}' AND p.door_id = {} "
				"  AND (p.owner_char_id = {} OR (p.owner_guild_id > 0 AND p.owner_guild_id = {})) "
				"  AND p.house_item_id = 0",
				item_id, pos_x, pos_y, pos_z, heading,
				Strings::Escape(zone->GetShortName()), estate_id, CharacterID(), GuildID()
			));

			if (claim.Success() && claim.RowsAffected()) {
				// The building decides the interior: create (or re-point) the house from the
				// item's template before anything -- key, door, GM enter -- looks it up.
				AttachHouseToPlot(this, zone->GetShortName(), estate_id, item_id);

				auto model_row = database.QueryDatabase(fmt::format(
					"SELECT COALESCE(idfile, ''), COALESCE(Name, '') FROM items WHERE id = {} LIMIT 1",
					item_id
				));

				if (model_row.Success() && model_row.RowCount()) {
					auto m = model_row.begin();
					const std::string model = (m[0] && *m[0]) ? m[0] : (m[1] ? m[1] : "");

					if (!model.empty()) {
						RemoveItem(item_id, 1);
						SendRealEstateExteriors(this);
						SendRealEstateItemList(this, estate_id);
						SendRealEstateOperationResult(this, 0);
						Message(
							Chat::White,
							fmt::format("[housing] you have placed your house on lot [{}].", estate_id).c_str()
						);
						LogInfo(
							"[Housing] house placement commit from [{}]: lot [{}], item [{}], "
							"pose ({:.1f}, {:.1f}, {:.1f}) heading {:.1f}",
							GetName(), estate_id, item_id, pos_x, pos_y, pos_z, heading
						);
						return;
					}
				}
			}

			LogInfo(
				"[Housing] house placement commit from [{}]: lot [{}] item [{}] did not apply "
				"(not owned, no model, or the lot already has a house)",
				GetName(), estate_id, item_id
			);
			SendRealEstateOperationResult(this, 1);
			return;
		}

		// 2b. A new furniture placement: the commit echoes the preview's identity, and our
		// new-placement preview put the TEMPLATE item id at 36. Consumed only once the row exists.
		if (CountItem(item_id)) {
			auto owner = database.QueryDatabase(fmt::format(
				"SELECT 1 FROM nms_plot p JOIN nms_neighborhood n ON n.id = p.neighborhood_id "
				"WHERE n.zone = '{}' AND p.door_id = {} "
				"  AND (p.owner_char_id = {} OR (p.owner_guild_id > 0 AND p.owner_guild_id = {})) "
				"LIMIT 1",
				Strings::Escape(zone->GetShortName()), estate_id, CharacterID(), GuildID()
			));

			if (owner.Success() && owner.RowCount()) {
				auto model_row = database.QueryDatabase(fmt::format(
					"SELECT COALESCE(idfile, ''), COALESCE(Name, '') FROM items WHERE id = {} LIMIT 1",
					item_id
				));

				if (model_row.Success() && model_row.RowCount()) {
					auto m = model_row.begin();
					const std::string model = (m[0] && *m[0]) ? m[0] : (m[1] ? m[1] : "");

					if (!model.empty()) {
						auto insert = database.QueryDatabase(fmt::format(
							"INSERT INTO nms_house_item "
							"(door_id, item_id, charges, pos_x, pos_y, pos_z, heading, pitch, roll, scale, placement_type, placed_by, placed_at) "
							"VALUES ({}, {}, 1, {}, {}, {}, {}, {}, {}, {}, 0, {}, NOW())",
							estate_id, item_id, pos_x, pos_y, pos_z, heading, pitch, roll,
							scale > 0.0f ? scale : 1.0f, CharacterID()
						));

						if (insert.Success()) {
							const uint32_t row_id = static_cast<uint32_t>(insert.LastInsertedID());

							RemoveItem(item_id, 1);
							SendRealEstateFurnitureWorldItem(
								this, estate_id, row_id, item_id, model, zone->GetZoneID(),
								pos_x, pos_y, pos_z, heading, scale > 0.0f ? scale : 1.0f
							);
							SendRealEstateItemList(this, estate_id);
							SendRealEstateOperationResult(this, 0);

							LogInfo(
								"[Housing] yard furniture commit from [{}]: lot [{}], row [{}], item [{}], "
								"pose ({:.1f}, {:.1f}, {:.1f}) heading {:.1f}",
								GetName(), estate_id, row_id, item_id, pos_x, pos_y, pos_z, heading
							);
							return;
						}
					}
				}
			}
		}

		// 3. The building pose: the lot's own placed building, keyed by its template item id.
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
			SendRealEstateItemList(this, estate_id);
			SendRealEstateOperationResult(this, 0);
		}
		return;
	}

	// House interior: furniture commit. The estate at 32 is the interior's lot door id and
	// the item at 36 the furniture being placed. Dormant until the v2 item-metadata tail
	// (same as Begin); #housing item place is the v1 path.
	uint32_t door_id = 0, nb_id = 0;

	if (!ResolveOwnedInterior(this, door_id, nb_id)) {
		LogInfo("[Housing] furniture commit from [{}]: zone [{}] is not their interior",
		        GetName(), zone->GetShortName());
		return;
	}
	(void) nb_id;

	if (estate_id != door_id) {
		LogInfo("[Housing] furniture commit from [{}]: body estate [{}] vs interior lot [{}]",
		        GetName(), estate_id, door_id);
	}

	// The interior is the character's, but the lot behind it may have changed hands since
	// the identity went out: the owner gate here is fail-closed.
	if (!FurniturePlotIsMine(this, door_id)) {
		LogInfo("[Housing] furniture commit from [{}]: lot [{}] is not theirs", GetName(), door_id);
		return;
	}

	// A furniture row move inside the interior: same identity rule as the yard -- the commit
	// echoes the row id the item list/menu/preview gave the client.
	auto moved = database.QueryDatabase(fmt::format(
		"UPDATE nms_house_item h "
		"JOIN nms_plot p ON p.door_id = h.door_id "
		"JOIN nms_neighborhood nb ON nb.id = p.neighborhood_id "
		"SET h.pos_x = {}, h.pos_y = {}, h.pos_z = {}, h.heading = {}, h.pitch = {}, "
		"    h.roll = {}, h.scale = {} "
		"WHERE nb.zone = '{}' AND h.door_id = {} AND h.id = {} "
		"  AND (p.owner_char_id = {} OR (p.owner_guild_id > 0 AND p.owner_guild_id = {}))",
		pos_x, pos_y, pos_z, heading, pitch, roll, scale > 0.0f ? scale : 1.0f,
		Strings::Escape(zone->GetShortName()), door_id, item_id,
		CharacterID(), GuildID()
	));

	if (moved.Success() && moved.RowCount() && moved.RowsAffected()) {
		auto model_row = database.QueryDatabase(fmt::format(
			"SELECT COALESCE(it.idfile, ''), COALESCE(it.Name, '') FROM nms_house_item h "
			"JOIN items it ON it.id = h.item_id WHERE h.id = {} LIMIT 1",
			item_id
		));

		if (model_row.Success() && model_row.RowCount()) {
			auto mr = model_row.begin();
			const std::string model = (mr[0] && *mr[0]) ? mr[0] : (mr[1] ? mr[1] : "");

			if (!model.empty()) {
				SendRealEstateFurnitureWorldItem(
					this, door_id, item_id, 0, model, zone->GetZoneID(),
					pos_x, pos_y, pos_z, heading, scale > 0.0f ? scale : 1.0f
				);
			}
		}

		SendRealEstateItemList(this, estate_id);
		SendRealEstateOperationResult(this, 0);
		LogInfo(
			"[Housing] furniture move commit from [{}]: interior lot [{}], row [{}], pose ({:.1f}, {:.1f}, {:.1f})",
			GetName(), door_id, item_id, pos_x, pos_y, pos_z
		);
		return;
	}

	// The model has to exist before anything is consumed: a consumed item with nothing
	// placed is the outcome the building path learned to refuse.
	auto model_row = database.QueryDatabase(fmt::format(
		"SELECT COALESCE(idfile, ''), COALESCE(Name, '') FROM items WHERE id = {} LIMIT 1", item_id
	));

	if (!model_row.Success() || !model_row.RowCount()) {
		LogInfo("[Housing] furniture commit from [{}]: item [{}] does not exist", GetName(), item_id);
		return;
	}

	auto m = model_row.begin();
	const std::string model = (m[0] && *m[0]) ? m[0] : (m[1] ? m[1] : "");

	if (model.empty()) {
		LogInfo("[Housing] furniture commit from [{}]: item [{}] has no model", GetName(), item_id);
		return;
	}

	if (!CountItem(item_id)) {
		LogInfo("[Housing] furniture commit from [{}]: item [{}] not carried", GetName(), item_id);
		return;
	}

	auto insert = database.QueryDatabase(fmt::format(
		"INSERT INTO nms_house_item "
		"(door_id, item_id, charges, pos_x, pos_y, pos_z, heading, pitch, roll, scale, placement_type, placed_by, placed_at) "
		"VALUES ({}, {}, 1, {}, {}, {}, {}, {}, {}, {}, 0, {}, NOW())",
		door_id, item_id, pos_x, pos_y, pos_z, heading, pitch, roll,
		scale > 0.0f ? scale : 1.0f, CharacterID()
	));

	if (!insert.Success()) {
		LogInfo("[Housing] furniture commit from [{}]: insert failed for item [{}]", GetName(), item_id);
		return;
	}

	const uint32_t row_id = static_cast<uint32_t>(insert.LastInsertedID());

	// Consume only once the row exists.
	RemoveItem(item_id, 1);

		SendRealEstateFurnitureWorldItem(
			this, door_id, row_id, item_id, model, zone->GetZoneID(), pos_x, pos_y, pos_z, heading,
			scale > 0.0f ? scale : 1.0f
		);

		SendRealEstateItemList(this, estate_id);
		SendRealEstateOperationResult(this, 0);

		Message(
			Chat::White,
			fmt::format("[housing] placed item [{}] in your house (row {}).", item_id, row_id).c_str()
		);

	LogInfo(
		"[Housing] furniture commit from [{}]: lot [{}], row [{}], item [{}], "
		"pose ({:.1f}, {:.1f}, {:.1f}) heading {:.1f} pitch {:.1f} roll {:.1f} scale {:.2f}",
		GetName(), door_id, row_id, item_id, pos_x, pos_y, pos_z, heading, pitch, roll,
		scale > 0.0f ? scale : 1.0f
	);
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

	// The client asks per estate (0x050c body = estate id) when the Items window needs data;
	// the reply is the 0x1cef list. The sender authorizes and answers empty for estates the
	// viewer does not own.
	SendRealEstateItemList(this, estate_id);
}

// 0x3424 C2S item operation: Source(44 bytes) plus a destination action word at 44 -- 2 =
// Closet (house storage), 3 = Shed (yard storage), 6 = Crate. This is the client's DEPOSIT:
// an inventory item moves into the estate's storage, the item list shows it unplaced, and the
// item menu's Move places it (Begin/Commit). The crate container has no server model here, so
// action 6 is refused with the native no-container result.
void Client::Handle_OP_RealEstateItemOperation(const EQApplicationPacket *app)
{
	LogHousingOpcode(this, app, "OP_RealEstateItemOperation");

	if (!zone || app->size != 48) {
		return;
	}

	const uint32_t action = ReadU32(app, 44);

	// Two source profiles share this 48-byte body. The inventory profile (deposit) carries
	// FFFFFFFF estate/item sentinels; the estate profile names a stored row with the same
	// estate/row identity the item list handed the client, which is a container withdrawal.
	const uint32_t source_estate = ReadU32(app, 32);
	const uint32_t source_item   = ReadU32(app, 36);

	if (source_estate != UINT32_MAX && source_item != UINT32_MAX) {
		const uint32_t source_door = NormalizeEstateDoor(source_estate);

		if (!FurniturePlotIsMine(this, source_door)) {
			LogInfo(
				"[Housing] withdraw from [{}]: row [{}] lot [{}] is not theirs",
				GetName(), source_item, source_door
			);
			SendRealEstateOperationResult(this, 9);
			return;
		}

		auto stored = database.QueryDatabase(fmt::format(
			"SELECT container FROM nms_house_item WHERE id = {} AND door_id = {} AND container >= 0 LIMIT 1",
			source_item, source_door
		));

		if (!stored.Success() || !stored.RowCount()) {
			LogInfo(
				"[Housing] withdraw from [{}]: row [{}] is not stored on lot [{}]",
				GetName(), source_item, source_door
			);
			SendRealEstateOperationResult(this, 9);
			return;
		}

		const int container = Strings::ToInt(stored.begin()[0] ? stored.begin()[0] : "0");

		if (!ReturnFurnitureRow(this, source_item)) {
			SendRealEstateOperationResult(this, 1);
			return;
		}

		SendRealEstateItemList(this, source_door);
		SendRealEstateOperationResult(this, 0);

		LogInfo(
			"[Housing] withdraw from [{}]: row [{}] taken out of [{}] on lot [{}]",
			GetName(), source_item, ContainerName(container), source_door
		);
		return;
	}

	uint32_t slot = 0, sub = 0;
	if (!DecodeInventorySource(app, slot, sub)) {
		LogInfo("[Housing] item operation from [{}]: source is not a personal inventory item", GetName());
		SendRealEstateOperationResult(this, 9);
		return;
	}

	if (action != 2 && action != 3 && action != 6) {
		LogInfo(
			"[Housing] item operation from [{}]: action [{}] has no container model",
			GetName(), action
		);
		SendRealEstateOperationResult(this, 9);
		return;
	}

	auto *top = GetInv().GetItem(static_cast<int16_t>(slot));
	auto *inst = top;
	int   bag_index = -1;

	if (sub) {
		// The player deposited from INSIDE the bag in the main slot. Taking the bag itself was
		// the live bug (a house deed deposit stored the bag that held it).
		if (!top || !top->IsClassBag()) {
			LogInfo(
				"[Housing] item operation from [{}]: slot [{}] sub [{}] is not a bag",
				GetName(), slot, sub
			);
			SendRealEstateOperationResult(this, 9);
			return;
		}

		for (int candidate : { static_cast<int>(sub), static_cast<int>(sub) - 1 }) {
			if (candidate < 0 || candidate > 255) {
				continue;
			}
			if (top->GetItem(static_cast<uint8_t>(candidate))) {
				bag_index = candidate;
				break;
			}
		}

		if (bag_index < 0) {
			LogInfo(
				"[Housing] item operation from [{}]: bag [{}] has no item at index [{}]",
				GetName(), slot, sub
			);
			SendRealEstateOperationResult(this, 9);
			return;
		}

		inst = top->GetItem(static_cast<uint8_t>(bag_index));
	}

	if (!inst || !inst->GetUnscaledItem()) {
		LogInfo("[Housing] item operation from [{}]: slot [{}] is empty", GetName(), slot);
		SendRealEstateOperationResult(this, 9);
		return;
	}

	const auto  *data    = inst->GetUnscaledItem();
	const uint32_t item_id = data->ID;

	// No placeability gate on the deposit: retail estate storage holds any carried item
	// (the window even filters NonRealEstate items). Placement stays policy-gated instead.

	const std::string model = (data->IDFile && *data->IDFile)
		? std::string(data->IDFile)
		: (data->Name ? std::string(data->Name) : std::string());

	// A deposit the window could not later render is worse than a refusal: no model, no row.
	if (model.empty()) {
		LogInfo("[Housing] item operation from [{}]: item [{}] has no model", GetName(), item_id);
		SendRealEstateOperationResult(this, 9);
		return;
	}

	uint32_t door_id = 0;

	// Yard storage is the shed, house storage the closet (retail). One row table backs both, so
	// the destination word cannot pick a table -- but it must not dead-end the menu either.
	// Observed live: the client sends `closet` (2) while standing on the lot. Accept either
	// word from the player's own property and let the standing context name the container.
	uint32_t nb_id = 0;
	const bool in_interior = ResolveOwnedInterior(this, door_id, nb_id);

	if (!in_interior) {
		const auto plot = FindNearestPlot(zone->GetShortName(), GetX(), GetY());

		if (!plot.found ||
		    !(plot.owner_char_id == CharacterID() ||
		      (plot.owner_guild_id && plot.owner_guild_id == GuildID()))) {
			LogInfo("[Housing] item operation from [{}]: no owned lot underfoot", GetName());
			SendRealEstateOperationResult(this, 23);
			return;
		}

		door_id = plot.door_id;
	}

	// Yard storage is the shed, house storage the closet, and 6 is the moving crate. One row
	// table backs all three, so the destination word picks the container; the standing context
	// only breaks the 2/3 tie the client gets wrong from the yard (observed live).
	const int container = (action == 6)
		? kContainerCrate
		: (in_interior ? kContainerCloset : kContainerShed);

	// Per-house capacity: the building's definition carries the reviewed totals. Zero means
	// "not established", never "allow nothing".
	const HouseCapacity capacity = LoadHouseCapacity(PlotHouseDefinition(door_id));
	const uint32_t      total    = PlotItemCount(door_id, -2);

	if (capacity.max_items && total >= capacity.max_items) {
		LogInfo(
			"[Housing] deposit from [{}] refused: lot [{}] holds [{}]/[{}] items",
			GetName(), door_id, total, capacity.max_items
		);
		Message(Chat::White, "[housing] your house is full.");
		SendRealEstateOperationResult(this, 9);
		return;
	}

	if (container == kContainerCloset && capacity.max_vault &&
	    PlotItemCount(door_id, kContainerCloset) >= capacity.max_vault) {
		LogInfo(
			"[Housing] deposit from [{}] refused: closet holds [{}]/[{}]",
			GetName(), PlotItemCount(door_id, kContainerCloset), capacity.max_vault
		);
		Message(Chat::White, "[housing] your closet is full.");
		SendRealEstateOperationResult(this, 9);
		return;
	}

	auto insert = database.QueryDatabase(fmt::format(
		"INSERT INTO nms_house_item "
		"(door_id, item_id, charges, pos_x, pos_y, pos_z, heading, pitch, roll, scale, placement_type, stowed, container, placed_by, placed_at) "
		"VALUES ({}, {}, 1, 0, 0, 0, 0, 0, 0, 1, 0, 1, {}, {}, NOW())",
		door_id, item_id, container, CharacterID()
	));

	if (!insert.Success()) {
		LogInfo("[Housing] item operation from [{}]: insert failed for item [{}]", GetName(), item_id);
		SendRealEstateOperationResult(this, 1);
		return;
	}

	// Custody moved to the estate: consume only once the row exists. A bag-sourced deposit
	// takes the item out of the bag, never the bag itself.
	if (bag_index >= 0) {
		top->DeleteItem(static_cast<uint8_t>(bag_index));
	}
	else {
		RemoveItem(item_id, 1);
	}

	// Refresh the window's list and close the operation.
	SendRealEstateItemList(this, door_id);
	SendRealEstateOperationResult(this, 0);

	const std::string stored_name = (data->Name && *data->Name) ? std::string(data->Name) : std::to_string(item_id);

	Message(
		Chat::White,
		fmt::format("[housing] stored {} into the {}.", stored_name, ContainerName(container)).c_str()
	);

	LogInfo(
		"[Housing] item operation from [{}]: item [{}] '{}' (slot {}{}) stored into [{}] of lot [{}] as row [{}]",
		GetName(), item_id, stored_name, slot,
		bag_index >= 0 ? fmt::format(" bag {}", bag_index) : std::string(), ContainerName(container), door_id,
		static_cast<uint32_t>(insert.LastInsertedID())
	);
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
		//
		// No 0x2b35 reply here. On receipt the client runs the same toggle the menu click used
		// (sub_4E4E60's "plot" branch: Show(wnd[406] == 0)), so *any* reply closes the window the
		// click just opened -- traced live twice, mode 1 and mode 0, both hiding at caller
		// 0x4E4F3E one frame after the open. The menu click owns the open; the list is what the
		// window actually needs. `#housing plotsearch [mode]` still sends the opener explicitly
		// for deliberate GM use.
		SendPlotList(this, zone->GetShortName(), search_type);
	}
	else {
		SendNeighborhoodList(this, zone->GetShortName());
	}
}

// 0x1da9 C2S: the retail /leaverealestate command, and the house-exit action behind the real
// estate window. It writes only its opcode -- the four body bytes are stale shared-buffer
// contents and select nothing -- so the exit is resolved from server state (the character's
// house row and the zone they are standing in).
void Client::Handle_OP_RealEstateExit(const EQApplicationPacket *app)
{
	LogHousingOpcode(this, app, "OP_RealEstateExit");
	HousingLeave(this, false);
}

// 0x21ba C2S: the "Swap Houses" choice the 0x21ec menu offers (action 17). Body: FFFFFFFF@0,
// zero@4, current estate/item @8/12, replacement estate/item @16/20. The lot's building is
// exchanged for a carried house item and the interior is re-derived from the new item.
void Client::Handle_OP_RealEstateHouseSwap(const EQApplicationPacket *app)
{
	LogHousingOpcode(this, app, "OP_RealEstateHouseSwap");

	if (!zone || app->size < 24) {
		return;
	}

	const uint32_t estate_id   = ReadU32(app, 8);
	const uint32_t replacement = ReadU32(app, 20);

	if (!estate_id || estate_id == UINT32_MAX || !replacement || replacement == UINT32_MAX) {
		return;
	}

	auto plot = database.QueryDatabase(fmt::format(
		"SELECT p.house_item_id, p.owner_char_id, p.owner_guild_id FROM nms_plot p "
		"JOIN nms_neighborhood n ON n.id = p.neighborhood_id "
		"WHERE n.zone = '{}' AND p.door_id = {} LIMIT 1",
		Strings::Escape(zone->GetShortName()), estate_id
	));

	if (!plot.Success() || !plot.RowCount()) {
		return;
	}

	auto row = plot.begin();

	const uint32_t current_item = Strings::ToUnsignedInt(row[0] ? row[0] : "0");
	const uint32_t owner_char   = Strings::ToUnsignedInt(row[1] ? row[1] : "0");
	const uint32_t owner_guild  = Strings::ToUnsignedInt(row[2] ? row[2] : "0");

	const bool owner = owner_char == CharacterID() || (owner_guild && owner_guild == GuildID());

	if (!owner || !current_item || replacement == current_item || !CountItem(replacement) ||
	    !IsHousePlacementItem(replacement)) {
		LogInfo(
			"[Housing] house swap from [{}]: lot [{}] current [{}] replacement [{}] refused",
			GetName(), estate_id, current_item, replacement
		);
		SendRealEstateOperationResult(this, 9);
		return;
	}

	auto upd = database.QueryDatabase(fmt::format(
		"UPDATE nms_plot SET house_item_id = {} WHERE door_id = {}", replacement, estate_id
	));

	if (!upd.Success() || !upd.RowsAffected()) {
		SendRealEstateOperationResult(this, 1);
		return;
	}

	// The new building decides the interior; the old one goes back into the pack.
	AttachHouseToPlot(this, zone->GetShortName(), estate_id, replacement);

	RemoveItem(replacement, 1);

	if (const EQ::ItemData *old_item = database.GetItem(current_item)) {
		if (EQ::ItemInstance *inst = database.CreateItem(old_item, 1)) {
			if (!AutoPutLootInInventory(*inst, true, true)) {
				PutLootInInventory(EQ::invslot::slotCursor, *inst);
			}
		}
	}

	SendRealEstateExteriors(this);
	SendRealEstateOperationResult(this, 0);

	Message(
		Chat::White,
		fmt::format("[housing] you swapped houses on lot [{}].", estate_id).c_str()
	);

	LogInfo(
		"[Housing] house swap from [{}]: lot [{}] [{}] -> [{}]",
		GetName(), estate_id, current_item, replacement
	);
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

	auto query_instance = [&]() {
		return database.QueryDatabase(fmt::format(
			"SELECT h.instance_id FROM nms_plot p "
			"JOIN nms_neighborhood n ON n.id = p.neighborhood_id "
			"JOIN house h ON h.id = p.house_id "
			"WHERE n.zone = '{}' AND p.door_id = {} "
			"  AND (p.owner_char_id = {} OR (p.owner_guild_id > 0 AND p.owner_guild_id = {})) "
			"LIMIT 1",
			Strings::Escape(zone->GetShortName()), estate_id, CharacterID(), GuildID()
		));
	};

	auto instance_of = [&]() -> uint32_t {
		auto house = query_instance();
		if (!house.Success() || !house.RowCount() || !house.begin()[0]) {
			return 0;
		}
		return Strings::ToUnsignedInt(house.begin()[0]);
	};

	auto lot = database.QueryDatabase(fmt::format(
		"SELECT p.house_item_id FROM nms_plot p JOIN nms_neighborhood n ON n.id = p.neighborhood_id "
		"WHERE n.zone = '{}' AND p.door_id = {} "
		"  AND (p.owner_char_id = {} OR (p.owner_guild_id > 0 AND p.owner_guild_id = {})) "
		"LIMIT 1",
		Strings::Escape(zone->GetShortName()), estate_id, CharacterID(), GuildID()
	));

	const uint32_t house_item = (lot.Success() && lot.RowCount() && lot.begin()[0])
		? Strings::ToUnsignedInt(lot.begin()[0]) : 0;

	// The building on the lot decides the interior. Reconcile on entry as well: the house row
	// may predate the template table, or the building may have been placed after it existed.
	if (house_item) {
		AttachHouseToPlot(this, zone->GetShortName(), estate_id, house_item);
	}

	const uint32_t instance_id = instance_of();

	if (!instance_id) {
		LogInfo("[Housing] go: estate [{}] has no interior linked for [{}]", estate_id, GetName());
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
	// The source location discriminates the two profiles: an all-FFFFFFFF location carries an
	// ESTATE item (estate at 32, row id at 36 -- the identity the item list, menu and world
	// actor use), while kind 0 with a personal slot (23..33) carries an INVENTORY item whose
	// estate/item fields are 0xFFFFFFFF sentinels. The two floats are SCREEN coordinates, not
	// world units; claiming is only the explicit #housing claim path.
	if (!zone || app->size < 60) {
		return;
	}

	const uint32_t loc0 = ReadU32(app, 20);
	const uint32_t loc1 = ReadU32(app, 24);
	const uint32_t loc2 = ReadU32(app, 28);
	const bool stored_source = (loc0 == UINT32_MAX && loc1 == UINT32_MAX && loc2 == UINT32_MAX);

	// The inventory profile is decoded by the shared helper (the live client packs the slot
	// into location[0], not location[1]); a failed decode leaves slot 0, which both inventory
	// branches reject as out of range.
	uint32_t slot = 0, sub = 0;
	if (!stored_source) {
		DecodeInventorySource(app, slot, sub);
	}

	// House-interior handles (kHouseEstateBase + door) key the same rows as the door id.
	const uint32_t estate_id = NormalizeEstateDoor(ReadU32(app, 32));
	const uint32_t item_id   = ReadU32(app, 36);

	// The shared model lookup: idfile first, name as the fallback the building flow uses.
	const auto model_for = [&](uint32_t id, std::string &out) -> bool {
		auto model_row = database.QueryDatabase(fmt::format(
			"SELECT COALESCE(idfile, ''), COALESCE(Name, '') FROM items WHERE id = {} LIMIT 1", id
		));

		if (!model_row.Success() || !model_row.RowCount()) {
			return false;
		}

		auto m = model_row.begin();
		out = (m[0] && *m[0]) ? m[0] : (m[1] ? m[1] : "");
		return !out.empty();
	};

	if (std::string(zone->GetShortName()) == "neighborhood") {
		// Inventory source: a new placement. The ghost spawns where the player stands and the
		// target lot is the one underfoot; ownership is fail-closed.
		if (!stored_source) {
			if (slot < 23 || slot > 33) {
				LogInfo(
					"[Housing] placement begin from [{}]: inventory slot [{}] is out of range",
					GetName(), slot
				);
				return;
			}

			auto *inst = GetInv().GetItem(static_cast<int16_t>(slot));
			if (!inst || !inst->GetUnscaledItem()) {
				LogInfo("[Housing] placement begin from [{}]: slot [{}] is empty", GetName(), slot);
				return;
			}

			const uint32_t carried_id = inst->GetUnscaledItem()->ID;

			const auto plot = FindNearestPlot(zone->GetShortName(), GetX(), GetY());
			if (!plot.found || !(plot.owner_char_id == CharacterID() ||
			                     (plot.owner_guild_id && plot.owner_guild_id == GuildID()))) {
				LogInfo("[Housing] placement begin from [{}]: no owned lot underfoot", GetName());
				return;
			}

			std::string model;
			if (!model_for(carried_id, model)) {
				LogInfo(
					"[Housing] placement begin from [{}]: item [{}] has no model",
					GetName(), carried_id
				);
				return;
			}

			auto nb = database.QueryDatabase(fmt::format(
				"SELECT neighborhood_id FROM nms_plot WHERE door_id = {} LIMIT 1", plot.door_id
			));
			const uint32_t nb_id = (nb.Success() && nb.RowCount())
				? Strings::ToUnsignedInt(nb.begin()[0] ? nb.begin()[0] : "0") : 0;

			// A house item (residence/deed) routes to the BUILDING flow: the ghost previews at
			// the lot marker's pose and the commit claims the lot's building slot. This is the
			// non-GM house placement the Items window drives. Furniture previews at the player.
			if (IsHousePlacementItem(carried_id)) {
				auto door = database.QueryDatabase(fmt::format(
					"SELECT d.pos_x, d.pos_y, d.pos_z, d.heading FROM nms_plot p "
					"JOIN nms_neighborhood n ON n.id = p.neighborhood_id "
					"JOIN doors d ON d.zone = n.zone AND d.doorid = p.door_id AND d.version = 0 "
					"WHERE n.zone = '{}' AND p.door_id = {} LIMIT 1",
					Strings::Escape(zone->GetShortName()), plot.door_id
				));

				if (door.Success() && door.RowCount()) {
					auto dr = door.begin();
					SendPlacementPreview(
						this, plot.door_id, carried_id, model, zone->GetZoneID(), nb_id,
						Strings::ToFloat(dr[0] ? dr[0] : "0"),
						Strings::ToFloat(dr[1] ? dr[1] : "0"),
						Strings::ToFloat(dr[2] ? dr[2] : "0"),
						Strings::ToFloat(dr[3] ? dr[3] : "0")
					);
					return;
				}
			}

			// Row id 0 marks the not-yet-placed ghost; the commit answers with the template id.
			SendRealEstateFurniturePreview(
				this, plot.door_id, 0, carried_id, model, zone->GetZoneID(), nb_id,
				GetX(), GetY(), GetZ(), GetHeading(), 0.0f, 0.0f, 1.0f
			);
			return;
		}

		// Estate source: a listed row being re-placed (the item menu's Move). The ghost spawns
		// at the row's current pose -- or at the player for a deposited (stowed) row that has
		// no pose yet; the commit updates that row and clears the stored flag.
		auto furn = database.QueryDatabase(fmt::format(
			"SELECT h.item_id, h.pos_x, h.pos_y, h.pos_z, h.heading, h.pitch, h.roll, h.scale, "
			"       p.owner_char_id, p.owner_guild_id, nb.id, COALESCE(it.idfile, ''), COALESCE(it.Name, ''), h.stowed "
			"FROM nms_house_item h "
			"JOIN nms_plot p ON p.door_id = h.door_id "
			"JOIN nms_neighborhood nb ON nb.id = p.neighborhood_id "
			"JOIN items it ON it.id = h.item_id "
			"WHERE nb.zone = '{}' AND h.door_id = {} AND h.id = {} LIMIT 1",
			Strings::Escape(zone->GetShortName()), estate_id, item_id
		));

		if (!furn.Success() || !furn.RowCount()) {
			// Not a row: the building flow. Answer with the placement preview -- the documented
			// server side of Begin -- when the estate is a lot this character may build on.
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
					"[Housing] placement begin from [{}]: estate [{}] item [{}] matches no placed row and is not a buildable lot",
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
			return;
		}

		auto f = furn.begin();

		const bool owner = Strings::ToUnsignedInt(f[8] ? f[8] : "0") == CharacterID() ||
			(Strings::ToUnsignedInt(f[9] ? f[9] : "0") != 0 &&
			 Strings::ToUnsignedInt(f[9] ? f[9] : "0") == GuildID());
		if (!owner) {
			LogInfo(
				"[Housing] placement begin from [{}]: row [{}] on lot [{}] is not theirs",
				GetName(), item_id, estate_id
			);
			return;
		}

		const std::string model = (f[11] && *f[11]) ? f[11] : (f[12] ? f[12] : "");
		if (model.empty()) {
			return;
		}

		const bool stowed = Strings::ToUnsignedInt(f[13] ? f[13] : "0") != 0;

		if (stowed) {
			// Deposited but never placed: the ghost spawns where the player stands.
			SendRealEstateFurniturePreview(
				this, estate_id, item_id, item_id, model, zone->GetZoneID(),
				Strings::ToUnsignedInt(f[10] ? f[10] : "0"),
				GetX(), GetY(), GetZ(), GetHeading(), 0.0f, 0.0f, 1.0f
			);
			return;
		}

		SendRealEstateFurniturePreview(
			this, estate_id, item_id, item_id, model, zone->GetZoneID(),
			Strings::ToUnsignedInt(f[10] ? f[10] : "0"),
			Strings::ToFloat(f[1] ? f[1] : "0"),
			Strings::ToFloat(f[2] ? f[2] : "0"),
			Strings::ToFloat(f[3] ? f[3] : "0"),
			Strings::ToFloat(f[4] ? f[4] : "0"),
			Strings::ToFloat(f[5] ? f[5] : "0"),
			Strings::ToFloat(f[6] ? f[6] : "0"),
			Strings::ToFloat(f[7] ? f[7] : "1")
		);
		return;
	}

	// House interior: furniture. The identity packet put the client's current estate at
	// the lot's door id. Both source profiles are served: the inventory profile spawns the
	// ghost at the player, the estate profile re-places a listed row.
	uint32_t door_id = 0, nb_id = 0;

	if (!ResolveOwnedInterior(this, door_id, nb_id)) {
		LogInfo(
			"[Housing] placement begin from [{}]: zone [{}] is not their interior",
			GetName(), zone->GetShortName()
		);
		return;
	}

	if (!stored_source) {
		if (slot < 23 || slot > 33) {
			LogInfo(
				"[Housing] placement begin from [{}]: inventory slot [{}] is out of range",
				GetName(), slot
			);
			return;
		}

		auto *inst = GetInv().GetItem(static_cast<int16_t>(slot));
		if (!inst || !inst->GetUnscaledItem()) {
			LogInfo("[Housing] placement begin from [{}]: slot [{}] is empty", GetName(), slot);
			return;
		}

		const uint32_t carried_id = inst->GetUnscaledItem()->ID;

		std::string model;
		if (!model_for(carried_id, model)) {
			LogInfo("[Housing] placement begin from [{}]: item [{}] has no model", GetName(), carried_id);
			return;
		}

		SendRealEstateFurniturePreview(
			this, door_id, 0, carried_id, model, zone->GetZoneID(), nb_id,
			GetX(), GetY(), GetZ(), GetHeading(), 0.0f, 0.0f, 1.0f
		);
		return;
	}

	// Estate source inside the interior: re-place a listed row at its current pose -- or at
	// the player when the row is a deposited (stowed) item that has no pose yet.
	auto furn = database.QueryDatabase(fmt::format(
		"SELECT h.item_id, h.pos_x, h.pos_y, h.pos_z, h.heading, h.pitch, h.roll, h.scale, "
		"       COALESCE(it.idfile, ''), COALESCE(it.Name, ''), h.stowed "
		"FROM nms_house_item h "
		"JOIN items it ON it.id = h.item_id "
		"WHERE h.door_id = {} AND h.id = {} LIMIT 1",
		door_id, item_id
	));

	if (!furn.Success() || !furn.RowCount()) {
		// Not a row: fall through to the legacy behaviour, which treated item at 36 as a
		// carried template id and previewed it at the player.
		std::string model;
		if (!model_for(item_id, model)) {
			LogInfo("[Housing] placement begin from [{}]: item [{}] has no model", GetName(), item_id);
			return;
		}

		SendRealEstateFurniturePreview(
			this, door_id, 0, item_id, model, zone->GetZoneID(), nb_id,
			GetX(), GetY(), GetZ(), GetHeading(), 0.0f, 0.0f, 1.0f
		);
		return;
	}

	auto f = furn.begin();

	const bool stowed = Strings::ToUnsignedInt(f[10] ? f[10] : "0") != 0;

	if (stowed) {
		SendRealEstateFurniturePreview(
			this, door_id, item_id, item_id,
			(f[8] && *f[8]) ? f[8] : (f[9] ? f[9] : ""),
			zone->GetZoneID(), nb_id,
			GetX(), GetY(), GetZ(), GetHeading(), 0.0f, 0.0f, 1.0f
		);
		return;
	}

	SendRealEstateFurniturePreview(
		this, door_id, item_id, item_id,
		(f[8] && *f[8]) ? f[8] : (f[9] ? f[9] : ""),
		zone->GetZoneID(), nb_id,
		Strings::ToFloat(f[1] ? f[1] : "0"),
		Strings::ToFloat(f[2] ? f[2] : "0"),
		Strings::ToFloat(f[3] ? f[3] : "0"),
		Strings::ToFloat(f[4] ? f[4] : "0"),
		Strings::ToFloat(f[5] ? f[5] : "0"),
		Strings::ToFloat(f[6] ? f[6] : "0"),
		Strings::ToFloat(f[7] ? f[7] : "1")
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

	// One definition per plot in the zone -- vacant ones included. The region id is the
	// definition's area_id, and the client's resolver (sub_4B30F0) only accepts a region whose
	// area id equals def[+28]; a vacant lot with a region but no definition therefore never
	// resolves, leaving RealEstate[+152] at -1 ("you must be on a plot", and no marker popup).
	//
	// The definition type is the estate's kind everywhere in the client (the underfoot walk's
	// mask 0x88 accepts kinds 4 AND 8; the purchase window's Guild/Player label and the
	// sub_5B41D0 predicate branches both read this type). nms_plot.plot_type 1 marks the guild
	// estates -- the four halls the zone map annotates "(Guild)": 200 Brimming Way, Vanward
	// Heights, Terminus Heights, Guild Way (doors 199-202).
	auto owned = database.QueryDatabase(fmt::format(
		"SELECT p.door_id, p.plot_type, (p.house_item_id > 0) AS housed "
		"FROM nms_plot p JOIN nms_neighborhood n ON n.id = p.neighborhood_id "
		"WHERE n.zone = '{}' "
		"ORDER BY p.door_id",
		Strings::Escape(zone ? zone->GetShortName() : "")
	));

	if (owned.Success() && owned.RowCount()) {
		for (auto row : owned) {
			if (!row[0]) {
				continue;
			}

			const uint32_t door_id   = Strings::ToUnsignedInt(row[0]);
			const uint32_t plot_type = Strings::ToUnsignedInt(row[1] ? row[1] : "0");
			const uint32_t housed    = Strings::ToUnsignedInt(row[2] ? row[2] : "0");

			EstateDefinition plot;
			plot.id                   = PlotDefinitionId(door_id);
			plot.area_id              = PlotRegionId(door_id);
			// Definition dword 7 is what sub_4B30F0 compares against the AREA ID:
			//   v9 = defmap_lookup(obj+32); v10 = *(v9 + 28); if (v10 == area_id) ...
			// It is not the neighbourhood link. The neighbourhood link is the object's +24.
			plot.zone_id              = PlotRegionId(door_id);
			// Guild rows (the four halls) present as kind-8 guild estates; every other plot is
			// a kind-4 personal home. The inspection record's owner string (estate+0x2C)
			// satisfies the kind-4 branch of sub_5B41D0, so personal plots no longer need the
			// guild-0 presentation workaround.
			plot.type                 = plot_type == 1 ? kRealEstateKindPlot : kRealEstateKindHouse;
			plot.address              = PlotStreetAddress(door_id);
			plot.purchase_scheme      = 1;   // the emulator tariff published below
			plot.upkeep_scheme        = 2;
			plot.max_items            = kMaxItems;
			plot.max_non_estate_items = kMaxNonEstate;
			plot.max_children         = kMaxChildEstates;
			plot.max_npc_items        = kMaxNpcItems;
			entries.push_back(plot);

			// A housed plot also carries its interior definition: type 2 is the house-interior
			// kind (sub_7F60F0). The plot snapshot's child estate resolves against it, and the
			// Items-window binder (sub_5AFFC0) only accepts children whose definition is 2/3.
			if (housed) {
				EstateDefinition interior;
				interior.id                   = kHouseInteriorDefBase + door_id;
				interior.area_id              = neighborhood_id;
				interior.zone_id              = neighborhood_id;
				interior.type                 = 2;   // house interior
				interior.max_items            = kMaxItems;
				interior.max_non_estate_items = kMaxNonEstate;
				interior.max_children         = 0;
				interior.max_npc_items        = kMaxNpcItems;
				entries.push_back(interior);
			}
		}
	}

	Writer w;
	w.U32(static_cast<uint32_t>(entries.size()));

	for (const auto &entry : entries) {
		WriteEstateDefinition(w, entry);
	}

	// Cost schemes. The grammar is recovered (scheme id, components, then 16-byte
	// type/subtype/amount values); the Live tariff is not -- those numbers lived in the 2013
	// server's catalogue, not in the client. What follows is a labelled emulator tariff so the
	// purchase window has a price and an upkeep to render at all: 420 platinum to buy and 3
	// platinum per period to keep, both in copper (type/subtype 0, the only pair we have a
	// witness for). If the client renders nothing, the type domain is wrong and the next test
	// should sweep it.
	w.U32(2);          // two schemes

	w.U32(1);          // scheme 1: purchase
	w.U32(1);          // one component
	w.U32(1);          // component id 1
	w.U32(1);          // one value
	w.U32(0);          // type
	w.U32(0);          // subtype
	w.Wide(4200000);   // 420 platinum, in copper

	w.U32(2);          // scheme 2: upkeep
	w.U32(1);
	w.U32(1);
	w.U32(1);
	w.U32(0);
	w.U32(0);
	w.Wide(30000);     // 3 platinum, in copper

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
		"       p.owner_guild_id, COALESCE(UNIX_TIMESTAMP(p.upkeep_paid_until), 0), n.id, "
		"       (p.house_item_id > 0) AS housed "
		"FROM nms_plot p "
		"JOIN nms_neighborhood n ON n.id = p.neighborhood_id "
		"LEFT JOIN character_data c ON c.id = p.owner_char_id "
		"LEFT JOIN guilds g ON g.id = p.owner_guild_id "
		"WHERE n.zone = '{}' "
		"ORDER BY p.door_id",
		Strings::Escape(zone_name)
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
		const uint32_t    housed      = Strings::ToUnsignedInt(row[7] ? row[7] : "0");
		const std::string display_name = plot_type == 1 ? guild_name : owner_name;

		EstateSnapshot plot;
		plot.estate_id     = door_id;                  // +20: the id the plot list and Go use
		// +24 is a second plot-map key. sub_4B30F0 looks the object up by RealEstate[+140] and
		// then demands obj[+20] == +140, so a plot is only reachable when it is registered
		// under the neighbourhood id that 0x6fd0 put into +140. This field is that key.
		// +24 is the STATIC id: the plot-marker identity the client associates with the pedestal
		// it just clicked. The upstream plot-marker resolver keys on exactly this value
		// (PlotMarker::Resolve(..., static_id)), so mirroring the lot id here is what lets a
		// pedestal click resolve to an estate. The +140 resolver chain does not need it any
		// more: the zone context now carries the plot id itself.
		plot.static_id     = door_id;
		plot.parent_id     = zone_id;                  // +28: the neighborhood object
		plot.definition_id = PlotDefinitionId(door_id); // +32: this plot's own definition
		// 0xFFFFFFFF reads as "absent" to the client's estate predicate (sub_5B41D0 demands
		// guild_id != -1 for a plot estate); 0 means "no guild" and passes the gate.
		plot.guild_id      = owner_guild ? owner_guild : 0;
		plot.owner_name    = display_name;
		plot.dynamic_name  = PlotStreetAddress(door_id);
		plot.expiry_time   = upkeep_unix;   // 0 = no paid-upkeep timestamp

		// A housed plot carries its interior estate as a child: the Items-window binder
		// (sub_5AFFC0, per second) walks the plot-underfoot's children for a definition of
		// kind 2/3 and binds RealEstate[+156] to it. That field is what the window's House
		// pane renders (sub_73B7E0 +624) -- without it the pane reads N/A and the action
		// buttons stay greyed.
		if (housed) {
			plot.children.push_back(kHouseEstateBase + door_id);
		}

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

		// The interior estate record itself: the child id must resolve in the estate map with
		// its type-2 definition for the binder to accept it.
		if (housed) {
			EstateSnapshot interior_estate;
			interior_estate.estate_id     = kHouseEstateBase + door_id;
			interior_estate.static_id     = door_id;
			interior_estate.parent_id     = door_id;    // the plot estate
			interior_estate.definition_id = kHouseInteriorDefBase + door_id;
			interior_estate.guild_id      = owner_guild ? owner_guild : 0;
			interior_estate.owner_name    = display_name;
			interior_estate.owner_handle  = display_name;
			interior_estate.dynamic_name  = PlotStreetAddress(door_id);

			Writer wi;
			WriteEstateSnapshot(wi, interior_estate);

			const auto &bufi = wi.Buffer();
			auto outi = new EQApplicationPacket(OP_RealEstateSnapshot, static_cast<uint32>(bufi.size()));
			std::memcpy(outi->pBuffer, bufi.data(), bufi.size());
			c->QueuePacket(outi);
			safe_delete(outi);

			++sent;

			LogInfo(
				"[Housing] sent house estate to [{}]: door [{}], estate [{}], {} bytes",
				c->GetName(), door_id, kHouseEstateBase + door_id, bufi.size()
			);
		}
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
		// Every plot in the zone, not just this character's: the "inside a plot" test is what
		// lets anyone inspect a lot, and an owner-filtered manifest leaves every other player
		// with RealEstate[+152] == -1 and the "you must be inside a plot or house" refusal.
		"WHERE n.zone = '{}'",
		Strings::Escape(zone_name)
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
			// geometry is not the problem -- the id resolution or the ingest is. Keyed under
			// the region id (not the door id): the resolver only accepts an area whose id
			// equals the plot definition's area_id field.
			write_region(PlotRegionId(door_id), c->GetX(), c->GetY(), c->GetZ(), 200.0f, 200.0f, 200.0f);
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

// ---------------------------------------------------------------------------
// Interior furniture (v1).
//
// Placement/pickup of ordinary items inside a house interior, on our own tables
// (nms_house_item) and the recovered wire layouts only: the placement commit 0x711a is
// 96 bytes with heading/pitch/roll/scale at 44..56 and Y/X/Z at 60..68, and the world
// item 0x1045 is one bare ActorRecord whose record num must not be the item id. The
// overlay's custody/escrow machinery is deliberately not ported (adoption doc §4): a
// placed item is consumed from the inventory and lives in nms_house_item until it is
// picked back up.
//
// v1 placement is GM-driven (#housing item place); the client's own Place action needs
// the item-metadata tail this tree does not emit yet, so the furniture half of the
// placement Begin/Commit handlers is wired but dormant until that tail lands (v2).
// ---------------------------------------------------------------------------

// An item may be placed only when a GM allowlisted it (nms_housing_placeable). No
// itemtype or name heuristic decides this: which items are furniture is server policy.
// An item may be placed only when a GM allowlisted it (nms_housing_placeable). No
// itemtype or name heuristic decides this: which items are furniture is server policy.
bool IsPlaceableHousingItem(uint32_t item_id)
{
	auto r = database.QueryDatabase(fmt::format(
		"SELECT 1 FROM nms_housing_placeable WHERE item_id = {} LIMIT 1", item_id
	));

	return r.Success() && r.RowCount() > 0;
}

// The interior identity's own lookup: the current zone is a house interior when the
// character's house row lives here. Returns the lot door id -- which is also the client's
// current estate id inside the interior -- and the neighborhood id. One house row per
// character; with several owned plots the lowest door id wins (documented v1 limitation:
// the shared interior cannot tell which plot was entered through).
bool ResolveOwnedInterior(Client *c, uint32_t &door_id, uint32_t &nb_id)
{
	door_id = 0;
	nb_id   = 0;

	if (!c || !zone) {
		return false;
	}

	auto interior = database.QueryDatabase(fmt::format(
		"SELECT p.door_id, n.id FROM house h "
		"JOIN nms_plot p ON p.house_id = h.id "
		"JOIN nms_neighborhood n ON n.id = p.neighborhood_id "
		"WHERE h.char_id = {} AND h.zone = '{}' "
		"ORDER BY p.door_id LIMIT 1",
		c->CharacterID(), Strings::Escape(zone->GetShortName())
	));

	if (!interior.Success() || !interior.RowCount() || !interior.begin()[0]) {
		return false;
	}

	door_id = Strings::ToUnsignedInt(interior.begin()[0]);
	nb_id   = Strings::ToUnsignedInt(interior.begin()[1] ? interior.begin()[1] : "0");

	return door_id != 0;
}

// True when the plot behind a door id belongs to this client (guild plots to the guild).
bool FurniturePlotIsMine(Client *c, uint32_t door_id)
{
	auto plot = database.QueryDatabase(fmt::format(
		"SELECT p.plot_type, p.owner_char_id, p.owner_guild_id FROM nms_plot p "
		"WHERE p.door_id = {} LIMIT 1",
		door_id
	));

	if (!plot.Success() || !plot.RowCount()) {
		return false;
	}

	auto row = plot.begin();

	const uint32_t plot_type   = Strings::ToUnsignedInt(row[0] ? row[0] : "0");
	const uint32_t owner_char  = Strings::ToUnsignedInt(row[1] ? row[1] : "0");
	const uint32_t owner_guild = Strings::ToUnsignedInt(row[2] ? row[2] : "0");

	return plot_type == 1
		? (owner_guild != 0 && owner_guild == c->GuildID())
		: (owner_char != 0 && owner_char == c->CharacterID());
}

// 0x1045 S2C for one furniture row: the same ActorRecord grammar as a building's world
// item, but the GUID packs the row id (MakeFurnitureId) and record_num IS the row id --
// the client keys placed actors by it, and STRUCTS.md warns it must not be the item id.
bool SendRealEstateFurnitureWorldItem(Client *c, uint32_t door_id, uint32_t row_id, uint32_t item_id,
                                      const std::string &model, uint32_t zone_id,
                                      float x, float y, float z, float heading, float scale)
{
	if (!c || !zone || model.empty()) {
		return false;
	}

	PlacementActor actor;
	actor.model      = model;
	actor.guid       = MakeFurnitureId(zone_id, door_id, row_id);
	actor.record_num = row_id;
	actor.estate_id  = door_id;
	actor.item_id    = item_id;
	actor.scale      = scale > 0.0f ? scale : 1.0f;
	actor.heading    = heading;
	actor.x          = x;
	actor.y          = y;
	actor.z          = z;
	// No collision maps exist in this tree (adoption doc §5), so the client-side collision
	// flag is cleared: there is no server-side validation for it to mirror.
	actor.ignore_collisions = 1;

	Writer w;
	WritePlacementActor(w, actor);

	const auto &buf = w.Buffer();
	auto outapp = new EQApplicationPacket(OP_RealEstateWorldItem, static_cast<uint32>(buf.size()));
	std::memcpy(outapp->pBuffer, buf.data(), buf.size());
	c->QueuePacket(outapp);
	safe_delete(outapp);

	LogInfo(
		"[Housing] sent furniture world item to [{}]: lot [{}], row [{}], item [{}], model [{}], "
		"({:.1f}, {:.1f}, {:.1f}), {} bytes",
		c->GetName(), door_id, row_id, item_id, model, x, y, z, buf.size()
	);

	return true;
}

// 0x2a9e S2C retire for one furniture row. The client matches the actor by the GUID it was
// sent, so this must carry the MakeFurnitureId form, not the building one.
bool SendRealEstateFurnitureWorldRemove(Client *c, uint32_t door_id, uint32_t row_id,
                                        uint32_t item_id, uint32_t zone_id)
{
	if (!c) {
		return false;
	}

	Writer w;
	w.CStr(MakeFurnitureId(zone_id, door_id, row_id));  // 16 characters plus NUL
	w.U8(0);                        // pad the GUID field to the fixed 18 bytes the layout uses
	w.U32(0); w.U32(0); w.U32(0);   // 20..31: not read by the retire path
	w.U32(door_id);                 // 32: estate id
	w.U32(item_id);                 // 36: item id

	const auto &buf = w.Buffer();
	auto outapp = new EQApplicationPacket(OP_RealEstateWorldRemove, static_cast<uint32>(buf.size()));
	std::memcpy(outapp->pBuffer, buf.data(), buf.size());
	c->QueuePacket(outapp);
	safe_delete(outapp);

	return true;
}

// Draws every furniture row recorded for a lot. Sent from the interior identity (zone-in
// and #housing send); the building path keeps its own SendRealEstateExteriors.
// 0x1228 S2C: the placement result. Result 0 closes the client's placement preview and commits
// its local state; the native result codes (9 invalid source, 20 too far, 23 not in region...)
// come from the same recovered table the overlay documents.
void SendRealEstateOperationResult(Client *c, uint32_t result)
{
	if (!c) {
		return;
	}

	Writer w;
	w.U32(result);

	const auto &buf = w.Buffer();
	auto outapp = new EQApplicationPacket(OP_RealEstateOperationResult, static_cast<uint32>(buf.size()));
	std::memcpy(outapp->pBuffer, buf.data(), buf.size());
	c->QueuePacket(outapp);
	safe_delete(outapp);

	LogInfo("[Housing] sent operation result [{}] to [{}]", result, c->GetName());
}

// The furniture placement preview: the same ActorRecord the world item carries, followed by the
// preview suffix (source kind, slots, flags, words, region map, fallback). The ghost spawns at
// (x, y, z) -- the player for new placements, the row's pose for re-placements -- and the commit
// echoes the identity this packet gave: lot at estate_id, row id (0 = not yet placed) or template
// id at item_id, GUID from MakeFurnitureId.
bool SendRealEstateFurniturePreview(Client *c, uint32_t door_id, uint32_t row_id, uint32_t item_id,
                                    const std::string &model, uint32_t zone_id, uint32_t neighborhood_id,
                                    float x, float y, float z, float heading, float pitch, float roll,
                                    float scale)
{
	if (!c || !zone || model.empty()) {
		return false;
	}

	PlacementActor actor;
	actor.model      = model;
	actor.guid       = MakeFurnitureId(zone_id, door_id, row_id);
	actor.record_num = row_id;
	actor.estate_id  = door_id;
	actor.item_id    = item_id;
	actor.scale      = scale > 0.0f ? scale : 1.0f;
	actor.heading    = heading;
	actor.pitch      = pitch;
	actor.roll       = roll;
	actor.y          = y;
	actor.x          = x;
	actor.z          = z;
	actor.ignore_collisions = 1;

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
		"[Housing] sent furniture preview to [{}]: lot [{}], row [{}], item [{}], model [{}], "
		"({:.1f}, {:.1f}, {:.1f}) heading {:.1f} pitch {:.1f} roll {:.1f} scale {:.2f}, {} bytes",
		c->GetName(), door_id, row_id, item_id, model, x, y, z, heading, pitch, roll,
		scale > 0.0f ? scale : 1.0f, buf.size()
	);

	return true;
}

// 0x1cef S2C estate item list: u32 estate + u32 count + per-item entries. Entry format per the
// public reconstruction's FurnitureEntry (estate, row id, placed byte, expired word, pose as
// heading/pitch/roll/scale then Y/X/Z, display owner, owner, embedded item serialization). The
// embedded item is the standard RoF2 item serialization the client already parses; an entry the
// client cannot parse crashes it, so rows without a serializable item are skipped, never guessed.
void SendRealEstateItemList(Client *c, uint32_t estate_id)
{
	if (!c || !zone || !estate_id || estate_id == UINT32_MAX) {
		return;
	}

	// The requested id decides which pane the client files these rows under: the plot estate
	// is Yard (placed + shed + crate), the house-interior estate is House (closet).
	const uint32_t requested_estate = estate_id;
	const bool     house_list       = requested_estate >= kHouseEstateBase;

	// House-interior handles (kHouseEstateBase + door) key the same rows as the door id.
	estate_id = NormalizeEstateDoor(estate_id);

	// The estate's NEIGHBORHOOD zone: the current zone when we stand in it, otherwise the zone
	// the lot belongs to. An interior is not a neighborhood, and filtering on the interior's
	// short name there dropped every row -- the window then had nothing to show or right-click.
	std::string neighborhood_zone = zone->GetShortName();

	auto here = database.QueryDatabase(fmt::format(
		"SELECT 1 FROM nms_neighborhood WHERE zone = '{}' LIMIT 1",
		Strings::Escape(zone->GetShortName())
	));

	if (!here.Success() || !here.RowCount()) {
		auto nb = database.QueryDatabase(fmt::format(
			"SELECT n.zone FROM nms_plot p JOIN nms_neighborhood n ON n.id = p.neighborhood_id "
			"WHERE p.door_id = {} ORDER BY p.id LIMIT 1", estate_id
		));

		if (nb.Success() && nb.RowCount() && nb.begin()[0]) {
			neighborhood_zone = nb.begin()[0];
		}
	}

	// Ownership gate: the list carries private estate data, so only the owner (or their guild)
	// gets rows; anyone else gets the empty-list shape the client already tolerated.
	auto plot = database.QueryDatabase(fmt::format(
		"SELECT 1 FROM nms_plot p JOIN nms_neighborhood n ON n.id = p.neighborhood_id "
		"WHERE n.zone = '{}' AND p.door_id = {} "
		"  AND (p.owner_char_id = {} OR (p.owner_guild_id > 0 AND p.owner_guild_id = {})) "
		"LIMIT 1",
		Strings::Escape(neighborhood_zone), estate_id, c->CharacterID(), c->GuildID()
	));

	const bool owner = plot.Success() && plot.RowCount();

	Writer w;
	w.U32(requested_estate);
	w.U32(0);   // count placeholder; patched below

	uint32_t count = 0;

	if (owner) {
		auto rows = database.QueryDatabase(fmt::format(
			"SELECT h.id, h.item_id, h.charges, h.heading, h.pitch, h.roll, h.scale, "
			"       h.pos_x, h.pos_y, h.pos_z, COALESCE(cd.name, ''), h.stowed, h.container "
			"FROM nms_house_item h "
			"LEFT JOIN character_data cd ON cd.id = h.placed_by "
			"WHERE h.door_id = {}{} "
			"ORDER BY h.id",
			estate_id, house_list ? " AND h.container = 0" : ""
		));

		if (rows.Success()) {
			for (auto row : rows) {
				const uint32_t row_id  = Strings::ToUnsignedInt(row[0] ? row[0] : "0");
				const uint32_t item_id = Strings::ToUnsignedInt(row[1] ? row[1] : "0");

				const auto *data = database.GetItem(item_id);
				if (!row_id || !item_id || !data) {
					continue;
				}

				auto *inst = database.CreateBaseItem(data, static_cast<int16_t>(
					Strings::ToUnsignedInt(row[2] ? row[2] : "1")));
				if (!inst) {
					continue;
				}

				EQ::OutBuffer body_ob;
				RoF2::SerializeItem(body_ob, inst, EQ::invslot::slotCursor, 0, ItemPacketCharInventory);
				const std::string body = body_ob.str();
				safe_delete(inst);

				if (body.empty()) {
					continue;
				}

				// Bound the packet: a UDP-sized list stays single-packet, like the reference's
				// ItemListWire (entries beyond it belong in the delta form we do not send yet).
				if (w.Buffer().size() + body.size() + 64 > 60000) {
					LogInfo("[Housing] item list for estate [{}] truncated at [{}] rows", estate_id, count);
					break;
				}

				const std::string owner_name = row[10] ? std::string(row[10]) : std::string();

				if (count == 0) {
					// The client renders a wrongly-sized ItemPtr as a garbage item (seen: a bed with
					// qty 250 for a satchel row). Log the size so the framing can be checked live.
					LogInfo(
						"[Housing] item list entry: estate [{}] row [{}] item [{}] body [{}] bytes, first [{}]",
						requested_estate, row_id, item_id, body.size(),
						body.size() >= 8 ? fmt::format("{:02x}{:02x}{:02x}{:02x}{:02x}{:02x}{:02x}{:02x}",
							static_cast<uint8_t>(body[0]), static_cast<uint8_t>(body[1]),
							static_cast<uint8_t>(body[2]), static_cast<uint8_t>(body[3]),
							static_cast<uint8_t>(body[4]), static_cast<uint8_t>(body[5]),
							static_cast<uint8_t>(body[6]), static_cast<uint8_t>(body[7])) : std::string("-")
					);
				}

				w.U32(requested_estate);
				w.U32(row_id);
				// container -1 is placed in the world; 0/1/2 are the closet/shed/crate rows.
				const int container = row[12] ? Strings::ToInt(row[12]) : (Strings::ToUnsignedInt(row[11] ? row[11] : "0") ? 0 : -1);
				w.U8(container < 0 ? 1 : 0);   // placed (0 = stored in a container)
				w.U32(0);             // expired
				w.Float(Strings::ToFloat(row[3] ? row[3] : "0"));   // heading
				w.Float(Strings::ToFloat(row[4] ? row[4] : "0"));   // pitch
				w.Float(Strings::ToFloat(row[5] ? row[5] : "0"));   // roll
				w.Float(Strings::ToFloat(row[6] ? row[6] : "1"));   // scale
				// ItemEntry carries X/Y/Z (the world actor is the one that swaps to Y/X/Z).
				w.Float(Strings::ToFloat(row[7] ? row[7] : "0"));   // X
				w.Float(Strings::ToFloat(row[8] ? row[8] : "0"));   // Y
				w.Float(Strings::ToFloat(row[9] ? row[9] : "0"));   // Z
				w.Str("");            // display owner: empty = the viewer's own estate
				w.Str(owner_name);
				w.Bytes(body);
				++count;
			}
		}
	}

	w.PatchU32(4, count);

	const auto &buf = w.Buffer();
	auto outapp = new EQApplicationPacket(OP_RealEstateItemList, static_cast<uint32>(buf.size()));
	std::memcpy(outapp->pBuffer, buf.data(), buf.size());
	c->QueuePacket(outapp);
	safe_delete(outapp);

	LogInfo(
		"[Housing] item list for [{}]: estate [{}], owner [{}], rows [{}], {} bytes",
		c->GetName(), estate_id, owner, count, buf.size()
	);
}

void SendRealEstateFurniture(Client *c, uint32_t door_id)
{
	if (!c || !zone || !door_id) {
		return;
	}

	const uint32_t zone_id = zone->GetZoneID();

	auto rows = database.QueryDatabase(fmt::format(
		"SELECT f.id, f.item_id, f.pos_x, f.pos_y, f.pos_z, f.heading, f.scale, "
		"       COALESCE(it.idfile, ''), COALESCE(it.Name, '') "
		"FROM nms_house_item f "
		"LEFT JOIN items it ON it.id = f.item_id "
		"WHERE f.door_id = {} AND f.container = -1 ORDER BY f.id",
		door_id
	));

	if (!rows.Success() || !rows.RowCount()) {
		return;
	}

	for (auto row : rows) {
		const uint32_t    row_id  = Strings::ToUnsignedInt(row[0]);
		const uint32_t    item_id = Strings::ToUnsignedInt(row[1]);
		const float       px      = static_cast<float>(Strings::ToFloat(row[2] ? row[2] : "0"));
		const float       py      = static_cast<float>(Strings::ToFloat(row[3] ? row[3] : "0"));
		const float       pz      = static_cast<float>(Strings::ToFloat(row[4] ? row[4] : "0"));
		const float       heading = static_cast<float>(Strings::ToFloat(row[5] ? row[5] : "0"));
		const float       scale   = static_cast<float>(Strings::ToFloat(row[6] ? row[6] : "1"));
		const std::string idfile  = std::string(row[7] ? row[7] : "");
		const std::string name    = std::string(row[8] ? row[8] : "");

		// Same model rule as the exteriors: the idfile is the world model, the display
		// name only a fallback that will not render but keeps the packet shape valid.
		const std::string model = idfile.empty() ? name : idfile;

		if (model.empty()) {
			LogInfo("[Housing] furniture row [{}] item [{}] has no model; skipped", row_id, item_id);
			continue;
		}

		SendRealEstateFurnitureWorldItem(c, door_id, row_id, item_id, model, zone_id, px, py, pz, heading, scale);
	}
}

// Puts one placed furniture row back into the client's inventory, deletes the row and
// retires the world actor. False keeps the row (nothing was consumed): the item data is
// gone or the caller's ownership gate failed before this ran. Inventory-full falls back
// to the cursor, the same order the merchant-buy path uses (client_packet.cpp:2759).
bool ReturnFurnitureRow(Client *c, uint32_t row_id)
{
	auto rows = database.QueryDatabase(fmt::format(
		"SELECT f.door_id, f.item_id, f.charges FROM nms_house_item f WHERE f.id = {} LIMIT 1",
		row_id
	));

	if (!rows.Success() || !rows.RowCount()) {
		return false;
	}

	auto row = rows.begin();

	const uint32_t door_id = Strings::ToUnsignedInt(row[0] ? row[0] : "0");
	const uint32_t item_id = Strings::ToUnsignedInt(row[1] ? row[1] : "0");
	const int32_t  charges = Strings::ToInt(row[2] ? row[2] : "1");

	const EQ::ItemData *item_data = item_id ? database.GetItem(item_id) : nullptr;

	if (!item_data) {
		LogInfo("[Housing] furniture row [{}] item [{}] no longer exists; row kept", row_id, item_id);
		return false;
	}

	EQ::ItemInstance *inst = database.CreateItem(item_data, charges > 0 ? charges : 1);

	if (!inst) {
		LogInfo("[Housing] furniture row [{}] item [{}] could not be instantiated; row kept", row_id, item_id);
		return false;
	}

	if (!c->AutoPutLootInInventory(*inst, true, true)) {
		c->PutLootInInventory(EQ::invslot::slotCursor, *inst);
	}

	database.QueryDatabase(fmt::format("DELETE FROM nms_house_item WHERE id = {}", row_id));

	if (zone) {
		SendRealEstateFurnitureWorldRemove(c, door_id, row_id, item_id, zone->GetZoneID());
	}

	LogInfo("[Housing] furniture row [{}] (item [{}]) returned to [{}]", row_id, item_id, c->GetName());
	return true;
}

// Puts a placed row into a container: the row stays (custody moved to the estate) and the
// world actor is retired. Capacity is the caller's business -- Store All checks once for the
// batch, a single deposit checks before it inserts.
bool StoreFurnitureRow(Client *c, uint32_t row_id, int container)
{
	auto row = database.QueryDatabase(fmt::format(
		"SELECT door_id, item_id FROM nms_house_item WHERE id = {} LIMIT 1", row_id
	));

	if (!row.Success() || !row.RowCount() || !row.begin()[0]) {
		return false;
	}

	const uint32_t door_id = Strings::ToUnsignedInt(row.begin()[0]);
	const uint32_t item_id = Strings::ToUnsignedInt(row.begin()[1] ? row.begin()[1] : "0");

	auto upd = database.QueryDatabase(fmt::format(
		"UPDATE nms_house_item SET stowed = 1, container = {} WHERE id = {}", container, row_id
	));

	if (!upd.Success() || !upd.RowsAffected()) {
		return false;
	}

	if (zone) {
		SendRealEstateFurnitureWorldRemove(c, door_id, row_id, item_id, zone->GetZoneID());
	}

	LogInfo(
		"[Housing] row [{}] (item [{}]) on lot [{}] stored in [{}]",
		row_id, item_id, door_id, ContainerName(container)
	);

	return true;
}

// 0x2036 C2S cursor pickup of a placed item. The exact C2S field layout is only partly
// recovered, but the GUID the client echoes at 0 is verbatim from the actor it was sent,
// and furniture GUIDs pack the row id -- so the GUID alone resolves the row. The
// estate/item fields the building shapes use (32/36) corroborate when the body is long
// enough; a mismatch is logged, the GUID still wins.
void Client::Handle_OP_RealEstatePickup(const EQApplicationPacket *app)
{
	LogHousingOpcode(this, app, "OP_RealEstatePickup");

	if (!zone || app->size < 16) {
		return;
	}

	const char *raw_guid = reinterpret_cast<const char *>(app->pBuffer);
	std::string guid(raw_guid, strnlen(raw_guid, 16));

	uint32_t guid_zone = 0, door_id = 0, row_id = 0;

	if (!DecodeRealEstateId(guid, guid_zone, door_id, row_id) || !row_id) {
		LogInfo("[Housing] pickup from [{}]: GUID [{}] does not resolve to furniture", GetName(), guid);
		return;
	}

	// The row's plot must still belong to the sender: the GUID is client-echoed data.
	if (!FurniturePlotIsMine(this, door_id)) {
		LogInfo("[Housing] pickup from [{}]: row [{}] lot [{}] (guid zone [{}]) is not theirs",
		        GetName(), row_id, door_id, guid_zone);
		return;
	}

	if (app->size >= 40) {
		const uint32_t estate_field = ReadU32(app, 32);

		if (estate_field != door_id) {
			LogInfo(
				"[Housing] pickup from [{}]: body estate [{}] vs row lot [{}] (GUID wins)",
				GetName(), estate_field, door_id
			);
		}
	}

	if (!ReturnFurnitureRow(this, row_id)) {
		Message(Chat::White, "[housing] that item could not be picked up.");
		return;
	}

	Message(Chat::White, "[housing] item picked up.");
}

// 0x6917 C2S store-all: the frame carries no application bytes; the estate context is
// wherever the player stands. Stows every furniture row in the sender's interior, stopping
// only when rows refuse to return (the placed items stay until picked up one by one).
void Client::Handle_OP_RealEstateStoreAll(const EQApplicationPacket *app)
{
	LogHousingOpcode(this, app, "OP_RealEstateStoreAll");

	uint32_t door_id = 0, nb_id = 0;

	if (!ResolveOwnedInterior(this, door_id, nb_id)) {
		LogInfo("[Housing] store-all from [{}]: not inside their own interior", GetName());
		return;
	}
	(void) nb_id;

	auto rows = database.QueryDatabase(fmt::format(
		"SELECT id FROM nms_house_item WHERE door_id = {} AND container = -1 ORDER BY id", door_id
	));

	if (!rows.Success() || !rows.RowCount()) {
		Message(Chat::White, "[housing] nothing is placed here.");
		return;
	}

	// Store All packs the placed furniture into the house closet, honouring its slot cap.
	const HouseCapacity capacity = LoadHouseCapacity(PlotHouseDefinition(door_id));
	const uint32_t      closet   = PlotItemCount(door_id, kContainerCloset);

	uint32_t room = capacity.max_vault
		? (closet < capacity.max_vault ? capacity.max_vault - closet : 0)
		: UINT32_MAX;

	uint32_t stored = 0;
	uint32_t left   = 0;

	for (auto row : rows) {
		const uint32_t row_id = Strings::ToUnsignedInt(row[0]);

		if (room && StoreFurnitureRow(this, row_id, kContainerCloset)) {
			++stored;
			--room;
		}
		else {
			++left;
		}
	}

	Message(
		Chat::White,
		fmt::format(
			"[housing] stored [{}] item(s) in the closet{}.",
			stored, left ? fmt::format("; [{}] left placed", left) : ""
		).c_str()
	);

	SendRealEstateItemList(this, door_id);
}

// Re-sends the exterior preview for every building placed on any lot in the zone -- not just
// the ones the incoming character owns. Every player standing in a neighbourhood has to receive
// these, otherwise a house is only ever visible to its owner.
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
		"ORDER BY p.door_id",
		Strings::Escape(zone_name)
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

// 0x2aa7 S2C: full replacement list of the estates this character may act on. Frame is a
// u32 count followed by that many estate ids (door ids), which is what fills the client's
// My Plots window. Always sent -- an empty list is how the window learns the player has none.
void SendRealEstateOwnedList(Client *c)
{
	if (!c || !zone) {
		return;
	}

	auto owned = database.QueryDatabase(fmt::format(
		"SELECT p.door_id FROM nms_plot p JOIN nms_neighborhood n ON n.id = p.neighborhood_id "
		"WHERE n.zone = '{}' AND (p.owner_char_id = {} OR (p.owner_guild_id > 0 AND p.owner_guild_id = {})) "
		"ORDER BY p.door_id",
		Strings::Escape(zone->GetShortName()), c->CharacterID(), c->GuildID()
	));

	std::vector<uint32_t> ids;
	if (owned.Success() && owned.RowCount()) {
		for (auto row : owned) {
			if (row[0]) {
				ids.push_back(Strings::ToUnsignedInt(row[0]));
			}
		}
	}

	Writer w;
	w.U32(static_cast<uint32_t>(ids.size()));
	for (uint32_t id : ids) {
		w.U32(id);
	}

	const auto &buf = w.Buffer();
	auto outapp = new EQApplicationPacket(OP_RealEstateOwnedList, static_cast<uint32>(buf.size()));
	std::memcpy(outapp->pBuffer, buf.data(), buf.size());
	c->QueuePacket(outapp);
	safe_delete(outapp);

	LogInfo("[Housing] sent owned list to [{}]: {} estate(s), {} bytes", c->GetName(), ids.size(), buf.size());
}

// 0x485d S2C access list: the Manage window's Access/Permissions data. Recovered grammar
// (upstream protocol docs): u32 estate id, SEVEN unconditional u32 group / u32 capability-mask
// pairs, u32 member count, then per member an LP32 name and a u32 group id. The client's
// dispatcher feeds this straight into the Manage window singleton and refreshes it only while
// the estate matches RealEstate[+152] -- without this packet the manage window has no access
// data to render and stays a bare context shell.
//
// Group ids follow the Manage window's own tier combobox (Everyone, Visitor, Acquaintance,
// Friend, Trustee, Co-Owner, Owner), so 6 is the owner tier. Capability-mask bit semantics
// were never recovered; this server does not enforce plot permissions, so every tier is sent
// fully permissive -- labelled emulator policy, to be narrowed if a tier gate ever matters.
void SendRealEstateAccessList(Client *c, uint32_t estate_id)
{
	if (!c || !zone || !estate_id || estate_id == UINT32_MAX) {
		return;
	}

	auto plot = database.QueryDatabase(fmt::format(
		"SELECT p.plot_type, COALESCE(c.name, ''), COALESCE(g.name, '') "
		"FROM nms_plot p "
		"JOIN nms_neighborhood nb ON nb.id = p.neighborhood_id "
		"LEFT JOIN character_data c ON c.id = p.owner_char_id "
		"LEFT JOIN guilds g ON g.id = p.owner_guild_id "
		"WHERE nb.zone = '{}' AND p.door_id = {} LIMIT 1",
		Strings::Escape(zone->GetShortName()), estate_id
	));

	if (!plot.Success() || !plot.RowCount()) {
		return;
	}

	auto        row        = plot.begin();
	const bool  guild_plot = Strings::ToUnsignedInt(row[0] ? row[0] : "0") == 1;
	std::string owner_name = std::string(row[1] ? row[1] : "");
	if (guild_plot) {
		owner_name = std::string(row[2] ? row[2] : "");
	}

	constexpr uint32_t kTierCount = 7;
	constexpr uint32_t kOwnerTier = 6;

	Writer w;
	w.U32(estate_id);
	for (uint32_t tier = 0; tier < kTierCount; ++tier) {
		w.U32(tier);             // group id
		w.U32(0xFFFFFFFFu);      // capability mask: every permission (see note above)
	}

	if (owner_name.empty()) {
		w.U32(0);
	} else {
		w.U32(1);
		w.Str(owner_name);
		w.U32(kOwnerTier);
	}

	const auto &buf = w.Buffer();
	auto outapp = new EQApplicationPacket(OP_RealEstateAccess, static_cast<uint32>(buf.size()));
	std::memcpy(outapp->pBuffer, buf.data(), buf.size());
	c->QueuePacket(outapp);
	safe_delete(outapp);

	LogInfo(
		"[Housing] sent access list to [{}]: estate [{}] owner '{}' ({} bytes)",
		c->GetName(), estate_id, owner_name, buf.size()
	);
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
		// The definition kind is the +144 gate inside the interior: sub_7F5F70 accepts ONLY kind 5,
		// and any other value makes the client answer "You must be in a neighborhood to use that"
		// (eqstr 8078) for every real-estate action, placement included -- which is why the
		// placement UI stayed greyed out inside the house. Kind 8 (plot) was the old choice to
		// satisfy the Manage predicate; that window never rendered anyway, so the gate wins.
		house_def.type                 = kRealEstateKindNeighborhood;
		// Per-house capacity profile: the totals the item/definition actually carries
		// (nms_house_capacity, seeded from the reviewed 2013 class-wide limits).
		const HouseCapacity capacity = LoadHouseCapacity(PlotHouseDefinition(door_id));

		house_def.max_items            = capacity.max_items ? capacity.max_items : 300;
		house_def.max_non_estate_items = capacity.max_non_estate ? capacity.max_non_estate : house_def.max_items;
		house_def.max_npc_items        = capacity.max_npc ? capacity.max_npc : 5;

		// The +152 gate ("You must be inside a plot or house to use that", eqstr 727) needs a
		// kind-4/8 object underfoot. The interior has no neighbourhood regions, so the lot is
		// registered here as a plot object with its own definition and one region box.
		EstateDefinition plot_def;
		plot_def.id                   = PlotDefinitionId(door_id);
		plot_def.area_id              = PlotRegionId(door_id);
		plot_def.zone_id              = PlotRegionId(door_id);
		plot_def.type                 = kRealEstateKindPlot;
		plot_def.address              = PlotStreetAddress(door_id);
		plot_def.max_items            = house_def.max_items;
		plot_def.max_non_estate_items = house_def.max_non_estate_items;
		plot_def.max_npc_items        = house_def.max_npc_items;
		plot_def.max_children         = 0;

		Writer defs;
		defs.U32(2);
		WriteEstateDefinition(defs, house_def);
		WriteEstateDefinition(defs, plot_def);
		defs.U32(0);

		const auto &def_bytes = defs.Buffer();
		auto def_packet = new EQApplicationPacket(OP_RealEstateDefinitions, static_cast<uint32>(def_bytes.size()));
		std::memcpy(def_packet->pBuffer, def_bytes.data(), def_bytes.size());
		QueuePacket(def_packet);
		safe_delete(def_packet);

		EstateSnapshot interior_snapshot;
		interior_snapshot.estate_id     = door_id;
		interior_snapshot.definition_id = 2;
		interior_snapshot.guild_id      = 0;   // -1 fails the kind-8 branch of sub_5B41D0
		interior_snapshot.owner_name    = GetName();
		interior_snapshot.dynamic_name  = PlotStreetAddress(door_id);   // "103 Park Circle", not "Plot 19"

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

		// The lot as a kind-8 object for the spatial walk: this is what sets +152 inside the
		// interior, which 727 (and the Manage window behind it) tests.
		EstateSnapshot lot_snapshot;
		lot_snapshot.estate_id     = door_id;
		lot_snapshot.parent_id     = nb_id;
		lot_snapshot.definition_id = PlotDefinitionId(door_id);
		lot_snapshot.guild_id      = 0;
		lot_snapshot.owner_name    = GetName();
		lot_snapshot.dynamic_name  = PlotStreetAddress(door_id);

		Writer lot_w;
		WriteEstateSnapshot(lot_w, lot_snapshot);

		const auto &lot_buf = lot_w.Buffer();
		auto lot_packet = new EQApplicationPacket(OP_RealEstateSnapshot, static_cast<uint32>(lot_buf.size()));
		std::memcpy(lot_packet->pBuffer, lot_buf.data(), lot_buf.size());
		QueuePacket(lot_packet);
		safe_delete(lot_packet);

		// One region box centred on the player, generous enough to cover any interior room.
		{
			Writer region;
			region.U32(1);
			region.U32(PlotRegionId(door_id));

			constexpr float half = 300.0f;
			const float cx = GetX(), cy = GetY(), cz = GetZ();

			// Same matrix convention as the neighbourhood manifest (extents Y/X, translation Y/X).
			region.Float(half); region.Float(0.0f); region.Float(0.0f); region.Float(0.0f);
			region.Float(0.0f); region.Float(half); region.Float(0.0f); region.Float(0.0f);
			region.Float(0.0f); region.Float(0.0f); region.Float(half); region.Float(0.0f);
			region.Float(cy); region.Float(cx); region.Float(cz); region.Float(1.0f);
			region.Float(0.0f); region.Float(0.0f); region.Float(0.0f);
			region.U32(0xFFFFFFFF); region.U32(0xFFFFFFFF);

			const auto &region_buf = region.Buffer();
			auto region_packet = new EQApplicationPacket(OP_RealEstateRegions, static_cast<uint32>(region_buf.size()));
			std::memcpy(region_packet->pBuffer, region_buf.data(), region_buf.size());
			QueuePacket(region_packet);
			safe_delete(region_packet);

			LogInfo(
				"[Housing] sent interior region for lot [{}]: id [{}] at ({:.1f}, {:.1f}, {:.1f})",
				door_id, PlotRegionId(door_id), cx, cy, cz
			);
		}

		SendRealEstateOwnedList(this);
		SendRealEstateAccessList(this, door_id);
		// The placed furniture draws the same way the building exteriors do in the
		// neighborhood: the client keeps no copy, so every identity burst re-sends it.
		SendRealEstateFurniture(this, door_id);
		// The Items window (and the item menu behind it) needs the estate's rows; it does not
		// ask for them on its own. Push them with the context.
		SendRealEstateItemList(this, door_id);
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

	// Seed the estate data the Manage window renders. The client opens that window without
	// asking for anything, so the inspection body has to be pushed: show=false registers the
	// estate record silently (the purchase window only pops when the record's show byte is 1).
	for (uint32_t plot_id : owned_plots) {
		SendRealEstateInspection(this, plot_id, false);
		// The Manage window renders the access/permission page from this list; seed it with
		// the inspection so the window is complete before it is first opened.
		SendRealEstateAccessList(this, plot_id);
	}

	SendRealEstateAreaManifest(this);

	// Buildings already placed on those lots: the preview is what actually draws them, and
	// it has to be re-sent on every zone-in because the client keeps no copy.
	SendRealEstateExteriors(this);

	// Last, so every estate it names is already registered: the My Plots window.
	SendRealEstateOwnedList(this);

	// The Items window binds per estate and never queries on its own (0x050c has not been
	// observed once). Push the list for every housed plot this character or guild owns, so the
	// window -- and the right-click menu it feeds -- has rows at zone-in.
	auto housed = database.QueryDatabase(fmt::format(
		"SELECT DISTINCT p.door_id FROM nms_plot p JOIN nms_neighborhood n ON n.id = p.neighborhood_id "
		"WHERE n.zone = '{}' AND p.house_item_id > 0 "
		"  AND (p.owner_char_id = {} OR (p.owner_guild_id > 0 AND p.owner_guild_id = {}))",
		Strings::Escape(zone_name), CharacterID(), GuildID()
	));

	if (housed.Success() && housed.RowCount()) {
		for (auto row : housed) {
			if (row[0]) {
				SendRealEstateItemList(this, Strings::ToUnsignedInt(row[0]));
			}
		}
	}
}

// Leaves a house interior. Retail houses have no doors on purpose -- you leave with the real
// estate window or the /leaverealestate command, which zones you back to the neighborhood just
// outside the plot. The client's own path is gated, so the server does the zoning.
//
// notify=false is the client packet path (0x1da9): the retail command fires from anywhere, and
// a chat line there would be noise on every unrelated use.
void HousingLeave(Client *c, bool notify)
{
	// The interior and the lot it belongs to; the exit point is that lot's door.
	auto home = database.QueryDatabase(fmt::format(
		"SELECT h.zone, COALESCE(n.zone, ''), COALESCE(d.pos_x, 0), COALESCE(d.pos_y, 0), "
		"       COALESCE(d.pos_z, 0), COALESCE(p.door_id, 0) "
		"FROM house h "
		"LEFT JOIN nms_plot p ON p.house_id = h.id "
		"LEFT JOIN nms_neighborhood n ON n.id = p.neighborhood_id "
		"LEFT JOIN doors d ON d.zone = n.zone AND d.doorid = p.door_id AND d.version = 0 "
		"WHERE h.char_id = {} LIMIT 1", c->CharacterID()
	));

	const std::string here = zone ? zone->GetShortName() : "";
	const bool in_interior = home.Success() && home.RowCount() && home.begin()[0] &&
		std::string(home.begin()[0]) == here;

	if (!in_interior) {
		if (notify) {
			c->Message(Chat::White, "[housing] you are not inside a house interior.");
		}
		return;
	}

	// Neighborhood safe point by default; the lot's front door when we can resolve it.
	float    sx = 2035.0f, sy = -3006.0f, sz = 4.0f;
	uint32_t zone_id = 712;

	auto nb = database.QueryDatabase(
		"SELECT safe_x, safe_y, safe_z, zoneidnumber FROM zone WHERE short_name = 'neighborhood' LIMIT 1");

	if (nb.Success() && nb.RowCount()) {
		auto row = nb.begin();
		sx = static_cast<float>(Strings::ToFloat(row[0] ? row[0] : "2035"));
		sy = static_cast<float>(Strings::ToFloat(row[1] ? row[1] : "-3006"));
		sz = static_cast<float>(Strings::ToFloat(row[2] ? row[2] : "4"));
		zone_id = Strings::ToUnsignedInt(row[3] ? row[3] : "712");
	}

	auto row = home.begin();

	const float door_x = static_cast<float>(Strings::ToFloat(row[2] ? row[2] : "0"));
	const float door_y = static_cast<float>(Strings::ToFloat(row[3] ? row[3] : "0"));
	const float door_z = static_cast<float>(Strings::ToFloat(row[4] ? row[4] : "0"));

	if (door_x != 0.0f || door_y != 0.0f) {
		sx = door_x;
		sy = door_y;
		sz = door_z;
	}

	if (notify) {
		c->Message(Chat::White, "[housing] returning to the neighborhood...");
	}

	LogInfo(
		"[Housing] [{}] leaving [{}] for the neighborhood at ({:.1f}, {:.1f}, {:.1f})",
		c->GetName(), here, sx, sy, sz
	);

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
		c->Message(Chat::White, "#housing item place <item_id> - place furniture from your inventory where you stand (inside your house)");
		c->Message(Chat::White, "#housing item remove <row_id|all> - pick placed furniture back up");
		c->Message(Chat::White, "#housing item list [door_id] - list placed furniture");
		c->Message(Chat::White, "#housing storage [door_id] - item totals and closet/shed/crate counts against the house's capacity");
		c->Message(Chat::White, "#housing withdraw <0 closet|1 shed|2 crate> <row|all> - take stored items back out");
		c->Message(Chat::White, "#housing anchor <0|1|2> [model] - record where a container's prop stands here");
		c->Message(Chat::White, "#housing anchors - list this zone's recorded container props");
		c->Message(Chat::White, "#housing placeable <item_id> [off] - allow/disallow an item as furniture");
		c->Message(Chat::White, "#housing exterior <door_id> [item_id] [model] - (re)send a lot's building world item");
		c->Message(Chat::White, "#housing areas <0-4> - resend the plot regions (0 both keys, 1 estate key, 2 area-id key, 3 player box, 4 world->local)");
		c->Message(Chat::White, "#housing send - re-send the real-estate identity packet");
		c->Message(Chat::White, "#housing send list - identity, then the neighborhood list");
		c->Message(Chat::White, "#housing send defs - real-estate definitions, then identity (experimental)");
		c->Message(Chat::White, "#housing enter - zone into your house interior");
		c->Message(Chat::White, "#housing leave - return from a house interior to the neighborhood");
		c->Message(Chat::White, "#housing retemplate <door_id> - rebuild the interior from the lot's building item");
		c->Message(Chat::White, "#housing plotsearch [mode] - send the plot-search window opener (0x2b35)");
		c->Message(Chat::White, "#housing guildplot <door_id> [off] - make a lot a guild plot");
		return;
	}

	const std::string sub  = sep->arg[1];
	const std::string zone_name = zone ? zone->GetShortName() : "";

	// Places a house item the character is carrying onto a lot: the item is consumed, the
	// lot is claimed, and the house row + interior instance persist. This is the
	// item-driven placement the client's own purchase window is meant to do.
	// The client's own Plot Search button takes the same path as the search request this
	// answers; the subcommand exists so the single-byte opener can be tested on its own.
	if (sub == "plotsearch") {
		const uint8_t mode = sep->IsNumber(2)
			? static_cast<uint8_t>(Strings::ToUnsignedInt(sep->arg[2]) & 0xFF)
			: 1;
		SendRealEstatePlotSearchOpen(c, mode);
		c->Message(Chat::White, "[housing] plot-search open sent with mode [{}].", mode);
		return;
	}

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

		AttachHouseToPlot(c, zone_name, door_id, item_id);

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

	// Interior furniture (v1). GM-driven placement: the client's own Place action needs the
	// item-metadata tail this tree does not emit yet. The item is consumed into
	// nms_house_item at the player's feet and drawn with the same ActorRecord the building
	// flow uses; pickup returns it to the inventory.
	if (sub == "item") {
		const std::string op = sep->arg[2] ? sep->arg[2] : "";

		if (op == "place" && sep->IsNumber(3)) {
			const uint32_t item_id = Strings::ToUnsignedInt(sep->arg[3]);

			uint32_t door_id = 0, nb_id = 0;

			if (!ResolveOwnedInterior(c, door_id, nb_id)) {
				c->Message(Chat::White, "[housing] stand inside your own house interior to place furniture.");
				return;
			}
			(void) nb_id;

			if (!IsPlaceableHousingItem(item_id)) {
				c->Message(
					Chat::White,
					fmt::format(
						"[housing] item [{}] is not on the placeable allowlist. "
						"Add it with #housing placeable <item_id> first.",
						item_id
					).c_str()
				);
				return;
			}

			if (!c->CountItem(item_id)) {
				c->Message(Chat::White, fmt::format("[housing] you are not carrying item [{}].", item_id).c_str());
				return;
			}

			auto model_row = database.QueryDatabase(fmt::format(
				"SELECT COALESCE(idfile, ''), COALESCE(Name, '') FROM items WHERE id = {} LIMIT 1", item_id
			));

			if (!model_row.Success() || !model_row.RowCount()) {
				c->Message(Chat::White, fmt::format("[housing] item [{}] does not exist.", item_id).c_str());
				return;
			}

			auto m = model_row.begin();
			const std::string model = (m[0] && *m[0]) ? m[0] : (m[1] ? m[1] : "");

			if (model.empty()) {
				c->Message(Chat::White, fmt::format("[housing] item [{}] has no idfile; nothing would draw.", item_id).c_str());
				return;
			}

			auto insert = database.QueryDatabase(fmt::format(
				"INSERT INTO nms_house_item "
				"(door_id, item_id, charges, pos_x, pos_y, pos_z, heading, pitch, roll, scale, placement_type, placed_by, placed_at) "
				"VALUES ({}, {}, 1, {}, {}, {}, {}, 0, 0, 1, 0, {}, NOW())",
				door_id, item_id, c->GetX(), c->GetY(), c->GetZ(), c->GetHeading(), c->CharacterID()
			));

			if (!insert.Success()) {
				c->Message(Chat::White, fmt::format("[housing] insert failed for item [{}].", item_id).c_str());
				return;
			}

			const uint32_t row_id = static_cast<uint32_t>(insert.LastInsertedID());

			// Consume only once the row exists.
			c->RemoveItem(item_id, 1);

			SendRealEstateFurnitureWorldItem(
				c, door_id, row_id, item_id, model, zone->GetZoneID(),
				c->GetX(), c->GetY(), c->GetZ(), c->GetHeading(), 1.0f
			);

			c->Message(
				Chat::White,
				fmt::format("[housing] placed item [{}] (row {}) in lot [{}]'s interior.", item_id, row_id, door_id).c_str()
			);
			return;
		}

		if (op == "remove") {
			uint32_t door_id = 0, nb_id = 0;

			if (!ResolveOwnedInterior(c, door_id, nb_id)) {
				c->Message(Chat::White, "[housing] stand inside your own house interior to pick furniture up.");
				return;
			}
			(void) nb_id;

			// "all" stows the whole interior; a number picks one row.
			if (sep->arg[3] && !strcasecmp(sep->arg[3], "all")) {
				auto rows = database.QueryDatabase(fmt::format(
					"SELECT id FROM nms_house_item WHERE door_id = {} ORDER BY id", door_id
				));

				if (!rows.Success() || !rows.RowCount()) {
					c->Message(Chat::White, "[housing] nothing is placed here.");
					return;
				}

				uint32_t stored = 0;
				uint32_t left   = 0;

				for (auto row : rows) {
					if (ReturnFurnitureRow(c, Strings::ToUnsignedInt(row[0]))) {
						++stored;
					}
					else {
						++left;
					}
				}

				c->Message(
					Chat::White,
					fmt::format(
						"[housing] stored [{}] item(s){}.",
						stored, left ? fmt::format("; [{}] left placed", left) : ""
					).c_str()
				);
				return;
			}

			if (sep->IsNumber(3)) {
				const uint32_t row_id = Strings::ToUnsignedInt(sep->arg[3]);

				if (!ReturnFurnitureRow(c, row_id)) {
					c->Message(Chat::White, fmt::format("[housing] row [{}] did not come back.", row_id).c_str());
					return;
				}

				c->Message(Chat::White, fmt::format("[housing] row [{}] picked up.", row_id).c_str());
				return;
			}

			c->Message(Chat::White, "[housing] usage: #housing item remove <row_id|all>");
			return;
		}

		if (op == "list") {
			uint32_t door_id = 0, nb_id = 0;

			// A door id answers from anywhere (GM inspection); without one the interior
			// the player stands in is used.
			if (sep->IsNumber(3)) {
				door_id = Strings::ToUnsignedInt(sep->arg[3]);
			}
			else if (!ResolveOwnedInterior(c, door_id, nb_id)) {
				c->Message(Chat::White, "[housing] stand inside your house interior or pass a door id.");
				return;
			}
			(void) nb_id;

			auto rows = database.QueryDatabase(fmt::format(
				"SELECT f.id, f.item_id, COALESCE(it.Name, ''), f.pos_x, f.pos_y, f.pos_z, f.heading "
				"FROM nms_house_item f LEFT JOIN items it ON it.id = f.item_id "
				"WHERE f.door_id = {} ORDER BY f.id", door_id
			));

			if (!rows.Success() || !rows.RowCount()) {
				c->Message(Chat::White, fmt::format("[housing] lot [{}] has no furniture placed.", door_id).c_str());
				return;
			}

			for (auto row : rows) {
				c->Message(
					Chat::White,
					fmt::format(
						"[housing] row [{}] item [{}] '{}' at ({:.1f}, {:.1f}, {:.1f}) heading {:.1f}",
						Strings::ToUnsignedInt(row[0]), Strings::ToUnsignedInt(row[1]),
						row[2] ? row[2] : "",
						Strings::ToFloat(row[3] ? row[3] : "0"), Strings::ToFloat(row[4] ? row[4] : "0"),
						Strings::ToFloat(row[5] ? row[5] : "0"), Strings::ToFloat(row[6] ? row[6] : "0")
					).c_str()
				);
			}
			return;
		}

		c->Message(Chat::White, "[housing] usage: #housing item place <item_id> | item remove <row_id|all> | item list [door_id]");
		return;
	}

	// Container status: what the lot holds and what its capacity profile allows.
	if (sub == "storage") {
		uint32_t door_id = 0;

		if (sep->IsNumber(2)) {
			door_id = Strings::ToUnsignedInt(sep->arg[2]);
		}
		else {
			uint32_t nb_id = 0;
			if (!ResolveOwnedInterior(c, door_id, nb_id)) {
				const auto plot = FindNearestPlot(zone_name, c->GetX(), c->GetY());
				if (plot.found) {
					door_id = plot.door_id;
				}
			}
		}

		if (!door_id) {
			c->Message(Chat::White, "[housing] storage needs a door id, or stand on the lot / in your interior.");
			return;
		}

		const HouseCapacity cap = LoadHouseCapacity(PlotHouseDefinition(door_id));

		c->Message(
			Chat::White,
			fmt::format(
				"[housing] lot [{}]: [{}]/[{}] items total; closet [{}]/[{}], shed [{}], crate [{}].",
				door_id, PlotItemCount(door_id, -2), cap.max_items,
				PlotItemCount(door_id, kContainerCloset), cap.max_vault,
				PlotItemCount(door_id, kContainerShed), PlotItemCount(door_id, kContainerCrate)
			).c_str()
		);
		return;
	}

	// Takes items back out of a container. ReturnFurnitureRow gives the item to the character
	// and retires the row, which is the only custody direction the row table can express.
	if (sub == "withdraw" && sep->IsNumber(2)) {
		const int container = Strings::ToInt(sep->arg[2]);

		if (container < kContainerCloset || container > kContainerCrate) {
			c->Message(Chat::White, "[housing] withdraw <0 closet|1 shed|2 crate> <row|all>");
			return;
		}

		uint32_t door_id = 0;
		uint32_t nb_id   = 0;

		if (!ResolveOwnedInterior(c, door_id, nb_id)) {
			const auto plot = FindNearestPlot(zone_name, c->GetX(), c->GetY());
			if (plot.found && (plot.owner_char_id == c->CharacterID() ||
			                   (plot.owner_guild_id && plot.owner_guild_id == c->GuildID()))) {
				door_id = plot.door_id;
			}
		}

		if (!door_id) {
			c->Message(Chat::White, "[housing] stand on your lot or in your interior to withdraw.");
			return;
		}

		const bool all = sep->arg[3] && std::string(sep->arg[3]) == "all";

		auto rows = database.QueryDatabase(all
			? fmt::format("SELECT id FROM nms_house_item WHERE door_id = {} AND container = {} ORDER BY id", door_id, container)
			: fmt::format("SELECT id FROM nms_house_item WHERE door_id = {} AND container = {} AND id = {} LIMIT 1",
				door_id, container, sep->IsNumber(3) ? Strings::ToUnsignedInt(sep->arg[3]) : 0)
		);

		uint32_t taken = 0;

		if (rows.Success()) {
			for (auto row : rows) {
				if (ReturnFurnitureRow(c, Strings::ToUnsignedInt(row[0]))) {
					++taken;
				}
			}
		}

		c->Message(
			Chat::White,
			fmt::format("[housing] withdrew [{}] item(s) from the {}.", taken, ContainerName(container)).c_str()
		);

		SendRealEstateItemList(c, door_id);
		return;
	}

	// Records where a container's physical prop stands in this zone. The retail bag/box models
	// are client-side geometry the server cannot move, so the anchor is the link between the
	// model the player sees and the storage the server keeps.
	if (sub == "anchor" && sep->IsNumber(2)) {
		const int container = Strings::ToInt(sep->arg[2]);

		if (container < kContainerCloset || container > kContainerCrate) {
			c->Message(Chat::White, "[housing] anchor <0 closet|1 shed|2 crate> [model]");
			return;
		}

		const std::string model = sep->arg[3] ? sep->arg[3] : "";

		database.QueryDatabase(fmt::format(
			"INSERT INTO nms_house_container_anchor (zone, container, x, y, z, heading, model) "
			"VALUES ('{}', {}, {}, {}, {}, {}, '{}') "
			"ON DUPLICATE KEY UPDATE x = VALUES(x), y = VALUES(y), z = VALUES(z), "
			"heading = VALUES(heading), model = VALUES(model)",
			Strings::Escape(zone_name), container, c->GetX(), c->GetY(), c->GetZ(), c->GetHeading(),
			Strings::Escape(model)
		));

		c->Message(
			Chat::White,
			fmt::format(
				"[housing] {} anchor in [{}] at ({:.1f}, {:.1f}, {:.1f}).",
				ContainerName(container), zone_name, c->GetX(), c->GetY(), c->GetZ()
			).c_str()
		);
		return;
	}

	if (sub == "anchors") {
		auto rows = database.QueryDatabase(fmt::format(
			"SELECT container, x, y, z, model FROM nms_house_container_anchor WHERE zone = '{}' ORDER BY container",
			Strings::Escape(zone_name)
		));

		if (!rows.Success() || !rows.RowCount()) {
			c->Message(Chat::White, fmt::format("[housing] no anchors recorded in [{}].", zone_name).c_str());
			return;
		}

		for (auto row : rows) {
			c->Message(
				Chat::White,
				fmt::format(
					"[housing] {} at ({:.1f}, {:.1f}, {:.1f}) model [{}]",
					ContainerName(Strings::ToInt(row[0] ? row[0] : "0")),
					Strings::ToFloat(row[1] ? row[1] : "0"),
					Strings::ToFloat(row[2] ? row[2] : "0"),
					Strings::ToFloat(row[3] ? row[3] : "0"),
					row[4] ? row[4] : ""
				).c_str()
			);
		}
		return;
	}

	// Re-derives the interior from the lot's recorded building item. Heals lots bought before
	// the house-template table existed (and any lot whose house row says the wrong zone).
	if (sub == "retemplate" && sep->IsNumber(2)) {
		const uint32_t door_id = Strings::ToUnsignedInt(sep->arg[2]);

		auto lot = database.QueryDatabase(fmt::format(
			"SELECT p.house_item_id FROM nms_plot p JOIN nms_neighborhood n ON n.id = p.neighborhood_id "
			"WHERE n.zone = '{}' AND p.door_id = {} "
			"  AND (p.owner_char_id = {} OR (p.owner_guild_id > 0 AND p.owner_guild_id = {})) "
			"LIMIT 1",
			Strings::Escape(zone->GetShortName()), door_id, c->CharacterID(), c->GuildID()
		));

		const uint32_t house_item = (lot.Success() && lot.RowCount() && lot.begin()[0])
			? Strings::ToUnsignedInt(lot.begin()[0]) : 0;

		if (!house_item) {
			c->Message(Chat::White, "[housing] that lot records no building item, or it is not yours.");
			return;
		}

		AttachHouseToPlot(c, zone->GetShortName(), door_id, house_item);

		auto after = database.QueryDatabase(fmt::format(
			"SELECT COALESCE(p.house_zone, ''), COALESCE(h.instance_id, 0) "
			"FROM nms_plot p LEFT JOIN house h ON h.id = p.house_id WHERE p.door_id = {} LIMIT 1",
			door_id
		));

		if (after.Success() && after.RowCount()) {
			auto row = after.begin();
			c->Message(
				Chat::White,
				fmt::format(
					"[housing] lot [{}] now opens [{}] (instance [{}]).",
					door_id, row[0] ? row[0] : "", row[1] ? row[1] : "0"
				).c_str()
			);
		}
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
		struct HouseRow {
			std::string id;
			std::string instance;
			std::string zone;
		};

		auto find_house = [&]() -> HouseRow {
			HouseRow out;

			auto house = database.QueryDatabase(fmt::format(
				"SELECT id, instance_id, zone FROM house WHERE char_id = {} LIMIT 1",
				c->CharacterID()
			));

			if (house.Success() && house.RowCount()) {
				auto row     = house.begin();
				out.id       = row[0] ? row[0] : "0";
				out.instance = row[1] ? row[1] : "0";
				out.zone     = row[2] ? row[2] : "";
			}

			return out;
		};

		HouseRow house = find_house();

		// The lot's building decides the interior. Reconcile here too, so a house bought
		// before the template table (or a building placed after the row) enters the right zone.
		auto lot = database.QueryDatabase(fmt::format(
			"SELECT n.zone, p.door_id, p.house_item_id FROM nms_plot p "
			"JOIN nms_neighborhood n ON n.id = p.neighborhood_id "
			"WHERE p.house_item_id > 0 "
			"  AND (p.owner_char_id = {} OR (p.owner_guild_id > 0 AND p.owner_guild_id = {})) "
			"LIMIT 1",
			c->CharacterID(), c->GuildID()
		));

		if (lot.Success() && lot.RowCount() && lot.begin()[2] &&
		    Strings::ToUnsignedInt(lot.begin()[2]) != 0) {
			AttachHouseToPlot(
				c,
				lot.begin()[0] ? lot.begin()[0] : "",
				Strings::ToUnsignedInt(lot.begin()[1] ? lot.begin()[1] : "0"),
				Strings::ToUnsignedInt(lot.begin()[2])
			);

			house = find_house();
		}

		if (house.id.empty() || house.id == "0") {
			c->Message(Chat::White, "[housing] you do not own a house.");
			return;
		}

		const uint32_t instance_id = Strings::ToUnsignedInt(house.instance);

		if (!instance_id) {
			c->Message(Chat::White, "[housing] your house has no interior instance.");
			return;
		}

		c->Message(
			Chat::White,
			fmt::format(
				"[housing] entering house #{} in [{}] instance [{}]...",
				house.id, house.zone, instance_id
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

	// Furniture allowlist. Placement is allowlist-gated, so this is the switch that makes an
	// item placeable at all; there is no itemtype or name heuristic behind it.
	if (sub == "placeable" && sep->IsNumber(2)) {
		const uint32_t item_id = Strings::ToUnsignedInt(sep->arg[2]);
		const bool     on      = !(sep->arg[3] && !strcasecmp(sep->arg[3], "off"));

		if (on) {
			auto exists = database.QueryDatabase(fmt::format(
				"SELECT 1 FROM items WHERE id = {} LIMIT 1", item_id
			));

			if (!exists.Success() || !exists.RowCount()) {
				c->Message(Chat::White, fmt::format("[housing] item [{}] does not exist.", item_id).c_str());
				return;
			}

			database.QueryDatabase(fmt::format(
				"INSERT IGNORE INTO nms_housing_placeable (item_id, added_by, added_at) VALUES ({}, {}, NOW())",
				item_id, c->CharacterID()
			));

			c->Message(Chat::White, fmt::format("[housing] item [{}] is now placeable furniture.", item_id).c_str());
		}
		else {
			auto r = database.QueryDatabase(fmt::format(
				"DELETE FROM nms_housing_placeable WHERE item_id = {}", item_id
			));

			c->Message(
				Chat::White,
				fmt::format(
					"[housing] item [{}] placeability {}.",
					item_id, (r.Success() && r.RowsAffected()) ? "removed" : "was not set"
				).c_str()
			);
		}
		return;
	}

	c->Message(Chat::White, "[housing] unknown sub-command. Try #housing list.");
}
