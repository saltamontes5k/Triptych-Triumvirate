#pragma once

// Nethack-style starvation hunger clock, gated by the Custom:StarvationDeath
// rule family (common/ruletypes.h). Client::ProcessStarvation() runs on the
// consumption tick (client_process.cpp, right after DoStaminaHungerUpdate) and
// advances the phase machine; per-character progress persists in the
// "NMSStarvation" data bucket so logout, zone changes, and process restarts
// never reset the clock.
//
// Timeline at the shipped defaults: the clock arms when a counter crosses the
// hungry/thirsty line (<=3000 — the same point the client warns), ~2.6 real
// hours from full (monks decay at half speed, so ~5.1 hours), then the debuff
// lands 2 EQ game days later and the death touch at 3. A resurrect buys 1 EQ
// game day before it kills again.
//
// The debuff spell (all-stat drain + crawl snare) is minted by manifest v355
// into spells_new id 44036 and reaches zone processes through the shared spell
// segments; until that row is live the clock logs a warning and still kills.

#include <cstdint>

namespace NMSStarvation {
	constexpr uint16 DebuffSpellId = 44036; // band 44000-44035 in use, client ceiling 45000
	constexpr const char *BucketKey = "NMSStarvation";
	// Real-ms gaps larger than this (logout, process restart) credit nothing:
	// the clock only runs while the client is alive in a zone.
	constexpr uint64 GapClampMs = 600000;

	// The arm condition must hold this many consecutive consumption ticks before
	// a fresh bucket is created. The hungry/thirsty line (<=3000) is also where
	// the client's auto-consume tops a fed player back up (stat food is
	// feast-grade, +6000 to +7100 a bite), so fed players sit at the line for
	// only 1-3 ticks; an actually unfed player sits there for hundreds. A
	// bucket that already exists (an accrued curse) is never delayed by this.
	constexpr uint8 ArmConfirmTicks = 5;

	enum Phase : int {
		Sated = 0,  // no bucket, or reset after eating and drinking
		Streak = 1, // hungry or thirsty; clock running toward the debuff and the DT
		Grace = 2,  // post-DT window; eating and drinking at any point resets all
	};

	struct State {
		int phase = Sated;
		uint64 starved_ms = 0;
		uint64 grace_ms = 0;
		int dt_count = 0;
		uint64 last_tick_ms = 0;
	};
}
