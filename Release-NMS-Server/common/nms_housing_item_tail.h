#ifndef EQS_NMS_HOUSING_ITEM_TAIL_H
#define EQS_NMS_HOUSING_ITEM_TAIL_H
// RoF2 housing item tail: the 72-byte block the client's item reader takes after the 96-byte
// quaternary head (Housing::ItemWire::EncodeTail, nightstalker6669/EQEmu).
//
// Why this exists: the RoF2 item reader (eqgame sub_7F6BF0) is a bounded cursor, not a framed
// record -- it reads field after field against the packet length and zero-fills whatever is
// missing. So a body that stops early is accepted silently with those fields zeroed, and a body
// with a block appended AFTER its own bytes shifts the reader (commit a0a64bb0 measured exactly
// that: 43 records x 72 bytes of drift, every bag slot empty). The only correct shape is the
// client's own: write 96 bytes of head, then this tail, and stop.
//
// Scope: applied only to the reviewed trophy sources below. Every other item keeps the historic
// 171-byte body, so a wrong guess here cannot touch ordinary gear or bank contents.
#include <cstdint>
#include <cstring>
#include <vector>

namespace NmsHousingItemTail {

// Placed trophy -> wire benefit id. Mirrors nms_housing_trophy_benefits.placed_item_id /
// benefit_id (v478 catalogue). Compile-time on purpose: SerializeItem runs for every item
// packet and must not touch the database.
struct TrophySource {
	uint32_t item_id;
	uint32_t benefit_id;
};

inline constexpr TrophySource kTrophySources[] = {
	{ 52999,   90 },
	{ 60972,   91 },
	{ 60973,   92 },
	{ 60974,   93 },
	{ 64586,   94 },
	{ 67913,   95 },
	{ 1067913, 96 },
	{ 2067913, 97 },
	{ 68727,  213 },
	{ 68730,  216 },
};

inline bool TrophyBenefit(uint32_t item_id, uint32_t &benefit_out)
{
	for (const auto &entry : kTrophySources) {
		if (entry.item_id == item_id) {
			benefit_out = entry.benefit_id;
			return true;
		}
	}

	return false;
}

inline void U32(std::vector<uint8_t> &out, uint32_t value)
{
	for (unsigned i = 0; i < 4; ++i) {
		out.push_back(static_cast<uint8_t>(value >> (8 * i)));
	}
}

inline void F32(std::vector<uint8_t> &out, float value)
{
	uint32_t bits = 0;
	std::memcpy(&bits, &value, 4);
	U32(out, bits);
}

// The reviewed placement profile of the physical trophies (personal_trophy_placement.json):
// mask 12, ignore-collisions 0, floor type 0, scales 0.1-2.5, upkeep id 4, max 1 per estate.
// Every remaining field is the zero/one default upstream sends for a trophy that carries no
// pet, no sockets and no estate restriction.
inline std::vector<uint8_t> EncodeTrophy(uint32_t benefit_id)
{
	std::vector<uint8_t> out;
	out.reserve(72);

	U32(out, 12);            // placeable mask
	out.push_back(0);        // ignore collisions
	U32(out, 0);             // placement type: floor
	U32(out, 0);             // definition id
	F32(out, 0.1f);          // minimum scale (UNK228)
	F32(out, 2.5f);          // maximum scale (UNK229)
	U32(out, 4);             // upkeep id
	U32(out, 1);             // max per estate
	out.push_back(0);        // housepet filename: empty
	out.push_back(0);        // interactive
	U32(out, benefit_id);    // trophy benefit id -- the field the window keys on
	out.push_back(0);        // disable rotation
	out.push_back(0);        // disable free placement
	U32(out, 0);             // respawn interval
	F32(out, 1.0f);          // default scale
	F32(out, 0.0f);          // default heading
	F32(out, 0.0f);          // default pitch
	F32(out, 0.0f);          // default roll
	out.push_back(0);        // socket count
	out.push_back(0);        // collectible
	out.push_back(0);        // no destroy
	out.push_back(0);        // marketplace
	out.push_back(0);        // no zone
	U32(out, 0);             // maker id
	out.push_back(0);        // no ground
	U32(out, 0);             // estate id count
	out.push_back(1);        // instance placeable

	return out;
}

} // namespace NmsHousingItemTail
#endif
