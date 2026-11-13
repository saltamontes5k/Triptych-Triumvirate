#include "../common/global_define.h"
#include "nms_starvation.h"

#include "../common/eqemu_logsys.h"
#include "../common/eq_constants.h"
#include "../common/rulesys.h"
#include "../common/spdat.h"
#include "../common/strings.h"
#include "client.h"
#include "common.h"
#include "entity.h"
#include "zone.h"

#include <chrono>
#include <cstdlib>
#include <fmt/format.h>

extern Zone* zone;

namespace {

	// 1 EQ minute = 3 real seconds (common/eqtime.cpp), so 1 EQ game day
	// (1440 EQ minutes) = 72 real minutes.
	uint64 EqMinutesToMs(int64 eq_minutes)
	{
		return static_cast<uint64>(eq_minutes < 0 ? 0 : eq_minutes) * 3000ULL;
	}

	uint64 SteadyNowMs()
	{
		return static_cast<uint64>(
			std::chrono::duration_cast<std::chrono::milliseconds>(
				std::chrono::steady_clock::now().time_since_epoch()
			).count()
		);
	}

	bool ParseState(const std::string &raw, NMSStarvation::State &out)
	{
		out = {};
		if (raw.empty()) {
			return true; // absent bucket = sated
		}

		const auto parts = Strings::Split(raw, '|');
		if (parts.size() < 5) {
			return false;
		}

		out.phase        = static_cast<int>(std::strtol(parts[0].c_str(), nullptr, 10));
		out.starved_ms   = std::strtoull(parts[1].c_str(), nullptr, 10);
		out.grace_ms     = std::strtoull(parts[2].c_str(), nullptr, 10);
		out.dt_count     = static_cast<int>(std::strtol(parts[3].c_str(), nullptr, 10));
		out.last_tick_ms = std::strtoull(parts[4].c_str(), nullptr, 10);

		return out.phase >= NMSStarvation::Phase::Sated && out.phase <= NMSStarvation::Phase::Grace;
	}

	std::string EncodeState(const NMSStarvation::State &state)
	{
		return fmt::format("{}|{}|{}|{}|{}", state.phase, state.starved_ms, state.grace_ms, state.dt_count, state.last_tick_ms);
	}

	void LogMissingSpellOnce()
	{
		static bool warned = false;
		if (!warned && !IsValidSpell(NMSStarvation::DebuffSpellId)) {
			warned = true;
			LogInfo("[NMSStarvation] debuff spell [{}] is missing: manifest v355 has not run or the shared spell segments predate it. The hunger clock still kills, but there is no debuff/snare warning.", NMSStarvation::DebuffSpellId);
		}
	}

	// Keeps the starvation debuff up while the clock runs past the debuff
	// threshold: refresh the duration if it is held, take hold otherwise. A
	// stronger snare on the target or a full buff list blocks the take hold for
	// that tick (no "did not take hold" spam); the next tick retries.
	void ApplyOrRefreshStarvationDebuff(Client *c, bool announce)
	{
		LogMissingSpellOnce();

		auto *buffs = c->GetBuffs();
		const int buff_count = c->GetMaxTotalSlots();
		for (int slot = 0; slot < buff_count; ++slot) {
			if (buffs[slot].spellid != NMSStarvation::DebuffSpellId) {
				continue;
			}

			const uint32 full_tics = static_cast<uint32>(c->CalcBuffDuration(c, c, NMSStarvation::DebuffSpellId));
			if (full_tics > 0 && buffs[slot].ticsremaining < full_tics) {
				buffs[slot].ticsremaining = full_tics;
				c->SendBuffDurationPacket(buffs[slot], slot);
			}
			return;
		}

		if (c->CanBuffStack(NMSStarvation::DebuffSpellId, c->GetCasterLevel(NMSStarvation::DebuffSpellId)) >= 0) {
			c->ApplySpellBuff(NMSStarvation::DebuffSpellId, 0);
			if (announce) {
				const bool hungry = c->Hungry();
				const bool thirsty = c->Thirsty();
				if (thirsty && !hungry) {
					c->Message(Chat::Red, "Thirst breaks your body. Your strength drains away and you can barely crawl. Drink before you die of dehydration.");
				} else if (hungry && thirsty) {
					c->Message(Chat::Red, "Hunger and thirst break your body. Your strength drains away and you can barely crawl. Eat and drink before you starve to death.");
				} else {
					c->Message(Chat::Red, "Hunger breaks your body. Your strength drains away and you can barely crawl. Eat and drink before you starve to death.");
				}
			}
		}
	}

	// System death: killer_mob is null so $killer_id is 0 and killer-keyed quest
	// scripts (slay credit, attribution emotes) can never misfire on it. Goes
	// through EVENT_DEATH like every other death, so house death rules apply.
	// Flavor follows the counter that is actually depleted: a character who
	// kept eating but never drank died of dehydration, not starvation.
	void StarvationDeathTouch(Client *c)
	{
		const bool hungry = c->Hungry();
		const bool thirsty = c->Thirsty();
		if (thirsty && !hungry) {
			c->Message(Chat::Red, "Your parched body finally gives out. You have died of dehydration.");
			c->Message(Chat::Yellow, "You have one game day to drink before dehydration takes you again.");
		} else if (hungry && thirsty) {
			c->Message(Chat::Red, "Your starved, parched body finally gives out. You have died of hunger and thirst.");
			c->Message(Chat::Yellow, "You have one game day to eat and drink before it takes you again.");
		} else {
			c->Message(Chat::Red, "Your starved body finally gives out. You have died of starvation.");
			c->Message(Chat::Yellow, "You have one game day to eat and drink before starvation takes you again.");
		}
		c->Death(nullptr, 0, SPELL_UNKNOWN, EQ::skills::SkillHandtoHand, KilledByTypes::Killed_NPC, false);
	}

} // namespace

void Client::ProcessStarvation()
{
	if (!RuleB(Custom, StarvationDeath)) {
		return;
	}

	// Fail-closed on the Character food rules: both IsStarved() (the anchor
	// below) and the regen stop they gate are inert while either is false, so
	// warn once per zone process instead of dying silently.
	static bool warned_inert = false;
	if (!RuleB(Character, EnableFoodRequirement) || !RuleB(Character, EnableHungerPenalties)) {
		if (!warned_inert) {
			warned_inert = true;
			LogInfo("[NMSStarvation] Custom:StarvationDeath needs Character:EnableFoodRequirement and Character:EnableHungerPenalties to be true; the hunger clock is inert until both are set.");
		}
		return;
	}

	// Mirrors DoStaminaHungerUpdate's exemptions (client_process.cpp): GMs and
	// the Bazaar never accrue hunger, so they never accrue the clock.
	if (dead || GetGM() || !zone || zone->GetZoneID() == Zones::BAZAAR) {
		return;
	}
	if (GetLevel() < RuleI(Custom, StarvationDeathMinLevel)) {
		return;
	}

	NMSStarvation::State state;
	const bool valid = ParseState(GetBucket(NMSStarvation::BucketKey), state);
	if (!valid) {
		state = {}; // garbled bucket: start clean rather than guess
	}

	// The clock arms at the hungry/thirsty line (<=3000) — the same point the
	// client starts warning "You are hungry/thirsty" — not at absolute zero, so
	// the consequences land within a play session of neglecting food or drink.
	// True zero still gates the stock regen stop via IsStarved().
	if (!Hungry() && !Thirsty()) {
		m_starvation_arm_ticks = 0;
		if (state.phase != NMSStarvation::Phase::Sated) {
			DeleteBucket(NMSStarvation::BucketKey);
			BuffFadeBySpellID(NMSStarvation::DebuffSpellId);
			Message(Chat::Yellow, "Food and drink restore you. The starvation curse lifts.");
		}
		return;
	}

	// Arm confirmation: the hungry/thirsty line is also where the client's
	// auto-consume bounces a fed player back above it (stat food is feast-grade,
	// +6000 to +7100 a bite), so a fed character sits at or under the line for
	// only a tick or two. Require the condition to hold for several consecutive
	// ticks before creating a fresh bucket; an existing bucket (a curse already
	// accrued) is never delayed by this.
	if (state.phase == NMSStarvation::Phase::Sated) {
		if (++m_starvation_arm_ticks < NMSStarvation::ArmConfirmTicks) {
			return;
		}
	} else {
		m_starvation_arm_ticks = 0;
	}

	// Real elapsed ms since the previous consumption tick. A gap larger than
	// GapClampMs means this client was not being processed (logged out, zone
	// boot, process restart): that time never counts toward the clock.
	const uint64 now_ms = SteadyNowMs();
	uint64 delta_ms = 0;
	if (state.last_tick_ms != 0 && now_ms > state.last_tick_ms) {
		delta_ms = now_ms - state.last_tick_ms;
		if (delta_ms > NMSStarvation::GapClampMs) {
			delta_ms = 0;
		}
	}
	state.last_tick_ms = now_ms;

	if (state.phase == NMSStarvation::Phase::Sated) {
		state.phase = NMSStarvation::Phase::Streak;
	}

	if (state.phase == NMSStarvation::Phase::Streak) {
		state.starved_ms += delta_ms;

		const int debuff_minutes = RuleI(Custom, StarvationDebuffEQMinutes);
		if (debuff_minutes > 0 && state.starved_ms >= EqMinutesToMs(debuff_minutes)) {
			ApplyOrRefreshStarvationDebuff(this, true);
		}

		const int death_minutes = RuleI(Custom, StarvationDeathEQMinutes);
		if (death_minutes > 0 && state.starved_ms >= EqMinutesToMs(death_minutes)) {
			state.phase = NMSStarvation::Phase::Grace;
			state.grace_ms = 0;
			state.dt_count += 1;
			SetBucket(NMSStarvation::BucketKey, EncodeState(state));
			StarvationDeathTouch(this);
			return;
		}
	} else { // Grace
		state.grace_ms += delta_ms;
		ApplyOrRefreshStarvationDebuff(this, false);

		const int grace_minutes = RuleI(Custom, StarvationResGraceEQMinutes);
		const int max_deaths = RuleI(Custom, StarvationMaxGraceDeaths);
		const bool under_cap = max_deaths <= 0 || state.dt_count < max_deaths;
		if (grace_minutes > 0 && under_cap && state.grace_ms >= EqMinutesToMs(grace_minutes)) {
			state.grace_ms = 0;
			state.dt_count += 1;
			SetBucket(NMSStarvation::BucketKey, EncodeState(state));
			StarvationDeathTouch(this);
			return;
		}
	}

	SetBucket(NMSStarvation::BucketKey, EncodeState(state));
}
