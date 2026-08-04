#include "../../common/eqemu_logsys.h"
#include "../../common/platform.h"
#include "../../zone.h"
#include "../../client.h"
#include "../../common/net/eqstream.h"

extern Zone *zone;

// NOTE: HandinEntry / HandinMoney / Handin / SerializeHandin / RunSerializedTest are defined in
// npc_handins.cpp, which zone_cli.cpp includes immediately before this file. Do not redeclare them
// here - a local shadow would not be the type SerializeHandin() takes.

// ---------------------------------------------------------------------------------------------
// Banking tests.
//
// A multi-quest NPC keeps ("banks") the items handed to it so several players can each contribute
// part of a requirement. NPC::CheckHandin decides what to bank by setting HandinEntry::is_multiquest_item;
// NPC::ReturnHandinItems then hands back everything NOT flagged. So the flag is the whole ballgame:
// flagged => stays on the NPC, unflagged => bounces straight back to the player's cursor.
//
// These tests assert on the bucket (NPC::GetHandin()) AFTER the return pass, because that is the
// thing that actually matters. Note ReturnHandinItems' RETURN VALUE is a snapshot of the bucket taken
// BEFORE it erases anything, so it still lists banked items - it cannot be used to tell the two apart.
//
// Fixture items (verified present in the items table):
//   12268   Ring of the Ancients
//   1012268 Ring of the Ancients (Enchanted)   <- 12268 + 1,000,000, the NMS tier-1 id scheme
//   7100    Shadowed Rapier
//   13073   Bone Chips (stackable, stacksize 100)
//   1001    Cloth Cap (used as the "matches nothing" item)
// ---------------------------------------------------------------------------------------------
struct MQBankCase {
	std::string                          description;
	std::vector<std::pair<std::string, uint32>> hand_in;   // item_id -> count handed to the NPC
	std::map<std::string, uint32>        required;         // the quest's full requirement
	bool                                 expect_handin_met;
	std::vector<std::string>             expect_banked;    // item ids still on the NPC afterwards
};

static void RunMultiQuestBankingTests(Client *c, const NPCType *npc_type)
{
	const std::vector<MQBankCase> cases = {
		// Baseline. A plain partial contribution has always banked; this guards against a regression.
		MQBankCase{
			.description       = "Banks a partial base-item contribution",
			.hand_in           = {{"12268", 1}},
			.required          = {{"12268", 1}, {"7100", 1}},
			.expect_handin_met = false,
			.expect_banked     = {"12268"},
		},

		// THE FIX. An Enchanted item is base_id + 1,000,000. CheckHandin's fulfilment check normalises
		// (id % 1000000), so a tiered item has always been able to COMPLETE a quest - but the flagging
		// loop compared the raw id string, so "1012268" != "12268" and it was never BANKED. The player
		// watched it bounce back to their cursor and assumed the NPC did not want it.
		MQBankCase{
			.description       = "Banks an ENCHANTED item toward a base-item requirement",
			.hand_in           = {{"1012268", 1}},
			.required          = {{"12268", 1}, {"7100", 1}},
			.expect_handin_met = false,
			.expect_banked     = {"1012268"},
		},

		// THE FIX, second half. The flagging loop demanded an exact count match, so a partial stack -
		// the entire point of a multi-quest - was never banked.
		MQBankCase{
			.description       = "Banks a PARTIAL STACK (4 of a required 10)",
			.hand_in           = {{"13073", 4}},
			.required          = {{"13073", 10}},
			.expect_handin_met = false,
			.expect_banked     = {"13073"},
		},

		// Safety net for the fix: relaxing the predicate must NOT start swallowing items the quest
		// never asked for. An item matching no requirement has to go back to the player.
		MQBankCase{
			.description       = "Returns an item that matches NO requirement (does not bank it)",
			.hand_in           = {{"1001", 1}},
			.required          = {{"12268", 1}},
			.expect_handin_met = false,
			.expect_banked     = {},
		},

		// Two players each contributing a different required item is the core multi-quest flow.
		MQBankCase{
			.description       = "Banks contributions from two separate hand-ins",
			.hand_in           = {{"12268", 1}, {"7100", 1}},
			.required          = {{"12268", 1}, {"7100", 1}, {"13073", 10}},
			.expect_handin_met = false,
			.expect_banked     = {"12268", "7100"},
		},
	};

	for (const auto &tc : cases) {
		// A fresh NPC per case. The bucket deliberately survives ResetHandin() on a multi-quest NPC,
		// so reusing one NPC would leak banked items from the previous case into the next.
		auto npc = new NPC(npc_type, nullptr, glm::vec4(0, 0, 0, 0), GravityBehavior::Water);
		entity_list.AddNPC(npc);
		npc->MultiQuestEnable();

		std::map<std::string, uint32>   hand_ins;
		std::vector<EQ::ItemInstance *> items;

		for (const auto &h : tc.hand_in) {
			EQ::ItemInstance *inst = database.CreateItem(Strings::ToInt(h.first));
			if (!inst) {
				std::cerr << "[❌] " << tc.description << " FAILED (fixture item " << h.first
						  << " does not exist in the items table)\n";
				std::exit(1);
			}
			if (inst->IsStackable()) {
				inst->SetCharges(h.second);
			}
			hand_ins[h.first] = inst->GetCharges() > 0 ? inst->GetCharges() : h.second;
			items.push_back(inst);
		}

		const bool met = npc->CheckHandin(c, hand_ins, tc.required, items);
		RunTest(tc.description + " (hand-in met?)", tc.expect_handin_met, met);

		npc->ReturnHandinItems(c);

		// Whatever is still on the NPC was banked; everything else went back to the player.
		std::map<std::string, uint32> banked;
		for (const auto &i : npc->GetHandin().items) {
			banked[i.item_id] += 1;
		}
		std::map<std::string, uint32> expected;
		for (const auto &id : tc.expect_banked) {
			expected[id] += 1;
		}

		HandinMoney no_money{};
		RunSerializedTest(
			tc.description + " (banked on NPC)",
			SerializeHandin(expected, no_money),
			SerializeHandin(banked, no_money)
		);

		npc->ResetHandin();
	}
}

void ZoneCLI::TestNpcHandinsMultiQuest(int argc, char **argv, argh::parser &cmd, std::string &description)
{
	if (cmd[{"-h", "--help"}]) {
		return;
	}

	uint32 break_length = 50;
	int    failed_count = 0;

	EQEmuLogSys::Instance()->SilenceConsoleLogging();

	Zone::Bootup(ZoneID("qrg"), 0, false);
	zone->StopShutdownTimer();

	entity_list.Process();
	entity_list.MobProcess();

	std::cout << "===========================================\n";
	std::cout << "⚙️> Running Hand-in Tests (Multi-Quest)...\n";
	std::cout << "===========================================\n\n";

	Client *c       = new Client();
	auto   npc_type = content_db.LoadNPCTypesData(754008);
	if (npc_type) {
		auto npc = new NPC(
			npc_type,
			nullptr,
			glm::vec4(0, 0, 0, 0),
			GravityBehavior::Water
		);

		entity_list.AddNPC(npc);
		npc->MultiQuestEnable();

		struct TestCase {
			std::string description = "";
			Handin      hand_in;
			Handin      required;
			Handin      returned;
			bool        handin_check_result;
		};

		std::vector<TestCase> test_cases = {
			TestCase{
				.description = "Journeyman's Boots",
				.hand_in = {
					.items = {
						HandinEntry{.item_id = "12268", .count = 1},
						HandinEntry{.item_id = "7100", .count = 1},
					},
					.money = {.platinum = 325},
				},
				.required = {
					.items = {
						HandinEntry{.item_id = "12268", .count = 1},
						HandinEntry{.item_id = "7100", .count = 1},
					},
					.money = {.platinum = 325},
				},
				.returned = {},
				.handin_check_result = true,
			},
		};

		std::map<std::string, uint32>   hand_ins;
		std::map<std::string, uint32>   required;
		std::vector<EQ::ItemInstance *> items;

		EQEmuLogSys::Instance()->EnableConsoleLogging();

		// turn this on to see debugging output
		EQEmuLogSys::Instance()->log_settings[Logs::NpcHandin].log_to_console = std::getenv("DEBUG") ? 3 : 0;

		for (auto &test: test_cases) {
			required.clear();

			for (auto &hand_in: test.hand_in.items) {
				hand_ins.clear();
				items.clear();

				auto             item_id = Strings::ToInt(hand_in.item_id);
				EQ::ItemInstance *inst   = database.CreateItem(item_id);
				if (inst->IsStackable()) {
					inst->SetCharges(hand_in.count);
				}

				if (inst->GetItem()->MaxCharges > 0) {
					inst->SetCharges(inst->GetItem()->MaxCharges);
				}

				hand_ins[hand_in.item_id] = inst->GetCharges();
				items.push_back(inst);

				npc->CheckHandin(c, hand_ins, required, items);
				npc->ResetHandin();
			}

			// money
			if (test.hand_in.money.platinum > 0) {
				hand_ins["platinum"] = test.hand_in.money.platinum;
			}
			if (test.hand_in.money.gold > 0) {
				hand_ins["gold"] = test.hand_in.money.gold;
			}
			if (test.hand_in.money.silver > 0) {
				hand_ins["silver"] = test.hand_in.money.silver;
			}
			if (test.hand_in.money.copper > 0) {
				hand_ins["copper"] = test.hand_in.money.copper;
			}

			for (auto &req: test.required.items) {
				required[req.item_id] = req.count;
			}

			// money
			if (test.required.money.platinum > 0) {
				required["platinum"] = test.required.money.platinum;
			}
			if (test.required.money.gold > 0) {
				required["gold"] = test.required.money.gold;
			}
			if (test.required.money.silver > 0) {
				required["silver"] = test.required.money.silver;
			}
			if (test.required.money.copper > 0) {
				required["copper"] = test.required.money.copper;
			}

			auto result = npc->CheckHandin(c, hand_ins, required, items);

			RunTest(test.description, test.handin_check_result, result);

			auto returned = npc->ReturnHandinItems(c);

			npc->ResetHandin();

			if (EQEmuLogSys::Instance()->log_settings[Logs::NpcHandin].log_to_console > 0) {
				std::cout << std::endl;
			}
		}

		// Which items a multi-quest NPC will actually BANK vs hand straight back.
		RunMultiQuestBankingTests(c, npc_type);
	}

	std::cout << "\n===========================================\n";
	std::cout << "✅ All NPC Hand-in Tests Completed (Multi-Quest)!\n";
	std::cout << "===========================================\n";
}
